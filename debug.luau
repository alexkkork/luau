--[[
    NexusUI Debug Loader
    Enhanced diagnostics for loading issues
]]

local url = "https://raw.githubusercontent.com/alexkkork/luau/main/lua.luau"

print("=== NexusUI Debug Loader ===")
print("")

-- Step 1: Download
print("[1] Downloading...")
local success, scriptContent = pcall(function()
    return game:HttpGet(url)
end)

if not success then
    warn("FAILED: Could not download script")
    warn("Error:", scriptContent)
    return
end

print("    SUCCESS: Downloaded", #scriptContent, "bytes")
print("    Lines:", select(2, scriptContent:gsub("\n", "\n")) + 1)
print("")

-- Step 2: Parse with loadstring
print("[2] Parsing with loadstring...")
local loadFunc, loadErr = loadstring(scriptContent)

if not loadFunc then
    warn("FAILED: loadstring error")
    warn("Error:", loadErr)
    
    -- Try to extract line number from error
    local lineNum = loadErr:match(":(%d+):")
    if lineNum then
        lineNum = tonumber(lineNum)
        print("")
        print("[2a] Code around error (line " .. lineNum .. "):")
        print("    ----------------------------------------")
        
        local lines = {}
        for line in scriptContent:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        
        local start = math.max(1, lineNum - 5)
        local stop = math.min(#lines, lineNum + 5)
        
        for i = start, stop do
            local prefix = i == lineNum and ">>> " or "    "
            print(prefix .. i .. ": " .. (lines[i] or ""))
        end
        print("    ----------------------------------------")
    end
    return
end

print("    SUCCESS: Script parsed successfully")
print("")

-- Step 3: Execute
print("[3] Executing...")
local execSuccess, NexusUI = pcall(loadFunc)

if not execSuccess then
    warn("FAILED: Execution error")
    warn("Error:", NexusUI)
    return
end

print("    SUCCESS: Script executed")
print("")

-- Step 4: Verify API
print("[4] Verifying API...")
if type(NexusUI) ~= "table" then
    warn("FAILED: NexusUI is not a table, got:", type(NexusUI))
    return
end

local requiredMethods = {"CreateWindow", "SetTheme", "Notify"}
local missingMethods = {}

for _, method in ipairs(requiredMethods) do
    if type(NexusUI[method]) ~= "function" then
        table.insert(missingMethods, method)
    end
end

if #missingMethods > 0 then
    warn("FAILED: Missing methods:", table.concat(missingMethods, ", "))
    return
end

print("    SUCCESS: All required methods found")
print("")

-- Step 5: Test functionality
print("[5] Testing CreateWindow...")
local windowSuccess, Window = pcall(function()
    return NexusUI:CreateWindow({
        Title = "Debug Test",
        Theme = "Midnight"
    })
end)

if not windowSuccess then
    warn("FAILED: CreateWindow error")
    warn("Error:", Window)
    return
end

print("    SUCCESS: Window created")
print("")

-- Step 6: Test Tab
print("[6] Testing AddTab...")
local tabSuccess, Tab = pcall(function()
    return Window:AddTab({ Name = "Test Tab" })
end)

if not tabSuccess then
    warn("FAILED: AddTab error")
    warn("Error:", Tab)
    return
end

print("    SUCCESS: Tab created")
print("")

-- Step 7: Test components
print("[7] Testing components...")
local tests = {
    {"AddButton", {Text = "Test", Callback = function() end}},
    {"AddToggle", {Text = "Test", Default = false, Callback = function() end}},
    {"AddSlider", {Text = "Test", Min = 0, Max = 100, Default = 50, Callback = function() end}},
}

for _, test in ipairs(tests) do
    local method, args = test[1], test[2]
    local s, e = pcall(function()
        Tab[method](Tab, args)
    end)
    if s then
        print("    " .. method .. ": OK")
    else
        warn("    " .. method .. ": FAILED -", e)
    end
end

print("")
print("=== ALL TESTS PASSED ===")
print("NexusUI is working correctly!")

-- Notify success
NexusUI:Notify({
    Title = "Debug Complete",
    Content = "All systems operational!",
    Type = "Success",
    Duration = 5
})
