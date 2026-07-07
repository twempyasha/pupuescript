local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

character.Archivable = true
local clone = character:Clone()
character.Archivable = false

clone.Parent = workspace
clone.Name = "ServerGhost"

for _, part in ipairs(clone:GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 0.6
        part.CastShadow = false
    elseif part:IsA("LocalScript") or part:IsA("Script") then
        part:Destroy()
    end
end

RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
    
    if root and cloneRoot then
        local ping = player:GetNetworkPing() * 1000
        local ghostColor = ping <= 150 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = ghostColor
            end
        end
        
        local velocity = root.AssemblyLinearVelocity
        local serverPosition = root.Position - (velocity * (ping / 1000))
        
        cloneRoot.CFrame = CFrame.new(serverPosition) * root.CFrame.Rotation
    end

end)
