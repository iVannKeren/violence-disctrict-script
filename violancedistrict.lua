-- ====== VannuxHUB - 终极PvP辅助脚本 ======
-- 包含：无敌模式、范围秒杀、静默自瞄、玩家透视
-- 重要声明：仅供学习研究使用

-- ====== 核心服务 ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====== 功能模块开关 ======
local Features = {
    GodMode = false,
    KillAura = false,
    SilentAim = false,
    Esp = false,
    SpeedHack = false
}

-- ====== 1. 无敌模式 ======
local function ToggleGodMode(state)
    Features.GodMode = state
    if state then
        spawn(function()
            while Features.GodMode do
                local character = localPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.MaxHealth = math.huge
                        humanoid.Health = math.huge
                        
                        -- 防止伤害
                        for _, connection in pairs(getconnections(humanoid.Touched)) do
                            connection:Disable()
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
        print("无敌模式: 已启用")
    else
        print("无敌模式: 已禁用")
    end
end

-- ====== 2. 范围秒杀 ======
local KILL_AURA_RANGE = 20
local KILL_AURA_COOLDOWN = 0.3
local lastKillTime = 0

local function ToggleKillAura(state)
    Features.KillAura = state
    if state then
        spawn(function()
            while Features.KillAura do
                task.wait(0.1)
                
                local myChar = localPlayer.Character
                if not myChar then continue end
                
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then continue end
                
                if tick() - lastKillTime < KILL_AURA_COOLDOWN then continue end
                
                local myPos = myRoot.Position
                local killedSomeone = false
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == localPlayer then continue end
                    
                    local targetChar = player.Character
                    if not targetChar then continue end
                    
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local distance = (myPos - targetRoot.Position).Magnitude
                        
                        if distance <= KILL_AURA_RANGE then
                            -- 多种击杀方法确保可靠性
                            targetHumanoid.Health = 0
                            
                            pcall(function()
                                local damage = Instance.new("IntValue")
                                damage.Name = "Damage"
                                damage.Value = 99999
                                damage.Parent = targetHumanoid
                                game:GetService("Debris"):AddItem(damage, 0.1)
                            end)
                            
                            killedSomeone = true
                            lastKillTime = tick()
                            break -- 每次循环只杀一个，避免检测
                        end
                    end
                end
                
                if killedSomeone then
                    task.wait(KILL_AURA_COOLDOWN)
                end
            end
        end)
        print("范围秒杀: 已启用 (范围: " .. KILL_AURA_RANGE .. ")")
    else
        print("范围秒杀: 已禁用")
    end
end

-- ====== 3. 静默自瞄 ======
local SilentAimSettings = {
    Enabled = false,
    FOV = 50,
    TargetPart = "Head",
    Smoothness = 0.2,
    VisibleCheck = true,
    TeamCheck = true
}

local function GetBestTarget()
    if not SilentAimSettings.Enabled then return nil end
    
    local bestTarget = nil
    local smallestAngle = SilentAimSettings.FOV
    local myTeam = localPlayer.Team
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local cameraDirection = Camera.CFrame.LookVector
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        if SilentAimSettings.TeamCheck and player.Team == myTeam then continue end
        
        local targetChar = player.Character
        if targetChar and targetChar:FindFirstChild("Humanoid") then
            local humanoid = targetChar.Humanoid
            if humanoid.Health <= 0 then continue end
            
            local targetPart = targetChar:FindFirstChild(SilentAimSettings.TargetPart)
            if not targetPart then 
                targetPart = targetChar:FindFirstChild("HumanoidRootPart") 
            end
            if not targetPart then continue end
            
            -- 可见性检查
            if SilentAimSettings.VisibleCheck then
                local origin = Camera.CFrame.Position
                local direction = (targetPart.Position - origin).Unit * 1000
                local ray = Ray.new(origin, direction)
                local hit, pos = Workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, targetChar})
                if hit and not hit:IsDescendantOf(targetChar) then continue end
            end
            
            -- 计算角度
            local myPos = myRoot.Position
            local directionToTarget = (targetPart.Position - myPos).Unit
            local angle = math.deg(math.acos(cameraDirection:Dot(directionToTarget)))
            
            if angle < smallestAngle then
                smallestAngle = angle
                bestTarget = {
                    Player = player,
                    Character = targetChar,
                    Part = targetPart,
                    Distance = (targetPart.Position - myPos).Magnitude,
                    Angle = angle
                }
            end
        end
    end
    
    return bestTarget
end

local originalNamecall
local function HookShootingFunctions()
    local mt = getrawmetatable(game)
    if not mt or originalNamecall then return end
    
    originalNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        local isShootingMethod = method == "FireServer" or method == "InvokeServer"
        local isShootingName = self.Name:lower():find("shoot") 
            or self.Name:lower():find("fire") 
            or self.Name:lower():find("hit") 
            or self.Name:lower():find("damage")
        
        if Features.SilentAim and isShootingMethod and isShootingName then
            local target = GetBestTarget()
            if target then
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        -- 修改射击位置
                        args[i] = target.Part.Position
                    elseif typeof(arg) == "Ray" then
                        -- 修改射线方向
                        local origin = arg.Origin
                        local direction = (target.Part.Position - origin).Unit
                        args[i] = Ray.new(origin, direction * 1000)
                    end
                end
            end
        end
        
        return originalNamecall(self, unpack(args))
    end)
end

local function ToggleSilentAim(state)
    Features.SilentAim = state
    SilentAimSettings.Enabled = state
    
    if state then
        HookShootingFunctions()
        
        -- 创建FOV可视化圆
        if Drawing then
            local circle = Drawing.new("Circle")
            circle.Visible = true
            circle.Radius = SilentAimSettings.FOV * 2
            circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            circle.Color = Color3.fromRGB(255, 50, 50)
            circle.Thickness = 2
            circle.Filled = false
            
            RunService.RenderStepped:Connect(function()
                if not SilentAimSettings.Enabled then 
                    circle.Visible = false
                    circle:Remove()
                    return 
                end
                
                local target = GetBestTarget()
                circle.Color = target and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
            end)
        end
        
        print("静默自瞄: 已启用 | FOV: " .. SilentAimSettings.FOV .. "° | 部位: " .. SilentAimSettings.TargetPart)
    else
        print("静默自瞄: 已禁用")
    end
end

-- ====== 4. 玩家透视 (ESP) ======
local EspSettings = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Distances = true,
    Health = true,
    TeamColor = true,
    MaxDistance = 500,
    UpdateInterval = 0.1
}

local EspObjects = {}
local TeamColors = {
    Default = Color3.fromRGB(255, 50, 50),
    Friendly = Color3.fromRGB(50, 255, 50),
    Neutral = Color3.fromRGB(255, 255, 50)
}

local function CreateEsp(player)
    if not player or player == localPlayer then return end
    
    local espData = {}
    
    if Drawing then
        -- 使用Drawing库（更高效）
        espData.Box = Drawing.new("Square")
        espData.Box.Visible = false
        espData.Box.Thickness = 2
        espData.Box.Filled = false
        
        espData.Name = Drawing.new("Text")
        espData.Name.Visible = false
        espData.Name.Size = 16
        espData.Name.Center = true
        espData.Name.Outline = true
        
        espData.Distance = Drawing.new("Text")
        espData.Distance.Visible = false
        espData.Distance.Size = 14
        espData.Distance.Center = true
        
        espData.HealthBar = Drawing.new("Square")
        espData.HealthBar.Visible = false
        espData.HealthBar.Filled = true
        
        espData.HealthText = Drawing.new("Text")
        espData.HealthText.Visible = false
        espData.HealthText.Size = 12
        espData.HealthText.Center = true
        
    else
        -- 备用方案：BillboardGui
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local espGui = Instance.new("BillboardGui")
        espGui.Name = "ESP_" .. player.Name
        espGui.Size = UDim2.new(5, 0, 8, 0)
        espGui.StudsOffset = Vector3.new(0, 3, 0)
        espGui.AlwaysOnTop = true
        espGui.MaxDistance = EspSettings.MaxDistance
        espGui.Parent = humanoidRootPart
        
        local box = Instance.new("Frame")
        box.Name = "Box"
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 2
        box.Parent = espGui
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, -0.25, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = espGui
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 16)
        distanceLabel.Position = UDim2.new(0, 0, 1, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 12
        distanceLabel.Parent = espGui
        
        local healthContainer = Instance.new("Frame")
        healthContainer.Name = "HealthContainer"
        healthContainer.Size = UDim2.new(0.8, 0, 0, 4)
        healthContainer.Position = UDim2.new(0.1, 0, 1.1, 0)
        healthContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        healthContainer.BorderSizePixel = 1
        healthContainer.Parent = espGui
        
        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        healthBar.Parent = healthContainer
        
        espData.Gui = espGui
        espData.Box = box
        espData.NameLabel = nameLabel
        espData.DistanceLabel = distanceLabel
        espData.HealthBar = healthBar
    end
    
    EspObjects[player] = espData
    return espData
end

local function GetPlayerColor(player)
    if not EspSettings.TeamColor then return TeamColors.Default end
    
    local myTeam = localPlayer.Team
    local playerTeam = player.Team
    
    if not myTeam or not playerTeam then return TeamColors.Default end
    
    if myTeam == playerTeam then
        return TeamColors.Friendly
    elseif playerTeam.Name == "Neutral" then
        return TeamColors.Neutral
    else
        return TeamColors.Default
    end
end

local function UpdateEsp()
    if not EspSettings.Enabled then return end
    
    local myCharacter = localPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        
        local espData = EspObjects[player]
        if not espData then
            espData = CreateEsp(player)
            if not espData then continue end
        end
        
        local character = player.Character
        if not character then
            if Drawing then
                if espData.Box then espData.Box.Visible = false end
                if espData.Name then espData.Name.Visible = false end
                if espData.Distance then espData.Distance.Visible = false end
                if espData.HealthBar then espData.HealthBar.Visible = false end
                if espData.HealthText then espData.HealthText.Visible = false end
            elseif espData.Gui then
                espData.Gui.Enabled = false
            end
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
            if Drawing then
                if espData.Box then espData.Box.Visible = false end
                if espData.Name then espData.Name.Visible = false end
                if espData.Distance then espData.Distance.Visible = false end
                if espData.HealthBar then espData.HealthBar.Visible = false end
                if espData.HealthText then espData.HealthText.Visible = false end
            elseif espData.Gui then
                espData.Gui.Enabled = false
            end
            continue
        end
        
        local distance = (myRoot.Position - humanoidRootPart.Position).Magnitude
        if distance > EspSettings.MaxDistance then
            if Drawing then
                if espData.Box then espData.Box.Visible = false end
                if espData.Name then espData.Name.Visible = false end
                if espData.Distance then espData.Distance.Visible = false end
                if espData.HealthBar then espData.HealthBar.Visible = false end
                if espData.HealthText then espData.HealthText.Visible = false end
            elseif espData.Gui then
                espData.Gui.Enabled = false
            end
            continue
        end
        
        local playerColor = GetPlayerColor(player)
        local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen then
            if Drawing and espData.Box then
                local boxSize = Vector2.new(50, 100) * (100 / distance)
                local boxPosition = Vector2.new(screenPosition.X, screenPosition.Y)
                
                -- 方框
                if EspSettings.Boxes then
                    espData.Box.Visible = true
                    espData.Box.Size = boxSize
                    espData.Box.Position = boxPosition - boxSize / 2
                    espData.Box.Color = playerColor
                else
                    espData.Box.Visible = false
                end
                
                -- 名称
                if EspSettings.Names then
                    espData.Name.Visible = true
                    espData.Name.Text = player.Name
                    espData.Name.Position = Vector2.new(boxPosition.X, boxPosition.Y - boxSize.Y/2 - 20)
                    espData.Name.Color = playerColor
                else
                    espData.Name.Visible = false
                end
                
                -- 距离
                if EspSettings.Distances then
                    espData.Distance.Visible = true
                    espData.Distance.Text = string.format("%.0fm", distance)
                    espData.Distance.Position = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y/2 + 10)
                    espData.Distance.Color = Color3.new(1, 1, 1)
                else
                    espData.Distance.Visible = false
                end
                
                -- 血量
                if EspSettings.Health then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    
                    espData.HealthBar.Visible = true
                    espData.HealthBar.Size = Vector2.new(boxSize.X * healthPercent, 4)
                    espData.HealthBar.Position = Vector2.new(
                        boxPosition.X - boxSize.X/2,
                        boxPosition.Y + boxSize.Y/2 + 20
                    )
                    
                    if healthPercent > 0.6 then
                        espData.HealthBar.Color = Color3.fromRGB(50, 255, 50)
                    elseif healthPercent > 0.3 then
                        espData.HealthBar.Color = Color3.fromRGB(255, 255, 50)
                    else
                        espData.HealthBar.Color = Color3.fromRGB(255, 50, 50)
                    end
                    
                    if espData.HealthText then
                        espData.HealthText.Visible = true
                        espData.HealthText.Text = string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                        espData.HealthText.Position = Vector2.new(
                            boxPosition.X,
                            boxPosition.Y + boxSize.Y/2 + 35
                        )
                        espData.HealthText.Color = Color3.new(1, 1, 1)
                    end
                else
                    if espData.HealthBar then espData.HealthBar.Visible = false end
                    if espData.HealthText then espData.HealthText.Visible = false end
                end
                
            elseif espData.Gui then
                espData.Gui.Enabled = true
                
                if espData.Box then
                    espData.Box.BorderColor3 = playerColor
                    espData.Box.Visible = EspSettings.Boxes
                end
                
                if espData.NameLabel then
                    espData.NameLabel.Text = player.Name
                    espData.NameLabel.TextColor3 = playerColor
                    espData.NameLabel.Visible = EspSettings.Names
                end
                
                if espData.DistanceLabel then
                    espData.DistanceLabel.Text = string.format("%.0f studs", distance)
                    espData.DistanceLabel.Visible = EspSettings.Distances
                end
                
                if humanoid and espData.HealthBar then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    espData.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                    
                    if healthPercent > 0.6 then
                        espData.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                    elseif healthPercent > 0.3 then
                        espData.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
                    else
                        espData.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end
            end
        else
            if Drawing then
                if espData.Box then espData.Box.Visible = false end
                if espData.Name then espData.Name.Visible = false end
                if espData.Distance then espData.Distance.Visible = false end
                if espData.HealthBar then espData.HealthBar.Visible = false end
                if espData.HealthText then espData.HealthText.Visible = false end
            elseif espData.Gui then
                espData.Gui.Enabled = false
            end
        end
    end
end

local function ToggleEsp(state)
    Features.Esp = state
    EspSettings.Enabled = state
    
    if state then
        print("玩家透视: 已启用 | 最大距离: " .. EspSettings.MaxDistance)
        
        -- 为现有玩家创建ESP
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                CreateEsp(player)
            end
        end
        
        -- 监听新玩家
        Players.PlayerAdded:Connect(function(player)
            task.wait(1)
            CreateEsp(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            local espData = EspObjects[player]
            if espData then
                if Drawing then
                    if espData.Box then espData.Box:Remove() end
                    if espData.Name then espData.Name:Remove() end
                    if espData.Distance then espData.Distance:Remove() end
                    if espData.HealthBar then espData.HealthBar:Remove() end
                    if espData.HealthText then espData.HealthText:Remove() end
                elseif espData.Gui then
                    espData.Gui:Destroy()
                end
                EspObjects[player] = nil
            end
        end)
        
        -- 启动ESP更新循环
        spawn(function()
            while EspSettings.Enabled do
                UpdateEsp()
                task.wait(EspSettings.UpdateInterval)
            end
        end)
    else
        print("玩家透视: 已禁用")
        
        -- 清理所有ESP对象
        for player, espData in pairs(EspObjects) do
            if Drawing then
                if espData.Box then espData.Box:Remove() end
                if espData.Name then espData.Name:Remove() end
                if espData.Distance then espData.Distance:Remove() end
                if espData.HealthBar then espData.HealthBar:Remove() end
                if espData.HealthText then espData.HealthText:Remove() end
            elseif espData.Gui then
                espData.Gui:Destroy()
            end
        end
        EspObjects = {}
    end
end

-- ====== 创建VannuxHUB界面 ======
local function CreateVannuxHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VannuxHUB"
    screenGui.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Text = "VANNUX HUB v3.0"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 100, 150)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "×"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.TextColor3 = Color3.white
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        ToggleGodMode(false)
        ToggleKillAura(false)
        ToggleSilentAim(false)
        ToggleEsp(false)
    end)
    
    -- 功能按钮容器
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 1, -60)
    buttonContainer.Position = UDim2.new(0, 10, 0, 50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Padding = UDim.new(0, 10)
    buttonLayout.Parent = buttonContainer
    
    -- 创建功能按钮函数
    local function CreateToggle(name, description, toggleFunction, color)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, 0, 0, 70)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        buttonFrame.BorderSizePixel = 0
        
        local button = Instance.new("TextButton")
        button.Text = name
        button.Size = UDim2.new(0.7, -5, 0.6, 0)
        button.Position = UDim2.new(0, 10, 0, 5)
        button.BackgroundColor3 = color or Color3.fromRGB(70, 70, 90)
        button.TextColor3 = Color3.white
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = buttonFrame
        
        local status = Instance.new("TextLabel")
        status.Text = "关"
        status.Size = UDim2.new(0.25, 0, 0.6, 0)
        status.Position = UDim2.new(0.75, 0, 0, 5)
        status.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        status.TextColor3 = Color3.white
        status.Font = Enum.Font.GothamBold
        status.TextSize = 14
        status.Parent = buttonFrame
        
        local desc = Instance.new("TextLabel")
        desc.Text = description
        desc.Size = UDim2.new(1, -20, 0, 20)
        desc.Position = UDim2.new(0, 10, 0.6, 0)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(180, 180, 180)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = buttonFrame
        
        local isEnabled = false
        button.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            if isEnabled then
                status.Text = "开"
                status.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            else
                status.Text = "关"
                status.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            end
            toggleFunction(isEnabled)
        end)
        
        buttonFrame.Parent = buttonContainer
        return buttonFrame
    end
    
    -- 创建所有功能按钮
    CreateToggle("无敌模式", "免疫所有伤害", ToggleGodMode, Color3.fromRGB(60, 120, 200))
    CreateToggle("范围秒杀", "自动击杀附近敌人", ToggleKillAura, Color3.fromRGB(200, 80, 60))
    CreateToggle("静默自瞄", "自动瞄准敌人 (FOV: " .. SilentAimSettings.FOV .. "°)", ToggleSilentAim, Color3.fromRGB(150, 60, 200))
    CreateToggle("玩家透视", "显示敌人方框、名称、距离、血量", ToggleEsp, Color3.fromRGB(80, 200, 120))
    
    mainFrame.Parent = screenGui
    return screenGui
end

-- ====== 主循环 ======
RunService.RenderStepped:Connect(function()
    if EspSettings.Enabled then
        UpdateEsp()
    end
end)

-- ====== 初始化 ======
if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end
task.wait(2)

local ui = CreateVannuxHub()

-- 快捷键
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.RightControl then
            ui.Enabled = not ui.Enabled
        elseif input.KeyCode == Enum.KeyCode.Insert then
            ui:Destroy()
            task.wait(0.1)
            ui = CreateVannuxHub()
        end
    end
end)

print("========================================")
print("VannuxHUB v3.0 已成功加载!")
print("功能: 无敌模式 | 范围秒杀 | 静默自瞄 | 玩家透视")
print("快捷键: RightCtrl=显示/隐藏界面 | Insert=重载脚本")
print("========================================")
