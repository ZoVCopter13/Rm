-- BUNKER HELPER STANDALONE GUI
-- Отдельный скрипт для бункера с собственным GUI

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Bunker Helper",
   Icon = 0,
   LoadingTitle = "Bunker Helper",
   LoadingSubtitle = "Bunker Assistant",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BunkerHelper",
      FileName = "BunkerSettings"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("bunker", 4483362458)

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2.5,
        Image = 4483362458
    })
end

-- ========== TELEPORT FUNCTIONS ==========
local function teleportTo(cf)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = cf
        return true
    end
    return false
end

local function bunkerTeleport(pos, matrix, name)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) * CFrame.fromMatrix(Vector3.new(), 
            matrix[1], matrix[2], matrix[3]
        )
        notify("Teleport", "Teleported to " .. name, 1.5)
        return true
    end
    return false
end

-- ========== AUTO FUEL FUNCTIONS ==========
local isFuelRunning = false
local fuelThread = nil
local fuelOriginalCFrame = nil
local usedJerryCans = {}

local function getAllJerryCans()
    local cans = {}
    local jerryCans = workspace:FindFirstChild("JerryCans")
    if not jerryCans then return cans end
    
    local indexes = {5, 3, 2, 4}
    for _, idx in ipairs(indexes) do
        local can = jerryCans:GetChildren()[idx]
        if can and not usedJerryCans[can] then
            table.insert(cans, can)
        end
    end
    
    local defaultCan = jerryCans:FindFirstChild("JerryCan")
    if defaultCan and not usedJerryCans[defaultCan] then
        table.insert(cans, defaultCan)
    end
    
    return cans
end

local function clickDetector(detector)
    if detector then
        pcall(function() fireclickdetector(detector) end)
        return true
    end
    return false
end

local function getJerryCanClickDetector(jerryCan)
    if jerryCan then
        local detector = jerryCan:FindFirstChild("ClickDetector")
        if detector then return detector end
        for _, child in pairs(jerryCan:GetDescendants()) do
            if child:IsA("ClickDetector") then return child end
        end
    end
    return nil
end

local function hasJerryCanInInventory()
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    local character = player.Character
    if character and character:FindFirstChild("JerryCan") then return true end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("JerryCan") then return true end
    
    return false
end

local function getRandomJerryCan()
    local cans = getAllJerryCans()
    if #cans == 0 then return nil end
    return cans[math.random(1, #cans)]
end

local function startAutoFuel()
    if isFuelRunning then
        notify("Auto Fuel", "Already running!", 2)
        return
    end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        notify("Error", "Character not found", 2)
        return
    end
    
    local jerryCan = getRandomJerryCan()
    if not jerryCan then
        notify("Error", "No available JerryCans found!", 2)
        return
    end
    
    isFuelRunning = true
    fuelOriginalCFrame = player.Character.HumanoidRootPart.CFrame
    
    local detector = getJerryCanClickDetector(jerryCan)
    if not detector then
        notify("Error", "ClickDetector not found", 2)
        isFuelRunning = false
        return
    end
    
    if not teleportTo(jerryCan:GetPivot()) then
        notify("Error", "Failed to teleport", 2)
        isFuelRunning = false
        return
    end
    
    notify("Refuel", "Teleported to JerryCan!", 2)
    task.wait(0.3)
    clickDetector(detector)
    usedJerryCans[jerryCan] = true
    notify("Refuel", "Waiting for JerryCan...", 2)
    
    fuelThread = task.spawn(function()
        local hasJerry = false
        while isFuelRunning do
            local hasInventory = hasJerryCanInInventory()
            if hasInventory and not hasJerry then
                hasJerry = true
                notify("Refuel", "JerryCan in inventory! Teleporting to generator...", 2)
                
                local genPos = CFrame.new(-30.0816879, 12.9999971, -153.728439) * CFrame.fromMatrix(Vector3.new(), 
                    Vector3.new(-0.0157155432, -3.22039675e-08, 0.999876499),
                    Vector3.new(-1.49766368e-08, 1, 3.19725473e-08),
                    Vector3.new(-0.999876499, -1.44723211e-08, -0.0157155432)
                )
                
                if teleportTo(genPos) then
                    task.wait(0.3)
                    local generator = workspace:FindFirstChild("Generator")
                    if generator then
                        local genDetector = generator:FindFirstChild("ClickDetector")
                        if genDetector then clickDetector(genDetector) end
                    end
                end
            end
            if hasJerry and not hasInventory then
                notify("Refuel", "Generator refueled! Returning...", 2)
                break
            end
            task.wait(0.2)
        end
        teleportTo(fuelOriginalCFrame)
        notify("Refuel", "Returned!", 2)
        isFuelRunning = false
        fuelThread = nil
    end)
end

-- ========== FIX VENTILATION FUNCTIONS ==========
local isVentRunning = false
local ventThread = nil
local ventOriginalCFrame = nil

local function getDebrisParts()
    local parts = {}
    local ventilation = workspace:FindFirstChild("Ventilation")
    if not ventilation then return parts end
    local debris = ventilation:FindFirstChild("Debris")
    if not debris then return parts end
    
    local indexes = {4, 2, 3}
    for _, idx in ipairs(indexes) do
        local part = debris:GetChildren()[idx]
        if part then table.insert(parts, part) end
    end
    local defaultDebris = debris:FindFirstChild("Debris")
    if defaultDebris then table.insert(parts, defaultDebris) end
    return parts
end

local function allDebrisTransparent()
    local parts = getDebrisParts()
    if #parts == 0 then return false end
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and part.Transparency ~= 1 then return false end
    end
    return true
end

local function startFixVentilation()
    if isVentRunning then
        notify("Fix Ventilation", "Already running!", 2)
        return
    end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        notify("Error", "Character not found", 2)
        return
    end
    
    isVentRunning = true
    ventOriginalCFrame = player.Character.HumanoidRootPart.CFrame
    
    local ventPos = CFrame.new(68.4254227, 16.9999943, 72.9057236) * CFrame.fromMatrix(Vector3.new(), 
        Vector3.new(-0.999506295, 5.29131272e-09, 0.0314188525),
        Vector3.new(5.40736034e-09, 1, 3.60859964e-09),
        Vector3.new(-0.0314188525, 3.77671094e-09, -0.999506295)
    )
    
    if not teleportTo(ventPos) then
        notify("Error", "Failed to teleport", 2)
        isVentRunning = false
        return
    end
    
    notify("Fix Ventilation", "Teleported! Clicking debris...", 2)
    task.wait(0.3)
    
    local ventilation = workspace:FindFirstChild("Ventilation")
    if ventilation then
        for _, detector in pairs(ventilation:GetDescendants()) do
            if detector:IsA("ClickDetector") then
                clickDetector(detector)
                task.wait(0.2)
            end
        end
    end
    
    notify("Fix Ventilation", "Waiting for debris to disappear...", 2)
    
    ventThread = task.spawn(function()
        while isVentRunning do
            if allDebrisTransparent() then
                notify("Fix Ventilation", "Debris cleared! Returning...", 2)
                break
            end
            task.wait(0.5)
        end
        teleportTo(ventOriginalCFrame)
        notify("Fix Ventilation", "Returned!", 2)
        isVentRunning = false
        ventThread = nil
    end)
end

-- ========== BUNKER RAT ESP ==========
local ratEspEnabled = false
local ratEspThread = nil
local ratHighlights = {}

local function addRatHighlight(rat, color)
    if not rat then return end
    for _, part in pairs(rat:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = color
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = color
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Name = "BunkerRatESP"
            highlight.Parent = part
            table.insert(ratHighlights, highlight)
        end
    end
end

local function removeRatHighlights()
    for _, h in ipairs(ratHighlights) do
        pcall(function() h:Destroy() end)
    end
    ratHighlights = {}
end

local function findAndHighlightRat()
    removeRatHighlights()
    local rat = workspace:FindFirstChild("BunkerRat")
    if rat then
        addRatHighlight(rat, Color3.fromRGB(139, 69, 19))
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "BunkerRat" and obj:IsA("Model") then
            addRatHighlight(obj, Color3.fromRGB(139, 69, 19))
        end
    end
end

local function startRatESP()
    if ratEspEnabled then return end
    ratEspEnabled = true
    notify("Bunker Rat ESP", "Started!", 2)
    findAndHighlightRat()
    ratEspThread = task.spawn(function()
        while ratEspEnabled do
            findAndHighlightRat()
            task.wait(2)
        end
    end)
end

local function stopRatESP()
    if not ratEspEnabled then return end
    ratEspEnabled = false
    if ratEspThread then task.cancel(ratEspThread) end
    removeRatHighlights()
    notify("Bunker Rat ESP", "Stopped!", 2)
end

-- ========== FULLBRIGHT ==========
local fullbrightEnabled = false
local fullbrightConnections = {}

local function applyFullbright()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 3
    lighting.Ambient = Color3.new(1, 1, 1)
    lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    lighting.ColorShift_Top = Color3.new(1, 1, 1)
    lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    lighting.FogColor = Color3.new(0.75, 0.75, 0.75)
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    
    local function applyToPart(part)
        if part:IsA("BasePart") and part.Material ~= Enum.Material.Neon then
            if part.Material ~= Enum.Material.ForceField then
                part.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    
    for _, part in pairs(workspace:GetDescendants()) do
        pcall(function() applyToPart(part) end)
    end
    
    local descendantConn = workspace.DescendantAdded:Connect(function(descendant)
        if fullbrightEnabled then pcall(function() applyToPart(descendant) end) end
    end)
    table.insert(fullbrightConnections, descendantConn)
    
    local lightingConn = lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if fullbrightEnabled then lighting.Brightness = 3 end
    end)
    table.insert(fullbrightConnections, lightingConn)
end

local function restoreLighting()
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

local function toggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        applyFullbright()
        notify("Fullbright", "ON", 2)
    else
        restoreLighting()
        notify("Fullbright", "OFF", 2)
    end
end

-- ========== BUNKER TELEPORTS ==========
local teleports = {
    {name = "Generator", pos = Vector3.new(-29.2898579, 12.9999971, -153.711624), mat = {
        Vector3.new(-0.0219825115, -3.6927613e-08, 0.999758363),
        Vector3.new(-3.63471777e-08, 1, 3.61373438e-08),
        Vector3.new(-0.999758363, -3.55440051e-08, -0.0219825115)
    }},
    {name = "Panel 1", pos = Vector3.new(-80.2965317, 19.9999943, -137.576843), mat = {
        Vector3.new(0.996404171, 8.92050025e-08, -0.0847270787),
        Vector3.new(-8.84429951e-08, 1, 1.27471447e-08),
        Vector3.new(0.0847270787, -5.20779198e-09, 0.996404171)
    }},
    {name = "Panel 2", pos = Vector3.new(-44.1996498, 19.9999943, 3.13688135), mat = {
        Vector3.new(-0.998889863, 7.60308723e-08, -0.0471071675),
        Vector3.new(7.30606189e-08, 1, 6.47748664e-08),
        Vector3.new(0.0471071675, 6.12612823e-08, -0.998889863)
    }},
    {name = "Panel 3", pos = Vector3.new(46.2096443, 23.9999962, -129.706573), mat = {
        Vector3.new(-0.997824669, 8.74903439e-09, 0.0659234896),
        Vector3.new(1.49209729e-08, 1, 9.31304101e-08),
        Vector3.new(-0.0659234896, 9.3911467e-08, -0.997824669)
    }},
    {name = "Panel 4", pos = Vector3.new(15.8920517, 19.9999943, -7.63388395), mat = {
        Vector3.new(-0.996666372, 5.46512657e-09, 0.0815852359),
        Vector3.new(5.42985301e-09, 1, -6.54218124e-10),
        Vector3.new(-0.0815852359, -2.09041368e-10, -0.996666372)
    }},
    {name = "Canister 1", pos = Vector3.new(-77.3688507, 19.9999943, -115.703163), mat = {
        Vector3.new(-0.16882965, -8.25173672e-08, -0.985645235),
        Vector3.new(4.1822215e-08, 1, -9.08827928e-08),
        Vector3.new(0.985645235, -5.65655789e-08, -0.16882965)
    }},
    {name = "Canister 2", pos = Vector3.new(-44.6160164, 19.9999943, 2.17054081), mat = {
        Vector3.new(-0.999980271, 2.927775e-08, 0.00627899822),
        Vector3.new(2.90886693e-08, 1, -3.02044292e-08),
        Vector3.new(-0.00627899822, -3.00211873e-08, -0.999980271)
    }},
    {name = "Canister 3", pos = Vector3.new(-33.8688202, 19.9999943, 3.15866494), mat = {
        Vector3.new(-0.999506652, 1.68698762e-08, 0.0314080305),
        Vector3.new(1.73458776e-08, 1, 1.48829766e-08),
        Vector3.new(-0.0314080305, 1.54204347e-08, -0.999506652)
    }},
    {name = "Canister 4", pos = Vector3.new(18.0693588, 23.9999943, -52.2483139), mat = {
        Vector3.new(-0.0502426773, 9.52078949e-08, -0.998737037),
        Vector3.new(-3.12019388e-08, 1, 9.68979421e-08),
        Vector3.new(0.998737037, 3.60309436e-08, -0.0502426773)
    }},
    {name = "Canister 5", pos = Vector3.new(16.1389828, 23.9999943, -118.857544), mat = {
        Vector3.new(-0.999876738, 1.11387592e-07, 0.0157006197),
        Vector3.new(1.12046358e-07, 1, 4.10783372e-08),
        Vector3.new(-0.0157006197, 4.28324718e-08, -0.999876738)
    }},
    {name = "Canister 6", pos = Vector3.new(82.5169907, 16.9999943, -2.82180023), mat = {
        Vector3.new(-0.109728783, -7.03379666e-09, -0.993961573),
        Vector3.new(2.88870639e-09, 1, -7.39542783e-09),
        Vector3.new(0.993961573, -3.68275455e-09, -0.109728783)
    }},
    {name = "Canister 7", pos = Vector3.new(-33.8688202, 19.9999943, 3.15866494), mat = {
        Vector3.new(-0.962880611, 2.16337384e-08, -0.269927621),
        Vector3.new(7.95824295e-09, 1, 5.17579473e-08),
        Vector3.new(0.269927621, 4.76885731e-08, -0.962880611)
    }},
    {name = "End Point", pos = Vector3.new(16.3039112, 16.9999943, 71.6612854), mat = {
        Vector3.new(-0.993611097, -3.63064356e-10, 0.112858333),
        Vector3.new(2.08186512e-09, 1, 2.15458495e-08),
        Vector3.new(-0.112858333, 2.16431513e-08, -0.993611097)
    }},
    {name = "Ventilation", pos = Vector3.new(68.2763901, 16.9999943, 73.0313492), mat = {
        Vector3.new(-0.999600291, -1.49585073e-08, 0.0282717124),
        Vector3.new(-1.36713512e-08, 1, 4.57213538e-08),
        Vector3.new(-0.0282717124, 4.53165647e-08, -0.999600291)
    }},
    {name = "Key", pos = Vector3.new(22.4428558, 23.9999943, -124.594475), mat = {
        Vector3.new(0.0753375217, -5.74800971e-08, -0.99715811),
        Vector3.new(9.30486177e-09, 1, -5.69409124e-08),
        Vector3.new(0.99715811, -4.98863084e-09, 0.0753375217)
    }}
}

-- ========== КНОПКИ GUI ==========
MainTab:CreateButton({
    Name = "Refill Generator",
    Callback = startAutoFuel
})

MainTab:CreateButton({
    Name = "Fix Ventilation",
    Callback = function()
        if isVentRunning then
            local function stopVent()
                isVentRunning = false
                if ventThread then task.cancel(ventThread) end
                if ventOriginalCFrame then teleportTo(ventOriginalCFrame) end
                notify("Fix Ventilation", "Stopped", 2)
            end
            stopVent()
        else
            startFixVentilation()
        end
    end
})

MainTab:CreateButton({
    Name = "────────── Teleports ──────────",
    Callback = function() end
})

for _, tp in ipairs(teleports) do
    MainTab:CreateButton({
        Name = "Teleport to " .. tp.name,
        Callback = function()
            bunkerTeleport(tp.pos, tp.mat, tp.name)
        end
    })
end

MainTab:CreateButton({
    Name = "────────── ESP ──────────",
    Callback = function() end
})

MainTab:CreateButton({
    Name = "Bunker Rat ESP",
    Callback = function()
        if ratEspEnabled then stopRatESP() else startRatESP() end
    end
})

MainTab:CreateButton({
    Name = "Fullbright",
    Callback = toggleFullbright
})

