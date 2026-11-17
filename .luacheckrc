-- luacheck config for Rich's Rainmeter Lua scripts.
-- The scripts are UTF-16 LE (Rainmeter's native encoding), which luacheck cannot
-- read: script/test-skin.ps1 -LuaUtf8Dir <dir> writes UTF-8 copies to lint.

-- Rainmeter embeds Lua 5.1.
std = "lua51"

-- Objects Rainmeter injects into every script.
read_globals = { "SKIN", "SELF" }

-- Top-level functions are Rainmeter entry points (Initialize, Update) or are
-- called from skins via [!CommandMeasure Script "fn()"], so they must be global.
allow_defined_top = true

max_line_length = false
