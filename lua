local ps = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = ps.LocalPlayer
local cam = workspace.CurrentCamera

-- Maximum distance for ESP to show
local maxDist = 1000
local esp = {}

-- Tool names
local tn = {
    RedOakStake = "RedOak",
    WhiteOakStake = "WhiteOak",
    QetsiyahCure = "QetCure",
    TheCure = "Cure",
    IndestructibleWhiteOakStake = "Indestructible"
}

-- Helper functions to create UI elements
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

-- ESP Script (for players and items)
local function setupESP()
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
                        e.char.Text = p.Name
                        e.char.Position = Vector2.new(pos.X, pos.Y - 50)
                        e.char.Visible = true

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
                            esp[p].char.Visible = false
                            esp[p].user.Visible = false
                            esp[p].tool.Visible = false
                        end
                    end
                else
                    if esp[p] then
                        esp[p].char.Visible = false
                        esp[p].user.Visible = false
                        esp[p].tool.Visible = false
                    end
                end
            end
        end
    end)
end

-- StunPlayer and EnhancedMovementService Removal
local function removeStunPlayerAndMovementServices()
    local stunPlayerPath = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameServices"):WaitForChild("ToClient"):WaitForChild("StunPlayer")
    local enhancedMovementService = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EnhancedMovementService")
    
    if stunPlayerPath then
        stunPlayerPath:Destroy()
    end

    if enhancedMovementService then
        enhancedMovementService:Destroy()
    end

    -- Handle any StunPlayer creation
    game.ReplicatedStorage.Remotes.GameServices.ToClient.ChildAdded:Connect(function(child)
        if child.Name == "StunPlayer" then
            child:Destroy()
        end
    end)
end

-- GUI Cleanup
local function cleanupGUI()
    local screenUtils = lp.PlayerGui:WaitForChild("ScreenUtils")
    local children = screenUtils:GetChildren()
    if #children >= 5 then
        children[3]:Destroy()
        children[4]:Destroy()
        children[5]:Destroy()
    end
end

-- Infinite Zoom
local function setupInfiniteZoom()
    -- Set camera zoom limits
    lp.CameraMaxZoomDistance = math.huge
    lp.CameraMinZoomDistance = 0
    
    -- Prevent zooming beyond limits
    spawn(function()
        while true do
            wait(1)
            lp.CameraMaxZoomDistance = math.huge
            lp.CameraMinZoomDistance = 0
        end
    end)
end

-- Remove Specific Objects (tomb, etc.)
local function removeObjects()
    spawn(function()
        -- Removing tomb door
        local tomb = workspace:WaitForChild("Interactables"):WaitForChild("SilasTomb")
        while true do
            local tunnelDoor = tomb:FindFirstChild("TunnelDoor")
            if tunnelDoor then
                tunnelDoor:Destroy()
                break
            end
            task.wait(1)
        end
    end)
end

-- Run the scripts in parallel
spawn(setupESP)
spawn(removeStunPlayerAndMovementServices)
spawn(cleanupGUI)
spawn(setupInfiniteZoom)
spawn(removeObjects)
