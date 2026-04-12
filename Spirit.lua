-- SPIRIT HELPER STANDALONE GUI
-- Отдельный скрипт для Spirit Helper с собственным GUI и подсветкой

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Spirit Helper",
   Icon = 0,
   LoadingTitle = "Spirit Helper",
   LoadingSubtitle = "Auto Assistant",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SpiritHelper",
      FileName = "SpiritSettings"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("spirit helper", 4483362458)

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2.5,
        Image = 4483362458
    })
end

-- Переменные для подсветки
local currentHighlight = nil
local currentBillboard = nil
local lampHeatBillboard = nil

-- Функция для удаления подсветки
local function removeHighlight()
    if currentHighlight then
        pcall(function() currentHighlight:Destroy() end)
        currentHighlight = nil
    end
    if currentBillboard then
        pcall(function() currentBillboard:Destroy() end)
        currentBillboard = nil
    end
end

-- Функция для подсветки объекта
local function highlightObject(obj, color, objName)
    removeHighlight()
    if not obj then return end
    
    -- Highlight для подсветки самого объекта
    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    currentHighlight = highlight
    
    -- Billboard для текста над объектом
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = objName or obj.Name
    text.TextColor3 = color
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.5
    text.Parent = frame
    
    currentBillboard = billboard
end

-- Функция для поиска Heat в любом месте
local function findLampHeat()
    -- Ищем в Lamp
    local lamp = workspace:FindFirstChild("Lamp")
    if lamp then
        local heat = lamp:FindFirstChild("Heat")
        if heat then return heat end
        
        -- Ищем во всех потомках Lamp
        for _, child in pairs(lamp:GetDescendants()) do
            if child.Name == "Heat" and child:IsA("NumberValue") then
                return child
            end
        end
    end
    
    -- Ищем во всем workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Heat" and obj:IsA("NumberValue") then
            local parent = obj.Parent
            if parent and (parent.Name == "Lamp" or parent.Name == "Bulb") then
                return obj
            end
        end
    end
    
    return nil
end

-- Функция для получения температуры
local function spiritGetHeat()
    local heatObj = findLampHeat()
    if heatObj then
        return heatObj.Value
    end
    return nil
end

-- Функция для подсветки лампы с температурой
local function setupLampHeatDisplay()
    local lamp = workspace:FindFirstChild("Lamp")
    if not lamp then 
        print("Lamp not found")
        return 
    end
    
    -- Ищем Bulb
    local bulb = lamp:FindFirstChild("Bulb")
    if not bulb then
        bulb = lamp:FindFirstChildWhichIsA("BasePart")
    end
    if not bulb then return end
    
    -- Удаляем старый дисплей если есть
    local oldDisplay = lamp:FindFirstChild("LampHeatDisplay")
    if oldDisplay then oldDisplay:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LampHeatDisplay"
    billboard.Adornee = bulb
    billboard.Size = UDim2.new(0, 120, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = bulb
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
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
    
    lampHeatBillboard = billboard
    
    -- Обновление температуры
    task.spawn(function()
        while lampHeatBillboard and lampHeatBillboard.Parent do
            local heat = spiritGetHeat()
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
                textLabel.Text = "Heat not found"
                frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
            task.wait(0.2)
        end
    end)
end

-- Функция для удаления дисплея лампы
local function removeLampHeatDisplay()
    if lampHeatBillboard then
        pcall(function() lampHeatBillboard:Destroy() end)
        lampHeatBillboard = nil
    end
    local lamp = workspace:FindFirstChild("Lamp")
    if lamp then
        local oldDisplay = lamp:FindFirstChild("LampHeatDisplay")
        if oldDisplay then oldDisplay:Destroy() end
    end
end

-- Переменные
local spiritEnabled = false
local spiritThread = nil
local spiritBloodmoon = false
local spiritData = {
   lampTime = 0, alarmTime = 0, bearTime = 0, lampHeat = -1,
   maxDist = nil, bearDist = nil, closetProgress = nil,
   lampHeatVal = -1, lampIncreaseTime = 0, monsterCooldown = 0,
   distAt8 = false, bedHidden = false,
   monsterProgress = {Door = 0, Window = 0, Vent = 0}
}

local spiritPos = {
   alarm = {pos = Vector3.new(-11.0053978, 5.00000334, 17.0491295), mat = {
      Vector3.new(-0.00265719951, 0, 0.999996483),
      Vector3.new(0, 1, 0),
      Vector3.new(-0.999996483, 0, -0.00265719951)
   }, name = "Alarm", objName = "Radio"},
   bed = {pos = Vector3.new(-4.52546644, 5.00000334, 17.4178753), mat = {
      Vector3.new(0.0772480145, 0, -0.9970119),
      Vector3.new(0, 1, 0),
      Vector3.new(0.9970119, 0, 0.0772480145)
   }, name = "Bed", objName = "Bed"},
   bear = {pos = Vector3.new(-8.43876457, 5.00000334, -8.79197693), mat = {
      Vector3.new(0.997374952, 0, 0.072410278),
      Vector3.new(0, 1, 0),
      Vector3.new(-0.072410278, 0, 0.997374952)
   }, name = "Bear", objName = "Teddy bear"},
   lamp = {pos = Vector3.new(8.50332642, 5.00000334, 19.6756325), mat = {
      Vector3.new(-0.998574674, 3.19413402e-08, 0.0533724651),
      Vector3.new(3.10384749e-08, 1, -1.77452169e-08),
      Vector3.new(-0.0533724651, -1.60633249e-08, -0.998574674)
   }, name = "Lamp", objName = "Lamp"},
   closet = {pos = Vector3.new(4.13197184, 5.12111855, -8.41910362), mat = {
      Vector3.new(0.993054211, 0, 0.117657781),
      Vector3.new(0, 1, 0),
      Vector3.new(-0.117657781, 0, 0.993054211)
   }, name = "Closet", objName = "Closet"}
}

local function spiritTP(loc) 
   local p = game.Players.LocalPlayer
   if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
      p.Character.HumanoidRootPart.CFrame = CFrame.new(spiritPos[loc].pos) * CFrame.fromMatrix(Vector3.new(), 
         spiritPos[loc].mat[1], spiritPos[loc].mat[2], spiritPos[loc].mat[3]
      )
      -- Подсвечиваем объект после телепортации
      local targetObj = workspace:FindFirstChild(spiritPos[loc].objName)
      if targetObj then
         highlightObject(targetObj, Color3.fromRGB(255, 255, 0), spiritPos[loc].name)
         task.wait(2)
         removeHighlight()
      end
      return true
   end
   return false
end

local function spiritGetRadioDist()
   local s, v = pcall(function()
      local radio = workspace:FindFirstChild("Radio")
      return radio and radio:FindFirstChild("ClickDetector") and radio.ClickDetector.MaxActivationDistance or nil
   end)
   return s and v or nil
end

local function spiritGetBearDist()
   local s, v = pcall(function()
      local bear = workspace:FindFirstChild("Teddy bear")
      return bear and bear:FindFirstChild("ClickDetector") and bear.ClickDetector.MaxActivationDistance or nil
   end)
   return s and v or nil
end

local function spiritGetCloset()
   local s, v = pcall(function()
      local mon = workspace:FindFirstChild("Monster")
      return mon and mon:FindFirstChild("Closet") and mon.Closet:FindFirstChild("Progress") and mon.Closet.Progress.Value or nil
   end)
   return s and v or nil
end

local function spiritBedHidden()
   local s, v = pcall(function()
      local bed = workspace:FindFirstChild("Bed")
      return bed and bed:FindFirstChild("Hidden") and bed.Hidden.Value or false
   end)
   return s and v or false
end

local function spiritMonsterProgress()
   local mon = workspace:FindFirstChild("Monster")
   if not mon then return 0, {}, 0 end
   local maxP, det, cnt3 = 0, {}, 0
   for _, p in ipairs({"Door", "Window", "Vent"}) do
      local t = mon:FindFirstChild(p)
      if t and t:FindFirstChild("Progress") then
         det[p] = t.Progress.Value
         if det[p] > maxP then maxP = det[p] end
         if det[p] == 3 then cnt3 = cnt3 + 1 end
      end
   end
   return maxP, det, cnt3
end

local function spiritCheckAndAct()
   local now = tick()
   local hidden = spiritBedHidden()
   local mProgress, mDetails, cnt3 = spiritMonsterProgress()

   if hidden ~= spiritData.bedHidden then spiritData.bedHidden = hidden end

   for p, v in pairs(mDetails) do
      if spiritData.monsterProgress[p] ~= nil and v ~= spiritData.monsterProgress[p] then
         if v == 0 and spiritData.monsterProgress[p] > 0 then
            notify("MONSTER IS GONE!", p .. " reset to 0", 5)
         end
      end
      spiritData.monsterProgress[p] = v
   end

   if mProgress == 3 then
      local heat = spiritGetHeat()
      if heat and heat - (spiritData.lampHeatVal == -1 and heat or spiritData.lampHeatVal) >= 0.2 and now - spiritData.lampIncreaseTime >= 2 then
         notify("LAMP HEAT INCREASE!", 2)
         spiritTP("lamp")
         spiritData.lampTime = now
         spiritData.lampIncreaseTime = now
         spiritData.lampHeatVal = heat
         return
      end
   end

   local closetP = spiritGetCloset()
   if closetP and spiritData.closetProgress ~= nil then
      if closetP == 3 and spiritData.closetProgress ~= 3 then
         notify("CLOSET ALERT!", "Teleporting to closet!", 3)
         spiritTP("closet")
         spiritData.closetProgress = closetP
         return
      end
      if closetP == 0 and spiritData.closetProgress == 3 then
         notify("CLOSET RESET!", "Teleporting to lamp!", 2)
         spiritTP("lamp")
         spiritData.lampTime = now
         spiritData.closetProgress = closetP
         return
      end
   end
   spiritData.closetProgress = closetP

   if hidden then return end

   local bearDist = spiritGetBearDist()
   if bearDist then
      if spiritData.bearDist ~= nil and bearDist == 0 and spiritData.bearDist > 0 then
         notify("BEAR RESET!", "Teleporting to lamp!", 2)
         spiritTP("lamp")
         spiritData.lampTime = now
         spiritData.bearDist = bearDist
         return
      end
      if bearDist >= 6 and bearDist <= 8 and now - spiritData.bearTime >= 3 then
         notify("BEAR!", "Distance: " .. bearDist, 2)
         spiritTP("bear")
         spiritData.bearTime = now
         spiritData.bearDist = bearDist
         return
      end
      spiritData.bearDist = bearDist
   end

   local heat = spiritGetHeat()
   if heat then
      if heat ~= spiritData.lampHeat then spiritData.lampHeat = heat end
      local needTP = false
      local action = ""
      if heat == 0 then needTP, action = true, "TURN ON"
      elseif heat >= 60 and heat <= 70 then needTP, action = true, "TURN OFF (" .. heat .. ")" end
      if needTP and now - spiritData.lampTime > 5 then
         notify("LAMP NEEDS " .. action .. "!", "Heat: " .. heat, 3)
         spiritTP("lamp")
         spiritData.lampTime = now
         return
      end
   end

   local radioDist = spiritGetRadioDist()
   if radioDist then
      if spiritData.maxDist ~= nil and radioDist == 0 and spiritData.maxDist > 0 then
         notify("ALARM RESET!", "Teleporting to lamp!", 2)
         spiritTP("lamp")
         spiritData.lampTime = now
         spiritData.maxDist = radioDist
         return
      end
      if radioDist == 8 then
         if not spiritData.distAt8 then
            notify("RADIO READY!", "Teleporting every 2 seconds", 2)
            spiritData.distAt8 = true
         end
      else
         if spiritData.distAt8 then spiritData.distAt8 = false end
      end
      if spiritData.distAt8 and now - spiritData.alarmTime >= 2 then
         notify("ALARM!", "Teleporting to alarm", 1.5)
         spiritTP("alarm")
         spiritData.alarmTime = now
         return
      end
      spiritData.maxDist = radioDist
   end

   if mProgress == 3 then
      if spiritBloodmoon then
         if cnt3 == 3 then return end
      end
      if now - spiritData.monsterCooldown > 10 then
         spiritData.monsterCooldown = now
         notify("MONSTER AT 3!", "Teleporting to lamp first!", 3)
         spiritTP("lamp")
         task.wait(3)
         notify("MONSTER AT 3!", "Now teleporting to bed!", 3)
         spiritTP("bed")
         task.wait(2)
      end
      return
   end
end

local function startSpirit()
   if spiritEnabled then 
      notify("Spirit Helper", "Already running!", 2)
      return 
   end
   spiritEnabled = true
   spiritData.lampTime = tick()
   spiritData.alarmTime = tick()
   spiritData.bearTime = tick()
   spiritData.lampIncreaseTime = tick()
   spiritData.monsterCooldown = 0
   spiritData.bedHidden = spiritBedHidden()
   spiritData.lampHeat = spiritGetHeat()
   spiritData.lampHeatVal = spiritGetHeat()
   spiritData.maxDist = spiritGetRadioDist()
   spiritData.bearDist = spiritGetBearDist()
   spiritData.closetProgress = spiritGetCloset()
   spiritData.distAt8 = (spiritData.maxDist == 8)
   local _, details, _ = spiritMonsterProgress()
   for p, v in pairs(details) do spiritData.monsterProgress[p] = v end
   notify("Spirit Helper", "Started!", 2)
   
   -- Устанавливаем дисплей температуры лампы
   setupLampHeatDisplay()
   
   spiritThread = task.spawn(function()
      while spiritEnabled do
         pcall(spiritCheckAndAct)
         task.wait(0.3)
      end
   end)
end

local function stopSpirit()
   if not spiritEnabled then 
      notify("Spirit Helper", "Not running!", 2)
      return 
   end
   spiritEnabled = false
   if spiritThread then task.cancel(spiritThread) spiritThread = nil end
   notify("Spirit Helper", "Stopped!", 2)
   
   -- Удаляем дисплей лампы
   removeLampHeatDisplay()
   removeHighlight()
end

local function toggleBloodmoon()
   spiritBloodmoon = not spiritBloodmoon
   notify("Bloodmoon Mode", spiritBloodmoon and "ENABLED" or "DISABLED", 3)
end

-- Кнопки
MainTab:CreateButton({
   Name = "START Spirit Helper",
   Callback = startSpirit
})

MainTab:CreateButton({
   Name = "STOP Spirit Helper",
   Callback = stopSpirit
})

MainTab:CreateButton({
   Name = "Force check lamp",
   Callback = function()
      local heat = spiritGetHeat()
      if not heat then 
         notify("Error", "Lamp Heat not found! Make sure lamp is nearby.", 2)
         return 
      end
      notify("Lamp Heat", "Current: " .. heat, 2)
      if heat == 0 or (heat >= 60 and heat <= 70) then
         notify("Manual teleport", "Teleporting to lamp", 2)
         spiritTP("lamp")
      end
   end
})

MainTab:CreateButton({
   Name = "BLOODMOON MODE",
   Callback = toggleBloodmoon
})


