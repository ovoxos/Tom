local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local win = DiscordLib:Window("Fishing Helper")
local serv = win:Server("Fishing Controls", "")

-- Autos Channel
local autos = serv:Channel("Autos")

-- Configuration settings
local config = {
    shakeSpeed = 0.1,              -- How fast the shake occurs
    autoShakeEnabled = false,      -- Whether auto-shake is enabled
    autoCastEnabled = false,       -- Whether auto-cast is enabled
    autoReelEnabled = false,       -- Whether auto-reel is enabled
    bigButtonScaleFactor = 2       -- Scale factor for making the shake button larger
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
    if not shake_ui then
        print("Shake UI not found!")
        return
    end

    local safezone = shake_ui:FindFirstChild("safezone")
    local button = safezone and safezone:FindFirstChild("button")

    if button then
        -- Scale the button
        if config.bigButtonScaleFactor then
            button.Size = UDim2.new(config.bigButtonScaleFactor, 0, config.bigButtonScaleFactor, 0)
        else
            button.Size = UDim2.new(1, 0, 1, 0)  -- Default size
        end

        -- Simulate click to shake the button
        if button.Visible then
            simulateClick(
                button.AbsolutePosition.X + button.AbsoluteSize.X / 2,
                button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
            )
        end
    else
        print("Shake button not found!")
    end
end

-- Updated Auto-Cast Function
local function autoCast()
    local resetEvent = localplayer:FindFirstChild("reset")
    if resetEvent then
        resetEvent:FireServer()
    else
        print("Reset event not found!")
        return
    end

    wait(1)  -- Delay to prevent rapid casting

    local args = {
        [1] = 14.2,  -- Updated cast distance
        [2] = 1      -- Cast force
    }

    local castEvent = localplayer:FindFirstChild("cast")
    if castEvent then
        castEvent:FireServer(unpack(args))
        print("Casting rod with distance: " .. args[1] .. " and force: " .. args[2])
    else
        print("Cast event not found!")
    end
end

-- Updated Auto-Reel Function
local function autoReel()
    if not config.autoReelEnabled then
        return  -- Exit the function if auto-reel is disabled
    end

    local args = {
        [1] = 100,  -- Reel speed
        [2] = true  -- Instant reeling
    }

    local reelEvent = replicated_storage:WaitForChild("events"):FindFirstChild("reelfinished")
    if reelEvent then
        reelEvent:FireServer(unpack(args))
        print("Reeling in with speed: " .. args[1] .. " and instant: " .. tostring(args[2]))
    else
        print("Reel event not found!")
    end
end

-- Add Toggle for Auto-Shake
autos:Toggle("Auto-Shake", false, function(bool)
    config.autoShakeEnabled = bool
    OrionLib:MakeNotification({
        Name = "Auto-Shake",
        Content = "Auto-Shake is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Add Toggle for Auto-Cast
autos:Toggle("Auto-Cast", false, function(bool)
    config.autoCastEnabled = bool
    OrionLib:MakeNotification({
        Name = "Auto-Cast",
        Content = "Auto-Cast is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Add Toggle for Auto-Reel
autos:Toggle("Auto-Reel", false, function(bool)
    config.autoReelEnabled = bool
    OrionLib:MakeNotification({
        Name = "Auto-Reel",
        Content = "Auto-Reel is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Main loop for auto-shake, auto-cast, and auto-reel
local shakeInterval = 0
local lastCast = 0
local lastReel = 0

run_service.Heartbeat:Connect(function()
    -- Handle auto-shake
    if config.autoShakeEnabled then
        if tick() - shakeInterval >= config.shakeSpeed then
            shake()
            shakeInterval = tick()
        end
    end

    -- Handle auto-cast
    if config.autoCastEnabled then
        if tick() - lastCast >= 1 then
            autoCast()
            lastCast = tick()
        end
    end

    -- Handle auto-reel
    if config.autoReelEnabled then
        if tick() - lastReel >= 1 then
            autoReel()
            lastReel = tick()
        end
    end
end)

win:Server("Main", "http://www.roblox.com/asset/?id=6031075938")
