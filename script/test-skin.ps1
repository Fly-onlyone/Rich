#Requires -Version 7.0
<#
.SYNOPSIS
    Static checks for the Rich Rainmeter skin pack.

.DESCRIPTION
    Rich has no compiler, so this script is its "build check". It catches the
    mistakes Rainmeter only reveals at runtime (or never):

      encoding   .ini/.inc/.lua must be UTF-16 LE with BOM, or BOM-less pure ASCII.
                 Rainmeter reads BOM-less files as ANSI, so non-ASCII text breaks.
      keys       A key defined twice in one section (incl. a reused @IncludeN, or
                 the same [Section] declared twice with conflicting keys).
      include    A static @Include=#@#... target that does not exist.
      i18n       Every Languages/en file exists in every other language with the
                 same set of keys.
      plugins    Every third-party Plugin= is bundled under packaging/Plugins.
      tracked    Local secrets / runtime caches must never be committed.
      wikilinks  Every [[link]] in the obsidian/ vault resolves to a note.
      lua        luacheck on UTF-8 copies of the (UTF-16) Lua scripts, if installed.
      powershell PSScriptAnalyzer on the repo's .ps1 files, if installed.

    Runs the same way locally (pre-commit hook) and in CI. Exits 1 on any error.

.PARAMETER Staged
    Limit the per-file checks (encoding, keys, include) to files staged for
    commit. Used by the pre-commit hook. Repo-wide checks always run. Note: the
    working-tree copy of each staged file is checked, not the staged blob.

.PARAMETER SkipExternal
    Skip luacheck and PSScriptAnalyzer.

.PARAMETER LuaUtf8Dir
    Write UTF-8 copies of the Lua scripts here (CI hands them to the luacheck
    action). Defaults to a temp folder when luacheck runs locally.

.EXAMPLE
    pwsh script/test-skin.ps1
.EXAMPLE
    pwsh script/test-skin.ps1 -Staged
#>
[CmdletBinding()]
param(
    [switch]$Staged,
    [switch]$SkipExternal,
    [string]$LuaUtf8Dir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = (git rev-parse --show-toplevel).Trim()
Set-Location -LiteralPath $RepoRoot

# Plugins that ship inside Rainmeter 4.5 (Program Files\Rainmeter\Plugins, plus
# the ones compiled into Rainmeter.dll). The .rmskin installer ignores these, so
# they are never bundled. Anything else must live in packaging/Plugins.
$BuiltInPlugins = @(
    'ActionTimer', 'AdvancedCPU', 'AudioLevel', 'CoreTemp', 'FileView', 'FolderInfo',
    'InputText', 'iTunesPlugin', 'MediaKey', 'NowPlaying', 'PerfMon', 'PingPlugin',
    'PowerPlugin', 'Process', 'QuotePlugin', 'RecycleManager', 'ResMon', 'RunCommand',
    'SpeedFanPlugin', 'SysInfo', 'UsageMonitor', 'WebParser', 'WifiStatus',
    'Win7AudioPlugin', 'WindowMessagePlugin'
)

# Gitignored local files that must never be committed.
$ForbiddenTracked = @(
    '@Resources/Variables/Secrets.inc',
    '@Resources/AIUsageData.txt',
    '@Resources/AIUsage-claude-cache.json',
    '@Resources/AIUsage-codex-cache.json'
)

# Every translation folder is checked against en, so a new language is covered automatically.
$Languages = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot '@Resources/Languages') -Directory |
    Where-Object Name -NE 'en' | ForEach-Object Name)
$Findings = [System.Collections.Generic.List[string]]::new()
$Warnings = [System.Collections.Generic.List[string]]::new()

function Add-Finding {
    param([string]$Check, [string]$Path, [int]$Line, [string]$Message)
    $location = if ($Line -gt 0) { "${Path}:${Line}" } else { $Path }
    $Findings.Add("${location}: [$Check] $Message")
}

function Get-TrackedFile {
    param([string[]]$Pattern)
    @(git -c core.quotepath=off ls-files -- @Pattern | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
}

function Get-StagedFile {
    @(git -c core.quotepath=off diff --cached --name-only --diff-filter=ACMR |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
}

# Every file that is (or is about to be) part of the repo: tracked plus untracked
# non-ignored. Lookups are case-insensitive like Rainmeter's file access on
# Windows, so CI on Linux does not report false "not found" results.
$RepoFiles = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($path in (git -c core.quotepath=off ls-files --cached --others --exclude-standard)) {
    if (Test-Path -LiteralPath $path -PathType Leaf) { [void]$RepoFiles.Add($path) }
}

# Reads a skin file and reports its encoding: UTF16LE, ASCII, NonAscii (no BOM),
# UTF8BOM or UTF16BE. Text is decoded so the other checks can parse it.
function Read-SkinFile {
    param([string]$Path)
    $bytes = [IO.File]::ReadAllBytes((Join-Path $RepoRoot $Path))
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [pscustomobject]@{ Encoding = 'UTF16LE'; Text = [Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2) }
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [pscustomobject]@{ Encoding = 'UTF16BE'; Text = [Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2) }
    }
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [pscustomobject]@{ Encoding = 'UTF8BOM'; Text = [Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3) }
    }
    $encoding = 'ASCII'
    foreach ($b in $bytes) { if ($b -gt 0x7F) { $encoding = 'NonAscii'; break } }
    [pscustomobject]@{ Encoding = $encoding; Text = [Text.Encoding]::UTF8.GetString($bytes) }
}

function Split-Line {
    param([string]$Text)
    $Text -split "`r?`n"
}

# Yields every key=value line of an INI file with its section and line number.
function Get-IniEntry {
    param([string]$Text)
    $section = ''
    $headerLine = 0
    $lineNo = 0
    foreach ($line in (Split-Line $Text)) {
        $lineNo++
        if ($line -match '^\s*\[([^\]]+)\]\s*$') {
            $section = $Matches[1].Trim()
            $headerLine = $lineNo
            continue
        }
        if ($line -match '^\s*([^;\s=\[][^=]*?)\s*=(.*)$') {
            [pscustomobject]@{ Section = $section; HeaderLine = $headerLine; Key = $Matches[1]; Value = $Matches[2].Trim(); Line = $lineNo }
        }
    }
}

# --- per-file checks -------------------------------------------------------

$skinFiles = Get-TrackedFile '*.ini', '*.inc', '*.lua'
if ($Staged) {
    $stagedSet = [System.Collections.Generic.HashSet[string]]::new([string[]]@(Get-StagedFile))
    $skinFiles = @($skinFiles | Where-Object { $stagedSet.Contains($_) })
}

$parsed = @{}
foreach ($file in $skinFiles) {
    $content = Read-SkinFile $file
    $parsed[$file] = $content

    # encoding
    switch ($content.Encoding) {
        'NonAscii' {
            $lineNo = 0
            foreach ($line in (Split-Line $content.Text)) {
                $lineNo++
                if ($line -match '[^\x00-\x7F]') {
                    Add-Finding 'encoding' $file $lineNo 'non-ASCII text in a BOM-less file (Rainmeter reads it as ANSI). Use ASCII, or save the file as UTF-16 LE with BOM.'
                    break
                }
            }
        }
        'UTF8BOM' { Add-Finding 'encoding' $file 1 'UTF-8 with BOM is not a Rainmeter encoding. Save as UTF-16 LE with BOM.' }
        'UTF16BE' { Add-Finding 'encoding' $file 1 'UTF-16 BE. Save as UTF-16 LE with BOM.' }
    }

    if ($file -like '*.lua') { continue }

    # Duplicate keys. Rainmeter treats a [Section] declared twice in one file as
    # ONE section, so keys are tracked per section name: two meters that share a
    # name collapse into one. A redeclared section is reported once, at its header.
    $seen = @{}
    $redeclared = [ordered]@{}
    foreach ($entry in (Get-IniEntry $content.Text)) {
        $id = "$($entry.Section.ToLowerInvariant())`n$($entry.Key.ToLowerInvariant())"
        if (-not $seen.ContainsKey($id)) {
            $seen[$id] = $entry
        }
        elseif ($seen[$id].HeaderLine -ne $entry.HeaderLine) {
            $groupId = "$($entry.HeaderLine)"
            if (-not $redeclared.Contains($groupId)) {
                $redeclared[$groupId] = [pscustomobject]@{ Entry = $entry; First = $seen[$id].HeaderLine; Keys = [System.Collections.Generic.List[string]]::new() }
            }
            $redeclared[$groupId].Keys.Add($entry.Key)
        }
        else {
            Add-Finding 'keys' $file $entry.Line "duplicate key '$($entry.Key)' in [$($entry.Section)] (first defined on line $($seen[$id].Line))"
        }

        # static @Include targets
        if ($entry.Key -match '^@Include\d*$') {
            $target = $entry.Value.Trim('"')
            if ($target -like '#@#*') {
                $relative = '@Resources/' + ($target.Substring(3) -replace '\\', '/')
                if ($relative -notmatch '#') {
                    # A gitignored target (e.g. Secrets.inc) is an optional local override.
                    git check-ignore -q -- $relative
                    $isLocalOverride = $LASTEXITCODE -eq 0
                    if (-not $RepoFiles.Contains($relative) -and -not $isLocalOverride) {
                        Add-Finding 'include' $file $entry.Line "@Include target not found: $target"
                    }
                }
            }
        }
    }
    foreach ($group in $redeclared.Values) {
        Add-Finding 'keys' $file $group.Entry.HeaderLine ("[$($group.Entry.Section)] is declared again (first on line $($group.First)); " +
            "Rainmeter merges both into one section, so these keys clash: $($group.Keys -join ', '). Rename one of the sections.")
    }
}

# --- repo-wide checks ------------------------------------------------------

function Get-ParsedSkinFile {
    param([string]$Path)
    if (-not $parsed.ContainsKey($Path)) { $parsed[$Path] = Read-SkinFile $Path }
    $parsed[$Path]
}

# i18n parity
$enRoot = '@Resources/Languages/en/'
foreach ($enFile in (Get-TrackedFile "$enRoot*")) {
    $relative = $enFile.Substring($enRoot.Length)
    $enKeys = @{}
    foreach ($entry in (Get-IniEntry (Get-ParsedSkinFile $enFile).Text)) { $enKeys[$entry.Key] = $entry.Line }
    foreach ($lang in $Languages) {
        $other = "@Resources/Languages/$lang/$relative"
        if (-not $RepoFiles.Contains($other)) {
            Add-Finding 'i18n' $other 0 "missing translation file (exists in en)"
            continue
        }
        $otherKeys = @{}
        foreach ($entry in (Get-IniEntry (Get-ParsedSkinFile $other).Text)) {
            $otherKeys[$entry.Key] = $entry.Line
            if (-not $enKeys.ContainsKey($entry.Key)) {
                Add-Finding 'i18n' $other $entry.Line "key '$($entry.Key)' is not defined in en/$relative"
            }
        }
        foreach ($key in $enKeys.Keys) {
            if (-not $otherKeys.ContainsKey($key)) {
                Add-Finding 'i18n' $other 0 "missing key '$key' (en/${relative}:$($enKeys[$key]))"
            }
        }
    }
}

# plugin coverage
$pluginUses = @{}
foreach ($file in (Get-TrackedFile '*.ini', '*.inc')) {
    foreach ($entry in (Get-IniEntry (Get-ParsedSkinFile $file).Text)) {
        if ($entry.Key -ieq 'Plugin' -and $entry.Value -notmatch '#') {
            $name = ($entry.Value -replace '^Plugins[\\/]', '' -replace '\.dll$', '').Trim()
            if (-not $pluginUses.ContainsKey($name)) { $pluginUses[$name] = "${file}:$($entry.Line)" }
        }
    }
}
foreach ($name in $pluginUses.Keys) {
    if ($BuiltInPlugins -contains $name) { continue }
    foreach ($arch in '32bit', '64bit') {
        $dll = "packaging/Plugins/$name/$arch/$name.dll"
        if (-not $RepoFiles.Contains($dll)) {
            $where = $pluginUses[$name]
            Add-Finding 'plugins' $dll 0 "third-party plugin '$name' (used at $where) is not bundled"
        }
    }
}

# forbidden tracked files
$tracked = @(git -c core.quotepath=off ls-files)
foreach ($path in $ForbiddenTracked) {
    if ($tracked -contains $path) {
        Add-Finding 'tracked' $path 0 'local-only file is committed. Run: git rm --cached -- "<path>"'
    }
}

# obsidian wikilinks
$vaultRoot = Join-Path $RepoRoot 'obsidian'
if (Test-Path -LiteralPath $vaultRoot) {
    $vaultFiles = @(Get-ChildItem -LiteralPath $vaultRoot -Recurse -File |
        Where-Object { $_.FullName -notmatch '[\\/]\.obsidian[\\/]' })
    $targets = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($f in $vaultFiles) {
        $rel = [IO.Path]::GetRelativePath($vaultRoot, $f.FullName) -replace '\\', '/'
        [void]$targets.Add($f.Name)
        [void]$targets.Add($rel)
        if ($f.Extension -eq '.md') {
            [void]$targets.Add($f.BaseName)
            [void]$targets.Add($rel.Substring(0, $rel.Length - 3))
        }
    }
    foreach ($note in ($vaultFiles | Where-Object { $_.Extension -eq '.md' -and $_.FullName -notmatch '[\\/]_Templates[\\/]' })) {
        $relNote = 'obsidian/' + ([IO.Path]::GetRelativePath($vaultRoot, $note.FullName) -replace '\\', '/')
        $inFence = $false
        $lineNo = 0
        foreach ($line in (Get-Content -LiteralPath $note.FullName -Encoding utf8)) {
            $lineNo++
            if ($line -match '^\s*(```|~~~)') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }
            $clean = $line -replace '`[^`]*`', ''
            foreach ($m in [regex]::Matches($clean, '!?\[\[([^\]\|#]*)')) {
                $target = $m.Groups[1].Value.Trim()
                if ($target -eq '') { continue }   # [[#Heading]] links inside the same note
                if (-not $targets.Contains($target)) {
                    Add-Finding 'wikilinks' $relNote $lineNo "broken link [[$target]]"
                }
            }
        }
    }
}

# --- external linters ------------------------------------------------------

# In -Staged mode only the staged scripts are linted, so the hook stays fast.
$luaFiles = @(Get-TrackedFile '*.lua')
$ps1Files = @(Get-TrackedFile '*.ps1')
if ($Staged) {
    $luaFiles = @($luaFiles | Where-Object { $stagedSet.Contains($_) })
    $ps1Files = @($ps1Files | Where-Object { $stagedSet.Contains($_) })
}
$luacheck = if ($luaFiles.Count -gt 0) { Get-Command luacheck -ErrorAction SilentlyContinue } else { $null }
if ($LuaUtf8Dir -or ($luacheck -and -not $SkipExternal)) {
    $luaOut = if ($LuaUtf8Dir) { $LuaUtf8Dir } else { Join-Path ([IO.Path]::GetTempPath()) "rich-lua-$PID" }
    if (Test-Path -LiteralPath $luaOut) { Remove-Item -LiteralPath $luaOut -Recurse -Force }
    foreach ($file in $luaFiles) {
        $dest = Join-Path $luaOut $file
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        [IO.File]::WriteAllText($dest, (Get-ParsedSkinFile $file).Text, [Text.UTF8Encoding]::new($false))
    }
}
if (-not $SkipExternal) {
    if ($luacheck) {
        $output = & luacheck $luaOut --config (Join-Path $RepoRoot '.luacheckrc') --formatter plain --codes 2>&1
        if ($LASTEXITCODE -ne 0) {
            foreach ($line in $output) {
                $text = "$line".Replace($luaOut, '').TrimStart('\', '/')
                if ($text) { $Findings.Add("$text [lua]") }
            }
        }
    }
    elseif ($luaFiles.Count -gt 0 -and -not $LuaUtf8Dir) {
        $Warnings.Add('luacheck not found on PATH, Lua lint skipped (CI runs it).')
    }

    $hasAnalyzer = $ps1Files.Count -gt 0 -and (Get-Module -ListAvailable -Name PSScriptAnalyzer)
    if ($hasAnalyzer) {
        $settings = Join-Path $RepoRoot 'PSScriptAnalyzerSettings.psd1'
        foreach ($ps1 in $ps1Files) {
            $results = Invoke-ScriptAnalyzer -Path $ps1 -Settings $settings | Where-Object Severity -In 'Error', 'Warning'
            foreach ($result in $results) {
                Add-Finding 'powershell' $ps1 $result.Line "$($result.RuleName): $($result.Message)"
            }
        }
    }
    elseif ($ps1Files.Count -gt 0) {
        $Warnings.Add('PSScriptAnalyzer not installed, PowerShell lint skipped (CI runs it). Install: Install-Module PSScriptAnalyzer -Scope CurrentUser')
    }
}

# --- report ----------------------------------------------------------------

foreach ($warning in $Warnings) { Write-Warning $warning }
if ($Findings.Count -gt 0) {
    $Findings | Sort-Object | ForEach-Object { Write-Output $_ }
    Write-Output ''
    Write-Output "test-skin: $($Findings.Count) problem(s) found."
    exit 1
}
$scope = if ($Staged) { "$($skinFiles.Count) staged skin file(s)" } else { "$($skinFiles.Count) skin file(s)" }
Write-Output "test-skin: OK ($scope checked)."
