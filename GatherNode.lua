--------------------------------------------------------------------------------------
-- FILE: GatherNode.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.GatherNode = ns.GatherNode or {}
local dbg = ns.Debug

if not ns.SkillsMessages.loaded then
    error("SkillsMessages.lua not loaded")
end
if dbg:debuggingIsEnabled() then
    print("SkillsMessages.lua loaded.")
end

--------------------------------------------------------------------------------
-- Gathering skill requirements
--------------------------------------------------------------------------------

local NODE_SKILL = {

    ------------------------------------------------------------------------
    -- Herbalism
    ------------------------------------------------------------------------

    ["Peacebloom"]          = 1,
    ["Silverleaf"]          = 1,
    ["Earthroot"]           = 15,
    ["Mageroyal"]           = 50,
    ["Briarthorn"]          = 70,
    ["Stranglekelp"]        = 85,
    ["Bruiseweed"]          = 100,
    ["Wild Steelbloom"]     = 115,
    ["Grave Moss"]          = 120,
    ["Kingsblood"]          = 125,
    ["Liferoot"]            = 150,
    ["Fadeleaf"]            = 160,
    ["Goldthorn"]           = 150,
    ["Khadgar's Whisker"]   = 185,
    ["Wintersbite"]         = 195,
    ["Firebloom"]           = 205,
    ["Purple Lotus"]        = 210,
    ["Arthas' Tears"]       = 220,
    ["Sungrass"]            = 230,
    ["Blindweed"]           = 235,
    ["Ghost Mushroom"]      = 245,
    ["Gromsblood"]          = 250,
    ["Golden Sansam"]       = 260,
    ["Dreamfoil"]           = 270,
    ["Mountain Silversage"] = 280,
    ["Plaguebloom"]         = 285,
    ["Icecap"]              = 290,
    ["Black Lotus"]         = 300,

    ------------------------------------------------------------------------
    -- Mining: conventional node names
    ------------------------------------------------------------------------

    ["Copper Vein"]         = 1,
    ["Tin Vein"]            = 65,
    ["Silver Vein"]         = 75,
    ["Iron Deposit"]        = 125,
    ["Gold Vein"]           = 155,
    ["Mithril Deposit"]     = 175,
    ["Truesilver Deposit"]  = 230,
    ["Small Thorium Vein"]  = 255,
    ["Rich Thorium Vein"]   = 275,

    ------------------------------------------------------------------------
    -- Mining: ore-name alternatives
    ------------------------------------------------------------------------

    ["Copper Ore"]          = 1,
    ["Tin Ore"]             = 65,
    ["Silver Ore"]          = 75,
    ["Iron Ore"]            = 125,
    ["Gold Ore"]            = 155,
    ["Mithril Ore"]         = 175,
    ["Truesilver Ore"]      = 230,
    ["Small Thorium Ore"]   = 255,
    ["Rich Thorium Ore"]    = 275,
}
--------------------------------------------------------------------------------
-- Read a tooltip line
--------------------------------------------------------------------------------

local function getTooltipLine(tooltip, lineNumber)
    local tooltipName = tooltip:GetName()
    if not tooltipName then
        return nil
    end
    local fontString = _G[tooltipName .. "TextLeft" .. lineNumber]
    if not fontString then
        return nil
    end
    return fontString:GetText()
end

--------------------------------------------------------------------------------
-- Check whether the requirement is already displayed
--------------------------------------------------------------------------------

local function hasRequirementLine(tooltip, requirementText)
    for lineNumber = 1, tooltip:NumLines() do

        if getTooltipLine(tooltip, lineNumber) == requirementText then
            return true
        end

    end
    return false
end

--------------------------------------------------------------------------------
-- Add the gathering requirement
--------------------------------------------------------------------------------

local function updateGatheringTooltip(tooltip)

    if not tooltip or not tooltip:IsShown() then
        return
    end
    if dbg:debuggingIsEnabled() then
    end

    ------------------------------------------------------------------------
    -- Read the two lines Forever currently displays
    ------------------------------------------------------------------------

    local nodeName = getTooltipLine(tooltip, 1)
    local profession = getTooltipLine(tooltip, 2)

    if not nodeName or not profession then
        return
    end

    ------------------------------------------------------------------------
    -- Only process Herbalism and Mining tooltips
    ------------------------------------------------------------------------

    if profession ~= "Herbalism" and profession ~= "Mining" then
        return
    end

    ------------------------------------------------------------------------
    -- Look up the required skill
    ------------------------------------------------------------------------

    local requiredSkill = NODE_SKILL[nodeName]

    if not requiredSkill then
        return
    end

    ------------------------------------------------------------------------
    -- Construct the additional tooltip line
    ------------------------------------------------------------------------

    local requirementText = string.format(
        "Requires %s (%d)",
        profession,
        requiredSkill
    )
    ------------------------------------------------------------------------
    -- Avoid adding the same line more than once
    ------------------------------------------------------------------------

    if hasRequirementLine(tooltip, requirementText) then
        return
    end

    ------------------------------------------------------------------------
    -- Append the requirement
    ------------------------------------------------------------------------

    tooltip:AddLine(requirementText, 1, 0.82, 0)

    -- Ensure the tooltip is wide enough for the requirement text.
    local textWidth = tooltip:GetWidth()
    local minimumWidth = 220

    if textWidth < minimumWidth then
        tooltip:SetWidth(minimumWidth)
    end
    tooltip:SetHeight(tooltip:GetHeight() + 6)
end

--------------------------------------------------------------------------------
-- Hook the tooltip
--------------------------------------------------------------------------------

hooksecurefunc(GameTooltip, "Show", function(tooltip)

    updateGatheringTooltip(tooltip)

end)

--------------------------------------------------------------------------------
-- Module loaded
--------------------------------------------------------------------------------

ns.GatherNode.loaded = true
