$SkinLink = Join-Path $env:USERPROFILE 'Documents\Rainmeter\Skins\Rich'
$RepoPath = 'C:\Users\PC\Documents\Rich'

New-Item -ItemType Directory -Force -Path (Split-Path $SkinLink) | Out-Null

if (Test-Path $SkinLink) {
    Write-Host "Already exists: $SkinLink"
    Write-Host "Remove or rename it first if it does not already point to $RepoPath"
    exit 0
}

New-Item -ItemType Junction -Path $SkinLink -Target $RepoPath

Write-Host "Created Rainmeter skin link:"
Write-Host "$SkinLink -> $RepoPath"
Write-Host "Now open Rainmeter and run Refresh all."
