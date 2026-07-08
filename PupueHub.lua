task.spawn(function()
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "PupueScript",
            Text = "Скрипт успешно запущен!",
            Icon = "rbxassetid://11954318818",
            Duration = 5
        })
    end)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
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


local PupueGui = Instance.new("ScreenGui")
PupueGui.Name = "PupueVisualsV3_Fixed"
PupueGui.ResetOnSpawn = false
PupueGui.Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui


local WaypointFolder = Instance.new("Folder")
WaypointFolder.Name = "PupueWaypoints"
WaypointFolder.Parent = PupueGui


local MainContainer = Instance.new("Frame")
MainContainer.Name = "ColumnsContainer"
MainContainer.Size = UDim2.new(0, 620, 0, 340)
MainContainer.Position = UDim2.new(0.5, -310, 0.5, -170)
MainContainer.BackgroundTransparency = 1 
MainContainer.Visible = false 
MainContainer.Parent = PupueGui


local UIHorizontalLayout = Instance.new("UIListLayout")
UIHorizontalLayout.Parent = MainContainer
UIHorizontalLayout.FillDirection = Enum.FillDirection.Horizontal
UIHorizontalLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIHorizontalLayout.Padding = UDim.new(0, 12)


local Toggles = {
    AspectRatio = false,
    FOV = false,
    WorldParticles = false,
    ParticleShape = false,
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
    WaypointsActive = false
}


local Values = {
    SpeedHack = 50,
    JumpPower = 50,
    AspectRatio = 0.7,
    FOV = 90,
    EspTrans = 0.5,
    P_Rate = 0.05,
    P_Lifetime = 5.0,
    P_Size = 0.35,
    NimbSize = 1.8,
    TrailLifetime = 1.8
}


local Highlights = {}
local Nimbs = {}
local Trails = {}
local ActiveWaypoints = {}
local WaypointCounter = 0


local FlyBodyGyro, FlyBodyVelocity
local FlySpeed = 45


local MenuVisible = false


local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "MenuIsland"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0.5, -22, 0, 15)
ToggleButton.BackgroundColor3 = COLOR_BG
ToggleButton.Image = "rbxassetid://125091046073664"
ToggleButton.Visible = true 
ToggleButton.Parent = PupueGui


local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton


local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = COLOR_ACCENT
ButtonStroke.Thickness = 1.5
ButtonStroke.Parent = ToggleButton


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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        islandDragging = false
    end
end)


local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseMenuButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, 5, 0, -35) 
CloseButton.BackgroundColor3 = COLOR_BG
CloseButton.Text = "×"
CloseButton.TextColor3 = COLOR_CLOSE
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = MainContainer


local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton


local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = COLOR_CLOSE
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseButton


local function SetMenuVisible(visible)
    MenuVisible = visible
    MainContainer.Visible = MenuVisible
    ToggleButton.Visible = not MenuVisible 
end


ToggleButton.MouseButton1Click:Connect(function() SetMenuVisible(true) end)
CloseButton.MouseButton1Click:Connect(function() SetMenuVisible(false) end)


CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = COLOR_CLOSE
    CloseButton.TextColor3 = COLOR_BG
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = COLOR_BG
    CloseButton.TextColor3 = COLOR_CLOSE
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
    local ds = Instance.new("UIStroke", Dot)
    ds.Color = Color3.fromRGB(255, 255, 255)
    ds.Thickness = 1
    
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


local function ClearAllWaypoints()
    for _, wp in pairs(ActiveWaypoints) do
        if wp.Container then wp.Container:Destroy() end
    end
    ActiveWaypoints = {}
    WaypointCounter = 0
end


RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.SpeedHack then
                hum.WalkSpeed = Values.SpeedHack
            end
            if Toggles.JumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = Values.JumpPower
            end
        end
        if Toggles.Noclip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)


RunService.RenderStepped:Connect(function()
    local Camera = Workspace.CurrentCamera
    if not Camera then return end
    
    if Toggles.FOV then
        Camera.FieldOfView = Values.FOV
    else
        Camera.FieldOfView = 70
    end


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
                FlyBodyVelocity.Velocity = Camera.CFrame.LookVector * FlySpeed * moveDir.Magnitude
            else
                FlyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
        end
    end


    if Toggles.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
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
        for _, wp in pairs(ActiveWaypoints) do
            wp.Container.Visible = false
        end
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
            
            if Toggles.ParticleShape then
                part.Shape = Enum.PartType.Ball
            else
                part.Shape = Enum.PartType.Block
            end
            
            local att = Instance.new("Attachment", part)
            local vel = Instance.new("LinearVelocity", part)
            vel.Attachment0 = att
            vel.MaxForce = 9e4
            vel.VectorVelocity = Vector3.new(0, -8, 0)
            
            local spawnPos = hrp.Position + Vector3.new(0, 25, 0)
            local rOffset = Vector3.new(math.random(-45, 45), math.random(-2, 2), math.random(-45, 45))
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
                if part and part.Parent and not touchedGround then
                    part:Destroy()
                end
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
    weld1.Part0 = character.Head
    weld1.Part1 = mainRing
    weld1.C0 = CFrame.new(0, 1.1, 0) * CFrame.Angles(math.rad(90), 0, 0)
    weld1.Parent = mainRing
    
    local weld2 = Instance.new("Weld")
    weld2.Part0 = character.Head
    weld2.Part1 = innerGlow
    weld2.C0 = CFrame.new(0, 1.1, 0) * CFrame.Angles(math.rad(90), 0, 0)
    weld2.Parent = innerGlow
    
    mainRing.Parent = character
    innerGlow.Parent = character
    return mainRing
end


local function ClearNimbFromCharacter(char)
    if char then
        if char:FindFirstChild("PupueDonut") then char.PupueDonut:Destroy() end
        if char:FindFirstChild("PupueDonutGlow") then char.PupueDonutGlow:Destroy() end
    end
end


task.spawn(function()
    while task.wait(0.2) do
        if Toggles.NimbEsp then
            for _, p in pairs(Players:GetPlayers()) do
                local shouldHaveNimb = false
                if Toggles.NimbTarget then
                    shouldHaveNimb = true
                else
                    shouldHaveNimb = (p == LocalPlayer)
                end
                
                if shouldHaveNimb and p.Character and p.Character:FindFirstChild("Head") then
                    local nimb = Nimbs[p]
                    if not nimb or nimb.Parent ~= p.Character or not p.Character:FindFirstChild("PupueDonut") then
                        ClearNimbFromCharacter(p.Character)
                        Nimbs[p] = CreateDonutNimb(p.Character)
                    else
                        local d1 = p.Character:FindFirstChild("PupueDonut")
                        local d2 = p.Character:FindFirstChild("PupueDonutGlow")
                        if d1 and d1:FindFirstChildOfClass("SpecialMesh") then
                            d1:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(Values.NimbSize, Values.NimbSize, 0.2)
                        end
                        if d2 and d2:FindFirstChildOfClass("SpecialMesh") then
                            d2:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(Values.NimbSize + 0.05, Values.NimbSize + 0.05, 0.3)
                        end
                    end
                else
                    if Nimbs[p] then
                        ClearNimbFromCharacter(p.Character)
                        Nimbs[p] = nil
                    end
                end
            end
        else
            for p, n in pairs(Nimbs) do
                ClearNimbFromCharacter(p.Character)
                Nimbs[p] = nil
            end
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
                    if Toggles.EspMode then
                        hl.FillTransparency = 1
                        hl.OutlineColor = COLOR_ACCENT 
                    else
                        hl.FillTransparency = Values.EspTrans
                        hl.OutlineColor = COLOR_BG
                    end
                end
            end
        else
            for p, hl in pairs(Highlights) do
                if hl then hl:Destroy() end
                Highlights[p] = nil
            end
        end
    end
end)


function UpdateFeatures(feature)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if feature == "SpeedHack" and not Toggles.SpeedHack then
        hum.WalkSpeed = 16
    end


    if feature == "JumpPower" and not Toggles.JumpPower then
        hum.JumpPower = 50
    end


    if feature == "Fly" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if Toggles.Fly then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.P = 9e4
            FlyBodyGyro.maxTorque = Vector3.new(9e5, 9e5, 9e5)
            FlyBodyGyro.CFrame = hrp.CFrame
            FlyBodyGyro.Parent = hrp
            
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
            FlyBodyVelocity.maxForce = Vector3.new(9e5, 9e5, 9e5)
            FlyBodyVelocity.Parent = hrp
            
            hum.PlatformStand = true
        else
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
            hum.PlatformStand = false
        end
    end


    if feature == "Trails" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if Toggles.Trails and hrp then
            if Trails[LocalPlayer] and Trails[LocalPlayer][1] then
                Trails[LocalPlayer][1].Lifetime = Values.TrailLifetime
            else
                local trail = Instance.new("Trail")
                local a0 = Instance.new("Attachment", hrp)
                local a1 = Instance.new("Attachment", hrp)
                a0.Position = Vector3.new(0, 0.8, 0)
                a1.Position = Vector3.new(0, -0.8, 0)
                trail.Attachment0 = a0
                trail.Attachment1 = a1
                trail.Color = ColorSequence.new(COLOR_ACCENT)
                trail.Lifetime = Values.TrailLifetime 
                trail.Parent = hrp
                Trails[LocalPlayer] = {trail, a0, a1}
            end
        else
            if Trails[LocalPlayer] then
                for _, v in pairs(Trails[LocalPlayer]) do v:Destroy() end
                Trails[LocalPlayer] = nil
            end
        end
    end
    
    if feature == "TrailLifetime" and Toggles.Trails and Trails[LocalPlayer] and Trails[LocalPlayer][1] then
        Trails[LocalPlayer][1].Lifetime = Values.TrailLifetime
    end
end


local function CreateColumn(categoryName, layoutOrder)
    local ColumnFrame = Instance.new("Frame")
    ColumnFrame.Name = categoryName .. "Column"
    ColumnFrame.Size = UDim2.new(0, 190, 0, 320)
    ColumnFrame.BackgroundColor3 = COLOR_BG
    ColumnFrame.BorderSizePixel = 0
    ColumnFrame.LayoutOrder = layoutOrder
    ColumnFrame.Parent = MainContainer


    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 14) 
    UICorner.Parent = ColumnFrame


    local ColumnStroke = Instance.new("UIStroke")
    ColumnStroke.Color = COLOR_ACCENT
    ColumnStroke.Thickness = 1.5
    ColumnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ColumnStroke.Parent = ColumnFrame


    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = categoryName
    Title.TextColor3 = COLOR_TEXT
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = ColumnFrame


    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, 0, 1, -30)
    ContentContainer.Position = UDim2.new(0, 0, 0, 30)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.ScrollBarImageColor3 = COLOR_ACCENT
    ContentContainer.Parent = ColumnFrame


    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ContentContainer
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center


    local UIPad = Instance.new("UIPadding")
    UIPad.PaddingTop = UDim.new(0, 3)
    UIPad.Parent = ContentContainer


    local dragToggle, dragStart, startPos
    ColumnFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = MainContainer.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
    end)


    return ContentContainer
end


local function CreateButton(parentColumn, name, text, layout, altOnText, altOffText)
    local onText = altOnText or "ON"
    local offText = altOffText or "OFF"


    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 32)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8) 


    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLOR_TEXT_DARK
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left


    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 15)
    ToggleBtn.Position = UDim2.new(1, -48, 0.5, -7)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleBtn.Text = offText
    ToggleBtn.TextColor3 = COLOR_TEXT_DARK
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 8
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)


    local ClickBtn = Instance.new("TextButton", Frame)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""


    ClickBtn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        
        ToggleBtn.Text = Toggles[name] and onText or offText
        ToggleBtn.BackgroundColor3 = Toggles[name] and COLOR_ACCENT or Color3.fromRGB(45, 45, 55)
        ToggleBtn.TextColor3 = Toggles[name] and Color3.fromRGB(20,20,20) or COLOR_TEXT_DARK
        Label.TextColor3 = Toggles[name] and COLOR_TEXT or COLOR_TEXT_DARK
        
        UpdateFeatures(name)
    end)
end


local function CreateActionClickable(parentColumn, text, layout, clickCallback)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 32)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)


    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -16, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLOR_ACCENT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Center


    local ClickBtn = Instance.new("TextButton", Frame)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.MouseButton1Click:Connect(clickCallback)
end


local function CreateSlider(parentColumn, name, text, min, max, isFloat, layout, customToggle)
    local Frame = Instance.new("Frame", parentColumn)
    Frame.Size = UDim2.new(0.92, 0, 0, 46)
    Frame.BackgroundColor3 = COLOR_FRAME
    Frame.LayoutOrder = layout
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8) 


    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 8, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(Values[name])
    Label.TextColor3 = COLOR_TEXT
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left


    local ToggleBtn
    if not customToggle then
        ToggleBtn = Instance.new("TextButton", Frame)
        ToggleBtn.Size = UDim2.new(0, 30, 0, 15)
        ToggleBtn.Position = UDim2.new(1, -38, 0, 4)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = COLOR_TEXT_DARK
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 8
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)
        
        ToggleBtn.MouseButton1Click:Connect(function()
            Toggles[name] = not Toggles[name]
            ToggleBtn.Text = Toggles[name] and "ON" or "OFF"
            ToggleBtn.BackgroundColor3 = Toggles[name] and COLOR_ACCENT or Color3.fromRGB(45, 45, 55)
            ToggleBtn.TextColor3 = Toggles[name] and Color3.fromRGB(20,20,20) or COLOR_TEXT_DARK
            UpdateFeatures(name)
        end)
    end


    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(0.9, 0, 0, 4)
    Track.Position = UDim2.new(0.05, 0, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)


    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((Values[name] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = COLOR_ACCENT
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)


    local DragBtn = Instance.new("TextButton", Track)
    DragBtn.Size = UDim2.new(1, 0, 1, 0)
    DragBtn.BackgroundTransparency = 1
    DragBtn.Text = ""


    local ActiveInput = false


    local function UpdateSlider()
        if not Track or not Track.Parent then return end
        local absolutePosition = Track.AbsolutePosition
        local absoluteSize = Track.AbsoluteSize
        local inputLocation = UserInputService:GetMouseLocation()
        
        local percentage = math.clamp((inputLocation.X - absolutePosition.X) / absoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        
        local rawValue = min + (max - min) * percentage
        local finalValue = isFloat and math.floor(rawValue * 100) / 100 or math.floor(rawValue)
        
        Values[name] = finalValue
        Label.Text = text .. ": " .. tostring(finalValue)
        
        UpdateFeatures(name)
    end


    DragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveInput = true
            UpdateSlider()
        end
    end)


    UserInputService.InputChanged:Connect(function(input)
        if ActiveInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider()
        end
    end)


    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveInput = false
        end
    end)
end


local VisualCol = CreateColumn("Visuals", 1)
local MovementCol = CreateColumn("Movement", 2)
local PlayerCol = CreateColumn("Player", 3)


CreateSlider(VisualCol, "AspectRatio", "Aspect Ratio", 0.2, 1.5, true, 1)
CreateSlider(VisualCol, "FOV", "Field of View", 30, 120, false, 2)
CreateButton(VisualCol, "WorldParticles", "World Particles", 3)
CreateButton(VisualCol, "ParticleShape", "Particle Shape", 4, "SPHERE", "CUBE")
CreateSlider(VisualCol, "P_Rate", "Particles Rate", 0.01, 0.3, true, 5, true)
CreateSlider(VisualCol, "P_Lifetime", "Particles Lifetime", 0.2, 10.0, true, 6, true)
CreateSlider(VisualCol, "P_Size", "Particles Size", 0.1, 1.5, true, 7, true)
CreateButton(VisualCol, "NimbEsp", "Donut Halo ESP", 8)
CreateButton(VisualCol, "NimbTarget", "Halo Target", 9, "ALL", "ONLY ME") 
CreateSlider(VisualCol, "NimbSize", "Halo Size", 0.5, 5.0, true, 10, true) 
CreateButton(VisualCol, "Fullbright", "Fullbright Mode", 11)
CreateButton(VisualCol, "WaypointsActive", "Show Waypoints", 12)
CreateActionClickable(VisualCol, "Add Waypoint", 13, AddWaypointAtCurrentPosition)
CreateActionClickable(VisualCol, "Clear Waypoints", 14, ClearAllWaypoints)


CreateSlider(MovementCol, "SpeedHack", "Speed Hack", 16, 150, false, 1)
CreateSlider(MovementCol, "JumpPower", "Jump Power", 50, 120, false, 2)
CreateButton(MovementCol, "Fly", "Fly Mode (Mobile)", 3)
CreateButton(MovementCol, "Noclip", "Noclip Mode", 4)


CreateButton(PlayerCol, "PlayerEsp", "Highlight ESP", 1)
CreateButton(PlayerCol, "EspMode", "ESP Mode", 2, "OUTLINE", "FULL") 
CreateSlider(PlayerCol, "EspTrans", "ESP Transparency", 0, 1, true, 3, true) 
CreateButton(PlayerCol, "Trails", "Player Trails", 4)
CreateSlider(PlayerCol, "TrailLifetime", "Trail Length", 0.1, 5.0, true, 5, true)


LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Toggles.Fly then Toggles.Fly = false UpdateFeatures("Fly") end
end)


Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then Highlights[player]:Destroy() Highlights[player] = nil end
    if Nimbs[player] then 
        ClearNimbFromCharacter(player.Character)
        Nimbs[player] = nil 
    end
end)
