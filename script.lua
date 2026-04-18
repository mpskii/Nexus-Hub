# 🌐 Nexus Hub - Football Fusion 3 Script Hub

```lua
-- ═══════════════════════════════════════════════════════════════
-- 📦 CORE DEPENDENCIES & INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- 🎨 THEME CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local Theme = {
    Primary = Color3.fromRGB(0, 0, 0),        -- Black
    Secondary = Color3.fromRGB(220, 20, 60),  -- Crimson Red
    Accent = Color3.fromRGB(255, 255, 255),   -- White
    Dark = Color3.fromRGB(15, 15, 15),        -- Dark Background
    Hover = Color3.fromRGB(30, 30, 30),       -- Hover State
    Border = Color3.fromRGB(50, 50, 50),      -- Border Color
}

-- ═══════════════════════════════════════════════════════════════
-- 💾 CONFIGURATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

local Config = {
    -- Catching Settings
    AutoCatch = false,
    AutoMoss = false,
    AutoJumpCatch = false,
    AutoDiveCatch = false,
    SmartCatch = false,
    CatchMode = "Legit",
    CatchDistance = 10.0,
    CatchDelay = 0.1,
    CatchAccuracy = 80,
    ClosestBallCatch = false,
    AirCatchOnly = false,
    ReachAssist = false,

    -- Magnet Settings
    BallMagnet = false,
    CatchMagnet = false,
    MagnetDistance = 15.0,
    MagnetStrength = 5,
    MagnetSmoothness = 0.5,
    OnlyAirBall = false,
    TeamCheck = true,
    MagnetMode = "Legit",

    -- QB Settings
    QBAimbot = false,
    AutoThrowAssist = false,
    SilentAim = false,
    ThrowPower = 50,
    PredictionAmount = 2.5,
    TargetMode = "Closest",
    ReceiverLock = false,
    AutoAngle = false,

    -- Defense Settings
    AutoIntercept = false,
    AutoJumpIntercept = false,
    AutoSwat = false,
    InterceptDistance = 10.0,
    InterceptDelay = 0.1,
    InterceptMode = "Legit",
    ClosestBallIntercept = false,

    -- Movement Settings
    SpeedBoost = false,
    SpeedAmount = 20,
    JumpPowerBoost = false,
    JumpPowerAmount = 75,
    InfiniteJump = false,
    NoSlowdown = false,
    AntiStamina = false,
    MovementMode = "Legit",

    -- Visual Settings
    PlayerESP = false,
    BallESP = false,
    QBHighlight = false,
    ClosestPlayerHighlight = false,
    ESPDistance = 250,
    ESPMode = "Highlight",

    -- Utility Settings
    AntiAFK = false,
    AutoRejoin = false,
    ServerHop = false,
    FPSBoost = false,
    RemoveCrowd = false,
    UIToggleKeybind = "RightShift",

    -- Advanced Settings
    Humanizer = false,
    HumanizerDelay = 0.1,
    PingBasedPrediction = false,
    SmartCatchTiming = false,
    LegitMode = false,
    BlatantMode = false,

    -- Config Settings
    CurrentSlot = "Slot 1",
    AutoLoad = false,
}

-- ═══════════════════════════════════════════════════════════════
-- 📊 STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

local State = {
    UIVisible = true,
    SelectedTab = "Catching",
    FPS = 0,
    Ping = 0,
    FrameCount = 0,
    LastFrameTime = tick(),
    Notifications = {},
}

-- ═══════════════════════════════════════════════════════════════
-- 🎯 UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function CreateTween(Object, Properties, Duration)
    local TweenInfo = TweenInfo.new(
        Duration or 0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.InOut
    )
    return TweenService:Create(Object, TweenInfo, Properties)
end

local function TweenSize(GUI, NewSize, Duration)
    CreateTween(GUI, { Size = NewSize }, Duration or 0.3):Play()
end

local function TweenPosition(GUI, NewPosition, Duration)
    CreateTween(GUI, { Position = NewPosition }, Duration or 0.3):Play()
end

local function TweenTransparency(GUI, NewTransparency, Duration)
    CreateTween(GUI, { BackgroundTransparency = NewTransparency }, Duration or 0.3):Play()
end

local function Notify(Title, Message, Duration)
    Duration = Duration or 3
    
    local NotificationData = {
        Title = Title,
        Message = Message,
        Duration = Duration,
        CreatedAt = tick()
    }
    
    table.insert(State.Notifications, NotificationData)
    
    -- Console output
    print(string.format("[%s] %s - %s", "Nexus Hub", Title, Message))
end

local function GetDistance(Part1, Part2)
    return (Part1.Position - Part2.Position).Magnitude
end

local function IsTeammate(Player)
    if not Player or not LocalPlayer then return false end
    return Player.Team == LocalPlayer.Team
end

-- ═══════════════════════════════════════════════════════════════
-- 📊 PERFORMANCE MONITORING
-- ═══════════════════════════════════════════════════════════════

local PerformanceMonitor = {}

function PerformanceMonitor:UpdateFPS()
    State.FrameCount = State.FrameCount + 1
    local CurrentTime = tick()
    
    if CurrentTime - State.LastFrameTime >= 1 then
        State.FPS = State.FrameCount
        State.FrameCount = 0
        State.LastFrameTime = CurrentTime
    end
end

function PerformanceMonitor:UpdatePing()
    State.Ping = LocalPlayer:GetNetworkPeer():GetRoundTripTime() * 1000
end

-- ═══════════════════════════════════════════════════════════════
-- 🎨 UI BUILDER MODULE
-- ═══════════════════════════════════════════════════════════════

local UIBuilder = {}

function UIBuilder:CreateFrame(Parent, Properties)
    local Frame = Instance.new("Frame")
    Frame.Parent = Parent
    Frame.BackgroundColor3 = Properties.BackgroundColor or Theme.Dark
    Frame.BorderSizePixel = 0
    Frame.Size = Properties.Size or UDim2.new(1, 0, 1, 0)
    Frame.Position = Properties.Position or UDim2.new(0, 0, 0, 0)
    Frame.ZIndex = Properties.ZIndex or 1
    
    if Properties.Rounded then
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame
    end
    
    return Frame
end

function UIBuilder:CreateLabel(Parent, Properties)
    local Label = Instance.new("TextLabel")
    Label.Parent = Parent
    Label.BackgroundTransparency = 1
    Label.Size = Properties.Size or UDim2.new(1, 0, 0, 30)
    Label.Position = Properties.Position or UDim2.new(0, 0, 0, 0)
    Label.Text = Properties.Text or ""
    Label.TextColor3 = Properties.TextColor or Theme.Accent
    Label.TextSize = Properties.TextSize or 14
    Label.Font = Properties.Font or Enum.Font.GothamBold
    Label.ZIndex = Properties.ZIndex or 1
    
    return Label
end

function UIBuilder:CreateButton(Parent, Properties)
    local Button = self:CreateFrame(Parent, {
        BackgroundColor = Properties.BackgroundColor or Theme.Secondary,
        Size = Properties.Size or UDim2.new(1, 0, 0, 40),
        Position = Properties.Position or UDim2.new(0, 0, 0, 0),
        Rounded = true,
        ZIndex = Properties.ZIndex or 1,
    })
    
    local Label = self:CreateLabel(Button, {
        Text = Properties.Text or "Button",
        TextColor = Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
    })
    Label.Size = UDim2.new(1, 0, 1, 0)
    
    local MouseEnter = false
    
    Button.MouseEnter:Connect(function()
        MouseEnter = true
        CreateTween(Button, { BackgroundColor3 = Color3.fromRGB(240, 40, 80) }, 0.2):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        MouseEnter = false
        CreateTween(Button, { BackgroundColor3 = Theme.Secondary }, 0.2):Play()
    end)
    
    Button.MouseButton1Click:Connect(Properties.OnClick or function() end)
    
    return Button
end

function UIBuilder:CreateToggle(Parent, Properties)
    local Container = self:CreateFrame(Parent, {
        BackgroundColor = Theme.Hover,
        Size = Properties.Size or UDim2.new(1, -10, 0, 45),
        Position = Properties.Position or UDim2.new(0, 5, 0, 0),
        Rounded = true,
    })
    
    local Label = self:CreateLabel(Container, {
        Text = Properties.Name or "Toggle",
        TextColor = Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
    })
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = self:CreateFrame(Container, {
        BackgroundColor = Properties.Value and Theme.Secondary or Theme.Border,
        Size = UDim2.new(0, 35, 0, 25),
        Position = UDim2.new(0.85, 0, 0.5, -12),
        Rounded = true,
    })
    
    local function UpdateToggle(Value)
        Properties.Value = Value
        CreateTween(ToggleButton, { 
            BackgroundColor3 = Value and Theme.Secondary or Theme.Border 
        }, 0.2):Play()
        
        if Properties.OnToggle then
            Properties.OnToggle(Value)
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        UpdateToggle(not Properties.Value)
    end)
    
    Container.MouseButton1Click:Connect(function()
        UpdateToggle(not Properties.Value)
    end)
    
    return Container, ToggleButton
end

function UIBuilder:CreateSlider(Parent, Properties)
    local Container = self:CreateFrame(Parent, {
        BackgroundColor = Theme.Hover,
        Size = Properties.Size or UDim2.new(1, -10, 0, 60),
        Position = Properties.Position or UDim2.new(0, 5, 0, 0),
        Rounded = true,
    })
    
    local Label = self:CreateLabel(Container, {
        Text = string.format("%s: %.1f", Properties.Name or "Slider", Properties.Value or 0),
        TextColor = Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
    })
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 5)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Track = self:CreateFrame(Container, {
        BackgroundColor = Theme.Border,
        Size = UDim2.new(1, -10, 0, 5),
        Position = UDim2.new(0, 5, 0, 30),
        Rounded = true,
    })
    
    local Thumb = self:CreateFrame(Container, {
        BackgroundColor = Theme.Secondary,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 5, 0, 25),
        Rounded = true,
    })
    
    local function UpdateSliderValue(InputX)
        local TrackAbsSize = Track.AbsoluteSize.X
        local ClickX = InputX - Track.AbsolutePosition.X
        local Percentage = math.clamp(ClickX / TrackAbsSize, 0, 1)
        
        local Range = Properties.Max - Properties.Min
        local NewValue = Properties.Min + (Percentage * Range)
        
        Properties.Value = NewValue
        Label.Text = string.format("%s: %.1f", Properties.Name or "Slider", NewValue)
        
        local ThumbPosition = Percentage * (TrackAbsSize - 12)
        Thumb.Position = UDim2.new(0, 5 + ThumbPosition, 0, 25)
        
        if Properties.OnChanged then
            Properties.OnChanged(NewValue)
        end
    end
    
    Track.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.UserInputType == Enum.UserInputType.MouseButton
