-- Snake Game v4.0 (с настраиваемым Keybind для меню)
-- Управление стрелками через ContextActionService, открытие/закрытие окна по клавише (по умолчанию K, можно сменить)

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- для смены keybind
local player = Players.LocalPlayer

-- ----- Настройки сохранения (через writefile) -----
local SAVE_FOLDER = "SnakeGame"
local SAVE_FILE = "config.json"
local defaultKeybind = "K"
local menuKeybind = defaultKeybind

local function saveConfig()
    if not writefile then return end
    pcall(function()
        if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
        local data = { menuKeybind = menuKeybind }
        writefile(SAVE_FOLDER .. "/" .. SAVE_FILE, game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function loadConfig()
    if not readfile then return end
    pcall(function()
        local data = readfile(SAVE_FOLDER .. "/" .. SAVE_FILE)
        if data then
            local decoded = game:GetService("HttpService"):JSONDecode(data)
            if decoded and decoded.menuKeybind then
                menuKeybind = decoded.menuKeybind
            end
        end
    end)
end
loadConfig()

-- ----- GUI -----
local gui = Instance.new("ScreenGui")
gui.Name = "SnakeGame"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Константы поля
local GRID_SIZE = 20
local CELL_SIZE = 25
local FIELD_WIDTH = GRID_SIZE * CELL_SIZE
local FIELD_HEIGHT = GRID_SIZE * CELL_SIZE

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, FIELD_WIDTH + 100, 0, FIELD_HEIGHT + 100)
mainFrame.Position = UDim2.new(0.5, -(FIELD_WIDTH+100)/2, 0.5, -(FIELD_HEIGHT+100)/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.Text = "Snake Game (arrow keys)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Игровое поле
local gameField = Instance.new("Frame")
gameField.Size = UDim2.new(0, FIELD_WIDTH, 0, FIELD_HEIGHT)
gameField.Position = UDim2.new(0.5, -FIELD_WIDTH/2, 0.5, -FIELD_HEIGHT/2 + 15)
gameField.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
gameField.BorderSizePixel = 1
gameField.BorderColor3 = Color3.fromRGB(100, 100, 100)
gameField.Parent = mainFrame

-- Счёт
local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(1, 0, 0, 30)
scoreLabel.Position = UDim2.new(0, 0, 1, -30)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "Score: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scoreLabel.Font = Enum.Font.Gotham
scoreLabel.TextSize = 16
scoreLabel.Parent = mainFrame

-- Кнопка рестарта
local restartBtn = Instance.new("TextButton")
restartBtn.Size = UDim2.new(0, 80, 0, 25)
restartBtn.Position = UDim2.new(1, -85, 1, -30)
restartBtn.Text = "Restart"
restartBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
restartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restartBtn.Parent = mainFrame

-- Кнопка смены Keybind
local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(0, 120, 0, 25)
keybindBtn.Position = UDim2.new(1, -210, 1, -30)
keybindBtn.Text = "Change Keybind"
keybindBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindBtn.Parent = mainFrame

-- Метка текущего Keybind
local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(0, 120, 0, 25)
keybindLabel.Position = UDim2.new(1, -210, 1, -60)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Menu key: " .. menuKeybind
keybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextSize = 12
keybindLabel.Parent = mainFrame

-- --- Состояние игры ---
local snake = {}
local snakeFrames = {}
local foodPos = nil
local foodFrame = nil
local direction = "right"
local nextDirection = "right"
local gameRunning = false
local score = 0
local stepTime = 0.15
local lastStep = 0

-- Функции игры
local function posToUDim2(x, y)
    return UDim2.new(0, (x-1) * CELL_SIZE, 0, (y-1) * CELL_SIZE)
end

local function createSegment(x, y, color)
    local seg = Instance.new("Frame")
    seg.Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)
    seg.Position = posToUDim2(x, y)
    seg.BackgroundColor3 = color
    seg.BorderSizePixel = 0
    seg.Parent = gameField
    return seg
end

local function updateSnakeVisuals()
    for _, f in ipairs(snakeFrames) do
        f:Destroy()
    end
    snakeFrames = {}
    for i, seg in ipairs(snake) do
        local color = (i == 1) and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(0, 150, 0)
        table.insert(snakeFrames, createSegment(seg.x, seg.y, color))
    end
end

local function createFoodAt(x, y)
    if foodFrame then foodFrame:Destroy() end
    foodFrame = Instance.new("Frame")
    foodFrame.Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)
    foodFrame.Position = posToUDim2(x, y)
    foodFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    foodFrame.BorderSizePixel = 0
    foodFrame.Parent = gameField
end

local function spawnRandomFood()
    local free = {}
    local occupied = {}
    for _, seg in ipairs(snake) do
        occupied[seg.x .. "," .. seg.y] = true
    end
    for x = 1, GRID_SIZE do
        for y = 1, GRID_SIZE do
            if not occupied[x..","..y] then
                table.insert(free, {x = x, y = y})
            end
        end
    end
    if #free == 0 then
        gameRunning = false
        local winMsg = Instance.new("TextLabel")
        winMsg.Size = UDim2.new(0, 200, 0, 50)
        winMsg.Position = UDim2.new(0.5, -100, 0.5, -25)
        winMsg.BackgroundColor3 = Color3.fromRGB(0,0,0)
        winMsg.BackgroundTransparency = 0.5
        winMsg.Text = "YOU WIN! Score: " .. score
        winMsg.TextColor3 = Color3.fromRGB(255,255,0)
        winMsg.Font = Enum.Font.GothamBold
        winMsg.TextSize = 18
        winMsg.Parent = mainFrame
        task.delay(3, function() winMsg:Destroy() end)
        return false
    end
    local rand = free[math.random(1, #free)]
    foodPos = {x = rand.x, y = rand.y}
    createFoodAt(rand.x, rand.y)
    return true
end

local function checkCollision(headX, headY)
    if headX < 1 or headX > GRID_SIZE or headY < 1 or headY > GRID_SIZE then
        return true
    end
    for i, seg in ipairs(snake) do
        if seg.x == headX and seg.y == headY then
            return true
        end
    end
    return false
end

local function stepGame()
    if not gameRunning then return end
    direction = nextDirection
    local newHead = {x = snake[1].x, y = snake[1].y}
    if direction == "right" then newHead.x = newHead.x + 1
    elseif direction == "left" then newHead.x = newHead.x - 1
    elseif direction == "up" then newHead.y = newHead.y - 1
    elseif direction == "down" then newHead.y = newHead.y + 1
    end

    local ate = (foodPos and newHead.x == foodPos.x and newHead.y == foodPos.y)

    if checkCollision(newHead.x, newHead.y) then
        gameRunning = false
        local loseMsg = Instance.new("TextLabel")
        loseMsg.Size = UDim2.new(0, 200, 0, 50)
        loseMsg.Position = UDim2.new(0.5, -100, 0.5, -25)
        loseMsg.BackgroundColor3 = Color3.fromRGB(0,0,0)
        loseMsg.BackgroundTransparency = 0.5
        loseMsg.Text = "GAME OVER! Score: " .. score
        loseMsg.TextColor3 = Color3.fromRGB(255,100,100)
        loseMsg.Font = Enum.Font.GothamBold
        loseMsg.TextSize = 18
        loseMsg.Parent = mainFrame
        task.delay(3, function() loseMsg:Destroy() end)
        return
    end

    table.insert(snake, 1, newHead)
    if not ate then
        table.remove(snake)
    else
        score = score + 1
        scoreLabel.Text = "Score: " .. score
        if not spawnRandomFood() then return end
        if foodFrame then
            local oldColor = foodFrame.BackgroundColor3
            foodFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
            task.wait(0.05)
            if foodFrame then foodFrame.BackgroundColor3 = oldColor end
        end
    end
    updateSnakeVisuals()
end

local function resetGame()
    gameRunning = false
    for _, f in ipairs(snakeFrames) do
        f:Destroy()
    end
    snakeFrames = {}
    if foodFrame then foodFrame:Destroy() end
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child:IsA("TextLabel") and child ~= title and child ~= scoreLabel and child ~= keybindLabel then
            child:Destroy()
        end
    end
    snake = {
        {x = math.floor(GRID_SIZE/2), y = math.floor(GRID_SIZE/2)},
        {x = math.floor(GRID_SIZE/2)-1, y = math.floor(GRID_SIZE/2)},
        {x = math.floor(GRID_SIZE/2)-2, y = math.floor(GRID_SIZE/2)}
    }
    direction = "right"
    nextDirection = "right"
    score = 0
    scoreLabel.Text = "Score: 0"
    gameRunning = true
    updateSnakeVisuals()
    spawnRandomFood()
end

-- --- Управление змейкой (ContextActionService) ---
local function handleSnakeAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin then return end
    local key = inputObject.KeyCode
    if key == Enum.KeyCode.Left and direction ~= "right" then
        nextDirection = "left"
    elseif key == Enum.KeyCode.Right and direction ~= "left" then
        nextDirection = "right"
    elseif key == Enum.KeyCode.Up and direction ~= "down" then
        nextDirection = "up"
    elseif key == Enum.KeyCode.Down and direction ~= "up" then
        nextDirection = "down"
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("SnakeMove", handleSnakeAction, false,
    Enum.KeyCode.Left,
    Enum.KeyCode.Right,
    Enum.KeyCode.Up,
    Enum.KeyCode.Down
)

-- --- Управление видимостью GUI через кастомный Keybind ---
local function toggleMenu()
    gui.Enabled = not gui.Enabled
end

-- Функция для обновления бинда (при смене клавиши)
local menuBindConnection = nil
local function rebindMenuKey()
    if menuBindConnection then
        ContextActionService:UnbindAction("MenuToggle")
        menuBindConnection = nil
    end
    -- Привязываем новую клавишу через ContextActionService (чтобы не конфликтовать)
    local keyEnum = Enum.KeyCode[menuKeybind]
    if keyEnum then
        local function menuAction(actionName, inputState, inputObject)
            if inputState == Enum.UserInputState.Begin then
                toggleMenu()
            end
            return Enum.ContextActionResult.Sink
        end
        ContextActionService:BindAction("MenuToggle", menuAction, false, keyEnum)
    else
        -- fallback на UserInputService, если Enum не найден
        if menuBindConnection then menuBindConnection:Disconnect() end
        menuBindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if keyName == menuKeybind then
                toggleMenu()
            end
        end)
    end
end

-- Смена Keybind через кнопку
local waitingForKey = false
keybindBtn.MouseButton1Click:Connect(function()
    if waitingForKey then return end
    waitingForKey = true
    local tempLabel = Instance.new("TextLabel")
    tempLabel.Size = UDim2.new(0, 200, 0, 30)
    tempLabel.Position = UDim2.new(0.5, -100, 0.5, -80)
    tempLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    tempLabel.BackgroundTransparency = 0.5
    tempLabel.Text = "Press any key..."
    tempLabel.TextColor3 = Color3.fromRGB(255,255,255)
    tempLabel.Font = Enum.Font.Gotham
    tempLabel.TextSize = 14
    tempLabel.Parent = mainFrame
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not waitingForKey then return end
        if gameProcessed then return end
        local key = input.KeyCode
        if key ~= Enum.KeyCode.Unknown then
            local keyName = tostring(key):gsub("Enum.KeyCode.", "")
            menuKeybind = keyName
            keybindLabel.Text = "Menu key: " .. menuKeybind
            saveConfig()
            rebindMenuKey()
            waitingForKey = false
            tempLabel:Destroy()
            connection:Disconnect()
            local confirm = Instance.new("TextLabel")
            confirm.Size = UDim2.new(0, 200, 0, 30)
            confirm.Position = UDim2.new(0.5, -100, 0.5, -80)
            confirm.BackgroundColor3 = Color3.fromRGB(0,0,0)
            confirm.BackgroundTransparency = 0.5
            confirm.Text = "Keybind set to " .. keyName
            confirm.TextColor3 = Color3.fromRGB(100,255,100)
            confirm.Font = Enum.Font.Gotham
            confirm.TextSize = 14
            confirm.Parent = mainFrame
            task.delay(2, function() confirm:Destroy() end)
        end
    end)
end)

-- Кнопка рестарта
restartBtn.MouseButton1Click:Connect(function()
    resetGame()
end)

-- Игровой цикл
local lastTime = os.clock()
RunService.RenderStepped:Connect(function()
    if not gameRunning then return end
    local now = os.clock()
    if now - lastTime >= stepTime then
        stepGame()
        lastTime = now
    end
end)

-- Запуск игры
resetGame()
rebindMenuKey()
gui.Enabled = true
