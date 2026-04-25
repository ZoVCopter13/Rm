-- Snake Game v6.0 (плавное движение, регулировка скорости, keybind R для рестарта)
-- Открыть/закрыть окно: K. Перезапуск: R или кнопка Restart. Скорость регулируется кнопками +/-.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer

-- Конфигурация
local GRID_SIZE = 20
local CELL_SIZE = 25
local FIELD_WIDTH = GRID_SIZE * CELL_SIZE
local FIELD_HEIGHT = GRID_SIZE * CELL_SIZE
local ANIMATION_DURATION = 0.05        -- длительность анимации перемещения (сек)

-- Скорость (интервал шага)
local speedLevel = 5                   -- от 1 до 10
local function getStepInterval()
    -- скорость 1 -> 0.2 сек, скорость 10 -> 0.05 сек
    return 0.05 + (0.15 * (11 - speedLevel) / 10)
end
local STEP_INTERVAL = getStepInterval()

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SnakeGame"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, FIELD_WIDTH + 100, 0, FIELD_HEIGHT + 130) -- немного больше для панели скорости
mainFrame.Position = UDim2.new(0.5, -(FIELD_WIDTH+100)/2, 0.5, -(FIELD_HEIGHT+130)/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.Text = "Snake Game (arrows, K hide, R restart)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local gameField = Instance.new("Frame")
gameField.Size = UDim2.new(0, FIELD_WIDTH, 0, FIELD_HEIGHT)
gameField.Position = UDim2.new(0.5, -FIELD_WIDTH/2, 0.5, -FIELD_HEIGHT/2 + 15)
gameField.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
gameField.BorderSizePixel = 1
gameField.BorderColor3 = Color3.fromRGB(100, 100, 100)
gameField.Parent = mainFrame

scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(1, 0, 0, 30)
scoreLabel.Position = UDim2.new(0, 0, 1, -60)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "Score: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scoreLabel.Font = Enum.Font.Gotham
scoreLabel.TextSize = 16
scoreLabel.Parent = mainFrame

-- Панель скорости
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 150, 0, 25)
speedFrame.Position = UDim2.new(0, 10, 1, -35)
speedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 60, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 5"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Parent = speedFrame

local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0, 25, 1, 0)
speedMinus.Position = UDim2.new(0, 65, 0, 0)
speedMinus.Text = "-"
speedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
speedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedMinus.Parent = speedFrame

local speedPlus = Instance.new("TextButton")
speedPlus.Size = UDim2.new(0, 25, 1, 0)
speedPlus.Position = UDim2.new(0, 95, 0, 0)
speedPlus.Text = "+"
speedPlus.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
speedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedPlus.Parent = speedFrame

-- Кнопка рестарта
local restartBtn = Instance.new("TextButton")
restartBtn.Size = UDim2.new(0, 80, 0, 25)
restartBtn.Position = UDim2.new(1, -85, 1, -35)
restartBtn.Text = "Restart"
restartBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
restartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restartBtn.Parent = mainFrame

-- Данные игры
local snake = {}
local snakeFrames = {}
local foodPos = nil
local foodFrame = nil
local direction = "right"
local nextDirection = "right"
local gameRunning = false
local score = 0
local gameLoopTask = nil
local activeTweens = {}
local lastTime = 0

-- Функция обновления скорости
local function updateSpeedDisplay()
    speedLabel.Text = "Speed: " .. speedLevel
    STEP_INTERVAL = getStepInterval()
end

local function changeSpeed(delta)
    local newSpeed = speedLevel + delta
    if newSpeed >= 1 and newSpeed <= 10 then
        speedLevel = newSpeed
        updateSpeedDisplay()
        -- перезапускать цикл не нужно, новый интервал подхватится в следующем шаге
    end
end

-- Вспомогательные функции
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

local function setPositionsInstant()
    for i, seg in ipairs(snake) do
        if snakeFrames[i] then
            snakeFrames[i].Position = posToUDim2(seg.x, seg.y)
        end
    end
end

local function animateSnakeMove(oldSnake, newSnake)
    for _, t in ipairs(activeTweens) do
        if t and t.PlaybackState ~= Enum.PlaybackState.Completed then
            t:Cancel()
        end
    end
    activeTweens = {}
    for i, newSeg in ipairs(newSnake) do
        local oldSeg = oldSnake[i]
        if oldSeg and (oldSeg.x ~= newSeg.x or oldSeg.y ~= newSeg.y) then
            local frame = snakeFrames[i]
            if frame then
                local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Linear), {Position = posToUDim2(newSeg.x, newSeg.y)})
                tween:Play()
                table.insert(activeTweens, tween)
            end
        end
    end
end

local function rebuildVisuals()
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

    local oldSnake = {}
    for i, seg in ipairs(snake) do
        oldSnake[i] = {x = seg.x, y = seg.y}
    end

    -- Добавляем новую голову
    table.insert(snake, 1, newHead)
    if not ate then
        -- удаляем хвост
        table.remove(snake)
    else
        -- увеличиваем счёт, не удаляем хвост
        score = score + 1
        scoreLabel.Text = "Score: " .. score
        if not spawnRandomFood() then return end
        -- эффект еды
        if foodFrame then
            local oldColor = foodFrame.BackgroundColor3
            foodFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
            task.wait(0.03)
            if foodFrame then foodFrame.BackgroundColor3 = oldColor end
        end
        -- При удлинении нужно добавить новый фрейм в конец (за хвостом) без пересоздания всех
        -- Сначала определяем позицию нового хвоста (старый последний сегмент)
        local lastSeg = snake[#snake]
        local newTailPos = {x = lastSeg.x, y = lastSeg.y}
        -- Добавляем новый фрейм в конец snakeFrames
        local newFrame = createSegment(newTailPos.x, newTailPos.y, Color3.fromRGB(0, 150, 0))
        table.insert(snakeFrames, newFrame)
        -- Обновляем массив snake уже содержит новый хвост (этот же lastSeg, но для ясности)
        -- Визуально новый сегмент появится на месте старого хвоста (так как хвост не удалялся, а мы добавили ещё один сегмент в конец)
        -- Но после роста змейка удлиняется на 1, и новый сегмент должен быть на месте предыдущего хвоста.
        -- Однако в логике после вставки головы и без удаления хвоста, snake уже имеет новый сегмент в конце (старый хвост остался, добавлен новый).
        -- Нам нужно просто добавить фрейм в snakeFrames, и его позиция уже соответствует последнему сегменту (который мы только что добавили).
        -- Так как мы не пересоздаём все фреймы, анимация головы и других сегментов не прерывается.
        -- Но чтобы новый сегмент появился именно в конце, его позиция должна быть равна позиции последнего сегмента в snake.
        -- У нас lastSeg — это как раз последний сегмент (старый хвост, который теперь не хвост, а предпоследний?).
        -- В общем, проще просто пересоздать визуалы, но это вызовет рывок. Поэтому оставим как есть.
        -- Альтернатива: не пересоздавать, а добавлять новый фрейм в конец и анимировать его появление.
        newFrame.Position = posToUDim2(lastSeg.x, lastSeg.y)
        -- Можно сделать анимацию появления (например, масштабирование), но для простоты оставим мгновенное появление.
    end

    -- Если количество фреймов не совпадает (из-за роста), то мы уже добавили один фрейм вручную. Проверка:
    if #snake ~= #snakeFrames and ate then
        -- Этого не должно случиться, так как мы добавили фрейм. На всякий случай синхронизируем.
        while #snakeFrames < #snake do
            local lastSeg = snake[#snakeFrames+1]
            local newF = createSegment(lastSeg.x, lastSeg.y, Color3.fromRGB(0, 150, 0))
            table.insert(snakeFrames, newF)
        end
    elseif #snake ~= #snakeFrames and not ate then
        -- При удалении хвоста (не рост) нужно удалить последний фрейм
        if #snakeFrames > #snake then
            local extra = table.remove(snakeFrames)
            extra:Destroy()
        end
    end

    -- Анимируем перемещение для всех сегментов (кроме нового, который и так на месте)
    animateSnakeMove(oldSnake, snake)
end

-- Сброс игры
local function resetGame()
    gameRunning = false
    for _, t in ipairs(activeTweens) do
        if t and t.PlaybackState ~= Enum.PlaybackState.Completed then
            t:Cancel()
        end
    end
    activeTweens = {}
    for _, f in ipairs(snakeFrames) do
        f:Destroy()
    end
    snakeFrames = {}
    if foodFrame then foodFrame:Destroy() end
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child:IsA("TextLabel") and child ~= title and child ~= scoreLabel and child ~= speedLabel and child.Parent ~= speedFrame then
            child:Destroy()
        end
    end
    local centerX = math.floor(GRID_SIZE/2)
    local centerY = math.floor(GRID_SIZE/2)
    snake = {
        {x = centerX, y = centerY},
        {x = centerX-1, y = centerY},
        {x = centerX-2, y = centerY}
    }
    direction = "right"
    nextDirection = "right"
    score = 0
    scoreLabel.Text = "Score: 0"
    rebuildVisuals()
    setPositionsInstant()
    spawnRandomFood()
    gameRunning = true
    lastTime = os.clock()
end

-- Управление змейкой
local function handleAction(actionName, inputState, inputObject)
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

ContextActionService:BindAction("SnakeMove", handleAction, false,
    Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Up, Enum.KeyCode.Down
)

-- Keybind для рестарта (R)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        resetGame()
    elseif input.KeyCode == Enum.KeyCode.K then
        gui.Enabled = not gui.Enabled
    end
end)

-- Кнопка рестарта
restartBtn.MouseButton1Click:Connect(function()
    resetGame()
end)

-- Кнопки скорости
speedMinus.MouseButton1Click:Connect(function()
    changeSpeed(-1)
end)
speedPlus.MouseButton1Click:Connect(function()
    changeSpeed(1)
end)

-- Игровой цикл
local function gameLoop()
    lastTime = os.clock()
    while true do
        if gameRunning then
            local now = os.clock()
            if now - lastTime >= STEP_INTERVAL then
                stepGame()
                lastTime = now
            end
        end
        RunService.RenderStepped:Wait()
    end
end
task.spawn(gameLoop)

-- Запуск
resetGame()
gui.Enabled = true
