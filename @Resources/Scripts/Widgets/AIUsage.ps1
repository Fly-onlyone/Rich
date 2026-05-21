# AIUsage.ps1 — Rich for Rainmeter
# -----------------------------------------------------------------------------
# Parses local Codex (and, optionally, Claude) coding-assistant usage and writes
# a flat data file that the AIUsage widget reads via a WebParser file:// measure.
#
# Codex  — live account-wide usage from chatgpt.com/backend-api/wham/usage,
#          authenticated with the OAuth token in ~/.codex/auth.json.
#
# Claude — live account-wide usage from api.anthropic.com/api/oauth/usage,
#          authenticated with the OAuth token in ~/.claude/.credentials.json.
#
# Both endpoints are undocumented and can rate-limit; each good reading is
# cached (AIUsage-{codex,claude}-cache.json) so the widget keeps showing real
# numbers while an endpoint is throttled.
#
# Output: @Resources/AIUsageData.txt — a single delimited line, e.g.
#   codex5=71|codex7=11|claude5=0|claude7=0|codex5r=2h 14m|codex7r=5d 3h|...
# -----------------------------------------------------------------------------

$ErrorActionPreference = 'SilentlyContinue'
$outFile = Join-Path $PSScriptRoot '..\..\AIUsageData.txt'   # -> @Resources\AIUsageData.txt

function Format-Reset([object]$value) {
    # Accepts a Unix epoch (Codex / statusline file) or an ISO-8601 string (the
    # /api/oauth/usage endpoint). Returns a short "in X" string, or '-'.
    if ($null -eq $value -or "$value" -eq '' -or "$value" -eq '0') { return '-' }
    $target = $null
    $secs = 0.0
    if ([double]::TryParse([string]$value, [ref]$secs)) {
        if ($secs -le 0) { return '-' }
        $target = [DateTimeOffset]::FromUnixTimeSeconds([int64]$secs)
    } else {
        try { $target = [DateTimeOffset]::Parse([string]$value, [System.Globalization.CultureInfo]::InvariantCulture) }
        catch { return '-' }
    }
    $span = $target - [DateTimeOffset]::UtcNow
    if ($span.TotalSeconds -le 0) { return 'now' }
    if ($span.TotalDays  -ge 1) { return ('{0}d {1}h' -f [int][math]::Floor($span.TotalDays), $span.Hours) }
    if ($span.TotalHours -ge 1) { return ('{0}h {1}m' -f [int][math]::Floor($span.TotalHours), $span.Minutes) }
    return ('{0}m' -f [int][math]::Max(1, $span.Minutes))
}

# --- Codex: live usage from chatgpt.com/backend-api/wham/usage ----------------
# Account-wide — reflects the Codex CLI, IDE and cloud. The OAuth token comes
# from ~/.codex/auth.json. On any failure the widget falls back to the cached
# last good reading (@Resources/AIUsage-codex-cache.json).
$codex5 = 0; $codex7 = 0; $codex5r = '-'; $codex7r = '-'; $codexErr = 1
$codexCache = Join-Path $PSScriptRoot '..\..\AIUsage-codex-cache.json'
$codex5Reset = $null; $codex7Reset = $null

$codexAuth = Join-Path $env:USERPROFILE '.codex\auth.json'
if (Test-Path $codexAuth) {
    try {
        $ca = Get-Content -Raw -LiteralPath $codexAuth | ConvertFrom-Json
        $tok = $ca.tokens.access_token
        if ($tok) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $hdr = @{ Authorization = "Bearer $tok" }
            if ($ca.tokens.account_id) { $hdr['chatgpt-account-id'] = $ca.tokens.account_id }
            $u = Invoke-RestMethod -Uri 'https://chatgpt.com/backend-api/wham/usage' -Headers $hdr -Method Get -TimeoutSec 15
            $rl = $u.rate_limit
            if ($rl -and $rl.primary_window -and $null -ne $rl.primary_window.used_percent) {
                $codex5      = [int][math]::Round([double]$rl.primary_window.used_percent)
                $codex5Reset = [string]$rl.primary_window.reset_at
                if ($rl.secondary_window -and $null -ne $rl.secondary_window.used_percent) {
                    $codex7      = [int][math]::Round([double]$rl.secondary_window.used_percent)
                    $codex7Reset = [string]$rl.secondary_window.reset_at
                }
                $codex5r  = Format-Reset $codex5Reset
                $codex7r  = Format-Reset $codex7Reset
                $codexErr = 0
            }
        }
    } catch { }
}

if ($codexErr -eq 0) {
    # Cache this good reading so a later failure can still show real numbers.
    try {
        $cache = [ordered]@{ codex5 = $codex5; codex7 = $codex7; codex5reset = $codex5Reset; codex7reset = $codex7Reset; updated = (Get-Date).ToString('s') }
        [System.IO.File]::WriteAllText($codexCache, ($cache | ConvertTo-Json -Compress), [System.Text.UTF8Encoding]::new($false))
    } catch { }
} elseif (Test-Path $codexCache) {
    # Endpoint failed — fall back to the last good reading.
    try {
        $c = Get-Content -Raw -LiteralPath $codexCache | ConvertFrom-Json
        if ($null -ne $c.codex5) {
            $codex5  = [int][math]::Round([double]$c.codex5)
            $codex7  = [int][math]::Round([double]$c.codex7)
            $codex5r = Format-Reset $c.codex5reset
            $codex7r = Format-Reset $c.codex7reset
            $codexErr = 0
        }
    } catch { }
}

# --- Claude: live usage from Anthropic's /api/oauth/usage endpoint -----------
# Account-wide — reflects Claude Code, Claude Desktop and claude.ai web, and
# works with Claude Code closed. The OAuth token comes from
# ~/.claude/.credentials.json. The endpoint is undocumented and rate-limits
# (429) aggressively; a good reading is cached to AIUsage-claude-cache.json so
# the widget can show the last-known value while the endpoint is throttled.
$claude5 = 0; $claude7 = 0; $claude5r = '-'; $claude7r = '-'; $claudeErr = 1
$claudeCache = Join-Path $PSScriptRoot '..\..\AIUsage-claude-cache.json'
$claude5Reset = $null; $claude7Reset = $null

$credFile = Join-Path $env:USERPROFILE '.claude\.credentials.json'
if (Test-Path $credFile) {
    try {
        $tok = (Get-Content -Raw -LiteralPath $credFile | ConvertFrom-Json).claudeAiOauth.accessToken
        if ($tok) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $hdr = @{ Authorization = "Bearer $tok"; 'anthropic-beta' = 'oauth-2025-04-20' }
            $u = Invoke-RestMethod -Uri 'https://api.anthropic.com/api/oauth/usage' -Headers $hdr -Method Get -TimeoutSec 15
            if ($u.five_hour -and $null -ne $u.five_hour.utilization) {
                $claude5      = [int][math]::Round([double]$u.five_hour.utilization)
                $claude5Reset = [string]$u.five_hour.resets_at
                if ($u.seven_day -and $null -ne $u.seven_day.utilization) {
                    $claude7      = [int][math]::Round([double]$u.seven_day.utilization)
                    $claude7Reset = [string]$u.seven_day.resets_at
                }
                $claude5r  = Format-Reset $claude5Reset
                $claude7r  = Format-Reset $claude7Reset
                $claudeErr = 0
            }
        }
    } catch { }
}

if ($claudeErr -eq 0) {
    # Cache this good reading so a later 429 can still show real numbers.
    try {
        $cache = [ordered]@{ claude5 = $claude5; claude7 = $claude7; claude5reset = $claude5Reset; claude7reset = $claude7Reset; updated = (Get-Date).ToString('s') }
        [System.IO.File]::WriteAllText($claudeCache, ($cache | ConvertTo-Json -Compress), [System.Text.UTF8Encoding]::new($false))
    } catch { }
} elseif (Test-Path $claudeCache) {
    # Endpoint failed (e.g. 429) — fall back to the last good reading. Reset
    # times are re-derived from the stored timestamps, so they stay accurate.
    try {
        $c = Get-Content -Raw -LiteralPath $claudeCache | ConvertFrom-Json
        if ($null -ne $c.claude5) {
            $claude5  = [int][math]::Round([double]$c.claude5)
            $claude7  = [int][math]::Round([double]$c.claude7)
            $claude5r = Format-Reset $c.claude5reset
            $claude7r = Format-Reset $c.claude7reset
            $claudeErr = 0
        }
    } catch { }
}

# --- Write the widget data file -----------------------------------------------
$line = "codex5=$codex5|codex7=$codex7|claude5=$claude5|claude7=$claude7|" +
        "codex5r=$codex5r|codex7r=$codex7r|claude5r=$claude5r|claude7r=$claude7r|" +
        "codexerr=$codexErr|claudeerr=$claudeErr|"
[System.IO.File]::WriteAllText($outFile, $line, [System.Text.UTF8Encoding]::new($false))
