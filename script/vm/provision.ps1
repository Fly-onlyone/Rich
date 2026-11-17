# Create a Hyper-V guest with a clean Windows 11 and take the checkpoint that
# every test run starts from. Run once per Windows image:
#   pwsh scripts\vm\provision.ps1 -Iso C:\path\windows11.iso
#
# Needs: the Windows feature Hyper-V, an account in "Hyper-V Administrators"
# (or an elevated shell), and oscdimg.exe from the Windows ADK's Deployment
# Tools. Uses about 6 GB of temporary disk space and leaves a disk image of
# roughly 10 to 20 GB.
#
# Windows Setup reads its answers from autounattend.xml at the root of the
# install media, so the script builds a copy of the ISO that carries
# scripts\vm\autounattend.xml and starts without "Press any key". The copy
# is deleted at the end.
#   where Setup looks for an answer file:
#   https://learn.microsoft.com/windows-hardware/manufacture/desktop/windows-setup-automation-overview
#   oscdimg options:
#   https://learn.microsoft.com/windows-hardware/manufacture/desktop/oscdimg-command-line-options
param(
    [string]$VmName = "Software Tester",
    [Parameter(Mandatory)][string]$Iso,
    [string]$User = "tester",
    # Kept simple on purpose: it is typed into command lines in the answer file.
    [string]$Password = "vmtest",
    [string]$Snapshot = "clean",
    [int]$Cpus = 2,
    [int]$MemoryMb = 4096,
    [int]$DiskGb = 64,
    # Which image of install.wim to install; `dism /Get-WimInfo` lists them.
    [int]$ImageIndex = 1,
    # A stock multi-edition ISO needs a key to pick the edition; an ISO that
    # holds one edition does not.
    [string]$ProductKey,
    [string]$Locale = "en-US",
    # Virtual switch the guest is connected to once Windows is installed.
    [string]$Switch = "Default Switch",
    # Folder that receives setup.png, a screenshot of the install, every poll.
    [string]$Progress,
    [int]$TimeoutMin = 120,
    # Replace an existing VM of this name and its disk.
    [switch]$Force,
    # Start the install in a VM that an earlier run created but could not
    # start, for example because the host had too little memory free.
    [switch]$Resume
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "Vm.ps1")
Initialize-Vm -Name $VmName -User $User -Password $Password

function Find-Oscdimg {
    $found = Get-Command oscdimg -ErrorAction SilentlyContinue
    if ($found) { return $found.Source }
    $kit = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    if (Test-Path $kit) { return $kit }
    throw "oscdimg.exe not found; install the Deployment Tools of the Windows ADK (winget install Microsoft.WindowsADK)"
}

$Iso = (Resolve-Path $Iso).Path
$oscdimg = Find-Oscdimg
if ($Password -notmatch '^[A-Za-z0-9._-]+$') { throw "use letters, digits, dot, dash and underscore in -Password" }

$work = Join-Path ([System.IO.Path]::GetTempPath()) "vmtest-provision"
$disk = Join-Path (Get-VMHost).VirtualHardDiskPath "$VmName.vhdx"
$existing = Get-VM -Name $VmName -ErrorAction SilentlyContinue

# Hyper-V gives a guest all of its memory when it starts and refuses to start
# it otherwise. Better to know before ten minutes of copying.
$freeMb = [int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024)
if ($freeMb -lt $MemoryMb) {
    throw "the host has $freeMb MB of memory free and the guest needs $MemoryMb MB; close programs or pass a smaller -MemoryMb"
}

if ($Resume) {
    if (-not $existing -or -not (Get-VMDvdDrive -VMName $VmName)) { throw "nothing to resume: no VM '$VmName' with install media attached" }
    "resuming with the VM and install media of the earlier run"
} else {

if ($existing) {
    if (-not $Force) { throw "a VM named '$VmName' exists; pass -Force to replace it and its disk" }
    "removing the existing VM '$VmName'"
    if ($existing.State -ne "Off") { Stop-VM -Name $VmName -TurnOff -Force }
    # With a checkpoint, the drive's path is a differencing .avhdx that removing
    # the checkpoint merges away; its base disk, $disk, is removed further down.
    $oldDisks = @(Get-VMHardDiskDrive -VMName $VmName | ForEach-Object { $_.Path })
    Get-VMSnapshot -VMName $VmName -ErrorAction SilentlyContinue | Remove-VMSnapshot -IncludeAllChildSnapshots -ErrorAction SilentlyContinue
    Remove-VM -Name $VmName -Force
    foreach ($oldDisk in $oldDisks) { Remove-Item $oldDisk -Force -ErrorAction SilentlyContinue }
}

# ---------------------------------------------------------------- install media
if (Test-Path $work) { Remove-Item -Recurse -Force $work }
$media = Join-Path $work "media"
New-Item -ItemType Directory -Force $media | Out-Null
$answerIso = Join-Path $work "install.iso"

"copying the install media"
$mounted = Mount-DiskImage -ImagePath $Iso -PassThru
try {
    $letter = ($mounted | Get-Volume).DriveLetter
    if (-not $letter) { throw "Windows gave the mounted ISO no drive letter" }
    # /A-:R takes the read-only mark off the copies; exit codes below 8 are success.
    robocopy "${letter}:\" $media /E /A-:R /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed with $LASTEXITCODE" }
} finally {
    Dismount-DiskImage -ImagePath $Iso | Out-Null
}
$boot = Join-Path $media "efi\microsoft\boot\efisys_noprompt.bin"
if (-not (Test-Path $boot)) { throw "the ISO has no efi\microsoft\boot\efisys_noprompt.bin; is it a Windows install ISO?" }

$escape = { param($text) [System.Security.SecurityElement]::Escape($text) }
$key = if ($ProductKey) { "<Key>$(& $escape $ProductKey)</Key>" } else { "<Key/>" }
$answers = (Get-Content (Join-Path $PSScriptRoot "autounattend.xml") -Raw).
    Replace("{{USER}}", (& $escape $User)).
    Replace("{{PASSWORD}}", (& $escape $Password)).
    Replace("{{IMAGE_INDEX}}", "$ImageIndex").
    Replace("{{PRODUCT_KEY}}", $key).
    Replace("{{LOCALE}}", $Locale).
    Replace("{{COMPUTER}}", "VMTEST")
# An ISO can bring an answer file of its own; this one replaces it.
Set-Content -Path (Join-Path $media "autounattend.xml") -Value $answers -Encoding utf8

"building the install ISO"
& $oscdimg -m -o -u2 -udfver102 "-bootdata:1#pEF,e,b$boot" $media $answerIso 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $answerIso)) { throw "oscdimg failed with $LASTEXITCODE" }
Remove-Item -Recurse -Force $media

# ---------------------------------------------------------------- the VM
"creating the VM"
if (Test-Path $disk) {
    if (-not $Force) { throw "$disk exists; pass -Force to replace it" }
    Remove-Item $disk -Force
}
New-VM -Name $VmName -Generation 2 -MemoryStartupBytes ($MemoryMb * 1MB) -NewVHDPath $disk -NewVHDSizeBytes ($DiskGb * 1GB) | Out-Null
Set-VM -Name $VmName -ProcessorCount $Cpus -StaticMemory -AutomaticCheckpointsEnabled $false -CheckpointType Standard `
    -AutomaticStartAction Nothing -AutomaticStopAction ShutDown
# One fixed screen size, so that screenshots and click positions stay comparable.
Set-VMVideo -VMName $VmName -ResolutionType Single -HorizontalResolution 1600 -VerticalResolution 900
$dvd = Add-VMDvdDrive -VMName $VmName -Path $answerIso -Passthru
Set-VMFirmware -VMName $VmName -FirstBootDevice $dvd
try {
    Set-VMKeyProtector -VMName $VmName -NewLocalKeyProtector
    Enable-VMTPM -VMName $VmName
} catch {
    "no virtual TPM ($($_.Exception.Message)); the answer file tells Setup not to ask for one"
}
# No network during Setup: the first-run screens then ask for no online account and fetch no updates.
Get-VMNetworkAdapter -VMName $VmName | Disconnect-VMNetworkAdapter

}

# ---------------------------------------------------------------- install
"installing Windows; this takes 10 to 40 minutes"
Start-Guest
$deadline = (Get-Date).AddMinutes($TimeoutMin)
$done = $false
while (-not $done -and (Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 20
    if ($Progress) {
        try { Save-Screenshot (Join-Path $Progress "setup.png") | Out-Null } catch { $script:Vm.Devices = $null }
    }
    try {
        $run = Invoke-InGuest -TimeoutSec 30 -Attempts 1 -ScriptBlock { Test-Path C:\provision-done.txt }
        $done = $run.Output -contains $true
    } catch {
        # Setup is still running; the account does not exist yet.
    }
}
if (-not $done) { throw "Windows did not finish installing within $TimeoutMin minutes; look at the VM in Hyper-V Manager" }

"Windows is installed; taking the checkpoint"
Stop-Guest
Get-VMDvdDrive -VMName $VmName | Remove-VMDvdDrive
Remove-Item -Recurse -Force $work
if (Get-VMSwitch -Name $Switch -ErrorAction SilentlyContinue) {
    Get-VMNetworkAdapter -VMName $VmName | Connect-VMNetworkAdapter -SwitchName $Switch
} else {
    Write-Warning "no virtual switch named '$Switch'; the guest stays without network"
}
# Prove that a cold start reaches the desktop before keeping this state.
Start-Guest
Wait-Guest -TimeoutSec 600
Start-Sleep -Seconds 30
Stop-Guest
Checkpoint-VM -Name $VmName -SnapshotName $Snapshot
"done: VM '$VmName', checkpoint '$Snapshot', disk $([math]::Round((Get-Item $disk).Length / 1GB, 1)) GB"
