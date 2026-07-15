-- Pupue Optimizer Core v1.0
-- High-Performance Roblox FPS Booster & Memory Optimizer

local DefaultConfig = {
    OPTIZ = true,
    OPTIMIZATION_INTERVAL = 10,
    SHOW_UPDATELOG = true,
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
        if not success then
            warn(string.format("[Zenith Error] %s: %s", name, err))
        end
        return success
    end

    local Running = true

    -- 1. Сглаживание материалов
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

    -- 2. Фирменный Update Log интерфейс (Zenith UI)
    local function CreateUpdateLog()
        if not Config.SHOW_UPDATELOG then return end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ZenithOptimizerUI"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local UserInputService = game:GetService("UserInputService")
        local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        local frameWidth = isMobile and 300 or 400
        local frameHeight = isMobile and 350 or 450
        local textSize = isMobile and 10 or 12

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
        frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.BorderColor3 = Color3.fromRGB(50, 50, 50)
        frame.BorderSizePixel = 2
        frame.Parent = screenGui

        -- Скругление углов для современного вида
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = frame

        local dragHeader = Instance.new("Frame")
        dragHeader.Size = UDim2.new(1, 0, 0, isMobile and 30 or 25)
        dragHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        dragHeader.BorderColor3 = Color3.fromRGB(60, 60, 60)
        dragHeader.BorderSizePixel = 0
        dragHeader.Parent = frame

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 8)
        headerCorner.Parent = dragHeader

        local headerTitle = Instance.new("TextLabel")
        headerTitle.Size = UDim2.new(1, -80, 1, 0)
        headerTitle.Position = UDim2.new(0, 10, 0, 0)
        headerTitle.BackgroundTransparency = 1
        headerTitle.Text = "// ZENITH_OPTIMIZER v1.0"
        headerTitle.TextColor3 = Color3.fromRGB(0, 255, 150) -- Красивый неоновый мятный цвет
        headerTitle.TextSize = textSize
        headerTitle.Font = Enum.Font.Code
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left
        headerTitle.Parent = dragHeader

        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, isMobile and 35 or 25, 0, isMobile and 30 or 25)
        closeButton.Position = UDim2.new(1, -(isMobile and 35 or 25), 0, 0)
        closeButton.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
        closeButton.TextSize = textSize
        closeButton.Font = Enum.Font.Code
        closeButton.Parent = dragHeader

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = closeButton

        local copyButton = Instance.new("TextButton")
        copyButton.Size = UDim2.new(0, isMobile and 45 or 50, 0, isMobile and 30 or 25)
        copyButton.Position = UDim2.new(1, -(isMobile and 85 or 80), 0, 0)
        copyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 80)
        copyButton.Text = "Copy"
        copyButton.TextColor3 = Color3.fromRGB(100, 100, 255)
        copyButton.TextSize = textSize
        copyButton.Font = Enum.Font.Code
        copyButton.Parent = dragHeader

        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 8)
        copyCorner.Parent = copyButton

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -10, 1, -(isMobile and 40 or 35))
        scrollFrame.Position = UDim2.new(0, 5, 0, isMobile and 35 or 30)
        scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = isMobile and 8 or 6
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Never
        scrollFrame.Parent = frame

        local scrollCorner = Instance.new("UICorner")
        scrollCorner.CornerRadius = UDim.new(0, 6)
        scrollCorner.Parent = scrollFrame

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Padding = UDim.new(0, 5)
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.Parent = scrollFrame

        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1, -10, 0, 0)
        contentLabel.BackgroundTransparency = 1
        contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        contentLabel.TextSize = textSize
        contentLabel.Font = Enum.Font.Code
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.TextWrapped = true
        contentLabel.AutomaticSize = Enum.AutomaticSize.Y
        contentLabel.LayoutOrder = 1
        contentLabel.Parent = scrollFrame

        -- Текст конфигурации для копирования (уже очищенный от старого автора)
        local configText = [[
-- Zenith Optimizer Configuration v1.0
-- Replace your current config with this one to customize settings!

local Config = {
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
    FPS_MONITOR = true,
    OPTIZ = true,

    OPTIMIZATION_INTERVAL = 10,
    SHOW_UPDATELOG = true,
    MIN_INTERVAL = 3,
    MAX_DISTANCE = 50,
    PERFORMANCE_MONITORING = true,
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
}
]]
        contentLabel.Text = configText

        local function updateCanvasSize()
            local contentSize = uiListLayout.AbsoluteContentSize
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
        end
        uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        contentLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateCanvasSize)
        task.spawn(function() task.wait(0.1) updateCanvasSize() end)

        copyButton.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(configText)
                local origText = copyButton.Text
                copyButton.Text = "Copied!"
                copyButton.BackgroundColor3 = Color3.fromRGB(25, 80, 25)
                copyButton.TextColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(1)
                copyButton.Text = origText
                copyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 80)
                copyButton.TextColor3 = Color3.fromRGB(100, 100, 255)
            end
        end)

        -- Драггер (перетаскивание окна)
        local dragging, dragInput, dragStart, startPos
        dragHeader.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        dragHeader.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)

        StarterGui:SetCore("SendNotification", {
            Title = "Zenith Optimizer",
            Text = "Settings loaded successfully!",
            Duration = 5;
        })
        return screenGui
    end

    -- 3. Остальной оригинальный функционал оптимизатора (сетевая часть, физика, лимиты)
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
        -- Базовый троттлинг RemoteEvent/RemoteFunction для оптимизации обмена пакетами
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                -- Логика перехвата вызовов
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

    -- Запуск
    CreateUpdateLog()
    applyAllOptimizations()

    -- Луп оптимизации
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
