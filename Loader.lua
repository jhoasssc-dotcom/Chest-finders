--[[ Chest Finder v13.0 - Só pega baús com contorno (Highlight/SelectionBox) --]]

local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local auto = true
local coletados = 0
local velocidade = 50
local abaAtual = "Main"

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

-- 🔍 Verifica se o objeto tem contorno
local function temContorno(obj)
    if obj:FindFirstChildWhichIsA("Highlight") then return true end
    if obj:FindFirstChildWhichIsA("SelectionBox") then return true end
    if obj:IsA("Model") then
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") and (part:FindFirstChildWhichIsA("Highlight") or part:FindFirstChildWhichIsA("SelectionBox")) then
                return true
            end
        end
    end
    return false
end

-- 🚫 Lista de palavras proibidas
local proibidas = {
    "presente", "gratuito", "free", "gift", "reward", "recompensa", "brinde",
    "shop", "loja", "store", "buy", "comprar", "roblox", "robux", "premium", "vip",
    "fuse", "set", "event", "starter", "iniciante", "pack", "pacote",
    "yellow", "amarelo", "gold", "dourado", "group", "grupo", "daily", "weekly", "bonus"
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

local function isPermitido(obj)
    local nome = string.lower(obj.Name or "")
    if not (string.find(nome, "chest") or string.find(nome, "bau")) then return false end
    return temContorno(obj) and not isRuim(obj)
end

local function getTipo(nome)
    local n = string.lower(nome)
    if string.find(n, "rainbow") or string.find(n, "arco") then
        return "🌈 Arco-Íris", 5, "🌈"
    elseif string.find(n, "legendary") or string.find(n, "lendario") then
        return "🏆 Lendário", 4, "🏆"
    elseif string.find(n, "rare") or string.find(n, "raro") then
        return "💎 Raro", 3, "💎"
    else
        return "📦 Comum", 1, "📦"
    end
end

local function acharChests()
    local lista = {}
    local posChar = char:GetPivot().Position
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isPermitido(obj) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
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

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ChestFinder"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Bolinha
local bola = Instance.new("ImageButton")
bola.Size = UDim2.new(0, 50, 0, 50)
bola.Position = UDim2.new(0, 10, 0, 100)
bola.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bola.Image = "rbxassetid://3926305904"
bola.ImageColor3 = Color3.fromRGB(0, 255, 255)
bola.Visible = false
bola.Parent = gui

local bolaC = Instance.new("UICorner")
bolaC.CornerRadius = UDim.new(1, 0)
bolaC.Parent = bola

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 240)
frame.Position = UDim2.new(0.5, -225, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
frame.Visible = true
frame.Parent = gui

local frameC = Instance.new("UICorner")
frameC.CornerRadius = UDim.new(0, 10)
frameC.Parent = frame

-- Barra de título
local barra = Instance.new("Frame")
barra.Size = UDim2.new(1, 0, 0, 35)
barra.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
barra.BackgroundTransparency = 0
barra.Parent = frame

local barraC = Instance.new("UICorner")
barraC.CornerRadius = UDim.new(0, 10)
barraC.Parent = barra

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(0, 120, 0, 35)
titulo.Position = UDim2.new(0, 8, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "🎁 Chest Finder"
titulo.TextColor3 = Color3.fromRGB(0, 255, 255)
titulo.TextSize = 12
titulo.Font = Enum.Font.GothamBold
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = barra

-- Botões de aba
local abaMainBtn = Instance.new("TextButton")
abaMainBtn.Size = UDim2.new(0, 55, 0, 28)
abaMainBtn.Position = UDim2.new(0.5, -75, 0, 4)
abaMainBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
abaMainBtn.Text = "Main"
abaMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
abaMainBtn.TextSize = 11
abaMainBtn.Font = Enum.Font.GothamBold
abaMainBtn.Parent = barra

local abaMainC = Instance.new("UICorner")
abaMainC.CornerRadius = UDim.new(0, 5)
abaMainC.Parent = abaMainBtn

local abaAutoBtn = Instance.new("TextButton")
abaAutoBtn.Size = UDim2.new(0, 100, 0, 28)
abaAutoBtn.Position = UDim2.new(0.5, -15, 0, 4)
abaAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
abaAutoBtn.Text = "Auto Buy/Collect"
abaAutoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
abaAutoBtn.TextSize = 10
abaAutoBtn.Font = Enum.Font.GothamBold
abaAutoBtn.Parent = barra

local abaAutoC = Instance.new("UICorner")
abaAutoC.CornerRadius = UDim.new(0, 5)
abaAutoC.Parent = abaAutoBtn

-- Botão minimizar
local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 28, 0, 28)
mini.Position = UDim2.new(1, -62, 0, 4)
mini.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mini.Text = "⬤"
mini.TextColor3 = Color3.fromRGB(0, 255, 255)
mini.TextSize = 14
mini.Font = Enum.Font.GothamBold
mini.Parent = barra

local miniC = Instance.new("UICorner")
miniC.CornerRadius = UDim.new(0, 5)
miniC.Parent = mini

-- Botão fechar
local fechar = Instance.new("TextButton")
fechar.Size = UDim2.new(0, 28, 0, 28)
fechar.Position = UDim2.new(1, -32, 0, 4)
fechar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
fechar.Text = "✕"
fechar.TextColor3 = Color3.fromRGB(255, 100, 100)
fechar.TextSize = 14
fechar.Font = Enum.Font.GothamBold
fechar.Parent = barra

local fecharC = Instance.new("UICorner")
fecharC.CornerRadius = UDim.new(0, 5)
fecharC.Parent = fechar

-- ========== ABA MAIN ==========
-- Auto Chest
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 200, 0, 38)
autoBtn.Position = UDim2.new(0, 12, 0, 50)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
autoBtn.Text = "🔍 Auto Chest: ON"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Font = Enum.Font.GothamSemibold
autoBtn.Parent = frame

local autoC = Instance.new("UICorner")
autoC.CornerRadius = UDim.new(0, 8)
autoC.Parent = autoBtn

-- Anti-AFK
local afkBtn = Instance.new("TextButton")
afkBtn.Size = UDim2.new(0, 210, 0, 38)
afkBtn.Position = UDim2.new(1, -222, 0, 50)
afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
afkBtn.Text = "💤 Anti-AFK: OFF"
afkBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
afkBtn.TextSize = 12
afkBtn.Font = Enum.Font.GothamSemibold
afkBtn.Parent = frame

local afkC = Instance.new("UICorner")
afkC.CornerRadius = UDim.new(0, 8)
afkC.Parent = afkBtn

-- Velocidade
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 300, 0, 45)
speedFrame.Position = UDim2.new(0, 12, 0, 100)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedFrame.BackgroundTransparency = 0.3
speedFrame.Parent = frame

local speedC = Instance.new("UICorner")
speedC.CornerRadius = UDim.new(0, 8)
speedC.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 40, 1, 0)
speedLabel.Position = UDim2.new(0, 5, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡"
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Center
speedLabel.Parent = speedFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 160, 0, 5)
sliderBg.Position = UDim2.new(0, 50, 0.5, -2.5)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame

local sliderBgC = Instance.new("UICorner")
sliderBgC.CornerRadius = UDim.new(1, 0)
sliderBgC.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((velocidade - 10) / 90, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 14, 0, 14)
sliderBtn.Position = UDim2.new((velocidade - 10) / 90, -7, 0.5, -7)
sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
sliderBtn.Text = ""
sliderBtn.BorderSizePixel = 0
sliderBtn.Parent = sliderBg

local speedValueBtn = Instance.new("TextButton")
speedValueBtn.Size = UDim2.new(0, 55, 0, 32)
speedValueBtn.Position = UDim2.new(1, -65, 0.5, -16)
speedValueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedValueBtn.Text = tostring(velocidade)
speedValueBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
speedValueBtn.TextSize = 12
speedValueBtn.Font = Enum.Font.GothamBold
speedValueBtn.Parent = speedFrame

-- Reset
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 85, 0, 32)
resetBtn.Position = UDim2.new(0, 325, 0, 106)
resetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resetBtn.Text = "↺ Reset"
resetBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
resetBtn.TextSize = 11
resetBtn.Font = Enum.Font.Gotham
resetBtn.Parent = frame

local resetC = Instance.new("UICorner")
resetC.CornerRadius = UDim.new(0, 5)
resetC.Parent = resetBtn

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 426, 0, 45)
statusFrame.Position = UDim2.new(0.5, -213, 0, 160)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusFrame.BackgroundTransparency = 0.3
statusFrame.Parent = frame

local statusC = Instance.new("UICorner")
statusC.CornerRadius = UDim.new(0, 8)
statusC.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 1, -5)
statusText.Position = UDim2.new(0, 5, 0, 2)
statusText.BackgroundTransparency = 1
statusText.Text = "✅ Auto Chest ATIVADO!"
statusText.TextColor3 = Color3.fromRGB(0, 255, 100)
statusText.TextSize = 10
statusText.TextWrapped = true
statusText.Font = Enum.Font.Gotham
statusText.Parent = statusFrame

-- ========== ABA AUTO BUY/COLLECT ==========
local autoBuyFrame = Instance.new("Frame")
autoBuyFrame.Size = UDim2.new(0, 426, 0, 155)
autoBuyFrame.Position = UDim2.new(0.5, -213, 0, 50)
autoBuyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
autoBuyFrame.BackgroundTransparency = 0.3
autoBuyFrame.Visible = false
autoBuyFrame.Parent = frame

local autoBuyC = Instance.new("UICorner")
autoBuyC.CornerRadius = UDim.new(0, 8)
autoBuyC.Parent = autoBuyFrame

local autoBuyTitle = Instance.new("TextLabel")
autoBuyTitle.Size = UDim2.new(1, -20, 0, 30)
autoBuyTitle.Position = UDim2.new(0, 10, 0, 10)
autoBuyTitle.BackgroundTransparency = 1
autoBuyTitle.Text = "🛒 Auto Buy / Collect"
autoBuyTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
autoBuyTitle.TextSize = 14
autoBuyTitle.Font = Enum.Font.GothamBold
autoBuyTitle.TextXAlignment = Enum.TextXAlignment.Left
autoBuyTitle.Parent = autoBuyFrame

local autoBuyInfo = Instance.new("TextLabel")
autoBuyInfo.Size = UDim2.new(1, -20, 0, 70)
autoBuyInfo.Position = UDim2.new(0, 10, 0, 45)
autoBuyInfo.BackgroundTransparency = 1
autoBuyInfo.Text = "⚙️ Funções disponíveis na versão 14.0:\n\n• Auto Buy de itens da loja\n• Auto Collect de recompensas\n• Filtro personalizado\n• E muito mais!"
autoBuyInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
autoBuyInfo.TextSize = 10
autoBuyInfo.TextWrapped = true
autoBuyInfo.Font = Enum.Font.Gotham
autoBuyInfo.TextXAlignment = Enum.TextXAlignment.Left
autoBuyInfo.Parent = autoBuyFrame

local versaoText = Instance.new("TextLabel")
versaoText.Size = UDim2.new(1, -20, 0, 20)
versaoText.Position = UDim2.new(0, 10, 0, 125)
versaoText.BackgroundTransparency = 1
versaoText.Text = "📅 Próxima atualização: v14.0"
versaoText.TextColor3 = Color3.fromRGB(255, 200, 100)
versaoText.TextSize = 9
versaoText.Font = Enum.Font.GothamItalic
versaoText.TextXAlignment = Enum.TextXAlignment.Left
versaoText.Parent = autoBuyFrame

-- Notificação
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 250, 0, 45)
notifFrame.Position = UDim2.new(1, -270, 0, 50)
notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
notifFrame.BackgroundTransparency = 0.1
notifFrame.Visible = false
notifFrame.Parent = gui

local notifC = Instance.new("UICorner")
notifC.CornerRadius = UDim.new(0, 6)
notifC.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -10, 1, -10)
notifText.Position = UDim2.new(0, 5, 0, 5)
notifText.BackgroundTransparency = 1
notifText.Text = ""
notifText.TextColor3 = Color3.fromRGB(0, 255, 255)
notifText.TextSize = 11
notifText.Font = Enum.Font.Gotham
notifText.Parent = notifFrame

local function avisar(msg)
    notifText.Text = msg
    notifFrame.Visible = true
    task.wait(2)
    notifFrame.Visible = false
end

-- ========== FUNÇÕES ==========
local function mostrarAbaMain(mostrar)
    autoBtn.Visible = mostrar
    afkBtn.Visible = mostrar
    speedFrame.Visible = mostrar
    resetBtn.Visible = mostrar
    statusFrame.Visible = mostrar
end

local function mostrarAbaAutoBuy(mostrar)
    autoBuyFrame.Visible = mostrar
end

local function trocarAba(aba)
    abaAtual = aba
    if aba == "Main" then
        mostrarAbaMain(true)
        mostrarAbaAutoBuy(false)
        abaMainBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
        abaAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    else
        mostrarAbaMain(false)
        mostrarAbaAutoBuy(true)
        abaMainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        abaAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    end
end

-- Loop principal
local coletando = false
local loopTask

local function mover(chest)
    if coletando then return end
    coletando = true
    
    if not chest or not hum then 
        coletando = false
        return 
    end
    
    statusText.Text = chest.emoji .. " " .. chest.tipo .. " (" .. math.floor(chest.dist) .. "m)"
    
    local path = Pathfinding:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(function() path:ComputeAsync(char:GetPivot().Position, chest.pos) end)
    
    if ok and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if not auto then break end
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(1)
        end
        
        if chest.obj and chest.obj.Parent and isPermitido(chest.obj) then
            coletados = coletados + 1
            avisar(chest.emoji .. " " .. chest.tipo .. " #" .. coletados)
            statusText.Text = "✅ " .. chest.tipo .. " coletado!"
            
            local click = chest.obj:FindFirstChild("ClickDetector")
            if click then
                click:Click()
            else
                local parte = chest.obj:IsA("BasePart") and chest.obj or chest.obj:FindFirstChildWhichIsA("BasePart")
                if parte then 
                    fireclickdetector(parte)
                end
            end
            task.wait(0.5)
        end
    else
        statusText.Text = "⚠️ Caminho bloqueado!"
        task.wait(1)
    end
    coletando = false
end

local function iniciarLoop()
    if loopTask then task.cancel(loopTask) end
    loopTask = task.spawn(function()
        while auto do
            if hum and hum.Health > 0 then
                deletarRuins()
                local chests = acharChests()
                if #chests > 0 then
                    mover(chests[1])
                else
                    statusText.Text = "🔍 Nenhum baú com contorno..."
                    task.wait(1)
                end
            else
                task.wait(1)
            end
        end
    end)
end

-- Anti AFK
local afkAtivo = false
local afkLoop
local function iniciarAFK()
    if afkLoop then task.cancel(afkLoop) end
    afkLoop = task.spawn(function()
        while afkAtivo do
            task.wait(240)
            if afkAtivo then
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
        end
    end)
end

-- ========== EVENTOS (USANDO MOUSEBUTTON1DOWN PARA MAIOR COMPATIBILIDADE) ==========

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
speedValueBtn.MouseButton1Down:Connect(function()
    local edit = Instance.new("TextBox")
    edit.Size = UDim2.new(1, 0, 1, 0)
    edit.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    edit.Text = tostring(velocidade)
    edit.TextColor3 = Color3.fromRGB(0, 255, 255)
    edit.TextSize = 12
    edit.Font = Enum.Font.GothamBold
    edit.TextXAlignment = Enum.TextXAlignment.Center
    edit.Parent = speedValueBtn
    edit.FocusLost:Connect(function()
        local n = tonumber(edit.Text)
        if n then setSpeed(n) end
        edit:Destroy()
    end)
end)

-- Arrastar frame
local arrastandoFrame = false
local arrastarInicioFrame, frameInicio

barra.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastandoFrame = true
        arrastarInicioFrame = input.Position
        frameInicio = frame.Position
    end
end)

UserInput.InputChanged:Connect(function(input)
    if arrastandoFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - arrastarInicioFrame
        frame.Position = UDim2.new(frameInicio.X.Scale, frameInicio.X.Offset + delta.X, frameInicio.Y.Scale, frameInicio.Y.Offset + delta.Y)
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then arrastandoFrame = false end
end)

-- Arrastar bolinha
local arrastandoBola = false
local arrastarInicioBola, bolaInicio

bola.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastandoBola = true
        arrastarInicioBola = input.Position
        bolaInicio = bola.Position
    end
end)

UserInput.InputChanged:Connect(function(input)
    if arrastandoBola and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - arrastarInicioBola
        bola.Position = UDim2.new(bolaInicio.X.Scale, bolaInicio.X.Offset + delta.X, bolaInicio.Y.Scale, bolaInicio.Y.Offset + delta.Y)
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then arrastandoBola = false end
end)

-- Botões de navegação (MouseButton1Down)
abaMainBtn.MouseButton1Down:Connect(function()
    trocarAba("Main")
    avisar("📱 Aba Main")
end)

abaAutoBtn.MouseButton1Down:Connect(function()
    trocarAba("AutoBuy")
    avisar("🛒 Aba Auto Buy/Collect (v14.0)")
end)

-- Minimizar/Fechar
mini.MouseButton1Down:Connect(function()
    frame.Visible = false
    bola.Visible = true
    avisar("📌 Minimizado")
end)

fechar.MouseButton1Down:Connect(function()
    frame.Visible = false
    bola.Visible = true
    avisar("📁 Minimizado")
end)

bola.MouseButton1Down:Connect(function()
    frame.Visible = true
    bola.Visible = false
    avisar("📂 Restaurado")
end)

-- Auto Chest
autoBtn.MouseButton1Down:Connect(function()
    auto = not auto
    if auto then
        autoBtn.Text = "🔍 Auto Chest: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        iniciarLoop()
        statusText.Text = "✅ ATIVADO!"
        avisar("✅ Auto Chest ON")
    else
        autoBtn.Text = "🔍 Auto Chest: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        if loopTask then task.cancel(loopTask) end
        statusText.Text = "⏸️ DESATIVADO"
        avisar("❌ Auto Chest OFF")
    end
end)

-- Anti-AFK
afkBtn.MouseButton1Down:Connect(function()
    afkAtivo = not afkAtivo
    if afkAtivo then
        afkBtn.Text = "💤 Anti-AFK: ON"
        afkBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        iniciarAFK()
        avisar("💤 Anti-AFK ON")
    else
        afkBtn.Text = "💤 Anti-AFK: OFF"
        afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        if afkLoop then task.cancel(afkLoop) end
        avisar("💪 Anti-AFK OFF")
    end
end)

-- Reset
resetBtn.MouseButton1Down:Connect(function()
    setSpeed(16)
    avisar("↺ Velocidade resetada para 16")
end)

-- Iniciar
task.spawn(function()
    wait(1)
    setSpeed(50)
    deletarRuins()
