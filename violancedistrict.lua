-- VANNUXHUB v2.0 - Violence District
-- Features: Aimbot, Adjustable Speedhack, ESP, Progress Indicator
-- Delta & Xeno compatible

local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")

-- Variables
local aimbot_enabled = false
local speedhack_enabled = false
local speed_multiplier = 3
local esp_enabled = true
local highlights = {}
local target = nil
local original_walkspeed = 16

-- Progress data
local progress = {
    kills = 0,
    deaths = 0,
    money = 0,
    level = 1,
    xp = 0
}

-- VANNUXHUB GUI
local screengui = Instance.new("ScreenGui")
screengui.Enabled = true
screengui.Parent = game.CoreGui

local mainframe = Instance.new("Frame")
mainframe.Size = UDim2.new(0, 380, 0, 450)
mainframe.Position = UDim2.new(0, 50, 0, 50)
mainframe.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainframe.BackgroundTransparency = 0.9
mainframe.OutlineColor3 = Color3.fromRGB(0, 150, 255)
mainframe.OutlineTransparency = 1
mainframe.Parent = screengui

-- Title
local titleframe = Instance.new("Frame")
titleframe.Size = UDim2.new(0, 380, 0, 40)
titleframe.Position = UDim2.new(0, 0, 0, 0)
titleframe.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
titleframe.Parent = mainframe

local titlelabel = Instance.new("TextLabel")
titlelabel.Text = "VANNUXHUB - Violence District"
titlelabel.Size = UDim2.new(0, 380, 0, 40)
titlelabel.Position = UDim2.new(0, 0, 0, 0)
titlelabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titlelabel.TextScaled = true
titlelabel.TextSize = 18
titlelabel.Font = Enum.Font.GothamBold
titlelabel.Parent = titleframe

-- Toggle buttons function
local function createToggle(name, description, ypos, enabled, callback)
    local toggleframe = Instance.new("Frame")
    toggleframe.Size = UDim2.new(0, 350, 0, 50)
    toggleframe.Position = UDim2.new(0, 15, 0, ypos)
    toggleframe.BackgroundTransparency = 0.7
    toggleframe.Parent = mainframe
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleframe
    
    local desclabel = Instance.new("TextLabel")
    desclabel.Text = description
    desclabel.Size = UDim2.new(0, 200, 0, 20)
    desclabel.Position = UDim2.new(0, 0, 0, 25)
    desclabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    desclabel.TextSize = 12
    desclabel.TextXAlignment = Enum.TextXAlignment.Left
    desclabel.Parent = toggleframe
    
    local togglebutton = Instance.new("TextButton")
    togglebutton.Text = enabled and "ON" or "OFF"
    togglebutton.Size = UDim2.new(0, 80, 0, 40)
    togglebutton.Position = UDim2.new(0, 250, 0, 5)
    togglebutton.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    togglebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
    togglebutton.Parent = toggleframe
    
    togglebutton.MouseButton1Click:Connect(function()
        enabled = not enabled
        togglebutton.Text = enabled and "ON" or "OFF"
        togglebutton.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        if callback then callback(enabled) end
        warn(name .. " " .. (enabled and "enabled" or "disabled"))
    end)
    
    return enabled, function(newstate)
        enabled = newstate
        togglebutton.Text = enabled and "ON" or "OFF"
        togglebutton.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    end
end

-- Speed slider function
local function createSpeedSlider(ypos, value, min, max, callback)
    local sliderframe = Instance.new("Frame")
    sliderframe.Size = UDim2.new(0, 350, 0, 60)
    sliderframe.Position = UDim2.new(0, 15, 0, ypos)
    sliderframe.BackgroundTransparency = 0.7
    sliderframe.Parent = mainframe
    
    local label = Instance.new("TextLabel")
    label.Text = "Speed Multiplier"
    label.Size = UDim2.new(0, 150, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderframe
    
    local valuelabel = Instance.new("TextLabel")
    valuelabel.Text = "x" .. value
    valuelabel.Size = UDim2.new(0, 50, 0, 25)
    valuelabel.Position = UDim2.new(0, 280, 0, 0)
    valuelabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    valuelabel.TextXAlignment = Enum.TextXAlignment.Center
    valuelabel.Parent = sliderframe
    
    local slider = Instance.new("TextBox")
    slider.PlaceholderText = "enter speed (1-" .. max .. ")"
    slider.Text = tostring(value)
    slider.Size = UDim2.new(0, 200, 0, 30)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    slider.Parent = sliderframe
    
    local applybutton = Instance.new("TextButton")
    applybutton.Text = "apply"
    applybutton.Size = UDim2.new(0, 80, 0, 30)
    applybutton.Position = UDim2.new(0, 210, 0, 30)
    applybutton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    applybutton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applybutton.Parent = sliderframe
    
    slider.Focused:Connect(function()
        slider.Text = ""
    end)
    
    applybutton.MouseButton1Click:Connect(function()
        local num = tonumber(slider.Text) or value
        if num < min then num = min end
        if num > max then num = max end
        
        value = num
        valuelabel.Text = "x" .. value
        slider.Text = tostring(value)
        
        if callback then callback(value) end
        warn("Speed set to x" .. value)
    end)
    
    return value, function(newvalue)
        if newvalue < min then newvalue = min end
        if newvalue > max then newvalue = max end
        
        value = newvalue
        valuelabel.Text = "x" .. value
        slider.Text = tostring(value)
    end
end

-- Create toggles and sliders
local aimbotYpos = 60
aimbot_enabled, local setAimbot = createToggle("Aimbot", "Right click to lock onto nearest enemy", aimbotYpos, false, function(enabled)
    aimbot_enabled = enabled
    if not enabled then target = nil end
end)

local speedYpos = 120
speedhack_enabled, local setSpeed = createToggle("SpeedHack", "Increases movement speed", speedYpos, false, function(enabled)
    speedhack_enabled = enabled
    local me = players.LocalPlayer
    if me and me.Character then
        local humanoid = me.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = enabled and (original_walkspeed * speed_multiplier) or original_walkspeed
        end
    end
end)

local speedSliderYpos = 180
speed_multiplier, local setSpeedMult = createSpeedSlider(speedSliderYpos, 3, 1, 10, function(newvalue)
    speed_multiplier = newvalue
    if speedhack_enabled then
        local me = players.LocalPlayer
        if me and me.Character then
            local humanoid = me.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = original_walkspeed * speed_multiplier
            end
        end
    end
end)

local espYpos = 250
esp_enabled, local setESP = createToggle("ESP Players", "Highlights enemy players", espYpos, true, function(enabled)
    esp_enabled = enabled
    if not enabled then
        for player, highlight in pairs(highlights) do
            if highlight then highlight:Destroy() end
            highlights[player] = nil
        end
    end
end)

-- Progress display
local progressframe = Instance.new("Frame")
progressframe.Size = UDim2.new(0, 350, 0, 120)
progressframe.Position = UDim2.new(0, 15, 0, 320)
progressframe.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
progressframe.Parent = mainframe

local progresslabel = Instance.new("TextLabel")
progresslabel.Text = "Game Progress"
progresslabel.Size = UDim2.new(0, 330, 0, 25)
progresslabel.Position = UDim2.new(0, 10, 0, 5)
progresslabel.TextColor3 = Color3.fromRGB(0, 200, 255)
progresslabel.TextXAlignment = Enum.TextXAlignment.Center
progresslabel.Parent = progressframe

local progressinfo = Instance.new("TextLabel")
progressinfo.Text = ""
progressinfo.Size = UDim2.new(0, 330, 0, 90)
progressinfo.Position = UDim2.new(0, 10, 0, 30)
progressinfo.TextColor3 = Color3.fromRGB(200, 200, 100)
progressinfo.TextXAlignment = Enum.TextXAlignment.Left
progressinfo.TextWrapped = true
progressinfo.Parent = progressframe

-- Close button
local closebutton = Instance.new("TextButton")
closebutton.Text = "X"
closebutton.Size = UDim2.new(0, 30, 0, 30)
closebutton.Position = UDim2.new(0, 345, 0, 5)
closebutton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closebutton.Parent = mainframe

closebutton.MouseButton1Click:Connect(function()
    screengui:Destroy()
    warn("VANNUXHUB closed")
end)

-- Draggable GUI
local dragging
local dragInput
local dragStart
local startPos

mainframe.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragInput = input
        startPos = mainframe.Position
        dragStart = input.Position
        
        input.Changed:Connect(function()
            if dragging then
                local delta = input.Position - dragStart
                mainframe.Position = UDim2.new(
                    startPos.X.Scale + delta.X,
                    startPos.Y.Scale + delta.Y
                )
            end
        end)
    end
end)

mainframe.InputEnded:Connect(function(input)
    if input == dragInput then
        dragging = false
    end
end)

-- ESP function
function create_esp(player)
    if not esp_enabled or not player or player == players.LocalPlayer or highlights[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(255, 50, 50)
    highlight.OutlineColor = Color3.new(255, 255, 50)
    highlight.FillTransparency = 0.2
    highlight.OutlineTransparency = 0.8
    highlight.Parent = player.Character
    
    highlights[player] = highlight
end

-- Main game loop
local loop_connection
loop_connection = runservice.Heartbeat:Connect(function()
    local me = players.LocalPlayer
    if not me or not me.Character then return end
    
    -- Aimbot logic
    if aimbot_enabled then
        local closest = nil
        local closestDist = 9999
        
        for _, player in pairs(players:GetPlayers()) do
            if player ~= me and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local mehrp = me.Character.HumanoidRootPart
                
                if hrp and mehrp then
                    local dist = (hrp.Position - mehrp.Position).Magnitude
                    if dist < closestDist and dist < 100 then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
        
        if closest and closest.Character then
            target = closest
            local hrp = closest.Character.HumanoidRootPart
            if hrp then
                workspace.CurrentCamera.CFrame = CFrame.new(
                    workspace.CurrentCamera.CFrame.p,
                    hrp.Position + Vector3.new(0, 2, 0)
                )
            end
        end
    end
    
    -- SpeedHack
    if speedhack_enabled then
        local humanoid = me.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = original_walkspeed * speed_multiplier
        end
    end
    
    -- Update ESP
    if esp_enabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= me and player.Character then
                create_esp(player)
            elseif highlights[player] and (player == me or not player.Character) then
                highlights[player]:Destroy()
                highlights[player] = nil
            end
        end
    end
    
    -- Update progress display
    progressinfo.Text = "Kills: " .. progress.kills .. "\n"
    progressinfo.Text = progressinfo.Text .. "Deaths: " .. progress.deaths .. "\n"
    progressinfo.Text = progressinfo.Text .. "Money: $" .. progress.money .. "\n"
    progressinfo.Text = progressinfo.Text .. "Level: " .. progress.level .. "\n"
    progressinfo.Text = progressinfo.Text .. "XP: " .. progress.xp .. "/100\n"
    progressinfo.Text = progressinfo.Text .. "Players: " .. (#players:GetPlayers() - 1) .. "\n"
    progressinfo.Text = progressinfo.Text .. "Speed: x" .. speed_multiplier .. " (" .. (speedhack_enabled and "ON" or "OFF") .. ")"
    
    -- Simulate progress (real game integration can be added here)
    if math.random() < 0.05 then
        progress.kills = progress.kills + 1
        progress.money = progress.money + math.random(25, 150)
        progress.xp = progress.xp + math.random(5, 20)
        
        if progress.xp >= 100 then
            progress.level = progress.level + 1
            progress.xp = 0
            warn("Level up! New level: " .. progress.level)
        end
    end
end)

-- Cleanup on player leave
players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)

-- Keybinds
uis.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        aimbot_enabled = not aimbot_enabled
        setAimbot(aimbot_enabled)
        warn("Aimbot: " .. (aimbot_enabled and "enabled" or "disabled"))
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        speedhack_enabled = not speedhack_enabled
        setSpeed(speedhack_enabled)
        warn("SpeedHack: " .. (speedhack_enabled and "enabled" or "disabled"))
    elseif input.KeyCode == Enum.KeyCode.Delete then
        esp_enabled = not esp_enabled
        setESP(esp_enabled)
        warn("ESP: " .. (esp_enabled and "enabled" or "disabled"))
    elseif input.KeyCode == Enum.KeyCode.Insert then
        screengui.Enabled = not screengui.Enabled
        warn("VANNUXHUB: " .. (screengui.Enabled and "visible" or "hidden"))
    elseif input.KeyCode == Enum.KeyCode.Up then
        if speedhack_enabled then
            speed_multiplier = speed_multiplier + 1
            if speed_multiplier > 10 then speed_multiplier = 10 end
            setSpeedMult(speed_multiplier)
        end
    elseif input.KeyCode == Enum.KeyCode.Down then
        if speedhack_enabled then
            speed_multiplier = speed_multiplier - 1
            if speed_multiplier < 1 then speed_multiplier = 1 end
            setSpeedMult(speed_multiplier)
        end
    end
end)

warn("VANNUXHUB v2.0 Loaded!")
warn("Toggle GUI: Insert")
warn("Aimbot: RCTRL | Speed: LCTRL | ESP: Delete")
warn("Speed adjust: Up/Down arrows (when enabled)")
warn("Drag title to move GUI")
warn("Speed range: 1-10x (default: 3x)")
