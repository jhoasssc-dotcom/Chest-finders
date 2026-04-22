--[[ Speed Hub X | Chest Finder v15 --]]

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local autoChest = true
local antiAFK = false
local noclipActive = false
local speedValue = 16
local coletados = 0

local function setSpeed(s)
    speedValue = math.clamp(s, 10, 100)
    hum.WalkSpeed = speedValue
end

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedHubX"
gui.Parent = player:WaitForChild("PlayerGui")

-- Bolinha
local bola = Instance.new("ImageButton")
bola.Size = UDim2.new(0, 50, 0, 50)
bola.Position = UDim2.new(0, 10, 0, 100)
bola.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
bola.BackgroundTransparency = 0.1
bola.Image = "rbxassetid://3926305904"
bola.Parent = gui

local bolaC = Instance.new("UICorner")
bolaC.CornerRadius = UDim.new(1, 0)
bolaC.Parent = bola

local bolaText = Instance.new("TextLabel")
bolaText.Size = UDim2.new(1, 0, 1, 0)
bolaText.BackgroundTransparency = 1
bolaText.Text = "S"
bolaText.TextColor3 = Color3.fromRGB(0, 0, 0)
bolaText.TextSize = 28
bolaText.Font = Enum.Font.GothamBold
bolaText.Parent = bola

-- Menu Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 400)
frame.Position = UDim2.new(0.5, -250, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui

local frameC = Instance.new("UICorner")
frameC.CornerRadius = UDim.new(0, 10)
frameC.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 255, 255)
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Speed Hub X | Chest Finder"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

local closeC = Instance.new("UICorner")
closeC.CornerRadius = UDim.new(0, 5)
closeC.Parent = closeBtn

-- Abas
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 100, 1, 0)
sideBar.Position = UDim2.new(0, 0, 0, 35)
sideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
sideBar.BackgroundTransparency = 0.3
sideBar.Parent = frame

local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(1, -20, 0, 40)
mainBtn.Position = UDim2.new(0, 10, 0, 10)
mainBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
mainBtn.Text = "Main"
mainBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
mainBtn.TextSize = 14
mainBtn.Font = Enum.Font.GothamBold
mainBtn.Parent = sideBar

local mainC = Instance.new("UICorner")
mainC.CornerRadius = UDim.new(0, 8)
mainC.Parent = mainBtn

local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(1, -20, 0, 40)
farmBtn.Position = UDim2.new(0, 10, 0, 60)
farmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
farmBtn.Text = "Auto Farm"
farmBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
farmBtn.TextSize = 14
farmBtn.Font = Enum.Font.GothamBold
farmBtn.Parent = sideBar

local farmC = Instance.new("UICorner")
farmC.CornerRadius = UDim.new(0, 8)
farmC.Parent = farmBtn

-- Área de conteúdo
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -110, 1, -10)
content.Position = UDim2.new(0, 105, 0, 5)
content.BackgroundTransparency = 1
content.Parent = frame

-- ABA MAIN
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = content

-- Speed
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -20, 0, 45)
speedFrame.Position = UDim2.new(0, 10, 0, 10)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedFrame.BackgroundTransparency = 0.3
speedFrame.Parent = mainContent

local speedC = Instance.new("UICorner")
speedC.CornerRadius = UDim.new(0, 6)
speedC.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 60, 1, 0)
speedLabel.Position = UDim2.new(0, 10, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed"
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedValueBtn = Instance.new("TextButton")
speedValueBtn.Size = UDim2.new(0, 45, 0, 30)
speedValueBtn.Position = UDim2.new(1, -55, 0.5, -15)
speedValueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedValueBtn.Text = tostring(speedValue)
speedValueBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
speedValueBtn.TextSize = 12
speedValueBtn.Font = Enum.Font.GothamBold
speedValueBtn.Parent = speedFrame

local speedValueC = Instance.new("UICorner")
speedValueC.CornerRadius = UDim.new(0, 5)
speedValueC.Parent = speedValueBtn

-- Anti AFK
local afkFrame = Instance.new("Frame")
afkFrame.Size = UDim2.new(1, -20, 0, 40)
afkFrame.Position = UDim2.new(0, 10, 0, 65)
afkFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
afkFrame.BackgroundTransparency = 0.3
afkFrame.Parent = mainContent

local afkC = Instance.new("UICorner")
afkC.CornerRadius = UDim.new(0, 6)
afkC.Parent = afkFrame

local afkLabel = Instance.new("TextLabel")
afkLabel.Size = UDim2.new(0, 80, 1, 0)
afkLabel.Position = UDim2.new(0, 10, 0, 0)
afkLabel.BackgroundTransparency = 1
afkLabel.Text = "Anti AFK"
afkLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
afkLabel.TextSize = 13
afkLabel.Font = Enum.Font.GothamBold
afkLabel.TextXAlignment = Enum.TextXAlignment.Left
afkLabel.Parent = afkFrame

local afkToggle = Instance.new("TextButton")
afkToggle.Size = UDim2.new(0, 60, 0, 30)
afkToggle.Position = UDim2.new(1, -70, 0, 5)
afkToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
afkToggle.Text = "OFF"
afkToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
afkToggle.TextSize = 12
afkToggle.Font = Enum.Font.GothamBold
afkToggle.Parent = afkFrame

local afkToggleC = Instance.new("UICorner")
afkToggleC.CornerRadius = UDim.new(0, 5)
afkToggleC.Parent = afkToggle

-- Noclip
local noclipFrame = Instance.new("Frame")
noclipFrame.Size = UDim2.new(1, -20, 0, 40)
noclipFrame.Position = UDim2.new(0, 10, 0, 115)
noclipFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
noclipFrame.BackgroundTransparency = 0.3
noclipFrame.Parent = mainContent

local noclipC = Instance.new("UICorner")
noclipC.CornerRadius = UDim.new(0, 6)
noclipC.Parent = noclipFrame

local noclipLabel = Instance.new("TextLabel")
noclipLabel.Size = UDim2.new(0, 80, 1, 0)
noclipLabel.Position = UDim2.new(0, 10, 0, 0)
noclipLabel.BackgroundTransparency = 1
noclipLabel.Text = "Noclip"
noclipLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
noclipLabel.TextSize = 13
noclipLabel.Font = Enum.Font.GothamBold
noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
noclipLabel.Parent = noclipFrame

local noclipToggle = Instance.new("TextButton")
noclipToggle.Size = UDim2.new(0, 60, 0, 30)
noclipToggle.Position = UDim2.new(1, -70, 0, 5)
noclipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
noclipToggle.Text = "OFF"
noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
noclipToggle.TextSize = 12
noclipToggle.Font = Enum.Font.GothamBold
noclipToggle.Parent = noclipFrame

local noclipToggleC = Instance.new("UICorner")
noclipToggleC.CornerRadius = UDim.new(0, 5)
noclipToggleC.Parent = noclipToggle

-- ABA AUTO FARM
local farmContent = Instance.new("Frame")
farmContent.Size = UDim2.new(1, 0, 1, 0)
farmContent.BackgroundTransparency = 1
farmContent.Visible = false
farmContent.Parent = content

-- Auto Chest
local chestFrame = Instance.new("Frame")
chestFrame.Size = UDim2.new(1, -20, 0, 40)
chestFrame.Position = UDim2.new(0, 10, 0, 10)
chestFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
chestFrame.BackgroundTransparency = 0.3
chestFrame.Parent = farmContent

local chestC = Instance.new("UICorner")
chestC.CornerRadius = UDim.new(0, 6)
chestC.Parent = chestFrame

local chestLabel = Instance.new("TextLabel")
chestLabel.Size = UDim2.new(0, 120, 1, 0)
chestLabel.Position = UDim2.new(0, 10, 0, 0)
chestLabel.BackgroundTransparency = 1
chestLabel.Text = "Auto Chest Finder"
chestLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
chestLabel.TextSize = 13
chestLabel.Font = Enum.Font.GothamBold
chestLabel.TextXAlignment = Enum.TextXAlignment.Left
chestLabel.Parent = chestFrame

local chestToggle = Instance.new("TextButton")
chestToggle.Size = UDim2.new(0, 60, 0, 30)
chestToggle.Position = UDim2.new(1, -70, 0, 5)
chestToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
chestToggle.Text = "ON"
chestToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
chestToggle.TextSize = 12
chestToggle.Font = Enum.Font.GothamBold
chestToggle.Parent = chestFrame

local chestToggleC = Instance.new("UICorner")
chestToggleC.CornerRadius = UDim.new(0, 5)
chestToggleC.Parent = chestToggle

-- Contador
local countFrame = Instance.new("Frame")
countFrame.Size = UDim2.new(1, -20, 0, 40)
countFrame.Position = UDim2.new(0, 10, 0, 60)
countFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
countFrame.BackgroundTransparency = 0.3
countFrame.Parent = farmContent

local countC = Instance.new("UICorner")
countC.CornerRadius = UDim.new(0, 6)
countC.Parent = countFrame

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -10, 1, 0)
countLabel.Position = UDim2.new(0, 10, 0, 0)
countLabel.BackgroundTransparency = 1
countLabel.Text = "📊 Baús coletados: 0"
countLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
countLabel.TextSize = 13
countLabel.Font = Enum.Font.GothamBold
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = countFrame

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 40)
statusFrame.Position = UDim2.new(0, 10, 0, 110)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusFrame.BackgroundTransparency = 0.3
statusFrame.Parent = farmContent

local statusC = Instance.new("UICorner")
statusC.CornerRadius = UDim.new(0, 6)
statusC.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "✅ Auto Chest ATIVADO!"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = statusFrame

-- Funções
speedValueBtn.MouseButton1Click:Connect(function()
    local edit = Instance.new("TextBox")
    edit.Size = UDim2.new(1, 0, 1, 0)
    edit.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    edit.Text = speedValueBtn.Text
    edit.TextColor3 = Color3.fromRGB(0, 255, 255)
    edit.TextSize = 12
    edit.Font = Enum.Font.GothamBold
    edit.TextXAlignment = Enum.TextXAlignment.Center
    edit.Parent = speedValueBtn
    edit.FocusLost:Connect(function()
        local n = tonumber(edit.Text)
        if n then setSpeed(n) end
        speedValueBtn.Text = tostring(math.floor(speedValue))
        edit:Destroy()
    end)
end)

-- Anti AFK
local afkLoop = nil
afkToggle.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    if antiAFK then
        afkToggle.Text = "ON"
        afkToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        afkToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        afkLoop = task.spawn(function()
            while antiAFK do
                task.wait(240)
                local mouse = player:GetMouse()
                if mouse then
                    local x = mouse.X
                    mouse.Move(x + 1, mouse.Y)
                    task.wait(0.1)
                    mouse.Move(x, mouse.Y)
                end
                if hum then
                    hum:MoveTo(char:GetPivot().Position + Vector3.new(1, 0, 0))
                    task.wait(0.2)
                    hum:MoveTo(char:GetPivot().Position)
                end
            end
        end)
    else
        afkToggle.Text = "OFF"
        afkToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        afkToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        if afkLoop then task.cancel(afkLoop) end
    end
end)

-- Noclip
local noclipConn = nil
noclipToggle.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    if noclipActive then
        noclipToggle.Text = "ON"
        noclipToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        noclipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        noclipConn = RunService.Stepped:Connect(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CanCollide = false
            end
        end)
    else
        noclipToggle.Text = "OFF"
        noclipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        if noclipConn then noclipConn:Disconnect() end
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CanCollide = true
        end
    end
end)

-- Funções do Auto Chest
local proibidas = {"free", "gift", "presente", "fuse", "shop", "yellow", "gold", "group"}
local function isChestPermitido(obj)
    local nome = string.lower(obj.Name or "")
    if not (string.find(nome, "chest") or string.find(nome, "bau")) then return false end
    for _, p in ipairs(proibidas) do if string.find(nome, p) then return false end end
    return true
end

local function getTipo(nome)
    local n = string.lower(nome)
    if string.find(n, "rainbow") then return "🌈 Arco-Íris", 5, "🌈"
    elseif string.find(n, "legendary") then return "🏆 Lendário", 4, "🏆"
    elseif string.find(n, "rare") then return "💎 Raro", 3, "💎"
    else return "📦 Comum", 1, "📦" end
end

local function acharChests()
    local encontrados = {}
    local posChar = char:GetPivot().Position
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isChestPermitido(obj) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
            if pos then
                local tipo, prio, emj = getTipo(obj.Name)
                local dist = (posChar - pos).Magnitude
                if dist < 500 then
                    table.insert(encontrados, {obj = obj, pos = pos, dist = dist, tipo = tipo, prio = prio, emj = emj})
                end
            end
        end
    end
    table.sort(encontrados, function(a, b)
        if a.prio ~= b.prio then return a.prio > b.prio end
        return a.dist < b.dist
    end)
    return encontrados
end

local function mover(chest)
    if not chest or not hum then return end
    statusLabel.Text = chest.emj .. " " .. chest.tipo .. " (" .. math.floor(chest.dist) .. "m)"
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(function() path:ComputeAsync(char:GetPivot().Position, chest.pos) end)
    if ok and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if not autoChest then break end
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(1)
        end
        if chest.obj and chest.obj.Parent then
            coletados = coletados + 1
            countLabel.Text = "📊 Baús coletados: " .. coletados
            statusLabel.Text = "✅ " .. chest.tipo .. " coletado!"
            local click = chest.obj:FindFirstChild("ClickDetector")
            if click then click:Click() end
        end
    else
        statusLabel.Text = "⚠️ Caminho bloqueado!"
    end
end

local farmLoop = nil
local function iniciarFarm()
    if farmLoop then task.cancel(farmLoop) end
    farmLoop = task.spawn(function()
        while autoChest do
            if hum and hum.Health > 0 then
                local chests = acharChests()
                if #chests > 0 then mover(chests[1]) else statusLabel.Text = "🔍 Nenhum baú..." end
            end
            task.wait(1)
        end
    end)
end

chestToggle.MouseButton1Click:Connect(function()
    autoChest = not autoChest
    if autoChest then
        chestToggle.Text = "ON"
        chestToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        iniciarFarm()
        statusLabel.Text = "✅ Auto Chest ATIVADO!"
    else
        chestToggle.Text = "OFF"
        chestToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        if farmLoop then task.cancel(farmLoop) end
        statusLabel.Text = "❌ Auto Chest DESATIVADO"
    end
end)

-- Navegação
mainBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = true
    farmContent.Visible = false
    mainBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    mainBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    farmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    farmBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

farmBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = false
    farmContent.Visible = true
    farmBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    farmBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    mainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- Arrastar
local dragging = false
local dragStart, frameStart

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Arrastar bolinha
local ballDrag = false
local ballStart, ballPosStart

bola.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ballDrag = true
        ballStart = input.Position
        ballPosStart = bola.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if ballDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - ballStart
        bola.Position = UDim2.new(ballPosStart.X.Scale, ballPosStart.X.Offset + delta.X, ballPosStart.Y.Scale, ballPosStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then ballDrag = false end
end)

bola.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Iniciar
setSpeed(16)
iniciarFarm()

print("✅ Speed Hub X | Chest Finder carregado!")
print("📌 Clique na bolinha 'S' para abrir o menu")
