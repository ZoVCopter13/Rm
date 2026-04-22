-- ========== RM LOADER ==========
-- Загрузчик с проверкой ключа
-- После успешного ввода запускает основной скрипт

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

-- Поле для ввода ключа
local KeyInput = MainTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Введите ключ...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        -- Сохраняем введённый ключ в переменную
        _G.EnteredKey = text
    end
})

-- Кнопка активации
MainTab:CreateButton({
    Name = "Activate Script",
    Callback = function()
        local key = _G.EnteredKey or ""
        -- Проверка ключа (здесь можно заменить на свою логику)
        -- Пример: ключ должен быть "da" (как в основном скрипте)
        if key == "da" then
            notify("Success", "Key accepted! Loading main script...", 2)
            task.wait(1)
            -- Запускаем основной скрипт
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ZoVCopter13/Rm/refs/heads/main/script.lua"))()
            end)
            if success then
                -- Закрываем окно лоадера после успешной загрузки
                LoaderWindow:Destroy()
            else
                notify("Error", "Failed to load main script: " .. tostring(err), 5)
            end
        else
            notify("Invalid Key", "The key you entered is incorrect.", 3)
        end
    end
})

-- Информация
MainTab:CreateButton({
    Name = "Info",
    Callback = function()
        notify("Info", "Get your key from discord.gg/Fqkp4xtMty", 5)
    end
})

notify("RM Loader", "Enter the key and click Activate Script", 3)
