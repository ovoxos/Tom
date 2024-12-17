local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local win = DiscordLib:Window("Skibidi Fisch")

-- Main Functions Channel (formerly Fishing Controls)
local mainFunctions = win:Server("Main Functions", "http://www.roblox.com/asset/?id=6031075938")

-- Autos Channel inside Main Functions (formerly Fishing Controls)
local autos = mainFunctions:Channel("Autos")

-- Miscellaneous Channel (formerly Main)
local miscellaneous = win:Server("Miscellaneous", "")

-- Other Channel inside Miscellaneous
local other = miscellaneous:Channel("Other")

-- Teleport Channel inside Miscellaneous (formerly Main)
local teleport = miscellaneous:Channel("Teleport")

-- Configuration settings
local config = {
    shakeSpeed = 0.1, -- How fast the shake occurs
    autoShakeEnabled = false, -- Whether auto-shake is enabled
    autoCastEnabled = false, -- Whether auto-cast is enabled
    autoReelEnabled = false, -- Whether auto-reel is enabled
    bigButtonScaleFactor = 2, -- Scale factor for making the shake button larger
    antiAfkEnabled = false -- Whether anti-afk is enabled
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
            button.Size = UDim2.new(1, 0, 1, 0) -- Default size
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

-- Optimized Auto-Cast Function with Rod Selection
local function autoCast()
    local rodNames = {
        "Rod Of The Depths", "Flimsy Rod", "Training Rod", "Relic Rod", "Astral Rod",
        "Destiny Rod", "Steady Rod", "Aurora Rod", "Rod Of The Forgotten Fang",
        "Lucky Rod", "Nocturnal Rod", "Kings Rod", "Carbon Rod", "Fungal Rod",
        "Mythical Rod", "Sunken Rod", "Candy Cane Rod", "Reinforced Rod",
        "Fast Rod", "No-Life Rod", "Fortune Rod", "Antler Rod", "Precision Rod",
        "Magma Rod", "Frost Warden Rod", "Rod Of The Eternal King", "Magnet Rod",
        "Celestial Rod", "Long Rod", "Krampus's Rod", "Scurvy Rod", "Plastic Rod",
        "The Lost Rod", "Rapid Rod", "Trident Rod", "Voyager Rod", "North-Star Rod",
        "Phoenix Rod", "Stone Rod"
    }

    local args = {97.4, 1} -- Cast distance and force
    local character = localplayer.Character
    local rodMap = {}

    -- Create a lookup table for rods in the character
    for _, rod in ipairs(character:GetChildren()) do
        if table.find(rodNames, rod.Name) then
            rodMap[rod.Name] = rod
        end
    end

    -- Find the first available rod and cast it
    for _, rodName in ipairs(rodNames) do
        local rod = rodMap[rodName]
        if rod then
            if rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
                -- Fire the cast event
                rod.events.cast:FireServer(unpack(args))
                print("Casting with rod: " .. rod.Name)
                return -- Exit after casting
            else
                warn("Rod found, but no valid 'events.cast' detected!")
                return -- Exit if there's an issue with this rod
            end
        end
    end

    warn("No rod found in the character!")
end

-- Auto-Reel Function
local function autoReel()
    local args = {
        [1] = 100, -- Reel speed (adjust as needed)
        [2] = true  -- Reel direction (true for reel in, false for reel out)
    }

    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(args))
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

-- Add Toggle for Auto-Reel (Blatant)
autos:Toggle("Auto-Reel (Blatant)", false, function(bool)
    config.autoReelEnabled = bool
    OrionLib:MakeNotification({
        Name = "Auto-Reel (Blatant)",
        Content = "Auto-Reel (Blatant) is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Add Teleport Button under "Miscellaneous" Section
teleport:Button("Teleport", function()
    local spawnLocation = workspace:FindFirstChild("SpawnLocation")
    if spawnLocation then
        localplayer.Character:SetPrimaryPartCFrame(spawnLocation.CFrame)
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "You have been teleported to the spawn location.",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        print("Spawn location not found!")
    end
end)

-- Add "Infinite Yield" Button inside "Other" Section
other:Button("Infinite Yield", function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'), true))() -- Execute Infinite Yield script
    OrionLib:MakeNotification({
        Name = "Infinite Yield",
        Content = "Infinite Yield script executed.",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Add Anti AFK Button in "Other"
other:Toggle("Anti AFK", false, function(bool)
    config.antiAfkEnabled = bool
    OrionLib:MakeNotification({
        Name = "Anti AFK",
        Content = "Anti AFK is now " .. (bool and "Activated" or "Deactivated"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Main loop for auto-shake, auto-cast, and anti-afk
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
        if tick() - lastCast >= 0.5 then -- Launch a new cast every 0.5 seconds
            autoCast()
            lastCast = tick()
        end
    end

    -- Handle auto-reel (Blatant)
    if config.autoReelEnabled then
        if tick() - lastReel >= 1 then -- Check every 1s for reel
            autoReel()
            lastReel = tick()
        end
    end

    -- Handle Anti-AFK
    if config.antiAfkEnabled then
        vim:SendMouseMove(0, 0) -- Simulate mouse movement to prevent AFK
    end
end)
