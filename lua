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
 
 local targetSize = Vector3.new(73.965, 1, 12.874)
 local targetParent = game.Workspace.Buildings.MikaelsonEstate
 
 local function destroyMatchingParts()
     while true do
         for _, part in pairs(targetParent:GetDescendants()) do
             if part:IsA("Part") and (part.Size - targetSize).Magnitude < 0.1 then
                 part:Destroy()
             end
         end
         wait(1)
     end
 end
 
 local function isSizeMatch(size)
     return math.abs(size.X - 0.124) < 0.01 and math.abs(size.Y - 6.944) < 0.01 and math.abs(size.Z - 37.45) < 0.01
 end
 
 local garage = game.Workspace:FindFirstChild("Buildings") and game.Workspace.Buildings:FindFirstChild("Garage")
 
 local function destroyGarageParts()
     while true do
         if garage then
             for _, obj in ipairs(garage:GetDescendants()) do
                 if obj:IsA("BasePart") and isSizeMatch(obj.Size) then
                     obj:Destroy()
                 end
             end
         end
         wait(1)
     end
 end
 
 coroutine.wrap(destroyMatchingParts)()
 coroutine.wrap(destroyGarageParts)()
 
 local stunPlayerPath = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameServices"):WaitForChild("ToClient"):WaitForChild("StunPlayer")
 local enhancedMovementService = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EnhancedMovementService")
 
 local function deleteStunPlayer()
     if stunPlayerPath then
         stunPlayerPath:Destroy()
     end
 end
 
 local function deleteEnhancedMovementService()
     if enhancedMovementService then
         enhancedMovementService:Destroy()
     end
 end
 
 deleteStunPlayer()
 deleteEnhancedMovementService()
 
 game.ReplicatedStorage.Remotes.GameServices.ToClient.ChildAdded:Connect(function(child)
     if child.Name == "StunPlayer" then
         child:Destroy()
     end
 end)

local function destroyTunnelDoor(door)
     if door and door.Parent then
         door:Destroy()
     end
 end
 
 local function checkAndDestroyTunnelDoor()
     while true do
         local tunnelDoor = game.Workspace.Interactables.SilasTomb:FindFirstChild("TunnelDoor")
         if tunnelDoor then
             destroyTunnelDoor(tunnelDoor)
         end
         wait(0.1)
     end
 end
 
 local player = game.Players.LocalPlayer
 local camera = workspace.CurrentCamera
 local espObjects = {}
 
 local function createESP(part)
     local mainPart = part:FindFirstChild("Main")
     if not mainPart then return end
 
     local billboardGui = Instance.new("BillboardGui", mainPart)
     billboardGui.Size = UDim2.new(0, 100, 0, 25)
     billboardGui.Adornee = mainPart
     billboardGui.AlwaysOnTop = true
     billboardGui.StudsOffset = Vector3.new(0, 5, 0)
 
     local label = Instance.new("TextLabel", billboardGui)
     label.Size = UDim2.new(1, 0, 1, 0)
     label.BackgroundTransparency = 1
     label.TextColor3 = Color3.fromRGB(169, 169, 169)
     label.TextScaled = true
     label.TextStrokeTransparency = 0.8
     label.Text = "White Oak Stake"
     label.TextSize = 10
 
     table.insert(espObjects, {mainPart = mainPart, billboardGui = billboardGui, label = label})
 end
 
 local function checkForNewParts()
     for _, part in ipairs(workspace:GetChildren()) do
         if part.Name == "IndestructibleWhiteOakStake" and part:FindFirstChild("Main") then
             local isAdded = false
             for _, esp in ipairs(espObjects) do
                 if esp.mainPart == part.Main then
                     isAdded = true
                     break
                 end
             end
             if not isAdded then
                 createESP(part)
             end
         end
     end
 end
 
 game:GetService("RunService").RenderStepped:Connect(function()
     checkForNewParts()
     for _, esp in ipairs(espObjects) do
         local mainPart = esp.mainPart
         local label = esp.label
         local distance = (camera.CFrame.Position - mainPart.Position).Magnitude
         label.Text = "White Oak Stake\n" .. math.round(distance) .. " studs"
         esp.billboardGui.Enabled = camera:WorldToViewportPoint(mainPart.Position).Z > 0
     end
 end)
 
 coroutine.wrap(checkAndDestroyTunnelDoor)()
 
 for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
     if v.ClassName == "ProximityPrompt" then
         v.HoldDuration = 0
     end
 end
