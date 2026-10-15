--------------------------------------------------------------------------------------
-- FILE: Debug.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.Debug = ns.Debug or {} 

local DEBUGGING_IS_ENABLED = false

local L = ns.Locales.L
local dbg = ns.Debug

if not ns.Locales.loaded then 
    error("Locales.lua not loaded")
end
if DEBUGGING_IS_ENABLED then
    print("Locales.lua loaded.")
end

-----------------------------------------------------------------
-- Private (local) functions
-----------------------------------------------------------------
local function getPrefix( stackTrace )
    local sourceFile, lineNumber =
        stackTrace:match("[\\/]([^\\/:]+):(%d+)")

    if not sourceFile or not lineNumber then
        return "[Unknown:0] "
    end
    local prefix = string.format("[%s:%s] ", sourceFile, lineNumber)
    return prefix
end

local function formatMessage(...)
    local values = {}
    local valueCount = select("#", ...)

    for index = 1, valueCount do
        local value = select(index, ...)

        if value == nil then
            value = "<nil>"
        elseif type(value) ~= "string" then
            value = tostring(value)
        end

        values[#values + 1] = value
    end
    return table.concat(values, " ")
end

-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------
function dbg:print(...)
    local prefix = getPrefix( debugstack(2) )
    return prefix .. formatMessage(...)
end

function dbg:debuggingIsEnabled()
    return DEBUGGING_IS_ENABLED
end

function dbg:enableDebugging()
    debuggingIsEnabled = true
    return DEBUGGING_IS_ENABLED
end

function dbg:disableDebugging()
    debuggingIsEnabled = false
    return DEBUGGING_IS_ENABLED
end

ns.Debug.loaded = true 
dbg:print("Debug.lua loaded.")
