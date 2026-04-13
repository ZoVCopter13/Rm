--OPEN SOURCE
--RM


--OPEN SOURCE
--RM

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RM",
   Icon = 0,
   LoadingTitle = "ZoV",
   LoadingSubtitle = "by NAGIEV",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "ZOVCOPTER"
   },
   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/Fqkp4xtMty",
      RememberJoins = false
   },
   KeySystem = true,
   KeySettings = {
      Title = "RM key system",
      Subtitle = "Key System",
      Note = "join to discord https://discord.gg/Fqkp4xtMty",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"da"}
   }
})


-- Создание всех вкладок
local Tab = Window:CreateTab("main", 4483362458)
local PlayerTab = Window:CreateTab("player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local TeleportsTab = Window:CreateTab("teleports 1", 4483362458)
local FixTowerTab = Window:CreateTab("auto wire", 4483362458)
local NightTab = Window:CreateTab("night 2", 4483362458)
local Night3Tab = Window:CreateTab("night 3 teleports", 4483362458)
local SpiritHelperTab = Window:CreateTab("spirit helper", 4483362458)
local MansionMainTab = Window:CreateTab("main mansion", 4483362458)
local MansionTeleportsTab = Window:CreateTab("mansion teleports", 4483362458)
local BunkerTab = Window:CreateTab("bunker", 4483362458)
local ItemGrabberTab = Window:CreateTab("item grabber", 4483362458)
-- Переменные
local oxygenLoopRunning = false
local coldDisabled = false
local sprintLoopRunning = false
local noclipEnabled = false
local noclipConnections = {}
local tpwalking = false
local tpwalkSpeed = 4
local RunService = game:GetService("RunService")

-- Функция уведомлений
local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2.5
    })
end

-- Универсальная функция телепортации
local function teleportTo(cf)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if type(cf) == "Vector3" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(cf)
        else
            player.Character.HumanoidRootPart.CFrame = cf
        end
        return true
    end
    return false
end

-- TpWalk функции
local function startTPWalk(speed)
    tpwalking = true
    tpwalkSpeed = speed or 4
    local player = game.Players.LocalPlayer
    task.spawn(function()
        while tpwalking do
            local char = player.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if not hum or not hum.Parent then
                tpwalking = false
                break
            end
            local delta = RunService.Heartbeat:Wait()
            if hum.MoveDirection.Magnitude > 0 then
                pcall(function()
                    char:TranslateBy(hum.MoveDirection * tpwalkSpeed * delta * 10)
                end)
            end
            if not player.Character or player.Character ~= char then
                tpwalking = false
            end
        end
    end)
end

local function stopTPWalk()
    tpwalking = false
end

-- ========== MAIN TAB ==========
local ButtonOxygen = Tab:CreateButton({
   Name = "Infinity oxygen",
   Callback = function()
       oxygenLoopRunning = not oxygenLoopRunning
       notify("Infinity oxygen", oxygenLoopRunning and "on" or "off")
       if oxygenLoopRunning then
           task.spawn(function()
               while oxygenLoopRunning do
                   task.wait(0.1)
                   local player = game.Players.LocalPlayer
                   if player and player.Character then
                       local oxygen = player.Character:FindFirstChild("Breath")
                       if oxygen then
                           oxygen.Value = 100
                       end
                   end
               end
           end)
       end
   end
})

local ButtonDisableCold = Tab:CreateButton({
   Name = "disable cold",
   Callback = function()
       coldDisabled = not coldDisabled
       local success, result = pcall(function()
           local replicatedStorage = game:GetService("ReplicatedStorage")
           local gameState = replicatedStorage:FindFirstChild("GameState")
           if gameState then
               local blizzard = gameState:FindFirstChild("Blizzard")
               if blizzard then
                   blizzard.Value = false
                   return true, "Blizzard disabled"
               else
                   return false, "Blizzard not found"
               end
           else
               return false, "GameState not found"
           end
       end)
       if success and result == true then
           notify("Disable Cold", "Cold effect disabled", 2)
       else
           local altSuccess, altResult = pcall(function()
               local blizzard = game:GetService("ReplicatedStorage"):FindFirstChild("Blizzard", true)
               if blizzard and blizzard:IsA("BoolValue") then
                   blizzard.Value = false
                   return true
               end
               for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                   if obj.Name == "Blizzard" and obj:IsA("BoolValue") then
                       obj.Value = false
                       return true
                   end
               end
               return false
           end)
           if altSuccess then
               notify("Disable Cold", "Cold effect disabled", 2)
           else
               notify("Disable Cold", "Failed to disable cold: " .. tostring(result), 3)
           end
       end
   end
})

local ButtonInfinityHunger = Tab:CreateButton({
   Name = "Infinity hunger",
   Callback = function()
       local success = pcall(function()
           local player = game.Players.LocalPlayer
           local statusUI = player.PlayerGui:FindFirstChild("StatusUI")
           if statusUI then
               local foodBG = statusUI:FindFirstChild("FoodBG")
               if foodBG then
                   foodBG.Visible = false
               end
           end
           local replicatedStorage = game:GetService("ReplicatedStorage")
           local gameState = replicatedStorage:FindFirstChild("GameState")
           if gameState then
               local weirdStrict = gameState:FindFirstChild("WeirdStrict")
               if weirdStrict then
                   weirdStrict.Value = false
               end
               local totalModifiers = gameState:FindFirstChild("TotalModifiers")
               if totalModifiers then
                   totalModifiers.Value = 0
               end
           end
       end)
       if success then
           notify("Infinity hunger", "on", 2)
       else
           notify("Infinity hunger", "Failed to enable", 2)
       end
   end
})

local function generateRandomName()
    local length = math.random(20, 35)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local randomIndex = math.random(1, #chars)
        result = result .. string.sub(chars, randomIndex, randomIndex)
    end
    return result
end

local ButtonRenameKick = Tab:CreateButton({
   Name = "Rename Kick Remote",
   Callback = function()
       local success = pcall(function()
           local replicatedStorage = game:GetService("ReplicatedStorage")
           local remotes = replicatedStorage:FindFirstChild("Remotes")
           
           local kickRemote = nil
           
           if remotes then
               kickRemote = remotes:FindFirstChild("Kick")
           end
           
           if not kickRemote then
               kickRemote = replicatedStorage:FindFirstChild("Kick")
           end
           
           if kickRemote then
               local newName = generateRandomName()
               kickRemote.Name = newName
               notify("Anti Cheat", "Kick remote renamed to: " .. newName, 3)
           else
               notify("Anti Cheat", "Kick remote not found", 2)
           end
       end)
       
       if not success then
           notify("Anti Cheat", "Failed to rename kick remote", 2)
       end
   end
})

local ButtonRemoveBarriers = Tab:CreateButton({
   Name = "Remove All Barriers",
   Callback = function()
       local success = pcall(function()
           local doors = workspace:FindFirstChild("Doors")
           if doors then
               local removed = 0
               for _, closet in pairs(doors:GetChildren()) do
                   if closet.Name == "Closet" and closet:FindFirstChild("Ignore") then
                       closet.Ignore:Destroy()
                       removed = removed + 1
                   end
               end
               notify("Barriers", "Removed " .. removed .. " closet barriers", 2)
           else
               notify("Barriers", "Doors folder not found", 2)
           end
       end)
       
       if not success then
           notify("Barriers", "Failed to remove barriers", 2)
       end
   end
})

local ButtonInfo = Tab:CreateButton({
   Name = "Info",
   Callback = function()
       notify("Info", "script ZOVCOPTER by NAGIEV", 5)
   end
})

-- ========== PLAYER TAB ==========
local sprintButton
local noclipButton

-- Переменные для ноклипа (из Infinite Yield)
local noclipEnabled = false
local noclipConnection = nil
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Функции для обновления кнопок
local function updateSprintButton()
    if sprintButton then
        sprintButton:Set(sprintLoopRunning and "Infinity sprint (ON)" or "Infinity sprint")
    end
end

local function updateNoclipButton()
    if noclipButton then
        noclipButton:Set(noclipEnabled and "Noclip (ON)" or "Noclip")
    end
end

-- Функции для спринта
local function startSprint()
    sprintLoopRunning = true
    updateSprintButton()
    notify("Infinity sprint", "on", 1)
    task.spawn(function()
        while sprintLoopRunning do
            task.wait(0.1)
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local sprint = player.Character:FindFirstChild("Sprint")
                if sprint then
                    local stamina = sprint:FindFirstChild("Stam")
                    if stamina then
                        stamina.Value = 90000
                    end
                end
            end
        end
    end)
end

local function stopSprint()
    sprintLoopRunning = false
    updateSprintButton()
    notify("Infinity sprint", "off", 1)
end

-- НОКЛИП (упрощенная версия из Infinite Yield)
local function startNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    updateNoclipButton()
    
    noclipConnection = RunService.Heartbeat:Connect(function()
        if not noclipEnabled then return end
        
        local player = Players.LocalPlayer
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    notify("Noclip", "on", 1)
end

local function stopNoclip()
    if not noclipEnabled then return end
    noclipEnabled = false
    updateNoclipButton()
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    notify("Noclip", "off", 1)
end

-- Создаем кнопки
sprintButton = PlayerTab:CreateButton({
    Name = "Infinity sprint",
    Callback = function()
        if sprintLoopRunning then
            stopSprint()
        else
            startSprint()
        end
    end
})

noclipButton = PlayerTab:CreateButton({
    Name = "Noclip",
    Callback = function()
        if noclipEnabled then
            stopNoclip()
        else
            startNoclip()
        end
    end
})

-- TpWalk
local TpWalkSlider = PlayerTab:CreateSlider({
    Name = "TpWalk Speed",
    Range = {1, 20},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = tpwalkSpeed,
    Flag = "TpWalkSpeed",
    Callback = function(value)
        tpwalkSpeed = value
    end
})

local TpWalkButton = PlayerTab:CreateButton({
    Name = "Toggle TpWalk",
    Callback = function()
        if tpwalking then
            stopTPWalk()
            notify("TpWalk", "Deactivated", 1)
        else
            startTPWalk(tpwalkSpeed)
            notify("TpWalk", "Activated - Speed: " .. tpwalkSpeed, 1)
        end
    end
})

PlayerTab:CreateButton({
    Name = "Stop TpWalk",
    Callback = function()
        if tpwalking then
            stopTPWalk()
            notify("TpWalk", "Stopped", 1)
        else
            notify("TpWalk", "Not active", 1)
        end
    end
})

-- ========== VISUALS TAB ==========
-- Оптимизированный ESP без лагов

local fullbrightEnabled = false
local fullbrightConnections = {}

-- Хранилище для подсветок
local activeHighlights = {}
local activeConnections = {}

local function createHighlight(part, color)
    if not part or not part:IsA("BasePart") then return nil end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = part
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Name = "OptimizedESP"
    highlight.Parent = part
    return highlight
end

local function createModelHighlight(model, color)
    if not model then return nil end
    local highlights = {}
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local h = createHighlight(part, color)
            if h then table.insert(highlights, h) end
        end
    end
    return highlights
end

local function destroyHighlights(highlights)
    if type(highlights) == "table" then
        for _, h in ipairs(highlights) do
            pcall(function() h:Destroy() end)
        end
    else
        pcall(function() highlights:Destroy() end)
    end
end

local function clearAllHighlights()
    for _, highlights in pairs(activeHighlights) do
        destroyHighlights(highlights)
    end
    activeHighlights = {}
end

local function clearAllConnections()
    for _, conn in ipairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    activeConnections = {}
end

-- ========== PLAYER ESP (С СИНЕЙ ПОДСВЕТКОЙ И HP) ==========
local playerEspEnabled = false
local playerHighlights = {}
local playerBillboards = {}
local playerEspThread = nil

local function getPlayerColor(player)
    return Color3.fromRGB(0, 120, 255)
end

local function getPlayerHealth(player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local hum = character.Humanoid
        return math.floor(hum.Health), math.floor(hum.MaxHealth)
    end
    return 0, 100
end

local function createPlayerBillboard(player, character)
    if not character then return nil end
    
    local attachPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") or character:FindFirstChild("Torso")
    if not attachPart then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerHPDisplay"
    billboard.Adornee = attachPart
    billboard.Size = UDim2.new(0, 120, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = attachPart
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(0.9, 0, 0.3, 0)
    healthBarBg.Position = UDim2.new(0.05, 0, 0.6, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = frame
    
    local healthBarBgCorner = Instance.new("UICorner")
    healthBarBgCorner.CornerRadius = UDim.new(0, 4)
    healthBarBgCorner.Parent = healthBarBg
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg
    
    local healthBarCorner = Instance.new("UICorner")
    healthBarCorner.CornerRadius = UDim.new(0, 4)
    healthBarCorner.Parent = healthBar
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.Position = UDim2.new(0, 0, 0.1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.3
    textLabel.Parent = frame
    
    local healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(1, 0, 0.3, 0)
    healthText.Position = UDim2.new(0, 0, 0.6, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = "HP: ?"
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 11
    healthText.Font = Enum.Font.Gotham
    healthText.TextStrokeTransparency = 0.3
    healthText.Parent = frame
    
    return billboard, healthBar, healthText
end

local function updateBillboardHealth(billboardData, health, maxHealth)
    if not billboardData then return end
    local healthBar = billboardData.healthBar
    local healthText = billboardData.healthText
    if healthBar then
        local percent = math.clamp(health / maxHealth, 0, 1)
        healthBar.Size = UDim2.new(percent, 0, 1, 0)
        if percent <= 0.3 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        elseif percent <= 0.6 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        end
    end
    if healthText then
        healthText.Text = " " .. health .. "/" .. maxHealth
    end
end

local function addPlayerHighlight(player)
    if not player or playerHighlights[player] then return end
    local character = player.Character
    if not character then return end
    
    local color = getPlayerColor(player)
    playerHighlights[player] = createModelHighlight(character, color)
    activeHighlights["Player_" .. player.Name] = playerHighlights[player]
    
    local billboard, healthBar, healthText = createPlayerBillboard(player, character)
    if billboard then
        playerBillboards[player] = {
            billboard = billboard,
            healthBar = healthBar,
            healthText = healthText
        }
        local health, maxHealth = getPlayerHealth(player)
        updateBillboardHealth(playerBillboards[player], health, maxHealth)
    end
end

local function removePlayerHighlight(player)
    if playerHighlights[player] then
        destroyHighlights(playerHighlights[player])
        playerHighlights[player] = nil
        activeHighlights["Player_" .. player.Name] = nil
    end
    if playerBillboards[player] then
        pcall(function() playerBillboards[player].billboard:Destroy() end)
        playerBillboards[player] = nil
    end
end

local function updateAllPlayerInfo()
    if not playerEspEnabled then return end
    for player, highlights in pairs(playerHighlights) do
        if player and player.Character then
            local color = getPlayerColor(player)
            if highlights then
                if type(highlights) == "table" then
                    for _, h in ipairs(highlights) do
                        if h then
                            h.FillColor = color
                            h.OutlineColor = color
                        end
                    end
                elseif highlights:IsA("Highlight") then
                    highlights.FillColor = color
                    highlights.OutlineColor = color
                end
            end
            
            local health, maxHealth = getPlayerHealth(player)
            if playerBillboards[player] then
                updateBillboardHealth(playerBillboards[player], health, maxHealth)
            end
        end
    end
end

local function onCharacterAdded(player, character)
    if playerEspEnabled and player ~= game.Players.LocalPlayer then
        task.wait(0.2)
        removePlayerHighlight(player)
        addPlayerHighlight(player)
    end
end

local function setupPlayerESP()
    if playerEspEnabled then
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                addPlayerHighlight(player)
            end
        end
        
        local playerAddedConn = game:GetService("Players").PlayerAdded:Connect(function(player)
            if playerEspEnabled and player ~= game.Players.LocalPlayer then
                task.wait(0.5)
                addPlayerHighlight(player)
                player.CharacterAdded:Connect(function(character)
                    onCharacterAdded(player, character)
                end)
            end
        end)
        table.insert(activeConnections, playerAddedConn)
        
        local playerRemovingConn = game:GetService("Players").PlayerRemoving:Connect(function(player)
            if playerEspEnabled then
                removePlayerHighlight(player)
            end
        end)
        table.insert(activeConnections, playerRemovingConn)
        
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if not player.CharacterAdded:IsConnected(onCharacterAdded) then
                    player.CharacterAdded:Connect(function(character)
                        onCharacterAdded(player, character)
                    end)
                end
            end
        end
        
        playerEspThread = task.spawn(function()
            while playerEspEnabled do
                updateAllPlayerInfo()
                task.wait(0.3)
            end
        end)
    else
        for player, highlights in pairs(playerHighlights) do
            destroyHighlights(highlights)
        end
        playerHighlights = {}
        for player, billboardData in pairs(playerBillboards) do
            pcall(function() billboardData.billboard:Destroy() end)
        end
        playerBillboards = {}
    end
end

local function togglePlayerESP()
    playerEspEnabled = not playerEspEnabled
    notify("Player ESP", playerEspEnabled and "ON" or "OFF", 2)
    if playerEspEnabled then
        setupPlayerESP()
    else
        clearAllHighlights()
        clearAllConnections()
        if playerEspThread then task.cancel(playerEspThread) end
        setupPlayerESP()
    end
end

-- ========== MONSTER ESP ==========
local monsterEnabled = false
local monsterHighlights = {}

local monsterNames = {"Mutant", "WeirdDad", "Winterhorn", "Intruder", "DoorMonster"}
local monsterColors = {
    Mutant = Color3.fromRGB(255, 48, 48),
    WeirdDad = Color3.fromRGB(255, 128, 0),
    Winterhorn = Color3.fromRGB(0, 255, 255),
    Intruder = Color3.fromRGB(255, 50, 100),
    DoorMonster = Color3.fromRGB(255, 200, 100)
}

local function addMonsterHighlight(monster)
    if not monster or monsterHighlights[monster] then return end
    local color = monsterColors[monster.Name] or Color3.fromRGB(255, 255, 255)
    monsterHighlights[monster] = createModelHighlight(monster, color)
    activeHighlights[monster.Name] = monsterHighlights[monster]
end

local function removeMonsterHighlight(monster)
    if monsterHighlights[monster] then
        destroyHighlights(monsterHighlights[monster])
        monsterHighlights[monster] = nil
    end
end

local function setupMonsterESP()
    if monsterEnabled then
        for _, name in ipairs(monsterNames) do
            local monster = workspace:FindFirstChild(name)
            if monster then addMonsterHighlight(monster) end
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        for _, name in ipairs({"WeirdDad", "Winterhorn", "Intruder"}) do
            local monsterInStorage = ReplicatedStorage:FindFirstChild(name)
            if monsterInStorage then
                local movedConn = monsterInStorage.ChildAdded:Connect(function(child)
                    if monsterEnabled and child.Name == name and child:IsA("Model") then
                        task.wait(0.1)
                        addMonsterHighlight(child)
                    end
                end)
                table.insert(activeConnections, movedConn)
            end
        end

        local conn = workspace.DescendantAdded:Connect(function(descendant)
            if monsterEnabled and descendant:IsA("Model") then
                for _, name in ipairs(monsterNames) do
                    if descendant.Name == name then
                        task.wait(0.1)
                        addMonsterHighlight(descendant)
                        break
                    end
                end
            end
        end)
        table.insert(activeConnections, conn)

        local removeConn = workspace.DescendantRemoving:Connect(function(descendant)
            if monsterEnabled and descendant:IsA("Model") then
                for _, name in ipairs(monsterNames) do
                    if descendant.Name == name then
                        removeMonsterHighlight(descendant)
                        break
                    end
                end
            end
        end)
        table.insert(activeConnections, removeConn)
    else
        for monster, highlights in pairs(monsterHighlights) do
            destroyHighlights(highlights)
        end
        monsterHighlights = {}
    end
end

local ButtonMonsterESP = VisualsTab:CreateButton({
   Name = "Monster ESP",
   Callback = function()
       monsterEnabled = not monsterEnabled
       notify("Monster ESP", monsterEnabled and "ON" or "OFF", 2)
       if monsterEnabled then
           setupMonsterESP()
       else
           clearAllHighlights()
           clearAllConnections()
           setupMonsterESP()
       end
   end
})

-- ========== ZOMBIE ESP ==========
local zombieEnabled = false
local zombieHighlights = {}

local function addZombieHighlight(zombie)
    if not zombie or zombieHighlights[zombie] then return end
    zombieHighlights[zombie] = createModelHighlight(zombie, Color3.fromRGB(0, 255, 0))
    activeHighlights[zombie.Name] = zombieHighlights[zombie]
end

local function removeZombieHighlight(zombie)
    if zombieHighlights[zombie] then
        destroyHighlights(zombieHighlights[zombie])
        zombieHighlights[zombie] = nil
    end
end

local function setupZombieESP()
    if zombieEnabled then
        for _, zombie in pairs(workspace:GetDescendants()) do
            if zombie:IsA("Model") and (zombie.Name == "Zombie" or zombie.Name == "FrozenZombie" or zombie.Name == "FrozenBloodZombie" or zombie.Name == "BloodZombie") then
                addZombieHighlight(zombie)
            end
        end

        local conn = workspace.DescendantAdded:Connect(function(descendant)
            if zombieEnabled and descendant:IsA("Model") then
                if descendant.Name == "Zombie" or descendant.Name == "FrozenZombie" or descendant.Name == "FrozenBloodZombie" or descendant.Name == "BloodZombie" then
                    task.wait(0.1)
                    addZombieHighlight(descendant)
                end
            end
        end)
        table.insert(activeConnections, conn)

        local removeConn = workspace.DescendantRemoving:Connect(function(descendant)
            if zombieEnabled and descendant:IsA("Model") then
                if descendant.Name == "Zombie" or descendant.Name == "FrozenZombie" or descendant.Name == "FrozenBloodZombie" or descendant.Name == "BloodZombie" then
                    removeZombieHighlight(descendant)
                end
            end
        end)
        table.insert(activeConnections, removeConn)
    else
        for zombie, highlights in pairs(zombieHighlights) do
            destroyHighlights(highlights)
        end
        zombieHighlights = {}
    end
end

local ButtonZombieESP = VisualsTab:CreateButton({
    Name = "Zombie ESP",
    Callback = function()
        zombieEnabled = not zombieEnabled
        notify("Zombie ESP", zombieEnabled and "ON" or "OFF", 2)
        if zombieEnabled then
            setupZombieESP()
        else
            clearAllHighlights()
            clearAllConnections()
            setupZombieESP()
        end
    end
})

-- ========== STALKER ESP ==========
local stalkerEnabled = false
local stalkerHighlights = nil

local function setupStalkerESP()
    if stalkerEnabled then
        if stalkerHighlights then destroyHighlights(stalkerHighlights) end
        local stalker = workspace:FindFirstChild("Stalker")
        if stalker then
            stalkerHighlights = createModelHighlight(stalker, Color3.fromRGB(255, 0, 255))
            activeHighlights["Stalker"] = stalkerHighlights
        end

        local conn = workspace.DescendantAdded:Connect(function(descendant)
            if stalkerEnabled and descendant.Name == "Stalker" and descendant:IsA("Model") then
                task.wait(0.1)
                if stalkerHighlights then destroyHighlights(stalkerHighlights) end
                stalkerHighlights = createModelHighlight(descendant, Color3.fromRGB(255, 0, 255))
                activeHighlights["Stalker"] = stalkerHighlights
            end
        end)
        table.insert(activeConnections, conn)
    else
        if stalkerHighlights then destroyHighlights(stalkerHighlights) end
        stalkerHighlights = nil
        activeHighlights["Stalker"] = nil
    end
end

local ButtonStalkerESP = VisualsTab:CreateButton({
    Name = "Stalker ESP",
    Callback = function()
        stalkerEnabled = not stalkerEnabled
        notify("Stalker ESP", stalkerEnabled and "ON" or "OFF", 2)
        if stalkerEnabled then
            setupStalkerESP()
        else
            clearAllHighlights()
            clearAllConnections()
            setupStalkerESP()
        end
    end
})

-- ========== SPIDER ESP ==========
local spiderEnabled = false
local spiderHighlights = {}

local function addSpiderHighlight(spider)
    if not spider or spiderHighlights[spider] then return end
    spiderHighlights[spider] = createModelHighlight(spider, Color3.fromRGB(255, 165, 0))
    activeHighlights[spider.Name] = spiderHighlights[spider]
end

local function setupSpiderESP()
    if spiderEnabled then
        local possibleNames = {"WorkerHead", "Spider", "Arachnid"}
        for _, name in ipairs(possibleNames) do
            local spider = workspace:FindFirstChild(name)
            if spider then addSpiderHighlight(spider) end
        end

        local conn = workspace.DescendantAdded:Connect(function(descendant)
            if spiderEnabled and descendant:IsA("Model") then
                if descendant.Name == "WorkerHead" or descendant.Name == "Spider" or descendant.Name == "Arachnid" then
                    task.wait(0.1)
                    addSpiderHighlight(descendant)
                end
            end
        end)
        table.insert(activeConnections, conn)
    else
        for spider, highlights in pairs(spiderHighlights) do
            destroyHighlights(highlights)
        end
        spiderHighlights = {}
    end
end

local ButtonSpiderESP = VisualsTab:CreateButton({
    Name = "Spider ESP",
    Callback = function()
        spiderEnabled = not spiderEnabled
        notify("Spider ESP", spiderEnabled and "ON" or "OFF", 2)
        if spiderEnabled then
            setupSpiderESP()
        else
            clearAllHighlights()
            clearAllConnections()
            setupSpiderESP()
        end
    end
})

-- ========== PLAYER ESP КНОПКА ==========
VisualsTab:CreateButton({
    Name = "Player ESP",
    Callback = function()
        togglePlayerESP()
    end
})

-- ========== FULLBRIGHT ==========
local ButtonFullbright = VisualsTab:CreateButton({
   Name = "Fullbright",
   Callback = function()
       fullbrightEnabled = not fullbrightEnabled
       notify("Fullbright", fullbrightEnabled and "on" or "off")
       if fullbrightEnabled then
           local lighting = game:GetService("Lighting")
           lighting.Brightness = 3
           lighting.Ambient = Color3.new(1, 1, 1)
           lighting.OutdoorAmbient = Color3.new(1, 1, 1)
           lighting.ColorShift_Top = Color3.new(1, 1, 1)
           lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
           lighting.FogColor = Color3.new(0.75, 0.75, 0.75)
           lighting.FogEnd = 100000
           lighting.GlobalShadows = false
           local function applyFullbrightToPart(part)
               if part:IsA("BasePart") and part.Material ~= Enum.Material.Neon then
                   if part.Material ~= Enum.Material.ForceField then
                       part.Material = Enum.Material.SmoothPlastic
                   end
               end
           end
           for _, part in pairs(workspace:GetDescendants()) do
               pcall(function()
                   applyFullbrightToPart(part)
               end)
           end
           local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
               if fullbrightEnabled then
                   pcall(function()
                       applyFullbrightToPart(descendant)
                   end)
               end
           end)
           table.insert(fullbrightConnections, descendantConn)
           local lightingConn = lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
               if fullbrightEnabled then
                   lighting.Brightness = 3
               end
           end)
           table.insert(fullbrightConnections, lightingConn)
       else
           local lighting = game:GetService("Lighting")
           lighting.Brightness = 1
           lighting.Ambient = Color3.new(0, 0, 0)
           lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
           lighting.ColorShift_Top = Color3.new(0, 0, 0)
           lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
           lighting.GlobalShadows = true
           for _, conn in ipairs(fullbrightConnections) do
               conn:Disconnect()
           end
           fullbrightConnections = {}
       end
   end
})

-- ========== DISABLE ALL ESP ==========
VisualsTab:CreateButton({
    Name = "DISABLE ALL ESP",
    Callback = function()
        monsterEnabled = false
        zombieEnabled = false
        stalkerEnabled = false
        spiderEnabled = false
        playerEspEnabled = false
        
        if playerEspThread then task.cancel(playerEspThread) end
        
        clearAllHighlights()
        clearAllConnections()
        
        monsterHighlights = {}
        stalkerHighlights = nil
        zombieHighlights = {}
        spiderHighlights = {}
        playerHighlights = {}
        playerBillboards = {}
        
        notify("ESP", "All ESP disabled", 2)
    end
})


-- ========== TELEPORTS 1 TAB ==========
local function teleportToGenerator()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        rootPart.CFrame = CFrame.new(-79.644043, 1.42498207, -133.520752) * CFrame.fromMatrix(Vector3.new(), 
            Vector3.new(-1, 0, 0), 
            Vector3.new(0, 1, 0), 
            Vector3.new(0, 0, -1)
        )
        notify("Teleport", "Teleported to generator", 2)
    else
        notify("Error", "Character not found", 2)
    end
end

local function teleportToFusebox()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local position = Vector3.new(-2.51521182, 4.69999933, -92.0851212)
        local xVector = Vector3.new(-0.976806104, 8.87231479e-08, -0.214125812)
        local yVector = Vector3.new(7.42130908e-08, 1, 7.58028662e-08)
        local zVector = Vector3.new(0.214125812, 5.81537662e-08, -0.976806104)
        rootPart.CFrame = CFrame.fromMatrix(position, xVector, yVector, zVector)
        notify("Teleport", "Teleported to fusebox", 2)
    else
        notify("Error", "Character not found", 2)
    end
end

local function teleportToRadio()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local position = Vector3.new(-34.1258278, 7.79997444, -57.7533989)
        local xVector = Vector3.new(0.684229016, 7.12727726e-08, -0.72926718)
        local yVector = Vector3.new(-3.57603689e-08, 1, 6.41801705e-08)
        local zVector = Vector3.new(0.72926718, -1.78350721e-08, 0.684229016)
        rootPart.CFrame = CFrame.fromMatrix(position, xVector, yVector, zVector)
        notify("Teleport", "Teleported to radio", 2)
    else
        notify("Error", "Character not found", 2)
    end
end

local function teleportToFlashlight()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local position = Vector3.new(-30.3133183, 7.79997444, -73.4244385)
        local xVector = Vector3.new(-0.999479949, 2.70063882e-08, 0.032245744)
        local yVector = Vector3.new(2.6297533e-08, 1, -2.240699e-08)
        local zVector = Vector3.new(-0.032245744, -2.15473541e-08, -0.999479949)
        rootPart.CFrame = CFrame.fromMatrix(position, xVector, yVector, zVector)
        notify("Teleport", "Teleported to flashlight", 2)
    else
        notify("Error", "Character not found", 2)
    end
end

local function teleportToBedroom()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local position = Vector3.new(-39.2392654, 23.7999763, -76.9212952)
        local xVector = Vector3.new(0.990411162, -2.13168043e-08, 0.138151094)
        local yVector = Vector3.new(1.92792555e-08, 1, 1.60868421e-08)
        local zVector = Vector3.new(-0.138151094, -1.32691387e-08, 0.990411162)
        rootPart.CFrame = CFrame.fromMatrix(position, xVector, yVector, zVector)
        notify("Teleport", "Teleported to bedroom", 2)
    else
        notify("Error", "Character not found", 2)
    end
end

local function teleportToKitchen()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local position = Vector3.new(-42.4974709, 7.79997444, -78.5954285)
        local xVector = Vector3.new(0.0261499137, -8.25942337e-09, 0.999658048)
        local yVector = Vector3.new(5.64396174e-08, 1, 6.78585321e-09)
        local zVector = Vector3.new(-0.999658048, 5.62428681e-08, 0.0261499137)
        rootPart.CFrame = CFrame.fromMatrix(position, xVector, yVector, zVector)
        notify("Teleport", "Teleported to kitchen", 2)
    else
        notify("Error", "Character not found", 2)
    end
end

-- Auto Fuel функция
local autoFuelWaiting = false
local autoFuelThread = nil
local autoFuelOriginalCFrame = nil

local function autoFuelClickDetector(detector)
    if detector then
        pcall(function()
            fireclickdetector(detector)
        end)
        return true
    end
    return false
end

local function refuelGenerator()
    if autoFuelWaiting then
        notify("Auto Fuel", "Already running!", 2)
        return
    end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        notify("Error", "Character not found", 2)
        return
    end
    
    autoFuelWaiting = true
    autoFuelOriginalCFrame = player.Character.HumanoidRootPart.CFrame
    
    local pos1 = CFrame.new(-76.3613968, 4.67498159, -128.592514) * CFrame.fromMatrix(Vector3.new(), 
        Vector3.new(0.048255261, -4.31380487e-09, -0.998835027),
        Vector3.new(-2.40804674e-08, 1, -5.48220092e-09),
        Vector3.new(0.998835027, 2.43169591e-08, 0.048255261)
    )
    
    if not teleportTo(pos1) then
        notify("Error", "Failed to teleport", 2)
        autoFuelWaiting = false
        return
    end
    
    task.wait(0.3)
    
    local shack = workspace:FindFirstChild("Shack")
    if shack then
        local jerryCan = shack:FindFirstChild("JerryCan")
        if jerryCan then
            local detector = jerryCan:FindFirstChild("ClickDetector")
            if detector then
                autoFuelClickDetector(detector)
            end
        end
    end
    
    notify("Refuel", "Waiting for JerryCan...", 2)
    
    autoFuelThread = task.spawn(function()
        local hasJerryCan = false
        local jerryCanAppeared = false
        
        while autoFuelWaiting do
            local playerChar = player.Character
            
            local currentHasJerryCan = false
            if playerChar then
                for _, child in pairs(playerChar:GetChildren()) do
                    if child.Name == "JerryCan" then
                        currentHasJerryCan = true
                        break
                    end
                end
            end
            
            if currentHasJerryCan and not hasJerryCan then
                hasJerryCan = true
                jerryCanAppeared = true
                notify("Refuel", "JerryCan in inventory! Waiting...", 2)
            end
            
            if not currentHasJerryCan and hasJerryCan then
                hasJerryCan = false
                break
            end
            
            task.wait(0.2)
        end
        
        if jerryCanAppeared then
            teleportTo(autoFuelOriginalCFrame)
            notify("Refuel", "Generator refueled! Returned.", 2)
        else
            teleportTo(autoFuelOriginalCFrame)
            notify("Refuel", "Failed, returning...", 2)
        end
        
        autoFuelWaiting = false
        autoFuelThread = nil
    end)
end

local TeleportButton1 = TeleportsTab:CreateButton({
    Name = "teleport to generator",
    Callback = function()
        teleportToGenerator()
    end
})

local TeleportButton2 = TeleportsTab:CreateButton({
    Name = "teleport to fusebox",
    Callback = function()
        teleportToFusebox()
    end
})

local TeleportButton3 = TeleportsTab:CreateButton({
    Name = "teleport to radio",
    Callback = function()
        teleportToRadio()
    end
})

local TeleportButton4 = TeleportsTab:CreateButton({
    Name = "teleport to flashlight",
    Callback = function()
        teleportToFlashlight()
    end
})

local TeleportButton5 = TeleportsTab:CreateButton({
    Name = "teleport to bedroom",
    Callback = function()
        teleportToBedroom()
    end
})

local TeleportButton6 = TeleportsTab:CreateButton({
    Name = "teleport to kitchen",
    Callback = function()
        teleportToKitchen()
    end
})

local RefuelButton = TeleportsTab:CreateButton({
    Name = "refuel generator",
    Callback = function()
        refuelGenerator()
    end
})
-- ========== AUTO WIRE TAB ==========
local autoRepairEnabled = false
local autoRepairThread = nil
local OneTime = false

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes

local function bypassAntiCheat()
    local disabledAC = false
    local remotesFolder = game.ReplicatedStorage.Remotes
    local AnticheatRemote = remotesFolder.Kick
    if disabledAC then return end

    AnticheatRemote.Name = ""
    Instance.new("RemoteEvent", remotesFolder).Name = "Kick"
    disabledAC = true
end

local function startAutoRepair()
    if autoRepairEnabled then
        notify("Auto Wire", "Already running!", 2)
        return
    end
    
    bypassAntiCheat()
    
    autoRepairEnabled = true
    notify("Auto Wire", "Started!", 2)
    
    autoRepairThread = task.spawn(function()
        local Fuses = workspace:FindFirstChild("FuseBox")
        if not Fuses then 
            notify("Auto Wire", "FuseBox not found!", 2)
            autoRepairEnabled = false
            return
        end
        
        while autoRepairEnabled do
            for _, Wire in ipairs(Fuses.Wires:GetChildren()) do
                local Sparkles = Wire:FindFirstChild("Sparkles")
                if Sparkles and Sparkles.Enabled and not OneTime then
                    OneTime = true
                    pcall(function()
                        Remotes.Repair:FireServer(Wire)
                    end)
                    task.wait(0.5)
                    OneTime = false
                end
            end
            task.wait(0.5)
        end
    end)
end

local function stopAutoRepair()
    if not autoRepairEnabled then
        notify("Auto Wire", "Not running!", 2)
        return
    end
    
    autoRepairEnabled = false
    if autoRepairThread then
        task.cancel(autoRepairThread)
        autoRepairThread = nil
    end
    notify("Auto Wire", "Stopped!", 2)
end

local function repairWire(wireNumber)
    local Fuses = workspace:FindFirstChild("FuseBox")
    if Fuses then
        local Wire = Fuses.Wires:FindFirstChild(tostring(wireNumber))
        if Wire then
            pcall(function()
                Remotes.Repair:FireServer(Wire)
            end)
            notify("Auto Wire", "Fixing wire " .. wireNumber, 2)
        end
    end
end

local function repairAllWires()
    for i = 1, 4 do
        repairWire(i)
        task.wait(0.3)
    end
    notify("Auto Wire", "All wires processed", 2)
end

FixTowerTab:CreateButton({
    Name = "START Auto Wire",
    Callback = function()
        startAutoRepair()
    end
})

FixTowerTab:CreateButton({
    Name = "STOP Auto Wire",
    Callback = function()
        stopAutoRepair()
    end
})

FixTowerTab:CreateButton({
    Name = "────────── Manual ──────────",
    Callback = function() end
})

FixTowerTab:CreateButton({
    Name = "Repair Wire 1",
    Callback = function()
        repairWire(1)
    end
})

FixTowerTab:CreateButton({
    Name = "Repair Wire 2",
    Callback = function()
        repairWire(2)
    end
})

FixTowerTab:CreateButton({
    Name = "Repair Wire 3",
    Callback = function()
        repairWire(3)
    end
})

FixTowerTab:CreateButton({
    Name = "Repair Wire 4",
    Callback = function()
        repairWire(4)
    end
})

FixTowerTab:CreateButton({
    Name = "Repair All Wires",
    Callback = function()
        repairAllWires()
    end
})

-- ========== NIGHT 2 TAB ==========
local panelFixRunning = false
local panelFixThread = nil

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS.Remotes

local batteryWaiting = false
local batteryThread = nil
local batteryOriginalCFrame = nil

local function teleportTo(cf)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = cf
        return true
    end
    return false
end

local function clickDetector(detector)
    if detector then
        pcall(function()
            fireclickdetector(detector)
        end)
        return true
    end
    return false
end

local function hasPowerCellInInventory()
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    local character = player.Character
    if character then
        local powerCell = character:FindFirstChild("PowerCell")
        if powerCell then
            return true
        end
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local powerCell = backpack:FindFirstChild("PowerCell")
        if powerCell then
            return true
        end
    end
    
    return false
end

local function startRefillBattery()
    if batteryWaiting then
        notify("Auto Battery", "Already running!", 2)
        return
    end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        notify("Error", "Character not found", 2)
        return
    end
    
    batteryWaiting = true
    batteryOriginalCFrame = player.Character.HumanoidRootPart.CFrame
    
    local pos1 = CFrame.new(-317.922394, 82.3999481, 98.2941666) * CFrame.fromMatrix(Vector3.new(), 
        Vector3.new(0.046649877, 6.02481407e-08, -0.998911321),
        Vector3.new(-4.86141349e-10, 1, 6.02911072e-08),
        Vector3.new(0.998911321, -2.3269604e-09, 0.046649877)
    )
    
    local pos2 = CFrame.new(-271.965637, 82.3999481, 112.363098) * CFrame.fromMatrix(Vector3.new(), 
        Vector3.new(-0.999907017, -2.46268765e-08, 0.0136381472),
        Vector3.new(-2.4771813e-08, 1, -1.04582671e-08),
        Vector3.new(-0.0136381472, -1.07951363e-08, -0.999907017)
    )
    
    if not teleportTo(pos1) then
        notify("Error", "Failed to teleport", 2)
        batteryWaiting = false
        return
    end
    
    task.wait(0.3)
    
    local powerCell = workspace:FindFirstChild("PowerCell")
    if powerCell then
        local detector = powerCell:FindFirstChild("ClickDetector")
        if detector then
            clickDetector(detector)
        end
    end
    
    notify("Auto Battery", "Waiting for battery...", 2)
    
    batteryThread = task.spawn(function()
        local batteryTaken = false
        
        while batteryWaiting do
            local hasBattery = hasPowerCellInInventory()
            
            if hasBattery and not batteryTaken then
                batteryTaken = true
                notify("Auto Battery", "Battery in inventory! Placing...", 2)
                
                if teleportTo(pos2) then
                    task.wait(0.3)
                    
                    local powerCellNew = workspace:FindFirstChild("PowerCell")
                    if powerCellNew then
                        local detectorNew = powerCellNew:FindFirstChild("ClickDetector")
                        if detectorNew then
                            clickDetector(detectorNew)
                        end
                    end
                end
            end
            
            if batteryTaken and not hasBattery then
                break
            end
            
            task.wait(0.2)
        end
        
        teleportTo(batteryOriginalCFrame)
        notify("Auto Battery", "Battery refilled! Returned.", 2)
        
        batteryWaiting = false
        batteryThread = nil
    end)
end

local function stopRefillBattery()
    if not batteryWaiting then
        notify("Auto Battery", "Not running!", 2)
        return
    end
    
    batteryWaiting = false
    if batteryThread then
        task.cancel(batteryThread)
        batteryThread = nil
    end
    
    if batteryOriginalCFrame then
        teleportTo(batteryOriginalCFrame)
    end
    
    notify("Auto Battery", "Stopped", 2)
end

local function teleportToPanel(panelNumber)
    local player = game.Players.LocalPlayer
    if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
        return false
    end
    local panelPositions = {
        Vector3.new(-253.133392, 82.3999481, 21.5142994),
        Vector3.new(-232.752625, 82.3999481, -0.575056553),
        Vector3.new(-333.060486, 82.3999481, -70.03479)
    }
    if panelNumber >= 1 and panelNumber <= 3 then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(panelPositions[panelNumber])
        return true
    end
    return false
end

local function checkBrokenPanels()
    local pressurePanels = workspace:FindFirstChild("PressurePanels")
    if not pressurePanels then return nil end
    local brokenPanels = {}
    for i, panel in ipairs(pressurePanels:GetChildren()) do
        if panel.Name == "Panel" then
            local failing = panel:FindFirstChild("Failing")
            if not failing then
                local data = panel:FindFirstChild("Data")
                if data then
                    failing = data:FindFirstChild("Failing")
                end
            end
            if failing and failing:IsA("BoolValue") and failing.Value == true then
                table.insert(brokenPanels, i)
            end
        end
    end
    return brokenPanels
end

local function startPanelFix()
    panelFixRunning = true
    notify("Auto Fix Panels", "Started monitoring panels", 2)
    panelFixThread = task.spawn(function()
        while panelFixRunning do
            local brokenPanels = checkBrokenPanels()
            if brokenPanels and #brokenPanels > 0 then
                for _, panelNum in ipairs(brokenPanels) do
                    if not panelFixRunning then break end
                    notify("Auto Fix", "Fixing Panel " .. panelNum, 2)
                    if teleportToPanel(panelNum) then
                        wait(2)
                    end
                end
            end
            for i = 1, 5 do
                if not panelFixRunning then break end
                wait(1)
            end
        end
    end)
end

local function stopPanelFix()
    panelFixRunning = false
    if panelFixThread then
        task.cancel(panelFixThread)
        panelFixThread = nil
    end
    notify("Auto Fix Panels", "Stopped monitoring", 2)
end

local function revive()
    local success = pcall(function()
        if Remotes and Remotes.LoadCharacter then
            Remotes.LoadCharacter:FireServer()
            notify("Revive", "Revive requested!", 2)
        else
            notify("Error", "LoadCharacter remote not found", 2)
        end
    end)
    
    if not success then
        notify("Error", "Failed to revive", 2)
    end
end

local function disableStalkerDamage()
    local success = pcall(function()
        if Remotes and Remotes.LookAt then
            Remotes.LookAt:Destroy()
            notify("Stalker", "Stalker view damage disabled", 2)
        else
            notify("Error", "LookAt remote not found", 2)
        end
    end)
end

local function escapeSnatch()
    local success = pcall(function()
        if Remotes and Remotes.EscapeSnatch then
            Remotes.EscapeSnatch:FireServer()
            notify("Escape", "Escaped from snatch!", 2)
        else
            notify("Error", "EscapeSnatch remote not found", 2)
        end
    end)
end

-- Кнопки Night 2 Tab
local PanelFixButton = NightTab:CreateButton({
    Name = "auto fix panels",
    Callback = function()
        if panelFixRunning then
            stopPanelFix()
        else
            startPanelFix()
        end
    end
})

local TpPanel1 = NightTab:CreateButton({
    Name = "teleport to panel 1",
    Callback = function()
        if teleportToPanel(1) then
            notify("Teleport", "Teleported to Panel 1", 2)
        else
            notify("Error", "Failed to teleport", 2)
        end
    end
})

local TpPanel2 = NightTab:CreateButton({
    Name = "teleport to panel 2",
    Callback = function()
        if teleportToPanel(2) then
            notify("Teleport", "Teleported to Panel 2", 2)
        else
            notify("Error", "Failed to teleport", 2)
        end
    end
})

local TpPanel3 = NightTab:CreateButton({
    Name = "teleport to panel 3",
    Callback = function()
        if teleportToPanel(3) then
            notify("Teleport", "Teleported to Panel 3", 2)
        else
            notify("Error", "Failed to teleport", 2)
        end
    end
})

local CheckStatusButton = NightTab:CreateButton({
    Name = "check panels status",
    Callback = function()
        local brokenPanels = checkBrokenPanels()
        if brokenPanels and #brokenPanels > 0 then
            local panelList = ""
            for i, num in ipairs(brokenPanels) do
                panelList = panelList .. "Panel " .. num
                if i < #brokenPanels then panelList = panelList .. ", " end
            end
            notify("Panel Status", "Broken: " .. panelList, 3)
        else
            notify("Panel Status", "All panels are working", 2)
        end
    end
})

NightTab:CreateButton({
    Name = "────────── Remotes ──────────",
    Callback = function() end
})

NightTab:CreateButton({
    Name = "Revive",
    Callback = function()
        revive()
    end
})

NightTab:CreateButton({
    Name = "Disable Stalker Damage",
    Callback = function()
        disableStalkerDamage()
    end
})

NightTab:CreateButton({
    Name = "Escape Snatch",
    Callback = function()
        escapeSnatch()
    end
})

NightTab:CreateButton({
    Name = "────────── Battery ──────────",
    Callback = function() end
})

NightTab:CreateButton({
    Name = "Refill Battery",
    Callback = function()
        if batteryWaiting then
            stopRefillBattery()
        else
            startRefillBattery()
        end
    end
})


-- ========== NIGHT 3 TELEPORTS TAB ==========
-- ========== NIGHT 3 TELEPORTS TAB ==========
local function teleportToPosition(position, matrix, name)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        rootPart.CFrame = CFrame.new(position) * CFrame.fromMatrix(Vector3.new(), 
            matrix[1], matrix[2], matrix[3]
        )
        notify("Teleport", "Teleported to " .. name, 1.5)
        return true
    end
    return false
end

Night3Tab:CreateButton({
    Name = "teleport to jerry can 1",
    Callback = function()
        local position = Vector3.new(160.476273, 2.44499946, -217.733551)
        local matrix = {
            Vector3.new(0, 0, -1),
            Vector3.new(0, 1, 0),
            Vector3.new(1, 0, 0)
        }
        teleportToPosition(position, matrix, "Jerry Can 1")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to jerry can 2",
    Callback = function()
        local position = Vector3.new(179.15065, 2.44501209, 195.470169)
        local matrix = {
            Vector3.new(1, 0, 0),
            Vector3.new(0, 1, 0),
            Vector3.new(0, 0, 1)
        }
        teleportToPosition(position, matrix, "Jerry Can 2")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to jerry can 3",
    Callback = function()
        local position = Vector3.new(-109.138596, 2.51999974, 251.681961)
        local matrix = {
            Vector3.new(0, 0, 1),
            Vector3.new(0, 1, -0),
            Vector3.new(-1, 0, 0)
        }
        teleportToPosition(position, matrix, "Jerry Can 3")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to jerry can 4",
    Callback = function()
        local position = Vector3.new(52.4763031, 2.44499969, 11.5749969)
        local matrix = {
            Vector3.new(0, 0, -1),
            Vector3.new(0, 1, 0),
            Vector3.new(1, 0, 0)
        }
        teleportToPosition(position, matrix, "Jerry Can 4")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to lodge",
    Callback = function()
        local position = Vector3.new(-227.710892, 17.4499874, 64.374733)
        local matrix = {
            Vector3.new(-0.999506176, -1.00725394e-07, -0.0314231403),
            Vector3.new(-1.00742938e-07, 1, -1.02507713e-09),
            Vector3.new(0.0314231403, 2.14108842e-09, -0.999506176)
        }
        teleportToPosition(position, matrix, "Lodge")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to cabin 1",
    Callback = function()
        local position = Vector3.new(102.80143, 4.450109, -242.755295)
        local matrix = {
            Vector3.new(0.999921024, -7.12327832e-08, -0.0125700254),
            Vector3.new(7.10630488e-08, 1, -1.39497667e-08),
            Vector3.new(0.0125700254, 1.30554003e-08, 0.999921024)
        }
        teleportToPosition(position, matrix, "Cabin 1")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to cabin 2",
    Callback = function()
        local position = Vector3.new(-31.217268, 4.45010996, 67.667778)
        local matrix = {
            Vector3.new(0.0282743815, -1.69663519e-08, 0.999600172),
            Vector3.new(-1.09505667e-08, 1, 1.72828827e-08),
            Vector3.new(-0.999600172, -1.14348513e-08, 0.0282743815)
        }
        teleportToPosition(position, matrix, "Cabin 2")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to cabin 3",
    Callback = function()
        local position = Vector3.new(-43.4988785, 4.45011091, 268.063293)
        local matrix = {
            Vector3.new(0.0533956699, 1.20570032e-09, -0.998573422),
            Vector3.new(3.72655212e-10, 1, 1.22734944e-09),
            Vector3.new(0.998573422, -4.37658743e-10, 0.0533956699)
        }
        teleportToPosition(position, matrix, "Cabin 3")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to cabin 4",
    Callback = function()
        local position = Vector3.new(231.341476, 4.45011091, 240.398682)
        local matrix = {
            Vector3.new(-0.999166012, -7.09342274e-08, 0.0408324189),
            Vector3.new(-7.02124723e-08, 1, 1.91100664e-08),
            Vector3.new(-0.0408324189, 1.62271832e-08, -0.999166012)
        }
        teleportToPosition(position, matrix, "Cabin 4")
    end
})

Night3Tab:CreateButton({
    Name = "teleport to base spawn",
    Callback = function()
        teleportTo(CFrame.new(0, 10, 0))
        notify("Teleport", "Returned to base spawn", 1.5)
    end
})

-- ========== SPIRIT HELPER TAB ==========
-- Кнопка для запуска отдельного GUI Spirit Helper

SpiritHelperTab:CreateButton({
    Name = "Open Spirit Helper GUI",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/ZoVCopter13/Rm/refs/heads/main/Spirit.lua'))()
            notify("Spirit Helper", "GUI opened! Press H to open menu", 3)
        end)
    end
})





-- MAIN MANSION TAB
-- Скрипт для mansion с Danger Reset, Kid Alert и другими функциями

local dangerLoopEnabled = false
local dangerThread = nil
local kidAlertEnabled = false
local kidAlertThread = nil
local kidDetected = false

local function mansionNotify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483362458
    })
end

local function findDanger()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end
    
    local danger = character:FindFirstChild("Danger")
    if danger then
        return danger
    end
    
    return nil
end

local function setDangerToZero()
    local danger = findDanger()
    if danger then
        danger.Value = 0
        return true
    end
    return false
end

local function startRemoveDanger()
    if dangerLoopEnabled then
        mansionNotify("Remove Danger", "Already running!", 2)
        return
    end
    
    dangerLoopEnabled = true
    mansionNotify("Remove Danger", "Started", 2)
    
    dangerThread = task.spawn(function()
        while dangerLoopEnabled do
            local danger = findDanger()
            if danger then
                danger.Value = 0
            end
            task.wait(0.05)
        end
    end)
end

local function stopRemoveDanger()
    if not dangerLoopEnabled then
        mansionNotify("Remove Danger", "Not running!", 2)
        return
    end
    
    dangerLoopEnabled = false
    if dangerThread then
        task.cancel(dangerThread)
        dangerThread = nil
    end
    mansionNotify("Remove Danger", "Stopped", 2)
end

local function startKidAlert()
    if kidAlertEnabled then
        mansionNotify("Kid Alert", "Already running!", 2)
        return
    end
    
    kidAlertEnabled = true
    kidDetected = false
    mansionNotify("Kid Alert", "Tracking enabled", 2)
    
    kidAlertThread = task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local lastKidState = false
        while kidAlertEnabled do
            local kidInStorage = ReplicatedStorage:FindFirstChild("Kid")
            local kidInWorkspace = workspace:FindFirstChild("Kid")
            if kidInWorkspace and not lastKidState then
                kidDetected = true
                for i = 1, 5 do
                    if not kidAlertEnabled then break end
                    mansionNotify("KID ALERT", "Kid is in the mansion! (Warning " .. i .. "/5)", 2)
                    task.wait(1)
                end
                lastKidState = true
            elseif not kidInWorkspace and lastKidState then
                kidDetected = false
                mansionNotify("Kid Alert", "Kid is gone", 2)
                lastKidState = false
            end
            if kidInWorkspace then
                kidDetected = true
            end
            task.wait(1)
        end
    end)
end

local function stopKidAlert()
    if not kidAlertEnabled then
        mansionNotify("Kid Alert", "Not running!", 2)
        return
    end
    
    kidAlertEnabled = false
    if kidAlertThread then
        task.cancel(kidAlertThread)
        kidAlertThread = nil
    end
    kidDetected = false
    mansionNotify("Kid Alert", "Tracking disabled", 2)
end

MansionMainTab:CreateButton({
    Name = "remove danger (toggle)",
    Callback = function()
        if dangerLoopEnabled then
            stopRemoveDanger()
        else
            startRemoveDanger()
        end
    end
})

MansionMainTab:CreateButton({
    Name = "set danger to 0 (once)",
    Callback = function()
        if setDangerToZero() then
            mansionNotify("Danger", "Set to 0", 2)
        else
            mansionNotify("Error", "Danger object not found", 2)
        end
    end
})

MansionMainTab:CreateButton({
    Name = "kid alert (toggle)",
    Callback = function()
        if kidAlertEnabled then
            stopKidAlert()
        else
            startKidAlert()
        end
    end
})

MansionMainTab:CreateButton({
    Name = "check kid status",
    Callback = function()
        local kidInStorage = game:GetService("ReplicatedStorage"):FindFirstChild("Kid")
        local kidInWorkspace = workspace:FindFirstChild("Kid")
        if kidInWorkspace then
            mansionNotify("Kid Status", "Kid is in workspace NOW!", 3)
        else
            mansionNotify("Kid Status", "Kid not in workspace", 2)
        end
    end
})

-- Mansion Teleports
MansionTeleportsTab:CreateButton({
    Name = "teleport to battery",
    Callback = function()
        teleportToPosition(
            Vector3.new(-32.499073, 36.9935989, 184.280792),
            {
                Vector3.new(0.00826583803, 1.22040849e-08, -0.999965847),
                Vector3.new(5.64465168e-08, 1, 1.26710953e-08),
                Vector3.new(0.999965847, -5.65493288e-08, 0.00826583803)
            },
            "Battery"
        )
    end
})

MansionTeleportsTab:CreateButton({
    Name = "teleport to candys",
    Callback = function()
        teleportToPosition(
            Vector3.new(-64.5843658, 53.793602, 296.737427),
            {
                Vector3.new(-1, -7.82279752e-09, -9.25075001e-05),
                Vector3.new(-7.82310128e-09, 1, 3.2817804e-09),
                Vector3.new(9.25075001e-05, 3.28250405e-09, -1)
            },
            "Candys"
        )
    end
})

MansionTeleportsTab:CreateButton({
    Name = "teleport to door",
    Callback = function()
        teleportToPosition(
            Vector3.new(-84.0964203, 36.9935989, 262.914368),
            {
                Vector3.new(-0.999789953, 2.20632348e-08, -0.0204955302),
                Vector3.new(2.07957083e-08, 1, 6.20571754e-08),
                Vector3.new(0.0204955302, 6.1617925e-08, -0.999789953)
            },
            "Door"
        )
    end
})
-- ========== BUNKER TAB ==========
-- Кнопка для запуска отдельного GUI Bunker Helper

BunkerTab:CreateButton({
    Name = "Open Bunker Helper",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/ZoVCopter13/Rm/refs/heads/main/bunker.lua'))()
            notify("Bunker Helper", "GUI opened! Press K to open menu", 3)
        end)
    end
})




-- ========== ITEM GRABBER (ПРОСТАЯ ВЕРСИЯ) ==========
local itemSpots = workspace:FindFirstChild("ItemSpots")
local itemNames = {"Wrench", "Medkit", "Hammer", "BloxyCola", "Battery", "Camera", "Marshmallow"}

local function grabItem(itemName)
    if not itemSpots then
        notify("Item Grabber", "ItemSpots not found", 2)
        return
    end
    
    for _, spot in ipairs(itemSpots:GetChildren()) do
        local item = spot:FindFirstChild(itemName)
        if item then
            local target = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
            if target and target:IsA("BasePart") then
                teleportTo(target.CFrame)
                task.wait(0.2)
                return
            end
        end
    end
    notify("Item Grabber", itemName .. " not found", 2)
end

for _, itemName in ipairs(itemNames) do
    ItemGrabberTab:CreateButton({
        Name = itemName,
        Callback = function()
            grabItem(itemName)
        end
    })
end
