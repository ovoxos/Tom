local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local win = DiscordLib:Window("Fishing Helper")

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
local bb = game:service'VirtualUser'

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

-- Function for Auto-Reel
local function autoReel()
    local args = {
        [1] = 100,
        [2] = true
    }
    replicated_storage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(args))
    print("Reeling in!")
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

-- Add Teleport Dropdown and Button
local selectedLocation = "Ancient Archive"  -- Default teleport location

teleport:Dropdown("Select Teleport Location", {"Ancient Archive", "Ancient Isle", "Brine Pool", "Desolate Deep", "Forsaken Shore", "Keeper Altar", "Moosewood", "Mushgrove", "Roslit", "Roslit Volcano", "Snowcap Island", "Sunstone", "Terrapin", "The Depth", "Vertigo"}, function(selected)
    selectedLocation = selected
end)

teleport:Button("Teleport", function()
    local targetPositions = {
        ["Ancient Archive"] = Vector3.new(-3162, -745, 1701),
        ["Ancient Isle"] = Vector3.new(6067, 200, 285),
        ["Brine Pool"] = Vector3.new(-1793, -141, -3297),
        ["Desolate Deep"] = Vector3.new(-1656, -211, -2848),
        ["Forsaken Shore"] = Vector3.new(-2487, 135, 1558),
        ["Keeper Altar"] = Vector3.new(1313, -803, -120),
        ["Moosewood"] = Vector3.new(388, 135, 254),
        ["Mushgrove"] = Vector3.new(2511, 134, -711),
        ["Roslit"] = Vector3.new(-1527, 134, 621),
        ["Roslit Volcano"] = Vector3.new(-1903, 164, 317),
        ["Snowcap Island"] = Vector3.new(2682, 156, 2405),
        ["Sunstone"] = Vector3.new(-922, 134, -1115),
        ["Terrapin"] = Vector3.new(-198, 137, 1951),
        ["The Depth"] = Vector3.new(991, -712, 1333),
        ["Vertigo"] = Vector3.new(-107, -512, 1139)
    }

    local targetPosition = targetPositions[selectedLocation]
    if targetPosition then
        localplayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "Teleporting to " .. selectedLocation,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Invalid teleport location",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end)

-- Add Infinite Yield Button in "Other" category
other:Button("Infinite Yield", function()
    -- Execute the Infinite Yield script when the button is pressed
    local success, err = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source', true))()
    end)
    
    -- Handle potential errors
    if not success then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Failed to execute Infinite Yield: " .. err,
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    else
        OrionLib:MakeNotification({
            Name = "Infinite Yield",
            Content = "Successfully executed Infinite Yield!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end)

-- Add Toggle for Anti-AFK in "Other" category
other:Toggle("Anti-AFK", false, function(bool)
    config.antiAfkEnabled = bool
    OrionLib:MakeNotification({
        Name = "Anti-AFK",
        Content = "Anti-AFK is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Anti-AFK feature
run_service.RenderStepped:Connect(function()
    if config.antiAfkEnabled then
        bb:ClickButton()
    end
end)

-- Main loop for Auto-Cast, Auto-Reel, and Auto-Shake
run_service.Heartbeat:Connect(function()
    if config.autoCastEnabled then
        autoCast()
    end

    if config.autoReelEnabled then
        autoReel()
    end

    if config.autoShakeEnabled then
        shake()
    end
end)
