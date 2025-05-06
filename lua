local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local function createESP(part, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = part
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = text
    label.Parent = billboard
    billboard.Parent = part
end

local function updateToolESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player ~= Players.LocalPlayer then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart and not humanoidRootPart:FindFirstChild("ESP") then
                local toolName = ""
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        toolName = item.Name
                        break
                    end
                end
                createESP(humanoidRootPart, player.Name .. " | " .. toolName)
            end
        end
    end
end

local function updateStakeESP()
    local stake = workspace:FindFirstChild("IndestructibleWhiteOakStake")
    if stake and not stake:FindFirstChild("ESP") then
        local distance = (stake.Position - Camera.CFrame.Position).Magnitude
        createESP(stake, "IndestructibleWhiteOakStake | " .. math.floor(distance) .. "m")
    end
end

task.spawn(function()
    while true do
        pcall(updateToolESP)
        pcall(updateStakeESP)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            humanoid.AutoJumpEnabled = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    local maxZoom = math.huge
    local minZoom = 0
    Players.LocalPlayer.CameraMaxZoomDistance = maxZoom
    Players.LocalPlayer.CameraMinZoomDistance = minZoom
    Players.LocalPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
        Players.LocalPlayer.CameraMaxZoomDistance = maxZoom
    end)
    Players.LocalPlayer:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
        Players.LocalPlayer.CameraMinZoomDistance = minZoom
    end)
end)

task.spawn(function()
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 100, 0, 30)
    Button.Position = UDim2.new(1, -110, 0, 10)
    Button.AnchorPoint = Vector2.new(0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Button.Text = "Noclip: OFF"
    Button.Parent = ScreenGui

    local noclip = false

    Button.MouseButton1Click:Connect(function()
        noclip = not noclip
        Button.Text = "Noclip: " .. (noclip and "ON" or "OFF")
        Button.BackgroundColor3 = noclip and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    RunService.Stepped:Connect(function()
        if Players.LocalPlayer.Character then
            for _, v in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = not noclip
                end
            end
        end
    end)
end)

task.spawn(function()
    local StarterGui = game:GetService("StarterGui")
    local StarterPlayer = game:GetService("StarterPlayer")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")

    if StarterGui:FindFirstChild("ChooseCharacter") then
        StarterGui.ChooseCharacter.Enabled = true
    end

    if StarterPlayer:FindFirstChild("CharacterScripts") then
        for _, v in pairs(StarterPlayer.CharacterScripts:GetChildren()) do
            v:Destroy()
        end
    end

    if ReplicatedFirst:FindFirstChild("ChooseCharacter") then
        ReplicatedFirst.ChooseCharacter.Enabled = true
    end
end)

task.spawn(function()
    local tomb = game.Workspace:WaitForChild("Interactables"):WaitForChild("SilasTomb")
    while true do
        local tunnelDoor = tomb:FindFirstChild("TunnelDoor")
        if tunnelDoor then
            tunnelDoor:Destroy()
            break
        end
        task.wait(1)
    end
end)
