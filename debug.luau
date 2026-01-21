--[[
    NexusUI Debug Loader
    This script will identify exactly what's wrong with the compiled file
]]

print("=== NexusUI Debug Loader ===")
print("")

-- Step 1: Try to download the file
print("[1] Downloading file...")
local url = "https://raw.githubusercontent.com/alexkkork/luau/main/lua.luau"
local success, content = pcall(function()
    return game:HttpGet(url)
end)

if not success then
    print("ERROR: Failed to download file!")
    print("Error:", content)
    return
end

print("SUCCESS: Downloaded", #content, "bytes")
print("")

-- Step 2: Check basic file info
print("[2] File Info:")
print("  - Length:", #content, "characters")
print("  - Lines:", select(2, content:gsub("\n", "\n")) + 1)
print("")

-- Step 3: Try loadstring
print("[3] Testing loadstring...")
local func, err = loadstring(content)

if func then
    print("SUCCESS: loadstring compiled the code!")
    print("")
    
    -- Step 4: Try to execute
    print("[4] Executing...")
    local execSuccess, execResult = pcall(func)
    
    if execSuccess then
        print("SUCCESS: Code executed!")
        print("Result type:", type(execResult))
        if type(execResult) == "table" then
            print("Table keys:")
            for k, v in pairs(execResult) do
                print("  -", k, ":", type(v))
            end
        end
    else
        print("ERROR: Execution failed!")
        print("Error:", execResult)
    end
else
    print("ERROR: loadstring failed!")
    print("Error:", err)
    print("")
    
    -- Try to find the error location
    print("[4] Analyzing error...")
    
    -- Parse the error message for line number
    local lineNum = err:match(":(%d+):")
    if lineNum then
        lineNum = tonumber(lineNum)
        print("Error is around line:", lineNum)
        print("")
        
        -- Show context around error
        print("[5] Code around error (lines", lineNum - 5, "to", lineNum + 5, "):")
        print("----------------------------------------")
        
        local lines = {}
        for line in content:gmatch("[^\n]*") do
            table.insert(lines, line)
        end
        
        for i = math.max(1, lineNum - 5), math.min(#lines, lineNum + 5) do
            local prefix = i == lineNum and ">>> " or "    "
            local lineContent = lines[i] or ""
            if #lineContent > 80 then
                lineContent = lineContent:sub(1, 77) .. "..."
            end
            print(prefix .. i .. ": " .. lineContent)
        end
        print("----------------------------------------")
    end
    
    -- Additional diagnostics
    print("")
    print("[6] Additional diagnostics:")
    
    -- Count keywords
    local funcCount = select(2, content:gsub("function", "function"))
    local endCount = select(2, content:gsub("%f[%a]end%f[%A]", "end"))
    
    print("  - 'function' count:", funcCount)
    print("  - 'end' count:", endCount)
    print("  - Difference:", funcCount - endCount)
    
    -- Check first 1000 chars
    print("")
    print("[7] First 500 characters:")
    print("----------------------------------------")
    print(content:sub(1, 500))
    print("----------------------------------------")
end

print("")
print("=== Debug Complete ===")
