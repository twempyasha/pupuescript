local Configuration = {
    Enabled = true,
    Parts = {
        'HumanoidRootPart', 'Head', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg',
        'LeftUpperArm', 'RightUpperArm', 'LeftLowerArm', 'RightLowerArm',
        'LeftHand', 'RightHand', 'LeftUpperLeg', 'RightUpperLeg',
        'LeftLowerLeg', 'RightLowerLeg', 'LeftFoot', 'RightFoot'
    },
    Timing = {
        MinDelay = 0.02,
        MaxDelay = 0.12,
        MaxDistance = 6,
        PingSmoothing = 0.12,
        DefaultPing = 120
    },
    Visual = {
        BaseColor = Color3.fromRGB(0, 100, 255),
        ActionColor = Color3.fromRGB(0, 255, 220),
        BaseThickness = 0.04
    }
}

local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local Stats = game:GetService('Stats')

local LocalPlayer = Players.LocalPlayer
LocalPlayer.Archivable = true

local GhostManager = {
    Parts = {},
    FrameHistory = {},
    Character = nil
}

function GhostManager:InitializeGhostPart(originalPart)
    local ghostPart = Instance.new('Part')
    ghostPart.Name = originalPart.Name .. '_Ghost'
    ghostPart.Size = originalPart.Size
    ghostPart.Anchored = true
    ghostPart.CanCollide = false
    ghostPart.Transparency = 1
    ghostPart.CFrame = originalPart.CFrame
    ghostPart.Parent = workspace

    local selectionBox = Instance.new('SelectionBox')
    selectionBox.Adornee = ghostPart
    selectionBox.LineThickness = Configuration.Visual.BaseThickness
    selectionBox.Parent = ghostPart

    return {
        Original = originalPart,
        Ghost = ghostPart,
        Box = selectionBox
    }
end

function GhostManager:CalculateCurrentPing()
    local networkStats = Stats.Network
    if not networkStats then return Configuration.Timing.DefaultPing end
    
    local pingStat = networkStats.ServerStatsItem['Data Ping'] or networkStats.ServerStatsItem['Data Ping (ms)']
    if not pingStat then return Configuration.Timing.DefaultPing end
    
    return tonumber(pingStat:GetValue()) or Configuration.Timing.DefaultPing
end

function GhostManager:ApplyDynamicEffects(selectionBox, velocity)
    local speed = velocity.Magnitude
    local clock = os.clock()
    local activityFactor = math.clamp(speed / 16, 0, 1) 
    
    selectionBox.Color3 = Configuration.Visual.BaseColor:Lerp(Configuration.Visual.ActionColor, activityFactor)
    
    local glitchNoise = math.sin(clock * 45) * 0.15 * activityFactor
    local baseTransparency = 0.3 + (1 - activityFactor) * 0.4
    
    selectionBox.Transparency = math.clamp(baseTransparency + glitchNoise, 0.1, 0.9)
    selectionBox.LineThickness = Configuration.Visual.BaseThickness + (activityFactor * 0.02)
end

function GhostManager:InitializeCharacter()
    self.Character = LocalPlayer.Character
    if not self.Character then return end

    self:CleanupExistingGhosts()

    local rootPart = self.Character:FindFirstChild('HumanoidRootPart')
    if not rootPart then return end

    self.Parts = {}
    for _, partName in ipairs(Configuration.Parts) do
        local characterPart = self.Character:FindFirstChild(partName)
        if characterPart and characterPart:IsA('BasePart') then
            self.Parts[partName] = self:InitializeGhostPart(characterPart)
        end
    end
end

function GhostManager:CleanupExistingGhosts()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA('Part') and child.Name:match('_Ghost$') then
            child:Destroy()
        end
    end
end

function GhostManager:CaptureFrameData()
    if not self.Character then return end
    
    local rootPart = self.Character:FindFirstChild('HumanoidRootPart')
    if not rootPart then return end

    local relativeTransforms = {}
    for partName, ghostData in pairs(self.Parts) do
        if ghostData.Original and ghostData.Original.Parent then
            relativeTransforms[partName] = rootPart.CFrame:ToObjectSpace(ghostData.Original.CFrame)
        end
    end

    table.insert(self.FrameHistory, {
        Timestamp = os.clock(),
        Transform = rootPart.CFrame,
        Position = rootPart.Position,
        Velocity = rootPart.Velocity,
        RelativeTransforms = relativeTransforms
    })

    if #self.FrameHistory > 200 then
        table.remove(self.FrameHistory, 1)
    end
end

function GhostManager:UpdateGhostParts(deltaTime)
    if not self.Character then return end
    
    local rootPart = self.Character:FindFirstChild('HumanoidRootPart')
    if not rootPart then return end

    local currentPing = self:CalculateCurrentPing()
    Configuration.Timing.DefaultPing = currentPing * Configuration.Timing.PingSmoothing + 
                                      Configuration.Timing.DefaultPing * (1 - Configuration.Timing.PingSmoothing)

    local targetDelay = math.clamp(Configuration.Timing.DefaultPing / 2000, 
                                 Configuration.Timing.MinDelay, 
                                 Configuration.Timing.MaxDelay)

    local targetFrame = self:FindTargetFrame(os.clock() - targetDelay)
    if not targetFrame then return end

    local timeDifference = math.clamp(os.clock() - targetFrame.Timestamp, 0, 0.06)
    local predictedPosition = targetFrame.Position + targetFrame.Velocity * timeDifference * 0.9
    local predictedTransform = CFrame.new(predictedPosition) * (targetFrame.Transform - targetFrame.Transform.Position)

    local stabilityFactor = math.clamp(1 - math.abs(currentPing - Configuration.Timing.DefaultPing) / 300, 0.25, 1)

    for partName, ghostData in pairs(self.Parts) do
        self:UpdateSingleGhostPart(ghostData, targetFrame, predictedTransform, deltaTime, stabilityFactor)
    end
end

function GhostManager:FindTargetFrame(targetTime)
    for index = #self.FrameHistory, 1, -1 do
        if self.FrameHistory[index].Timestamp <= targetTime then
            return self.FrameHistory[index]
        end
    end
    return self.FrameHistory[1]
end

function GhostManager:UpdateSingleGhostPart(ghostData, targetFrame, predictedTransform, deltaTime, stability)
    local ghostPart = ghostData.Ghost
    local selectionBox = ghostData.Box
    if not ghostPart then return end

    local relativeTransform = targetFrame.RelativeTransforms[ghostData.Original.Name]
    local targetCFrame = relativeTransform and predictedTransform * relativeTransform or 
                        (ghostData.Original and ghostData.Original.CFrame or ghostPart.CFrame)

    local positionOffset = (targetCFrame.Position - predictedTransform.Position).Magnitude
    if positionOffset > Configuration.Timing.MaxDistance then
        local direction = (targetCFrame.Position - predictedTransform.Position).Unit
        local rotationX, rotationY, rotationZ = targetCFrame:ToEulerAnglesXYZ()
        targetCFrame = CFrame.new(predictedTransform.Position + direction * Configuration.Timing.MaxDistance) * CFrame.Angles(rotationX, rotationY, rotationZ)
    end

    local interpolationWeight = math.clamp(deltaTime * 20 * stability, 0, 1)
    ghostPart.CFrame = ghostPart.CFrame:Lerp(targetCFrame, interpolationWeight)
    
    self:ApplyDynamicEffects(selectionBox, targetFrame.Velocity)
end

GhostManager:InitializeCharacter()

RunService.Heartbeat:Connect(function(deltaTime)
    GhostManager:CaptureFrameData()
    GhostManager:UpdateGhostParts(deltaTime)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    GhostManager:InitializeCharacter()
end)
