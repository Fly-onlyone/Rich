# Runs inside the test guest as SYSTEM, started by Update-GuestWindows in
# Vm.ps1. Installs the updates whose title matches -Pattern through the
# Windows Update Agent and writes its progress to -Log. The last line starts
# with DONE or FAILED.
#
# It runs as a scheduled task because the Windows Update Agent refuses to
# download or install from a remote session, which PowerShell Direct is.
param(
    # The monthly Windows update: "2026-11 Security Update (KB...)", earlier
    # "... Cumulative Update for Windows 11 ...". Not the .NET or Defender ones.
    [string]$Pattern = '^\d{4}-\d{2} (Security|Cumulative) Update',
    [string]$Log = "C:\vmtest\update.log"
)
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force (Split-Path -Parent $Log) | Out-Null
function Say { param([string]$Text) Add-Content -Path $Log -Value ("{0:HH:mm:ss} {1}" -f (Get-Date), $Text) }

try {
    $session = New-Object -ComObject Microsoft.Update.Session
    Say "searching"
    $found = $session.CreateUpdateSearcher().Search("IsInstalled=0 and Type='Software' and IsHidden=0")
    $wanted = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach ($update in $found.Updates) {
        $take = $update.Title -match $Pattern
        Say ("{0}: {1}" -f $(if ($take) { "take" } else { "skip" }), $update.Title)
        if ($take) {
            if (-not $update.EulaAccepted) { $update.AcceptEula() }
            [void]$wanted.Add($update)
        }
    }
    if ($wanted.Count -eq 0) {
        Say "DONE nothing to install"
        return
    }
    Say "downloading"
    $downloader = $session.CreateUpdateDownloader()
    $downloader.Updates = $wanted
    $download = $downloader.Download()
    Say "download result $($download.ResultCode)"
    Say "installing"
    $installer = $session.CreateUpdateInstaller()
    $installer.Updates = $wanted
    $install = $installer.Install()
    # Result 2 is success, 3 success with errors, 4 failed.
    Say "DONE install result $($install.ResultCode), restart needed: $($install.RebootRequired)"
} catch {
    Say "FAILED $($_.Exception.Message)"
}
