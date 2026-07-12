local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer


local COLOR_BG = Color3.fromRGB(20, 20, 25)
local COLOR_FRAME = Color3.fromRGB(28, 28, 35)
local COLOR_ACCENT = Color3.fromRGB(0, 170, 255)
local COLOR_TEXT = Color3.fromRGB(240, 240, 240)
local COLOR_TEXT_DARK = Color3.fromRGB(150, 150, 150)
local COLOR_CLOSE = Color3.fromRGB(255, 75, 75)
local COLOR_TEAM_PARTICLE = Color3.fromRGB(0, 255, 100)


local OrigLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}


local PupueGui = Instance.new("ScreenGui")
PupueGui.Name = "PupueVisualsV3_Final"
PupueGui.ResetOnSpawn = false
PupueGui.Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui


local WaypointFolder = Instance.new("Folder")
WaypointFolder.Name = "PupueWaypoints"
WaypointFolder.Parent = PupueGui


local MainContainer = Instance.new("Frame")
MainContainer.Name = "ColumnsContainer"
MainContainer.Size = UDim2.new(0, 620, 0, 320)
MainContainer.Position = UDim2.new(0.5, -310, 0.5, -160)
MainContainer.BackgroundTransparency = 1 
MainContainer.Visible = false 
MainContainer.Parent = PupueGui


local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Size = UDim2.new(0, 250, 0, 28)
SearchFrame.Position = UDim2.new(0.5, -125, 0, 0)
SearchFrame.BackgroundColor3 = COLOR_BG
SearchFrame.Parent = MainContainer
local SearchCorner = Instance.new("UICorner", SearchFrame)
SearchCorner.CornerRadius = UDim.new(0, 8)
local SearchStroke = Instance.new("UIStroke", SearchFrame)
SearchStroke.Color = COLOR_ACCENT
SearchStroke.Thickness = 1.5


local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -35, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Поиск..."
SearchBox.PlaceholderColor3 = COLOR_TEXT_DARK
SearchBox.TextColor3 = COLOR_TEXT
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 11
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = SearchFrame


local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseMenuButton"
CloseButton.Size = UDim2.new(0, 22, 0, 22)
CloseButton.Position = UDim2.new(1, -25, 0.5, -11) 
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
CloseButton.Text = "×"
CloseButton.TextColor3 = COLOR_CLOSE
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = SearchFrame


local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 6)
local CloseStroke = Instance.new("UIStroke", CloseButton)
CloseStroke.Color = COLOR_CLOSE
CloseStroke.Thickness = 1


local ColumnsFrame = Instance.new("Frame")
ColumnsFrame.Name = "ColumnsFrame"
ColumnsFrame.Size = UDim2.new(1, 0, 1, -38)
ColumnsFrame.Position = UDim2.new(0, 0, 0, 38)
ColumnsFrame.BackgroundTransparency = 1
ColumnsFrame.Parent = MainContainer


local UIHorizontalLayout = Instance.new("UIListLayout")
UIHorizontalLayout.Parent = ColumnsFrame
UIHorizontalLayout.FillDirection = Enum.FillDirection.Horizontal
UIHorizontalLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIHorizontalLayout.Padding = UDim.new(0, 12)


local Toggles = {
    AspectRatio = false,
    FOV = false,
    WorldParticles = false,
    ParticleShape = false,
    PTrails = false,          
    PTrailsShape = false,     
    Trails = false,
    NimbEsp = false,
    NimbTarget = false, 
    SpeedHack = false,
    JumpPower = false,
    Fly = false,
    Noclip = false,
    PlayerEsp = false,
    EspMode = false,
    Fullbright = false,
    WaypointsActive = false,
    TeamParticle = false,       
    TeamParticleShape = false,
    InfiniteJump = false,     
    NameTagEsp = false,       
    NameTagMode = false,
    Spinner = false           
}


local Values = {
    SpeedHack = 50,
    JumpPower = 50,
    FlySpeed = 45,       
    AspectRatio = 0.7,
    FOV = 90,
    EspTrans = 0.5,
    P_Rate = 0.05,
    P_Lifetime = 5.0,
    P_Size = 0.35,
    P_Radius = 75,       
    NimbSize = 1.8,
    TrailLifetime = 1.8,
    PTrailsSize = 0.4,        
    PTrailsLifetime = 1.5,    
    PTrailsTrans = 0.2,       
    PTrailsRadius = 2,
    TeamParticleSize = 0.8,    
    TeamParticleHeight = 2.5,
    SpinnerSpeed = 25         
}


local Highlights = {}
local Nimbs = {}
local Trails = {}
local TeamParticles = {} 
local NameTags = {}           
local AllUIElements = {} 
local ActiveWaypoints = {}
local WaypointCounter = 0
local TargetNickText = ""
local TargetFlingText = ""
local FriendCache = {}


local FlyBodyGyro, FlyBodyVelocity
local SpinnerInstance = nil   
local MenuVisible = false


local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "MenuIsland"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0.5, -22, 0, 15)
ToggleButton.BackgroundColor3 = COLOR_BG
ToggleButton.Image = "rbxassetid://125091046073664"
ToggleButton.Visible = true 
ToggleButton.Parent = PupueGui


local ButtonCorner = Instance.new("UICorner", ToggleButton)
ButtonCorner.CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", ToggleButton)
ButtonStroke.Color = COLOR_ACCENT
ButtonStroke.Thickness = 1.5


local dragToggle, dragStart, startPos
SearchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainContainer.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end
end)


local islandDragging, islandDragStart, islandStartPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        islandDragging = true
        islandDragStart = input.Position
        islandStartPos = ToggleButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if islandDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - islandDragStart
        ToggleButton.Position = UDim2.new(islandStartPos.X.Scale, islandStartPos.X.Offset + delta.X, islandStartPos.Y.Scale, islandStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then islandDragging = false end
end)


local function SetMenuVisible(visible)
    MenuVisible = visible
    MainContainer.Visible = MenuVisible
    ToggleButton.Visible = not MenuVisible 
end


ToggleButton.MouseButton1Click:Connect(function() SetMenuVisible(true) end)
CloseButton.MouseButton1Click:Connect(function() SetMenuVisible(false) end)


SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, item in pairs(AllUIElements) do
        if query == "" then
            item.Frame.Visible = true
        else
            if item.Text:lower():find(query) then
                item.Frame.Visible = true
            else
                item.Frame.Visible = false
            end
        end
    end
end)


local function AddWaypointAtCurrentPosition()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    WaypointCounter = WaypointCounter + 1
    local pos = char.HumanoidRootPart.Position
    local wpName = "Waypoint " .. tostring(WaypointCounter)
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 100, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.Parent = WaypointFolder
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(0.5, -4, 0.5, -4)
    Dot.BackgroundColor3 = COLOR_ACCENT
    Dot.Parent = Container
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 0, 20)
    Label.Position = UDim2.new(0.5, -100, 0.5, -24)
    Label.BackgroundTransparency = 1
    Label.Text = wpName .. "\n[0m]"
    Label.TextColor3 = COLOR_TEXT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10
    Label.Parent = Container
    
    table.insert(ActiveWaypoints, {
        Position = pos,
        Container = Container,
        Label = Label,
        Name = wpName
    })
end


local function TeleportToLastWaypoint()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and #ActiveWaypoints > 0 then
        local lastWp = ActiveWaypoints[#ActiveWaypoints]
        hrp.CFrame = CFrame.new(lastWp.Position + Vector3.new(0, 3, 0))
    end
end


local function ClearAllWaypoints()
    for _, wp in pairs(ActiveWaypoints) do
        if wp.Container then wp.Container:Destroy() end
    end
    ActiveWaypoints = {}
    WaypointCounter = 0
end


local function TeleportToPlayerByName()
    if TargetNickText == "" then return end
    local searchStr = TargetNickText:lower()
    local targetPlayer = nil
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Name:lower():find(searchStr) then
            targetPlayer = p
            break
        end
    end
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 3)
        end
    end
end


local function FlingPlayerByName()
    if TargetFlingText == "" then return end
    local searchStr = TargetFlingText:lower()
    local targetPlayer = nil
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Name:lower():find(searchStr) then
            targetPlayer = p
            break
        end
    end
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if myHrp and myHum then
            local origCFrame = myHrp.CFrame
            
            local bV = Instance.new("BodyVelocity")
            bV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bV.Velocity = Vector3.new(0, 0, 0)
            bV.Parent = myHrp
            
            local bAV = Instance.new("BodyAngularVelocity")
            bAV.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bAV.AngularVelocity = Vector3.new(0, 99999, 0)
            bAV.Parent = myHrp
            
            myHum.PlatformStand = true
            
            for i = 1, 45 do
                if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then break end
                myHrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                task.wait(0.02)
            end
            
            bV:Destroy()
            bAV:Destroy()
            myHum.PlatformStand = false
            myHrp.CFrame = origCFrame
        end
    end
end


local function CheckIfFriend(player)
    if player == LocalPlayer then return true end
    if FriendCache[player.UserId] ~= nil then
        return FriendCache[player.UserId]
    end
    
    local success, isFriend = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    
    if success then
        FriendCache[player.UserId] = isFriend
        return isFriend
    end
    return false
end


local function UpdateTeamParticle(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end


    local currentPart = TeamParticles[player]
    
    if not Toggles.TeamParticle then
        if currentPart then
            currentPart:Destroy()
            TeamParticles[player] = nil
        end
        return
    end


    if not currentPart or currentPart.Parent ~= char then
        if currentPart then currentPart:Destroy() end
        
        currentPart = Instance.new("Part")
        currentPart.Name = "PupueTeamParticle"
        currentPart.Material = Enum.Material.Neon
        currentPart.Color = COLOR_TEAM_PARTICLE
        currentPart.CanCollide = false
        currentPart.Massless = true
        
        local weld = Instance.new("Weld")
        weld.Name = "ParticleWeld"
        weld.Part0 = char.Head
        weld.Part1 = currentPart
        weld.Parent = currentPart
        
        currentPart.Parent = char
        TeamParticles[player] = currentPart
    end


    currentPart.Shape = Toggles.TeamParticleShape and Enum.PartType.Ball or Enum.PartType.Block
    local s = Values.TeamParticleSize
    currentPart.Size = Vector3.new(s, s, s)
    
    local weld = currentPart:FindFirstChild("ParticleWeld")
    if weld then
        weld.C0 = CFrame.new(0, Values.TeamParticleHeight, 0)
    end
end


local function UpdateNameTag(player)
    if player == LocalPlayer or not Toggles.NameTagEsp then
        if NameTags[player] then
            NameTags[player]:Destroy()
            NameTags[player] = nil
        end
        return
    end


    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    local hum = char and char:FindFirstChildOfClass("Humanoid")


    if head and hum then
        local tag = NameTags[player]
        if not tag or tag.Parent ~= head then
            if tag then tag:Destroy() end
            
            tag = Instance.new("BillboardGui")
            tag.Name = "PupueNameTag"
            tag.Size = UDim2.new(0, 200, 0, 24)
            tag.AlwaysOnTop = true
            tag.ExtentsOffset = Vector3.new(0, 2.5, 0)
            
            local bgFrame = Instance.new("Frame", tag)
            bgFrame.Name = "BGFrame"
            bgFrame.Size = UDim2.new(0, 0, 1, 0)
            bgFrame.Position = UDim2.new(0.5, 0, 0, 0)
            bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bgFrame.BackgroundTransparency = 0.45
            bgFrame.BorderSizePixel = 0
            Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 6)
            
            local tl = Instance.new("TextLabel", bgFrame)
            tl.Name = "Label"
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 11
            tl.TextColor3 = Color3.fromRGB(255, 255, 255)
            tl.TextStrokeTransparency = 1
            
            tag.Parent = head
            NameTags[player] = tag
        end
        
        local currentHp = math.floor(hum.Health)
        local maxHp = math.floor(hum.MaxHealth)
        local bgFrame = tag:FindFirstChild("BGFrame")
        local label = bgFrame and bgFrame:FindFirstChild("Label")
        
        if label and bgFrame then
            local textStr = player.Name .. " [" .. currentHp .. "/" .. maxHp .. "]"
            label.Text = textStr
            
            local textBounds = label.TextBounds
            bgFrame.Size = UDim2.new(0, textBounds.X + 16, 1, 0)
            bgFrame.Position = UDim2.new(0.5, -(textBounds.X + 16)/2, 0, 0)
            
            if Toggles.NameTagMode then
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                label.TextColor3 = Color3.fromHSV(hpPercent * 0.33, 1, 1) 
            end
        end
    else
        if NameTags[player] then
            NameTags[player]:Destroy()
            NameTags[player] = nil
        end
    end
end


UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.SpeedHack then hum.WalkSpeed = Values.SpeedHack end
            if Toggles.JumpPower then hum.UseJumpPower = true hum.JumpPower = Values.JumpPower end
        end
        if Toggles.Noclip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
        
        if Toggles.PTrails and char:FindFirstChild("HumanoidRootPart") and hum and hum.MoveDirection.Magnitude > 0 then
            local hrp = char.HumanoidRootPart
            local p = Instance.new("Part")
            local pSize = Values.PTrailsSize
            p.Size = Vector3.new(pSize, pSize, pSize)
            p.Transparency = Values.PTrailsTrans
            p.Color = COLOR_ACCENT
            p.Material = Enum.Material.Neon
            p.CanCollide = false
            p.Anchored = true
            p.Shape = Toggles.PTrailsShape and Enum.PartType.Ball or Enum.PartType.Block
            
            local rad = Values.PTrailsRadius
            local offset = Vector3.new(
                math.random(-rad, rad) / 10,
                math.random(-rad, rad) / 10,
                math.random(-rad, rad) / 10
            )
            p.Position = hrp.Position - Vector3.new(0, 1.2, 0) + offset
            p.Parent = Workspace
            
            task.spawn(function()
                local lifetime = Values.PTrailsLifetime
                local startTrans = p.Transparency
                local steps = 12
                for i = 1, steps do
                    task.wait(lifetime / steps)
                    if not p or not p.Parent then break end
                    p.Transparency = startTrans + (1 - startTrans) * (i / steps)
                end
                if p and p.Parent then p:Destroy() end
            end)
        end
    end
end)


RunService.RenderStepped:Connect(function()
    local Camera = Workspace.CurrentCamera
    if not Camera then return end
    
    if Toggles.FOV then Camera.FieldOfView = Values.FOV else Camera.FieldOfView = 70 end


    if Toggles.AspectRatio then
        local baseCFrame = Camera.CFrame
        local xVector = baseCFrame.XVector * math.max(Values.AspectRatio, 0.1)
        Camera.CFrame = CFrame.fromMatrix(baseCFrame.Position, xVector, baseCFrame.YVector, baseCFrame.ZVector)
    end


    if Toggles.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        
        if FlyBodyGyro and FlyBodyVelocity then
            FlyBodyGyro.CFrame = Camera.CFrame
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                FlyBodyVelocity.Velocity = Camera.CFrame.LookVector * Values.FlySpeed * moveDir.Magnitude
            else
                FlyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
        end
    end
    
    if Toggles.WaypointsActive then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        for _, wp in pairs(ActiveWaypoints) do
            local screenPos, onScreen = Camera:WorldToViewportPoint(wp.Position)
            if onScreen then
                wp.Container.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                wp.Container.Visible = true
                if hrp then
                    local dist = math.floor((hrp.Position - wp.Position).Magnitude)
                    wp.Label.Text = wp.Name .. "\n[" .. tostring(dist) .. "m]"
                else
                    wp.Label.Text = wp.Name
                end
            else
                wp.Container.Visible = false
            end
        end
    else
        for _, wp in pairs(ActiveWaypoints) do wp.Container.Visible = false end
    end
end)


task.spawn(function()
    while true do
        if Toggles.WorldParticles and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local part = Instance.new("Part")
            local pSize = Values.P_Size
            part.Size = Vector3.new(pSize, pSize, pSize)
            part.Transparency = 0.15
            part.Color = COLOR_ACCENT
            part.Material = Enum.Material.Neon
            part.CanCollide = false 
            part.Anchored = false 
            part.Shape = Toggles.ParticleShape and Enum.PartType.Ball or Enum.PartType.Block
            
            local att = Instance.new("Attachment", part)
            local vel = Instance.new("LinearVelocity", part)
            vel.Attachment0 = att
            vel.MaxForce = 9e4
            vel.VectorVelocity = Vector3.new(0, -8, 0)
            
            local spawnPos = hrp.Position + Vector3.new(0, 25, 0)
            local rad = Values.P_Radius
            local rOffset = Vector3.new(math.random(-rad, rad), math.random(-2, 2), math.random(-rad, rad))
            part.Position = spawnPos + rOffset
            part.Parent = Workspace
            
            local touchedGround = false
            task.spawn(function()
                local function fadeOutAndDestroy()
                    if touchedGround then return end
                    touchedGround = true
                    vel:Destroy()
                    part.Anchored = true 
                    local fadeSteps = 15
                    for i = 1, fadeSteps do
                        task.wait(0.02)
                        if not part or not part.Parent then break end
                        part.Transparency = math.min(1, part.Transparency + (0.85 / fadeSteps))
                    end
                    if part and part.Parent then part:Destroy() end
                end
                
                local connection
                connection = part.Touched:Connect(function(hit)
                    if hit and not hit:IsDescendantOf(LocalPlayer.Character) and hit.Name ~= "Part" then
                        if connection then connection:Disconnect() end
                        fadeOutAndDestroy()
                    end
                end)
                
                task.wait(Values.P_Lifetime)
                if connection then connection:Disconnect() end
                if part and part.Parent and not touchedGround then part:Destroy() end
            end)
        end
        task.wait(math.max(0.01, Values.P_Rate))
    end
end)


local function CreateDonutNimb(character)
    if not character or not character:FindFirstChild("Head") then return end
    local mainRing = Instance.new("Part")
    mainRing.Name = "PupueDonut"
    mainRing.Size = Vector3.new(1, 1, 1)
    mainRing.Material = Enum.Material.Neon
    mainRing.Color = COLOR_ACCENT
    mainRing.CanCollide = false
    mainRing.Massless = true
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://3270017" 
    mesh.Scale = Vector3.new(Values.NimbSize, Values.NimbSize, 0.2)
    mesh.Parent = mainRing
    
    local innerGlow = Instance.new("Part")
    innerGlow.Name = "PupueDonutGlow"
    innerGlow.Size = Vector3.new(1, 1, 1)
    innerGlow.Material = Enum.Material.Neon
    innerGlow.Color = COLOR_ACCENT
    innerGlow.Transparency = 0.4
    innerGlow.CanCollide = false
    innerGlow.Massless = true
    
    local meshGlow = Instance.new("SpecialMesh")
    meshGlow.MeshType = Enum.MeshType.FileMesh
    meshGlow.MeshId = "rbxassetid://3270017"
    meshGlow.Scale = Vector3.new(Values.NimbSize + 0.05, Values.NimbSize + 0.05, 0.3)
    meshGlow.Parent = innerGlow
    
    local weld1 = Instance.new("Weld")
    weld1.Part0 = character.Head; weld1.Part1 = mainRing; weld1.C0 = CFrame.new(0, 1.1, 0) * CFrame.Angles(math.rad(90), 0, 0); weld1.Parent = mainRing
    local weld2 = Instance.new("Weld")
    weld2.Part0 = character.Head; weld2.Part1 = innerGlow; weld2.C0 = CFrame.new(0, 1.1, 0) * CFrame.Angles(math.rad(90), 0, 0); weld2.Parent = innerGlow
    
    mainRing.Parent = character; innerGlow.Parent = character
    return mainRing
end


local function ClearNimbFromCharacter(char)
    if char then
        if char:FindFirstChild("PupueDonut") then char.PupueDonut:Destroy() end
        if char:FindFirstChild("PupueDonutGlow") then char.PupueDonutGlow:Destroy() end
    end
end


task.spawn(function()
    while task.wait(0.1) do
        for _, p in pairs(Players:GetPlayers()) do
            local isFriend = CheckIfFriend(p)
            
            if Toggles.TeamParticle and isFriend then
                UpdateTeamParticle(p)
            else
                if TeamParticles[p] then TeamParticles[p]:Destroy() TeamParticles[p] = nil end
            end


            UpdateNameTag(p)
        end


        if Toggles.NimbEsp then
            for _, p in pairs(Players:GetPlayers()) do
                local shouldHaveNimb = Toggles.NimbTarget and true or (p == LocalPlayer)
                if shouldHaveNimb and p.Character and p.Character:FindFirstChild("Head") then
                    local nimb = Nimbs[p]
                    if not nimb or nimb.Parent ~= p.Character or not p.Character:FindFirstChild("PupueDonut") then
                        ClearNimbFromCharacter(p.Character)
                        Nimbs[p] = CreateDonutNimb(p.Character)
                    else
                        local d1 = p.Character:FindFirstChild("PupueDonut")
                        local d2 = p.Character:FindFirstChild("PupueDonutGlow")
                        if d1 and d1:FindFirstChildOfClass("SpecialMesh") then d1:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(Values.NimbSize, Values.NimbSize, 0.2) end
                        if d2 and d2:FindFirstChildOfClass("SpecialMesh") then d2:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(Values.NimbSize + 0.05, Values.NimbSize + 0.05, 0.3) end
                    end
                else
                    if Nimbs[p] then ClearNimbFromCharacter(p.Character) Nimbs[p] = nil end
                end
            end
        else
            for p, n in pairs(Nimbs) do ClearNimbFromCharacter(p.Character) Nimbs[p] = nil end
        end


        if Toggles.PlayerEsp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = Highlights[p]
                    if not hl or hl.Parent ~= p.Character then
                        if hl then hl:Destroy() end
                        hl = Instance.new("Highlight")
                        hl.Parent = p.Character
                        Highlights[p] = hl
                    end
                    hl.FillColor = COLOR_ACCENT
                    if Toggles.EspMode then hl.FillTransparency = 1 hl.OutlineColor = COLOR_ACCENT else hl.FillTransparency = Values.EspTrans hl.OutlineColor = COLOR_BG end
                end
            end
        else
            for p, hl in pairs(Highlights) do if hl then hl:Destroy() end Highlights[p] = nil end
        end
    end
end)


function UpdateFeatures(feature)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if feature == "SpeedHack" and not Toggles.SpeedHack then hum.WalkSpeed = 16 end
    if feature == "JumpPower" and not Toggles.JumpPower then hum.JumpPower = 50 end


    if feature == "Fullbright" then
        if Toggles.Fullbright then
            Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255); Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = OrigLighting.Brightness; Lighting.ClockTime = OrigLighting.ClockTime; Lighting.FogEnd = OrigLighting.FogEnd
            Lighting.GlobalShadows = OrigLighting.GlobalShadows; Lighting.Ambient = OrigLighting.Ambient; Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
        end
    end


    if feature == "Fly" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if Toggles.Fly then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.P = 9e4; FlyBodyGyro.maxTorque = Vector3.new(9e5, 9e5, 9e5); FlyBodyGyro.CFrame = hrp.CFrame; FlyBodyGyro.Parent = hrp
            
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.velocity = Vector3.new(0, 0.1, 0); FlyBodyVelocity.maxForce = Vector3.new(9e5, 9e5, 9e5); FlyBodyVelocity.Parent = hrp
            hum.PlatformStand = true
        else
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
            hum.PlatformStand = false
        end
    end


    if feature == "Spinner" or feature == "SpinnerSpeed" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if Toggles.Spinner then
            if not SpinnerInstance then
                SpinnerInstance = Instance.new("BodyAngularVelocity")
                SpinnerInstance.Name = "PupueSpinner"
                SpinnerInstance.MaxTorque = Vector3.new(0, 9e9, 0)
                SpinnerInstance.Parent = hrp
            end
            SpinnerInstance.AngularVelocity = Vector3.new(0, Values.SpinnerSpeed, 0)
        else
            if SpinnerInstance then SpinnerInstance:Destroy() SpinnerInstance = nil end
        end
    end


    if feature == "Trails" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if Toggles.Trails and hrp then
            if Trails[LocalPlayer] and Trails[LocalPlayer][1] then
                Trails[LocalPlayer][1].Lifetime = Values.TrailLifetime
            else
                local trail = Instance.new("Trail")
                local a0 = Instance.new("Attachment", hrp); local a1 = Instance.new("Attachment", hrp)
                a0.Position = Vector3.new(0, 0.8, 0); a1.Position = Vector3.new(0, -0.8, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(COLOR_ACCENT); trail.Lifetime = Values.TrailLifetime; trail.Parent = hrp
                Trails[LocalPlayer] = {trail, a0, a1}
            end
        else
            if Trails[LocalPlayer] then for _, v in pairs(Trails[LocalPlayer]) do v:Destroy() end Trails[LocalPlayer] = nil end
        end
    end
    
    if feature == "TrailLifetime" and Toggles.Trails and Trails[LocalPlayer] and Trails[LocalPlayer][1] then
        Trails[LocalPlayer][1].Lifetime = Values.TrailLifetime
    end
end


LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if Toggles.Fly then Toggles.Fly = false UpdateFeatures("Fly") end
    if Toggles.Trails then Trails[LocalPlayer] = nil UpdateFeatures("Trails") end
    if Toggles.Spinner then SpinnerInstance = nil UpdateFeatures("Spinner") end
end)


local function CreateColumn(categoryName, layoutOrder)
    local ColumnFrame = Instance.new("Frame")
    ColumnFrame.Name = categoryName .. "Column"
    ColumnFrame.Size = UDim2.new(0, 190, 0, 272)
    ColumnFrame.BackgroundColor3 = COLOR_BG
    ColumnFrame.BorderSizePixel = 0
    ColumnFrame.LayoutOrder = layoutOrder
    ColumnFrame.Parent = ColumnsFrame


    local UICorner = Instance.new("UICorner", ColumnFrame)
    UICorner.CornerRadius = UDim.new(0, 14) 
    local ColumnStroke = Instance.new("UIStroke", ColumnFrame)
    ColumnStroke.Color = COLOR_ACCENT
    ColumnStroke.Thickness = 1.5


    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = categoryName
    Title.TextColor3 = COLOR_TEXT
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.Parent = ColumnFrame


    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, 0, 1, -30)
    ContentContainer.Position = UDim2.new(0, 0, 0, 30)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.ScrollBarImageColor3 = COLOR_ACCENT
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentContainer.Parent = ColumnFrame


    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ContentContainer
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center


    local UIPad = Instance.new("UIPadding", ContentContainer)
    UIPad.PaddingTop = UDim.new(0, 3)
    UIPad.PaddingBottom = UDim.new(0, 60) 


    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 65)
    end)


    return ContentContainer
end


local function CreateButton(parentColumn, name, text, layout, altOnText, altOffText)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 32)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8) 


    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text; Label.TextColor3 = COLOR_TEXT_DARK; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 10.5; Label.TextXAlignment = Enum.TextXAlignment.Left


    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 15)
    ToggleBtn.Position = UDim2.new(1, -48, 0.5, -7)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleBtn.Text = altOffText or "OFF"; ToggleBtn.TextColor3 = COLOR_TEXT_DARK; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 8
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)


    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        ToggleBtn.Text = Toggles[name] and (altOnText or "ON") or (altOffText or "OFF")
        ToggleBtn.BackgroundColor3 = Toggles[name] and COLOR_ACCENT or Color3.fromRGB(45, 45, 55)
        ToggleBtn.TextColor3 = Toggles[name] and Color3.fromRGB(20,20,20) or COLOR_TEXT_DARK
        Label.TextColor3 = Toggles[name] and COLOR_TEXT or COLOR_TEXT_DARK
        UpdateFeatures(name)
    end)
    
    table.insert(AllUIElements, {Text = text, Frame = Frame})
end


local function CreateActionClickable(parentColumn, text, layout, clickCallback)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 32)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)


    local ClickBtn = Instance.new("TextButton", Frame)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0); ClickBtn.BackgroundTransparency = 1; ClickBtn.Text = text
    ClickBtn.TextColor3 = COLOR_ACCENT; ClickBtn.Font = Enum.Font.GothamBold; ClickBtn.TextSize = 10.5; ClickBtn.TextXAlignment = Enum.TextXAlignment.Center
    ClickBtn.MouseButton1Click:Connect(clickCallback)
    
    table.insert(AllUIElements, {Text = text, Frame = Frame})
end


local function CreateSlider(parentColumn, name, text, min, max, isFloat, layout, customToggle)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 44)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8) 


    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -10, 0, 18); Label.Position = UDim2.new(0, 8, 0, 2); Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(Values[name]); Label.TextColor3 = COLOR_TEXT; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 9.5; Label.TextXAlignment = Enum.TextXAlignment.Left


    if not customToggle then
        local ToggleBtn = Instance.new("TextButton", Frame)
        ToggleBtn.Size = UDim2.new(0, 30, 0, 14); ToggleBtn.Position = UDim2.new(1, -38, 0, 3); ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        ToggleBtn.Text = "OFF"; ToggleBtn.TextColor3 = COLOR_TEXT_DARK; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 8
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)
        
        ToggleBtn.MouseButton1Click:Connect(function()
            Toggles[name] = not Toggles[name]
            ToggleBtn.Text = Toggles[name] and "ON" or "OFF"
            ToggleBtn.BackgroundColor3 = Toggles[name] and COLOR_ACCENT or Color3.fromRGB(45, 45, 55)
            ToggleBtn.TextColor3 = Toggles[name] and Color3.fromRGB(20,20,20) or COLOR_TEXT_DARK
            UpdateFeatures(name)
        end)
    end


    -- Фикс бага: привязываем к Frame (а не к несуществующему Track)
    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(0.9, 0, 0, 4); Track.Position = UDim2.new(0.05, 0, 0, 28); Track.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)


    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((Values[name] - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = COLOR_ACCENT
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)


    local DragBtn = Instance.new("TextButton", Track)
    DragBtn.Size = UDim2.new(1, 0, 1, 0); DragBtn.BackgroundTransparency = 1; DragBtn.Text = ""


    local ActiveInput = false
    local function UpdateSlider()
        if not Track then return end
        local trackWidth = Track.AbsoluteSize.X
        if trackWidth <= 0 then trackWidth = 160 end
        
        local percentage = math.clamp((UserInputService:GetMouseLocation().X - Track.AbsolutePosition.X) / trackWidth, 0, 1)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        local rawValue = min + (max - min) * percentage
        local finalValue = isFloat and math.floor(rawValue * 100) / 100 or math.floor(rawValue)
        Values[name] = finalValue
        Label.Text = text .. ": " .. tostring(finalValue)
        UpdateFeatures(name)
    end


    DragBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveInput = true UpdateSlider() end end)
    UserInputService.InputChanged:Connect(function(input) if ActiveInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveInput = false end end)
    
    table.insert(AllUIElements, {Text = text, Frame = Frame})
end


local function CreateCombinedToggleSlider(parentColumn, toggleName, sliderName, text, min, max, layout, isFloat)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 50) 
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)


    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -55, 0, 22)
    Label.Position = UDim2.new(0, 8, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(Values[sliderName])
    Label.TextColor3 = COLOR_TEXT_DARK
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left


    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 15)
    ToggleBtn.Position = UDim2.new(1, -48, 0, 5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = COLOR_TEXT_DARK
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 8
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)


    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[toggleName] = not Toggles[toggleName]
        ToggleBtn.Text = Toggles[toggleName] and "ON" or "OFF"
        ToggleBtn.BackgroundColor3 = Toggles[toggleName] and COLOR_ACCENT or Color3.fromRGB(45, 45, 55)
        ToggleBtn.TextColor3 = Toggles[toggleName] and Color3.fromRGB(20,20,20) or COLOR_TEXT_DARK
        Label.TextColor3 = Toggles[toggleName] and COLOR_TEXT or COLOR_TEXT_DARK
        UpdateFeatures(toggleName)
    end)


    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(0.9, 0, 0, 4)
    Track.Position = UDim2.new(0.05, 0, 0, 34)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)


    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((Values[sliderName] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = COLOR_ACCENT
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)


    local DragBtn = Instance.new("TextButton", Track)
    DragBtn.Size = UDim2.new(1, 0, 1, 0)
    DragBtn.BackgroundTransparency = 1
    DragBtn.Text = ""


    local ActiveInput = false
    local function UpdateSlider()
        if not Track then return end
        local trackWidth = Track.AbsoluteSize.X
        if trackWidth <= 0 then trackWidth = 160 end
        
        local percentage = math.clamp((UserInputService:GetMouseLocation().X - Track.AbsolutePosition.X) / trackWidth, 0, 1)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        local rawValue = min + (max - min) * percentage
        Values[sliderName] = isFloat and (math.floor(rawValue * 10) / 10) or math.floor(rawValue)
        Label.Text = text .. ": " .. tostring(Values[sliderName])
        UpdateFeatures(toggleName)
    end


    DragBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveInput = true UpdateSlider() end end)
    UserInputService.InputChanged:Connect(function(input) if ActiveInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveInput = false end end)


    table.insert(AllUIElements, {Text = text, Frame = Frame})
end


local function CreatePlayerTeleporter(parentColumn, layout)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 36)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)


    local TxtBox = Instance.new("TextBox", Frame)
    TxtBox.Size = UDim2.new(0.6, -10, 1, -10)
    TxtBox.Position = UDim2.new(0, 6, 0.5, -13)
    TxtBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TxtBox.Text = ""
    TxtBox.PlaceholderText = "Ник игрока..."
    TxtBox.PlaceholderColor3 = COLOR_TEXT_DARK
    TxtBox.TextColor3 = COLOR_TEXT
    TxtBox.Font = Enum.Font.GothamMedium
    TxtBox.TextSize = 9.5
    Instance.new("UICorner", TxtBox).CornerRadius = UDim.new(0, 5)
    
    TxtBox:GetPropertyChangedSignal("Text"):Connect(function()
        TargetNickText = TxtBox.Text
    end)


    local TpBtn = Instance.new("TextButton", Frame)
    TpBtn.Size = UDim2.new(0.4, -6, 1, -10)
    TpBtn.Position = UDim2.new(0.6, 2, 0.5, -13)
    TpBtn.BackgroundColor3 = COLOR_ACCENT
    TpBtn.Text = "Teleport"
    TpBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    TpBtn.Font = Enum.Font.GothamBold
    TpBtn.TextSize = 10
    Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 5)


    TpBtn.MouseButton1Click:Connect(TeleportToPlayerByName)
    
    table.insert(AllUIElements, {Text = "Teleport Player Nickname Tp", Frame = Frame})
end


local function CreatePlayerFlinger(parentColumn, layout)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 36)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)


    local TxtBox = Instance.new("TextBox", Frame)
    TxtBox.Size = UDim2.new(0.6, -10, 1, -10)
    TxtBox.Position = UDim2.new(0, 6, 0.5, -13)
    TxtBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TxtBox.Text = ""
    TxtBox.PlaceholderText = "Ник для Fling..."
    TxtBox.PlaceholderColor3 = COLOR_TEXT_DARK
    TxtBox.TextColor3 = COLOR_TEXT
    TxtBox.Font = Enum.Font.GothamMedium
    TxtBox.TextSize = 9.5
    Instance.new("UICorner", TxtBox).CornerRadius = UDim.new(0, 5)
    
    TxtBox:GetPropertyChangedSignal("Text"):Connect(function()
        TargetFlingText = TxtBox.Text
    end)


    local FlBtn = Instance.new("TextButton", Frame)
    FlBtn.Size = UDim2.new(0.4, -6, 1, -10)
    FlBtn.Position = UDim2.new(0.6, 2, 0.5, -13)
    FlBtn.BackgroundColor3 = Color3.fromRGB(255, 65, 65) 
    FlBtn.Text = "Fling"
    FlBtn.TextColor3 = COLOR_TEXT
    FlBtn.Font = Enum.Font.GothamBold
    FlBtn.TextSize = 10
    Instance.new("UICorner", FlBtn).CornerRadius = UDim.new(0, 5)


    FlBtn.MouseButton1Click:Connect(FlingPlayerByName)
    
    table.insert(AllUIElements, {Text = "Fling Player Kill Toxic Nickname", Frame = Frame})
end


local VisualCol = CreateColumn("Visuals", 1)
local MovementCol = CreateColumn("Movement", 2)
local PlayerCol = CreateColumn("Player", 3)


-- КОЛОНКА VISUALS
CreateSlider(VisualCol, "AspectRatio", "Aspect Ratio", 0.2, 1.5, true, 1)
CreateSlider(VisualCol, "FOV", "Field of View", 30, 120, false, 2)


CreateButton(VisualCol, "TeamParticle", "Team Particle", 3)
CreateButton(VisualCol, "TeamParticleShape", "Team Part. Shape", 4, "SPHERE", "CUBE")
CreateSlider(VisualCol, "TeamParticleSize", "Team Part. Size", 0.1, 4.0, true, 5, true)
CreateSlider(VisualCol, "TeamParticleHeight", "Team Part. Height", 1.0, 7.0, true, 6, true)


CreateButton(VisualCol, "WorldParticles", "World Particles", 7)
CreateButton(VisualCol, "ParticleShape", "Particle Shape", 8, "SPHERE", "CUBE")
CreateSlider(VisualCol, "P_Rate", "Particles Rate", 0.01, 0.3, true, 9, true)
CreateSlider(VisualCol, "P_Lifetime", "Particles Lifetime", 0.2, 10.0, true, 10, true)
CreateSlider(VisualCol, "P_Size", "Particles Size", 0.1, 1.5, true, 11, true)
CreateSlider(VisualCol, "P_Radius", "Particles Radius", 10, 250, false, 12, true) 


CreateButton(VisualCol, "PTrails", "Particle Trails", 13)
CreateButton(VisualCol, "PTrailsShape", "Particle Trails Shape", 14, "SPHERE", "CUBE")
CreateSlider(VisualCol, "PTrailsRadius", "Particle Trails Radius", 0, 25, false, 15, true)
CreateSlider(VisualCol, "PTrailsLifetime", "Particle Trails Lifetime", 0.2, 5.0, true, 16, true)
CreateSlider(VisualCol, "PTrailsSize", "Particle Trails Size", 0.1, 2.0, true, 17, true)
CreateSlider(VisualCol, "PTrailsTrans", "Particle Trails Transparency", 0.0, 0.9, true, 18, true)


CreateButton(VisualCol, "NimbEsp", "Donut Halo ESP", 19)
CreateButton(VisualCol, "NimbTarget", "Halo Target", 20, "ALL", "ONLY ME") 
CreateSlider(VisualCol, "NimbSize", "Halo Size", 0.5, 5.0, true, 21, true) 
CreateButton(VisualCol, "Fullbright", "Fullbright Mode", 22)


CreateButton(VisualCol, "WaypointsActive", "Show Waypoints", 23)
CreateActionClickable(VisualCol, "Add Waypoint", 24, AddWaypointAtCurrentPosition)
CreateActionClickable(VisualCol, "TP to Last Waypoint", 25, TeleportToLastWaypoint) 
CreateActionClickable(VisualCol, "Clear Waypoints", 26, ClearAllWaypoints)


-- КОЛОНКА MOVEMENT
CreateCombinedToggleSlider(MovementCol, "SpeedHack", "SpeedHack", "Speed Hack", 16, 150, 1, false)
CreateCombinedToggleSlider(MovementCol, "JumpPower", "JumpPower", "Jump Power", 50, 120, 2, false)
CreateCombinedToggleSlider(MovementCol, "Fly", "FlySpeed", "Fly Mode (Mobile)", 10, 200, 3, false) 
CreateButton(MovementCol, "Noclip", "Noclip Mode", 4)
CreateButton(MovementCol, "InfiniteJump", "Infinite Jump", 5)


-- КОЛОНКА PLAYER
CreateButton(PlayerCol, "PlayerEsp", "Highlight ESP", 1)
CreateButton(PlayerCol, "EspMode", "ESP Mode", 2, "OUTLINE", "FULL") 
CreateSlider(PlayerCol, "EspTrans", "ESP Transparency", 0, 1, true, 3, true) 
CreateCombinedToggleSlider(PlayerCol, "Trails", "TrailLifetime", "Player Trails", 0.1, 5.0, 4, true) 
CreateButton(PlayerCol, "NameTagEsp", "NameTag ESP (Nick/HP)", 5)
CreateButton(PlayerCol, "NameTagMode", "NameTag Mode", 6, "WHITE", "HP-COLOR")
CreateCombinedToggleSlider(PlayerCol, "Spinner", "SpinnerSpeed", "Player Spinner", 0, 60, 7, false)


CreatePlayerTeleporter(PlayerCol, 8) 
CreatePlayerFlinger(PlayerCol, 9) 


Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then Highlights[player]:Destroy() Highlights[player] = nil end
    if Nimbs[player] then ClearNimbFromCharacter(player.Character) Nimbs[player] = nil end
    if TeamParticles[player] then TeamParticles[player]:Destroy() TeamParticles[player] = nil end
    if NameTags[player] then NameTags[player]:Destroy() NameTags[player] = nil end
end)
