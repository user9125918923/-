local ps = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = ps.LocalPlayer
local cam = workspace.CurrentCamera

local maxDist = 1000
local esp = {}

local tn = {
    RedOakStake = "RedOak",
    WhiteOakStake = "WhiteOak",
    QetsiyahCure = "QetCure",
    TheCure = "Cure",
    IndestructibleWhiteOakStake = "Indestructible"
}

local function newText(sz, col)
    local t = Drawing.new("Text")
    t.Size = sz
    t.Center = true
    t.Outline = true
    t.Color = col
    t.Visible = false
    return t
end

local function newBox(col)
    local b = Drawing.new("Square")
    b.Thickness = 1
    b.Transparency = 1
    b.Filled = false
    b.Color = col
    return b
end

local function getTools(p)
    local bp = p:FindFirstChildOfClass("Backpack")
    if not bp then return nil end
    local tools, seen = {}, {}
    for _, tool in ipairs(bp:GetChildren()) do
        local mapped = tn[tool.Name]
        if mapped and not seen[mapped] then
            seen[mapped] = true
            table.insert(tools, mapped)
        end
    end
    return #tools > 0 and table.concat(tools, ", ") or nil
end

rs.RenderStepped:Connect(function()
    for _, p in ipairs(ps:GetPlayers()) do
        if p == lp then continue end
        local c = p.Character

        if c and c:IsDescendantOf(workspace) then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    if not esp[p] then
                        esp[p] = {
                            char = newText(14, Color3.fromRGB(150, 150, 150)),
                            user = newText(14, Color3.fromRGB(255, 255, 255)),
                            tool = newText(12, Color3.fromRGB(150, 150, 150))
                        }
                    end

                    local e = esp[p]
                    local charName = p:GetAttribute("CharacterName")

                    if charName then
                        e.char.Text = charName
                        e.char.Position = Vector2.new(pos.X, pos.Y - 50)
                        e.char.Visible = true
                    else
                        e.char.Visible = false
                    end

                    e.user.Text = p.Name
                    e.user.Position = Vector2.new(pos.X, pos.Y - 36)
                    e.user.Visible = true

                    local t = getTools(p)
                    if t then
                        e.tool.Text = t
                        e.tool.Position = Vector2.new(pos.X, pos.Y - 22)
                        e.tool.Visible = true
                    else
                        e.tool.Visible = false
                    end
                else
                    if esp[p] then
                        e = esp[p]
                        e.char.Visible = false
                        e.user.Visible = false
                        e.tool.Visible = false
                    end
                end
            else
                if esp[p] then
                    e = esp[p]
                    e.char.Visible = false
                    e.user.Visible = false
                    e.tool.Visible = false
                end
            end
        else
            if esp[p] then
                e = esp[p]
                e.char.Visible = false
                e.user.Visible = false
                e.tool.Visible = false
            end
        end
    end

    local folder = workspace:FindFirstChild("playerCloneFolder")
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") then
                for _, prt in ipairs(model:GetChildren()) do
                    if prt:IsA("BasePart") then
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - prt.Position).Magnitude
                            if dist < maxDist then
                                local pos, onScreen = cam:WorldToViewportPoint(prt.Position)
                                if onScreen then
                                    local scale = math.clamp(1 / (dist / 100), 1, 5)
                                    local sz = Vector2.new(1000 / pos.Z * scale, 2000 / pos.Z * scale)
                                    local screen = Vector2.new(pos.X - sz.X / 2, pos.Y - sz.Y / 2)

                                    if not esp[model] then
                                        esp[model] = {
                                            box = newBox(Color3.fromRGB(255, 0, 0)),
                                            label = newText(14, Color3.fromRGB(255, 255, 255))
                                        }

                                        model.AncestryChanged:Connect(function(_, parent)
                                            if not parent and esp[model] then
                                                esp[model].box:Remove()
                                                esp[model].label:Remove()
                                                esp[model] = nil
                                            end
                                        end)
                                    end

                                    local e = esp[model]
                                    e.box.Size = sz
                                    e.box.Position = screen
                                    e.box.Visible = true

                                    e.label.Text = model.Name
                                    e.label.Position = Vector2.new(pos.X, screen.Y - 20)
                                    e.label.Visible = true
                                else
                                    if esp[model] then
                                        esp[model].box.Visible = false
                                        esp[model].label.Visible = false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

ps.PlayerRemoving:Connect(function(p)
    if esp[p] then
        esp[p].char:Remove()
        esp[p].user:Remove()
        esp[p].tool:Remove()
        esp[p] = nil
    end
end)

-- Deleting StunPlayer and EnhancedMovementService
local stunPlayerPath = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameServices"):WaitForChild("ToClient"):WaitForChild("StunPlayer")
local enhancedMovementService = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EnhancedMovementService")

if stunPlayerPath then
    stunPlayerPath:Destroy()
end

if enhancedMovementService then
    enhancedMovementService:Destroy()
end

game.ReplicatedStorage.Remotes.GameServices.ToClient.ChildAdded:Connect(function(child)
    if child.Name == "StunPlayer" then
        child:Destroy()
    end
end)

-- Deleting GUI Elements
local screenUtils = lp.PlayerGui:WaitForChild("ScreenUtils")
local children = screenUtils:GetChildren()
if #children >= 5 then
    children[3]:Destroy()
    children[4]:Destroy()
    children[5]:Destroy()
end

-- Setting camera zoom
lp.CameraMaxZoomDistance = math.huge
lp.CameraMinZoomDistance = 0

if not game:IsLoaded() then game.Loaded:Wait() end
local PopperClient = lp.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("ZoomController"):WaitForChild("Popper")
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
        lp.CameraMaxZoomDistance = math.huge
        lp.CameraMinZoomDistance = 0
    end
end)

local function isSizeMatch(size)
    return math.abs(size.X - 0.124) < 0.01 and math.abs(size.Y - 6.944) < 0.01 and math.abs(size.Z - 37.45) < 0.01
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

local tomb = workspace:WaitForChild("Interactables"):WaitForChild("SilasTomb")

while true do
    local tunnelDoor = tomb:FindFirstChild("TunnelDoor")
    if tunnelDoor then
        tunnelDoor:Destroy()
        break
    end
    task.wait(1)
end
