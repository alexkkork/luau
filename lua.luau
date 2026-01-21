--[[
    NexusUI - Premium UI Library
    Version: 1.0.0
    A complete, working UI library for Roblox executors
]]

local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.Version = "1.0.0"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Themes
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(60, 130, 255),
        Secondary = Color3.fromRGB(45, 45, 50),
        Background = Color3.fromRGB(25, 25, 30),
        Surface = Color3.fromRGB(35, 35, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 180),
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
        TextDim = Color3.fromRGB(107, 114, 128),
        Accent = Color3.fromRGB(59, 130, 246),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Midnight = {
        Primary = Color3.fromRGB(99, 102, 241),
        Secondary = Color3.fromRGB(30, 30, 46),
        Background = Color3.fromRGB(17, 17, 27),
        Surface = Color3.fromRGB(24, 24, 37),
        Text = Color3.fromRGB(205, 214, 244),
        TextDim = Color3.fromRGB(147, 153, 178),
        Accent = Color3.fromRGB(137, 180, 250),
        Success = Color3.fromRGB(166, 227, 161),
        Warning = Color3.fromRGB(249, 226, 175),
        Error = Color3.fromRGB(243, 139, 168),
    },
    Cyberpunk = {
        Primary = Color3.fromRGB(236, 72, 153),
        Secondary = Color3.fromRGB(30, 30, 40),
        Background = Color3.fromRGB(13, 13, 20),
        Surface = Color3.fromRGB(25, 25, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(168, 162, 158),
        Accent = Color3.fromRGB(139, 92, 246),
        Success = Color3.fromRGB(16, 185, 129),
        Warning = Color3.fromRGB(245, 158, 11),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Ocean = {
        Primary = Color3.fromRGB(6, 182, 212),
        Secondary = Color3.fromRGB(30, 41, 59),
        Background = Color3.fromRGB(15, 23, 42),
        Surface = Color3.fromRGB(30, 41, 59),
        Text = Color3.fromRGB(248, 250, 252),
        TextDim = Color3.fromRGB(148, 163, 184),
        Accent = Color3.fromRGB(56, 189, 248),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Neon = {
        Primary = Color3.fromRGB(0, 255, 136),
        Secondary = Color3.fromRGB(20, 20, 30),
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(20, 20, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(0, 255, 255),
        Success = Color3.fromRGB(0, 255, 136),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 85),
    },
    Dracula = {
        Primary = Color3.fromRGB(189, 147, 249),
        Secondary = Color3.fromRGB(68, 71, 90),
        Background = Color3.fromRGB(40, 42, 54),
        Surface = Color3.fromRGB(68, 71, 90),
        Text = Color3.fromRGB(248, 248, 242),
        TextDim = Color3.fromRGB(98, 114, 164),
        Accent = Color3.fromRGB(255, 121, 198),
        Success = Color3.fromRGB(80, 250, 123),
        Warning = Color3.fromRGB(241, 250, 140),
        Error = Color3.fromRGB(255, 85, 85),
    },
    Nord = {
        Primary = Color3.fromRGB(136, 192, 208),
        Secondary = Color3.fromRGB(59, 66, 82),
        Background = Color3.fromRGB(46, 52, 64),
        Surface = Color3.fromRGB(59, 66, 82),
        Text = Color3.fromRGB(236, 239, 244),
        TextDim = Color3.fromRGB(216, 222, 233),
        Accent = Color3.fromRGB(129, 161, 193),
        Success = Color3.fromRGB(163, 190, 140),
        Warning = Color3.fromRGB(235, 203, 139),
        Error = Color3.fromRGB(191, 97, 106),
    },
    Rose = {
        Primary = Color3.fromRGB(244, 63, 94),
        Secondary = Color3.fromRGB(30, 25, 30),
        Background = Color3.fromRGB(20, 15, 20),
        Surface = Color3.fromRGB(35, 25, 30),
        Text = Color3.fromRGB(255, 241, 242),
        TextDim = Color3.fromRGB(190, 170, 175),
        Accent = Color3.fromRGB(251, 113, 133),
        Success = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(250, 204, 21),
        Error = Color3.fromRGB(248, 113, 113),
    },
    LiquidGlass = {
        Primary = Color3.fromRGB(100, 180, 255),
        Secondary = Color3.fromRGB(40, 40, 50),
        Background = Color3.fromRGB(20, 20, 28),
        Surface = Color3.fromRGB(30, 30, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(170, 180, 200),
        Accent = Color3.fromRGB(130, 200, 255),
        Success = Color3.fromRGB(80, 220, 150),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 100, 100),
    },
}

-- State
local State = {
    ScreenGui = nil,
    Windows = {},
    Theme = "Midnight",
    Notifications = {},
}

-- Utilities
local function GetTheme()
    return Themes[State.Theme] or Themes.Dark
end

local function Tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function Stroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Color3.fromRGB(60, 60, 70),
        Thickness = thickness or 1,
        Parent = parent
    })
end

-- ScreenGui
local function CreateScreenGui()
    if State.ScreenGui then return State.ScreenGui end
    
    local gui = Create("ScreenGui", {
        Name = "NexusUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    local ok = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not ok then
        gui.Parent = PlayerGui
    end
    
    State.ScreenGui = gui
    return gui
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    local theme = GetTheme()
    
    config = config or {}
    self.Title = config.Title or "NexusUI"
    self.Size = config.Size or UDim2.new(0, 550, 0, 400)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true
    self.Minimized = false
    
    local gui = CreateScreenGui()
    
    -- Main Frame
    self.Frame = Create("Frame", {
        Name = "Window",
        Size = self.Size,
        Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = gui
    })
    Corner(self.Frame, 12)
    Stroke(self.Frame, Color3.fromRGB(50, 50, 60))
    
    -- Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = self.Frame
    })
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = self.Frame
    })
    Corner(titleBar, 12)
    
    local titleFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    local title = Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Window Buttons
    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -33, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 95, 87),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = titleBar
    })
    Corner(closeBtn, 14)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 70, 60)}, 0.1)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 95, 87)}, 0.1)
    end)
    
    local minBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -66, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 189, 46),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = titleBar
    })
    Corner(minBtn, 14)
    
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
            self.Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Tab Container
    self.TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 130, 1, -46),
        Position = UDim2.new(0, 6, 0, 42),
        BackgroundTransparency = 1,
        Parent = self.Frame
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = self.TabBar
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        Parent = self.TabBar
    })
    
    -- Content
    self.Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -144, 1, -50),
        Position = UDim2.new(0, 140, 0, 46),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Frame
    })
    Corner(self.Content, 10)
    
    table.insert(State.Windows, self)
    return self
end

function Window:AddTab(config)
    config = config or {}
    local theme = GetTheme()
    
    local tab = {
        Name = config.Name or "Tab",
        Elements = {},
    }
    
    -- Tab Button
    local btn = Create("TextButton", {
        Name = "Tab_" .. tab.Name,
        Size = UDim2.new(1, -8, 0, 34),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Text = "  " .. tab.Name,
        TextColor3 = theme.TextDim,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = self.TabBar
    })
    Corner(btn, 8)
    
    tab.Button = btn
    
    -- Tab Content
    local frame = Create("ScrollingFrame", {
        Name = "Content_" .. tab.Name,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Content
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = frame
    })
    
    tab.Frame = frame
    
    -- Tab Methods
    function tab:AddLabel(text)
        local label = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        return label
    end
    
    function tab:AddSection(name)
        local section = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("Frame", {
            Size = UDim2.new(0.15, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Parent = section
        })
        
        Create("TextLabel", {
            Size = UDim2.new(0.7, 0, 1, 0),
            Position = UDim2.new(0.15, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = name or "Section",
            TextColor3 = theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            Parent = section
        })
        
        Create("Frame", {
            Size = UDim2.new(0.15, 0, 0, 1),
            Position = UDim2.new(0.85, 0, 0.5, 0),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Parent = section
        })
        
        return section
    end
    
    function tab:AddButton(cfg)
        cfg = cfg or {}
        
        local button = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Text = cfg.Text or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
            Parent = frame
        })
        Corner(button, 8)
        
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = Color3.new(
                math.min(1, theme.Primary.R * 1.15),
                math.min(1, theme.Primary.G * 1.15),
                math.min(1, theme.Primary.B * 1.15)
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
        local enabled = cfg.Default or false
        
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Text or "Toggle",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local toggleBg = Create("Frame", {
            Size = UDim2.new(0, 46, 0, 24),
            Position = UDim2.new(1, -46, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = enabled and theme.Primary or theme.Secondary,
            BorderSizePixel = 0,
            Parent = container
        })
        Corner(toggleBg, 12)
        
        local circle = Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = toggleBg
        })
        Corner(circle, 9)
        
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = container
        })
        
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            Tween(toggleBg, {BackgroundColor3 = enabled and theme.Primary or theme.Secondary}, 0.2)
            Tween(circle, {Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
            if cfg.Callback then
                cfg.Callback(enabled)
            end
        end)
        
        return {
            Set = function(_, v)
                enabled = v
                toggleBg.BackgroundColor3 = enabled and theme.Primary or theme.Secondary
                circle.Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            end,
            Get = function() return enabled end
        }
    end
    
    function tab:AddSlider(cfg)
        cfg = cfg or {}
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = math.clamp(cfg.Default or min, min, max)
        
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 20),
            BackgroundTransparency = 1,
            Text = cfg.Text or "Slider",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local valLabel = Create("TextLabel", {
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -50, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(value),
            TextColor3 = theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = container
        })
        
        local sliderBg = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 8),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Parent = container
        })
        Corner(sliderBg, 4)
        
        local fill = Create("Frame", {
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Parent = sliderBg
        })
        Corner(fill, 4)
        
        local isDragging = false
        
        local function update(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos + 0.5)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valLabel.Text = tostring(value)
            if cfg.Callback then
                cfg.Callback(value)
            end
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                update(input)
            end
        end)
        
        sliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)
        
        return {
            Set = function(_, v)
                value = math.clamp(v, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                valLabel.Text = tostring(value)
            end,
            Get = function() return value end
        }
    end
    
    function tab:AddDropdown(cfg)
        cfg = cfg or {}
        local options = cfg.Options or {}
        local selected = cfg.Default or (options[1] or "")
        local open = false
        
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            ClipsDescendants = false,
            ZIndex = 5,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Text or "Dropdown",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local dropBtn = Create("TextButton", {
            Size = UDim2.new(0.55, 0, 1, 0),
            Position = UDim2.new(0.45, 0, 0, 0),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Text = selected .. "  v",
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            Parent = container
        })
        Corner(dropBtn, 8)
        
        local optFrame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 10,
            Parent = dropBtn
        })
        Corner(optFrame, 8)
        Stroke(optFrame, Color3.fromRGB(50, 50, 60))
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = optFrame
        })
        
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            Parent = optFrame
        })
        
        for _, opt in ipairs(options) do
            local optBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = theme.Secondary,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = opt,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false,
                ZIndex = 11,
                Parent = optFrame
            })
            Corner(optBtn, 6)
            
            optBtn.MouseEnter:Connect(function()
                optBtn.BackgroundTransparency = 0
            end)
            
            optBtn.MouseLeave:Connect(function()
                optBtn.BackgroundTransparency = 1
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                dropBtn.Text = selected .. "  v"
                open = false
                optFrame.Visible = false
                Tween(optFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                if cfg.Callback then
                    cfg.Callback(selected)
                end
            end)
        end
        
        dropBtn.MouseButton1Click:Connect(function()
            open = not open
            optFrame.Visible = true
            local h = #options * 30 + 8
            Tween(optFrame, {Size = UDim2.new(1, 0, 0, open and h or 0)}, 0.15)
            if not open then
                task.delay(0.15, function()
                    if not open then optFrame.Visible = false end
                end)
            end
        end)
        
        return {
            Set = function(_, v)
                selected = v
                dropBtn.Text = selected .. "  v"
            end,
            Get = function() return selected end
        }
    end
    
    function tab:AddInput(cfg)
        cfg = cfg or {}
        
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(0.35, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Text or "Input",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local input = Create("TextBox", {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0.4, 0, 0, 0),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Text = cfg.Default or "",
            PlaceholderText = cfg.Placeholder or "Enter text...",
            TextColor3 = theme.Text,
            PlaceholderColor3 = theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            Parent = container
        })
        Corner(input, 8)
        
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = input
        })
        
        input.FocusLost:Connect(function()
            if cfg.Callback then
                cfg.Callback(input.Text)
            end
        end)
        
        return {
            Set = function(_, v) input.Text = v end,
            Get = function() return input.Text end
        }
    end
    
    function tab:AddKeybind(cfg)
        cfg = cfg or {}
        local key = cfg.Default or Enum.KeyCode.Unknown
        local listening = false
        
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Text or "Keybind",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local keyBtn = Create("TextButton", {
            Size = UDim2.new(0.35, 0, 1, 0),
            Position = UDim2.new(0.65, 0, 0, 0),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Text = key.Name or "None",
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
            Parent = container
        })
        Corner(keyBtn, 8)
        
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
        local color = cfg.Default or Color3.new(1, 1, 1)
        
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Text or "Color",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        local colorBtn = Create("TextButton", {
            Size = UDim2.new(0, 60, 0, 28),
            Position = UDim2.new(1, -60, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = container
        })
        Corner(colorBtn, 6)
        Stroke(colorBtn, Color3.fromRGB(60, 60, 70))
        
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
        local idx = 1
        
        colorBtn.MouseButton1Click:Connect(function()
            idx = idx % #presets + 1
            color = presets[idx]
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
    
    function tab:AddParagraph(title, text)
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
            Parent = frame
        })
        
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = title or "Title",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
        
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 26),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = container
        })
        
        return container
    end
    
    -- Tab Selection
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = theme.Secondary
            t.Button.TextColor3 = theme.TextDim
        end
        tab.Frame.Visible = true
        btn.BackgroundColor3 = theme.Primary
        btn.TextColor3 = Color3.new(1, 1, 1)
        self.ActiveTab = tab
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        tab.Frame.Visible = true
        btn.BackgroundColor3 = theme.Primary
        btn.TextColor3 = Color3.new(1, 1, 1)
        self.ActiveTab = tab
    end
    
    return tab
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    Tween(self.Frame, {Size = self.Minimized and UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 38) or self.Size}, 0.3)
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

-- Main API
function NexusUI:CreateWindow(config)
    return Window.new(config)
end

function NexusUI:SetTheme(name)
    if Themes[name] then
        State.Theme = name
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
    
    local notif = Create("Frame", {
        Size = UDim2.new(0, 280, 0, 70),
        Position = UDim2.new(1, 10, 1, -80 - (#State.Notifications * 80)),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = gui
    })
    Corner(notif, 10)
    
    table.insert(State.Notifications, notif)
    
    Create("Frame", {
        Size = UDim2.new(0, 4, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = colors[config.Type] or theme.Primary,
        BorderSizePixel = 0,
        Parent = notif
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 22),
        Position = UDim2.new(0, 16, 0, 8),
        BackgroundTransparency = 1,
        Text = config.Title or "Notification",
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 16, 0, 32),
        BackgroundTransparency = 1,
        Text = config.Content or config.Message or "",
        TextColor3 = theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif
    })
    
    Tween(notif, {Position = UDim2.new(1, -290, 1, -80 - ((#State.Notifications - 1) * 80))}, 0.3, Enum.EasingStyle.Back)
    
    task.delay(config.Duration or 4, function()
        Tween(notif, {Position = UDim2.new(1, 10, notif.Position.Y.Scale, notif.Position.Y.Offset)}, 0.3)
        task.wait(0.3)
        
        for i, n in ipairs(State.Notifications) do
            if n == notif then
                table.remove(State.Notifications, i)
                break
            end
        end
        notif:Destroy()
        
        for i, n in ipairs(State.Notifications) do
            Tween(n, {Position = UDim2.new(1, -290, 1, -80 - ((i - 1) * 80))}, 0.2)
        end
    end)
end

function NexusUI:EnableFPSMonitor(config)
    config = config or {}
    local gui = CreateScreenGui()
    local theme = GetTheme()
    
    if State.FPSMonitor then
        State.FPSMonitor:Destroy()
    end
    
    local frame = Create("Frame", {
        Name = "FPSMonitor",
        Size = UDim2.new(0, 80, 0, 24),
        Position = config.Position == "TopRight" and UDim2.new(1, -90, 0, 10) or UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = gui
    })
    Corner(frame, 6)
    
    local label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "FPS: --",
        TextColor3 = theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        Parent = frame
    })
    
    State.FPSMonitor = frame
    
    local frameCount = 0
    local lastTime = os.clock()
    
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastTime >= 1 then
            local fps = math.floor(frameCount / (now - lastTime))
            label.Text = "FPS: " .. fps
            frameCount = 0
            lastTime = now
        end
    end)
end

function NexusUI:DisableFPSMonitor()
    if State.FPSMonitor then
        State.FPSMonitor:Destroy()
        State.FPSMonitor = nil
    end
end

function NexusUI:RegisterHotkey(name, key, callback)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == key then
            callback()
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

print("[NexusUI] Loaded v" .. NexusUI.Version)
return NexusUI
