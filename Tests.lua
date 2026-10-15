--------------------------------------------------------------------------------------
-- FILE: Tests.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.Tests = ns.Tests or {}

local SkillsMessages = ns.SkillsMessages
local dbg = ns.Debug
local L = ns.Locales.L

-----------------------------------------------------------------
-- Dependency validation
-----------------------------------------------------------------
if not ns.GatherNode.loaded then
    error("GatherNode.lua not loaded")
end
if dbg:debuggingIsEnabled() then
    print("GatherNode.lua loaded.")
    print("Tests.Lua loaded.")
end

ns.Tests = ns.Tests or {}

if not dbg:debuggingIsEnabled() then
    return
end
-----------------------------------------------------------------
-- Test configuration
-----------------------------------------------------------------
local MESSAGE_DURATION = 3.0

-- Allow a little extra time for animation updates.
local EXPIRATION_DELAY = MESSAGE_DURATION + 0.5

-- Space test groups far enough apart to prevent interference.
local TEST_INTERVAL = 5.0

-----------------------------------------------------------------
-- Test statistics
-----------------------------------------------------------------
local testsPassed = 0
local testsFailed = 0

-----------------------------------------------------------------
-- Private helper functions
-----------------------------------------------------------------

-----------------------------------------------------------------
-- Print a test message to the chat window
-----------------------------------------------------------------
local function printTestMessage(message)
    print("[SkillsMonitor Tests] " .. tostring(message))
end

-----------------------------------------------------------------
-- Record an assertion result
-----------------------------------------------------------------
local function assertEqual(actual, expected, description)
    if actual == expected then
        testsPassed = testsPassed + 1

        printTestMessage(
            "PASS: " .. description
        )

        return true
    end

    testsFailed = testsFailed + 1

    printTestMessage(
        string.format(
            "FAIL: %s (expected %s, received %s)",
            description,
            tostring(expected),
            tostring(actual)
        )
    )

    return false
end

-----------------------------------------------------------------
-- Display a test message and report an unexpected failure
-----------------------------------------------------------------
local function sendTestMessage(eventName, message)
    local successful, errorDescr =
        SkillsMessages:displayTestMessage(eventName, message)

    if not successful then
        testsFailed = testsFailed + 1

        printTestMessage(
            "FAIL: " .. tostring(errorDescr)
        )
    end

    return successful
end

-----------------------------------------------------------------
-- Verify that all messages have expired
-----------------------------------------------------------------
local function verifyMessagesExpired(testName)
    local activeCount = SkillsMessages:getActiveMessageCount()

    assertEqual(
        activeCount,
        0,
        testName .. ": all messages expired"
    )
end

-----------------------------------------------------------------
-- TEST 1
--
-- Four rapid loot messages
--
-- Purpose:
--     Verify that several messages can be displayed
--     simultaneously.
--
-- Visual expectation:
--     Four messages appear without overwriting one another.
-----------------------------------------------------------------
local function test1()
    printTestMessage("TEST 1: Four rapid loot messages")

    local initialCount = SkillsMessages:getActiveMessageCount()

    assertEqual(
        initialCount,
        0,
        "Test 1: initial active count"
    )

    for index = 1, 4 do
        sendTestMessage(
            "CHAT_MSG_LOOT",
            string.format(
                "TEST 1 - Loot item %d",
                index
            )
        )
    end

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        4,
        "Test 1: four messages active"
    )

    printTestMessage(
        "VISUAL CHECK: Four loot messages should be separated."
    )

    C_Timer.After(EXPIRATION_DELAY, function()
        verifyMessagesExpired("Test 1")
    end)
end

-----------------------------------------------------------------
-- TEST 2
--
-- Mixed message types
--
-- Purpose:
--     Verify that skill, loot, and money messages
--     can coexist.
--
-- Visual expectation:
--     Messages appear in their configured regions.
-----------------------------------------------------------------
local function test2()
    printTestMessage("TEST 2: Mixed message types")

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        0,
        "Test 2: initial active count"
    )

    sendTestMessage(
        "CHAT_MSG_SKILL",
        "TEST 2 - Your skill has increased!"
    )

    sendTestMessage(
        "CHAT_MSG_LOOT",
        "TEST 2 - You receive loot: [Test Sword]"
    )

    sendTestMessage(
        "CHAT_MSG_MONEY",
        "TEST 2 - You loot 12 Gold."
    )

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        3,
        "Test 2: three messages active"
    )

    printTestMessage(
        "VISUAL CHECK: Skill, loot, and money messages should be visible."
    )

    C_Timer.After(EXPIRATION_DELAY, function()
        verifyMessagesExpired("Test 2")
    end)
end

-----------------------------------------------------------------
-- TEST 3
--
-- Twenty rapid loot messages
--
-- Purpose:
--     Stress-test frame creation, stacking, and expiration.
--
-- Visual expectation:
--     Messages should animate independently.
--
-- Note:
--     Some messages may begin below the visible screen.
--     This is expected with the current global stacking
--     algorithm and is not an automatic test failure.
-----------------------------------------------------------------
local function test3()
    printTestMessage("TEST 3: Twenty rapid loot messages")

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        0,
        "Test 3: initial active count"
    )

    for index = 1, 20 do
        sendTestMessage(
            "CHAT_MSG_LOOT",
            string.format(
                "TEST 3 - Stress item %02d",
                index
            )
        )
    end

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        20,
        "Test 3: twenty messages active"
    )

    printTestMessage(
        "VISUAL CHECK: Watch for overlap or unexpected animation."
    )

    C_Timer.After(EXPIRATION_DELAY, function()
        verifyMessagesExpired("Test 3")
    end)
end

-----------------------------------------------------------------
-- TEST 4
--
-- Conveyor restart and frame reuse
--
-- Purpose:
--     Verify that a new message works after all previous
--     messages have expired.
--
-- Visual expectation:
--     A new message appears and animates normally.
-----------------------------------------------------------------
local function test4()
    printTestMessage("TEST 4: Conveyor restart")

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        0,
        "Test 4: initial active count"
    )

    sendTestMessage(
        "CHAT_MSG_LOOT",
        "TEST 4 - Conveyor restarted successfully!"
    )

    assertEqual(
        SkillsMessages:getActiveMessageCount(),
        1,
        "Test 4: new message active"
    )

    printTestMessage(
        "VISUAL CHECK: Message should scroll upward and fade normally."
    )

    C_Timer.After(EXPIRATION_DELAY, function()
        verifyMessagesExpired("Test 4")
    end)
end

-----------------------------------------------------------------
-- Print final test results
-----------------------------------------------------------------
local function printTestSummary()
    printTestMessage("----------------------------------------")

    printTestMessage(
        string.format(
            "RESULTS: %d passed, %d failed",
            testsPassed,
            testsFailed
        )
    )

    if testsFailed == 0 then
        printTestMessage("All automated checks passed.")
    else
        printTestMessage("One or more automated checks failed.")
    end

    printTestMessage(
        "Remember to review the visual checks separately."
    )

    printTestMessage("----------------------------------------")
end

-----------------------------------------------------------------
-- Run all tests sequentially
-----------------------------------------------------------------
local function unitTests()
    printTestMessage("----------------------------------------")
    printTestMessage("Starting SkillsMonitor unit tests")
    printTestMessage("----------------------------------------")

    -------------------------------------------------------------
    -- Test 1: Four loot messages
    -------------------------------------------------------------
    C_Timer.After(1.0, function()
        test1()
    end)

    -------------------------------------------------------------
    -- Test 2: Mixed messages
    -------------------------------------------------------------
    C_Timer.After(1.0 + TEST_INTERVAL, function()
        test2()
    end)

    -------------------------------------------------------------
    -- Test 3: Stress test
    -------------------------------------------------------------
    C_Timer.After(1.0 + (TEST_INTERVAL * 2), function()
        test3()
    end)

    -------------------------------------------------------------
    -- Test 4: Conveyor restart
    -------------------------------------------------------------
    C_Timer.After(1.0 + (TEST_INTERVAL * 3), function()
        test4()
    end)

    -------------------------------------------------------------
    -- Final summary
    --
    -- Wait until Test 4's messages have expired.
    -------------------------------------------------------------
    C_Timer.After(
        1.0 + (TEST_INTERVAL * 3) + EXPIRATION_DELAY + 0.2,
        function()
            printTestSummary()
        end
    )
end

-----------------------------------------------------------------
-- Module loaded
-----------------------------------------------------------------
ns.Tests.loaded = true

if dbg:debuggingIsEnabled() then
    dbg:print("Tests.lua loaded.")
end

-----------------------------------------------------------------
-- Execute tests
-----------------------------------------------------------------
unitTests()