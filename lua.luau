--[[
    NexusUI Minimal Test Version
    A stripped down version to test basic functionality
]]

-- Simple module system
local NexusUI = {}
NexusUI.__index = NexusUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- State
local Windows = {}
local ScreenGui = nil

-- Create ScreenGui
local function CreateScreenGui()
    if ScreenGui then return ScreenGui end
    
    local success, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "NexusUI"
        g.ResetOnSpawn = false
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        g.Parent = game:GetService("CoreGui")
        return g
    end)
    
    if not success then
        local g = Instance.new("ScreenGui")
        g.Name = "NexusUI"
        g.ResetOnSpawn = false
        g.Parent = PlayerGui
        gui = g
    end
    
    ScreenGui = gui
    return gui
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    
    config = config or {}
    self.Title = config.Title or "Window"
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Create window frame
    local gui = CreateScreenGui()
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "Window"
    self.Frame.Size = config.Size or UDim2.new(0, 500, 0, 400)
    self.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Frame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.Frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
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
    
    -- Tab container
    self.TabBar = Instance.new("Frame")
    self.TabBar.Name = "TabBar"
    self.TabBar.Size = UDim2.new(0, 120, 1, -40)
    self.TabBar.Position = UDim2.new(0, 4, 0, 36)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Parent = self.Frame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.TabBar
    
    -- Content container
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -132, 1, -44)
    self.Content.Position = UDim2.new(0, 128, 0, 40)
    self.Content.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    self.Content.BorderSizePixel = 0
    self.Content.Parent = self.Frame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = self.Content
    
    table.insert(Windows, self)
    return self
end

function Window:AddTab(config)
    config = config or {}
    local tab = {
        Name = config.Name or "Tab",
        Elements = {},
        Frame = nil,
        Button = nil
    }
    
    -- Tab button
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tab.Name
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Text = tab.Name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    btn.Parent = self.TabBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    tab.Button = btn
    
    -- Tab content frame
    local frame = Instance.new("ScrollingFrame")
    frame.Name = "TabContent_" .. tab.Name
    frame.Size = UDim2.new(1, -16, 1, -16)
    frame.Position = UDim2.new(0, 8, 0, 8)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    frame.Parent = self.Content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = frame
    
    tab.Frame = frame
    
    -- Tab methods
    function tab:AddButton(cfg)
        cfg = cfg or {}
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 32)
        button.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
        button.BorderSizePixel = 0
        button.Text = cfg.Text or "Button"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 13
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = false
        button.Parent = frame
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = button
        
        button.MouseButton1Click:Connect(function()
            if cfg.Callback then
                cfg.Callback()
            end
        end)
        
        return button
    end
    
    function tab:AddToggle(cfg)
        cfg = cfg or {}
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 32)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Toggle"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(0, 40, 0, 20)
        toggleFrame.Position = UDim2.new(1, -40, 0.5, 0)
        toggleFrame.AnchorPoint = Vector2.new(0, 0.5)
        toggleFrame.BackgroundColor3 = cfg.Default and Color3.fromRGB(60, 130, 255) or Color3.fromRGB(60, 60, 65)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = container
        
        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0.5, 0)
        tc.Parent = toggleFrame
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = cfg.Default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        circle.AnchorPoint = Vector2.new(0, 0.5)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = toggleFrame
        
        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(0.5, 0)
        cc.Parent = circle
        
        local enabled = cfg.Default or false
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = toggleFrame
        
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and Color3.fromRGB(60, 130, 255) or Color3.fromRGB(60, 60, 65)
            }):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            }):Play()
            if cfg.Callback then
                cfg.Callback(enabled)
            end
        end)
        
        return {
            SetValue = function(_, v)
                enabled = v
                toggleFrame.BackgroundColor3 = enabled and Color3.fromRGB(60, 130, 255) or Color3.fromRGB(60, 60, 65)
                circle.Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            end,
            GetValue = function() return enabled end
        }
    end
    
    function tab:AddSlider(cfg)
        cfg = cfg or {}
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 45)
        container.BackgroundTransparency = 1
        container.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = cfg.Text or "Slider"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Position = UDim2.new(1, -40, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(cfg.Default or cfg.Min or 0)
        valueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = container
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0, 28)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = container
        
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(0.5, 0)
        sc.Parent = sliderBg
        
        local fill = Instance.new("Frame")
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        
        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0.5, 0)
        fc.Parent = fill
        
        local dragging = false
        
        local function update(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos)
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
    
    function tab:AddLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text or ""
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        return label
    end
    
    -- Click handler
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        tab.Frame.Visible = true
        tab.Button.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.ActiveTab = tab
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        frame.Visible = true
        self.ActiveTab = tab
    end
    
    return tab
end

function Window:Toggle()
    self.Frame.Visible = not self.Frame.Visible
end

function Window:Show()
    self.Frame.Visible = true
end

function Window:Hide()
    self.Frame.Visible = false
end

function Window:Destroy()
    self.Frame:Destroy()
end

-- Main API
function NexusUI:CreateWindow(config)
    return Window.new(config)
end

function NexusUI:Notify(config)
    config = config or {}
    local gui = CreateScreenGui()
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 250, 0, 60)
    notification.Position = UDim2.new(1, -260, 1, -70)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notification.BorderSizePixel = 0
    notification.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 20)
    title.Position = UDim2.new(0, 8, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notification"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -16, 0, 20)
    content.Position = UDim2.new(0, 8, 0, 30)
    content.BackgroundTransparency = 1
    content.Text = config.Content or config.Message or ""
    content.TextColor3 = Color3.fromRGB(180, 180, 180)
    content.TextSize = 12
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Parent = notification
    
    -- Animate in
    notification.Position = UDim2.new(1, 10, 1, -70)
    TweenService:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -260, 1, -70)
    }):Play()
    
    -- Auto dismiss
    task.delay(config.Duration or 3, function()
        TweenService:Create(notification, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 10, 1, -70)
        }):Play()
        task.wait(0.3)
        notification:Destroy()
    end)
end

function NexusUI:SetTheme(theme)
    -- Minimal version doesn't support themes
    print("[NexusUI] Theme support not available in minimal version")
end

function NexusUI:Destroy()
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
    Windows = {}
end

print("[NexusUI Minimal] Loaded successfully!")
return NexusUI
