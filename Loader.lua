--[[ Chest Finder v13.0 - Corrigido e Funcional --]]

local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Aguarda o personagem carregar
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

local auto = true
local coletados = 0
local velocidade = 50

-- Função para definir velocidade
local function setSpeed(s)
    velocidade = math.clamp(s, 10, 100)
    hum.WalkSpeed = velocidade
    if speedValueBtn then speedValueBtn.Text = tostring(math.floor(velocidade)) end
    if sliderFill then
        local p = (velocidade - 10) / 90
        sliderFill.Size = UDim2.new(p, 0, 1, 0)
        sliderBtn.Position = UDim2.new(p, -6, 0.5, -6)
    end
end

-- Verifica contorno (Highlight/SelectionBox)
local function temContorno(obj)
    if obj:FindFirstChildWhichIsA("Highlight") then return true end
    if obj:FindFirstChildWhichIsA("SelectionBox") then return true end
    if obj:IsA("Model") then
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                if part:FindFirstChildWhichIsA("Highlight") or part:FindFirstChildWhichIsA("SelectionBox") then
                    return true
                end
            end
        end
    end
    return false
end

-- Palavras proibidas
local proibidas = {
    "presente", "gratuito", "free", "gift", "reward", "recompensa", "brinde",
    "shop", "loja", "store", "buy", "comprar", "roblox", "robux", "premium", "vip",
    "starter", "iniciante", "pack", "pacote", "daily", "weekly", "bonus"
}

local function isRuim(obj)
    local current = obj
    for i = 1, 5 do
        if not current then break end
        local nome = string.lower(current.Name or "")
        for _, p in ipairs(proibidas) do
            if string.find(nome, p) then return true end
        end
        if current:FindFirstChild("Price") or current:FindFirstChild("RobuxPrice") or current:FindFirstChild("Cost") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isPermitido(obj)
    local nome = string.lower(obj.Name or "")
    if not (string.find(nome, "chest") or string.find(nome, "bau")) then return false end
    return temContorno(obj) and not isRuim(obj)
end

local function getTipo(nome)
    local n = string.lower(nome)
    if string.find(n, "rainbow") or string.find(n, "arco") then return "🌈 Arco-Íris", 5, "🌈" end
    if string.find(n, "legendary") or string.find(n, "lendario") then return "🏆 Lendário", 4, "🏆" end
    if string.find(n, "rare") or string.find(n, "raro") then return "💎 Raro", 3, "💎" end
    return "📦 Comum", 1, "📦"
end

local function acharChests()
    local lista = {}
    local posChar = rootPart.Position
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isPermitido(obj) then
            local pos = obj:IsA("Model") and obj:GetPivot().Position or (obj:IsA("BasePart") and obj.Position)
            if pos then
                local tipo, prio, emoji = getTipo(obj.Name)
                local dist = (posChar - pos).Magnitude
                if dist < 500 then
                    table.insert(lista, {obj = obj, pos = pos, dist = dist, tipo = tipo, prio = prio, emoji = emoji})
                end
            end
        end
    end
    table.sort(lista, function(a, b)
        if a.prio ~= b.prio then return a.prio > b.prio end
        return a.dist < b.dist
    end)
    return lista
end

-- Deleta baús ruins
local function deletarRuins()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local nome = string.lower(obj.Name or "")
        if (string.find(nome, "chest") or string.find(nome, "bau") or obj:FindFirstChild("ClickDetector")) then
            if not temContorno(obj) and isRuim(obj) then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- Pulo
local function pular()
    if hum and rootPart then
        hum.Jump = true
        task.wait(0.1)
        hum.Jump = false
    end
end

-- ========== CRIAR GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ChestFinder"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Frame principal (horizontal)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 160)
frame.Position = UDim2.new(0.5, -250, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
frame.Parent = gui

-- Barra de título
local barra = Instance.new("Frame")
barra.Size = UDim2.new(1, 0, 0, 30)
barra.BackgroundTransparency = 1
barra.Parent = frame

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -100, 0, 30)
titulo.Position = UDim2.new(0, 5, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "🎁 Chest Finder v13"
titulo.TextColor3 = Color3.fromRGB(0, 255, 255)
titulo.TextSize = 12
titulo.Font = Enum.Font.GothamBold
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = barra

-- Botões de aba
local abaMainBtn = Instance.new("TextButton")
abaMainBtn.Size = UDim2.new(0, 50, 0, 24)
abaMainBtn.Position = UDim2.new(0.5, -60, 0, 3)
abaMainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
abaMainBtn.Text = "Main"
abaMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
abaMainBtn.TextSize = 10
abaMainBtn.Font = Enum.Font.GothamBold
abaMainBtn.Parent = barra

local abaAutoBtn = Instance.new("TextButton")
abaAutoBtn.Size = UDim2.new(0, 100, 0, 24)
abaAutoBtn.Position = UDim2.new(0.5, -5, 0, 3)
abaAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
abaAutoBtn.Text = "Auto Buy"
abaAutoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
abaAutoBtn.TextSize = 10
abaAutoBtn.Font = Enum.Font.GothamBold
abaAutoBtn.Parent = barra

-- Botão minimizar
local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 25, 0, 25)
mini.Position = UDim2.new(1, -30, 0, 3)
mini.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mini.Text = "⬤"
mini.TextColor3 = Color3.fromRGB(0, 255, 255)
mini.TextSize = 14
mini.Font = Enum.Font.GothamBold
mini.Parent = barra

-- Botão fechar
local fechar = Instance.new("TextButton")
fechar.Size = UDim2.new(0, 25, 0, 25)
fechar.Position = UDim2.new(1, -58, 0, 3)
fechar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
fechar.Text = "✕"
fechar.TextColor3 = Color3.fromRGB(255, 100, 100)
fechar.TextSize = 14
fechar.Font = Enum.Font.GothamBold
fechar.Parent = barra

-- Botão Auto Chest
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 230, 0, 35)
autoBtn.Position = UDim2.new(0, 10, 0, 40)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
autoBtn.Text = "🔍 Auto Chest: ON"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Font = Enum.Font.GothamSemibold
autoBtn.Parent = frame

-- Botão Anti-AFK
local afkBtn = Instance.new("TextButton")
afkBtn.Size = UDim2.new(0, 230, 0, 35)
afkBtn.Position = UDim2.new(1, -240, 0, 40)
afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
afkBtn.Text = "💤 Anti-AFK: OFF"
afkBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
afkBtn.TextSize = 12
afkBtn.Font = Enum.Font.GothamSemibold
afkBtn.Parent = frame

-- Frame da velocidade
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 350, 0, 40)
speedFrame.Position = UDim2.new(0, 10, 0, 85)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedFrame.BackgroundTransparency = 0.3
speedFrame.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 40, 1, 0)
speedLabel.Position = UDim2.new(0, 5, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡"
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = speedFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 180, 0, 5)
sliderBg.Position = UDim2.new(0, 50, 0.5, -2.5)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((velocidade - 10) / 90, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 12, 0, 12)
sliderBtn.Position = UDim2.new((velocidade - 10) / 90, -6, 0.5, -6)
sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
sliderBtn.Text = ""
sliderBtn.BorderSizePixel = 0
sliderBtn.Parent = sliderBg

local speedValueBtn = Instance.new("TextButton")
speedValueBtn.Size = UDim2.new(0, 50, 0, 30)
speedValueBtn.Position = UDim2.new(1, -55, 0.5, -15)
speedValueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedValueBtn.Text = tostring(velocidade)
speedValueBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
speedValueBtn.TextSize = 12
speedValueBtn.Font = Enum.Font.GothamBold
speedValueBtn.Parent = speedFrame

-- Botão Reset
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 80, 0, 30)
resetBtn.Position = UDim2.new(0, 370, 0, 90)
resetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resetBtn.Text = "↺ Reset"
resetBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
resetBtn.TextSize = 10
resetBtn.Font = Enum.Font.Gotham
resetBtn.Parent = frame

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 480, 0, 30)
statusFrame.Position = UDim2.new(0.5, -240, 0, 128)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusFrame.BackgroundTransparency = 0.3
statusFrame.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 1, -5)
statusText.Position = UDim2.new(0, 5, 0, 2)
statusText.BackgroundTransparency = 1
statusText.Text = "✅ Auto Chest ATIVADO!"
statusText.TextColor3 = Color3.fromRGB(0, 255, 100)
statusText.TextSize = 10
statusText.Font = Enum.Font.Gotham
statusText.Parent = statusFrame

-- ABA AUTO BUY
local autoBuyFrame = Instance.new("Frame")
autoBuyFrame.Size = UDim2.new(0, 480, 0, 100)
autoBuyFrame.Position = UDim2.new(0.5, -240, 0, 45)
autoBuyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
autoBuyFrame.BackgroundTransparency = 0.3
autoBuyFrame.Visible = false
autoBuyFrame.Parent = frame

local autoBuyText = Instance.new("TextLabel")
autoBuyText.Size = UDim2.new(1, -20, 1, -20)
autoBuyText.Position = UDim2.new(0, 10, 0, 10)
autoBuyText.BackgroundTransparency = 1
autoBuyText.Text = "🛒 Auto Buy / Collect\n\n⚙️ Funções disponíveis na versão 14.0"
autoBuyText.TextColor3 = Color3.fromRGB(180, 180, 200)
autoBuyText.TextSize = 11
autoBuyText.TextWrapped = true
autoBuyText.Font = Enum.Font.Gotham
autoBuyText.Parent = autoBuyFrame

-- Bolinha minimizada
local bola = Instance.new("ImageButton")
bola.Size = UDim2.new(0, 45, 0, 45)
bola.Position = UDim2.new(0, 10, 0, 100)
bola.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bola.Image = "rbxassetid://6031094839"
bola.ImageColor3 = Color3.fromRGB(200, 200, 200)
bola.Visible = false
bola.Parent = gui

-- ========== FUNÇÕES DA UI ==========
local function trocarAba(aba)
    if aba == "Main" then
        autoBtn.Visible = true
        afkBtn.Visible = true
        speedFrame.Visible = true
        resetBtn.Visible = true
        statusFrame.Visible = true
        autoBuyFrame.Visible = false
        abaMainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
        abaAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    else
        autoBtn.Visible = false
        afkBtn.Visible = false
        speedFrame.Visible = false
        resetBtn.Visible = false
        statusFrame.Visible = false
        autoBuyFrame.Visible = true
        abaMainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        abaAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
    end
end

-- Arrastar
local dragging = false
local dragStart, frameStart

barra.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

UserInput.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Arrastar bolinha
local bolaDragging = false
local bolaDragStart, bolaStart

bola.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bolaDragging = true
        bolaDragStart = input.Position
        bolaStart = bola.Position
    end
end)

UserInput.InputChanged:Connect(function(input)
    if bolaDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - bolaDragStart
        bola.Position = UDim2.new(bolaStart.X.Scale, bolaStart.X.Offset + delta.X, bolaStart.Y.Scale, bolaStart.Y.Offset + delta.Y)
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then bolaDragging = false end
end)

-- Slider
local sliderDrag = false
sliderBtn.MouseButton1Down:Connect(function() sliderDrag = true end)

UserInput.InputChanged:Connect(function(input)
    if sliderDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = input.Position.X - sliderBg.AbsolutePosition.X
        local p = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
        setSpeed(10 + (p * 90))
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliderDrag = false end
end)

-- Editar velocidade
speedValueBtn.MouseButton1Click:Connect(function()
    local edit = Instance.new("TextBox")
    edit.Size = UDim2.new(1, 0, 1, 0)
    edit.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    edit.Text = tostring(velocidade)
    edit.TextColor3 = Color3.fromRGB(0, 255, 255)
    edit.TextSize = 12
    edit.Font = Enum.Font.GothamBold
    edit.Parent = speedValueBtn
    edit.FocusLost:Connect(function()
        local n = tonumber(edit.Text)
        if n then setSpeed(n) end
        edit:Destroy()
    end)
end)

-- Eventos dos botões
abaMainBtn.MouseButton1Click:Connect(function() trocarAba("Main") end)
abaAutoBtn.MouseButton1Click:Connect(function() trocarAba("AutoBuy") end)

mini.MouseButton1Click:Connect(function()
    frame.Visible = false
    bola.Visible = true
end)

fechar.MouseButton1Click:Connect(function()
    frame.Visible = false
    bola.Visible = true
end)

bola.MouseButton1Click:Connect(function()
    frame.Visible = true
    bola.Visible = false
end)

resetBtn.MouseButton1Click:Connect(function() setSpeed(16) end)

-- ========== LOOP DE COLETA ==========
local loopRunning = false
local currentLoop = nil

local function coletarBaú(chest)
    if not chest or not chest.obj or not chest.obj.Parent then return false end
    
    statusText.Text = chest.emoji .. " " .. chest.tipo .. " (" .. math.floor(chest.dist) .. "m)"
    
    local path = Pathfinding:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(function() path:ComputeAsync(rootPart.Position, chest.pos) end)
    
    if not ok or path.Status ~= Enum.PathStatus.Success then
        statusText.Text = "⚠️ Caminho bloqueado!"
        return false
    end
    
    for _, wp in ipairs(path:GetWaypoints()) do
        if not auto then break end
        hum:MoveTo(wp.Position)
        hum.MoveToFinished:Wait(0.5)
    end
    
    -- Pula se estiver perto
    if (rootPart.Position - chest.pos).Magnitude < 15 then
        pular()
        task.wait(0.2)
    end
    
    if chest.obj and chest.obj.Parent and isPermitido(chest.obj) then
        coletados = coletados + 1
        statusText.Text = "✅ " .. chest.tipo .. " #" .. coletados
        local click = chest.obj:FindFirstChild("ClickDetector")
        if click then
            click:Click()
        else
            local parte = chest.obj:IsA("BasePart") and chest.obj or chest.obj:FindFirstChildWhichIsA("BasePart")
            if parte then fireclickdetector(parte) end
        end
        return true
    end
    return false
end

local function iniciarLoop()
    if currentLoop then task.cancel(currentLoop) end
    
    currentLoop = task.spawn(function()
        print("🔄 Loop iniciado!")
        while auto do
            if hum and hum.Health > 0 then
                deletarRuins()
                local chests = acharChests()
                if #chests > 0 then
                    coletarBaú(chests[1])
                else
                    statusText.Text = "🔍 Nenhum baú..."
                end
            end
            task.wait(1)
        end
        print("🔄 Loop finalizado")
    end)
end

-- Toggle Auto Chest
autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    if auto then
        autoBtn.Text = "🔍 Auto Chest: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        statusText.Text = "✅ ATIVADO!"
        iniciarLoop()
    else
        autoBtn.Text = "🔍 Auto Chest: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        statusText.Text = "⏸️ DESATIVADO"
        if currentLoop then task.cancel(currentLoop) end
    end
end)

-- Anti-AFK
local afkActive = false
local afkLoop = nil

local function iniciarAFK()
    if afkLoop then task.cancel(afkLoop) end
    afkLoop = task.spawn(function()
        while afkActive do
            task.wait(240)
            if afkActive then
                local mouse = player:GetMouse()
                if mouse then
                    local x = mouse.X
                    mouse.Move(x + 1, mouse.Y)
                    task.wait(0.1)
                    mouse.Move(x, mouse.Y)
                end
            end
        end
    end)
end

afkBtn.MouseButton1Click:Connect(function()
    afkActive = not afkActive
    if afkActive then
        afkBtn.Text = "💤 Anti-AFK: ON"
        afkBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        iniciarAFK()
    else
        afkBtn.Text = "💤 Anti-AFK: OFF"
        afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        if afkLoop then task.cancel(afkLoop) end
    end
end)

-- Iniciar tudo
task.wait(1)
setSpeed(50)
iniciarLoop()
print("✅ Chest Finder v13 - Carregado com sucesso!")
