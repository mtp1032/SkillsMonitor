--------------------------------------------------------------------------------------
-- FILE: SkillsMessages.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.SkillsMessages = ns.SkillsMessages or {}
local skills = ns.SkillsMessages

local dbg = ns.Debug
local L = ns.Locales.L

if not ns.Debug.loaded then
    error("Debug.lua failed to load.")
end
if dbg:debuggingIsEnabled() then
    dbg:print("Debug.lua loaded.")
end

-----------------------------------------------------------------
-- Message types
-----------------------------------------------------------------
local SKILL = 1
local LOOT  = 2
local MONEY = 3

-----------------------------------------------------------------
-- Starting positions (per message type)
-----------------------------------------------------------------
local START_POSITIONS = {
    [SKILL] = { x = 100, y = 25 },
    [LOOT]  = { x = 100, y = 25 },
    [MONEY] = { x = 100, y = 25 },
}

local function getStartingPosition(messageType)
    local position = START_POSITIONS[messageType]

    if not position then
        return 0, 0
    end

    return position.x, position.y
end

-----------------------------------------------------------------
-- Frame pool and active frames
-----------------------------------------------------------------
local framePool = {}
local activeFrames = {}

local STACK_SPACING = 28
local MESSAGE_DURATION = 3.0
local SCROLL_SPEED = 40

-----------------------------------------------------------------
-- Create a floating text frame
-----------------------------------------------------------------
local function createNewFrame()
    local frame = CreateFrame("Frame", nil, UIParent)

    frame:SetSize(5, 5)

    frame.Text = frame:CreateFontString(nil, "OVERLAY")
    frame.Text:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    frame.Text:SetPoint("CENTER")
    frame.Text:SetTextColor(1, 0, 0)
    frame.Text:SetShadowOffset(1, -1)

    frame.timeElapsed = 0
    frame.startX = 0
    frame.startY = 0

    return frame
end

-----------------------------------------------------------------
-- Return a floating frame to the pool
-----------------------------------------------------------------
local function releaseFrame(frame)
    frame:Hide()
    frame.Text:SetText("")

    table.insert(framePool, frame)
end

-----------------------------------------------------------------
-- Obtain a floating frame from the pool
-----------------------------------------------------------------
local function acquireFrame()
    local frame = table.remove(framePool)

    if not frame then
        frame = createNewFrame()
    end

    frame:Show()

    return frame
end

-----------------------------------------------------------------
-- Conveyor animation
-----------------------------------------------------------------
local conveyor = CreateFrame("Frame")
conveyor:Hide()

conveyor:SetScript("OnUpdate", function(self, elapsed)
    for index = #activeFrames, 1, -1 do
        local frame = activeFrames[index]

        frame.timeElapsed = frame.timeElapsed + elapsed

        if frame.timeElapsed >= MESSAGE_DURATION then
            table.remove(activeFrames, index)
            releaseFrame(frame)
        else
            -----------------------------------------------------
            -- Calculate position from starting coordinates
            -----------------------------------------------------
            local currentY =
                frame.startY + (SCROLL_SPEED * frame.timeElapsed)

            frame:ClearAllPoints()
            frame:SetPoint(
                "CENTER",
                UIParent,
                "CENTER",
                frame.startX,
                currentY
            )

            -----------------------------------------------------
            -- Fade out
            -----------------------------------------------------
            local alpha = 1 - (frame.timeElapsed / MESSAGE_DURATION)

            frame:SetAlpha(math.max(alpha, 0))
        end
    end

    -------------------------------------------------------------
    -- Stop updates when all messages have expired
    -------------------------------------------------------------
    if #activeFrames == 0 then
        self:Hide()
    end
end)

-----------------------------------------------------------------
-- Display a floating message
-----------------------------------------------------------------
local function displayMsg(messageType, message)
    local frame = acquireFrame()

    frame.Text:SetText(message)

    -------------------------------------------------------------
    -- Optional debugging output
    -------------------------------------------------------------
    if dbg:debuggingIsEnabled() then
        print(dbg:print(message))
    end

    -------------------------------------------------------------
    -- Preserve global stacking behavior
    -------------------------------------------------------------
    local startX, startY = getStartingPosition(messageType)

    local dynamicY =
        startY - (#activeFrames * STACK_SPACING)

    frame.startX = startX
    frame.startY = dynamicY
    frame.timeElapsed = 0

    frame:SetAlpha(1)

    frame:ClearAllPoints()
    frame:SetPoint(
        "CENTER",
        UIParent,
        "CENTER",
        startX,
        dynamicY
    )

    table.insert(activeFrames, frame)

    -------------------------------------------------------------
    -- Start the conveyor if necessary
    -------------------------------------------------------------
    if not conveyor:IsShown() then
        conveyor:Show()
    end
end

-----------------------------------------------------------------
-- Public testing interface
-----------------------------------------------------------------

-----------------------------------------------------------------
-- Display a test message using the production display function.
--
-- Accepted event names:
--     CHAT_MSG_SKILL
--     CHAT_MSG_LOOT
--     CHAT_MSG_MONEY
--
-- Returns:
--     true, nil          Success
--     false, errorDescr  Invalid event name or message
-----------------------------------------------------------------
function skills:displayTestMessage(eventName, message)
    local messageType

    if eventName == "CHAT_MSG_SKILL" then
        messageType = SKILL

    elseif eventName == "CHAT_MSG_LOOT" then
        messageType = LOOT

    elseif eventName == "CHAT_MSG_MONEY" then
        messageType = MONEY

    else
        return false, "Unknown test event: " .. tostring(eventName)
    end

    if type(message) ~= "string" then
        return false, "Test message must be a string."
    end

    displayMsg(messageType, message)

    return true, nil
end

-----------------------------------------------------------------
-- Return the number of currently active floating messages.
-----------------------------------------------------------------
function skills:getActiveMessageCount()
    return #activeFrames
end

-----------------------------------------------------------------
-- Event handling
-----------------------------------------------------------------
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SKILL")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local message = ...

    -------------------------------------------------------------
    -- Addon initialization
    -------------------------------------------------------------
    if event == "ADDON_LOADED" then
        if message == ADDON_NAME then
            print(L["ADDON_LOADED_MSG"])
            print( debugstack(2))
            self:UnregisterEvent("ADDON_LOADED")
        end

        return
    end

    -------------------------------------------------------------
    -- Floating chat messages
    -------------------------------------------------------------
    if event == "CHAT_MSG_LOOT" then
        displayMsg(LOOT, message)

    elseif event == "CHAT_MSG_SKILL" then
        displayMsg(SKILL, message)

    elseif event == "CHAT_MSG_MONEY" then
        displayMsg(MONEY, message)
    end
end)

-----------------------------------------------------------------
-- Module loaded
-----------------------------------------------------------------
ns.SkillsMessages.loaded = true
