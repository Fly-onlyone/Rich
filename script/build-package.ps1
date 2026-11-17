#Requires -Version 7.0
<#
.SYNOPSIS
    Builds the Rich .rmskin package.

.DESCRIPTION
    Stages <OutDir>/pkg with exactly the layout Rainmeter's skin installer reads,
    then packs it into <OutDir>/<ArchiveName>:

      RMSKIN.ini                       generated, see below
      Skins/Rich/...                   the skin files as committed in HEAD, so a local
                                       build matches CI and releases, and local
                                       secrets, caches and setting edits never ship
      Plugins/{32bit,64bit}/<Name>.dll from packaging/Plugins/<Name>/<arch>/; each
                                       DLL's PE header must match its arch folder

    The release version is stamped into the [Metadata] Version= key of every
    staged .ini, written back in that file's own encoding (UTF-16 LE or ASCII).
    The repository itself is never modified.

    RMSKIN.ini lists every @Resources/Variables/*.inc file in VariableFiles, so
    an upgrade keeps the user's saved settings: for each [Variables] key present
    in both the old and new file, the installer carries the old value over.

    The .rmskin format matches Rainmeter's own Skin Packager: a zip (no directory
    entries, '/' separators) followed by a 16-byte footer, the zip size as a
    little-endian UInt64 and then "\0RMSKIN\0". The archive is built here rather
    than with rmskin-builder because that tool rewrites RMSKIN.ini with escaped
    backslashes (Load=Rich\\Settings.ini), which Rainmeter reads literally.

    In GitHub Actions the archive path and file name are written to
    $GITHUB_OUTPUT as `archive` and `name`.

.PARAMETER Version
    Package version, e.g. 1.1.0 (release) or dev-1a2b3c4 (CI build).

.PARAMETER OutDir
    Output folder, relative to the repo root unless absolute. Default: dist.

.PARAMETER ArchiveName
    File name of the .rmskin. Default: Rich_<Version>.rmskin.

.PARAMETER WorkingTree
    Pack the working-tree copies of the tracked skin files instead of HEAD, to try
    uncommitted changes. Every uncommitted file packed is listed in a warning:
    Variables/*.inc edits become the package's defaults.

.EXAMPLE
    pwsh script/build-package.ps1 -Version 1.1.0
.EXAMPLE
    pwsh script/build-package.ps1 -Version 0.0.0-try -WorkingTree
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9A-Za-z][0-9A-Za-z.+-]*$')]
    [string]$Version,

    [string]$OutDir = 'dist',

    [ValidatePattern('^[\w.+-]+\.rmskin$')]
    [string]$ArchiveName,

    [switch]$WorkingTree
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

# 1. Skin files: as committed in HEAD, or the working-tree copies with -WorkingTree.
$uncommitted = @(git -c core.quotepath=off diff --name-only HEAD -- @SkinContent)
New-Item -ItemType Directory -Force -Path $skinRoot | Out-Null
if ($WorkingTree) {
    $tracked = @(git -c core.quotepath=off ls-files -- @SkinContent | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    foreach ($file in $tracked) {
        $dest = Join-Path $skinRoot $file
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item -LiteralPath $file -Destination $dest
    }
    if ($uncommitted) { Write-Warning "Packing uncommitted changes in $($uncommitted.Count) file(s): $($uncommitted -join ', ')" }
}
else {
    $tarball = Join-Path $outRoot 'skin-head.tar'
    git archive --format=tar --output=$tarball HEAD -- @SkinContent
    if ($LASTEXITCODE -ne 0) { throw 'git archive failed.' }
    tar -xf $tarball -C $skinRoot
    if ($LASTEXITCODE -ne 0) { throw 'Extracting the skin files failed.' }
    Remove-Item -LiteralPath $tarball
    if ($uncommitted) { Write-Warning "Built from HEAD; uncommitted changes in $($uncommitted.Count) file(s) are not included (add -WorkingTree to include them): $($uncommitted -join ', ')" }
}
$files = @(Get-ChildItem -LiteralPath $skinRoot -Recurse -File)
if ($files.Count -eq 0) { throw 'No skin files found.' }

# 2. Stamp the version into the staged copies, keeping each file's encoding:
#    [Metadata] Version= in every .ini, and [Variables] RichVersion= (the version the
#    About page shows). RichVersion lives in Scripts/Settings/About.inc, never in a
#    Variables/*.inc file: those are VariableFiles, so an upgrade would carry the old
#    version over the new one.
$utf16 = [Text.UnicodeEncoding]::new($false, $true)
$utf8 = [Text.UTF8Encoding]::new($false)
$stamped = 0
$richVersionStamped = 0
foreach ($file in (Get-ChildItem -LiteralPath $skinRoot -Recurse -File -Include '*.ini', '*.inc')) {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    $isUtf16 = $bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE
    $text = if ($isUtf16) { [Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2) } else { $utf8.GetString($bytes) }

    $section = ''
    $changed = $false
    $lines = [regex]::Split($text, '(?<=\n)')   # keeps each line's own ending
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\s*\[([^\]]+)\]') { $section = $Matches[1].Trim(); continue }
        if ($file.Extension -ieq '.ini' -and $section -ieq 'Metadata' -and $lines[$i] -match '^(\s*Version\s*=)[^\r\n]*(\r?\n?)$') {
            $lines[$i] = "$($Matches[1])$Version$($Matches[2])"
            $changed = $true
        }
        elseif ($section -ieq 'Variables' -and $lines[$i] -match '^(\s*RichVersion\s*=)[^\r\n]*(\r?\n?)$') {
            $lines[$i] = "$($Matches[1])$Version$($Matches[2])"
            $changed = $true
            $richVersionStamped++
        }
    }
    if ($changed) {
        $encoding = if ($isUtf16) { $utf16 } else { $utf8 }
        [IO.File]::WriteAllText($file.FullName, (-join $lines), $encoding)
        if ($file.Extension -ieq '.ini') { $stamped++ }
    }
}
if ($richVersionStamped -ne 1) {
    throw "Expected exactly one [Variables] RichVersion= to stamp (Scripts/Settings/About.inc), found $richVersionStamped."
}

# 3. Plugins: packaging/Plugins/<Name>/<arch>/<Name>.dll -> Plugins/<arch>/<Name>.dll.
$machineArch = @{ 0x014C = '32bit'; 0x8664 = '64bit' }
$pluginSource = Join-Path $RepoRoot 'packaging/Plugins'
$plugins = @(Get-ChildItem -LiteralPath $pluginSource -Directory)
foreach ($dll in (Get-ChildItem -LiteralPath $pluginSource -Recurse -File -Filter '*.dll')) {
    $arch = $dll.Directory.Name
    $pe = [IO.File]::ReadAllBytes($dll.FullName)
    $machine = [int][BitConverter]::ToUInt16($pe, [BitConverter]::ToInt32($pe, 0x3C) + 4)
    if ($machineArch[$machine] -ne $arch) {
        throw "$($dll.FullName): PE machine 0x$('{0:X4}' -f $machine) does not match folder '$arch'."
    }
    $dest = Join-Path $pkg "Plugins/$arch"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item -LiteralPath $dll.FullName -Destination (Join-Path $dest $dll.Name)
}

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
if (-not (Test-Path -LiteralPath (Join-Path $pkg ('Skins/' + ($LoadSkin -replace '\\', '/'))) -PathType Leaf)) {
    throw "Load target '$LoadSkin' is not in the package."
}

# 5. The .rmskin: zip of the staged folder (RMSKIN.ini first) + 16-byte footer.
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
if (-not $ArchiveName) { $ArchiveName = "${PackageName}_$Version.rmskin" }
$archivePath = Join-Path $outRoot $ArchiveName
$entries = @(Get-ChildItem -LiteralPath $pkg -Recurse -File |
    ForEach-Object { [pscustomobject]@{ Path = $_.FullName; Name = [IO.Path]::GetRelativePath($pkg, $_.FullName) -replace '\\', '/' } } |
    Sort-Object @{ Expression = { $_.Name -ne 'RMSKIN.ini' } }, Name)
$buffer = [IO.MemoryStream]::new()
$zip = [IO.Compression.ZipArchive]::new($buffer, [IO.Compression.ZipArchiveMode]::Create, $true)
try {
    foreach ($entry in $entries) {
        [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $entry.Path, $entry.Name, [IO.Compression.CompressionLevel]::Optimal)
    }
}
finally {
    $zip.Dispose()
}
$footer = [byte[]]::new(16)
[BitConverter]::GetBytes([uint64]$buffer.Length).CopyTo($footer, 0)
[Text.Encoding]::ASCII.GetBytes("`0RMSKIN`0").CopyTo($footer, 8)
$buffer.Write($footer, 0, $footer.Length)
[IO.File]::WriteAllBytes($archivePath, $buffer.ToArray())

if ($env:GITHUB_OUTPUT) {
    Add-Content -LiteralPath $env:GITHUB_OUTPUT -Value "archive=$archivePath", "name=$ArchiveName"
}

Write-Output "Built $archivePath ($([math]::Round($buffer.Length / 1MB, 2)) MB, $($entries.Count) entries)"
Write-Output "  $($files.Count) skin files, Version= stamped in $stamped .ini files"
Write-Output "  $($plugins.Count) plugins: $(($plugins.Name | Sort-Object) -join ', ')"
Write-Output "  VariableFiles: $($variableFiles.Count) files"
