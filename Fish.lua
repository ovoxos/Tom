teeeeeeeeeeeeeeest ﻿local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Create Notification
OrionLib:MakeNotification({
    Name = "Executed",
    Content = "WIP",
    Image = "rbxassetid://4483345998",
    Time = 5
})

local Window = OrionLib:MakeWindow({Name = "Tom Testing", HidePremium = false, SaveConfig = true, ConfigFolder = "Orion"})

-- Configuration
local config = {
    shakeSpeed = 0.1,              -- How fast the shake occurs
    autoShakeEnabled = false,      -- Whether auto-shake is enabled
    autoCastEnabled = false,       -- Whether auto-cast is enabled
    autoReelEnabled = false,       -- Whether auto-reel is enabled
    bigButtonScaleFactor = 2      -- Scale factor for making the shake button larger
}

-- Services
local players = game:GetService("Players")
local vim = game:GetService("VirtualInputManager")
local run_service = game:GetService("RunService")
local replicated_storage = game:GetService("ReplicatedStorage")
local localplayer = players.LocalPlayer
local playergui = localplayer.PlayerGui

-- Utility function to simulate a click
local function simulateClick(x, y)
    vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
    vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- Function to perform the shake action
local function shake()
    local shake_ui = playergui:FindFirstChild("shakeui")
    if shake_ui then
        local safezone = shake_ui:FindFirstChild("safezone")
        local button = safezone and safezone:FindFirstChild("button")

        if button then
            -- Scale the button if bigButtonScaleFactor is enabled
            if config.bigButtonScaleFactor then
                button.Size = UDim2.new(config.bigButtonScaleFactor, 0, config.bigButtonScaleFactor, 0)
            else
                button.Size = UDim2.new(1, 0, 1, 0)  -- Reset to default size if disabled
            end

            -- Simulate click to shake the button
            if button.Visible then
                simulateClick(
                    button.AbsolutePosition.X + button.AbsoluteSize.X / 2,
                    button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
                )
            end
        end
    end
end

-- Function to perform the auto-cast action after waiting for "reset"
local function autoCast()
    -- Wait for the "reset" event before casting
    local resetEvent = game:GetService("Players").LocalPlayer:WaitForChild("reset")
    resetEvent:FireServer()  -- Fire the reset event

    -- Now proceed with casting
    -- Set up the arguments to trigger the cast
    local args = {
        [1] = 23.5,  -- The cast distance or position
        [2] = 1      -- The force or type of cast
    }

    -- Fire the event to cast the rod
    game:GetService("Players").LocalPlayer:WaitForChild("cast"):FireServer(unpack(args))
    print("Casting rod!") -- Optional: for debugging purposes, you can print when the cast happens.
end

-- Function to perform the auto-reel action
local function autoReel()
    -- Set up the arguments to trigger the reel
    local args = {
        [1] = 100,  -- Reel speed or value
        [2] = true  -- Whether to reel instantly (true for no wait)
    }

    -- Trigger the reel action
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(args))
end

-- Toggle the auto-shake feature
local function toggleAutoShake()
    config.autoShakeEnabled = not config.autoShakeEnabled
end

-- Toggle the auto-cast feature
local function toggleAutoCast()
    config.autoCastEnabled = not config.autoCastEnabled
end

-- Toggle the auto-reel feature
local function toggleAutoReel()
    config.autoReelEnabled = not config.autoReelEnabled
end

-- Create a GUI section with a toggle button for auto-shake, auto-cast, and auto-reel
local PlayerTab = Window:MakeTab({
    Name = "Fishing",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerSection = PlayerTab:AddSection({
    Name = "Auto-Shake, Auto-Cast & Auto-Reel Controls"
})

-- Add button to toggle Auto-Shake
PlayerSection:AddButton({
    Name = "Toggle Auto-Shake",
    Callback = function()
        toggleAutoShake()
        OrionLib:MakeNotification({
            Name = "Auto-Shake Toggled",
            Content = config.autoShakeEnabled and "Auto-Shake Enabled!" or "Auto-Shake Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Add button to toggle Auto-Cast
PlayerSection:AddButton({
    Name = "Toggle Auto-Cast",
    Callback = function()
        toggleAutoCast()
        OrionLib:MakeNotification({
            Name = "Auto-Cast Toggled",
            Content = config.autoCastEnabled and "Auto-Cast Enabled!" or "Auto-Cast Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Add button to toggle Auto-Reel
PlayerSection:AddButton({
    Name = "Toggle Auto-Reel",
    Callback = function()
        toggleAutoReel()
        OrionLib:MakeNotification({
            Name = "Auto-Reel Toggled",
            Content = config.autoReelEnabled and "Auto-Reel Enabled!" or "Auto-Reel Disabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Main loop for auto-shake, auto-cast, and auto-reel
local shakeInterval = 0  -- Track the shake interval to ensure continuous shaking
run_service.Heartbeat:Connect(function()
    if config.autoShakeEnabled then
        if tick() - shakeInterval >= config.shakeSpeed then
            shake()  -- Perform shake action
            shakeInterval = tick()  -- Update the shake interval
        end
    end

    if config.autoCastEnabled then
        autoCast()  -- Perform cast action after waiting for reset
        wait(0.5)   -- Wait 0.5 seconds before casting again (can adjust as needed)
    end

    if config.autoReelEnabled then
        -- Perform auto-reel after shaking
        if config.autoShakeEnabled then
            autoReel()  -- Perform reel action
            wait(1)     -- Wait 1 second before next reel (adjust if needed)
        end
    end
end)

-- Initialize Orion UI
OrionLib:Init()
