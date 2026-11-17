#Requires -Version 7.0
# Install Rich.rmskin into a clean Hyper-V guest the way the README says
# (install Rainmeter, run Rich.rmskin), use it, reinstall it, and keep the evidence.
#   pwsh script/vm/test-rich.ps1 -Package dist/Rich.rmskin -RainmeterInstaller <Rainmeter-4.5.x.exe>
#
# Every run starts from the VM's "Clean" checkpoint (see provision.ps1). Results go
# to report\vm-test-<date>\: screenshots\, recording\session.mp4, logs\results.json,
# logs\facts-*.json, logs\Rainmeter.log and logs\run.log. The script decides what a
# program can decide (files, plugins, active configs, log errors, settings kept);
# whether a widget is drawn correctly is for whoever reads the screenshots.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Password', Justification = 'Throwaway test-VM account, same convention as Vm.ps1.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Pace', Justification = 'Read by Wait-For in script scope.')]
param(
    [string]$VmName = "Tiny 11",
    # The .rmskin to test. Test what ships: the release asset or build-package.ps1 output.
    [Parameter(Mandatory)][string]$Package,
    # Rainmeter's official installer (github.com/rainmeter/rainmeter/releases).
    [Parameter(Mandatory)][string]$RainmeterInstaller,
    [string]$Report,
    [string]$User = "Software Tester",
    [string]$Password = "",
    [string]$Snapshot = "Clean",
    [switch]$KeepRunning,
    # Multiplies every wait; raise it on a slow host.
    [double]$Pace = 1.0
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "Vm.ps1")
Initialize-Vm -Name $VmName -User $User -Password $Password

# ---------------------------------------------------------------- settings
$guestHome = "C:\Users\$User"
$guestDownloads = "$guestHome\Downloads"
$rainmeterExe = "C:\Program Files\Rainmeter\Rainmeter.exe"
$guestSkins = "$guestHome\Documents\Rainmeter\Skins"
$guestGlobal = "$guestSkins\Rich\@Resources\Variables\Global.inc"
$guestSettings = "$guestHome\AppData\Roaming\Rainmeter"
# Third-party plugins the package must install (the rest ship with Rainmeter).
$bundledPlugins = "AppVolume", "Chameleon", "ConfigActive", "FrostedGlass", "MediaPlayer", "TrayIcon"
# Widgets loaded in D2 (config, file, x, y); between them they use every bundled
# plugin but TrayIcon. A new config opens at 0,0, so each is moved to its own spot
# along the bottom of the 1024x768 screen, clear of the centred installer dialog.
$widgets = @(
    @("Rich\Widgets\Clock", "Small.ini", 20, 560), @("Rich\Widgets\Calendar", "Medium.ini", 120, 520),
    @("Rich\Widgets\Monitor", "Medium.ini", 320, 520), @("Rich\Widgets\Volume", "Medium.ini", 520, 520),
    @("Rich\Widgets\Music", "Medium.ini", 720, 520)
)
# Skins that sit on top of the installer dialog and take the focus click meant for it.
$overlapping = "Rich", "illustro\Welcome"

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Package = (Resolve-Path $Package).Path
$RainmeterInstaller = (Resolve-Path $RainmeterInstaller).Path
if (-not $Report) { $Report = Join-Path $root ("report\vm-test-" + (Get-Date -Format "yyyy-MM-dd")) }
$shots = Join-Path $Report "screenshots"
$logs = Join-Path $Report "logs"
New-Item -ItemType Directory -Force $shots, $logs, (Join-Path $Report "recording") | Out-Null
$Report = (Resolve-Path $Report).Path
Get-ChildItem $shots -Filter "*.png" | Remove-Item -Force
Get-ChildItem $logs -Filter "facts-*.json" | Remove-Item -Force
Start-Transcript -Path (Join-Path $logs "run.log") -Force | Out-Null
$guestPackage = "$guestDownloads\$(Split-Path -Leaf $Package)"
$guestInstaller = "$guestDownloads\$(Split-Path -Leaf $RainmeterInstaller)"

# ---------------------------------------------------------------- harness
$results = [System.Collections.Generic.List[object]]::new()
$shotCount = 0

function Wait-For { param([double]$Seconds) Start-Sleep -Milliseconds ([int]($Seconds * 1000 * $Pace)) }

function Shot {
    param([string]$Name)
    $script:shotCount += 1
    $file = "{0:d2}-{1}.png" -f $script:shotCount, $Name
    Save-Screenshot (Join-Path $shots $file) | Out-Null
    $file
}

function Add-Result {
    param(
        [string]$Id, [string]$Title, [string]$Expect,
        [ValidateSet("pass", "fail", "note", "error")][string]$Status,
        [string]$Observed, [string[]]$Shots = @(), [string]$Output = ""
    )
    $results.Add([pscustomobject]@{
            id = $Id; title = $Title; expect = $Expect; status = $Status
            observed = $Observed; screenshots = $Shots; output = $Output
        })
    "{0,-5} {1,-4} {2}" -f $Status, $Id, $Observed
    $results | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $logs "results.json")
}

function Test-Case {
    param([string]$Id, [string]$Title, [string]$Expect, [scriptblock]$Body)
    try {
        & $Body
    } catch {
        $shot = try { Shot "$Id-error" } catch { $null }
        Add-Result -Id $Id -Title $Title -Expect $Expect -Status error `
            -Observed "the harness failed: $($_.Exception.Message)" -Shots @($shot | Where-Object { $_ })
    }
}

# Facts about Rainmeter and Rich in the guest, as an object. Throws when the guest
# prints nothing: a command that timed out must never read as "nothing there".
function Get-GuestFact {
    param([string]$Name, [int]$TimeoutSec = 300)
    $run = Invoke-GuestScript -TimeoutSec $TimeoutSec -Script @"
`$skins = '$guestSkins'
`$rich = Join-Path `$skins 'Rich'
`$settings = '$guestSettings'
`$ini = Join-Path `$settings 'Rainmeter.ini'
`$log = Join-Path `$settings 'Rainmeter.log'
function Get-Machine(`$path) { `$b = [IO.File]::ReadAllBytes(`$path); '{0:X4}' -f [BitConverter]::ToUInt16(`$b, [BitConverter]::ToInt32(`$b, 0x3C) + 4) }
`$active = @()
if (Test-Path `$ini) {
    `$section = ''
    foreach (`$line in (Get-Content `$ini)) {
        if (`$line -match '^\[(.+)\]\s*$') { `$section = `$Matches[1]; continue }
        if (`$section -like 'Rich*' -and `$line -match '^Active=(\d+)' -and [int]`$Matches[1] -gt 0) { `$active += "`$section #`$(`$Matches[1])" }
    }
}
`$palette = `$null
if (Test-Path '$guestGlobal') { `$palette = (Get-Content '$guestGlobal' | Where-Object { `$_ -match '^Palette=' } | Select-Object -First 1) -replace '^Palette=', '' }
`$version = `$null
if (Test-Path (Join-Path `$rich 'Settings.ini')) { `$version = (Get-Content (Join-Path `$rich 'Settings.ini') | Where-Object { `$_ -match '^Version=' } | Select-Object -First 1) -replace '^Version=', '' }
`$logProblems = @()
if (Test-Path `$log) { `$logProblems = @(Get-Content `$log | Where-Object { `$_ -match '^(ERRO|WARN)' } | Select-Object -Last 40 | ForEach-Object { [string]`$_ }) }
`$crashes = @(Get-WinEvent -FilterHashtable @{ LogName = 'Application'; ProviderName = 'Application Error', 'Application Hang'; StartTime = (Get-Date).AddHours(-12) } -ErrorAction SilentlyContinue |
        Where-Object { `$_.Message -match 'Rainmeter|SkinInstaller' } | Select-Object -First 10 | ForEach-Object { `$_.TimeCreated.ToString('o') + ' ' + `$_.Message.Substring(0, [Math]::Min(400, `$_.Message.Length)) })
[ordered]@{
    build        = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
    rainmeter    = Test-Path '$rainmeterExe'
    running      = @(Get-Process Rainmeter -ErrorAction SilentlyContinue).Count
    installer    = @(Get-Process SkinInstaller -ErrorAction SilentlyContinue).Count
    skinsFolder  = Test-Path `$skins
    richFiles    = @(Get-ChildItem `$rich -Recurse -File -ErrorAction SilentlyContinue).Count
    version      = `$version
    plugins      = @(Get-ChildItem (Join-Path `$settings 'Plugins') -Filter *.dll -ErrorAction SilentlyContinue | ForEach-Object { "`$(`$_.BaseName) `$(Get-Machine `$_.FullName) `$(`$_.VersionInfo.FileVersion)" })
    activeRich   = `$active
    palette      = `$palette
    marker       = Test-Path (Join-Path `$rich 'vmtest-marker.txt')
    backupMarker = @(Get-ChildItem (Join-Path `$skins '@Backup') -Recurse -Filter 'vmtest-marker.txt' -ErrorAction SilentlyContinue).Count
    logging      = Test-Path `$log
    logProblems  = `$logProblems
    crashes      = `$crashes
} | ConvertTo-Json -Depth 5
"@
    Set-Content (Join-Path $logs "facts-$Name.json") $run.Output
    if (-not $run.Completed -or -not $run.Output.Trim()) { throw "the guest gave no facts for '$Name': $($run.Stderr)" }
    $run.Output | ConvertFrom-Json
}

# Send a bang to the running Rainmeter, as a skin or the command line does.
function Send-Bang {
    param([string[]]$Bang)
    Invoke-GuestExe -Exe $rainmeterExe -Arguments $Bang -TimeoutSec 60 | Out-Null
}

# Run the package the way the README says ("Run Rich.rmskin"): open it with its
# file association, as a double-click does, then press Install in the dialog.
function Install-RichPackage {
    param([string]$Name)
    Start-GuestExe -Exe "explorer.exe" -Arguments $guestPackage
    Show-GuestWindow -ProcessName "SkinInstaller" -TimeoutSec 90 | Out-Null
    Wait-For 2
    $dialog = Shot "$Name-dialog"
    Send-Keys "enter"
    Wait-For 30
    $after = Shot "$Name-after"
    [pscustomobject]@{ Dialog = $dialog; After = $after; Facts = (Get-GuestFact $Name) }
}

function Get-MissingPlugin {
    param($Facts)
    @(foreach ($plugin in $bundledPlugins) {
            if (-not @($Facts.plugins | Where-Object { $_ -like "$plugin 8664 *" })) { "$plugin (64-bit) missing" }
        })
}

# Hyper-V gives the guest all of its startup memory at once, or refuses to start it.
function Initialize-HostMemory {
    $needMb = [int]((Get-VM -Name $VmName).MemoryStartup / 1MB)
    $freeMb = [int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024)
    if ($freeMb -ge $needMb) { return "free $freeMb MB, the guest needs $needMb MB" }
    Add-Type -Namespace RichVmTest -Name Psapi -MemberDefinition '[DllImport("psapi.dll")] public static extern bool EmptyWorkingSet(IntPtr process);'
    $trimmed = 0; $skipped = 0
    foreach ($process in Get-Process) {
        try { if ([RichVmTest.Psapi]::EmptyWorkingSet($process.Handle)) { $trimmed++ } else { $skipped++ } } catch { $skipped++ }
    }
    Start-Sleep -Seconds 3
    $after = [int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024)
    if ($after -lt $needMb) { throw "only $after MB free after trimming $trimmed working sets; the guest needs $needMb MB. Close programs and run again." }
    "free $freeMb MB -> $after MB after trimming $trimmed working sets ($skipped skipped); the guest needs $needMb MB"
}

# ---------------------------------------------------------------- A, host
Test-Case "A1" "Package contents" "RMSKIN.ini, Skins/Rich and both builds of the six plugins, with a valid footer" {
    $bytes = [IO.File]::ReadAllBytes($Package)
    $footer = [byte[]]$bytes[($bytes.Length - 16)..($bytes.Length - 1)]
    $footerOk = [Text.Encoding]::ASCII.GetString($footer, 8, 8) -eq "`0RMSKIN`0" -and [BitConverter]::ToUInt64($footer, 0) -eq ($bytes.Length - 16)
    Add-Type -AssemblyName System.IO.Compression
    $zip = [IO.Compression.ZipArchive]::new([IO.MemoryStream]::new($bytes, 0, $bytes.Length - 16))
    try {
        $entries = @($zip.Entries | ForEach-Object FullName)
        $reader = [IO.StreamReader]::new(($zip.Entries | Where-Object FullName -EQ "RMSKIN.ini").Open())
        $rmskin = $reader.ReadToEnd(); $reader.Close()
    } finally { $zip.Dispose() }
    $needed = @("RMSKIN.ini", "Skins/Rich/Settings.ini") + @(foreach ($p in $bundledPlugins) { "Plugins/32bit/$p.dll"; "Plugins/64bit/$p.dll" })
    $missing = @($needed | Where-Object { $entries -notcontains $_ })
    $loadOk = $rmskin -match '(?m)^Load=Rich\\Settings\.ini\s*$'
    Add-Result -Id "A1" -Title "Package contents" -Expect "RMSKIN.ini, Skins/Rich and both builds of the six plugins, with a valid footer" `
        -Status $(if ($missing -or -not $footerOk -or -not $loadOk) { "fail" } else { "pass" }) -Output $rmskin `
        -Observed "$(Split-Path -Leaf $Package), $([math]::Round($bytes.Length / 1MB, 1)) MB, $($entries.Count) entries; footer valid: $footerOk; Load=Rich\Settings.ini: $loadOk; missing: $(if ($missing) { $missing -join ', ' } else { 'none' })"
}

# ---------------------------------------------------------------- guest up
"restoring checkpoint '$Snapshot'"
try {
    Restore-Guest -Snapshot $Snapshot
    Initialize-HostMemory
    Start-Guest
    Wait-Guest -TimeoutSec 900
    Wait-For 30
    Start-Recording -Path (Join-Path $Report "recording\session.mp4") | Out-Null
    Copy-ToGuest -Path $RainmeterInstaller -GuestDirectory $guestDownloads -MarkDownloaded
    Copy-ToGuest -Path $Package -GuestDirectory $guestDownloads -MarkDownloaded

    Test-Case "B1" "Guest before install" "no Rainmeter, no skins" {
        $facts = Get-GuestFact "before"
        Add-Result -Id "B1" -Title "Guest before install" -Expect "no Rainmeter, no skins" -Shots @(Shot "desktop") `
            -Status $(if ($facts.rainmeter -or $facts.skinsFolder -or $facts.plugins.Count) { "fail" } else { "pass" }) `
            -Observed "Windows build $($facts.build); Rainmeter installed: $($facts.rainmeter); skins folder: $($facts.skinsFolder); plugins: $($facts.plugins.Count)"
    }

    # ---------------------------------------------------------------- C, install
    Test-Case "C0" "Install Rainmeter (README step 1)" "Rainmeter installs and starts" {
        # The installer runs silently and elevated: Rainmeter's own installer is not under test.
        $setup = Invoke-GuestExe -Exe $guestInstaller -Arguments "/S" -TimeoutSec 600 -Background
        Start-GuestExe -Exe $rainmeterExe
        Wait-For 25
        $facts = Get-GuestFact "rainmeter"
        # Log to %APPDATA%\Rainmeter\Rainmeter.log from the next start on (the
        # skin installer restarts Rainmeter), so plugin and @Include errors show.
        Send-Bang "!WriteKeyValue", "Rainmeter", "Logging", "1", "$guestSettings\Rainmeter.ini"
        Add-Result -Id "C0" -Title "Install Rainmeter (README step 1)" -Expect "Rainmeter installs and starts" `
            -Status $(if ($facts.rainmeter -and $facts.running) { "pass" } else { "fail" }) -Shots @(Shot "rainmeter-first-start") `
            -Observed "installer exit $($setup.ExitCode); Rainmeter.exe present: $($facts.rainmeter); running: $($facts.running); skins folder: $($facts.skinsFolder)"
    }

    Test-Case "C1" "Run Rich.rmskin (README step 3)" "Rich and the six plugins install; Rainmeter restarts with the settings panel" {
        $install = Install-RichPackage "install"
        $facts = $install.Facts
        $problems = @(Get-MissingPlugin $facts)
        if (-not $facts.richFiles) { $problems += "no Skins\Rich" }
        if (-not $facts.running) { $problems += "Rainmeter is not running" }
        if ($facts.installer) { $problems += "the installer dialog is still open" }
        Add-Result -Id "C1" -Title "Run Rich.rmskin (README step 3)" -Expect "Rich and the six plugins install; Rainmeter restarts" `
            -Status $(if ($problems) { "fail" } else { "pass" }) -Shots @($install.Dialog, $install.After) -Output ($facts.plugins -join "`n") `
            -Observed "Rich files: $($facts.richFiles); version $($facts.version); plugins: $($facts.plugins.Count) ($(($facts.plugins | ForEach-Object { ($_ -split ' ')[0] }) -join ', ')); $(if ($problems) { $problems -join '; ' } else { 'all present' })"
    }

    # ---------------------------------------------------------------- D, use
    Test-Case "D1" "Settings panel after install" "Load=Rich\Settings.ini is active; the log has no errors" {
        Wait-For 10
        $facts = Get-GuestFact "settings-panel"
        $errors = @($facts.logProblems | Where-Object { $_ -match '^ERRO .*Rich\\.*\.ini' })
        Add-Result -Id "D1" -Title "Settings panel after install" -Expect "Rich\Settings.ini active; no ERRO lines in the log" `
            -Status $(if ($facts.activeRich -and -not $errors -and $facts.logging) { "pass" } elseif (-not $facts.logging) { "note" } else { "fail" }) `
            -Shots @(Shot "settings-panel") -Output ($facts.logProblems -join "`n") `
            -Observed "active Rich configs: $(if ($facts.activeRich) { $facts.activeRich -join ', ' } else { 'none' }); logging: $($facts.logging); ERRO lines: $($errors.Count); WARN lines: $(@($facts.logProblems | Where-Object { $_ -match '^WARN' }).Count)"
    }

    Test-Case "D2" "Widgets with the bundled plugins" "each widget loads without errors; read the screenshot for the drawing" {
        foreach ($skin in $overlapping) { Send-Bang "!DeactivateConfig", $skin }
        foreach ($widget in $widgets) {
            Send-Bang "!ActivateConfig", $widget[0], $widget[1]; Wait-For 2
            Send-Bang "!Move", "$($widget[2])", "$($widget[3])", $widget[0]; Wait-For 1
        }
        Wait-For 15
        $facts = Get-GuestFact "widgets"
        $errors = @($facts.logProblems | Where-Object { $_ -match '^ERRO .*Rich\\.*\.ini' })
        Add-Result -Id "D2" -Title "Widgets with the bundled plugins" -Expect "each widget loads without errors" `
            -Status $(if ($errors) { "fail" } else { "note" }) -Shots @(Shot "widgets") -Output ($facts.logProblems -join "`n") `
            -Observed "active Rich configs: $($facts.activeRich -join ', '); ERRO lines: $($errors.Count); read the screenshot"
    }

    # ---------------------------------------------------------------- E, upgrade
    Test-Case "E1" "Reinstall keeps settings (VariableFiles)" "the changed Palette survives; the old skin folder moves to @Backup" {
        $before = Get-GuestFact "before-reinstall"
        $target = if ($before.palette -eq "Nord") { "Dracula" } else { "Nord" }
        # Rich saves a setting exactly this way (!WriteKeyValue into Variables\*.inc).
        Send-Bang "!WriteKeyValue", "Variables", "Palette", $target, $guestGlobal
        # D2 already unloaded the skins that cover the installer dialog.
        Invoke-GuestScript -Script "Set-Content -LiteralPath '$guestSkins\Rich\vmtest-marker.txt' -Value 'old install'" | Out-Null
        $changed = Get-GuestFact "palette-changed"
        $install = Install-RichPackage "reinstall"
        $facts = $install.Facts
        $problems = @()
        if ($changed.palette -ne $target) { $problems += "the palette could not be changed before the reinstall ($($changed.palette))" }
        if ($facts.palette -ne $target) { $problems += "Palette is '$($facts.palette)' after the reinstall, expected '$target'" }
        if ($facts.marker) { $problems += "the old skin folder was not replaced" }
        if (-not $facts.backupMarker) { $problems += "no @Backup copy of the old skin" }
        $problems += @(Get-MissingPlugin $facts)
        Add-Result -Id "E1" -Title "Reinstall keeps settings (VariableFiles)" -Expect "the changed Palette survives; the old skin folder moves to @Backup" `
            -Status $(if ($problems) { "fail" } else { "pass" }) -Shots @($install.Dialog, $install.After) `
            -Observed "Palette '$($before.palette)' -> '$($changed.palette)' -> after reinstall '$($facts.palette)'; old folder in @Backup: $($facts.backupMarker); $(if ($problems) { $problems -join '; ' } else { 'kept' })"
    }

    # ---------------------------------------------------------------- I, restart
    Test-Case "I1" "Restart Windows" "Rainmeter starts with Windows and restores the Rich layout" {
        # The host's programs take memory back while the guest runs; trim again
        # between the shutdown and the start, or Hyper-V refuses to start it.
        Stop-Guest
        Initialize-HostMemory
        Start-Guest
        Wait-Guest -TimeoutSec 900
        Wait-For 45
        $facts = Get-GuestFact "after-restart"
        Add-Result -Id "I1" -Title "Restart Windows" -Expect "Rainmeter starts with Windows and restores the Rich layout" `
            -Status $(if ($facts.running -and $facts.activeRich) { "pass" } else { "note" }) -Shots @(Shot "after-restart") `
            -Observed "Rainmeter running: $($facts.running); active Rich configs: $($facts.activeRich -join ', ')"
    }

    Test-Case "K1" "Uninstall" "recorded only" {
        Add-Result -Id "K1" -Title "Uninstall" -Expect "recorded only" -Status note `
            -Observed "a .rmskin has no uninstaller; a user unloads the skins and deletes Skins\Rich. Not run."
    }

    Test-Case "M1" "Windows event log" "no crash of Rainmeter or the skin installer" {
        $facts = Get-GuestFact "final"
        Copy-FromGuest -GuestPath "$guestSettings\Rainmeter.log" -Destination $logs | Out-Null
        Add-Result -Id "M1" -Title "Windows event log" -Expect "no crash of Rainmeter or the skin installer" `
            -Status $(if ($facts.crashes.Count) { "fail" } else { "pass" }) -Shots @(Shot "final") `
            -Observed "$($facts.crashes.Count) crash entries name Rainmeter or SkinInstaller" -Output ($facts.crashes -join "`n`n")
    }
} finally {
    Stop-Recording
    if (-not $KeepRunning) { Stop-Guest }
}
Get-VM -Name $VmName | Select-Object Name, Generation, ProcessorCount, @{ n = "MemoryMb"; e = { $_.MemoryStartup / 1MB } }, Version |
    ConvertTo-Json | Set-Content (Join-Path $logs "vm.json")

$counts = $results | Group-Object status | ForEach-Object { "$($_.Count) $($_.Name)" }
"done: $($counts -join ', '); evidence in $Report"
Stop-Transcript | Out-Null
