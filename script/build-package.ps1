#Requires -Version 7.0
<#
.SYNOPSIS
    Stages the Rich .rmskin package contents for rmskin-builder.

.DESCRIPTION
    Builds <OutDir>/pkg in the layout rmskin-builder (2bndy5/rmskin-action) expects:

      RMSKIN.ini                               generated, see below
      Skins/Rich/...                           tracked skin files only (git ls-files),
                                               so local secrets and runtime caches never ship
      Plugins/<Name>/{32bit,64bit}/<Name>.dll  copied from packaging/Plugins

    The release version is stamped into the [Metadata] Version= key of every
    staged .ini, written back in that file's own encoding (UTF-16 LE or ASCII).
    The repository itself is never modified.

    RMSKIN.ini lists every @Resources/Variables/*.inc file in VariableFiles, so
    an upgrade keeps the user's saved settings: for each [Variables] key present
    in both the old and new file, the installer carries the old value over.

    Turn the staged folder into a .rmskin with rmskin-builder:
      CI:    2bndy5/rmskin-action  (path: dist/pkg)
      Local: pip install rmskin-builder; rmskin-builder --path dist/pkg --dir-out dist

.PARAMETER Version
    Package version, e.g. 1.1.0 (release) or dev-1a2b3c4 (CI build).

.PARAMETER OutDir
    Output folder, relative to the repo root unless absolute. Default: dist.

.EXAMPLE
    pwsh script/build-package.ps1 -Version 1.1.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9A-Za-z][0-9A-Za-z.+-]*$')]
    [string]$Version,

    [string]$OutDir = 'dist'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PackageName = 'Rich'
$Author = 'Fly-onlyone'
$MinimumRainmeter = '4.5.18.3727'   # same floor as the upstream Monterey package
$MinimumWindows = '10.0'            # FrostedGlass (default Blur effect) needs Windows 10
$LoadSkin = 'Rich\Settings.ini'     # opens the settings panel after install
$SkinContent = @('@Resources', 'Widgets', 'Extras', 'Settings.ini', 'LICENSE')

$RepoRoot = (git rev-parse --show-toplevel).Trim()
Set-Location -LiteralPath $RepoRoot

$outRoot = if ([IO.Path]::IsPathRooted($OutDir)) { $OutDir } else { Join-Path $RepoRoot $OutDir }
$pkg = Join-Path $outRoot 'pkg'
if (Test-Path -LiteralPath $pkg) { Remove-Item -LiteralPath $pkg -Recurse -Force }
$skinRoot = Join-Path $pkg "Skins/$PackageName"

# 1. Skin files: tracked only.
$files = @(git -c core.quotepath=off ls-files -- @SkinContent | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
if ($files.Count -eq 0) { throw 'No tracked skin files found.' }
foreach ($file in $files) {
    $dest = Join-Path $skinRoot $file
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item -LiteralPath $file -Destination $dest
}

# 2. Stamp [Metadata] Version= in the staged .ini copies, keeping each file's encoding.
$utf16 = [Text.UnicodeEncoding]::new($false, $true)
$utf8 = [Text.UTF8Encoding]::new($false)
$stamped = 0
foreach ($ini in (Get-ChildItem -LiteralPath $skinRoot -Recurse -File -Filter '*.ini')) {
    $bytes = [IO.File]::ReadAllBytes($ini.FullName)
    $isUtf16 = $bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE
    $text = if ($isUtf16) { [Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2) } else { $utf8.GetString($bytes) }

    $section = ''
    $changed = $false
    $lines = [regex]::Split($text, '(?<=\n)')   # keeps each line's own ending
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\s*\[([^\]]+)\]') { $section = $Matches[1].Trim(); continue }
        if ($section -ieq 'Metadata' -and $lines[$i] -match '^(\s*Version\s*=)[^\r\n]*(\r?\n?)$') {
            $lines[$i] = "$($Matches[1])$Version$($Matches[2])"
            $changed = $true
        }
    }
    if ($changed) {
        $encoding = if ($isUtf16) { $utf16 } else { $utf8 }
        [IO.File]::WriteAllText($ini.FullName, (-join $lines), $encoding)
        $stamped++
    }
}

# 3. Plugins.
$plugins = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'packaging/Plugins') -Directory)
Copy-Item -LiteralPath (Join-Path $RepoRoot 'packaging/Plugins') -Destination (Join-Path $pkg 'Plugins') -Recurse

# 4. RMSKIN.ini.
$variableFiles = @(git -c core.quotepath=off ls-files -- '@Resources/Variables/*.inc' |
    ForEach-Object { "$PackageName\" + ($_ -replace '/', '\') })
$rmskin = @(
    '[rmskin]'
    "Name=$PackageName"
    "Author=$Author"
    "Version=$Version"
    "MinimumRainmeter=$MinimumRainmeter"
    "MinimumWindows=$MinimumWindows"
    'LoadType=Skin'
    "Load=$LoadSkin"
    "VariableFiles=$($variableFiles -join ' | ')"
) -join "`r`n"
[IO.File]::WriteAllText((Join-Path $pkg 'RMSKIN.ini'), "$rmskin`r`n", $utf8)

Write-Output "Staged $PackageName $Version in $pkg"
Write-Output "  $($files.Count) skin files, Version= stamped in $stamped .ini files"
Write-Output "  $($plugins.Count) plugins: $(($plugins.Name | Sort-Object) -join ', ')"
Write-Output "  VariableFiles: $($variableFiles.Count) files"
