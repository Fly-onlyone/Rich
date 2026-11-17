-- luacheck config for Rich's Rainmeter Lua scripts.
-- The scripts are UTF-16 LE (Rainmeter's native encoding), which luacheck cannot
-- read: script/test-skin.ps1 -LuaUtf8Dir <dir> writes UTF-8 copies to lint.

-- Rainmeter embeds Lua 5.1.
std = "lua51"

-- Objects Rainmeter injects into every script.
read_globals = { "SKIN", "SELF" }

-- Scripts keep their state in globals set in Initialize() and read by later
-- calls. Reading a global that is never assigned anywhere is still reported.
allow_defined = true

ignore = {
  "131", -- unused global: Rainmeter calls Initialize/Update, skins call the rest via !CommandMeasure
  "61.", -- whitespace only
}

max_line_length = false

-- Calendar.lua assigns these through loadstring('Size=...')(), which luacheck cannot see.
files["**/Widgets/Calendar.lua"] = { globals = { "Size", "OffsetX" } }
