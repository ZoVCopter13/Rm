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

local Tab = Window:CreateTab("main", 4483362458)

local sprintLoopRunning = false
local oxygenLoopRunning = false
local noclipEnabled = false
local noclipConnections = {}
local coldDisabled = false

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2.5
    })
end

local Button1 = Tab:CreateButton({
   Name = "Infinity sprint",
   Callback = function()
       sprintLoopRunning = not sprintLoopRunning
       notify("Infinity sprint", sprintLoopRunning and "on" or "off")
       
       if sprintLoopRunning then
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
   end
})

local Button2 = Tab:CreateButton({
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

local Button3 = Tab:CreateButton({
   Name = "Noclip",
   Callback = function()
       noclipEnabled = not noclipEnabled
       notify("Noclip", noclipEnabled and "on" or "off")
       
       if noclipEnabled then
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
       else
           for _, conn in ipairs(noclipConnections) do
               conn:Disconnect()
           end
           noclipConnections = {}
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

local Button4 = Tab:CreateButton({
   Name = "Info",
   Callback = function()
       notify("Info", "script ZOVCOPTER by NAGIEV\nAdded: Disable Cold, Auto Fix Panels, ESP (Mutant, Zombie, Stalker, Spider)", 5)
   end
})

local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local fullbrightEnabled = false
local fullbrightConnections = {}

local function highlightParts(model, color)
    if not model then return end
    
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = color
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = color
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Name = "PartHighlight_" .. color.r .. color.g .. color.b
            highlight.Parent = part
        end
    end
end

local function removeHighlights(model)
    if not model then return end
    
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Highlight") and child.Name:find("PartHighlight") then
                    child:Destroy()
                end
            end
        end
    end
end

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

local TeleportsTab = Window:CreateTab("teleports 1", 4483362458)

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

local NightTab = Window:CreateTab("night 2", 4483362458)

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

local Night3Tab = Window:CreateTab("night 3 teleports", 4483362458)

local function teleportTo(position, matrix)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        rootPart.CFrame = CFrame.new(position) * CFrame.fromMatrix(Vector3.new(), 
            matrix[1], matrix[2], matrix[3]
        )
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Jerry Can 1", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Jerry Can 2", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Jerry Can 3", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Jerry Can 4", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Lodge", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Cabin 1", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Cabin 2", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Cabin 3", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
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
        if teleportTo(position, matrix) then
            notify("Teleport", "Teleported to Cabin 4", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
    end
})

Night3Tab:CreateButton({
    Name = "teleport to base spawn",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            notify("Teleport", "Returned to base spawn", 1.5)
        else
            notify("Error", "Character not found", 2)
        end
    end
})
