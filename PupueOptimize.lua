local DefaultConfig = {
    OPTIZ = true,
    OPTIMIZATION_INTERVAL = 10,
    MIN_INTERVAL = 3,
    MAX_DISTANCE = 50,
    PERFORMANCE_MONITORING = true,
    FPS_MONITOR = true,
    FPS_THRESHOLD = 30,
    GRAY_SKY_ENABLED = true,
    GRAY_SKY_ID = "rbxassetid://114666145996289",
    FULL_BRIGHT_ENABLED = true,
    SMOOTH_PLASTIC_ENABLED = true,
    COLLISION_GROUP_NAME = "OptimizedParts",
    OPTIMIZE_PHYSICS = true,
    DISABLE_CONSTRAINTS = true,
    THROTTLE_PARTICLES = true,
    THROTTLE_TEXTURES = true,
    REMOVE_ANIMATIONS = true,
    LOW_POLY_CONVERSION = true,
    SELECTIVE_TEXTURE_REMOVAL = true,
    PRESERVE_IMPORTANT_TEXTURES = true,
    IMPORTANT_TEXTURE_KEYWORDS = {"sign", "ui", "hud", "menu", "button", "fence"},
    QUALITY_LEVEL = 1,
    FPS_CAP = 1000,
    MEMORY_CLEANUP_THRESHOLD = 500,
    NETWORK_OPTIMIZATION = true,
    REDUCE_REPLICATION = true,
    THROTTLE_REMOTE_EVENTS = true,
    OPTIMIZE_CHAT = true,
    DISABLE_UNNECESSARY_GUI = true,
    STREAMING_ENABLED = true,
    REDUCE_PLAYER_REPLICATION_DISTANCE = 100,
    THROTTLE_SOUNDS = true,
    DESTROY_EMITTERS = true,
    REMOVE_GRASS = true,
    CORE = true,
}

local function Main(ExternalConfig)
    local Config = table.clone(DefaultConfig)
    if ExternalConfig and type(ExternalConfig) == "table" then
        for key, value in pairs(ExternalConfig) do
            if Config[key] ~= nil then
                Config[key] = value
            end
        end
    end

    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local GuiService = game:GetService("GuiService")
    local LocalPlayer = Players.LocalPlayer

    local function safeCall(func, name, ...)
        local success, err = pcall(func, ...)
        return success
    end

    local Running = true

    local function setSmoothPlastic()
        if not Config.SMOOTH_PLASTIC_ENABLED then return end
        local function handleInstance(instance)
            if LocalPlayer and LocalPlayer.Character and instance:IsDescendantOf(LocalPlayer.Character) then 
                return 
            end
            if instance:IsA("BasePart") then
                instance.Material = Enum.Material.SmoothPlastic
                instance.Reflectance = 0
            elseif instance:IsA("Texture") or instance:IsA("Decal") then
                instance.Transparency = 1
            end
        end
        for _, instance in ipairs(workspace:GetDescendants()) do
            handleInstance(instance)
        end
        workspace.DescendantAdded:Connect(handleInstance)
    end

    local function applyFullBright()
        if not Config.FULL_BRIGHT_ENABLED then return end
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 14
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    local function applyGraySky()
        if not Config.GRAY_SKY_ENABLED then return end
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        sky.SkyboxBk = Config.GRAY_SKY_ID
        sky.SkyboxDn = Config.GRAY_SKY_ID
        sky.SkyboxFt = Config.GRAY_SKY_ID
        sky.SkyboxLf = Config.GRAY_SKY_ID
        sky.SkyboxRt = Config.GRAY_SKY_ID
        sky.SkyboxUp = Config.GRAY_SKY_ID
    end

    local function optimizeNetworkSettings()
        if not Config.NETWORK_OPTIMIZATION then return end
        settings().Network.StreamingEnabled = Config.STREAMING_ENABLED
    end

    local function reduceReplication()
        if not Config.REDUCE_REPLICATION then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored then
                pcall(function() obj:SetNetworkOwner(nil) end)
            end
        end
    end

    local function throttleRemoteEvents()
        if not Config.THROTTLE_REMOTE_EVENTS then return end
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            end
        end
    end

    local function applyAllOptimizations()
        if not Config.OPTIZ then return end
        safeCall(setSmoothPlastic, "SmoothPlastic")
        safeCall(applyFullBright, "FullBright")
        safeCall(applyGraySky, "GraySky")
        safeCall(optimizeNetworkSettings, "NetworkSettings")
        safeCall(reduceReplication, "Replication")
        safeCall(throttleRemoteEvents, "RemoteEvents")
    end

    applyAllOptimizations()

    task.spawn(function()
        while Running do
            safeCall(applyAllOptimizations, "LoopOptimizations")
            task.wait(Config.OPTIMIZATION_INTERVAL)
        end
    end)

    return {
        Config = Config,
        stopOptimizations = function() Running = false end,
        applyOptimizations = applyAllOptimizations
    }
end

return Main
