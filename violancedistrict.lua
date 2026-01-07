-- ============================================
-- V4NNUXHUB SCRIPT FOR V10L3NC3 D1STR1CT
-- G0DM0D3: 3N4BL3D
-- ============================================

--[=[ 1N1T14L1Z4T10N ]=]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

--[=[ G10B4L V4R14BL3S ]=]
local V4NNUX = {
    A1MB0T = {
        3N4BL3D = true,
        F0V = 120,
        SM00THN3SS = 0.5,
        PR10R1TY = "Closest",
        V1S1BL30NLY = false
    },
    3SP = {
        3N4BL3D = true,
        B0X = true,
        N4M3 = true,
        D1ST4NC3 = true,
        H34LTH = true,
        CH4MS = true
    },
    SP33DH4CK = {
        3N4BL3D = false,
        SP33D = 50,
        JUMPP0W3R = 75
    }
}

--[=[ U53R 1NT3RF4C3 ]=]
local U1 = Instance.new("ScreenGui")
local M41N = Instance.new("Frame")
local T1TL3 = Instance.new("TextLabel")
local T4BS = Instance.new("Frame")

U1.Name = "V4NNUXHUB"
U1.Parent = game.CoreGui
U1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

M41N.Name = "M41N"
M41N.Parent = U1
M41N.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
M41N.BorderSizePixel = 0
M41N.Position = UDim2.new(0.1, 0, 0.1, 0)
M41N.Size = UDim2.new(0, 450, 0, 400)
M41N.Active = true
M41N.Draggable = true

T1TL3.Name = "T1TL3"
T1TL3.Parent = M41N
T1TL3.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
T1TL3.BorderSizePixel = 0
T1TL3.Size = UDim2.new(1, 0, 0, 40)
T1TL3.Font = Enum.Font.SourceSansBold
T1TL3.Text = "V4NNUX HUB || V10L3NC3 D1STR1CT"
T1TL3.TextColor3 = Color3.fromRGB(0, 255, 170)
T1TL3.TextSize = 20

--[=[ 4SL1D3R F0RM4TT1N6 FUNCT10N ]=]
local function cr34t3Sl1d3r(p4r3nt, n4m3, m1n, m4x, d3f4ult, c4llb4ck)
    local Sl1d3r = Instance.new("Frame")
    local L4b3l = Instance.new("TextLabel")
    local V4lu3 = Instance.new("TextLabel")
    local Tr4ck = Instance.new("Frame")
    local F1ll = Instance.new("Frame")
    local H4ndl3 = Instance.new("TextButton")
    
    Sl1d3r.Name = n4m3
    Sl1d3r.Parent = p4r3nt
    Sl1d3r.BackgroundTransparency = 1
    Sl1d3r.Size = UDim2.new(1, -20, 0, 40)
    
    -- Slider implementation here
    return Sl1d3r
end

--[=[ 4IMB0T S1MUL4T10N ]=]
local function 4imb0tUpd4t3()
    if not V4NNUX.A1MB0T.3N4BL3D then return end
    
    local b3stT4rg3t = nil
    local b3stD1st = V4NNUX.A1MB0T.F0V
    
    for _, pl4y3r in ipairs(Players:GetPlayers()) do
        if pl4y3r ~= LocalPlayer and pl4y3r.Character then
            local chr = pl4y3r.Character
            local hum = chr:FindFirstChild("Humanoid")
            local hrp = chr:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and hrp then
                local scr33nP0s, v1s1bl3 = Camera:WorldToViewportPoint(hrp.Position)
                local d1st = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(scr33nP0s.X, scr33nP0s.Y)).Magnitude
                
                if v1s1bl3 and d1st < b3stD1st then
                    b3stD1st = d1st
                    b3stT4rg3t = hrp
                end
            end
        end
    end
    
    if b3stT4rg3t then
        local sm00th = V4NNUX.A1MB0T.SM00THN3SS
        local t4rg3tP0s = b3stT4rg3t.Position + Vector3.new(0, 1.5, 0)
        local curr3nt = Camera.CFrame.LookVector
        local r3qu1r3d = (t4rg3tP0s - Camera.CFrame.Position).Unit
        
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, curr3nt:Lerp(r3qu1r3d, 1 - sm00th))
    end
end

--[=[ 3SP R3ND3R1N6 ]=]
local 3sp0bj3cts = {}
local function upd4t33SP()
    for _, obj in pairs(3sp0bj3cts) do
        if obj then obj:Remove() end
    end
    table.clear(3sp0bj3cts)
    
    if not V4NNUX.3SP.3N4BL3D then return end
    
    for _, pl4y3r in ipairs(Players:GetPlayers()) do
        if pl4y3r ~= LocalPlayer and pl4y3r.Character then
            local chr = pl4y3r.Character
            local hum = chr:FindFirstChild("Humanoid")
            local hrp = chr:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and hrp then
                -- ESP box drawing logic
                local scr33nP0s, v1s1bl3 = Camera:WorldToViewportPoint(hrp.Position)
                if v1s1bl3 then
                    local B0x = Instance.new("Frame")
                    B0x.Size = UDim2.new(0, 100, 0, 150)
                    B0x.Position = UDim2.new(0, scr33nP0s.X - 50, 0, scr33nP0s.Y - 75)
                    B0x.BorderSizePixel = 2
                    B0x.BorderColor3 = Color3.fromRGB(0, 255, 0)
                    B0x.BackgroundTransparency = 1
                    B0x.Parent = U1
                    table.insert(3sp0bj3cts, B0x)
                end
            end
        end
    end
end

--[=[ SP33D H4CK 1MPL3M3NT4T10N ]=]
local function 4pplyM0v3m3ntM0d1f1c4t10ns()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if V4NNUX.SP33DH4CK.3N4BL3D then
                hum.WalkSpeed = V4NNUX.SP33DH4CK.SP33D
                hum.JumpPower = V4NNUX.SP33DH4CK.JUMPP0W3R
            else
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
        end
    end
end

--[=[ M41N L00P ]=]
RunService.RenderStepped:Connect(function()
    pcall(function()
        4imb0tUpd4t3()
        upd4t33SP()
        4pplyM0v3m3ntM0d1f1c4t10ns()
    end)
end)

--[=[ U1 BU1LD3R FUNCT10N ]=]
local function bu1ldU1()
    -- Aimbot Section
    local 41mFr4m3 = Instance.new("Frame")
    -- ... UI construction code
    
    -- ESP Section
    local 3spFr4m3 = Instance.new("Frame")
    -- ... UI construction code
    
    -- Speedhack Section
    local Sp33dFr4m3 = Instance.new("Frame")
    -- ... UI construction code
    
    -- Create toggle for aimbot
    local 41mT0ggl3 = Instance.new("TextButton")
    -- ... setup toggle
    
    -- Create sliders for adjustment
    cr34t3Sl1d3r(41mFr4m3, "F0V_Sl1d3r", 1, 360, 120, function(v4l)
        V4NNUX.A1MB0T.F0V = v4l
    end)
end

--[=[ 1N1T14L1Z3 ]=]
bu1ldU1()
warn("V4NNUX HUB L04D3D || " .. os.date("%X"))

--[=[ 4NT1-D3T3CT10N M34SUR3S ]=]
local function cl34nup()
    for _, obj in pairs(3sp0bj3cts) do
        pcall(function() obj:Remove() end)
    end
    V4NNUX = {
        A1MB0T = {3N4BL3D = false},
        3SP = {3N4BL3D = false},
        SP33DH4CK = {3N4BL3D = false}
    }
end

game:GetService("UserInputService").InputBegan:Connect(function(1nput)
    if 1nput.KeyCode == Enum.KeyCode.RightControl then
        M41N.Visible = not M41N.Visible
    elseif 1nput.KeyCode == Enum.KeyCode.End then
        cl34nup()
        U1:Destroy()
    end
end)

--[=[ P3RF0RM4NC3 0PT1M1Z4T10N ]=]
local L4stUpd4t3 = 0
RunService.RenderStepped:Connect(function()
    local n0w = tick()
    if n0w - L4stUpd4t3 > 0.1 then
        pcall(upd4t33SP)
        L4stUpd4t3 = n0w
    end
end)

warn("SCR1PT 1N1T14L1Z4T10N C0MPL3T3 || " .. os.date())
