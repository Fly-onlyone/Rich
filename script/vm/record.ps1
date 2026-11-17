# Record a Hyper-V guest's screen to an MP4 file. Started by Start-Recording
# in Vm.ps1 as a process of its own; it ends when the stop file appears.
#
# Hyper-V has no screen recorder. This takes a screenshot several times a
# second and writes the pixels to ffmpeg, which stamps each picture with the
# time it arrived. While the VM is off or restarting the last picture is
# repeated, so one file covers a restart.
param(
    [Parameter(Mandatory)][string]$VmName,
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$StopFile,
    [Parameter(Mandatory)][string]$Ffmpeg,
    [int]$Fps = 4,
    # Width of the film; the height follows from the shape of the guest's screen.
    [int]$Width = 1280,
    # Stop by itself after this long, in case the test that started it died.
    [int]$MaxMinutes = 180
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "Vm.ps1")
Initialize-Vm -Name $VmName

# The picture size is fixed for the whole file; take it from the first screen.
$size = $null
$deadline = (Get-Date).AddMinutes($MaxMinutes)
while (-not $size -and -not (Test-Path $StopFile) -and (Get-Date) -lt $deadline) {
    try { $size = Get-GuestScreenSize } catch { $script:Vm.Devices = $null }
    if (-not $size) { Start-Sleep -Milliseconds 500 }
}
if (-not $size) { exit 0 }
# The encoder wants even numbers.
$width = [Math]::Min($Width, $size.Width)
$width -= $width % 2
$height = [int]($width * $size.Height / $size.Width)
$height -= $height % 2

$info = [System.Diagnostics.ProcessStartInfo]::new($Ffmpeg)
foreach ($argument in @(
        "-hide_banner", "-loglevel", "error", "-y",
        "-use_wallclock_as_timestamps", "1",
        "-f", "rawvideo", "-pix_fmt", "rgb565le", "-video_size", "${width}x${height}", "-i", "pipe:0",
        "-vf", "fps=$Fps", "-c:v", "libx264", "-preset", "veryfast", "-crf", "30", "-pix_fmt", "yuv420p",
        # Written in pieces, so the file plays even if this process is killed.
        "-movflags", "+frag_keyframe+empty_moov+default_base_moof", $Path)) {
    $info.ArgumentList.Add($argument)
}
$info.RedirectStandardInput = $true
$info.UseShellExecute = $false
$info.CreateNoWindow = $true
$encoder = [System.Diagnostics.Process]::Start($info)
$pipe = $encoder.StandardInput.BaseStream

$interval = [int](1000 / $Fps)
$frame = [byte[]]::new($width * $height * 2)
try {
    while (-not (Test-Path $StopFile) -and (Get-Date) -lt $deadline -and -not $encoder.HasExited) {
        $started = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $bytes = Get-GuestScreenBytes -Width $width -Height $height
            if ($bytes -and $bytes.Length -eq $frame.Length) { $frame = $bytes }
        } catch {
            # The VM is off or restarting; look its devices up again next time.
            $script:Vm.Devices = $null
        }
        $pipe.Write($frame, 0, $frame.Length)
        $pipe.Flush()
        $left = $interval - [int]$started.ElapsedMilliseconds
        if ($left -gt 0) { Start-Sleep -Milliseconds $left }
    }
} finally {
    $pipe.Close()
    if (-not $encoder.WaitForExit(30000)) { $encoder.Kill() }
}
