local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local win = DiscordLib:Window("Skibidi Tom")

-- Main Functions Channel
local mainFunctions = win:Server("Main Functions", "http://www.roblox.com/asset/?id=6031075938")

-- Autos Channel inside Main Functions
local autos = mainFunctions:Channel("Autos")

-- Miscellaneous Channel
local miscellaneous = win:Server("Miscellaneous", "")

-- Other Channel inside Miscellaneous
local other = miscellaneous:Channel("Other")

-- Teleport Channel inside Miscellaneous
local teleport = miscellaneous:Channel("Teleport")

-- Character Channel inside Miscellaneous
local flyChannel = miscellaneous:Channel("Character")

-- Configuration settings
local config = {
    shakeSpeed = 0.1,
    autoShakeEnabled = false,
    autoCastEnabled = false,
    autoReelEnabled = false,
    bigButtonScaleFactor = 5,
    antiAfkEnabled = false,
    flyEnabled = false,
    freezeCharacterEnabled = false -- New feature toggle state
}

-- Services
local players = game:GetService("Players")
local vim = game:GetService("VirtualInputManager")
local run_service = game:GetService("RunService")
local replicated_storage = game:GetService("ReplicatedStorage")
local localplayer = players.LocalPlayer
local playergui = localplayer.PlayerGui
local vu = game:GetService("VirtualUser")

-- Utility function to simulate a click
local function simulateClick(x, y)
    vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
    vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- Function to perform the shake action
local function shake()
    local shake_ui = playergui:FindFirstChild("shakeui")
    if not shake_ui then
        return
    end

    local safezone = shake_ui:FindFirstChild("safezone")
    local button = safezone and safezone:FindFirstChild("button")

    if button and button.Visible then
        -- Scale the button to make it bigger
        if config.bigButtonScaleFactor then
            button.Size = UDim2.new(config.bigButtonScaleFactor, 0, config.bigButtonScaleFactor, 0)
        else
            button.Size = UDim2.new(1, 0, 1, 0)
        end

        -- Simulate click to shake the button
        simulateClick(
            button.AbsolutePosition.X + button.AbsoluteSize.X / 2,
            button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
        )
    end
end

-- Optimized Auto-Cast Function with Rod Selection and Check
local function autoCast()
    -- Check if player is already fishing
    local fishingUI = playergui:FindFirstChild("FishingUI")
    if fishingUI and fishingUI:FindFirstChild("CastButton") and not fishingUI.CastButton.Visible then
        return
    end

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

    local args = {97.4, 1}
    local character = localplayer.Character
    local rodMap = {}

    for _, rod in ipairs(character:GetChildren()) do
        if table.find(rodNames, rod.Name) then
            rodMap[rod.Name] = rod
        end
    end

    for _, rodName in ipairs(rodNames) do
        local rod = rodMap[rodName]
        if rod then
            if rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
                rod.events.cast:FireServer(unpack(args))
                return
            end
        end
    end
end

local function autoReel()
    local args = {
        [1] = 100,
        [2] = true
    }
    replicated_storage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(args))
end

autos:Toggle("Auto-Shake", false, function(bool)
    if config.autoShakeEnabled ~= bool then
        config.autoShakeEnabled = bool
        OrionLib:MakeNotification({
            Name = "Auto-Shake",
            Content = "Auto-Shake is now " .. (bool and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end)

autos:Toggle("Auto-Cast", false, function(bool)
    if config.autoCastEnabled ~= bool then
        config.autoCastEnabled = bool
        OrionLib:MakeNotification({
            Name = "Auto-Cast",
            Content = "Auto-Cast is now " .. (bool and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end)

autos:Toggle("Auto-Reel (Blatant)", false, function(bool)
    if config.autoReelEnabled ~= bool then
        config.autoReelEnabled = bool
        OrionLib:MakeNotification({
            Name = "Auto-Reel (Blatant)",
            Content = "Auto-Reel (Blatant) is now " .. (bool and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end)

local selectedLocation = "Moosewood"

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

other:Button("Infinite Yield", function()
    local success, err = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source', true))()
    end)
    
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

other:Toggle("Anti-AFK", false, function(bool)
    config.antiAfkEnabled = bool
    OrionLib:MakeNotification({
        Name = "Anti-AFK",
        Content = "Anti-AFK is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Anti-AFK feature and main loop for Auto functionalities
run_service.RenderStepped:Connect(function()
    if config.antiAfkEnabled then
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end

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

-- Flying Variables
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 200 -- Flying speed
local bodyVelocity
local bodyGyro
local flyingAnimation
local animationTracks = {} -- Table to store active animations

-- Stop all default animations
local function stopAllAnimations()
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if not animationTracks[track.Animation.AnimationId] then
            track:Stop()
        end
    end
end

-- Function to play flying animation
local function playFlyAnimation()
    stopAllAnimations() -- Stop any conflicting animations first
    
    if not flyingAnimation then
        flyingAnimation = Instance.new("Animation")
        flyingAnimation.AnimationId = "rbxassetid://507777826" -- Replace with your flying animation ID
        local animator = humanoid:WaitForChild("Animator")
        flyingAnimation = animator:LoadAnimation(flyingAnimation)
        flyingAnimation.Priority = Enum.AnimationPriority.Action -- Force priority
    end

    if not flyingAnimation.IsPlaying then
        flyingAnimation:Play()
        animationTracks[flyingAnimation.AnimationId] = flyingAnimation
    end
end

-- Function to stop flying animation
local function stopFlyAnimation()
    if flyingAnimation and flyingAnimation.IsPlaying then
        flyingAnimation:Stop()
        animationTracks[flyingAnimation.AnimationId] = nil
    end
    stopAllAnimations() -- Restore default animations when stopping fly
end

-- Function to toggle flying
local function toggleFly(state)
    flying = state

    if flying then
        -- Enable flying
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.P = 1250
        bodyVelocity.Parent = rootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.P = 3000
        bodyGyro.Parent = rootPart

        playFlyAnimation()
    else
        -- Disable flying
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        stopFlyAnimation()
    end
end

-- Movement control
local userInput = game:GetService("UserInputService")
local function onMove(input, gameProcessed)
    if gameProcessed or not flying then return end

    -- Adjust velocity based on movement
    local moveDirection = Vector3.zero

    if userInput:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
    end
    if userInput:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
    end
    if userInput:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
    end
    if userInput:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
    end
    if userInput:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end

    if moveDirection.Magnitude > 0 then
        bodyVelocity.Velocity = moveDirection.Unit * speed
    else
        bodyVelocity.Velocity = Vector3.zero
    end
end

-- Update movement
userInput.InputChanged:Connect(onMove)

-- Add Toggle for Flying
flyChannel:Toggle("Fly", false, function(bool)
    toggleFly(bool)
    OrionLib:MakeNotification({
        Name = "Fly",
        Content = "Flying is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Function to freeze the player
local function freezePlayer(player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Parent = character.PrimaryPart
            
            return bodyVelocity
        end
    end
end

-- Function to unfreeze the player
local function unfreezePlayer(player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 -- Default WalkSpeed
            humanoid.JumpPower = 50 -- Default JumpPower
            
            if character.PrimaryPart:FindFirstChildOfClass("BodyVelocity") then
                character.PrimaryPart:FindFirstChildOfClass("BodyVelocity"):Destroy()
            end
        end
    end
end

-- Add new toggle button to the Character channel
flyChannel:Toggle("Freeze Character", false, function(bool)
    config.freezeCharacterEnabled = bool
    if bool then
        config.freezeBodyVelocity = freezePlayer(localplayer)
    else
        unfreezePlayer(localplayer)
        config.freezeBodyVelocity = nil
    end
    OrionLib:MakeNotification({
        Name = "Freeze Character",
        Content = "Freeze Character is now " .. (bool and "Enabled" or "Disabled"),
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)
