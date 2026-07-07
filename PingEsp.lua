local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local box = Instance.new("Part")
box.Size = Vector3.new(4, 5, 2)
box.Transparency = 0.6
box.CanCollide = false
box.Anchored = true
box.CastShadow = false
box.Parent = workspace

RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        local ping = player:GetNetworkPing() * 1000
        box.Color = ping <= 150 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        local velocity = root.AssemblyLinearVelocity
        local serverPosition = root.Position - (velocity * (ping / 1000))
        
        box.CFrame = CFrame.new(serverPosition) * root.CFrame.Rotation
    end
end)
