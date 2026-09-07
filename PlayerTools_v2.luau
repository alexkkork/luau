-- Player Tools v2: replace your old script with this entire script.
-- Added adjustable speed and reversible, zero-hold local prompts.
-- Studio: LocalScript in StarterPlayer > StarterPlayerScripts.
-- Designed for your own experience / an authorized test session.
-- Standard Roblox APIs only; server-side rules still apply.

local Config = {
    FriendColor = Color3.fromRGB(70, 150, 255),
    EnemyColor = Color3.fromRGB(255, 80, 95),
    UseTeamColor = true,
    ESPMaxDistance = 5000,
    ESPInterval = 0.15,
    PromptInterval = 0.05, -- bounded auto-interaction polling; no per-frame world scans
    PromptCooldown = 1.0,
    OnlyEPrompts = false, -- false = all keys; true = E prompts only
    RepeatPrompts = false, -- false = once per approach; avoids door-toggle spam
    JumpCooldown = 0.16,
    DefaultWalkSpeed = 32,
    MinWalkSpeed = 1,
    MaxWalkSpeed = 250,
    SpeedStep = 4,
    SpeedInterval = 0.10,
    InstantPromptsOnStart = true, -- zero hold time for manual + automatic prompts
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Input = game:GetService("UserInputService")
local Prompts = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local me = Players.LocalPlayer
assert(me, "Player Tools must run on the client, not in a server Script.")
local playerGui = me:WaitForChild("PlayerGui")

-- Rerunning this version unloads the previous copy first.
local previous = playerGui:FindFirstChild("PlayerTools")
if previous then
    local stop = previous:FindFirstChild("Shutdown")
    if stop and stop:IsA("BindableFunction") then
        pcall(function() stop:Invoke() end)
    end
    previous:Destroy()
end

local alive, focused = true, true
local state = {
    ESP = true, InfiniteJump = false, Noclip = false, AutoPrompts = false,
    InstantPrompts = Config.InstantPromptsOnStart, Speed = false,
    WalkSpeed = Config.DefaultWalkSpeed,
}
local connections, entries, promptCache = {}, {}, {}
local parts, originalCollision, characterConnections = {}, {}, {}
local currentCharacter, selectedPlayer, activeHold
local speedHumanoid, originalWalkSpeed
local dirtyPrompts = {}
local statusUntil, lastJump = 0, -math.huge
local colors = {
    Background = Color3.fromRGB(18, 20, 28),
    Row = Color3.fromRGB(32, 36, 48),
    Accent = Color3.fromRGB(77, 115, 245),
    On = Color3.fromRGB(32, 72, 61),
    Text = Color3.fromRGB(239, 242, 250),
    Muted = Color3.fromRGB(167, 175, 194),
}
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function new(class, properties, parent)
    local object = Instance.new(class)
    for property, value in pairs(properties) do object[property] = value end
    object.Parent = parent
    return object
end
local function round(object, radius)
    new("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, object)
end
local gui = new("ScreenGui", {
    Name = "PlayerTools", ResetOnSpawn = false, DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)
local shutdown = new("BindableFunction", { Name = "Shutdown" }, gui)
local effects = new("Folder", { Name = "PlayerTools_LocalEffects" }, Workspace)
local panel = new("Frame", {
    Name = "Panel", Size = UDim2.fromOffset(330, 676),
    Position = UDim2.fromOffset(20, 30), BackgroundColor3 = colors.Background,
    BorderSizePixel = 0, Active = true,
}, gui)
round(panel, 12)
new("UIStroke", { Color = colors.Row, Thickness = 1 }, panel)
local scale = new("UIScale", { Scale = 1 }, panel)
local function text(parent, value, x, y, w, h, size)
    return new("TextLabel", {
        Text = value, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
        BackgroundTransparency = 1, TextColor3 = colors.Text,
        TextSize = size or 14, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end
local function button(parent, name, value, x, y, w, h)
    local object = new("TextButton", {
        Name = name, Text = value, Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(w, h), BackgroundColor3 = colors.Row,
        BorderSizePixel = 0, TextColor3 = colors.Text,
        TextSize = 13, Font = Enum.Font.GothamMedium, AutoButtonColor = true,
    }, parent)
    round(object)
    return object
end
local title = text(panel, "PLAYER TOOLS", 16, 12, 236, 28, 18)
title.Active = true
local hideButton = button(panel, "Hide", "-", 254, 12, 28, 28)
local exitButton = button(panel, "Unload", "X", 288, 12, 28, 28)
text(panel, "K ESP   J jump   N noclip   P auto   I instant   F speed", 16, 45, 300, 18, 10).TextColor3 = colors.Muted
text(panel, "TELEPORT TO PLAYER", 16, 384, 300, 20, 12).TextColor3 = colors.Muted
local search = new("TextBox", {
    Name = "PlayerSearch", Position = UDim2.fromOffset(16, 410),
    Size = UDim2.fromOffset(298, 30), BackgroundColor3 = colors.Row,
    BorderSizePixel = 0, Text = "", PlaceholderText = "Search username / display name",
    ClearTextOnFocus = false, TextColor3 = colors.Text, PlaceholderColor3 = colors.Muted,
    TextSize = 12, Font = Enum.Font.Gotham,
}, panel)
round(search)
local list = new("ScrollingFrame", {
    Name = "Players", Position = UDim2.fromOffset(16, 448),
    Size = UDim2.fromOffset(298, 112), BackgroundTransparency = 1, BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
}, panel)
new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.Name }, list)
local empty = text(list, "No matching players", 0, 0, 284, 30, 12)
empty.Name = "_Empty"
local teleportButton = button(panel, "Teleport", "Select a player above", 16, 570, 298, 34)
teleportButton.BackgroundColor3 = colors.Accent
local status = text(panel, "Ready. ESP + instant prompts on; speed / auto off.", 16, 613, 298, 34, 11)
status.TextWrapped = true
status.TextColor3 = colors.Muted
text(panel, "Right Shift: hide / show     X: unload everything", 16, 652, 300, 16, 10).TextColor3 = colors.Muted
text(panel, "Walk speed (studs/sec)", 16, 305, 148, 30, 12).TextColor3 = colors.Muted
local speedMinus = button(panel, "SpeedMinus", "-", 166, 305, 32, 30)
local speedBox = new("TextBox", {
    Name = "SpeedValue", Position = UDim2.fromOffset(204, 305),
    Size = UDim2.fromOffset(68, 30), BackgroundColor3 = colors.Row,
    BorderSizePixel = 0, Text = tostring(state.WalkSpeed),
    ClearTextOnFocus = false, TextColor3 = colors.Text,
    TextSize = 14, Font = Enum.Font.GothamMedium,
}, panel)
round(speedBox)
local speedPlus = button(panel, "SpeedPlus", "+", 278, 305, 36, 30)
local speedPresets = {}
for index, value in ipairs({16, 32, 64, 100}) do
    speedPresets[value] = button(panel, "SpeedPreset_" .. value, tostring(value),
        16 + (index - 1) * 76, 345, 70, 26)
end
local openButton = button(gui, "Open", "Player Tools", 12, 12, 114, 34)
openButton.Visible = false
local function notify(message)
    status.Text = message
    statusUntil = os.clock() + 3
end
local function setVisible(visible)
    panel.Visible, openButton.Visible = visible, not visible
end
connect(hideButton.Activated, function() setVisible(false) end)
connect(openButton.Activated, function() setVisible(true) end)

-- Keep the panel usable on smaller screens and after a camera/viewport change.
local function fitPanel()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    scale.Scale = math.min(1, math.max(0.1, (viewport.X - 24) / 330),
        math.max(0.1, (viewport.Y - 80) / 676))
    panel.Position = UDim2.fromOffset(
        math.clamp(panel.Position.X.Offset, 0, math.max(0, viewport.X - 330 * scale.Scale)),
        math.clamp(panel.Position.Y.Offset, 0, math.max(0, viewport.Y - 676 * scale.Scale - 50)))
end
local dragging, dragStart, panelStart
connect(title.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, panelStart = input, input.Position, panel.Position
    end
end)
connect(Input.InputChanged, function(input)
    if dragging and (input == dragging or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.fromOffset(panelStart.X.Offset + delta.X, panelStart.Y.Offset + delta.Y)
        fitPanel()
    end
end)
connect(Input.InputEnded, function(input)
    if input == dragging or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = nil end
end)

local function body(player)
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and root:IsA("BasePart") and humanoid.Health > 0 then
        return character, humanoid, root
    end
    return nil
end

-- Speed: capture each Humanoid's actual speed, not a hard-coded reset to 16.
local function restoreSpeed()
    local humanoid, original = speedHumanoid, originalWalkSpeed
    speedHumanoid, originalWalkSpeed = nil, nil
    if humanoid and original ~= nil then
        pcall(function() humanoid.WalkSpeed = original end)
    end
end
local function applySpeed()
    if not alive or not state.Speed then restoreSpeed(); return end
    local _, humanoid = body(me)
    if humanoid ~= speedHumanoid then
        restoreSpeed()
        if humanoid then
            speedHumanoid, originalWalkSpeed = humanoid, humanoid.WalkSpeed
        end
    end
    if humanoid and humanoid.WalkSpeed ~= state.WalkSpeed then
        humanoid.WalkSpeed = state.WalkSpeed
    end
end

-- Noclip: cache character parts once, track additions, restore exact original values.
local function restorePart(part)
    local original = originalCollision[part]
    if original ~= nil then
        pcall(function() part.CanCollide = original end)
        originalCollision[part] = nil
    end
end
local function restoreCollisions()
    for part in pairs(originalCollision) do restorePart(part) end
end
local function trackCharacter(character)
    restoreSpeed()
    restoreCollisions()
    for _, connection in ipairs(characterConnections) do connection:Disconnect() end
    characterConnections, parts, currentCharacter = {}, {}, character
    if not character then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then parts[descendant] = true end
    end
    table.insert(characterConnections, character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then parts[descendant] = true end
    end))
    table.insert(characterConnections, character.DescendantRemoving:Connect(function(descendant)
        restorePart(descendant)
        parts[descendant] = nil
    end))
end
connect(RunService.PreSimulation, function()
    if not alive or not state.Noclip or not currentCharacter then return end
    local humanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then restoreCollisions(); return end
    for part in pairs(parts) do
        if part.Parent then
            if originalCollision[part] == nil then originalCollision[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
end)

-- Auto prompts: hold a single eligible prompt; never fake global keyboard input.
local function releasePrompt()
    local hold = activeHold
    activeHold = nil -- Clear first: InputHoldEnd can itself dispatch events.
    if hold then
        local record = promptCache[hold.prompt]
        if record then
            record.lastUsed = os.clock()
            record.nextTry = os.clock() + Config.PromptCooldown
        end
        pcall(function() hold.prompt:InputHoldEnd() end)
    end
end
-- HoldDuration = 0 removes the local timer for manual and automatic input.
-- This does not alter distance/visibility requirements or server-side game logic.
local function restorePromptDuration(prompt, record)
    local original = record.originalHoldDuration
    record.originalHoldDuration = nil
    if original ~= nil then
        pcall(function()
            -- Preserve a newer game-side value if it changed since our last pass.
            if prompt.HoldDuration == 0 then prompt.HoldDuration = original end
        end)
    end
end
local function syncPromptDuration(prompt, record)
    if state.InstantPrompts and prompt:IsDescendantOf(Workspace)
        and prompt:GetAttribute("PlayerToolsIgnore") ~= true then
        local current = prompt.HoldDuration
        if record.originalHoldDuration == nil or current ~= 0 then
            record.originalHoldDuration = current
        end
        if current ~= 0 then prompt.HoldDuration = 0 end
    else
        restorePromptDuration(prompt, record)
    end
end
local function syncAllPromptDurations()
    for prompt, record in pairs(promptCache) do syncPromptDuration(prompt, record) end
end
local function syncDirtyPromptDurations()
    -- Property callbacks queue work instead of recursively fighting other scripts.
    local pending = dirtyPrompts
    dirtyPrompts = {}
    for prompt in pairs(pending) do
        local record = promptCache[prompt]
        if record then syncPromptDuration(prompt, record) end
    end
end
local function cachePrompt(object)
    if not object:IsA("ProximityPrompt") or promptCache[object] then return end
    local record = { nextTry = 0, lastUsed = 0, completed = false }
    promptCache[object] = record
    record.durationConnection = object:GetPropertyChangedSignal("HoldDuration"):Connect(function()
        if alive and state.InstantPrompts then
            if record.originalHoldDuration ~= nil and object.HoldDuration ~= 0 then
                record.originalHoldDuration = object.HoldDuration
            end
            dirtyPrompts[object] = true
        end
    end)
    record.ignoreConnection = object:GetAttributeChangedSignal("PlayerToolsIgnore"):Connect(function()
        if alive then dirtyPrompts[object] = true end
    end)
    syncPromptDuration(object, record)
end
local function uncachePrompt(object)
    local record = promptCache[object]
    if not record then return end
    if activeHold and activeHold.prompt == object then releasePrompt() end
    record.durationConnection:Disconnect()
    record.ignoreConnection:Disconnect()
    restorePromptDuration(object, record)
    promptCache[object], dirtyPrompts[object] = nil, nil
end
local function promptPosition(prompt)
    local host = prompt.Parent
    if not host then return nil end
    if host:IsA("Attachment") then return host.WorldPosition, host.Parent end
    if host:IsA("BasePart") then return host.Position, host end
    if host:IsA("Model") and host.PrimaryPart then return host.PrimaryPart.Position, host end
    return nil
end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function eligible(prompt, record, character, root)
    if not prompt:IsDescendantOf(Workspace) then return nil end
    local position, host = promptPosition(prompt)
    if not position then return nil end
    local distance = (root.Position - position).Magnitude
    if distance > prompt.MaxActivationDistance then
        record.completed = false -- Re-arm once you leave and approach again.
        return nil
    end
    if not prompt.Enabled or prompt:IsDescendantOf(character) then return nil end
    if prompt:GetAttribute("PlayerToolsIgnore") == true then return nil end
    if Config.OnlyEPrompts and prompt.KeyboardKeyCode ~= Enum.KeyCode.E then return nil end
    if prompt.RequiresLineOfSight then
        local camera = Workspace.CurrentCamera
        if not camera then return nil end
        local origin = camera.CFrame.Position
        rayParams.FilterDescendantsInstances = { character }
        local hit = Workspace:Raycast(origin, position - origin, rayParams)
        if hit and hit.Instance ~= host and not hit.Instance:IsDescendantOf(host) then return nil end
    end
    return distance
end
local function stepPrompts(now)
    local character, _, root = body(me)
    if not state.AutoPrompts or not focused or Input:GetFocusedTextBox() or not Prompts.Enabled or not character then
        releasePrompt()
        return "Auto prompts: " .. (state.AutoPrompts and "paused / waiting" or "off")
    end
    if activeHold then
        local hold = activeHold
        local record = promptCache[hold.prompt]
        if not record or not eligible(hold.prompt, record, character, root) then
            releasePrompt()
            return "Auto prompts: interrupted"
        end
        local elapsed = now - hold.started
        if hold.triggered or hold.instant or elapsed >= math.max(0, hold.prompt.HoldDuration) + 0.25 then
            releasePrompt()
            return hold.triggered and "Auto prompts: local trigger sent" or "Auto prompts: input sent; game decides result"
        end
        return string.format("Holding: %s  %.1f / %.1fs", hold.prompt.ActionText, elapsed, hold.prompt.HoldDuration)
    end
    local best, bestRecord, bestDistance
    for prompt, record in pairs(promptCache) do
        local distance = eligible(prompt, record, character, root)
        if distance and now >= record.nextTry and (Config.RepeatPrompts or not record.completed) then
            if not best or record.lastUsed < bestRecord.lastUsed
                or (record.lastUsed == bestRecord.lastUsed and distance < bestDistance) then
                best, bestRecord, bestDistance = prompt, record, distance
            end
        end
    end
    if best then
        -- Re-check immediately before input in case game code changed the timer.
        syncPromptDuration(best, bestRecord)
        local hold = { prompt = best, started = now, triggered = false, instant = best.HoldDuration <= 0 }
        activeHold = hold
        local ok, err = pcall(function() best:InputHoldBegin() end)
        if not ok then
            releasePrompt()
            warn("Player Tools prompt: " .. tostring(err))
        elseif activeHold == hold and hold.triggered then
            releasePrompt()
        end
        -- Otherwise release on the next prompt tick, allowing deferred engine events.
        -- Zero-hold prompts never wait for their previous configured duration.
    end
    return best and "Auto prompts: interacting" or "Auto prompts: waiting for nearby prompts"
end
connect(Workspace.DescendantAdded, cachePrompt)
connect(Workspace.DescendantRemoving, uncachePrompt)
for _, object in ipairs(Workspace:GetDescendants()) do cachePrompt(object) end
connect(Prompts.PromptTriggered, function(prompt, player)
    if player ~= me then return end
    local record = promptCache[prompt]
    if record then record.completed = true end
    if activeHold and activeHold.prompt == prompt then activeHold.triggered = true end
end)
connect(Input.WindowFocusReleased, function() focused = false; dragging = nil; releasePrompt() end)
connect(Input.WindowFocused, function() focused = true end)
connect(me.CharacterAdded, function(character) releasePrompt(); trackCharacter(character) end)
connect(me.CharacterRemoving, function(character)
    if character == currentCharacter then releasePrompt(); trackCharacter(nil) end
end)
trackCharacter(me.Character)

-- ESP / player picker: no respawn waits, default-name edits, or duplicate loops.
local function updateSelection()
    local query = string.lower(search.Text)
    local count = 0
    for player, entry in pairs(entries) do
        entry.row.Visible = query == "" or string.find(string.lower(player.Name .. " " .. player.DisplayName), query, 1, true) ~= nil
        entry.row.BackgroundColor3 = player == selectedPlayer and colors.Accent or colors.Row
        if entry.row.Visible then count = count + 1 end
    end
    empty.Visible = count == 0
    teleportButton.Text = selectedPlayer and ("Teleport to @" .. selectedPlayer.Name) or "Select a player above"
end
local function addPlayer(player)
    if player == me or entries[player] then return end
    local highlight = new("Highlight", {
        Name = "ESP_" .. player.UserId, Enabled = false,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillTransparency = 0.65, OutlineTransparency = 0,
    }, effects)
    local billboard = new("BillboardGui", {
        Name = "Name_" .. player.UserId, Enabled = false, AlwaysOnTop = true,
        Size = UDim2.fromOffset(250, 45), StudsOffsetWorldSpace = Vector3.new(0, 2.7, 0),
        MaxDistance = Config.ESPMaxDistance,
    }, effects)
    local tag = text(billboard, "", 0, 0, 250, 45, 13)
    tag.TextXAlignment = Enum.TextXAlignment.Center
    tag.TextStrokeTransparency = 0.25
    tag.TextStrokeColor3 = Color3.new(0, 0, 0)
    local row = button(list, player.Name, player.DisplayName .. "  (@" .. player.Name .. ")", 0, 0, 288, 30)
    row.TextTruncate = Enum.TextTruncate.AtEnd
    local entry = { highlight = highlight, billboard = billboard, tag = tag, row = row }
    entries[player] = entry
    entry.connection = row.Activated:Connect(function() selectedPlayer = player; updateSelection() end)
    updateSelection()
end
local function removePlayer(player)
    local entry = entries[player]
    if entry then
        entry.connection:Disconnect()
        entry.highlight:Destroy(); entry.billboard:Destroy(); entry.row:Destroy()
        entries[player] = nil
    end
    if selectedPlayer == player then selectedPlayer = nil end
    updateSelection()
end
local function updateESP()
    local _, _, myRoot = body(me)
    for player, entry in pairs(entries) do
        local character, humanoid, root = body(player)
        local distance = root and myRoot and (root.Position - myRoot.Position).Magnitude or nil
        local show = state.ESP and character ~= nil and (distance == nil or distance <= Config.ESPMaxDistance)
        entry.highlight.Enabled, entry.billboard.Enabled = show, show
        if show then
            local friendly = not me.Neutral and not player.Neutral and me.Team ~= nil and me.Team == player.Team
            local color = friendly and Config.FriendColor or Config.EnemyColor
            if Config.UseTeamColor and not player.Neutral and player.Team then color = player.TeamColor.Color end
            entry.highlight.Adornee = character
            entry.highlight.FillColor, entry.highlight.OutlineColor = color, color
            entry.billboard.Adornee = character:FindFirstChild("Head") or root
            entry.tag.TextColor3 = color
            entry.tag.Text = string.format("%s (@%s)\n%d / %d HP  |  %s", player.DisplayName, player.Name,
                math.floor(humanoid.Health), math.floor(humanoid.MaxHealth),
                distance and (math.floor(distance) .. " studs") or "distance unavailable")
        else
            entry.highlight.Adornee, entry.billboard.Adornee = nil, nil
        end
    end
end
connect(Players.PlayerAdded, addPlayer)
connect(Players.PlayerRemoving, removePlayer)
connect(search:GetPropertyChangedSignal("Text"), updateSelection)
for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end
updateSelection()

-- Independent toggles; changes take effect without replacing the UI.
local toggleButtons = {}
local function setToggle(key, enabled)
    state[key] = enabled
    local item = toggleButtons[key]
    item.button.Text = item.label .. "   [" .. (enabled and "ON" or "OFF") .. "]"
    item.button.BackgroundColor3 = enabled and colors.On or colors.Row
    if key == "Noclip" and not enabled then restoreCollisions() end
    if key == "AutoPrompts" and not enabled then releasePrompt() end
    if key == "InstantPrompts" then
        releasePrompt()
        syncAllPromptDurations()
    end
    if key == "Speed" then applySpeed() end
    if key == "ESP" then updateESP() end
    if key == "Noclip" and enabled then notify("Noclip also disables floor collision. Toggle off before landing.") end
end
for index, item in ipairs({
    { "ESP", "Player ESP", "K" }, { "InfiniteJump", "Infinite jump", "J" },
    { "Noclip", "Noclip", "N" }, { "AutoPrompts", "Auto proximity prompts", "P" },
    { "InstantPrompts", "Instant prompts (local)", "I" }, { "Speed", "Custom walk speed", "F" },
}) do
    local key = item[1]
    local b = button(panel, "Toggle_" .. key, "", 16, 73 + (index - 1) * 37, 298, 31)
    toggleButtons[key] = { button = b, label = item[2] .. " (" .. item[3] .. ")" }
    connect(b.Activated, function() setToggle(key, not state[key]) end)
    setToggle(key, state[key])
end
local function setSpeed(value)
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge then
        speedBox.Text = tostring(state.WalkSpeed)
        notify("Enter a finite speed from " .. Config.MinWalkSpeed .. " to " .. Config.MaxWalkSpeed .. ".")
        return
    end
    state.WalkSpeed = math.clamp(math.floor(number + 0.5), Config.MinWalkSpeed, Config.MaxWalkSpeed)
    speedBox.Text = tostring(state.WalkSpeed)
    setToggle("Speed", true)
    notify("Walk speed: " .. state.WalkSpeed .. ". Press F to restore the original speed.")
end
connect(speedBox.FocusLost, function() setSpeed(speedBox.Text) end)
connect(speedMinus.Activated, function() setSpeed(state.WalkSpeed - Config.SpeedStep) end)
connect(speedPlus.Activated, function() setSpeed(state.WalkSpeed + Config.SpeedStep) end)
for value, preset in pairs(speedPresets) do
    local speed = value
    connect(preset.Activated, function() setSpeed(speed) end)
end
local hotkeys = {
    [Enum.KeyCode.K] = "ESP", [Enum.KeyCode.J] = "InfiniteJump",
    [Enum.KeyCode.N] = "Noclip", [Enum.KeyCode.P] = "AutoPrompts",
    [Enum.KeyCode.I] = "InstantPrompts", [Enum.KeyCode.F] = "Speed",
}
connect(Input.InputBegan, function(input, processed)
    if Input:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.RightShift then setVisible(not panel.Visible); return end
    if processed then return end
    local key = hotkeys[input.KeyCode]
    if key then setToggle(key, not state[key]) end
end)
connect(Input.JumpRequest, function()
    if not alive or not focused or not state.InfiniteJump or Input:GetFocusedTextBox() then return end
    local now = os.clock()
    if now - lastJump < Config.JumpCooldown then return end
    local character, humanoid, root = body(me)
    if not character or humanoid.Sit or humanoid.PlatformStand or root.Anchored then return end
    local speed = humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * Workspace.Gravity * humanoid.JumpHeight)
    if speed <= 0 then return end
    lastJump = now
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    local velocity = root.AssemblyLinearVelocity
    root.AssemblyLinearVelocity = Vector3.new(velocity.X, speed, velocity.Z)
end)
connect(teleportButton.Activated, function()
    if not selectedPlayer or selectedPlayer.Parent ~= Players then notify("Select an available player first."); return end
    local character, humanoid, root = body(me)
    local targetCharacter, _, targetRoot = body(selectedPlayer)
    if not character then notify("Your character is not ready."); return end
    if not targetCharacter then notify("Target is dead, loading, or not streamed to your client."); return end
    if humanoid.SeatPart or root.Anchored then notify("Leave your seat / wait until your character can move."); return end
    releasePrompt()
    local ok, err = pcall(function()
        local rootToPivot = root.CFrame:ToObjectSpace(character:GetPivot())
        character:PivotTo(targetRoot.CFrame * CFrame.new(4, 1, 0) * rootToPivot)
        root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    end)
    notify(ok and ("Moved beside @" .. selectedPlayer.Name .. ". Server rules still apply.") or ("Teleport error: " .. tostring(err)))
end)

local espTimer, promptTimer, layoutTimer, speedTimer = 0, 0, 0, 0
connect(RunService.Heartbeat, function(dt)
    if not alive then return end
    espTimer, promptTimer, layoutTimer = espTimer + dt, promptTimer + dt, layoutTimer + dt
    speedTimer = speedTimer + dt
    if speedTimer >= Config.SpeedInterval then speedTimer = 0; applySpeed() end
    if espTimer >= Config.ESPInterval then espTimer = 0; updateESP() end
    if promptTimer >= Config.PromptInterval then
        promptTimer = 0
        syncDirtyPromptDurations()
        local description = stepPrompts(os.clock())
        if os.clock() >= statusUntil then status.Text = description end
    end
    if layoutTimer >= 0.5 then layoutTimer = 0; fitPanel() end
end)
local function cleanup()
    if not alive then return end
    alive = false
    releasePrompt()
    restoreSpeed()
    restoreCollisions()
    for prompt in pairs(promptCache) do uncachePrompt(prompt) end
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for _, connection in ipairs(characterConnections) do connection:Disconnect() end
    for _, entry in pairs(entries) do entry.connection:Disconnect() end
    effects:Destroy()
    gui:Destroy()
end
shutdown.OnInvoke = function() cleanup(); return true end
connect(exitButton.Activated, cleanup)
connect(gui.Destroying, cleanup)
fitPanel()
updateESP()
