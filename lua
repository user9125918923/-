local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local maxDistance = 1000
_G.Settings = _G.Settings or { ShowNames = true, ShowDistance = true }
local toolNames = {
    RedOakStake = "RedOak",
    WhiteOakStake = "WhiteOak",
    QetsiyahCure = "QetCure",
    TheCure = "Cure",
    IndestructibleWhiteOakStake = "Indestructible"
}
local function createBox(color)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false
    box.Color = color
    return box
end
local function createText(size, color)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.Color = color
    text.Visible = false
    return text
end
local espElements = {}
local function isTeammate(player)
    return LocalPlayer.Team and player.Team == LocalPlayer.Team
end
local function getBackpackTools(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not backpack then return nil end
    local foundTools = {}
    local addedTools = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        local mappedName = toolNames[tool.Name]
        if mappedName and not addedTools[mappedName] then
            addedTools[mappedName] = true
            table.insert(foundTools, mappedName)
        end
    end
    return #foundTools > 0 and table.concat(foundTools, ", ") or nil
end
local function updateESP()
    local function convertStudsToMeters(studs)
        return studs * 0.28
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if rootPart and humanoid and humanoid.Health > 0 then
                local distance = convertStudsToMeters((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
                if distance < maxDistance then
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local size = Vector2.new(1000 / screenPosition.Z, 2000 / screenPosition.Z)
                        local position = Vector2.new(screenPosition.X - size.X / 2, screenPosition.Y - size.Y / 2)
                        if not espElements[player] then
                            espElements[player] = {
                                box = createBox(Color3.fromRGB(0, 0, 255)),
                                charName = createText(14, Color3.fromRGB(150, 150, 150)),
                                name = createText(14, Color3.fromRGB(255, 255, 255)),
                                distance = createText(12, Color3.fromRGB(255, 255, 255)),
                                tools = createText(12, Color3.fromRGB(150, 150, 150))
                            }
                        end
                        local elements = espElements[player]
                        elements.box.Size = size
                        elements.box.Position = position
                        elements.box.Visible = true
                        if _G.Settings.ShowNames then
                            local characterName = player:GetAttribute("CharacterName")
                            if characterName then
                                elements.charName.Text = characterName
                                elements.charName.Position = Vector2.new(screenPosition.X, position.Y - 34)
                                elements.charName.Visible = true
                            else
                                elements.charName.Visible = false
                            end
                            elements.name.Text = player.Name
                            elements.name.Position = Vector2.new(screenPosition.X, position.Y - 20)
                            elements.name.Visible = true
                            if _G.Settings.ShowDistance then
                                elements.distance.Text = string.format("%.1f meters", distance)
                                elements.distance.Position = Vector2.new(screenPosition.X, position.Y + size.Y + 2)
                                elements.distance.Visible = true
                            else
                                elements.distance.Visible = false
                            end
                            local toolsText = getBackpackTools(player)
                            if toolsText then
                                elements.tools.Text = toolsText
                                elements.tools.Position = Vector2.new(screenPosition.X, position.Y + size.Y + 16)
                                elements.tools.Visible = true
                            else
                                elements.tools.Visible = false
                            end
                        else
                            elements.charName.Visible = false
                            elements.name.Visible = false
                            elements.distance.Visible = false
                            elements.tools.Visible = false
                        end
                    elseif espElements[player] then
                        espElements[player].box.Visible = false
                        espElements[player].charName.Visible = false
                        espElements[player].name.Visible = false
                        espElements[player].distance.Visible = false
                        espElements[player].tools.Visible = false
                    end
                elseif espElements[player] then
                    espElements[player].box.Visible = false
                    espElements[player].charName.Visible = false
                    espElements[player].name.Visible = false
                    espElements[player].distance.Visible = false
                    espElements[player].tools.Visible = false
                end
            elseif espElements[player] then
                espElements[player].box.Visible = false
                espElements[player].charName.Visible = false
                espElements[player].name.Visible = false
                espElements[player].distance.Visible = false
                espElements[player].tools.Visible = false
            end
        elseif espElements[player] then
            espElements[player].box.Visible = false
            espElements[player].charName.Visible = false
            espElements[player].name.Visible = false
            espElements[player].distance.Visible = false
            espElements[player].tools.Visible = false
        end
    end
    local playerCloneFolder = game.Workspace:FindFirstChild("playerCloneFolder")
    if playerCloneFolder then
        for _, object in ipairs(playerCloneFolder:GetChildren()) do
            if object:IsA("Model") then
                for _, part in ipairs(object:GetChildren()) do
                    if part:IsA("BasePart") then
                        local distance = convertStudsToMeters((LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude)
                        if distance < maxDistance then
                            local screenPosition, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local size = Vector2.new(1000 / screenPosition.Z, 2000 / screenPosition.Z)
                                local position = Vector2.new(screenPosition.X - size.X / 2, screenPosition.Y - size.Y / 2)
                                if not espElements[object] then
                                    espElements[object] = {
                                        box = createBox(Color3.fromRGB(255, 0, 0)),
                                        name = createText(14, Color3.fromRGB(255, 255, 255)),
                                        distance = createText(12, Color3.fromRGB(255, 255, 255))
                                    }
                                    object.AncestryChanged:Connect(function(_, parent)
                                        if not parent then
                                            espElements[object].box:Remove()
                                            espElements[object].name:Remove()
                                            espElements[object].distance:Remove()
                                            espElements[object] = nil
                                        end
                                    end)
                                end
                                local elements = espElements[object]
                                elements.box.Size = size
                                elements.box.Position = position
                                elements.box.Visible = true
                                elements.name.Text = object.Name
                                elements.name.Position = Vector2.new(screenPosition.X, position.Y - 20)
                                elements.name.Visible = true
                                if _G.Settings.ShowDistance then
                                    elements.distance.Text = string.format("%.1f meters", distance)
                                    elements.distance.Position = Vector2.new(screenPosition.X, position.Y + size.Y + 2)
                                    elements.distance.Visible = true
                                else
                                    elements.distance.Visible = false
                                end
                            else
                                if espElements[object] then
                                    espElements[object].box.Visible = false
                                    espElements[object].name.Visible = false
                                    espElements[object].distance.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(updateESP)
Players.PlayerRemoving:Connect(function(player)
    if espElements[player] then
        espElements[player].box:Remove()
        espElements[player].charName:Remove()
        espElements[player].name:Remove()
        espElements[player].distance:Remove()
        espElements[player].tools:Remove()
        espElements[player] = nil
    end
end)
game.Workspace.playerCloneFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        for _, part in ipairs(child:GetChildren()) do
            if part:IsA("BasePart") then
                updateESP()
            end
        end
    end
end)

local player, camera = game.Players.LocalPlayer, workspace.CurrentCamera
local espObjects = {}

local function createESP(part)
    local mainPart = part:FindFirstChild("Main")
    if not mainPart then return end

    local label = Instance.new("TextLabel", Instance.new("BillboardGui", mainPart))
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency, label.TextColor3 = 1, Color3.fromRGB(169, 169, 169)
    label.TextScaled, label.TextStrokeTransparency, label.TextSize = true, 0.8, 10
    label.Text = "White Oak Stake"
    label.Parent.Size = UDim2.new(0, 100, 0, 25)
    label.Parent.Adornee, label.Parent.AlwaysOnTop, label.Parent.StudsOffset = mainPart, true, Vector3.new(0, 5, 0)

    table.insert(espObjects, {mainPart = mainPart, label = label, billboardGui = label.Parent})
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, part in ipairs(workspace:GetChildren()) do
        if part.Name == "IndestructibleWhiteOakStake" and part:FindFirstChild("Main") then
            local exists = false
            for _, esp in ipairs(espObjects) do
                if esp.mainPart == part.Main then
                    exists = true
                    break
                end
            end
            if not exists then createESP(part) end
        end
    end

    for _, esp in ipairs(espObjects) do
        local distance = (camera.CFrame.Position - esp.mainPart.Position).Magnitude
        esp.label.Text = "White Oak Stake\n" .. math.round(distance) .. " studs"
        esp.billboardGui.Enabled = camera:WorldToViewportPoint(esp.mainPart.Position).Z > 0
    end
end)

for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
    if v.ClassName == "ProximityPrompt" then v.HoldDuration = 0 end
end

local tomb = game.Workspace:WaitForChild("Interactables"):WaitForChild("SilasTomb")

while true do
    local tunnelDoor = tomb:FindFirstChild("TunnelDoor")
    if tunnelDoor then
        tunnelDoor:Destroy()
        break
    end
    task.wait(1)
end

local targetSize1 = Vector3.new(73.965, 1, 12.874)
local targetSize2 = Vector3.new(0.124, 6.944, 37.45)

local function isMatch1(size)
    return (size - targetSize1).Magnitude < 0.05
end

local function isMatch2(size)
    return math.abs(size.X - targetSize2.X) < 0.01 and math.abs(size.Y - targetSize2.Y) < 0.01 and math.abs(size.Z - targetSize2.Z) < 0.01
end

task.spawn(function()
    while true do
        local b = workspace:FindFirstChild("Buildings")
        local estate = b and b:FindFirstChild("MikaelsonEstate")
        if estate then
            local found = false
            for _, p in pairs(estate:GetDescendants()) do
                if p:IsA("BasePart") and isMatch1(p.Size) then
                    p:Destroy()
                    found = true
                end
            end
            if found then break end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local b = workspace:FindFirstChild("Buildings")
        local garage = b and b:FindFirstChild("Garage")
        if garage then
            local found = false
            for _, p in ipairs(garage:GetDescendants()) do
                if p:IsA("BasePart") and isMatch2(p.Size) then
                    p:Destroy()
                    found = true
                end
            end
            if found then break end
        end
        task.wait(1)
    end
end)

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("Remotes")
local gameServices = remotes:WaitForChild("GameServices")
local toClient = gameServices:WaitForChild("ToClient")

local function block(name, parent)
	local item = parent:FindFirstChild(name)
	if item then
		item:Destroy()
	end
	parent.ChildAdded:Connect(function(child)
		if child.Name == name then
			child:Destroy()
		end
	end)
end

block("StunPlayer", toClient)
block("EnhancedMovementService", remotes)

local player = game.Players.LocalPlayer
local screenUtils = player:WaitForChild("PlayerGui"):WaitForChild("ScreenUtils")
local children = screenUtils:GetChildren()
if #children >= 5 then
    children[3]:Destroy()
    children[4]:Destroy()
    children[5]:Destroy()
end
game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
game.Players.LocalPlayer.CameraMinZoomDistance = 0
if not game:IsLoaded() then game.Loaded:Wait() end
local PopperClient = game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("ZoomController"):WaitForChild("Popper")
for _, v in next, getgc() do
    if getfenv(v).script == PopperClient and typeof(v) == "function" then
        for i2, v2 in next, debug.getconstants(v) do
            if tonumber(v2) == 0.25 then debug.setconstant(v, i2, 0) end
            if tonumber(v2) == 0 then debug.setconstant(v, i2, 0.25) end
        end
    end
end
spawn(function()
    while true do
        wait(1)
        game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
        game.Players.LocalPlayer.CameraMinZoomDistance = 0
    end
end)

local function isSizeMatch(size)
    return math.abs(size.X - 0.124) < 0.01 and math.abs(size.Y - 6.944) < 0.01 and math.abs(size.Z - 37.45) < 0.01
end
