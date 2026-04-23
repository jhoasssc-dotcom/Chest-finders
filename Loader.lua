--[[ Chest Finder v13.0 - Loop Infinito (Nunca para) --]]

local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

local auto = true  -- Controle do botão
local coletados = 0
local velocidade = 50
local loopAtivo = true  -- Loop SEMPRE rodando

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

-- Pulo
local function pular()
    if hum then
        hum.Jump = true
        task.wait(0.1)
        hum.Jump = false
    end
end

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ChestFinder"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- Bolinha
local bola = Instance.new("ImageButton")
bola.Size = UDim2.new(0, 45, 0, 45)
bola.Position = UDim2.new(0, 10, 0, 100)
bola.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bola.Image = "rbxassetid://6031094839"
bola.ImageColor3 = Color3.fromRGB(200, 200, 200)
bola.Visible = false
bola.Parent = gui

local bolaC = Instance.new("UICorner")
bolaC.CornerRadius = UDim.new(1, 0)
bolaC.Parent = bola

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 160)
frame.Position = UDim2.new(0.5, -250, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
frame.Visible = true
frame.Parent = gui

local frameC = Instance.new("UICorner")
frameC.CornerRadius = UDim.new(0, 10)
frameC.Parent = frame

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

-- Botões de ABA
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

local miniC = Instance.new("UICorner")
miniC.CornerRadius = UDim.new(0, 5)
miniC.Parent = mini

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

local fecharC = Instance.new("UICorner")
fecharC.CornerRadius = UDim.new(0, 5)
fecharC.Parent = fechar

-- ========== CONTEÚDO ==========
-- Auto Chest
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 230, 0, 35)
autoBtn.Position = UDim2.new(0, 10, 0, 40)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
autoBtn.Text = "🔍 Auto Chest: ON"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Font = Enum.Font.GothamSemibold
autoBtn.Parent = frame

local autoC = Instance.new("UICorner")
autoC.CornerRadius = UDim.new(0, 6)
autoC.Parent = autoBtn

-- Anti-AFK
local afkBtn = Instance.new("TextButton")
afkBtn.Size = UDim2.new(0, 230, 0, 35)
afkBtn.Position = UDim2.new(1, -240, 0, 40)
afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
afkBtn.Text = "💤 Anti-AFK: OFF"
afkBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
afkBtn.TextSize = 12
afkBtn.Font = Enum.Font.GothamSemibold
afkBtn.Parent = frame

local afkC = Instance.new("UICorner")
afkC.CornerRadius = UDim.new(0, 6)
afkC.Parent = afkBtn

-- Velocidade
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 350, 0, 40)
speedFrame.Position = UDim2.new(0, 10, 0, 85)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedFrame.BackgroundTransparency = 0.3
speedFrame.Parent = frame

local speedC = Instance.new("UICorner")
speedC.CornerRadius = UDim.new(0, 6)
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
sliderBg.Size = UDim2.new(0, 180, 0, 5)
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

-- Reset
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 80, 0, 30)
resetBtn.Position = UDim2.new(0, 370, 0, 90)
resetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resetBtn.Text = "↺ Reset"
resetBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
resetBtn.TextSize = 10
resetBtn.Font = Enum.Font.Gotham
resetBtn.Parent = frame

local resetC = Instance.new("UICorner")
resetC.CornerRadius = UDim.new(0, 5)
resetC.Parent = resetBtn

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 480, 0, 30)
statusFrame.Position = UDim2.new(0.5, -240, 0, 128)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusFrame.BackgroundTransparency = 0.3
statusFrame.Parent = frame

local statusC = Instance.new("UICorner")
statusC.CornerRadius = UDim.new(0, 6)
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

-- Função para trocar abas
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

-- Slider drag
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
    edit.TextXAlignment = Enum.TextXAlignment.Center
    edit.Parent = speedValueBtn
    edit.FocusLost:Connect(function()
        local n = tonumber(edit.Text)
        if n then setSpeed(n) end
        edit:Destroy()
    end)
end)

-- Arrastar UI
local arrastando = false
local arrastarInicio, frameInicio

barra.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = true
        arrastarInicio = i.Position
        frameInicio = frame.Position
    end
end)

UserInput.InputChanged:Connect(function(i)
    if arrastando and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - arrastarInicio
        frame.Position = UDim2.new(frameInicio.X.Scale, frameInicio.X.Offset + delta.X, frameInicio.Y.Scale, frameInicio.Y.Offset + delta.Y)
    end
end)

UserInput.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then arrastando = false end
end)

-- Arrastar bolinha
local bolaArrastando = false
local bolaInicio, bolaPosInicio

bola.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        bolaArrastando = true
        bolaInicio = i.Position
        bolaPosInicio = bola.Position
    end
end)

UserInput.InputChanged:Connect(function(i)
    if bolaArrastando and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - bolaInicio
        bola.Position = UDim2.new(bolaPosInicio.X.Scale, bolaPosInicio.X.Offset + delta.X, bolaPosInicio.Y.Scale, bolaPosInicio.Y.Offset + delta.Y)
    end
end)

UserInput.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then bolaArrastando = false end
end)

-- Eventos dos botões
abaMainBtn.MouseButton1Click:Connect(function() trocarAba("Main") end)
abaAutoBtn.MouseButton1Click:Connect(function() trocarAba("AutoBuy") end)

mini.MouseButton1Click:Connect(function()
    if frame.Visible then
        frame.Visible = false
        bola.Visible = true
        avisar("📌 Minimizado")
    else
        frame.Visible = true
        bola.Visible = false
        avisar("📂 Restaurado")
    end
end)

fechar.MouseButton1Click:Connect(function()
    frame.Visible = false
    bola.Visible = true
    avisar("📁 Minimizado")
end)

bola.MouseButton1Click:Connect(function()
    frame.Visible = true
    bola.Visible = false
    avisar("📂 Restaurado")
end)

resetBtn.MouseButton1Click:Connect(function() setSpeed(16) end)

-- ========== LOOP INFINITO (NUNCA PARA) ==========
-- Esta função roda para SEMPRE, independente do botão
local function mover(chest)
    if not chest or not hum then return end
    statusText.Text = chest.emoji .. " " .. chest.tipo .. " (" .. math.floor(chest.dist) .. "m)"
    
    local path = Pathfinding:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(function() path:ComputeAsync(rootPart.Position, chest.pos) end)
    
    if ok and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if not auto then break end  -- Só para se o botão estiver OFF
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(1)
        end
        
        -- Pulo ao chegar perto
        if (rootPart.Position - chest.pos).Magnitude < 15 then
            pular()
            task.wait(0.2)
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
                if parte then fireclickdetector(parte) end
            end
            task.wait(0.3)
        end
    else
        statusText.Text = "⚠️ Caminho bloqueado!"
    end
end

-- LOOP PRINCIPAL - RODA PARA SEMPRE
task.spawn(function()
    print("🔄 Loop infinito iniciado - NUNCA vai parar!")
    while loopAtivo do  -- loopAtivo é sempre true
        if hum and hum.Health > 0 then
            deletarRuins()
            local chests = acharChests()
            if #chests > 0 then
                mover(chests[1])
            else
                if auto then
                    statusText.Text = "🔍 Nenhum baú com contorno..."
                else
                    statusText.Text = "⏸️ Auto Chest DESATIVADO - Aguardando..."
                end
            end
        else
            statusText.Text = "💀 Aguardando revive..."
        end
        task.wait(1)
    end
end)

-- Toggle Auto Chest (SÓ MUDA A VARIÁVEL, NÃO INTERROMPE O LOOP)
autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    print("🔘 Auto Chest - Estado:", auto)
    
    if auto then
        autoBtn.Text = "🔍 Auto Chest: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        statusText.Text = "✅ ATIVADO!"
        avisar("✅ Auto Chest ON - Coletando!")
    else
        autoBtn.Text = "🔍 Auto Chest: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        statusText.Text = "⏸️ DESATIVADO"
        avisar("❌ Auto Chest OFF")
    end
end)

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

afkBtn.MouseButton1Click:Connect(function()
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

-- Iniciar
task.spawn(function()
    wait(1)
    setSpeed(50)
    deletarRuins()
    print("✅ Chest Finder v13 - Loop INFINITO! Nunca para!")
    avisar("🚀 Loop infinito ativado!")
end)

-- Animação
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do
            local t = 0.5 + math.sin(i * math.pi) * 0.5
            frame.BorderColor3 = Color3.fromRGB(0, 255 * (1 - t), 255)
            if bola.Visible then
                bola.ImageColor3 = Color3.fromRGB(0, 255 * (1 - t), 255)
            end
            task.wait(0.05)
        end
    end
end)
