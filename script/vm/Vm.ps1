# Helpers for driving a Hyper-V guest from the host.
# Dot-source this file, then call Initialize-Vm once:
#   . scripts\vm\Vm.ps1
#   Initialize-Vm -Name "Software Tester" -User tester -Password vmtest
#
# Needs PowerShell 7, the Hyper-V PowerShell module and membership of the
# local group "Hyper-V Administrators" (or an elevated shell). Nothing here
# needs elevation once the account is in that group.
#
# What is used for what:
#   files and commands   PowerShell Direct (New-PSSession -VMName), no network
#   a program on the     a scheduled task that runs in the logged-in session;
#   guest's desktop      a PowerShell Direct session has no desktop
#   screenshots          the thumbnail call of the virtualization WMI provider
#   keyboard and mouse   Msvm_Keyboard and Msvm_SyntheticMouse
#   recording            record.ps1, which pipes screenshots to ffmpeg
#
# Microsoft's pages for these interfaces:
#   PowerShell Direct    https://learn.microsoft.com/windows-server/virtualization/hyper-v/powershell-direct
#   screenshot           https://learn.microsoft.com/windows/win32/hyperv_v2/getvirtualsystemthumbnailimage-msvm-virtualsystemmanagementservice
#   keyboard             https://learn.microsoft.com/windows/win32/hyperv_v2/msvm-keyboard
#   key codes            https://learn.microsoft.com/windows/win32/inputdev/virtual-key-codes
#   mouse                https://learn.microsoft.com/windows/win32/hyperv_v2/msvm-syntheticmouse
#   graphics card        https://learn.microsoft.com/windows-hardware/drivers/display/gpu-paravirtualization

$ErrorActionPreference = "Stop"

$script:Vm = $null
$script:VirtualizationNamespace = "root\virtualization\v2"

function Initialize-Vm {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$User = "tester",
        [string]$Password = "vmtest",
        # Folder in the guest that holds everything the test copies in.
        [string]$GuestDir = "C:\vmtest"
    )
    if (-not (Get-Command Get-VM -ErrorAction SilentlyContinue)) {
        throw "the Hyper-V PowerShell module is missing; turn on the Windows feature 'Hyper-V'"
    }
    # A guest account may have no password; ConvertTo-SecureString refuses an
    # empty string. (The guest must then allow blank passwords over
    # PowerShell Direct: HKLM\SYSTEM\CurrentControlSet\Control\Lsa,
    # LimitBlankPasswordUse = 0.)
    $secret = if ($Password) { ConvertTo-SecureString $Password -AsPlainText -Force } else { [securestring]::new() }
    $script:Vm = @{
        Name       = $Name
        User       = $User
        Password   = $Password
        Credential = [pscredential]::new($User, $secret)
        GuestDir   = $GuestDir
        Sequence   = 0
        Recorder   = $null
        # WMI objects of the running VM; cleared whenever the VM stops.
        Devices    = $null
    }
}

function Get-VmState {
    $machine = Get-VM -Name $script:Vm.Name -ErrorAction SilentlyContinue
    if ($machine) { "$($machine.State)" } else { "Missing" }
}

# ------------------------------------------------------------ guest commands

# Open a PowerShell Direct session as the guest user. It fails while Windows
# starts; the callers that expect that use Wait-Guest first.
function New-GuestSession {
    param([int]$Attempts = 4)
    $problem = $null
    foreach ($attempt in 1..$Attempts) {
        try {
            return New-PSSession -VMName $script:Vm.Name -Credential $script:Vm.Credential -ErrorAction Stop
        } catch {
            $problem = $_
            if ($attempt -lt $Attempts) { Start-Sleep -Seconds 5 }
        }
    }
    throw "no PowerShell Direct session to '$($script:Vm.Name)': $($problem.Exception.Message)"
}

# Run a script block in the guest in a session of its own, so that it sees
# the environment (PATH and the rest) as a newly started program would.
# Returns Completed (false after a timeout), Output and Errors.
function Invoke-InGuest {
    param(
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [object[]]$ArgumentList = @(),
        [int]$TimeoutSec = 300,
        # How often to try to open the session; 1 while Windows may not be up yet.
        [int]$Attempts = 4
    )
    $session = New-GuestSession -Attempts $Attempts
    $job = $null
    try {
        $job = Invoke-Command -Session $session -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList -AsJob
        if (-not (Wait-Job $job -Timeout $TimeoutSec)) {
            return [pscustomobject]@{ Completed = $false; Output = @(); Errors = @("no answer within $TimeoutSec seconds") }
        }
        $problems = @()
        $output = @(Receive-Job $job -ErrorAction SilentlyContinue -ErrorVariable problems)
        $errors = @($problems | ForEach-Object { "$_" })
        # A session that broke mid-way leaves its reason on the job, not in the output.
        $reason = $job.ChildJobs | ForEach-Object { $_.JobStateInfo.Reason } | Where-Object { $_ } | Select-Object -First 1
        if ($reason) { $errors += "$($reason.Message)" }
        [pscustomobject]@{
            Completed = $job.State -eq "Completed"
            Output    = $output
            Errors    = $errors
        }
    } finally {
        # Closing the session first ends a command that is still running.
        Remove-PSSession $session -ErrorAction SilentlyContinue
        if ($job) { Remove-Job $job -Force -ErrorAction SilentlyContinue }
    }
}

# Guest-side code of Invoke-GuestExe: start the program named in {{SPEC}},
# collect what it prints, and print the result as one line.
$script:RunExeTemplate = @'
$spec = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('{{SPEC}}')) | ConvertFrom-Json
# Quoted the way Windows programs split a command line: backslashes before a
# quote, and at the end of a quoted argument, are doubled.
$line = (@($spec.arguments) | Where-Object { $null -ne $_ } | ForEach-Object {
        if ($_ -match '[\s"]' -or $_ -eq '') { '"' + ($_ -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"' } else { $_ }
    }) -join ' '
$info = New-Object System.Diagnostics.ProcessStartInfo
$info.FileName = $spec.exe
$info.Arguments = $line
$info.UseShellExecute = $false
$info.RedirectStandardOutput = $true
$info.RedirectStandardError = $true
$info.CreateNoWindow = $true
$process = [System.Diagnostics.Process]::Start($info)
$err = $process.StandardError.ReadToEndAsync()
$out = $process.StandardOutput.ReadToEnd()
$process.WaitForExit()
$answer = @{ code = $process.ExitCode; out = $out; err = $err.Result } | ConvertTo-Json -Compress
"__RESULT=" + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($answer))
$global:LASTEXITCODE = 0
'@

# Run a program in the guest and wait for it. Returns ExitCode (null when it
# did not finish in time), Stdout and Stderr. Where it runs: see
# Invoke-GuestScript. Use Start-GuestExe for a program that opens a window.
function Invoke-GuestExe {
    param(
        [Parameter(Mandatory)][string]$Exe,
        [string[]]$Arguments = @(),
        [int]$TimeoutSec = 300,
        [switch]$Background
    )
    $json = @{ exe = $Exe; arguments = @($Arguments) } | ConvertTo-Json -Compress
    $spec = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
    $run = Invoke-GuestScript -TimeoutSec $TimeoutSec -Background:$Background -Script $script:RunExeTemplate.Replace("{{SPEC}}", $spec)
    if ($run.Output -match '(?m)^__RESULT=(\S+)') {
        $answer = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Matches[1])) | ConvertFrom-Json
        return [pscustomobject]@{ ExitCode = $answer.code; Stdout = "$($answer.out)"; Stderr = "$($answer.err)" }
    }
    [pscustomobject]@{ ExitCode = $null; Stdout = ""; Stderr = ("$($run.Output)`n$($run.Stderr)").Trim() }
}

# Start a program on the desktop of the logged-in guest user and do not wait
# for it. It runs as a scheduled task with normal priority and the user's
# everyday rights, which is as close to a double-click as a script gets.
function Start-GuestExe {
    param(
        [Parameter(Mandatory)][string]$Exe,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory
    )
    $script:Vm.Sequence += 1
    $task = "vmtest-app-{0:d3}" -f $script:Vm.Sequence
    $run = Invoke-InGuest -TimeoutSec 120 -ArgumentList $Exe, $Arguments, $WorkingDirectory, $task -ScriptBlock {
        param($exe, $arguments, $directory, $task)
        Get-ScheduledTask -TaskName "vmtest-app-*" -ErrorAction SilentlyContinue | Where-Object { $_.State -ne "Running" } |
            Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue
        # Quoted as in Invoke-GuestExe, the way Windows programs split a command line.
        $line = (@($arguments) | Where-Object { $null -ne $_ } | ForEach-Object {
                if ($_ -match '[\s"]' -or $_ -eq '') { '"' + ($_ -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"' } else { $_ }
            }) -join " "
        $options = @{ Execute = $exe }
        if ($line) { $options.Argument = $line }
        if ($directory) { $options.WorkingDirectory = $directory }
        $action = New-ScheduledTaskAction @options
        $principal = New-ScheduledTaskPrincipal -UserId "$env:COMPUTERNAME\$env:USERNAME" -LogonType Interactive -RunLevel Limited
        # A task runs below normal priority unless told otherwise.
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Priority 4 -ExecutionTimeLimit ([TimeSpan]::Zero)
        Register-ScheduledTask -TaskName $task -Action $action -Principal $principal -Settings $settings -Force | Out-Null
        Start-ScheduledTask -TaskName $task
        "started"
    }
    if ($run.Output -notcontains "started") { throw "could not start $Exe on the guest's desktop: $($run.Errors -join '; ')" }
}

# Wait for a program's window, click its top edge so that it has the keyboard
# focus, and return where it is on the guest's screen (Left, Top, Right,
# Bottom, in pixels). A window that Start-GuestExe opened does not get the
# focus by itself: Windows gives it only to what the user started, and keys
# sent before this call go to the desktop instead. The returned position
# lets a test click at a place relative to the window.
function Show-GuestWindow {
    param(
        [Parameter(Mandatory)][string]$ProcessName,
        [int]$TimeoutSec = 60
    )
    $run = Invoke-GuestScript -TimeoutSec ($TimeoutSec + 60) -Script @"
Add-Type -Namespace VmTest -Name Window -MemberDefinition '[DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr window, out Rect rect); [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }'
`$deadline = (Get-Date).AddSeconds($TimeoutSec)
do {
    `$process = Get-Process '$ProcessName' -ErrorAction SilentlyContinue | Where-Object { `$_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if (-not `$process) { Start-Sleep -Milliseconds 500 }
} while (-not `$process -and (Get-Date) -lt `$deadline)
if (`$process) {
    `$rect = New-Object VmTest.Window+Rect
    [void][VmTest.Window]::GetWindowRect(`$process.MainWindowHandle, [ref]`$rect)
    "rect=`$(`$rect.Left),`$(`$rect.Top),`$(`$rect.Right),`$(`$rect.Bottom)"
}
"@
    if ($run.Output -notmatch 'rect=(-?\d+),(-?\d+),(-?\d+),(-?\d+)') {
        throw "no window of '$ProcessName' appeared within $TimeoutSec seconds: $($run.Output) $($run.Stderr)"
    }
    $window = [pscustomobject]@{ Left = [int]$Matches[1]; Top = [int]$Matches[2]; Right = [int]$Matches[3]; Bottom = [int]$Matches[4] }
    Send-Click -X ([int](($window.Left + $window.Right) / 2)) -Y ($window.Top + 10)
    $window
}
function New-GuestDirectory {
    param([Parameter(Mandatory)][string]$GuestPath)
    Invoke-InGuest -ArgumentList $GuestPath -ScriptBlock {
        param($path) New-Item -ItemType Directory -Force $path | Out-Null
    } | Out-Null
}

# Copy a file or a folder into a guest folder; a folder arrives under its own
# name. The content travels as one zip file: that is quick for many small
# files, and it leaves behind file attributes the guest does not know (a
# cloud-synced folder marks its files in a way that makes a plain copy fail).
# -MarkDownloaded marks every copied file as downloaded from the internet
# (the Mark of the Web), as a browser does; Windows then treats a script from
# it more strictly, for example under the RemoteSigned policy.
function Copy-ToGuest {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$GuestDirectory,
        [switch]$MarkDownloaded
    )
    $source = (Resolve-Path $Path).Path
    $script:Vm.Sequence += 1
    $name = "vmtest-copy-$PID-$($script:Vm.Sequence).zip"
    $package = Join-Path ([System.IO.Path]::GetTempPath()) $name
    Remove-Item $package -Force -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (Test-Path $source -PathType Container) {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($source, $package, [System.IO.Compression.CompressionLevel]::Fastest, $true)
    } else {
        $archive = [System.IO.Compression.ZipFile]::Open($package, [System.IO.Compression.ZipArchiveMode]::Create)
        try {
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $source, (Split-Path -Leaf $source), [System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
        } finally {
            $archive.Dispose()
        }
    }
    $session = New-GuestSession
    try {
        $guestPackage = Join-Path $script:Vm.GuestDir $name
        Invoke-Command -Session $session -ArgumentList $script:Vm.GuestDir -ScriptBlock {
            param($staging) New-Item -ItemType Directory -Force $staging | Out-Null
        }
        Copy-Item -ToSession $session -Path $package -Destination $guestPackage -Force
    } finally {
        Remove-PSSession $session -ErrorAction SilentlyContinue
        Remove-Item $package -Force -ErrorAction SilentlyContinue
    }
    $mark = ""
    if ($MarkDownloaded) {
        $copied = Join-Path $GuestDirectory (Split-Path -Leaf $source)
        $mark = "Get-ChildItem -LiteralPath '$copied' -Recurse -File -Force | ForEach-Object { Set-Content -LiteralPath `$_.FullName -Stream Zone.Identifier -Value '[ZoneTransfer]', 'ZoneId=3' }"
    }
    # Unpacked by the user, so that the files belong to the user as downloaded files do.
    $run = Invoke-GuestScript -TimeoutSec 600 -Script @"
New-Item -ItemType Directory -Force '$GuestDirectory' | Out-Null
Expand-Archive -Path '$guestPackage' -DestinationPath '$GuestDirectory' -Force
Remove-Item '$guestPackage' -Force
$mark
"@
    if (-not $run.Completed -or $run.ExitCode -ne 0) { throw "could not unpack $Path in the guest: $($run.Output) $($run.Stderr)" }
}
# Copy a file or a folder out of the guest.
function Copy-FromGuest {
    param(
        [Parameter(Mandatory)][string]$GuestPath,
        [Parameter(Mandatory)][string]$Destination
    )
    $session = New-GuestSession
    try {
        Copy-Item -FromSession $session -Path $GuestPath -Destination $Destination -Recurse -Force
    } finally {
        Remove-PSSession $session -ErrorAction SilentlyContinue
    }
}

# Run PowerShell code in the guest as a new Windows PowerShell 5.1 process,
# which is what a clean Windows has. The code travels as a file, so it needs
# no quoting. Returns the output, the exit code the code left in
# $LASTEXITCODE (0 when it ran no program), and Completed, which is false
# when the code did not run to its end.
#
# By default the code runs where the user's own programs run: in the
# logged-in desktop session, with the user's everyday rights, without a
# window of its own. It can see the windows on the desktop, and a dialog it
# raises shows in a screenshot. With -Background it runs in the PowerShell
# Direct session instead: elevated and without a desktop. Use that for
# housekeeping, not for what a user would do.
function Invoke-GuestScript {
    param(
        [Parameter(Mandatory)][string]$Script,
        [int]$TimeoutSec = 300,
        [switch]$Background
    )
    $script:Vm.Sequence += 1
    $task = "vmtest-{0:d3}" -f $script:Vm.Sequence
    $file = Join-Path $script:Vm.GuestDir "$task.ps1"
    $body = @"
# This file runs with -ExecutionPolicy Bypass, which travels to every child
# process in this variable. Without it, what the code starts sees the policy
# the guest really has.
Remove-Item Env:PSExecutionPolicyPreference -ErrorAction SilentlyContinue
& {
`$ErrorActionPreference = 'Continue'
`$global:LASTEXITCODE = 0
try {
$Script
    `$__code = `$global:LASTEXITCODE
} catch {
    `$_ | Out-String | Write-Output
    `$__code = 997
}
Write-Output "__EXIT=`$__code"
} 2>&1 | ForEach-Object { "`$_" } | Out-File -FilePath "`$PSCommandPath.out" -Encoding utf8 -Width 8192
"@
    $inBackground = [bool]$Background
    $run = Invoke-InGuest -TimeoutSec ($TimeoutSec + 60) -ArgumentList $file, $body, $TimeoutSec, $inBackground, $task -ScriptBlock {
        param($file, $body, $timeout, $background, $task)
        $ErrorActionPreference = "Continue"
        New-Item -ItemType Directory -Force (Split-Path -Parent $file) | Out-Null
        [System.IO.File]::WriteAllText($file, $body, (New-Object System.Text.UTF8Encoding $true))
        $out = "$file.out"
        Remove-Item $out -Force -ErrorAction SilentlyContinue
        $shell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        if ($background) {
            & $shell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $file | Out-Null
        } else {
            # conhost --headless gives the console program no window, so nothing
            # flashes on the desktop and the program under test keeps the focus.
            $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\conhost.exe" `
                -Argument "--headless `"$shell`" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$file`""
            $principal = New-ScheduledTaskPrincipal -UserId "$env:COMPUTERNAME\$env:USERNAME" -LogonType Interactive -RunLevel Limited
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Priority 4 -ExecutionTimeLimit ([TimeSpan]::Zero)
            Register-ScheduledTask -TaskName $task -Action $action -Principal $principal -Settings $settings -Force | Out-Null
            Start-ScheduledTask -TaskName $task
            $deadline = (Get-Date).AddSeconds($timeout)
            $idle = 0
            while ((Get-Date) -lt $deadline) {
                Start-Sleep -Milliseconds 500
                if ((Test-Path $out) -and (Select-String -Path $out -Pattern '^__EXIT=' -Quiet)) { break }
                # A task that stopped without the last line has crashed or was closed.
                if ((Get-ScheduledTask -TaskName $task).State -eq "Running") { $idle = 0 } else { $idle += 1 }
                if ($idle -ge 20) { break }
            }
            Stop-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
        }
        if (Test-Path $out) { Get-Content $out }
    }
    $code = $null
    $lines = foreach ($line in $run.Output) {
        if ("$line" -match '^__EXIT=(-?\d+)$') { $code = [int]$Matches[1] } else { "$line" }
    }
    [pscustomobject]@{
        ExitCode  = $code
        Output    = ($lines -join "`n").Trim()
        Stderr    = ($run.Errors -join "`n").Trim()
        Completed = $null -ne $code
    }
}

# ------------------------------------------------------------ power

# Wait until the guest user is logged in at the desktop and commands answer.
function Wait-Guest {
    param([int]$TimeoutSec = 900)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if ((Get-VmState) -eq "Running") {
            try {
                $user = $script:Vm.User
                $run = Invoke-InGuest -TimeoutSec 60 -Attempts 1 -ArgumentList $user -ScriptBlock {
                    param($user)
                    $shell = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" |
                        Where-Object { (Invoke-CimMethod -InputObject $_ -MethodName GetOwner).User -eq $user }
                    if ($shell) { "desktop" }
                }
                if ($run.Output -contains "desktop") { return }
            } catch {
                # Windows is still starting.
            }
        }
        Start-Sleep -Seconds 5
    }
    throw "the guest did not reach a logged-in desktop within $TimeoutSec seconds"
}

function Wait-VmState {
    param(
        [Parameter(Mandatory)][string]$State,
        [int]$TimeoutSec = 300
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if ((Get-VmState) -eq $State) { return $true }
        Start-Sleep -Seconds 2
    }
    $false
}

function Start-Guest {
    $script:Vm.Devices = $null
    if ((Get-VmState) -ne "Running") { Start-VM -Name $script:Vm.Name }
}

# Ask Windows to shut down; pull the plug if it does not within the timeout.
function Stop-Guest {
    param([int]$TimeoutSec = 180)
    $script:Vm.Devices = $null
    if ((Get-VmState) -eq "Off") { return }
    try {
        Stop-VM -Name $script:Vm.Name -Force -AsJob | Out-Null
    } catch {
        # Falls through to the plug.
    }
    if (-not (Wait-VmState -State "Off" -TimeoutSec $TimeoutSec)) {
        Stop-VM -Name $script:Vm.Name -TurnOff -Force
        Wait-VmState -State "Off" -TimeoutSec 60 | Out-Null
    }
}

# Shut Windows down and start it again.
function Restart-Guest {
    Stop-Guest
    Start-Guest
}

# Put the VM back to the named checkpoint. A checkpoint taken while the VM
# was off leaves it off; Start-Guest then boots it.
function Restore-Guest {
    param([string]$Snapshot = "clean")
    $script:Vm.Devices = $null
    if ((Get-VmState) -ne "Off") {
        Stop-VM -Name $script:Vm.Name -TurnOff -Force
        Wait-VmState -State "Off" -TimeoutSec 60 | Out-Null
    }
    Restore-VMCheckpoint -VMName $script:Vm.Name -Name $Snapshot -Confirm:$false
}

# How busy the guest's processors are, in percent of all of them, averaged
# over the given time. Measured by the host, so it works when the guest is too
# busy to answer a command, which is exactly when the number matters.
function Get-GuestProcessorLoad {
    param([int]$Seconds = 10)
    $samples = Get-Counter '\Hyper-V Hypervisor Virtual Processor(*)\% Guest Run Time' -SampleInterval 1 -MaxSamples $Seconds
    $prefix = $script:Vm.Name.ToLowerInvariant() + ":"
    $values = @($samples | ForEach-Object { $_.CounterSamples } |
            Where-Object { $_.InstanceName.StartsWith($prefix) } | ForEach-Object { $_.CookedValue })
    if (-not $values.Count) { throw "the host has no processor counters for '$($script:Vm.Name)'; is it running?" }
    [math]::Round(($values | Measure-Object -Average).Average, 1)
}

# Wait until the guest's processors are quiet and return their load. Right
# after a start or an install Windows is busy by itself for a minute or two,
# and a measurement taken then says nothing about the program under test.
function Wait-GuestIdle {
    param([int]$BelowPercent = 20, [int]$TimeoutSec = 180)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    do { $load = Get-GuestProcessorLoad -Seconds 5 } while ($load -ge $BelowPercent -and (Get-Date) -lt $deadline)
    $load
}
# ------------------------------------------------------------ screen, keys, mouse

function Get-VmDevices {
    if ($script:Vm.Devices) { return $script:Vm.Devices }
    $namespace = $script:VirtualizationNamespace
    $name = $script:Vm.Name -replace "'", "''"
    $system = Get-CimInstance -Namespace $namespace -ClassName Msvm_ComputerSystem -Filter "ElementName='$name'"
    if (-not $system) { throw "no virtual machine named '$($script:Vm.Name)'" }
    $script:Vm.Devices = @{
        System   = $system
        Settings = Get-CimAssociatedInstance -InputObject $system -ResultClassName Msvm_VirtualSystemSettingData -Association Msvm_SettingsDefineState
        Service  = Get-CimInstance -Namespace $namespace -ClassName Msvm_VirtualSystemManagementService
        Keyboard = Get-CimAssociatedInstance -InputObject $system -ResultClassName Msvm_Keyboard
        Mouse    = Get-CimAssociatedInstance -InputObject $system -ResultClassName Msvm_SyntheticMouse | Select-Object -First 1
    }
    $script:Vm.Devices
}

# Width and height of the guest's screen in pixels; null while the VM is off.
function Get-GuestScreenSize {
    $devices = Get-VmDevices
    $head = Get-CimInstance -Namespace $script:VirtualizationNamespace -ClassName Msvm_VideoHead -Filter "SystemName='$($devices.System.Name)'" |
        Select-Object -First 1
    if (-not $head -or -not $head.CurrentHorizontalResolution) { return $null }
    [pscustomobject]@{ Width = [int]$head.CurrentHorizontalResolution; Height = [int]$head.CurrentVerticalResolution }
}

# The guest's screen as raw pixels, two bytes each (RGB565), scaled to the
# given size. Null when the VM shows nothing.
function Get-GuestScreenBytes {
    param([Parameter(Mandatory)][int]$Width, [Parameter(Mandatory)][int]$Height)
    $devices = Get-VmDevices
    $answer = Invoke-CimMethod -InputObject $devices.Service -MethodName GetVirtualSystemThumbnailImage -Arguments @{
        TargetSystem = $devices.Settings
        WidthPixels  = [uint16]$Width
        HeightPixels = [uint16]$Height
    }
    if ($answer.ReturnValue -ne 0 -or -not $answer.ImageData) { return $null }
    $bytes = [byte[]]$answer.ImageData
    # The WMI layer puts the array's length in front of the pixels.
    $pixels = $Width * $Height * 2
    if ($bytes.Length -eq $pixels + 4) {
        $picture = [byte[]]::new($pixels)
        [Array]::Copy($bytes, 4, $picture, 0, $pixels)
        $bytes = $picture
    }
    , $bytes
}

# Save the guest's screen as a PNG at its own size. Colors come from the
# host as 16 bits per pixel, so smooth gradients show faint bands.
function Save-Screenshot {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Force (Split-Path -Parent $Path) | Out-Null
    $size = Get-GuestScreenSize
    if (-not $size) { throw "the guest shows no screen (state $(Get-VmState))" }
    $bytes = Get-GuestScreenBytes -Width $size.Width -Height $size.Height
    if (-not $bytes) { throw "the host returned no picture of the guest's screen" }
    Add-Type -AssemblyName System.Drawing
    $bitmap = [System.Drawing.Bitmap]::new($size.Width, $size.Height, [System.Drawing.Imaging.PixelFormat]::Format16bppRgb565)
    try {
        $area = [System.Drawing.Rectangle]::new(0, 0, $size.Width, $size.Height)
        $data = $bitmap.LockBits($area, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, $bitmap.PixelFormat)
        $rowBytes = $size.Width * 2
        foreach ($row in 0..($size.Height - 1)) {
            [System.Runtime.InteropServices.Marshal]::Copy($bytes, $row * $rowBytes, [IntPtr]::Add($data.Scan0, $row * $data.Stride), $rowBytes)
        }
        $bitmap.UnlockBits($data)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $bitmap.Dispose()
    }
    $Path
}

function Invoke-Device {
    param([string]$Device, [string]$Method, [hashtable]$Arguments = @{})
    $target = (Get-VmDevices)[$Device]
    if (-not $target) { throw "the VM has no $Device device; is it running?" }
    $answer = Invoke-CimMethod -InputObject $target -MethodName $Method -Arguments $Arguments
    if ($answer.ReturnValue -ne 0) { throw "$Device.$Method failed with $($answer.ReturnValue)" }
}

# Windows virtual-key codes. Letters and digits are their own character codes.
$script:KeyCodes = @{
    "backspace" = 0x08; "tab" = 0x09; "enter" = 0x0D; "shift" = 0x10; "ctrl" = 0x11; "alt" = 0x12
    "esc" = 0x1B; "space" = 0x20; "pgup" = 0x21; "pgdn" = 0x22; "end" = 0x23; "home" = 0x24
    "left" = 0x25; "up" = 0x26; "right" = 0x27; "down" = 0x28; "insert" = 0x2D; "delete" = 0x2E
    "win" = 0x5B; "f1" = 0x70; "f2" = 0x71; "f3" = 0x72; "f4" = 0x73; "f5" = 0x74; "f6" = 0x75
    "f7" = 0x76; "f8" = 0x77; "f9" = 0x78; "f10" = 0x79; "f11" = 0x7A; "f12" = 0x7B
    "equals" = 0xBB; "minus" = 0xBD
}

# Press keys on the guest's keyboard. Each argument is one key or a chord
# joined with "+": Send-Keys "ctrl+k", "down", "enter". A chord holds its keys
# down in order and releases them in reverse, as a hand does.
function Send-Keys {
    param(
        [Parameter(Mandatory, Position = 0)][string[]]$Keys,
        [int]$DelayMs = 150
    )
    foreach ($chord in $Keys) {
        $codes = foreach ($name in ($chord.ToLowerInvariant() -split "\+")) {
            if ($script:KeyCodes.ContainsKey($name)) { [uint32]$script:KeyCodes[$name] }
            elseif ($name -match '^[a-z0-9]$') { [uint32][char]$name.ToUpperInvariant() }
            else { throw "unknown key '$name'" }
        }
        $codes = @($codes)
        foreach ($code in $codes) { Invoke-Device Keyboard PressKey @{ KeyCode = $code }; Start-Sleep -Milliseconds 30 }
        [array]::Reverse($codes)
        foreach ($code in $codes) { Invoke-Device Keyboard ReleaseKey @{ KeyCode = $code }; Start-Sleep -Milliseconds 30 }
        Start-Sleep -Milliseconds $DelayMs
    }
}

# Type plain ASCII text on the guest's keyboard, one character at a time.
# Handed over as one string, or faster than this, the guest loses characters.
function Send-Text {
    param(
        [Parameter(Mandatory)][string]$Text,
        [int]$DelayMs = 60
    )
    foreach ($character in $Text.ToCharArray()) {
        Invoke-Device Keyboard TypeText @{ AsciiText = [string]$character }
        Start-Sleep -Milliseconds $DelayMs
    }
    Start-Sleep -Milliseconds 300
}

# Move the guest's pointer to a point of its screen, in pixels from the top left.
function Move-Pointer {
    param([Parameter(Mandatory)][int]$X, [Parameter(Mandatory)][int]$Y)
    Invoke-Device Mouse SetAbsolutePosition @{ HorizontalPosition = [int32]$X; VerticalPosition = [int32]$Y }
}

# Click at a point of the guest's screen. Read the point off a screenshot.
function Send-Click {
    param(
        [Parameter(Mandatory)][int]$X,
        [Parameter(Mandatory)][int]$Y,
        [ValidateSet("left", "right", "middle")][string]$Button = "left",
        [switch]$Double
    )
    $index = @{ left = 1; right = 2; middle = 3 }[$Button]
    Move-Pointer -X $X -Y $Y
    Start-Sleep -Milliseconds 150
    Invoke-Device Mouse ClickButton @{ ButtonIndex = [uint32]$index }
    if ($Double) {
        Start-Sleep -Milliseconds 80
        Invoke-Device Mouse ClickButton @{ ButtonIndex = [uint32]$index }
    }
    Start-Sleep -Milliseconds 300
}

# Turn the mouse wheel; a positive number scrolls up.
function Send-Scroll {
    param([Parameter(Mandatory)][int]$Notches)
    Invoke-Device Mouse SetScrollPosition @{ ScrollPositionDelta = [int32]($Notches * 120) }
    Start-Sleep -Milliseconds 300
}

# ------------------------------------------------------------ Windows Update
# Windows version of the running guest as "build.revision", for example 26200.6584.
function Get-GuestBuild {
    $run = Invoke-InGuest -TimeoutSec 120 -ScriptBlock {
        $current = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        "$($current.CurrentBuild).$($current.UBR)"
    }
    "$($run.Output | Select-Object -Last 1)"
}

# Install the updates whose title matches the pattern in the running guest,
# through Windows Update, and return the log. The guest needs internet. The
# work is done by guest\update-windows.ps1 as a SYSTEM task; restart the
# guest afterwards. Takes from ten minutes to over an hour.
function Update-GuestWindows {
    param(
        # The monthly Windows update: "2026-11 Security Update (KB...)", earlier
        # "... Cumulative Update for Windows 11 ...". Not the .NET or Defender ones.
        [string]$Pattern = '^\d{4}-\d{2} (Security|Cumulative) Update',
        [int]$TimeoutMin = 120
    )
    $updateScript = Get-Content (Join-Path $PSScriptRoot "guest\update-windows.ps1") -Raw
    $log = Join-Path $script:Vm.GuestDir "update.log"
    $start = Invoke-InGuest -TimeoutSec 120 -ArgumentList $updateScript, $script:Vm.GuestDir, $Pattern, $log -ScriptBlock {
        param($updateScript, $directory, $pattern, $log)
        New-Item -ItemType Directory -Force $directory | Out-Null
        $file = Join-Path $directory "update-windows.ps1"
        [System.IO.File]::WriteAllText($file, $updateScript, (New-Object System.Text.UTF8Encoding $true))
        Remove-Item $log -Force -ErrorAction SilentlyContinue
        $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
            -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$file`" -Pattern `"$pattern`" -Log `"$log`""
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
        Register-ScheduledTask -TaskName "vmtest-update" -Action $action -Principal $principal -Settings $settings -Force | Out-Null
        Start-ScheduledTask -TaskName "vmtest-update"
        "started"
    }
    if ($start.Output -notcontains "started") { throw "could not start the update in the guest: $($start.Errors -join '; ')" }
    $deadline = (Get-Date).AddMinutes($TimeoutMin)
    $lines = @()
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 30
        try {
            $read = Invoke-InGuest -TimeoutSec 60 -Attempts 1 -ArgumentList $log -ScriptBlock { param($log) if (Test-Path $log) { Get-Content $log } }
            $lines = @($read.Output | ForEach-Object { "$_" })
        } catch {
            # The guest is busy installing; ask again.
        }
        if ($lines | Where-Object { $_ -match '^\S+ (DONE|FAILED)' }) { break }
    }
    Invoke-InGuest -TimeoutSec 60 -ScriptBlock { Unregister-ScheduledTask -TaskName "vmtest-update" -Confirm:$false -ErrorAction SilentlyContinue } | Out-Null
    $lines
}
# ------------------------------------------------------------ graphics card
# A guest normally has the "Microsoft Hyper-V Video" adapter only and draws
# everything on the processor. These helpers give it a share of the host's
# graphics card (GPU paravirtualization, the mechanism Windows Sandbox and
# WSL use). Microsoft documents GPU partitioning for Windows Server hosts and
# data-center cards; on a Windows 11 host with a desktop card it works when
# Get-VMHostPartitionableGpu lists the card, but it is not a supported setup.
#   https://learn.microsoft.com/windows-server/virtualization/hyper-v/gpu-partitioning
#   https://learn.microsoft.com/windows-hardware/drivers/display/gpu-paravirtualization

# Folder in the host's driver store that holds the driver of the first
# graphics card Hyper-V can share.
function Get-HostGpuDriverFolder {
    $gpu = Get-VMHostPartitionableGpu | Select-Object -First 1
    if (-not $gpu) { throw "this host has no graphics card that Hyper-V can share (Get-VMHostPartitionableGpu is empty)" }
    # \\?\PCI#VEN_...#4&22f77229&0&0008#{guid}\GPUPARAV  ->  PCI\VEN_...\4&22f77229&0&0008
    if ($gpu.Name -notmatch '^\\\\\?\\(.+?)#\{') { throw "cannot read a device id from '$($gpu.Name)'" }
    $device = $Matches[1] -replace '#', '\'
    $service = (Get-PnpDeviceProperty -InstanceId $device -KeyName DEVPKEY_Device_Service).Data
    $image = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\$service").ImagePath
    if ($image -notmatch '(?i)DriverStore\\FileRepository\\([^\\]+)\\') { throw "the driver of $device is not in the driver store: $image" }
    Join-Path $env:SystemRoot "System32\DriverStore\FileRepository\$($Matches[1])"
}

# Copy the host's graphics driver into the running guest. The guest loads its
# user-mode half from System32\HostDriverStore; Windows does not copy it there
# by itself. About 2 GB for an NVIDIA driver. Repeat after a driver update on
# the host: guest and host must hold the same version.
function Copy-GpuDriverToGuest {
    $folder = Get-HostGpuDriverFolder
    $name = Split-Path -Leaf $folder
    $package = Join-Path ([System.IO.Path]::GetTempPath()) "vmtest-gpu-$PID.zip"
    Remove-Item $package -Force -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::Open($package, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        # Without the Linux libraries the driver carries for WSL.
        foreach ($file in Get-ChildItem $folder -Recurse -File | Where-Object { $_.Name -notmatch '\.so(\.|$)' }) {
            $entry = $file.FullName.Substring($folder.Length + 1) -replace '\\', '/'
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $entry, [System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
        }
    } finally {
        $archive.Dispose()
    }
    $session = New-GuestSession
    try {
        $guestPackage = "C:\vmtest-gpu.zip"
        Copy-Item -ToSession $session -Path $package -Destination $guestPackage -Force
        # The PowerShell Direct session is elevated, which System32 needs.
        Invoke-Command -Session $session -ArgumentList $guestPackage, $name -ScriptBlock {
            param($package, $name)
            $target = Join-Path $env:SystemRoot "System32\HostDriverStore\FileRepository\$name"
            if (Test-Path $target) { Remove-Item $target -Recurse -Force }
            New-Item -ItemType Directory -Force $target | Out-Null
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($package, $target)
            Remove-Item $package -Force
        }
    } finally {
        Remove-PSSession $session -ErrorAction SilentlyContinue
        Remove-Item $package -Force -ErrorAction SilentlyContinue
    }
    $name
}

# Attach a share of the host's graphics card to the VM, which must be off.
# The settings are those of Microsoft's GPU paravirtualization sample. A
# checkpoint does not keep the adapter, so call this after every Restore-Guest.
function Enable-GuestGpu {
    if ((Get-VmState) -ne "Off") { throw "turn the VM off before attaching the graphics card" }
    if (-not (Get-VMGpuPartitionAdapter -VMName $script:Vm.Name -ErrorAction SilentlyContinue)) {
        Add-VMGpuPartitionAdapter -VMName $script:Vm.Name
    }
    Set-VM -Name $script:Vm.Name -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 1GB -HighMemoryMappedIoSpace 16GB
}

function Disable-GuestGpu {
    if ((Get-VmState) -ne "Off") { throw "turn the VM off before removing the graphics card" }
    Get-VMGpuPartitionAdapter -VMName $script:Vm.Name -ErrorAction SilentlyContinue | Remove-VMGpuPartitionAdapter
}

# Whether the running guest holds the same graphics driver as the host. The
# driver's folder name changes with every driver version, so after a driver
# update on the host the guest's copy is stale and the card may not start
# there. provision-gpu.ps1 -Force copies the new one and retakes the checkpoint.
function Test-GuestGpuDriver {
    $expected = Split-Path -Leaf (Get-HostGpuDriverFolder)
    $run = Invoke-InGuest -TimeoutSec 120 -ScriptBlock {
        Get-ChildItem "$env:SystemRoot\System32\HostDriverStore\FileRepository" -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }
    }
    $found = @($run.Output | ForEach-Object { "$_" })
    [pscustomobject]@{ Match = $found -contains $expected; HostDriver = $expected; GuestDrivers = $found }
}
# Whether the logged-in desktop has a screen. With a graphics card attached,
# Windows 11 builds 26100.4484 to 26100.7170 (and the same revisions of
# 26200) lose it: the session's display device is then "WinDisc", the host's
# screenshots stay on the boot logo, and nothing is drawn at all, which makes
# an idle-load measurement look perfect. Microsoft fixed it in KB5068861
# (revision 7171); Update-GuestWindows brings a guest past it.
function Test-GuestDisplay {
    $run = Invoke-GuestScript -TimeoutSec 120 -Script 'Add-Type -AssemblyName System.Windows.Forms; "device=" + [System.Windows.Forms.Screen]::PrimaryScreen.DeviceName'
    $run.Output -match 'device=\\\\\.\\DISPLAY'
}
# Display adapters as the guest sees them: name, driver version, and whether
# Windows started the device (problem code 0).
function Get-GuestDisplayAdapters {
    $run = Invoke-InGuest -TimeoutSec 120 -ScriptBlock {
        Get-CimInstance Win32_VideoController | ForEach-Object { "$($_.Name) | driver $($_.DriverVersion) | problem code $($_.ConfigManagerErrorCode)" }
    }
    $run.Output | ForEach-Object { "$_" }
}
# ------------------------------------------------------------ recording

function Find-Ffmpeg {
    $found = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($found) { $found.Source } else { $null }
}

# Record the guest's screen to an MP4 file until Stop-Recording. Hyper-V has
# no recorder, so record.ps1 takes screenshots and hands them to ffmpeg.
# Returns false, and records nothing, when ffmpeg is not on PATH.
function Start-Recording {
    param(
        [Parameter(Mandatory)][string]$Path,
        [int]$Fps = 4,
        # Width of the film in pixels. A full-size picture takes the host over
        # half a second to hand over, one of 1280 pixels a fifth of a second.
        [int]$Width = 1280
    )
    $ffmpeg = Find-Ffmpeg
    if (-not $ffmpeg) {
        Write-Warning "ffmpeg is not on PATH; the screen is not recorded"
        return $false
    }
    New-Item -ItemType Directory -Force (Split-Path -Parent $Path) | Out-Null
    $stop = "$Path.stop"
    Remove-Item $stop, $Path -Force -ErrorAction SilentlyContinue
    $arguments = "-NoProfile", "-File", (Join-Path $PSScriptRoot "record.ps1"),
        "-VmName", $script:Vm.Name, "-Path", $Path, "-StopFile", $stop, "-Fps", $Fps, "-Width", $Width, "-Ffmpeg", $ffmpeg
    $process = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList ($arguments | ForEach-Object { if ("$_" -match '\s') { "`"$_`"" } else { "$_" } }) `
        -WindowStyle Hidden -PassThru
    $script:Vm.Recorder = @{ Process = $process; Stop = $stop }
    $true
}

function Stop-Recording {
    $recorder = $script:Vm.Recorder
    if (-not $recorder) { return }
    Set-Content -Path $recorder.Stop -Value "stop"
    if (-not $recorder.Process.WaitForExit(60000)) { $recorder.Process.Kill() }
    Remove-Item $recorder.Stop -Force -ErrorAction SilentlyContinue
    $script:Vm.Recorder = $null
}
