# Give the test guest a share of the host's graphics card and keep that
# state as a second checkpoint. Run once after provision.ps1, and again
# after a graphics driver update on the host:
#   pwsh scripts\vm\provision-gpu.ps1
#
# The guest made by provision.ps1 draws on the processor. That is one real
# case (virtual machines, remote desktop). This adds the other: a machine
# with a graphics card. It restores the checkpoint "clean", brings Windows
# up to date if its build has the display fault described below, copies the
# host's graphics driver into the guest (about 2 GB), takes the checkpoint
# "clean-gpu", then starts the guest once with the card attached to check
# that Windows there starts the device and still shows a desktop.
#
# Microsoft documents GPU partitioning for Windows Server hosts and
# data-center cards. On a Windows 11 host with a desktop card it is not a
# supported setup; it works where Get-VMHostPartitionableGpu lists the card.
#   https://learn.microsoft.com/windows-server/virtualization/hyper-v/gpu-partitioning
#   https://learn.microsoft.com/windows-server/virtualization/hyper-v/partition-assign-vm-gpu
#   https://learn.microsoft.com/windows-hardware/drivers/display/gpu-paravirtualization
#
# The driver is copied because that is the only way for a full VM: Microsoft's
# page describes an automatic copy and says "This feature is disabled in the
# released version of the OS". The registry value it names for it
# (DriverStoreCopyMode) did nothing when set in the guest.
#
# A checkpoint does not keep the card. A test that wants it restores
# "clean-gpu" and calls Enable-GuestGpu before Start-Guest.
param(
    [string]$VmName = "Software Tester",
    [string]$User = "tester",
    [string]$Password = "vmtest",
    # Checkpoint to start from, and the one this script makes.
    [string]$BaseSnapshot = "clean",
    [string]$Snapshot = "clean-gpu",
    # Replace an existing checkpoint of that name.
    [switch]$Force,
    # Leave Windows as it is even when its build has the display fault.
    [switch]$SkipWindowsUpdate
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "Vm.ps1")
Initialize-Vm -Name $VmName -User $User -Password $Password

$driver = Get-HostGpuDriverFolder
"host driver: $driver"
$old = Get-VMSnapshot -VMName $VmName -Name $Snapshot -ErrorAction SilentlyContinue
if ($old) {
    if (-not $Force) { throw "the checkpoint '$Snapshot' exists; pass -Force to replace it" }
    $old | Remove-VMSnapshot
}

"restoring '$BaseSnapshot'"
Restore-Guest -Snapshot $BaseSnapshot
Start-Guest
Wait-Guest -TimeoutSec 900

# Windows 11 builds 26100 and 26200 with a revision from 4484 to 7170 lose the
# desktop's screen once a graphics card is attached (see Test-GuestDisplay).
$build = Get-GuestBuild
"guest Windows build: $build"
# An empty answer is a failed probe, not a build outside the faulty range.
if ($build -notmatch '^\d+\.\d+$') { throw "the guest did not report its Windows build (got '$build'); is it up?" }
$parts = $build -split '\.'
$faulty = $parts[0] -in "26100", "26200" -and [int]$parts[1] -ge 4484 -and [int]$parts[1] -lt 7171
if ($faulty -and -not $SkipWindowsUpdate) {
    "this build loses its screen with a graphics card attached; installing the current Windows update (can take an hour)"
    $log = Update-GuestWindows
    $log
    if (-not ($log | Where-Object { $_ -match 'DONE install result 2' })) { throw "the Windows update did not install; see the lines above" }
    # Windows finishes the update while it shuts down and starts; pulling the
    # plug then would undo it, so both get plenty of time.
    Stop-Guest -TimeoutSec 1800
    Start-Guest
    Wait-Guest -TimeoutSec 1800
    "guest Windows build now: $(Get-GuestBuild)"
}

"copying the driver into the guest"
$name = Copy-GpuDriverToGuest
Stop-Guest
# Taken without the card attached: Hyper-V does not checkpoint a VM that has one.
Checkpoint-VM -Name $VmName -SnapshotName $Snapshot
"checkpoint '$Snapshot' taken"

"starting the guest with the card attached"
Enable-GuestGpu
Start-Guest
Wait-Guest -TimeoutSec 900
Start-Sleep -Seconds 30
$adapters = @(Get-GuestDisplayAdapters)
$adapters
$screen = Test-GuestDisplay
Stop-Guest
$working = @($adapters | Where-Object { $_ -notmatch "Hyper-V Video" -and $_ -match "problem code 0$" })
if (-not $working) { throw "the guest did not start the graphics card; see the adapter list above (driver folder $name)" }
if (-not $screen) { throw "the guest started the graphics card but its desktop has no screen; its Windows build has the display fault (see Test-GuestDisplay in Vm.ps1)" }
"done: the guest has $($working[0]) and shows its desktop"
