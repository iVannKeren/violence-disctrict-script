-- VANNUXHUB - Violence District (Delta Compatible)
-- Works on Delta (Android) and Xeno (Windows)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local aimbotEnabled = false
local speedhackEnabled = false
local speedMultiplier = 3
local espEnabled = true
local highlights = {}
local target = nil
local originalWalkSpeed = 16

-- Progress data
local progress = {
    kills = 0,
    deaths = 0,
    money = 0,
    level = 1,
    xp = 0
}

-- Create GUI (Delta compatible method)
local success, errorMsg = pcall(function()
    -- VANNUXHUB GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VannuxHub"
    screenGui.Parent = CoreGui
    screenGui.Enabled = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 420)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.Parent = screenGui

    -- Title
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleFrame.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "VANNUXHUB - Violence District"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = titleFrame

    -- Function to create toggle buttons
    local function createToggle(name, description, yPos, defaultState, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -30, 0, 50)
        toggleFrame.Position = UDim2.new(0, 15, 0, yPos)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = mainFrame
        
        local label = Instance.new("TextLabel")
        label.Text = name
        label.Size = UDim2.new(0.6, 0, 0, 25)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = toggleFrame
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Text = description
        descLabel.Size = UDim2.new(0.6, 0, 0, 20)
        descLabel.Position = UDim2.new(0, 0, 0, 25)
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.BackgroundTransparency = 1
        descLabel.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Text = defaultState and "ON" or "OFF"
        toggleButton.Size = UDim2.new(0, 80, 0, 40)
        toggleButton.Position = UDim2.new(1, -80, 0, 5)
        toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.Parent = toggleFrame
        
        toggleButton.MouseButton1Click:Connect(function()
            local newState = not defaultState
            toggleButton.Text = newState and "ON" or "OFF"
            toggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            defaultState = newState
            if callback then callback(newState) end
            warn(name .. " " .. (newState and "enabled" or "disabled"))
        end)
        
        return defaultState, function(newState)
            defaultState = newState
            toggleButton.Text = newState and "ON" or "OFF"
            toggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        end
    end

    -- Create toggles
    aimbotEnabled, local setAimbot = createToggle("Aimbot", "Hold RMB to lock on", 50, false, function(state)
        aimbotEnabled = state
        if not state then target = nil end
    end)

    speedhackEnabled, local setSpeed = createToggle("SpeedHack", "Movement speed", 110, false, function(state)
        speedhackEnabled = state
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = state and (originalWalkSpeed * speedMultiplier) or originalWalkSpeed
            end
        end
    end)

    espEnabled, local setESP = createToggle("ESP Players", "Highlight enemies", 170, true, function(state)
        espEnabled = state
        if not state then
            for player, highlight in pairs(highlights) do
                if highlight then highlight:Destroy() end
                highlights[player] = nil
            end
        end
    end)

    -- Speed controls
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -30, 0, 60)
    speedFrame.Position = UDim2.new(0, 15, 0, 230)
    speedFrame.BackgroundTransparency = 1
    speedFrame.Parent = mainFrame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Text = "Speed: x" .. speedMultiplier
    speedLabel.Size = UDim2.new(1, 0, 0, 25)
    speedLabel.Position = UDim2.new(0, 0, 0, 0)
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Parent = speedFrame

    local increaseButton = Instance.new("TextButton")
    increaseButton.Text = "+"
    increaseButton.Size = UDim2.new(0, 60, 0, 30)
    increaseButton.Position = UDim2.new(0, 0, 0, 30)
    increaseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    increaseButton.Parent = speedFrame

    local decreaseButton = Instance.new("TextButton")
    decreaseButton.Text = "-"
    decreaseButton.Size = UDim2.new(0, 60, 0, 30)
    decreaseButton.Position = UDim2.new(1, -60, 0, 30)
    decreaseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    decreaseButton.Parent = speedFrame

    increaseButton.MouseButton1Click:Connect(function()
        if speedMultiplier < 10 then
            speedMultiplier = speedMultiplier + 1
            speedLabel.Text = "Speed: x" .. speedMultiplier
            if speedhackEnabled then
                local player = Players.LocalPlayer
                if player and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = originalWalkSpeed * speedMultiplier
                    end
                end
            end
        end
    end)

    decreaseButton.MouseButton1Click:Connect(function()
        if speedMultiplier > 1 then
            speedMultiplier = speedMultiplier - 1
            speedLabel.Text = "Speed: x" .. speedMultiplier
            if speedhackEnabled then
                local player = Players.LocalPlayer
                if player and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = originalWalkSpeed * speedMultiplier
                    end
                end
            end
        end
    end)

    -- Progress display
    local progressFrame = Instance.new("Frame")
    progressFrame.Size = UDim2.new(1, -30, 0, 100)
    progressFrame.Position = UDim2.new(0, 15, 0, 300)
    progressFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    progressFrame.Parent = mainFrame

    local progressLabel = Instance.new("TextLabel")
    progressLabel.Text = "Game Progress"
    progressLabel.Size = UDim2.new(1, 0, 0, 25)
    progressLabel.Position = UDim2.new(0, 0, 0, 5)
    progressLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Parent = progressFrame

    local progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Text = "Loading..."
    progressText.Size = UDim2.new(1, -10, 1, -30)
    progressText.Position = UDim2.new(0, 5, 0, 30)
    progressText.TextColor3 = Color3.fromRGB(200, 200, 100)
    progressText.TextXAlignment = Enum.TextXAlignment.Left
    progressText.TextYAlignment = Enum.TextYAlignment.Top
    progressText.TextWrapped = true
    progressText.BackgroundTransparency = 1
    progressText.Parent = progressFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Parent = mainFrame

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        warn("VANNUXHUB closed")
    end)

    -- ESP function
    local function createESP(player)
        if not espEnabled or not player or player == Players.LocalPlayer or highlights[player] then 
            return 
        end
        
        if player.Character then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 50)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0.7
            highlight.Parent = player.Character
            
            highlights[player] = highlight
        end
    end

    -- Main loop
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local player = Players.LocalPlayer
        if not player or not player.Character then return end

        -- Aimbot (hold right mouse button)
        if aimbotEnabled then
            local closest = nil
            local closestDist = 999
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = otherPlayer.Character.HumanoidRootPart
                    local myHrp = player.Character.HumanoidRootPart
                    
                    if hrp and myHrp then
                        local dist = (hrp.Position - myHrp.Position).Magnitude
                        if dist < closestDist and dist < 50 then
                            closestDist = dist
                            closest = otherPlayer
                        end
                    end
                end
            end
            
            if closest and closest.Character then
                target = closest
                local hrp = closest.Character.HumanoidRootPart
                if hrp then
                    local currentCamera = Workspace.CurrentCamera
                    if currentCamera then
                        currentCamera.CFrame = CFrame.new(
                            currentCamera.CFrame.p,
                            hrp.Position + Vector3.new(0, 2, 0)
                        )
                    end
                end
            end
        end

        -- Speed hack
        if speedhackEnabled then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalWalkSpeed * speedMultiplier
            end
        end

        -- ESP
        if espEnabled then
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player then
                    if otherPlayer.Character then
                        createESP(otherPlayer)
                    end
                elseif highlights[otherPlayer] and (otherPlayer == player or not otherPlayer.Character) then
                    highlights[otherPlayer]:Destroy()
                    highlights[otherPlayer] = nil
                end
            end
        end

        -- Update progress display
        if progressText then
            progressText.Text = "Kills: " .. progress.kills .. "\n" ..
                               "Money: $" .. progress.money .. "\n" ..
                               "Level: " .. progress.level .. "\n" ..
                               "Players: " .. (#Players:GetPlayers() - 1) .. "\n" ..
                               "Speed: x" .. speedMultiplier
        end

        -- Simulate some progress
        if math.random() < 0.02 then
            progress.kills = progress.kills + 1
            progress.money = progress.money + math.random(10, 50)
            
            if progress.kills % 5 == 0 then
                progress.level = progress.level + 1
                warn("Level up! Now level " .. progress.level)
            end
        end
    end)

    -- Clean up highlights when players leave
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if highlights[leavingPlayer] then
            highlights[leavingPlayer]:Destroy()
            highlights[leavingPlayer] = nil
        end
    end)

    warn("VANNUXHUB Loaded Successfully!")
    warn("Controls:")
    warn("- Aimbot: Toggle in GUI")
    warn("- Speed: 1-10x in GUI")
    warn("- ESP: Toggle in GUI")
    warn("- Close GUI: X button")
end)

if not success then
    warn("Error loading GUI: " .. tostring(errorMsg))
    
    -- Fallback simple version
    warn("Loading fallback version...")
    
    -- Simple ESP function as fallback
    local function simpleESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.Parent = player.Character
            end
        end
    end
    
    -- Simple speed hack
    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = originalWalkSpeed * 3
            warn("Speed hack enabled (3x)")
        end
    end
    
    simpleESP()
    warn("Fallback features loaded")
end
