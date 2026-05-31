-- ==========RM LOADER==========


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local LoaderWindow = Rayfield:CreateWindow({
    Name = "RM Loader",
    Icon = 0,
    LoadingTitle = "RM Loader",
    LoadingSubtitle = "by NAGIEV",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local MainTab = LoaderWindow:CreateTab("Key System", 4483362458)


local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3
    })
end


local function canSave()
    pcall(function()
        writefile("test.txt", "test")
        delfile("test.txt")
    end)
    return pcall(function() return readfile end) and pcall(function() return writefile end)
end

local saveSupported = canSave()
local SAVE_FILE = "RM_Key.txt"


local function saveKey(key)
    if saveSupported then
        pcall(function()
            writefile(SAVE_FILE, key)
        end)
    end
end


local function loadSavedKey()
    if saveSupported then
        local success, result = pcall(function()
            return readfile(SAVE_FILE)
        end)
        if success and result and result ~= "" then
            return result
        end
    end
    return nil
end


local function deleteSavedKey()
    if saveSupported then
        pcall(function()
            delfile(SAVE_FILE)
        end)
    end
end


local function loadMainScript()
    notify("Loading", "Starting main script...", 2)
    task.wait(0.5)
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZoVCopter13/Rm/refs/heads/main/script.lua"))()
    end)
    if success then
        LoaderWindow:Destroy()
    else
        notify("Error", "Failed to load main script: " .. tostring(err), 5)
    end
end


local function validateKey(key)

    local validKeys = {"da"} 
    for _, validKey in ipairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end


local function checkAndRun()
    local savedKey = loadSavedKey()
    if savedKey and validateKey(savedKey) then
  
        notify("Auto-Login", "Saved key found! Loading main script...", 2)
        loadMainScript()
        return true
    end
    return false
end


if checkAndRun() then
    return 
end


notify("RM Loader", "Enter your key to continue", 3)


local KeyInput = MainTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Введите ключ...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        _G.EnteredKey = text
    end
})


MainTab:CreateButton({
    Name = "Activate Script",
    Callback = function()
        local key = _G.EnteredKey or ""
        if validateKey(key) then
            saveKey(key) 
            notify("Success", "Key accepted! Loading main script...", 2)
            loadMainScript()
        else
            notify("Invalid Key", "The key you entered is incorrect.", 3)
        end
    end
})


MainTab:CreateButton({
    Name = "Reset Saved Key",
    Callback = function()
        deleteSavedKey()
        notify("Reset", "Saved key has been deleted. Restart the script to enter a new key.", 3)
    end
})


MainTab:CreateButton({
    Name = "Info",
    Callback = function()
        notify("Info", "Get your key from discord.gg/Fqkp4xtMty\n.", 5)
    end
})
