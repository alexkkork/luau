--[[
╔═══════════════════════════════════════════════════════════════════════════════╗
║   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗██╗   ██╗██╗                     ║
║   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝██║   ██║██║                     ║
║   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗██║   ██║██║                     ║
║   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║██║   ██║██║                     ║
║   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║╚██████╔╝██║                     ║
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝                     ║
║   NexusUI - Premium UI Library for Roblox Executors | v1.0.0                  ║
╚═══════════════════════════════════════════════════════════════════════════════╝
--]]

local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.Version = "1.0.0"

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Theme System
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(60, 130, 255),
        Secondary = Color3.fromRGB(45, 45, 50),
        Background = Color3.fromRGB(25, 25, 30),
        Surface = Color3.fromRGB(35, 35, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(60, 130, 255),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Light = {
        Primary = Color3.fromRGB(59, 130, 246),
        Secondary = Color3.fromRGB(229, 231, 235),
        Background = Color3.fromRGB(255, 255, 255),
        Surface = Color3.fromRGB(243, 244, 246),
        Text = Color3.fromRGB(17, 24, 39),
        TextSecondary = Color3.fromRGB(107, 114, 128),
        Accent = Color3.fromRGB(59, 130, 246),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Ocean = {
        Primary = Color3.fromRGB(6, 182, 212),
        Secondary = Color3.fromRGB(30, 41, 59),
        Background = Color3.fromRGB(15, 23, 42),
        Surface = Color3.fromRGB(30, 41, 59),
        Text = Color3.fromRGB(248, 250, 252),
        TextSecondary = Color3.fromRGB(148, 163, 184),
        Accent = Color3.fromRGB(6, 182, 212),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Cyberpunk = {
        Primary = Color3.fromRGB(236, 72, 153),
        Secondary = Color3.fromRGB(30, 30, 40),
        Background = Color3.fromRGB(13, 13, 20),
        Surface = Color3.fromRGB(25, 25, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(168, 162, 158),
        Accent = Color3.fromRGB(139, 92, 246),
        Success = Color3.fromRGB(16, 185, 129),
        Warning = Color3.fromRGB(245, 158, 11),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Neon = {
        Primary = Color3.fromRGB(0, 255, 136),
        Secondary = Color3.fromRGB(20, 20, 30),
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(20, 20, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(0, 255, 255),
        Success = Color3.fromRGB(0, 255, 136),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 85),
    },
    LiquidGlass = {
        Primary = Color3.fromRGB(100, 180, 255),
        Secondary = Color3.fromRGB(40, 40, 50),
        Background = Color3.fromRGB(20, 20, 28),
        Surface = Color3.fromRGB(30, 30, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 180, 200),
        Accent = Color3.fromRGB(130, 200, 255),
        Success = Color3.fromRGB(80, 220, 150),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 100, 100),
        Glass = true,
        GlassTransparency = 0.15,
    },
}

--// State
local State = {
    ScreenGui = nil,
    Windows = {},
    CurrentTheme = "Dark",
    Notifications = {},
    FPSEnabled = false,
}

--// Utility Functions
local function GetTheme()
    return Themes[State.CurrentTheme] or Themes.Dark
end

local function Tween(instance, props, duration, style, direction)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 70)
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

--// ScreenGui Creation
local function CreateScreenGui()
    if State.ScreenGui then return State.ScreenGui end
    
    local gui
    local success = pcall(function()
        gui = Instance.new("ScreenGui")
        gui.Name = "NexusUI"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        gui = Instance.new("ScreenGui")
        gui.Name = "NexusUI"
        gui.ResetOnSpawn = false
        gui.Parent = PlayerGui
    end
    
    State.ScreenGui = gui
    return gui
end

--// Window Class
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    local theme = GetTheme()
    
    config = config or {}
    self.Title = config.Title or "NexusUI Window"
    self.Size = config.Size or UDim2.new(0, 550, 0, 400)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true
    self.Minimized = false
    
    local gui = CreateScreenGui()
    
    -- Main Frame
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "Window"
    self.Frame.Size = self.Size
    self.Frame.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Frame.BackgroundColor3 = theme.Background
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = gui
    
    CreateCorner(self.Frame, 10)
    CreateStroke(self.Frame, Color3.fromRGB(50, 50, 60), 1)
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 5)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = self.Frame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = theme.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.Frame
    
    CreateCorner(titleBar, 10)
    
    -- Fix bottom corners of title bar
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 10)
    titleFix.Position = UDim2.new(0, 0, 1, -10)
    titleFix.BackgroundColor3 = theme.Surface
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = theme.Text
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    CreateCorner(closeBtn, 15)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 70, 60)}, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 95, 87)}, 0.1)
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0.5, 0)
    minBtn.AnchorPoint = Vector2.new(0, 0.5)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    minBtn.BorderSizePixel = 0
    minBtn.Text = ""
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    CreateCorner(minBtn, 15)
    
    minBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    -- Dragging
    local dragging, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab Container
    self.TabBar = Instance.new("Frame")
    self.TabBar.Name = "TabBar"
    self.TabBar.Size = UDim2.new(0, 130, 1, -44)
    self.TabBar.Position = UDim2.new(0, 4, 0, 40)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Parent = self.Frame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.TabBar
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 4)
    tabPadding.PaddingLeft = UDim.new(0, 4)
    tabPadding.Parent = self.TabBar
    
    -- Content Container
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -142, 1, -48)
    self.Content.Position = UDim2.new(0, 138, 0, 44)
    self.Content.BackgroundColor3 = theme.Surface
    self.Content.BorderSizePixel = 0
    self.Content.ClipsDescendants = true
    self.Content.Parent = self.Frame
    
    CreateCorner(self.Content, 8)
    
    table.insert(State.Windows, self)
    return self
end

function Window:AddTab(config)
    config = config or {}
    local theme = GetTheme()
    
    local tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon,
        Elements = {},
    }
    
    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tab.Name
    btn.Size = UDim2.new(1, -8, 0, 32)
    btn.BackgroundColor3 = theme.Secondary
    btn.BorderSizePixel = 0
    btn.Text = "  " .. tab.Name
    btn.TextColor3 = theme.TextSecondary
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = self.TabBar
    
    CreateCorner(btn, 6)
    
    tab.Button = btn
    
    -- Tab Content
    local frame = Instance.new("ScrollingFrame")
    frame.Name = "Content_" .. tab.Name
    frame.Size = UDim2.new(1, -16, 1, -16)
    frame.Position = UDim2.new(0, 8, 0, 8)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = theme.Primary
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    frame.Parent = self.Content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame
    
    tab.Frame = frame
    
    -- Add Element Methods
    function tab:AddButton(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = theme.Primary
        button.BorderSizePixel = 0
        button.Text = cfg.Text or "Button"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = false
        button.Parent = frame
        
        CreateCorner(button, 6)
        
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = Color3.new(
                math.min(1, theme.Primary.R * 1.1),
                math.min(1, theme.Primary.G * 1.1),
                math.min(1, theme.Primary.B * 1.1)
            )}, 0.15)
        end)
        
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundColor3 = theme.Primary}, 0.15)
        end)
        
        button.MouseButton1Click:Connect(function()
            if cfg.Callback then
                cfg.Callback()
            end
        end)
        
        return button
    end
    
    function tab:AddToggle(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        local enabled = cfg.Default or false
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Toggle"
        label.TextColor3 = theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 44, 0, 24)
        toggleBg.Position = UDim2.new(1, -44, 0.5, 0)
        toggleBg.AnchorPoint = Vector2.new(0, 0.5)
        toggleBg.BackgroundColor3 = enabled and theme.Primary or theme.Secondary
        toggleBg.BorderSizePixel = 0
        toggleBg.Parent = container
        
        CreateCorner(toggleBg, 12)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 18, 0, 18)
        circle.Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        circle.AnchorPoint = Vector2.new(0, 0.5)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = toggleBg
        
        CreateCorner(circle, 9)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = container
        
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            Tween(toggleBg, {BackgroundColor3 = enabled and theme.Primary or theme.Secondary}, 0.2)
            Tween(circle, {Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
            if cfg.Callback then
                cfg.Callback(enabled)
            end
        end)
        
        return {
            SetValue = function(_, v)
                enabled = v
                toggleBg.BackgroundColor3 = enabled and theme.Primary or theme.Secondary
                circle.Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            end,
            GetValue = function() return enabled end
        }
    end
    
    function tab:AddSlider(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Slider"
        label.TextColor3 = theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, -50, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(value)
        valueLabel.TextColor3 = theme.TextSecondary
        valueLabel.TextSize = 13
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = container
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 8)
        sliderBg.Position = UDim2.new(0, 0, 0, 30)
        sliderBg.BackgroundColor3 = theme.Secondary
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = container
        
        CreateCorner(sliderBg, 4)
        
        local fill = Instance.new("Frame")
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        fill.BackgroundColor3 = theme.Primary
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        
        CreateCorner(fill, 4)
        
        local dragging = false
        
        local function update(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos + 0.5)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if cfg.Callback then
                cfg.Callback(value)
            end
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input)
            end
        end)
        
        sliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)
        
        return {
            SetValue = function(_, v)
                value = math.clamp(v, min, max)
                local p = (value - min) / (max - min)
                fill.Size = UDim2.new(p, 0, 1, 0)
                valueLabel.Text = tostring(value)
            end,
            GetValue = function() return value end
        }
    end
    
    function tab:AddDropdown(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        local options = cfg.Options or {}
        local selected = cfg.Default or (options[1] or "")
        local open = false
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = false
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Dropdown"
        label.TextColor3 = theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0.55, 0, 1, 0)
        dropBtn.Position = UDim2.new(0.45, 0, 0, 0)
        dropBtn.BackgroundColor3 = theme.Secondary
        dropBtn.BorderSizePixel = 0
        dropBtn.Text = selected .. " ▼"
        dropBtn.TextColor3 = theme.Text
        dropBtn.TextSize = 13
        dropBtn.Font = Enum.Font.Gotham
        dropBtn.AutoButtonColor = false
        dropBtn.Parent = container
        
        CreateCorner(dropBtn, 6)
        
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, 0)
        optionFrame.Position = UDim2.new(0, 0, 1, 4)
        optionFrame.BackgroundColor3 = theme.Surface
        optionFrame.BorderSizePixel = 0
        optionFrame.ClipsDescendants = true
        optionFrame.Visible = false
        optionFrame.ZIndex = 10
        optionFrame.Parent = dropBtn
        
        CreateCorner(optionFrame, 6)
        CreateStroke(optionFrame, Color3.fromRGB(50, 50, 60), 1)
        
        local optionLayout = Instance.new("UIListLayout")
        optionLayout.Padding = UDim.new(0, 2)
        optionLayout.Parent = optionFrame
        
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingTop = UDim.new(0, 4)
        optionPadding.PaddingBottom = UDim.new(0, 4)
        optionPadding.PaddingLeft = UDim.new(0, 4)
        optionPadding.PaddingRight = UDim.new(0, 4)
        optionPadding.Parent = optionFrame
        
        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = theme.Secondary
            optBtn.BackgroundTransparency = 1
            optBtn.BorderSizePixel = 0
            optBtn.Text = opt
            optBtn.TextColor3 = theme.Text
            optBtn.TextSize = 13
            optBtn.Font = Enum.Font.Gotham
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 11
            optBtn.Parent = optionFrame
            
            CreateCorner(optBtn, 4)
            
            optBtn.MouseEnter:Connect(function()
                optBtn.BackgroundTransparency = 0
            end)
            optBtn.MouseLeave:Connect(function()
                optBtn.BackgroundTransparency = 1
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                dropBtn.Text = selected .. " ▼"
                open = false
                optionFrame.Visible = false
                Tween(optionFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                if cfg.Callback then
                    cfg.Callback(selected)
                end
            end)
        end
        
        dropBtn.MouseButton1Click:Connect(function()
            open = not open
            optionFrame.Visible = true
            local targetHeight = #options * 30 + 8
            Tween(optionFrame, {Size = UDim2.new(1, 0, 0, open and targetHeight or 0)}, 0.15)
            if not open then
                task.delay(0.15, function()
                    if not open then optionFrame.Visible = false end
                end)
            end
        end)
        
        return {
            SetValue = function(_, v)
                selected = v
                dropBtn.Text = selected .. " ▼"
            end,
            GetValue = function() return selected end,
            SetOptions = function(_, newOpts)
                options = newOpts
                -- Rebuild options (simplified)
            end
        }
    end
    
    function tab:AddInput(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.35, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Input"
        label.TextColor3 = theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.6, 0, 1, 0)
        input.Position = UDim2.new(0.4, 0, 0, 0)
        input.BackgroundColor3 = theme.Secondary
        input.BorderSizePixel = 0
        input.Text = cfg.Default or ""
        input.PlaceholderText = cfg.Placeholder or "Enter text..."
        input.TextColor3 = theme.Text
        input.PlaceholderColor3 = theme.TextSecondary
        input.TextSize = 13
        input.Font = Enum.Font.Gotham
        input.ClearTextOnFocus = false
        input.Parent = container
        
        CreateCorner(input, 6)
        
        local inputPadding = Instance.new("UIPadding")
        inputPadding.PaddingLeft = UDim.new(0, 10)
        inputPadding.PaddingRight = UDim.new(0, 10)
        inputPadding.Parent = input
        
        input.FocusLost:Connect(function()
            if cfg.Callback then
                cfg.Callback(input.Text)
            end
        end)
        
        return {
            SetValue = function(_, v) input.Text = v end,
            GetValue = function() return input.Text end
        }
    end
    
    function tab:AddLabel(text)
        local theme = GetTheme()
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 24)
        label.BackgroundTransparency = 1
        label.Text = text or ""
        label.TextColor3 = theme.TextSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        return label
    end
    
    function tab:AddSection(name)
        local theme = GetTheme()
        
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 28)
        section.BackgroundTransparency = 1
        section.Parent = frame
        
        local line1 = Instance.new("Frame")
        line1.Size = UDim2.new(0.2, 0, 0, 1)
        line1.Position = UDim2.new(0, 0, 0.5, 0)
        line1.BackgroundColor3 = theme.Secondary
        line1.BorderSizePixel = 0
        line1.Parent = section
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(0.6, 0, 1, 0)
        text.Position = UDim2.new(0.2, 0, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = name or "Section"
        text.TextColor3 = theme.TextSecondary
        text.TextSize = 12
        text.Font = Enum.Font.GothamMedium
        text.Parent = section
        
        local line2 = Instance.new("Frame")
        line2.Size = UDim2.new(0.2, 0, 0, 1)
        line2.Position = UDim2.new(0.8, 0, 0.5, 0)
        line2.BackgroundColor3 = theme.Secondary
        line2.BorderSizePixel = 0
        line2.Parent = section
        
        return section
    end
    
    function tab:AddKeybind(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        local key = cfg.Default or Enum.KeyCode.Unknown
        local listening = false
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Keybind"
        label.TextColor3 = theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0.35, 0, 1, 0)
        keyBtn.Position = UDim2.new(0.65, 0, 0, 0)
        keyBtn.BackgroundColor3 = theme.Secondary
        keyBtn.BorderSizePixel = 0
        keyBtn.Text = key.Name or "None"
        keyBtn.TextColor3 = theme.Text
        keyBtn.TextSize = 13
        keyBtn.Font = Enum.Font.GothamMedium
        keyBtn.AutoButtonColor = false
        keyBtn.Parent = container
        
        CreateCorner(keyBtn, 6)
        
        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
        end)
        
        UserInputService.InputBegan:Connect(function(input, processed)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                keyBtn.Text = key.Name
                listening = false
                if cfg.ChangedCallback then
                    cfg.ChangedCallback(key)
                end
            elseif not listening and input.KeyCode == key and not processed then
                if cfg.Callback then
                    cfg.Callback()
                end
            end
        end)
        
        return {
            SetKey = function(_, k) key = k; keyBtn.Text = k.Name end,
            GetKey = function() return key end
        }
    end
    
    function tab:AddColorPicker(cfg)
        cfg = cfg or {}
        local theme = GetTheme()
        local color = cfg.Default or Color3.fromRGB(255, 255, 255)
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Color"
        label.TextColor3 = theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 60, 0, 28)
        colorBtn.Position = UDim2.new(1, -60, 0.5, 0)
        colorBtn.AnchorPoint = Vector2.new(0, 0.5)
        colorBtn.BackgroundColor3 = color
        colorBtn.BorderSizePixel = 0
        colorBtn.Text = ""
        colorBtn.AutoButtonColor = false
        colorBtn.Parent = container
        
        CreateCorner(colorBtn, 6)
        CreateStroke(colorBtn, Color3.fromRGB(60, 60, 70), 1)
        
        -- Simple color picker (click to cycle through preset colors)
        local presets = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 128, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 128, 255),
            Color3.fromRGB(128, 0, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 255, 255),
        }
        local presetIndex = 1
        
        colorBtn.MouseButton1Click:Connect(function()
            presetIndex = presetIndex % #presets + 1
            color = presets[presetIndex]
            colorBtn.BackgroundColor3 = color
            if cfg.Callback then
                cfg.Callback(color)
            end
        end)
        
        return {
            SetColor = function(_, c) color = c; colorBtn.BackgroundColor3 = c end,
            GetColor = function() return color end
        }
    end
    
    -- Tab Selection
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = theme.Secondary
            t.Button.TextColor3 = theme.TextSecondary
        end
        tab.Frame.Visible = true
        tab.Button.BackgroundColor3 = theme.Primary
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.ActiveTab = tab
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        tab.Frame.Visible = true
        btn.BackgroundColor3 = theme.Primary
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.ActiveTab = tab
    end
    
    return tab
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    local targetSize = self.Minimized and UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 36) or self.Size
    Tween(self.Frame, {Size = targetSize}, 0.3)
end

function Window:Toggle()
    self.Visible = not self.Visible
    self.Frame.Visible = self.Visible
end

function Window:Show()
    self.Visible = true
    self.Frame.Visible = true
end

function Window:Hide()
    self.Visible = false
    self.Frame.Visible = false
end

function Window:Destroy()
    self.Frame:Destroy()
    for i, w in ipairs(State.Windows) do
        if w == self then
            table.remove(State.Windows, i)
            break
        end
    end
end

--// Main API
function NexusUI:CreateWindow(config)
    return Window.new(config)
end

function NexusUI:SetTheme(themeName)
    if Themes[themeName] then
        State.CurrentTheme = themeName
    end
end

function NexusUI:Notify(config)
    config = config or {}
    local gui = CreateScreenGui()
    local theme = GetTheme()
    
    local colors = {
        Info = theme.Primary,
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error,
    }
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 280, 0, 70)
    notification.Position = UDim2.new(1, 10, 1, -80 - (#State.Notifications * 80))
    notification.BackgroundColor3 = theme.Surface
    notification.BorderSizePixel = 0
    notification.Parent = gui
    
    table.insert(State.Notifications, notification)
    
    CreateCorner(notification, 8)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -8)
    accent.Position = UDim2.new(0, 4, 0, 4)
    accent.BackgroundColor3 = colors[config.Type] or theme.Primary
    accent.BorderSizePixel = 0
    accent.Parent = notification
    CreateCorner(accent, 2)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 22)
    title.Position = UDim2.new(0, 16, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notification"
    title.TextColor3 = theme.Text
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -24, 0, 30)
    content.Position = UDim2.new(0, 16, 0, 32)
    content.BackgroundTransparency = 1
    content.Text = config.Content or config.Message or ""
    content.TextColor3 = theme.TextSecondary
    content.TextSize = 12
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.Parent = notification
    
    -- Animate in
    Tween(notification, {Position = UDim2.new(1, -290, 1, -80 - ((#State.Notifications - 1) * 80))}, 0.3, Enum.EasingStyle.Back)
    
    -- Auto dismiss
    task.delay(config.Duration or 4, function()
        Tween(notification, {Position = UDim2.new(1, 10, notification.Position.Y.Scale, notification.Position.Y.Offset)}, 0.3)
        task.wait(0.3)
        
        for i, n in ipairs(State.Notifications) do
            if n == notification then
                table.remove(State.Notifications, i)
                break
            end
        end
        notification:Destroy()
        
        -- Reposition remaining notifications
        for i, n in ipairs(State.Notifications) do
            Tween(n, {Position = UDim2.new(1, -290, 1, -80 - ((i - 1) * 80))}, 0.2)
        end
    end)
end

function NexusUI:Destroy()
    if State.ScreenGui then
        State.ScreenGui:Destroy()
        State.ScreenGui = nil
    end
    State.Windows = {}
    State.Notifications = {}
end

print("[NexusUI] Loaded successfully! Version:", NexusUI.Version)
return NexusUI
