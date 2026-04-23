--[[ Chest Finder v13.0 - Apenas correção do loop --]]

local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local auto = true
local coletados = 0
local velocidade = 16

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

-- GUI (igual ao seu original, omitido aqui por brevidade, mas mantenha a GUI que você já tem)
-- ... (todo o código da GUI, da bolinha até a criação dos botões, deve permanecer igual ao seu original)

-- 🔥 FUNÇÃO MOVER (apenas com o wait adicional)
local function mover(chest)
    if not chest or not hum then return end
    statusText.Text = chest.emoji .. " " .. chest.tipo .. " (" .. math.floor(chest.dist) .. "m)"
    local path = Pathfinding:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(function() path:ComputeAsync(char:GetPivot().Position, chest.pos) end)
    if ok and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if not auto then break end
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(1)
        end
        hum.Jump = true
        task.wait(0.3)
        if chest.obj and chest.obj.Parent and isPermitido(chest.obj) then
            coletados = coletados + 1
            contText.Text = "📊 Coletados: " .. coletados
            avisar(chest.emoji .. " " .. chest.tipo .. " #" .. coletados)
            statusText.Text = "✅ " .. chest.tipo .. "!"
            local click = chest.obj:FindFirstChild("ClickDetector")
            if click then
                click:Click()
            else
                local parte = chest.obj:IsA("BasePart") and chest.obj or chest.obj:FindFirstChildWhichIsA("BasePart")
                if parte then fireclickdetector(parte) end
            end
            task.wait(0.8)  -- <--- LINHA ADICIONADA
        end
    else
        statusText.Text = "⚠️ Caminho bloqueado!"
    end
end

-- 🔁 LOOP PRINCIPAL (apenas com o wait adicional)
local loop
local function iniciarLoop()
    if loop then task.cancel(loop) end
    loop = task.spawn(function()
        while auto do
            if hum and hum.Health > 0 then
                deletarRuins()
                local chests = acharChests()
                if #chests > 0 then
                    mover(chests[1])
                else
                    statusText.Text = "🔍 Nenhum baú com contorno..."
                end
            end
            task.wait(0.5)  -- <--- ALTERADO de 1 para 0.5
        end
        task.wait(0.5)      -- <--- LINHA ADICIONADA
    end)
end

-- O restante do script (arrastar, botões, anti-afk, animação) permanece igual ao seu original
