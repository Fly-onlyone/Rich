[Variables]
; --- AI usage tracker widget (Claude) ---

; Threshold colours for the 5h / 7d bars. Colour keys off USED %, so a
; near-empty "remaining" bar turns yellow then red.
GreenColor=2dd255
YellowColor=ffc70a
RedColor=eb5546
YellowStarts=75
RedStarts=90

; Live bar colours — updated by the percentage measures in AIUsage.inc.
Claude5Color=#GreenColor#
Claude7Color=#GreenColor#

; Data state — 1 = no data (e.g. the Claude usage endpoint is down, no cache).
ActiveErr=0
ActiveOk=1

; How often the PowerShell parser re-runs (seconds). Kept modest so the Claude
; usage endpoint isn't polled too often — it rate-limits aggressively.
AIUsageRefreshSeconds=900
