--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                     UNIVERSAL MEDIA LOADER v3.0                           ║
    ║         Load ANY media in Roblox - Images, Sounds, Videos                 ║
    ║                                                                           ║
    ║  Supports: Synapse X, Script-Ware, Fluxus, KRNL, Oxygen U, etc.          ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
    SUPPORTED FORMATS:
    ══════════════════
    IMAGES: png, jpg, jpeg, gif, webp, bmp, ico, svg
    SOUNDS: mp3, wav, ogg, flac, aac, m4a
    VIDEOS: mp4, webm, mov, avi, mkv
    
    USAGE:
    ══════
    -- Load the module
    loadstring(game:HttpGet("your-paste-url"))()
    
    -- IMAGES
    local img = MediaLoader.image("https://i.imgur.com/abc.png")
    local img = MediaLoader.imageBase64("data:image/png;base64,...")
    
    -- SOUNDS
    MediaLoader.playSound("https://example.com/sound.mp3")
    local sound = MediaLoader.sound("https://example.com/music.mp3")
    
    -- VIDEOS
    local video = MediaLoader.video("https://example.com/video.mp4")
    video:Play()
    
    -- QUICK GUI
    MediaLoader.showImage("https://i.imgur.com/abc.png")
    MediaLoader.showVideo("https://example.com/video.mp4")
]]

-- ══════════════════════════════════════════════════════════════════════════════
-- EXECUTOR COMPATIBILITY LAYER
-- ══════════════════════════════════════════════════════════════════════════════

local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
local GetCustomAsset = getcustomasset or getsynasset

if not HttpRequest then
    error("[MediaLoader] Your executor doesn't support HTTP requests!")
end

-- ══════════════════════════════════════════════════════════════════════════════
-- SERVICES & GLOBALS
-- ══════════════════════════════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ══════════════════════════════════════════════════════════════════════════════
-- MAIN MODULE
-- ══════════════════════════════════════════════════════════════════════════════

getgenv().MediaLoader = {}
local MediaLoader = getgenv().MediaLoader

-- Configuration
MediaLoader.Config = {
    CacheFolder = "MediaLoaderCache",
    ImageFolder = "MediaLoaderCache/images",
    SoundFolder = "MediaLoaderCache/sounds",
    VideoFolder = "MediaLoaderCache/videos",
    DefaultVolume = 0.5,
    DebugMode = false
}

-- Caches
local ImageCache = {}
local SoundCache = {}
local VideoCache = {}

-- Supported formats
local ImageFormats = { "png", "jpg", "jpeg", "gif", "webp", "bmp", "ico", "svg" }
local SoundFormats = { "mp3", "wav", "ogg", "flac", "aac", "m4a" }
local VideoFormats = { "mp4", "webm", "mov", "avi", "mkv", "wmv" }

-- ══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════════════════════════

local function debugPrint(...)
    if MediaLoader.Config.DebugMode then
        print("[MediaLoader]", ...)
    end
end

local function ensureFolders()
    if makefolder then
        if not isfolder(MediaLoader.Config.CacheFolder) then
            makefolder(MediaLoader.Config.CacheFolder)
        end
        if not isfolder(MediaLoader.Config.ImageFolder) then
            makefolder(MediaLoader.Config.ImageFolder)
        end
        if not isfolder(MediaLoader.Config.SoundFolder) then
            makefolder(MediaLoader.Config.SoundFolder)
        end
        if not isfolder(MediaLoader.Config.VideoFolder) then
            makefolder(MediaLoader.Config.VideoFolder)
        end
    end
end

local function getExtension(url)
    -- Try multiple patterns to extract extension
    local ext = url:match("%.([%w]+)$")  -- Simple: ends with .ext
        or url:match("%.([%w]+)%?")       -- Has query string: .ext?
        or url:match("%.([%w]+)%#")       -- Has hash: .ext#
        or url:match("/[^/]+%.([%w]+)")   -- In path: /file.ext
    return ext and ext:lower() or nil
end

local function detectMediaType(url)
    local ext = getExtension(url)
    if not ext then return "unknown", "bin" end
    
    for _, format in ipairs(ImageFormats) do
        if ext == format then return "image", ext end
    end
    for _, format in ipairs(SoundFormats) do
        if ext == format then return "sound", ext end
    end
    for _, format in ipairs(VideoFormats) do
        if ext == format then return "video", ext end
    end
    
    return "unknown", ext
end

local function decodeBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2^(8-i) or 0)
        end
        return string.char(c)
    end))
end

local function downloadFile(url, folder, format)
    local fileName = folder .. "/" .. HttpService:GenerateGUID(false) .. "." .. format
    
    local response = HttpRequest({
        Url = url,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
    })
    
    if not response or response.StatusCode ~= 200 then
        error("[MediaLoader] Failed to download: " .. (response and response.StatusCode or "No response"))
    end
    
    ensureFolders()
    
    if writefile then
        writefile(fileName, response.Body)
        debugPrint("Cached to:", fileName)
        return fileName, response.Body
    end
    
    return nil, response.Body
end

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- IMAGE FUNCTIONS
-- ══════════════════════════════════════════════════════════════════════════════

--[[
    Load image from URL
    @param url string - Image URL
    @param options table? - { size, position, parent }
    @return ImageLabel
]]
function MediaLoader.image(url, options)
    options = options or {}
    
    debugPrint("Loading image:", url)
    
    -- Check cache
    if ImageCache[url] and GetCustomAsset then
        local img = Instance.new("ImageLabel")
        img.Name = "LoadedImage"
        img.BackgroundTransparency = 1
        img.Size = options.size or UDim2.new(0, 256, 0, 256)
        img.Position = options.position or UDim2.new(0, 0, 0, 0)
        img.Image = GetCustomAsset(ImageCache[url])
        if options.parent then img.Parent = options.parent end
        return img
    end
    
    local _, format = detectMediaType(url)
    format = format or "png"
    
    local filePath, rawData = downloadFile(url, MediaLoader.Config.ImageFolder, format)
    
    if filePath and GetCustomAsset then
        ImageCache[url] = filePath
        
        local img = Instance.new("ImageLabel")
        img.Name = "LoadedImage"
        img.BackgroundTransparency = 1
        img.Size = options.size or UDim2.new(0, 256, 0, 256)
        img.Position = options.position or UDim2.new(0, 0, 0, 0)
        img.Image = GetCustomAsset(filePath)
        if options.parent then img.Parent = options.parent end
        return img
    end
    
    -- Fallback: Drawing library
    if Drawing and rawData then
        local drawImg = Drawing.new("Image")
        drawImg.Data = rawData
        drawImg.Size = Vector2.new(256, 256)
        drawImg.Position = Vector2.new(100, 100)
        drawImg.Visible = true
        return drawImg
    end
    
    error("[MediaLoader] Failed to load image - getcustomasset required")
end

--[[
    Load image from base64
    @param base64Data string - Base64 encoded image
    @param options table? - { size, position, parent, format }
    @return ImageLabel
]]
function MediaLoader.imageBase64(base64Data, options)
    options = options or {}
    
    -- Extract format from data URL if present
    local format = "png"
    local formatMatch = base64Data:match("^data:image/([%w]+);base64,")
    if formatMatch then
        format = formatMatch
        base64Data = base64Data:gsub("^data:image/[%w]+;base64,", "")
    end
    format = options.format or format
    
    local imageData = decodeBase64(base64Data)
    
    if not imageData or #imageData == 0 then
        error("[MediaLoader] Failed to decode base64")
    end
    
    ensureFolders()
    
    local fileName = MediaLoader.Config.ImageFolder .. "/" .. HttpService:GenerateGUID(false) .. "." .. format
    
    if writefile and GetCustomAsset then
        writefile(fileName, imageData)
        
        local img = Instance.new("ImageLabel")
        img.Name = "LoadedImage"
        img.BackgroundTransparency = 1
        img.Size = options.size or UDim2.new(0, 256, 0, 256)
        img.Position = options.position or UDim2.new(0, 0, 0, 0)
        img.Image = GetCustomAsset(fileName)
        if options.parent then img.Parent = options.parent end
        return img
    end
    
    -- Fallback: Drawing
    if Drawing then
        local drawImg = Drawing.new("Image")
        drawImg.Data = imageData
        drawImg.Size = Vector2.new(256, 256)
        drawImg.Position = Vector2.new(100, 100)
        drawImg.Visible = true
        return drawImg
    end
    
    error("[MediaLoader] Failed to load base64 image")
end

--[[
    Show image in a GUI window
    @param urlOrBase64 string - URL or base64 data
    @param options table? - { title, size, position }
    @return ScreenGui
]]
function MediaLoader.showImage(urlOrBase64, options)
    options = options or {}
    
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Remove existing
    local existing = playerGui:FindFirstChild("MediaLoaderImageGui")
    if existing then existing:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MediaLoaderImageGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = options.size or UDim2.new(0, 320, 0, 360)
    container.Position = options.position or UDim2.new(0.5, -160, 0.5, -180)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = options.title or "🖼️ Image Viewer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Image container
    local imgContainer = Instance.new("Frame")
    imgContainer.Name = "ImageContainer"
    imgContainer.Size = UDim2.new(1, -20, 1, -60)
    imgContainer.Position = UDim2.new(0, 10, 0, 50)
    imgContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    imgContainer.BorderSizePixel = 0
    imgContainer.ClipsDescendants = true
    imgContainer.Parent = container
    
    local imgContainerCorner = Instance.new("UICorner")
    imgContainerCorner.CornerRadius = UDim.new(0, 8)
    imgContainerCorner.Parent = imgContainer
    
    -- Loading
    local loading = Instance.new("TextLabel")
    loading.Size = UDim2.new(1, 0, 1, 0)
    loading.BackgroundTransparency = 1
    loading.Text = "Loading..."
    loading.TextColor3 = Color3.fromRGB(150, 150, 150)
    loading.TextSize = 16
    loading.Font = Enum.Font.Gotham
    loading.Parent = imgContainer
    
    makeDraggable(container)
    
    -- Load image async
    task.spawn(function()
        local success, img = pcall(function()
            if urlOrBase64:match("^data:") or #urlOrBase64 > 500 then
                return MediaLoader.imageBase64(urlOrBase64)
            else
                return MediaLoader.image(urlOrBase64)
            end
        end)
        
        if success and img then
            loading:Destroy()
            img.Size = UDim2.new(1, 0, 1, 0)
            img.Position = UDim2.new(0, 0, 0, 0)
            img.ScaleType = Enum.ScaleType.Fit
            img.Parent = imgContainer
        else
            loading.Text = "Failed to load"
            loading.TextColor3 = Color3.fromRGB(239, 68, 68)
        end
    end)
    
    return screenGui
end

-- ══════════════════════════════════════════════════════════════════════════════
-- SOUND FUNCTIONS
-- ══════════════════════════════════════════════════════════════════════════════

--[[
    Load sound from URL
    @param url string - Sound URL
    @param options table? - { volume, looped, autoPlay, parent }
    @return Sound
]]
function MediaLoader.sound(url, options)
    options = options or {}
    
    debugPrint("Loading sound:", url)
    
    if not GetCustomAsset or not writefile then
        error("[MediaLoader] Sound loading requires getcustomasset and writefile!")
    end
    
    -- Check cache
    if SoundCache[url] then
        local sound = Instance.new("Sound")
        sound.Name = "LoadedSound"
        sound.SoundId = GetCustomAsset(SoundCache[url])
        sound.Volume = options.volume or MediaLoader.Config.DefaultVolume
        sound.Looped = options.looped or false
        sound.Parent = options.parent or SoundService
        if options.autoPlay then sound:Play() end
        return sound
    end
    
    local _, format = detectMediaType(url)
    format = format or "mp3"
    
    local filePath = downloadFile(url, MediaLoader.Config.SoundFolder, format)
    
    if not filePath then
        error("[MediaLoader] Failed to cache sound")
    end
    
    SoundCache[url] = filePath
    
    local sound = Instance.new("Sound")
    sound.Name = "LoadedSound"
    sound.SoundId = GetCustomAsset(filePath)
    sound.Volume = options.volume or MediaLoader.Config.DefaultVolume
    sound.Looped = options.looped or false
    sound.Parent = options.parent or SoundService
    
    if options.autoPlay then
        sound:Play()
    end
    
    return sound
end

--[[
    Load sound from base64
    @param base64Data string - Base64 encoded audio
    @param options table? - { volume, looped, autoPlay, format }
    @return Sound
]]
function MediaLoader.soundBase64(base64Data, options)
    options = options or {}
    
    local format = "mp3"
    local formatMatch = base64Data:match("^data:audio/([%w]+);base64,")
    if formatMatch then
        format = formatMatch
        base64Data = base64Data:gsub("^data:audio/[%w]+;base64,", "")
    end
    format = options.format or format
    
    local audioData = decodeBase64(base64Data)
    
    if not audioData or #audioData == 0 then
        error("[MediaLoader] Failed to decode base64 audio")
    end
    
    ensureFolders()
    
    local fileName = MediaLoader.Config.SoundFolder .. "/" .. HttpService:GenerateGUID(false) .. "." .. format
    writefile(fileName, audioData)
    
    local sound = Instance.new("Sound")
    sound.Name = "LoadedSound"
    sound.SoundId = GetCustomAsset(fileName)
    sound.Volume = options.volume or MediaLoader.Config.DefaultVolume
    sound.Looped = options.looped or false
    sound.Parent = SoundService
    
    if options.autoPlay then
        sound:Play()
    end
    
    return sound
end

--[[
    Quick play sound from URL (auto-cleanup)
    @param url string
    @param volume number?
    @return Sound
]]
function MediaLoader.playSound(url, volume)
    local sound = MediaLoader.sound(url, {
        volume = volume or MediaLoader.Config.DefaultVolume,
        autoPlay = true
    })
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    
    return sound
end

--[[
    Loop sound from URL
    @param url string
    @param volume number?
    @return Sound
]]
function MediaLoader.loopSound(url, volume)
    return MediaLoader.sound(url, {
        volume = volume or MediaLoader.Config.DefaultVolume,
        looped = true,
        autoPlay = true
    })
end

--[[
    Stop all loaded sounds
]]
function MediaLoader.stopAllSounds()
    for _, sound in ipairs(SoundService:GetChildren()) do
        if sound:IsA("Sound") and sound.Name == "LoadedSound" then
            sound:Stop()
            sound:Destroy()
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════
-- VIDEO FUNCTIONS
-- ══════════════════════════════════════════════════════════════════════════════

--[[
    Load video from URL
    @param url string - Video URL
    @param options table? - { volume, looped, autoPlay }
    @return VideoFrame
]]
function MediaLoader.video(url, options)
    options = options or {}
    
    print("[MediaLoader] Loading video:", url)
    
    if not GetCustomAsset or not writefile then
        error("[MediaLoader] Video loading requires getcustomasset and writefile!")
    end
    
    -- Check cache
    if VideoCache[url] then
        print("[MediaLoader] Using cached video:", VideoCache[url])
        local assetId = GetCustomAsset(VideoCache[url])
        print("[MediaLoader] Asset ID:", assetId)
        
        local video = Instance.new("VideoFrame")
        video.Name = "LoadedVideo"
        video.Video = assetId
        video.Volume = options.volume or MediaLoader.Config.DefaultVolume
        video.Looped = options.looped or false
        video.Size = UDim2.new(0, 480, 0, 270)
        video.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        if options.autoPlay then video:Play() end
        return video
    end
    
    -- Detect format - force mp4 for common video URLs
    local _, format = detectMediaType(url)
    if not format or format == "unknown" then
        format = "mp4"
    end
    print("[MediaLoader] Detected format:", format)
    
    local filePath = downloadFile(url, MediaLoader.Config.VideoFolder, format)
    
    if not filePath then
        error("[MediaLoader] Failed to cache video")
    end
    
    print("[MediaLoader] Saved to:", filePath)
    VideoCache[url] = filePath
    
    local assetId = GetCustomAsset(filePath)
    print("[MediaLoader] Asset ID:", assetId)
    
    local video = Instance.new("VideoFrame")
    video.Name = "LoadedVideo"
    video.Video = assetId
    video.Volume = options.volume or MediaLoader.Config.DefaultVolume
    video.Looped = options.looped or false
    video.Size = UDim2.new(0, 480, 0, 270)
    video.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    
    if options.autoPlay then
        video:Play()
    end
    
    return video
end

--[[
    Load video from base64
    @param base64Data string
    @param options table?
    @return VideoFrame
]]
function MediaLoader.videoBase64(base64Data, options)
    options = options or {}
    
    local format = "mp4"
    local formatMatch = base64Data:match("^data:video/([%w]+);base64,")
    if formatMatch then
        format = formatMatch
        base64Data = base64Data:gsub("^data:video/[%w]+;base64,", "")
    end
    format = options.format or format
    
    local videoData = decodeBase64(base64Data)
    
    if not videoData or #videoData == 0 then
        error("[MediaLoader] Failed to decode base64 video")
    end
    
    ensureFolders()
    
    local fileName = MediaLoader.Config.VideoFolder .. "/" .. HttpService:GenerateGUID(false) .. "." .. format
    writefile(fileName, videoData)
    
    local video = Instance.new("VideoFrame")
    video.Name = "LoadedVideo"
    video.Video = GetCustomAsset(fileName)
    video.Volume = options.volume or MediaLoader.Config.DefaultVolume
    video.Looped = options.looped or false
    video.Size = UDim2.new(0, 480, 0, 270)
    video.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    
    if options.autoPlay then
        video:Play()
    end
    
    return video
end

--[[
    Show video in a GUI window with controls
    @param url string - Video URL
    @param options table? - { title, size, position }
    @return ScreenGui
]]
function MediaLoader.showVideo(url, options)
    options = options or {}
    
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local existing = playerGui:FindFirstChild("MediaLoaderVideoGui")
    if existing then existing:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MediaLoaderVideoGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = options.size or UDim2.new(0, 520, 0, 380)
    container.Position = options.position or UDim2.new(0.5, -260, 0.5, -190)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = options.title or "🎬 Video Player"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Video container
    local vidContainer = Instance.new("Frame")
    vidContainer.Size = UDim2.new(1, -20, 1, -100)
    vidContainer.Position = UDim2.new(0, 10, 0, 50)
    vidContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    vidContainer.BorderSizePixel = 0
    vidContainer.ClipsDescendants = true
    vidContainer.Parent = container
    
    local vidContainerCorner = Instance.new("UICorner")
    vidContainerCorner.CornerRadius = UDim.new(0, 8)
    vidContainerCorner.Parent = vidContainer
    
    -- Loading
    local loading = Instance.new("TextLabel")
    loading.Size = UDim2.new(1, 0, 1, 0)
    loading.BackgroundTransparency = 1
    loading.Text = "Loading video..."
    loading.TextColor3 = Color3.fromRGB(150, 150, 150)
    loading.TextSize = 16
    loading.Font = Enum.Font.Gotham
    loading.Parent = vidContainer
    
    -- Controls
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -20, 0, 40)
    controls.Position = UDim2.new(0, 10, 1, -50)
    controls.BackgroundTransparency = 1
    controls.Parent = container
    
    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0, 60, 0, 35)
    playBtn.Position = UDim2.new(0, 0, 0, 0)
    playBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    playBtn.BorderSizePixel = 0
    playBtn.Text = "▶ Play"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.TextSize = 12
    playBtn.Font = Enum.Font.GothamBold
    playBtn.Parent = controls
    
    local playBtnCorner = Instance.new("UICorner")
    playBtnCorner.CornerRadius = UDim.new(0, 6)
    playBtnCorner.Parent = playBtn
    
    local pauseBtn = Instance.new("TextButton")
    pauseBtn.Size = UDim2.new(0, 60, 0, 35)
    pauseBtn.Position = UDim2.new(0, 70, 0, 0)
    pauseBtn.BackgroundColor3 = Color3.fromRGB(234, 179, 8)
    pauseBtn.BorderSizePixel = 0
    pauseBtn.Text = "⏸ Pause"
    pauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    pauseBtn.TextSize = 12
    pauseBtn.Font = Enum.Font.GothamBold
    pauseBtn.Parent = controls
    
    local pauseBtnCorner = Instance.new("UICorner")
    pauseBtnCorner.CornerRadius = UDim.new(0, 6)
    pauseBtnCorner.Parent = pauseBtn
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0, 60, 0, 35)
    stopBtn.Position = UDim2.new(0, 140, 0, 0)
    stopBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "⏹ Stop"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 12
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Parent = controls
    
    local stopBtnCorner = Instance.new("UICorner")
    stopBtnCorner.CornerRadius = UDim.new(0, 6)
    stopBtnCorner.Parent = stopBtn
    
    makeDraggable(container)
    
    -- Load video async
    task.spawn(function()
        local success, vid = pcall(function()
            return MediaLoader.video(url)
        end)
        
        if success and vid then
            loading:Destroy()
            vid.Size = UDim2.new(1, 0, 1, 0)
            vid.Parent = vidContainer
            
            playBtn.MouseButton1Click:Connect(function()
                vid:Play()
            end)
            
            pauseBtn.MouseButton1Click:Connect(function()
                vid:Pause()
            end)
            
            stopBtn.MouseButton1Click:Connect(function()
                vid:Pause()
                vid.TimePosition = 0
            end)
        else
            loading.Text = "Failed to load video"
            loading.TextColor3 = Color3.fromRGB(239, 68, 68)
        end
    end)
    
    return screenGui
end

-- ══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════════════════════════

--[[
    Auto-detect and load any media type
    @param urlOrBase64 string
    @param options table?
    @return ImageLabel | Sound | VideoFrame
]]
function MediaLoader.load(urlOrBase64, options)
    options = options or {}
    
    local isBase64 = urlOrBase64:match("^data:") or #urlOrBase64 > 500
    
    if isBase64 then
        if urlOrBase64:match("^data:image") then
            return MediaLoader.imageBase64(urlOrBase64, options)
        elseif urlOrBase64:match("^data:audio") then
            return MediaLoader.soundBase64(urlOrBase64, options)
        elseif urlOrBase64:match("^data:video") then
            return MediaLoader.videoBase64(urlOrBase64, options)
        else
            -- Try to guess from content
            return MediaLoader.imageBase64(urlOrBase64, options)
        end
    else
        local mediaType = detectMediaType(urlOrBase64)
        if mediaType == "image" then
            return MediaLoader.image(urlOrBase64, options)
        elseif mediaType == "sound" then
            return MediaLoader.sound(urlOrBase64, options)
        elseif mediaType == "video" then
            return MediaLoader.video(urlOrBase64, options)
        else
            -- Default to image
            return MediaLoader.image(urlOrBase64, options)
        end
    end
end

--[[
    Clear all caches
]]
function MediaLoader.clearCache()
    ImageCache = {}
    SoundCache = {}
    VideoCache = {}
    
    if isfolder and listfiles and delfile then
        pcall(function()
            for _, folder in ipairs({
                MediaLoader.Config.ImageFolder,
                MediaLoader.Config.SoundFolder,
                MediaLoader.Config.VideoFolder
            }) do
                if isfolder(folder) then
                    for _, file in ipairs(listfiles(folder)) do
                        delfile(file)
                    end
                end
            end
        end)
    end
    
    debugPrint("All caches cleared")
end

--[[
    Check capabilities
    @return table
]]
function MediaLoader.checkCapabilities()
    return {
        httpRequest = HttpRequest ~= nil,
        getCustomAsset = GetCustomAsset ~= nil,
        writeFile = writefile ~= nil,
        makeFolder = makefolder ~= nil,
        drawing = Drawing ~= nil,
        executorName = identifyexecutor and identifyexecutor() or "Unknown"
    }
end

-- ══════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ══════════════════════════════════════════════════════════════════════════════

ensureFolders()

local caps = MediaLoader.checkCapabilities()
print("╔═══════════════════════════════════════════════════════════════╗")
print("║         UNIVERSAL MEDIA LOADER v3.0                          ║")
print("║         Images • Sounds • Videos                             ║")
print("╠═══════════════════════════════════════════════════════════════╣")
print("║  Executor:      " .. caps.executorName .. string.rep(" ", 46 - #caps.executorName) .. "║")
print("║  HTTP Requests: " .. (caps.httpRequest and "✓" or "✗") .. "                                             ║")
print("║  Custom Assets: " .. (caps.getCustomAsset and "✓" or "✗") .. "                                             ║")
print("║  File System:   " .. (caps.writeFile and "✓" or "✗") .. "                                             ║")
print("║  Drawing Lib:   " .. (caps.drawing and "✓" or "✗") .. "                                             ║")
print("╠═══════════════════════════════════════════════════════════════╣")

if caps.getCustomAsset and caps.writeFile then
    print("║  ✓ Full support: Images, Sounds, Videos                      ║")
elseif caps.drawing then
    print("║  ⚠ Partial: Images only (Drawing overlay)                    ║")
else
    print("║  ✗ Limited: Upgrade your executor                            ║")
end

print("╠═══════════════════════════════════════════════════════════════╣")
print("║  IMAGES:  png, jpg, gif, webp, bmp, svg                       ║")
print("║  SOUNDS:  mp3, wav, ogg, flac, aac, m4a                       ║")
print("║  VIDEOS:  mp4, webm, mov, avi, mkv                            ║")
print("╚═══════════════════════════════════════════════════════════════╝")
print("")
print("QUICK START:")
print("  MediaLoader.showImage('https://i.imgur.com/xxx.png')")
print("  MediaLoader.playSound('https://example.com/sound.mp3')")
print("  MediaLoader.showVideo('https://example.com/video.mp4')")
print("")
print("  -- Or load directly:")
print("  local img = MediaLoader.image('url')")
print("  local sound = MediaLoader.sound('url')")
print("  local video = MediaLoader.video('url')")
print("")

return MediaLoader
