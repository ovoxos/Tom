local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local win = DiscordLib:Window("Fishing Helper")

local serv = win:Server("Fishing Controls", "")

-- Removed the "Buttons" channel and renamed "Toggles" to "Autos"
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

-- Function to perform the auto-cast action
local function autoCast()
    local resetEvent = game:GetService("Players").LocalPlayer:WaitForChild("reset")
    resetEvent:FireServer()

    -- Delay before casting again to prevent rapid casting
    wait(1)  -- You can adjust this wait time if necessary

    local args = {
        [1] = 23.5,  -- The cast distance or position
        [2] = 1      -- The force or type of cast
    }

    game:GetService("Players").LocalPlayer:WaitForChild("cast"):FireServer(unpack(args))
    print("Casting rod!")
end

-- Function to perform the auto-reel action
local function autoReel()
    -- Ensure auto-reel happens after the cast, so we only reel when appropriate
    local args = {
        [1] = 100,  -- Reel speed or value
        [2] = true  -- Whether to reel instantly (true for no wait)
    }

    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(args))
    print("Reeling in!")
end

-- Add Toggle for Auto-Shake
autos:Toggle("Auto-Shake", false, function(bool)
    config.autoShakeEnabled = bool
    print("Auto-Shake is: " .. tostring(config.autoShakeEnabled))
    OrionLib:MakeNotification({
        Name = "Auto-Shake",
        Content = config.autoShakeEnabled and "Enabled" or "Disabled",
        Image = "rbxassetid://4483345998",  -- Replace with your preferred image if needed
        Time = 3
    })
end)

-- Add Toggle for Auto-Cast
autos:Toggle("Auto-Cast", false, function(bool)
    config.autoCastEnabled = bool
    print("Auto-Cast is: " .. tostring(config.autoCastEnabled))
    OrionLib:MakeNotification({
        Name = "Auto-Cast",
        Content = config.autoCastEnabled and "Enabled" or "Disabled",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Add Toggle for Auto-Reel
autos:Toggle("Auto-Reel", false, function(bool)
    config.autoReelEnabled = bool
    print("Auto-Reel is: " .. tostring(config.autoReelEnabled))
    OrionLib:MakeNotification({
        Name = "Auto-Reel",
        Content = config.autoReelEnabled and "Enabled" or "Disabled",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Main loop for auto-shake, auto-cast, and auto-reel
local shakeInterval = 0  -- Track the shake interval to ensure continuous shaking
run_service.Heartbeat:Connect(function()
    -- Handle auto-shake
    if config.autoShakeEnabled then
        if tick() - shakeInterval >= config.shakeSpeed then
            shake()  -- Perform shake action
            shakeInterval = tick()  -- Update the shake interval
        end
    end

    -- Handle auto-cast
    if config.autoCastEnabled then
        autoCast()  -- Perform cast action after waiting for reset
        wait(1)   -- Add a delay to avoid rapid casting
    end

    -- Handle auto-reel
    if config.autoReelEnabled then
        if config.autoCastEnabled then
            -- Only reel if auto-cast is enabled (to prevent reel without casting)
            autoReel()  -- Perform reel action
            wait(1)     -- Wait a second before next reel (adjust as needed)
        end
    end
end)

win:Server("Main", "http://www.roblox.com/asset/?id=6031075938")
