-- ========== RM LOADER (С ЗАПОМИНАНИЕМ КЛЮЧА) ==========
-- Сохраняет ключ в файл, при повторном запуске проверяет сохранённый ключ

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создаём окно лоадера
local LoaderWindow = Rayfield:CreateWindow({
    Name = "RM Loader",
    Icon = 0,
    LoadingTitle = "RM Loader",
    LoadingSubtitle = "by NAGIEV",
    Theme = "Default",
    ToggleUIKeybind = "L",
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

-- Функция уведомлений
local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3
    })
end

-- Проверяем, поддерживает ли экзекутор readfile/writefile
local function canSave()
    pcall(function()
        writefile("test.txt", "test")
        delfile("test.txt")
    end)
    return pcall(function() return readfile end) and pcall(function() return writefile end)
end

local saveSupported = canSave()
local SAVE_FILE = "RM_Key.txt"

-- Функция для сохранения ключа
local function saveKey(key)
    if saveSupported then
        pcall(function()
            writefile(SAVE_FILE, key)
        end)
    end
end

-- Функция для загрузки сохранённого ключа
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

-- Функция для удаления сохранённого ключа (если нужно)
local function deleteSavedKey()
    if saveSupported then
        pcall(function()
            delfile(SAVE_FILE)
        end)
    end
end

-- Функция запуска основного скрипта
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

-- Проверка ключа
local function validateKey(key)
    -- Здесь можно изменить условие проверки ключа
    -- Например: проверка через удалённый сервер, сравнение с массивом ключей и т.д.
    local validKeys = {"da"} -- Список валидных ключей
    for _, validKey in ipairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- Основная функция проверки и запуска
local function checkAndRun()
    local savedKey = loadSavedKey()
    if savedKey and validateKey(savedKey) then
        -- Ключ есть и он правильный -> запускаем сразу
        notify("Auto-Login", "Saved key found! Loading main script...", 2)
        loadMainScript()
        return true
    end
    return false
end

-- Пытаемся запустить с сохранённым ключом
if checkAndRun() then
    return -- Скрипт запущен, выходим
end

-- Если сохранённого ключа нет или он невалидный, показываем интерфейс ввода
notify("RM Loader", "Enter your key to continue", 3)

-- Поле для ввода ключа
local KeyInput = MainTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Введите ключ...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        _G.EnteredKey = text
    end
})

-- Кнопка активации
MainTab:CreateButton({
    Name = "Activate Script",
    Callback = function()
        local key = _G.EnteredKey or ""
        if validateKey(key) then
            saveKey(key) -- Сохраняем правильный ключ
            notify("Success", "Key accepted! Loading main script...", 2)
            loadMainScript()
        else
            notify("Invalid Key", "The key you entered is incorrect.", 3)
        end
    end
})

-- Кнопка для сброса сохранённого ключа (на случай, если ключ протух)
MainTab:CreateButton({
    Name = "Reset Saved Key",
    Callback = function()
        deleteSavedKey()
        notify("Reset", "Saved key has been deleted. Restart the script to enter a new key.", 3)
    end
})

-- Информация
MainTab:CreateButton({
    Name = "Info",
    Callback = function()
        notify("Info", "Get your key from discord.gg/Fqkp4xtMty\n.", 5)
    end
})
