--[[ Chest Finder v14.0 - Auto Chest + Auto Buy/Collect --]]

local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- ========== VARIÁVEIS ==========
local autoChest = true
local autoBuy = false
local coletados = 0
local velocidade = 50

-- Lista de itens selecionados para Auto Buy
local selectedItems = {}
local selectedCategories = {}

-- ========== CATEGORIAS E ITENS ==========
local categories = {
    ["🌲 Madeira"] = {"Wood", "Wooden Slab", "Wood Planks", "Log"},
    ["🪨 Pedra"] = {"Stone", "Stone Slab", "Cobblestone", "Granite"},
    ["⚫ Carvão"] = {"Coal", "Charcoal", "Blackstone"},
    ["🟤 Terracota"] = {"Terracotta", "Black Terracotta", "Dark Grey Terracotta", "White Terracotta"},
    ["🔴 Rubi"] = {"Ruby", "Ruby Chamber", "Ruby Upgrader", "Ruby Conveyor"},
    ["🟢 Esmeralda"] = {"Emerald", "Emerald Chamber", "Emerald Upgrader", "Emerald Conveyor"},
    ["🔷 Obsidiana"] = {"Obsidian", "Obsidian Chamber", "Obsidian Upgrader", "Obsidian Conveyor"},
    ["💜 Plasma"] = {"Plasma", "Plasma Chamber", "Plasma Upgrader", "Plasma Conveyor"},
    ["✨ Astral"] = {"Astral", "Astral Collector", "Astral Upgrader", "Astral Conveyor"},
    ["🧪 Radioativo"] = {"Radioactive", "Radioactive Chamber", "Radioactive Upgrader", "Radioactive Conveyor"},
    ["🌌 Vazio"] = {"Void", "Void Chamber", "Void Upgrader", "Void Collector"},
    ["🍬 Doce"] = {"Candy", "Candy Chamber", "Candy Upgrader", "Candy Conveyor"},
    ["🔥 Infernal"] = {"Infernal", "Infernal Chamber", "Infernal Upgrader", "Infernal Conveyor"},
    ["📦 Comum"] = {"Common", "Common Collector", "Common Chamber", "Common Upgrader"},
    ["🟡 Raro"] = {"Rare", "Rare Collector", "Rare Chamber", "Rare Upgrader"},
    ["🟣 Épico"] = {"Epic", "Epic Collector", "Epic Chamber", "Epic Upgrader"},
    ["🔵 Lendário"] = {"Legendary", "Legendary Collector", "Legendary Chamber", "Legendary Upgrader"},
}

-- Todos os itens individuais (para busca)
local allItems = {}
for cat, items in pairs(categories) do
    for _, item in ipairs(items) do
        table.insert(allItems, {name = item, category = cat})
    end
end

-- ========== FUNÇÕES DO CHEST FINDER ==========
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

local function pular()
    if hum and rootPart then
        hum.Jump = true
        task.wait(0.15)
        hum.Jump = false
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0, 55, 0)
        bodyVel.MaxForce = Vector3.new(0, 10000, 0)
        bodyVel.Parent = rootPart
        task.wait(0.25)
        bodyVel:Destroy()
    end
end

-- ========== FUNÇÕES DO AUTO BUY ==========
local function comprarItem(itemName)
    print("🛒 Tentando comprar:", itemName)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name and string.find(string.lower(obj.Name), string.lower(itemName)) then
            if obj:FindFirstChild("ClickDetector") then
                obj.ClickDetector:Click()
                print("✅ Comprou:", itemName)
                return true
            end
        end
    end
    return false
end

local function comprarCategoria(categoryName)
    local items = categories[categoryName]
    if items then
        for _, item in ipairs(items) do
            comprarItem(item)
            task.wait(0.5)
        end
    end
end

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ChestFinder"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- Bolinha minimizada
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
frame.Size = UDim2.new(0, 750, 0, 500)
frame.Position = UDim2.new(0.5, -375, 0.5, -250)
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
barra.Size = UDim2.new(1, 0, 0, 35)
barra.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
barra.Parent = frame

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(0, 150, 0, 35)
titulo.Position = UDim2.new(0, 8, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "🎁 Chest Finder v14.0"
titulo.TextColor3 = Color3.fromRGB(0, 255, 255)
titulo.TextSize = 12
titulo.Font = Enum.Font.GothamBold
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = barra

-- Botões de ABA
local abaMainBtn = Instance.new("TextButton")
abaMainBtn.Size = UDim2.new(0, 60, 0, 28)
abaMainBtn.Position = UDim2.new(0.5, -80, 0, 4)
abaMainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
abaMainBtn.Text = "Main"
abaMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
abaMainBtn.TextSize = 11
abaMainBtn.Font = Enum.Font.GothamBold
abaMainBtn.Parent = barra

local abaAutoBtn = Instance.new("TextButton")
abaAutoBtn.Size = UDim2.new(0, 100, 0, 28)
abaAutoBtn.Position = UDim2.new(0.5, 20, 0, 4)
abaAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
abaAutoBtn.Text = "Auto Buy"
abaAutoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
abaAutoBtn.TextSize = 11
abaAutoBtn.Font = Enum.Font.GothamBold
abaAutoBtn.Parent = barra

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

-- ========== ABA MAIN ==========
-- Auto Chest
local autoChestBtn = Instance.new("TextButton")
autoChestBtn.Size = UDim2.new(0, 300, 0, 40)
autoChestBtn.Position = UDim2.new(0, 15, 0, 50)
autoChestBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
autoChestBtn.Text = "🔍 Auto Chest: ON"
autoChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoChestBtn.TextSize = 13
autoChestBtn.Font = Enum.Font.GothamSemibold
autoChestBtn.Parent = frame

-- Anti-AFK
local afkBtn = Instance.new("TextButton")
afkBtn.Size = UDim2.new(0, 300, 0, 40)
afkBtn.Position = UDim2.new(1, -315, 0, 50)
afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
afkBtn.Text = "💤 Anti-AFK: OFF"
afkBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
afkBtn.TextSize = 13
afkBtn.Font = Enum.Font.GothamSemibold
afkBtn.Parent = frame

-- Velocidade
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 450, 0, 45)
speedFrame.Position = UDim2.new(0, 15, 0, 105)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedFrame.BackgroundTransparency = 0.3
speedFrame.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 45, 1, 0)
speedLabel.Position = UDim2.new(0, 5, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡"
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
speedLabel.TextSize = 18
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = speedFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 250, 0, 6)
sliderBg.Position = UDim2.new(0, 55, 0.5, -3)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame

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
speedValueBtn.Size = UDim2.new(0, 60, 0, 32)
speedValueBtn.Position = UDim2.new(1, -70, 0.5, -16)
speedValueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedValueBtn.Text = tostring(velocidade)
speedValueBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
speedValueBtn.TextSize = 13
speedValueBtn.Font = Enum.Font.GothamBold
speedValueBtn.Parent = speedFrame

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 100, 0, 32)
resetBtn.Position = UDim2.new(0, 480, 0, 111)
resetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resetBtn.Text = "↺ Reset (16)"
resetBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
resetBtn.TextSize = 11
resetBtn.Font = Enum.Font.Gotham
resetBtn.Parent = frame

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 720, 0, 40)
statusFrame.Position = UDim2.new(0.5, -360, 0, 165)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusFrame.BackgroundTransparency = 0.3
statusFrame.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 1, -5)
statusText.Position = UDim2.new(0, 5, 0, 2)
statusText.BackgroundTransparency = 1
statusText.Text = "✅ Auto Chest ATIVADO!"
statusText.TextColor3 = Color3.fromRGB(0, 255, 100)
statusText.TextSize = 11
statusText.Font = Enum.Font.Gotham
statusText.Parent = statusFrame

-- Contador
local contadorText = Instance.new("TextLabel")
contadorText.Size = UDim2.new(0, 200, 0, 30)
contadorText.Position = UDim2.new(0, 15, 0, 215)
contadorText.BackgroundTransparency = 1
contadorText.Text = "📊 Baús coletados: 0"
contadorText.TextColor3 = Color3.fromRGB(0, 255, 255)
contadorText.TextSize = 12
contadorText.Font = Enum.Font.GothamBold
contadorText.Parent = frame

-- ========== ABA AUTO BUY ==========
local autoBuyFrame = Instance.new("Frame")
autoBuyFrame.Size = UDim2.new(0, 720, 0, 400)
autoBuyFrame.Position = UDim2.new(0.5, -360, 0, 50)
autoBuyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
autoBuyFrame.BackgroundTransparency = 0.2
autoBuyFrame.Visible = false
autoBuyFrame.Parent = frame

-- Barra de pesquisa
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0, 300, 0, 35)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
searchBox.Text = "Pesquisar item..."
searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
searchBox.TextSize = 12
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = true
searchBox.Parent = autoBuyFrame

-- Botão Auto Buy ON/OFF
local autoBuyToggle = Instance.new("TextButton")
autoBuyToggle.Size = UDim2.new(0, 150, 0, 35)
autoBuyToggle.Position = UDim2.new(1, -160, 0, 10)
autoBuyToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
autoBuyToggle.Text = "🛒 Auto Buy: OFF"
autoBuyToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
autoBuyToggle.TextSize = 12
autoBuyToggle.Font = Enum.Font.GothamSemibold
autoBuyToggle.Parent = autoBuyFrame

-- ScrollingFrame para a lista de itens
local itemList = Instance.new("ScrollingFrame")
itemList.Size = UDim2.new(1, -20, 0, 300)
itemList.Position = UDim2.new(0, 10, 0, 55)
itemList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
itemList.BackgroundTransparency = 0.3
itemList.BorderSizePixel = 0
itemList.CanvasSize = UDim2.new(0, 0, 0, 0)
itemList.ScrollBarThickness = 8
itemList.Parent = autoBuyFrame

local itemListLayout = Instance.new("UIListLayout")
itemListLayout.Padding = UDim.new(0, 5)
itemListLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemListLayout.Parent = itemList

-- Função para criar botões de categoria/item
local function criarBotaoSelecionavel(texto, tipo, valor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = itemList
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = btn
    
    local borda = Instance.new("UICorner")
    borda.CornerRadius = UDim.new(0, 4)
    borda.Parent = btn
    
    -- Borda de seleção
    local selectionBorder = Instance.new("Frame")
    selectionBorder.Size = UDim2.new(1, 0, 1, 0)
    selectionBorder.BackgroundTransparency = 1
    selectionBorder.BorderSizePixel = 2
    selectionBorder.BorderColor3 = Color3.fromRGB(255, 0, 0)
    selectionBorder.Parent = btn
    
    local function atualizarBorda()
        local selecionado = false
        if tipo == "categoria" then
            selecionado = selectedCategories[valor]
        else
            selecionado = selectedItems[valor]
        end
        
        if selecionado then
            selectionBorder.BorderColor3 = Color3.fromRGB(0, 255, 0)
            btn.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
        else
            selectionBorder.BorderColor3 = Color3.fromRGB(200, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        if tipo == "categoria" then
            selectedCategories[valor] = not selectedCategories[valor]
            if selectedCategories[valor] then
                -- Seleciona todos os itens da categoria
                for _, item in ipairs(categories[valor]) do
                    selectedItems[item] = true
                end
            else
                -- Deseleciona todos os itens da categoria
                for _, item in ipairs(categories[valor]) do
                    selectedItems[item] = nil
                end
            end
        else
            selectedItems[valor] = not selectedItems[valor]
        end
        atualizarBorda()
    end)
    
    atualizarBorda()
    return btn
end

-- Função para atualizar a lista baseado na pesquisa
local function atualizarLista(pesquisa)
    -- Limpar lista
    for _, child in ipairs(itemList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    pesquisa = string.lower(pesquisa or "")
    
    -- Adicionar categorias primeiro
    for catName, items in pairs(categories) do
        if pesquisa == "" or string.find(string.lower(catName), pesquisa) then
            criarBotaoSelecionavel("📁 " .. catName, "categoria", catName)
        end
    end
    
    -- Adicionar itens individuais se pesquisa não estiver vazia
    if pesquisa ~= "" then
        for _, item in ipairs(allItems) do
            if string.find(string.lower(item.name), pesquisa) then
                criarBotaoSelecionavel("📦 " .. item.name, "item", item.name)
            end
        end
    end
    
    -- Ajustar canvas size
    task.wait()
    itemList.CanvasSize = UDim2.new(0, 0, 0, itemListLayout.AbsoluteContentSize.Y + 10)
end

-- Evento de pesquisa
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    atualizarLista(searchBox.Text)
end)

-- Carregar lista inicial
atualizarLista("")

-- Função de Auto Buy (loop)
local buyLoop = nil
local function iniciarBuyLoop()
    if buyLoop then task.cancel(buyLoop) end
    buyLoop = task.spawn(function()
        while autoBuy do
            for catName, selecionado in pairs(selectedCategories) do
                if selecionado and autoBuy then
                    comprarCategoria(catName)
                    task.wait(1)
                end
            end
            for itemName, selecionado in pairs(selectedItems) do
                if selecionado and autoBuy then
                    comprarItem(itemName)
                    task.wait(0.5)
                end
            end
            task.wait(2)
        end
    end)
end

-- Toggle Auto Buy
autoBuyToggle.MouseButton1Click:Connect(function()
    autoBuy = not autoBuy
    if autoBuy then
        autoBuyToggle.Text = "🛒 Auto Buy: ON"
        autoBuyToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        iniciarBuyLoop()
        avisar("🛒 Auto Buy ON")
    else
        autoBuyToggle.Text = "🛒 Auto Buy: OFF"
        autoBuyToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        if buyLoop then task.cancel(buyLoop) end
        avisar("🛒 Auto Buy OFF")
    end
end)

-- Notificação
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 300, 0, 50)
notifFrame.Position = UDim2.new(1, -320, 0, 60)
notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
notifFrame.BackgroundTransparency = 0.1
notifFrame.Visible = false
notifFrame.Parent = gui

local notifC = Instance.new("UICorner")
notifC.CornerRadius = UDim.new(0, 8)
notifC.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -10, 1, -10)
notifText.Position = UDim2.new(0, 5, 0, 5)
notifText.BackgroundTransparency = 1
notifText.Text = ""
notifText.TextColor3 = Color3.fromRGB(0, 255, 255)
notifText.TextSize = 12
notifText.Font = Enum.Font.Gotham
notifText.TextWrapped = true
notifText.Parent = notifFrame

local function avisar(msg)
    notifText.Text = msg
    notifFrame.Visible = true
    task.wait(2.5)
    notifFrame.Visible = false
end

-- ========== LOOP DO CHEST FINDER (CORRIGIDO) ==========
local function moverParaChest(chest)
    if not chest or not chest.obj or not chest.obj.Parent then return false end
    
    statusText.Text = chest.emoji .. " " .. chest.tipo .. " (" .. math.floor(chest.dist) .. "m)"
    
    local path = Pathfinding:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local success = pcall(function() 
        path:ComputeAsync(rootPart.Position, chest.pos) 
    end)
    
    if not success or path.Status ~= Enum.PathStatus.Success then
        statusText.Text = "⚠️ Caminho bloqueado! Tentando novamente..."
        return false
    end
    
    local waypoints = path:GetWaypoints()
    for i, waypoint in ipairs(waypoints) do
        if not autoChest then break end
        hum:MoveTo(waypoint.Position)
        hum.MoveToFinished:Wait(0.5)
    end
    
    local distFinal = (rootPart.Position - chest.pos).Magnitude
    if distFinal < 20 then
        pular()
        task.wait(0.3)
    end
    
    if chest.obj and chest.obj.Parent and isPermitido(chest.obj) then
        coletados = coletados + 1
        contadorText.Text = "📊 Baús coletados: " .. coletados
        avisar(chest.emoji .. " " .. chest.tipo .. " #" .. coletados)
        statusText.Text = "✅ " .. chest.tipo .. " coletado!"
        
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

-- Loop principal do Chest
task.spawn(function()
    print("🔄 Loop do Chest Finder iniciado!")
    while true do
        if autoChest and hum and hum.Health > 0 then
            deletarRuins()
            local chests = acharChests()
            if #chests > 0 then
                moverParaChest(chests[1])
            else
                statusText.Text = "🔍 Nenhum baú com contorno..."
            end
        elseif not autoChest then
            statusText.Text = "⏸️ Auto Chest DESATIVADO"
        elseif hum and hum.Health <= 0 then
            statusText.Text = "💀 Aguardando revive..."
        end
        task.wait(0.5)
    end
end)

-- ========== EVENTOS ==========
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

speedValueBtn.MouseButton1Click:Connect(function()
    local edit = Instance.new("TextBox")
    edit.Size = UDim2.new(1, 0, 1, 0)
    edit.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    edit.Text = tostring(velocidade)
    edit.TextColor3 = Color3.fromRGB(0, 255, 255)
    edit.TextSize = 13
    edit.Font = Enum.Font.GothamBold
    edit.Parent = speedValueBtn
    edit.FocusLost:Connect(function()
        local n = tonumber(edit.Text)
        if n then setSpeed(n) end
        edit:Destroy()
    end)
end)

-- Arrastar UI
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

-- Toggle Abas
local function trocarAba(aba)
    if aba == "Main" then
        autoChestBtn.Visible = true
        afkBtn.Visible = true
        speedFrame.Visible = true
        resetBtn.Visible = true
        statusFrame.Visible = true
        contadorText.Visible = true
        autoBuyFrame.Visible = false
        abaMainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
        abaAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    else
        autoChestBtn.Visible = false
        afkBtn.Visible = false
        speedFrame.Visible = false
        resetBtn.Visible = false
        statusFrame.Visible = false
        contadorText.Visible = false
        autoBuyFrame.Visible = true
        abaMainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        abaAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
    end
end

abaMainBtn.MouseButton1Click:Connect(function() trocarAba("Main") end)
abaAutoBtn.MouseButton1Click:Connect(function() trocarAba("AutoBuy") end)

-- Minimizar/Fechar
mini.MouseButton1Click:Connect(function()
    frame.Visible = false
    bola.Visible = true
    avisar("📌 Minimizado")
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

-- Toggle Auto Chest
autoChestBtn.MouseButton1Click:Connect(function()
    autoChest = not autoChest
    if autoChest then
        autoChestBtn.Text = "🔍 Auto Chest: ON"
        autoChestBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        statusText.Text = "✅ ATIVADO!"
        avisar("✅ Auto Chest ON")
    else
        autoChestBtn.Text = "🔍 Auto Chest: OFF"
        autoChestBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        statusText.Text = "⏸️ DESATIVADO"
        avisar("❌ Auto Chest OFF")
    end
end)

-- Anti AFK
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
                if hum then
                    hum:MoveTo(rootPart.Position + Vector3.new(1, 0, 0))
                    task.wait(0.2)
                    hum:MoveTo(rootPart.Position)
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
        avisar("💤 Anti-AFK ON")
    else
        afkBtn.Text = "💤 Anti-AFK: OFF"
        afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        if afkLoop then task.cancel(afkLoop) end
        avisar("💪 Anti-AFK OFF")
    end
end)

resetBtn.MouseButton1Click:Connect(function()
    setSpeed(16)
    avisar("↺ Velocidade resetada para 16")
end)

-- Iniciar
task.spawn(function()
    wait(1)
    setSpeed(50)
    deletarRuins()
    print("✅ Chest Finder v14.0 - Carregado!")
    avisar("🚀 v14.0 - Auto Chest + Auto Buy!")
end)

-- Animação da borda
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
