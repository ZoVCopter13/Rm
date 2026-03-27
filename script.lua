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
-- Создание всех вкладок
local Tab = Window:CreateTab("main", 4483362458)
local PlayerTab = Window:CreateTab("player", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local TeleportsTab = Window:CreateTab("teleports 1", 4483362458)
local FixTowerTab = Window:CreateTab("fix tower", 4483362458)  -- ДОБАВИТЬ ЭТУ СТРОКУ
local NightTab = Window:CreateTab("night 2", 4483362458)
local Night3AmmoTab = Window:CreateTab("Night 3 ammo", 4483362458)
local Night3Tab = Window:CreateTab("night 3 teleports", 4483362458)
local SpiritHelperTab = Window:CreateTab("spirit helper", 4483362458)
local BloodmoonTab = Window:CreateTab("bloodmoon", 4483362458)
local SpiritVisualsTab = Window:CreateTab("spirit visuals", 4483362458)
local MansionMainTab = Window:CreateTab("main mansion", 4483362458)
local MansionVisualsTab = Window:CreateTab("mansion visuals", 4483362458)
local MansionTeleportsTab = Window:CreateTab("mansion teleports", 4483362458)
local BunkerTab = Window:CreateTab("bunker", 4483362458)
local ItemGrabber1 = Window:CreateTab("item graber 1", 4483362458)
local ItemGrabber2 = Window:CreateTab("item graber 2", 4483362458)
local ItemGrabber3 = Window:CreateTab("item graber 3", 4483362458)
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

local ButtonInfo = Tab:CreateButton({
   Name = "Info",
   Callback = function()
       notify("Info", "script ZOVCOPTER by NAGIEV", 5)
   end
})

--- ========== PLAYER TAB ==========
-- ========== PLAYER TAB ==========
local sprintButton
local noclipButton

-- Переменные для ноклипа (старая версия)
local noclipEnabled = false
local noclipConnections = {}

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

-- СТАРЫЙ НОКЛИП (только для локального игрока)
local function startNoclip()
    noclipEnabled = true
    updateNoclipButton()
    notify("Noclip", "on", 1)
    
    task.spawn(function()
        local player = game.Players.LocalPlayer
        if not player then return end
        
        local function setNoCollisions(character)
            if not character then return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false
                end
            end
        end
        
        if player.Character then
            setNoCollisions(player.Character)
        end
        
        local charAddedConn = player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            if noclipEnabled then
                setNoCollisions(character)
            end
        end)
        table.insert(noclipConnections, charAddedConn)
        
        local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
            if not noclipEnabled then
                for _, conn in ipairs(noclipConnections) do
                    conn:Disconnect()
                end
                noclipConnections = {}
                return
            end
            
            if player and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and (part.CanCollide or part.CanTouch) then
                        part.CanCollide = false
                        part.CanTouch = false
                    end
                end
            end
        end)
        table.insert(noclipConnections, heartbeatConn)
    end)
end

local function stopNoclip()
    noclipEnabled = false
    updateNoclipButton()
    notify("Noclip", "off", 1)
    
    for _, conn in ipairs(noclipConnections) do
        conn:Disconnect()
    end
    noclipConnections = {}
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

-- Mutant ESP
local mutantEspEnabled = false
local mutantEspConnections = {}
local mutantList = {}

local ButtonMutantESP = VisualsTab:CreateButton({
   Name = "Mutant ESP",
   Callback = function()
       mutantEspEnabled = not mutantEspEnabled
       notify("Mutant ESP", mutantEspEnabled and "on" or "off")
       if mutantEspEnabled then
           task.spawn(function()
               local function updateMutantESP()
                   local mutant = workspace:FindFirstChild("Mutant")
                   if mutant and not mutantList[mutant] then
                       highlightParts(mutant, Color3.fromRGB(255, 48, 48))
                       mutantList[mutant] = true
                   end
               end
               local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
                   if descendant.Name == "Mutant" and mutantEspEnabled then
                       task.wait(0.1)
                       if not mutantList[descendant] then
                           highlightParts(descendant, Color3.fromRGB(255, 48, 48))
                           mutantList[descendant] = true
                       end
                   end
               end)
               table.insert(mutantEspConnections, descendantConn)
               local childRemovedConn = workspace.ChildRemoved:Connect(function(child)
                   if child.Name == "Mutant" and mutantList[child] then
                       mutantList[child] = nil
                   end
               end)
               table.insert(mutantEspConnections, childRemovedConn)
               updateMutantESP()
           end)
       else
           for mutant, _ in pairs(mutantList) do
               if mutant and mutant.Parent then
                   removeHighlights(mutant)
               end
           end
           mutantList = {}
           for _, conn in ipairs(mutantEspConnections) do
               conn:Disconnect()
           end
           mutantEspConnections = {}
       end
   end
})

-- Zombie ESP
local zombieEspEnabled = false
local zombieEspConnections = {}
local zombieList = {}
local zombieTypes = {
    "FrozenZombie",
    "FrozenBloodZombie", 
    "Zombie"
}

local ButtonZombieESP = VisualsTab:CreateButton({
   Name = "Zombie ESP",
   Callback = function()
       zombieEspEnabled = not zombieEspEnabled
       notify("Zombie ESP", zombieEspEnabled and "on" or "off")
       if zombieEspEnabled then
           task.spawn(function()
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               local Assets = ReplicatedStorage:FindFirstChild("Assets")
               if not Assets then
                   notify("Error", "Assets folder not found", 3)
                   return
               end
               local function addESPToZombie(zombie)
                   if not zombie or not zombieEspEnabled or zombieList[zombie] then 
                       return 
                   end
                   highlightParts(zombie, Color3.fromRGB(0, 255, 0))
                   zombieList[zombie] = true
               end
               local function updateZombieESP()
                   if not Assets then return end
                   for _, zombieName in ipairs(zombieTypes) do
                       for _, obj in pairs(workspace:GetDescendants()) do
                           if obj.Name == zombieName and obj:IsA("Model") then
                               addESPToZombie(obj)
                           end
                       end
                   end
               end
               local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
                   if not zombieEspEnabled then return end
                   for _, zombieName in ipairs(zombieTypes) do
                       if descendant.Name == zombieName and descendant:IsA("Model") then
                           task.wait(0.1)
                           addESPToZombie(descendant)
                           break
                       end
                   end
               end)
               table.insert(zombieEspConnections, descendantConn)
               local childRemovedConn = workspace.DescendantRemoving:Connect(function(descendant)
                   if zombieList[descendant] then
                       zombieList[descendant] = nil
                   end
               end)
               table.insert(zombieEspConnections, childRemovedConn)
               updateZombieESP()
           end)
       else
           for zombie, _ in pairs(zombieList) do
               if zombie and zombie.Parent then
                   removeHighlights(zombie)
               end
           end
           zombieList = {}
           for _, conn in ipairs(zombieEspConnections) do
               conn:Disconnect()
           end
           zombieEspConnections = {}
       end
   end
})

-- Stalker ESP
local stalkerEspEnabled = false
local stalkerEspConnections = {}
local stalkerList = {}

local ButtonStalkerESP = VisualsTab:CreateButton({
   Name = "stalker ESP",
   Callback = function()
       stalkerEspEnabled = not stalkerEspEnabled
       notify("Stalker ESP", stalkerEspEnabled and "on" or "off")
       if stalkerEspEnabled then
           task.spawn(function()
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               local function addESPToStalker(stalker)
                   if not stalker or not stalkerEspEnabled or stalkerList[stalker] then 
                       return 
                   end
                   highlightParts(stalker, Color3.fromRGB(255, 0, 255))
                   stalkerList[stalker] = true
               end
               local function checkForStalker()
                   local stalkerInWorkspace = workspace:FindFirstChild("Stalker")
                   if stalkerInWorkspace and not stalkerList[stalkerInWorkspace] then
                       addESPToStalker(stalkerInWorkspace)
                   end
                   for _, obj in pairs(workspace:GetDescendants()) do
                       if obj.Name == "Stalker" and obj:IsA("Model") and not stalkerList[obj] then
                           addESPToStalker(obj)
                       end
                   end
               end
               local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
                   if not stalkerEspEnabled then return end
                   if descendant.Name == "Stalker" and descendant:IsA("Model") then
                       task.wait(0.1)
                       addESPToStalker(descendant)
                   end
               end)
               table.insert(stalkerEspConnections, descendantConn)
               local childRemovedConn = workspace.DescendantRemoving:Connect(function(descendant)
                   if stalkerList[descendant] then
                       stalkerList[descendant] = nil
                   end
               end)
               table.insert(stalkerEspConnections, childRemovedConn)
               checkForStalker()
               local function periodicCheck()
                   while stalkerEspEnabled do
                       checkForStalker()
                       task.wait(5)
                   end
               end
               task.spawn(periodicCheck)
           end)
       else
           for stalker, _ in pairs(stalkerList) do
               if stalker and stalker.Parent then
                   removeHighlights(stalker)
               end
           end
           stalkerList = {}
           for _, conn in ipairs(stalkerEspConnections) do
               conn:Disconnect()
           end
           stalkerEspConnections = {}
       end
   end
})

-- Spider ESP
local spiderEspEnabled = false
local spiderEspConnections = {}
local spiderList = {}

local ButtonSpiderESP = VisualsTab:CreateButton({
   Name = "spider ESP",
   Callback = function()
       spiderEspEnabled = not spiderEspEnabled
       notify("Spider ESP", spiderEspEnabled and "on" or "off")
       if spiderEspEnabled then
           task.spawn(function()
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               local function addESPToSpider(spider)
                   if not spider or not spiderEspEnabled or spiderList[spider] then 
                       return 
                   end
                   highlightParts(spider, Color3.fromRGB(255, 165, 0))
                   spiderList[spider] = true
               end
               local function checkForSpider()
                   local spiderInStorage = ReplicatedStorage:FindFirstChild("WorkerHead")
                   if spiderInStorage and not spiderList[spiderInStorage] then
                       local function onSpiderMoved(child)
                           if child.Name == "WorkerHead" and child:IsA("Model") then
                               addESPToSpider(child)
                           end
                       end
                       local movedConn = spiderInStorage.ChildAdded:Connect(onSpiderMoved)
                       table.insert(spiderEspConnections, movedConn)
                   end
                   local possibleNames = {"WorkerHead", "Spider", "Arachnid"}
                   for _, name in ipairs(possibleNames) do
                       local spiderInWorkspace = workspace:FindFirstChild(name)
                       if spiderInWorkspace and spiderInWorkspace:IsA("Model") and not spiderList[spiderInWorkspace] then
                           addESPToSpider(spiderInWorkspace)
                       end
                   end
                   for _, obj in pairs(workspace:GetDescendants()) do
                       for _, name in ipairs(possibleNames) do
                           if obj.Name == name and obj:IsA("Model") and not spiderList[obj] then
                               addESPToSpider(obj)
                           end
                       end
                   end
               end
               local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
                   if not spiderEspEnabled then return end
                   local possibleNames = {"WorkerHead", "Spider", "Arachnid"}
                   for _, name in ipairs(possibleNames) do
                       if descendant.Name == name and descendant:IsA("Model") then
                           task.wait(0.1)
                           addESPToSpider(descendant)
                           break
                       end
                   end
               end)
               table.insert(spiderEspConnections, descendantConn)
               local childRemovedConn = workspace.DescendantRemoving:Connect(function(descendant)
                   if spiderList[descendant] then
                       spiderList[descendant] = nil
                   end
               end)
               table.insert(spiderEspConnections, childRemovedConn)
               checkForSpider()
               local function periodicCheck()
                   while spiderEspEnabled do
                       checkForSpider()
                       task.wait(5)
                   end
               end
               task.spawn(periodicCheck)
           end)
       else
           for spider, _ in pairs(spiderList) do
               if spider and spider.Parent then
                   removeHighlights(spider)
               end
           end
           spiderList = {}
           for _, conn in ipairs(spiderEspConnections) do
               conn:Disconnect()
           end
           spiderEspConnections = {}
       end
   end
})

-- Bunker Rat ESP
local bunkerRatEspEnabled = false
local bunkerRatEspConnections = {}
local bunkerRatList = {}

local function highlightBunkerRatParts(model, color, name)
    if not model then return end
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = color
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = color
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Name = name or "BunkerRatESP"
            highlight.Parent = part
        end
    end
end

local function removeBunkerRatHighlights(model, name)
    if not model then return end
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Highlight") and child.Name == (name or "BunkerRatESP") then
                    child:Destroy()
                end
            end
        end
    end
end

local ButtonBunkerRatESP = VisualsTab:CreateButton({
    Name = "Bunker Rat ESP",
    Callback = function()
        bunkerRatEspEnabled = not bunkerRatEspEnabled
        notify("Bunker Rat ESP", bunkerRatEspEnabled and "on" or "off", 2)
        if bunkerRatEspEnabled then
            task.spawn(function()
                local function addESPToRat(rat)
                    if not rat or not bunkerRatEspEnabled or bunkerRatList[rat] then return end
                    highlightBunkerRatParts(rat, Color3.fromRGB(139, 69, 19), "BunkerRatESP")
                    bunkerRatList[rat] = true
                end
                local function findRat()
                    local rat = workspace:FindFirstChild("BunkerRat")
                    if rat and not bunkerRatList[rat] then
                        addESPToRat(rat)
                    end
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "BunkerRat" and obj:IsA("Model") and not bunkerRatList[obj] then
                            addESPToRat(obj)
                        end
                    end
                end
                local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
                    if not bunkerRatEspEnabled then return end
                    if descendant.Name == "BunkerRat" and descendant:IsA("Model") then
                        task.wait(0.1)
                        addESPToRat(descendant)
                    end
                end)
                table.insert(bunkerRatEspConnections, descendantConn)
                local childRemovedConn = workspace.DescendantRemoving:Connect(function(descendant)
                    if bunkerRatList[descendant] then
                        bunkerRatList[descendant] = nil
                    end
                end)
                table.insert(bunkerRatEspConnections, childRemovedConn)
                findRat()
                local function periodicCheck()
                    while bunkerRatEspEnabled do
                        findRat()
                        task.wait(5)
                    end
                end
                task.spawn(periodicCheck)
            end)
        else
            for rat, _ in pairs(bunkerRatList) do
                if rat and rat.Parent then
                    removeBunkerRatHighlights(rat, "BunkerRatESP")
                end
            end
            bunkerRatList = {}
            for _, conn in ipairs(bunkerRatEspConnections) do
                conn:Disconnect()
            end
            bunkerRatEspConnections = {}
        end
    end
})

VisualsTab:CreateButton({
    Name = "Check Bunker Rat",
    Callback = function()
        local rat = workspace:FindFirstChild("BunkerRat")
        if rat then
            notify("Bunker Rat", "Found in workspace", 2)
        else
            local found = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "BunkerRat" and obj:IsA("Model") then
                    notify("Bunker Rat", "Found in descendants", 2)
                    found = true
                    break
                end
            end
            if not found then
                notify("Bunker Rat", "Not found", 2)
            end
        end
    end
})

-- Fullbright
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

-- ========== TELEPORTS TAB ==========
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
-- ========== FIX TOWER ==========
local fixTowerAutoEnabled = false
local fixTowerThread = nil
local fixTowerOriginalCFrame = nil
local fixTowerLastStates = {false, false, false, false}
local fixTowerIsFixing = false

local function fixTowerHasWrench()
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    local success = pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            local wrench = backpack:FindFirstChild("Wrench")
            if wrench then
                return true
            end
        end
        
        local character = player.Character
        if character then
            local wrench = character:FindFirstChild("Wrench")
            if wrench then
                return true
            end
        end
    end)
    
    return success or false
end

local function fixTowerGetWireStatus(wireNumber)
    local success, result = pcall(function()
        local fuseBox = workspace:FindFirstChild("FuseBox")
        if not fuseBox then return nil end
        
        local wires = fuseBox:FindFirstChild("Wires")
        if not wires then return nil end
        
        local wire = wires:FindFirstChild(tostring(wireNumber))
        if not wire then return nil end
        
        local highlight = wire:FindFirstChild("Highlight")
        if not highlight then return nil end
        
        if highlight:IsA("Highlight") then
            return highlight.Enabled
        elseif highlight:IsA("BoolValue") then
            return highlight.Value
        else
            local success2, enabled = pcall(function()
                return highlight.Enabled
            end)
            if success2 then
                return enabled
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

local function fixTowerWaitForFix(wireNumber)
    local startTime = tick()
    
    while tick() - startTime < 10 do
        local status = fixTowerGetWireStatus(wireNumber)
        if status == false then
            return true
        end
        task.wait(0.2)
    end
    
    return false
end

local function fixTowerTeleport()
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local position = Vector3.new(-429.696381, 153.949982, -16.9267139)
    local xVector = Vector3.new(0.77367574, 5.28210009e-09, 0.633581758)
    local yVector = Vector3.new(-2.64950195e-09, 1, -5.10154274e-09)
    local zVector = Vector3.new(-0.633581758, 2.26826358e-09, 0.77367574)
    
    local fixCFrame = CFrame.fromMatrix(position, xVector, yVector, zVector)
    
    if type(fixCFrame) == "Vector3" then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(fixCFrame)
    else
        player.Character.HumanoidRootPart.CFrame = fixCFrame
    end
    return true
end

local function fixTowerFixAll()
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if fixTowerIsFixing then
        return
    end
    
    if not fixTowerHasWrench() then
        return
    end
    
    fixTowerIsFixing = true
    fixTowerOriginalCFrame = player.Character.HumanoidRootPart.CFrame
    
    local brokenWires = {}
    for wireNum = 1, 4 do
        local status = fixTowerGetWireStatus(wireNum)
        if status == true then
            table.insert(brokenWires, wireNum)
        end
    end
    
    for _, wireNum in ipairs(brokenWires) do
        if fixTowerGetWireStatus(wireNum) == true then
            if fixTowerTeleport() then
                task.wait(0.5)
                fixTowerWaitForFix(wireNum)
                task.wait(0.5)
            end
        end
    end
    
    if fixTowerOriginalCFrame then
        if type(fixTowerOriginalCFrame) == "Vector3" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(fixTowerOriginalCFrame)
        else
            player.Character.HumanoidRootPart.CFrame = fixTowerOriginalCFrame
        end
    end
    
    fixTowerIsFixing = false
end

local function fixTowerStartAuto()
    if fixTowerAutoEnabled then
        return
    end
    
    for wireNum = 1, 4 do
        fixTowerLastStates[wireNum] = fixTowerGetWireStatus(wireNum) == true
    end
    
    fixTowerAutoEnabled = true
    notify("Fix Tower", "Auto Fix Started", 2)
    
    fixTowerThread = task.spawn(function()
        while fixTowerAutoEnabled do
            task.wait(0.5)
            
            for wireNum = 1, 4 do
                local currentStatus = fixTowerGetWireStatus(wireNum) == true
                local previousStatus = fixTowerLastStates[wireNum]
                
                if previousStatus == false and currentStatus == true then
                    if fixTowerHasWrench() then
                        local player = game.Players.LocalPlayer
                        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            fixTowerOriginalCFrame = player.Character.HumanoidRootPart.CFrame
                            
                            if fixTowerTeleport() then
                                fixTowerWaitForFix(wireNum)
                                task.wait(0.5)
                                if fixTowerOriginalCFrame then
                                    if type(fixTowerOriginalCFrame) == "Vector3" then
                                        player.Character.HumanoidRootPart.CFrame = CFrame.new(fixTowerOriginalCFrame)
                                    else
                                        player.Character.HumanoidRootPart.CFrame = fixTowerOriginalCFrame
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            for wireNum = 1, 4 do
                fixTowerLastStates[wireNum] = fixTowerGetWireStatus(wireNum) == true
            end
        end
    end)
end

local function fixTowerStopAuto()
    if not fixTowerAutoEnabled then
        return
    end
    
    fixTowerAutoEnabled = false
    if fixTowerThread then
        task.cancel(fixTowerThread)
        fixTowerThread = nil
    end
    notify("Fix Tower", "Auto Fix Stopped", 2)
end

FixTowerTab:CreateButton({
    Name = "START Auto Fix Monitor",
    Callback = function()
        fixTowerStartAuto()
    end
})

FixTowerTab:CreateButton({
    Name = "STOP Auto Fix Monitor",
    Callback = function()
        fixTowerStopAuto()
    end
})

FixTowerTab:CreateButton({
    Name = "Fix All Wires",
    Callback = function()
        fixTowerFixAll()
    end
})
-- ========== NIGHT 2 TAB (Panels) ==========
local panelFixRunning = false
local panelFixThread = nil

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

-- ========== NIGHT 3 AMMO TAB ==========
local ammoCollecting = false
local originalCFrame = nil

-- Функция для получения количества патронов
local function getCurrentAmmo()
    local player = game.Players.LocalPlayer
    local success, value = pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            local shotgun = backpack:FindFirstChild("Shotgun")
            if shotgun then
                local ammo = shotgun:FindFirstChild("Ammo")
                if ammo and ammo:IsA("NumberValue") then
                    return ammo.Value
                end
            end
        end
        return nil
    end)
    return success and value or nil
end

-- Функция для активации ClickDetector
local function activateClickDetector(detector)
    local success = pcall(function()
        fireclickdetector(detector)
    end)
    return success
end

-- Функция для получения ClickDetector у аммо
local function getNight3ClickDetector(ammoName)
    local ammoPiles = workspace:FindFirstChild("AmmoPiles")
    if not ammoPiles then return nil end
    
    local pile = ammoPiles:FindFirstChild(ammoName)
    if not pile then return nil end
    
    local detectorPart = pile:FindFirstChild("Detector")
    if not detectorPart then return nil end
    
    return detectorPart:FindFirstChildOfClass("ClickDetector")
end

-- Функция для сбора аммо с отслеживанием
local function collectNight3Ammo(ammoName, positionCFrame)
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        notify("Ammo", "Character not found", 2)
        return false
    end
    
    if ammoCollecting then
        notify("Ammo", "Already collecting!", 2)
        return false
    end
    
    ammoCollecting = true
    originalCFrame = player.Character.HumanoidRootPart.CFrame
    
    -- Проверяем начальное количество
    local startAmmo = getCurrentAmmo()
    if startAmmo == nil then
        notify("Ammo", "Cannot detect ammo count", 2)
        ammoCollecting = false
        return false
    end
    
    -- Телепортируемся к аммо
    if not teleportTo(positionCFrame) then
        notify("Ammo", "Failed to teleport", 2)
        ammoCollecting = false
        return false
    end
    
    notify("Ammo", "Teleported to " .. ammoName, 1)
    task.wait(0.5)
    
    -- Получаем ClickDetector
    local detector = getNight3ClickDetector(ammoName)
    if not detector then
        notify("Ammo", "ClickDetector not found", 2)
        teleportTo(originalCFrame)
        ammoCollecting = false
        return false
    end
    
    -- Нажимаем
    local clickSuccess = activateClickDetector(detector)
    if not clickSuccess then
        notify("Ammo", "Failed to click", 2)
        teleportTo(originalCFrame)
        ammoCollecting = false
        return false
    end
    
    notify("Ammo", "Clicked! Waiting for ammo...", 2)
    
    -- Ждем увеличения патронов (до 5 секунд)
    local waitStart = tick()
    local ammoIncreased = false
    while tick() - waitStart < 5 do
        local currentAmmo = getCurrentAmmo()
        if currentAmmo and currentAmmo > startAmmo then
            ammoIncreased = true
            notify("Ammo", "Ammo collected! +" .. (currentAmmo - startAmmo), 2)
            break
        end
        task.wait(0.2)
    end
    
    if not ammoIncreased then
        notify("Ammo", "Ammo did not increase", 2)
    end
    
    -- Возвращаемся
    task.wait(0.5)
    teleportTo(originalCFrame)
    
    ammoCollecting = false
    return ammoIncreased
end

-- Позиции для Night 3 аммо
local night3AmmoLocations = {
    {
        name = "Left Ammo Pile 1",
        cframe = CFrame.new(-46.8036766, 2.4266336, -68.25),
        pileName = "LeftAmmoPile"
    },
    {
        name = "Left Ammo Pile 2",
        cframe = CFrame.new(-6.80367327, 2.4266336, -153.25),
        pileName = "LeftAmmoPile"
    },
    {
        name = "Right Ammo Pile 1",
        cframe = CFrame.new(96.9999847, 2.4266336, 178),
        pileName = "RightAmmoPile"
    },
    {
        name = "Right Ammo Pile 2",
        cframe = CFrame.new(48.6963272, 2.4266336, 282.75),
        pileName = "RightAmmoPile"
    }
}

-- Функция для сбора всех аммо
local function collectAllNight3Ammo()
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        notify("Ammo", "Character not found", 2)
        return
    end
    
    if ammoCollecting then
        notify("Ammo", "Already collecting!", 2)
        return
    end
    
    ammoCollecting = true
    originalCFrame = player.Character.HumanoidRootPart.CFrame
    local collected = 0
    
    for i, ammo in ipairs(night3AmmoLocations) do
        local startAmmo = getCurrentAmmo()
        if startAmmo == nil then
            break
        end
        
        if teleportTo(ammo.cframe) then
            task.wait(0.5)
            
            local detector = getNight3ClickDetector(ammo.pileName)
            if detector then
                if activateClickDetector(detector) then
                    local waitStart = tick()
                    while tick() - waitStart < 4 do
                        local currentAmmo = getCurrentAmmo()
                        if currentAmmo and currentAmmo > startAmmo then
                            collected = collected + 1
                            break
                        end
                        task.wait(0.2)
                    end
                end
            end
            task.wait(0.5)
        end
    end
    
    teleportTo(originalCFrame)
    ammoCollecting = false
    
    notify("Ammo", "Collected " .. collected .. "/4 ammo piles", 3)
end

-- Функция для проверки текущего количества патронов
local function checkNight3Ammo()
    local ammo = getCurrentAmmo()
    if ammo ~= nil then
        notify("Ammo", "Shotgun Ammo: " .. ammo, 2)
    else
        notify("Ammo", "Cannot detect ammo. Make sure you have a shotgun in backpack", 3)
    end
end

-- Кнопки Night 3 Ammo Tab
Night3AmmoTab:CreateButton({
    Name = "Collect All Ammo",
    Callback = function()
        collectAllNight3Ammo()
    end
})

Night3AmmoTab:CreateButton({
    Name = "Check Ammo Count",
    Callback = function()
        checkNight3Ammo()
    end
})

-- Кнопки для отдельных патронов
for _, ammo in ipairs(night3AmmoLocations) do
    Night3AmmoTab:CreateButton({
        Name = "Collect " .. ammo.name,
        Callback = function()
            collectNight3Ammo(ammo.pileName, ammo.cframe)
        end
    })
end

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

-- ========== SPIRIT HELPER TAB (сокращен для длины) ==========
local spiritHelperRunning = false
local spiritHelperThread = nil
local lastSpiritLampTime = 0
local lastSpiritAlarmTime = 0
local lastSpiritBearTime = 0
local spiritBedHidden = false
local lastSpiritLampHeat = -1
local lastSpiritMaxDistance = nil
local lastSpiritBearDistance = nil
local lastSpiritDistanceAt8 = false
local lastSpiritBearCheckTime = 0
local lastSpiritClosetProgress = nil
local spiritBloodmoonMode = false
local lastSpiritMonsterProgress = {Door = 0, Window = 0, Vent = 0}
local lastSpiritLampHeatValue = -1
local lastSpiritLampIncreaseTime = 0
local spiritMonsterCooldown = 0
local spiritLampESPEnabled = false
local spiritLampESPThread = nil
local spiritLampBillboard = nil

local spiritPositions = {
   alarm = {
      pos = Vector3.new(-11.0053978, 5.00000334, 17.0491295),
      matrix = {
         Vector3.new(-0.00265719951, 0, 0.999996483),
         Vector3.new(0, 1, 0),
         Vector3.new(-0.999996483, 0, -0.00265719951)
      },
      name = "Alarm"
   },
   bed = {
      pos = Vector3.new(-4.52546644, 5.00000334, 17.4178753),
      matrix = {
         Vector3.new(0.0772480145, 0, -0.9970119),
         Vector3.new(0, 1, 0),
         Vector3.new(0.9970119, 0, 0.0772480145)
      },
      name = "Bed"
   },
   bear = {
      pos = Vector3.new(-8.43876457, 5.00000334, -8.79197693),
      matrix = {
         Vector3.new(0.997374952, 0, 0.072410278),
         Vector3.new(0, 1, 0),
         Vector3.new(-0.072410278, 0, 0.997374952)
      },
      name = "Bear"
   },
   lamp = {
      pos = Vector3.new(8.50332642, 5.00000334, 19.6756325),
      matrix = {
         Vector3.new(-0.998574674, 3.19413402e-08, 0.0533724651),
         Vector3.new(3.10384749e-08, 1, -1.77452169e-08),
         Vector3.new(-0.0533724651, -1.60633249e-08, -0.998574674)
      },
      name = "Lamp"
   },
   closet = {
      pos = Vector3.new(4.13197184, 5.12111855, -8.41910362),
      matrix = {
         Vector3.new(0.993054211, 0, 0.117657781),
         Vector3.new(0, 1, 0),
         Vector3.new(-0.117657781, 0, 0.993054211)
      },
      name = "Closet"
   },
   default = {
      pos = Vector3.new(10.4230566, 5.00000334, 14.5195627),
      matrix = {
         Vector3.new(0.947909236, 1.45944297e-08, -0.318540603),
         Vector3.new(-3.40286341e-08, 1, -5.54454544e-08),
         Vector3.new(0.318540603, 6.33967616e-08, 0.947909236)
      },
      name = "Default"
   }
}

local function spiritTeleportTo(position, matrix)
   local player = game.Players.LocalPlayer
   if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
      player.Character.HumanoidRootPart.CFrame = CFrame.new(position) * CFrame.fromMatrix(Vector3.new(), 
         matrix[1], matrix[2], matrix[3]
      )
      return true
   end
   return false
end

local function spiritTeleportToLocation(loc)
   return spiritTeleportTo(spiritPositions[loc].pos, spiritPositions[loc].matrix)
end

local function spiritGetLampHeat()
   local success, value = pcall(function()
      local lamp = workspace:FindFirstChild("Lamp")
      if lamp then
         local heat = lamp:FindFirstChild("Heat")
         if heat and heat:IsA("NumberValue") then
            return heat.Value
         end
      end
      return nil
   end)
   return success and value or nil
end

local function spiritGetMaxActivationDistance()
   local success, value = pcall(function()
      local radio = workspace:FindFirstChild("Radio")
      if radio then
         local clickDetector = radio:FindFirstChild("ClickDetector")
         if clickDetector and clickDetector:IsA("ClickDetector") then
            return clickDetector.MaxActivationDistance
         end
      end
      return nil
   end)
   return success and value or nil
end

local function spiritGetBearClickDetectorDistance()
   local success, value = pcall(function()
      local teddyBear = workspace:FindFirstChild("Teddy bear")
      if teddyBear then
         local clickDetector = teddyBear:FindFirstChild("ClickDetector")
         if clickDetector and clickDetector:IsA("ClickDetector") then
            return clickDetector.MaxActivationDistance
         end
      end
      return nil
   end)
   return success and value or nil
end

local function spiritGetClosetProgress()
   local success, value = pcall(function()
      local monster = workspace:FindFirstChild("Monster")
      if monster then
         local closet = monster:FindFirstChild("Closet")
         if closet then
            local progress = closet:FindFirstChild("Progress")
            if progress and progress:IsA("NumberValue") then
               return progress.Value
            end
         end
      end
      return nil
   end)
   return success and value or nil
end

local function spiritIsBedHidden()
   local success, result = pcall(function()
      local bed = workspace:FindFirstChild("Bed")
      if bed then
         local hidden = bed:FindFirstChild("Hidden")
         if hidden and hidden:IsA("BoolValue") then
            return hidden.Value
         end
      end
      return false
   end)
   return success and result or false
end

local function spiritCheckMonsterProgress()
   local monster = workspace:FindFirstChild("Monster")
   if not monster then return 0, {}, 0 end
   
   local paths = {"Door", "Window", "Vent"}
   local maxProgress = 0
   local details = {}
   local countAt3 = 0
   
   for _, path in ipairs(paths) do
      local target = monster:FindFirstChild(path)
      if target then
         local progress = target:FindFirstChild("Progress")
         if progress and progress:IsA("NumberValue") then
            details[path] = progress.Value
            if progress.Value > maxProgress then
               maxProgress = progress.Value
            end
            if progress.Value == 3 then
               countAt3 = countAt3 + 1
            end
         end
      end
   end
   
   return maxProgress, details, countAt3
end

local function spiritCheckMonsterChanges(currentDetails)
   local resetMessages = {}
   
   for path, value in pairs(currentDetails) do
      local lastValue = lastSpiritMonsterProgress[path]
      if lastValue ~= nil and value ~= lastValue then
         if value == 0 and lastValue > 0 then
            table.insert(resetMessages, path .. " is gone! (was " .. lastValue .. ")")
         end
      end
   end
   
   for path, value in pairs(currentDetails) do
      lastSpiritMonsterProgress[path] = value
   end
   
   for path, lastValue in pairs(lastSpiritMonsterProgress) do
      if currentDetails[path] == nil then
         table.insert(resetMessages, path .. " disappeared!")
         lastSpiritMonsterProgress[path] = nil
      end
   end
   
   if #resetMessages > 0 then
      local message = table.concat(resetMessages, "\n")
      notify("MONSTER IS GONE!", message, 5)
   end
   
   return #resetMessages > 0
end

local function spiritCheckAlarmAndTeleport()
   local currentDistance = spiritGetMaxActivationDistance()
   if currentDistance == nil then 
      lastSpiritDistanceAt8 = false
      return false 
   end
   
   local hidden = spiritIsBedHidden()
   
   if hidden then
      return false
   end
   
   if lastSpiritMaxDistance ~= nil and currentDistance == 0 and lastSpiritMaxDistance > 0 then
      notify("ALARM RESET!", "Distance: " .. lastSpiritMaxDistance .. " → 0 - Teleporting to lamp!", 2)
      spiritTeleportToLocation("lamp")
      lastSpiritLampTime = tick()
      lastSpiritMaxDistance = currentDistance
      return true
   end
   
   if currentDistance == 8 then
      if not lastSpiritDistanceAt8 then
         notify("RADIO READY!", "Distance set to 8 - Teleporting every 2 seconds", 2)
         lastSpiritDistanceAt8 = true
      end
   else
      if lastSpiritDistanceAt8 then
         lastSpiritDistanceAt8 = false
      end
   end
   
   if lastSpiritDistanceAt8 and tick() - lastSpiritAlarmTime >= 2 then
      notify("ALARM!", "Teleporting to alarm", 1.5)
      spiritTeleportToLocation("alarm")
      lastSpiritAlarmTime = tick()
      return true
   end
   
   lastSpiritMaxDistance = currentDistance
   return false
end

local function spiritCheckBearAndTeleport()
   local currentDistance = spiritGetBearClickDetectorDistance()
   if currentDistance == nil then return false end
   
   local hidden = spiritIsBedHidden()
   
   if hidden then
      return false
   end
   
   local currentTime = tick()
   
   if lastSpiritBearDistance ~= nil and currentDistance == 0 and lastSpiritBearDistance > 0 then
      notify("BEAR RESET!", "Distance: " .. lastSpiritBearDistance .. " → 0 - Teleporting to lamp!", 2)
      spiritTeleportToLocation("lamp")
      lastSpiritLampTime = tick()
      lastSpiritBearDistance = currentDistance
      return true
   end
   
   if currentDistance >= 6 and currentDistance <= 8 and currentTime - lastSpiritBearCheckTime >= 3 then
      notify("BEAR!", "Distance: " .. currentDistance .. " - Teleporting to bear!", 2)
      spiritTeleportToLocation("bear")
      lastSpiritBearCheckTime = currentTime
      lastSpiritBearDistance = currentDistance
      return true
   end
   
   lastSpiritBearDistance = currentDistance
   return false
end

local function spiritCheckClosetAndTeleport()
   local currentProgress = spiritGetClosetProgress()
   if currentProgress == nil then return false end
   
   local hidden = spiritIsBedHidden()
   
   if hidden then
      return false
   end
   
   if lastSpiritClosetProgress ~= nil and currentProgress == 3 and lastSpiritClosetProgress ~= 3 then
      notify("CLOSET ALERT!", "Progress: 3 - Teleporting to closet!", 3)
      spiritTeleportToLocation("closet")
      lastSpiritClosetProgress = currentProgress
      return true
   end
   
   if lastSpiritClosetProgress ~= nil and currentProgress == 0 and lastSpiritClosetProgress == 3 then
      notify("CLOSET RESET!", "Progress: 3 → 0 - Teleporting to lamp!", 2)
      spiritTeleportToLocation("lamp")
      lastSpiritLampTime = tick()
      lastSpiritClosetProgress = currentProgress
      return true
   end
   
   lastSpiritClosetProgress = currentProgress
   return false
end

local function spiritCheckLampAndTeleport()
   local heat = spiritGetLampHeat()
   if heat == nil then return false end
   
   if heat ~= lastSpiritLampHeat then
      lastSpiritLampHeat = heat
   end
   
   local shouldTeleport = false
   local action = ""
   
   if heat == 0 then
      shouldTeleport = true
      action = "TURN ON"
   elseif heat >= 60 and heat <= 70 then
      shouldTeleport = true
      action = "TURN OFF (" .. heat .. ")"
   end
   
   if shouldTeleport and tick() - lastSpiritLampTime > 5 then
      notify("LAMP NEEDS " .. action .. "!", "Heat: " .. heat, 3)
      spiritTeleportToLocation("lamp")
      lastSpiritLampTime = tick()
      return true
   end
   
   return false
end

local function spiritCheckLampIncrease()
   local heat = spiritGetLampHeat()
   if heat == nil then return false end
   
   if lastSpiritLampHeatValue == -1 then
      lastSpiritLampHeatValue = heat
      return false
   end
   
   local increase = heat - lastSpiritLampHeatValue
   
   if increase >= 0.2 and increase <= 100 and tick() - lastSpiritLampIncreaseTime >= 2 then
      notify("LAMP HEAT INCREASE!", "Heat increased by " .. string.format("%.2f", increase), 2)
      spiritTeleportToLocation("lamp")
      lastSpiritLampTime = tick()
      lastSpiritLampIncreaseTime = tick()
      lastSpiritLampHeatValue = heat
      return true
   end
   
   lastSpiritLampHeatValue = heat
   return false
end

local function spiritHandleMonsterAt3()
   notify("MONSTER AT 3!", "Teleporting to lamp first!", 3)
   spiritTeleportToLocation("lamp")
   task.wait(3)
   notify("MONSTER AT 3!", "Now teleporting to bed!", 3)
   spiritTeleportToLocation("bed")
   task.wait(2)
end

local function spiritCheckAndAct()
   local currentTime = tick()
   local hidden = spiritIsBedHidden()
   local monsterProgress, monsterDetails, countAt3 = spiritCheckMonsterProgress()
   
   if hidden ~= spiritBedHidden then
      spiritBedHidden = hidden
   end
   
   spiritCheckMonsterChanges(monsterDetails)
   
   if monsterProgress == 3 then
      if spiritCheckLampIncrease() then
         return
      end
   end
   
   if spiritCheckClosetAndTeleport() then
      return
   end
   
   if hidden then
      return
   end
   
   if spiritCheckBearAndTeleport() then
      return
   end
   
   if spiritCheckLampAndTeleport() then
      return
   end
   
   if spiritCheckAlarmAndTeleport() then
      return
   end
   
   if monsterProgress == 3 then
      if spiritBloodmoonMode then
         if countAt3 == 3 then
            return
         end
      end
      
      if tick() - spiritMonsterCooldown > 10 then
         spiritMonsterCooldown = tick()
         spiritHandleMonsterAt3()
      end
      return
   end
   
   for path, value in pairs(monsterDetails) do
      local lastValue = lastSpiritMonsterProgress[path]
      if lastValue ~= nil and value ~= lastValue then
         if value == 0 and lastValue > 0 then
            notify("MONSTER IS GONE!", path .. " reset to 0", 2)
         end
      end
      lastSpiritMonsterProgress[path] = value
   end
end

local function spiritStartHelper()
   if spiritHelperRunning then
      notify("Spirit Helper", "Already running", 2)
      return
   end
   
   spiritHelperRunning = true
   lastSpiritLampTime = tick()
   lastSpiritAlarmTime = tick()
   lastSpiritBearCheckTime = tick()
   lastSpiritLampIncreaseTime = tick()
   spiritMonsterCooldown = 0
   spiritBedHidden = spiritIsBedHidden()
   lastSpiritLampHeat = spiritGetLampHeat()
   lastSpiritLampHeatValue = spiritGetLampHeat()
   lastSpiritMaxDistance = spiritGetMaxActivationDistance()
   lastSpiritBearDistance = spiritGetBearClickDetectorDistance()
   lastSpiritClosetProgress = spiritGetClosetProgress()
   lastSpiritDistanceAt8 = (lastSpiritMaxDistance == 8)
   
   local _, details, _ = spiritCheckMonsterProgress()
   for path, value in pairs(details) do
      lastSpiritMonsterProgress[path] = value
   end
   
   notify("Spirit Helper", "Auto assistant started", 2)
   
   spiritHelperThread = task.spawn(function()
      while spiritHelperRunning do
         local success, err = pcall(spiritCheckAndAct)
         if not success then
         end
         task.wait(0.3)
      end
   end)
end

local function spiritStopHelper()
   spiritHelperRunning = false
   if spiritHelperThread then
      task.cancel(spiritHelperThread)
      spiritHelperThread = nil
   end
   notify("Spirit Helper", "Stopped", 2)
end

local function spiritToggleBloodmoon()
   spiritBloodmoonMode = not spiritBloodmoonMode
   notify("Bloodmoon Mode", spiritBloodmoonMode and "ENABLED - Hallucinations ignored" or "DISABLED - Normal mode", 3)
end

local function spiritToggleLampESP()
   spiritLampESPEnabled = not spiritLampESPEnabled
   if spiritLampESPEnabled then
      local lamp = workspace:FindFirstChild("Lamp")
      if lamp then
         local bulb = lamp:FindFirstChild("Bulb")
         if bulb then
            if spiritLampBillboard and spiritLampBillboard.Parent then
               spiritLampBillboard:Destroy()
            end
            
            spiritLampBillboard = Instance.new("BillboardGui")
            spiritLampBillboard.Name = "LampHeatDisplay"
            spiritLampBillboard.Adornee = bulb
            spiritLampBillboard.Size = UDim2.new(0, 100, 0, 30)
            spiritLampBillboard.StudsOffset = Vector3.new(0, 1.5, 0)
            spiritLampBillboard.AlwaysOnTop = true
            spiritLampBillboard.Parent = bulb
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.3
            frame.BorderSizePixel = 0
            frame.Parent = spiritLampBillboard
            
            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 8)
            uiCorner.Parent = frame
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "Lamp Heat: --%"
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextSize = 14
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Parent = frame
            
            spiritLampESPThread = task.spawn(function()
               while spiritLampESPEnabled and spiritLampBillboard and spiritLampBillboard.Parent do
                  local heat = spiritGetLampHeat()
                  if heat ~= nil then
                     local color
                     if heat == 0 then
                        color = Color3.fromRGB(255, 100, 100)
                        textLabel.Text = "LAMP OFF - 0%"
                     elseif heat >= 60 and heat <= 70 then
                        color = Color3.fromRGB(255, 200, 100)
                        textLabel.Text = "TURN OFF! " .. math.floor(heat) .. "%"
                     else
                        color = Color3.fromRGB(100, 255, 100)
                        textLabel.Text = "Lamp Heat: " .. math.floor(heat) .. "%"
                     end
                     frame.BackgroundColor3 = color
                     frame.BackgroundTransparency = 0.2
                  else
                     textLabel.Text = "Lamp not found"
                     frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                  end
                  task.wait(0.2)
               end
            end)
         end
      end
      notify("Lamp ESP", "Enabled", 2)
   else
      if spiritLampESPThread then
         task.cancel(spiritLampESPThread)
         spiritLampESPThread = nil
      end
      if spiritLampBillboard and spiritLampBillboard.Parent then
         spiritLampBillboard:Destroy()
         spiritLampBillboard = nil
      end
      notify("Lamp ESP", "Disabled", 2)
   end
end

SpiritHelperTab:CreateButton({
   Name = "START auto helper",
   Callback = spiritStartHelper
})

SpiritHelperTab:CreateButton({
   Name = "STOP auto helper",
   Callback = spiritStopHelper
})

SpiritHelperTab:CreateButton({
   Name = "RESTART auto helper",
   Callback = function()
      spiritStopHelper()
      task.wait(0.5)
      spiritStartHelper()
   end
})

SpiritHelperTab:CreateButton({
   Name = "Check radio distance",
   Callback = function()
      local distance = spiritGetMaxActivationDistance()
      if distance ~= nil then
         notify("Radio Distance", "Current: " .. distance, 2)
      else
         notify("Error", "Radio ClickDetector not found", 2)
      end
   end
})

SpiritHelperTab:CreateButton({
   Name = "Check bear distance",
   Callback = function()
      local distance = spiritGetBearClickDetectorDistance()
      if distance ~= nil then
         notify("Bear Distance", "Current: " .. distance, 2)
      else
         notify("Error", "Teddy bear ClickDetector not found", 2)
      end
   end
})

SpiritHelperTab:CreateButton({
   Name = "Check closet progress",
   Callback = function()
      local progress = spiritGetClosetProgress()
      if progress ~= nil then
         notify("Closet Progress", "Current: " .. progress, 2)
      else
         notify("Error", "Closet not found", 2)
      end
   end
})

SpiritHelperTab:CreateButton({
   Name = "Force check lamp",
   Callback = function()
      local heat = spiritGetLampHeat()
      if heat == nil then
         notify("Error", "Lamp not found", 2)
         return
      end
      
      notify("Lamp Heat", "Current: " .. heat, 2)
      
      if heat == 0 or (heat >= 60 and heat <= 70) then
         local action = (heat == 0) and "TURN ON" or "TURN OFF"
         notify("Manual teleport", "Heat: " .. heat .. " - " .. action, 2)
         spiritTeleportToLocation("lamp")
      end
   end
})

SpiritHelperTab:CreateButton({
   Name = "Check lamp heat",
   Callback = function()
      local heat = spiritGetLampHeat()
      if heat == nil then
         notify("Error", "Lamp not found", 2)
         return
      end
      
      local status = "Current: " .. heat
      if heat == 0 then
         status = status .. " (needs TURN ON)"
      elseif heat >= 60 and heat <= 70 then
         status = status .. " (needs TURN OFF)"
      end
      notify("Lamp Heat", status, 2)
   end
})

SpiritHelperTab:CreateButton({
   Name = "Check bed status",
   Callback = function()
      local hidden = spiritIsBedHidden()
      notify("Bed Status", hidden and "HIDDEN" or "VISIBLE", 2)
   end
})

SpiritVisualsTab:CreateButton({
   Name = "Lamp Heat ESP",
   Callback = spiritToggleLampESP
})

BloodmoonTab:CreateButton({
   Name = "BLOODMOON MODE",
   Callback = spiritToggleBloodmoon
})

BloodmoonTab:CreateButton({
   Name = "Teleport to Closet",
   Callback = function()
      spiritTeleportToLocation("closet")
      notify("Teleport", "Teleported to closet", 2)
   end
})

BloodmoonTab:CreateButton({
   Name = "Check Closet Progress",
   Callback = function()
      local progress = spiritGetClosetProgress()
      if progress ~= nil then
         notify("Closet Progress", "Current: " .. progress, 2)
      else
         notify("Error", "Closet not found", 2)
      end
   end
})

BloodmoonTab:CreateButton({
   Name = "Bloodmoon Info",
   Callback = function()
      notify("Bloodmoon Mode", "When enabled:\n- All 3 monsters at 3 (hallucinations) are IGNORED\n- Real monster attacks (1-2 monsters at 3) still trigger teleport\n- Closet, Bear, Alarm, Lamp work normally", 5)
   end
})


-- ========== MANSION TABS ==========
local removeDangerRunning = false
local removeDangerThread = nil
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

local function setDangerToZero()
    local success = pcall(function()
        local accwithChat = workspace:FindFirstChild("AccwithChat")
        if accwithChat then
            local danger = accwithChat:FindFirstChild("Danger")
            if danger then
                danger.Value = 0
                return true
            end
        end
        return false
    end)
    return success
end

local function startRemoveDanger()
    removeDangerRunning = true
    mansionNotify("Remove Danger", "Started", 2)
    removeDangerThread = task.spawn(function()
        while removeDangerRunning do
            setDangerToZero()
            task.wait(0.1)
        end
    end)
end

local function stopRemoveDanger()
    removeDangerRunning = false
    if removeDangerThread then
        task.cancel(removeDangerThread)
        removeDangerThread = nil
    end
    mansionNotify("Remove Danger", "Stopped", 2)
end

MansionMainTab:CreateButton({
    Name = "remove danger (toggle)",
    Callback = function()
        if removeDangerRunning then
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

local function startKidAlert()
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
    kidAlertEnabled = false
    if kidAlertThread then
        task.cancel(kidAlertThread)
        kidAlertThread = nil
    end
    kidDetected = false
    mansionNotify("Kid Alert", "Tracking disabled", 2)
end

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

-- Mansion Visuals
local mansionFullbrightEnabled = false
local mansionFullbrightConnections = {}

local MansionButtonFullbright = MansionVisualsTab:CreateButton({
    Name = "Fullbright",
    Callback = function()
        mansionFullbrightEnabled = not mansionFullbrightEnabled
        mansionNotify("Fullbright", mansionFullbrightEnabled and "on" or "off", 2)
        if mansionFullbrightEnabled then
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
                if mansionFullbrightEnabled then
                    pcall(function()
                        applyFullbrightToPart(descendant)
                    end)
                end
            end)
            table.insert(mansionFullbrightConnections, descendantConn)
            local lightingConn = lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
                if mansionFullbrightEnabled then
                    lighting.Brightness = 3
                end
            end)
            table.insert(mansionFullbrightConnections, lightingConn)
        else
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 1
            lighting.Ambient = Color3.new(0, 0, 0)
            lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            lighting.ColorShift_Top = Color3.new(0, 0, 0)
            lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            lighting.GlobalShadows = true
            for _, conn in ipairs(mansionFullbrightConnections) do
                conn:Disconnect()
            end
            mansionFullbrightConnections = {}
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
local function bunkerTeleport(pos, matrix, name)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) * CFrame.fromMatrix(Vector3.new(), 
            matrix[1], matrix[2], matrix[3]
        )
        notify("Bunker", "Teleported to " .. name, 1.5)
        return true
    end
    return false
end

BunkerTab:CreateButton({
    Name = "Generator",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-29.2898579, 12.9999971, -153.711624),
            {
                Vector3.new(-0.0219825115, -3.6927613e-08, 0.999758363),
                Vector3.new(-3.63471777e-08, 1, 3.61373438e-08),
                Vector3.new(-0.999758363, -3.55440051e-08, -0.0219825115)
            },
            "Generator"
        )
    end
})

BunkerTab:CreateButton({
    Name = "PANELS",
    Callback = function() end
})

BunkerTab:CreateButton({
    Name = "Panel 1",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-80.2965317, 19.9999943, -137.576843),
            {
                Vector3.new(0.996404171, 8.92050025e-08, -0.0847270787),
                Vector3.new(-8.84429951e-08, 1, 1.27471447e-08),
                Vector3.new(0.0847270787, -5.20779198e-09, 0.996404171)
            },
            "Panel 1"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Panel 2",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-44.1996498, 19.9999943, 3.13688135),
            {
                Vector3.new(-0.998889863, 7.60308723e-08, -0.0471071675),
                Vector3.new(7.30606189e-08, 1, 6.47748664e-08),
                Vector3.new(0.0471071675, 6.12612823e-08, -0.998889863)
            },
            "Panel 2"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Panel 3",
    Callback = function()
        bunkerTeleport(
            Vector3.new(46.2096443, 23.9999962, -129.706573),
            {
                Vector3.new(-0.997824669, 8.74903439e-09, 0.0659234896),
                Vector3.new(1.49209729e-08, 1, 9.31304101e-08),
                Vector3.new(-0.0659234896, 9.3911467e-08, -0.997824669)
            },
            "Panel 3"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Panel 4",
    Callback = function()
        bunkerTeleport(
            Vector3.new(15.8920517, 19.9999943, -7.63388395),
            {
                Vector3.new(-0.996666372, 5.46512657e-09, 0.0815852359),
                Vector3.new(5.42985301e-09, 1, -6.54218124e-10),
                Vector3.new(-0.0815852359, -2.09041368e-10, -0.996666372)
            },
            "Panel 4"
        )
    end
})

BunkerTab:CreateButton({
    Name = "CANISTERS",
    Callback = function() end
})

BunkerTab:CreateButton({
    Name = "Canister 1",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-77.3688507, 19.9999943, -115.703163),
            {
                Vector3.new(-0.16882965, -8.25173672e-08, -0.985645235),
                Vector3.new(4.1822215e-08, 1, -9.08827928e-08),
                Vector3.new(0.985645235, -5.65655789e-08, -0.16882965)
            },
            "Canister 1"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Canister 2",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-44.6160164, 19.9999943, 2.17054081),
            {
                Vector3.new(-0.999980271, 2.927775e-08, 0.00627899822),
                Vector3.new(2.90886693e-08, 1, -3.02044292e-08),
                Vector3.new(-0.00627899822, -3.00211873e-08, -0.999980271)
            },
            "Canister 2"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Canister 3",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-33.8688202, 19.9999943, 3.15866494),
            {
                Vector3.new(-0.999506652, 1.68698762e-08, 0.0314080305),
                Vector3.new(1.73458776e-08, 1, 1.48829766e-08),
                Vector3.new(-0.0314080305, 1.54204347e-08, -0.999506652)
            },
            "Canister 3"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Canister 4",
    Callback = function()
        bunkerTeleport(
            Vector3.new(18.0693588, 23.9999943, -52.2483139),
            {
                Vector3.new(-0.0502426773, 9.52078949e-08, -0.998737037),
                Vector3.new(-3.12019388e-08, 1, 9.68979421e-08),
                Vector3.new(0.998737037, 3.60309436e-08, -0.0502426773)
            },
            "Canister 4"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Canister 5",
    Callback = function()
        bunkerTeleport(
            Vector3.new(16.1389828, 23.9999943, -118.857544),
            {
                Vector3.new(-0.999876738, 1.11387592e-07, 0.0157006197),
                Vector3.new(1.12046358e-07, 1, 4.10783372e-08),
                Vector3.new(-0.0157006197, 4.28324718e-08, -0.999876738)
            },
            "Canister 5"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Canister 6",
    Callback = function()
        bunkerTeleport(
            Vector3.new(82.5169907, 16.9999943, -2.82180023),
            {
                Vector3.new(-0.109728783, -7.03379666e-09, -0.993961573),
                Vector3.new(2.88870639e-09, 1, -7.39542783e-09),
                Vector3.new(0.993961573, -3.68275455e-09, -0.109728783)
            },
            "Canister 6"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Canister 7",
    Callback = function()
        bunkerTeleport(
            Vector3.new(-33.8688202, 19.9999943, 3.15866494),
            {
                Vector3.new(-0.962880611, 2.16337384e-08, -0.269927621),
                Vector3.new(7.95824295e-09, 1, 5.17579473e-08),
                Vector3.new(0.269927621, 4.76885731e-08, -0.962880611)
            },
            "Canister 7"
        )
    end
})

BunkerTab:CreateButton({
    Name = "OTHER",
    Callback = function() end
})

BunkerTab:CreateButton({
    Name = "End Point",
    Callback = function()
        bunkerTeleport(
            Vector3.new(16.3039112, 16.9999943, 71.6612854),
            {
                Vector3.new(-0.993611097, -3.63064356e-10, 0.112858333),
                Vector3.new(2.08186512e-09, 1, 2.15458495e-08),
                Vector3.new(-0.112858333, 2.16431513e-08, -0.993611097)
            },
            "End Point"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Ventilation",
    Callback = function()
        bunkerTeleport(
            Vector3.new(68.2763901, 16.9999943, 73.0313492),
            {
                Vector3.new(-0.999600291, -1.49585073e-08, 0.0282717124),
                Vector3.new(-1.36713512e-08, 1, 4.57213538e-08),
                Vector3.new(-0.0282717124, 4.53165647e-08, -0.999600291)
            },
            "Ventilation"
        )
    end
})

BunkerTab:CreateButton({
    Name = "Key",
    Callback = function()
        bunkerTeleport(
            Vector3.new(22.4428558, 23.9999943, -124.594475),
            {
                Vector3.new(0.0753375217, -5.74800971e-08, -0.99715811),
                Vector3.new(9.30486177e-09, 1, -5.69409124e-08),
                Vector3.new(0.99715811, -4.98863084e-09, 0.0753375217)
            },
            "Key"
        )
    end
})

-- ========== ITEM GRABBERS ==========
local spotIndexes1 = {2, 9, 3, 4, 6, 7, 8, 5, 10}
local itemNames1 = {"Wrench", "Medkit", "Hammer", "BloxyCola", "Battery"}

local function findItemInSpot1(spotIndex, itemName)
    local itemSpots = workspace:FindFirstChild("ItemSpots")
    if not itemSpots then return nil end
    local spot = itemSpots:GetChildren()[spotIndex]
    if not spot then return nil end
    local item = spot:FindFirstChild(itemName)
    if not item then return nil end
    local target = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
    if target and target:IsA("BasePart") then
        return {
            spot = spotIndex,
            cframe = target.CFrame,
            name = string.format("%s (Spot %d)", itemName, spotIndex)
        }
    end
    return nil
end

local function findAllItems1()
    local results = {}
    for _, spotIndex in ipairs(spotIndexes1) do
        for _, itemName in ipairs(itemNames1) do
            local item = findItemInSpot1(spotIndex, itemName)
            if item then table.insert(results, item) end
        end
    end
    return results
end

ItemGrabber1:CreateButton({
    Name = "Grab All Items",
    Callback = function()
        local results = findAllItems1()
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

ItemGrabber1:CreateButton({
    Name = "Wrench",
    Callback = function()
        local results = {}
        for _, spotIndex in ipairs(spotIndexes1) do
            local item = findItemInSpot1(spotIndex, "Wrench")
            if item then table.insert(results, item) end
        end
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

ItemGrabber1:CreateButton({
    Name = "Medkit",
    Callback = function()
        local results = {}
        for _, spotIndex in ipairs(spotIndexes1) do
            local item = findItemInSpot1(spotIndex, "Medkit")
            if item then table.insert(results, item) end
        end
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

ItemGrabber1:CreateButton({
    Name = "Hammer",
    Callback = function()
        local results = {}
        for _, spotIndex in ipairs(spotIndexes1) do
            local item = findItemInSpot1(spotIndex, "Hammer")
            if item then table.insert(results, item) end
        end
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

ItemGrabber1:CreateButton({
    Name = "BloxyCola",
    Callback = function()
        local results = {}
        for _, spotIndex in ipairs(spotIndexes1) do
            local item = findItemInSpot1(spotIndex, "BloxyCola")
            if item then table.insert(results, item) end
        end
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

ItemGrabber1:CreateButton({
    Name = "Battery",
    Callback = function()
        local results = {}
        for _, spotIndex in ipairs(spotIndexes1) do
            local item = findItemInSpot1(spotIndex, "Battery")
            if item then table.insert(results, item) end
        end
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

-- Item Grabber 2
local spotIndexes2 = {3, 15, 8, 2, 13, 12, 11, 10, 9, 14, 7, 6, 5, 4}
local itemNames2 = {"Wrench", "Medkit", "Hammer", "BloxyCola", "Battery"}

local function findItemInSpot2(spotIndex, itemName)
    local itemSpots = workspace:FindFirstChild("ItemSpots")
    if not itemSpots then return nil end
    local spot = itemSpots:GetChildren()[spotIndex]
    if not spot then return nil end
    local item = spot:FindFirstChild(itemName)
    if not item then return nil end
    local target = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
    if target and target:IsA("BasePart") then
        return {
            spot = spotIndex,
            cframe = target.CFrame,
            name = string.format("%s (Spot %d)", itemName, spotIndex)
        }
    end
    return nil
end

local function findAllItems2()
    local results = {}
    for _, spotIndex in ipairs(spotIndexes2) do
        for _, itemName in ipairs(itemNames2) do
            local item = findItemInSpot2(spotIndex, itemName)
            if item then table.insert(results, item) end
        end
    end
    return results
end

ItemGrabber2:CreateButton({
    Name = "Grab All Items",
    Callback = function()
        local results = findAllItems2()
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

for _, itemName in ipairs(itemNames2) do
    ItemGrabber2:CreateButton({
        Name = itemName,
        Callback = function()
            local results = {}
            for _, spotIndex in ipairs(spotIndexes2) do
                local item = findItemInSpot2(spotIndex, itemName)
                if item then table.insert(results, item) end
            end
            if #results > 0 then
                for _, res in ipairs(results) do
                    teleportTo(res.cframe)
                    task.wait(0.3)
                end
            end
        end
    })
end

-- Item Grabber 3
local spotIndexes3 = {14, 7, 2, 12, 11, 10, 9, 8, 13, 6, 5, 4, 3}
local itemNames3 = {"Camera", "BloxyCola", "Marshmallow", "Battery"}

local function findItemInSpot3(spotIndex, itemName)
    local itemSpots = workspace:FindFirstChild("ItemSpots")
    if not itemSpots then return nil end
    local spot
    if spotIndex == "Spot" then
        spot = itemSpots:FindFirstChild("Spot")
    else
        spot = itemSpots:GetChildren()[spotIndex]
    end
    if not spot then return nil end
    local item = spot:FindFirstChild(itemName)
    if not item then return nil end
    local target = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
    if target and target:IsA("BasePart") then
        local spotName = (spotIndex == "Spot") and "Spot" or "Spot " .. spotIndex
        return {
            spot = spotIndex,
            cframe = target.CFrame,
            name = string.format("%s (%s)", itemName, spotName)
        }
    end
    return nil
end

local function findAllItems3()
    local results = {}
    for _, spotIndex in ipairs(spotIndexes3) do
        for _, itemName in ipairs(itemNames3) do
            local item = findItemInSpot3(spotIndex, itemName)
            if item then table.insert(results, item) end
        end
    end
    for _, itemName in ipairs(itemNames3) do
        local spotItem = findItemInSpot3("Spot", itemName)
        if spotItem then table.insert(results, spotItem) end
    end
    return results
end

ItemGrabber3:CreateButton({
    Name = "Grab All Items",
    Callback = function()
        local results = findAllItems3()
        if #results > 0 then
            for _, res in ipairs(results) do
                teleportTo(res.cframe)
                task.wait(0.3)
            end
        end
    end
})

for _, itemName in ipairs(itemNames3) do
    ItemGrabber3:CreateButton({
        Name = itemName,
        Callback = function()
            local results = {}
            for _, spotIndex in ipairs(spotIndexes3) do
                local item = findItemInSpot3(spotIndex, itemName)
                if item then table.insert(results, item) end
            end
            local spotItem = findItemInSpot3("Spot", itemName)
            if spotItem then table.insert(results, spotItem) end
            if #results > 0 then
                for _, res in ipairs(results) do
                    teleportTo(res.cframe)
                    task.wait(0.3)
                end
            end
        end
    })
end
