--[[ Chest Finder v11.2 - Pega baús normais, deleta recompensas de grupo, com velocidade --]]

local P=game:GetService("Players")
local S=game:GetService("PathfindingService")
local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local plr=P.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local hum=char:WaitForChild("Humanoid")
local auto=true
local coletados=0
local velocidade=16  -- velocidade padrão

local NEON=Color3.fromRGB(0,255,255)
local ESC=Color3.fromRGB(20,20,30)

-- Função de velocidade
local function setSpeed(s)
    s=math.clamp(s,10,100)
    velocidade=s
    hum.WalkSpeed=s
    if speedValueBtn then speedValueBtn.Text=tostring(math.floor(s)) end
    if sliderFill then
        local p=(s-10)/90
        sliderFill.Size=UDim2.new(p,0,1,0)
        sliderBtn.Position=UDim2.new(p,-6,0.5,-6)
    end
end

-- 🗑️ FUNÇÃO PARA DELETAR BAÚS RUINS (recompensas de grupo, free gift, etc.)
local function deletarBausRuins()
    local deletados=0
    for _,obj in ipairs(workspace:GetDescendants()) do
        local nome=string.lower(obj.Name or "")
        local isRuim=false
        local palavrasRuins={"free","gift","presente","reward","recompensa","brinde","fuse","shop","loja","store","buy","roblox","robux","yellow","amarelo","gold","group","grupo","daily","weekly"}
        for _,p in ipairs(palavrasRuins) do
            if string.find(nome,p) then
                isRuim=true
                break
            end
        end
        -- Se for um baú (tem chest no nome ou tem ClickDetector) e for ruim, deleta
        if isRuim and (string.find(nome,"chest") or string.find(nome,"bau") or obj:FindFirstChild("ClickDetector")) then
            pcall(function() obj:Destroy() end)
            deletados=deletados+1
        end
    end
    if deletados>0 then print("🗑️ Deletados",deletados,"baús ruins") end
end

-- 🚫 LISTA DE PALAVRAS BLOQUEADAS (para ignorar na hora de coletar)
local proibidas={
    "free","gift","presente","reward","recompensa","brinde","bonus","daily","diario","weekly",
    "shop","loja","store","buy","comprar","venda","roblox","robux","premium","vip",
    "fuse","set","event","starter","iniciante","beginner","pack","pacote","tutorial",
    "yellow","amarelo","gold","dourado","golden","ouro",
    "group","grupo","clan","guild"
}

-- ✅ Nomes PERMITIDOS (baús que queremos pegar)
local permitidos={
    "common","rare","legendary","rainbow","epic",
    "comum","raro","lendario","arco","iris"
}

local function isChestPermitido(obj)
    local nome=string.lower(obj.Name or "")
    
    -- Tem que ter "chest" ou "bau" no nome
    if not(string.find(nome,"chest") or string.find(nome,"bau") or string.find(nome,"baú")) then
        return false
    end
    
    -- Verifica palavras proibidas
    for _,p in ipairs(proibidas) do
        if string.find(nome,p) then
            return false
        end
    end
    
    -- Verifica se é um dos tipos permitidos (Common, Rare, etc.)
    local permitido=false
    for _,p in ipairs(permitidos) do
        if string.find(nome,p) then
            permitido=true
            break
        end
    end
    
    -- Se não for nenhum tipo específico, mas for apenas "Chest" ou "Baú", também permite (baú comum genérico)
    if not permitido then
        -- Se o nome é exatamente "chest" ou "bau" ou "baú" (sem qualificador), permite
        if nome=="chest" or nome=="bau" or nome=="baú" then
            permitido=true
        end
    end
    
    if not permitido then
        return false
    end
    
    -- Verifica hierarquia (pais)
    local atual=obj
    for i=1,5 do
        if not atual then break end
        local nomeAtual=string.lower(atual.Name or"")
        for _,p in ipairs(proibidas) do
            if string.find(nomeAtual,p) then
                return false
            end
        end
        if atual:FindFirstChild("Price") or atual:FindFirstChild("RobuxPrice") then
            return false
        end
        atual=atual.Parent
    end
    
    return true
end

local function getTipo(nome)
    local n=string.lower(nome)
    if string.find(n,"rainbow") or string.find(n,"arco") then
        return"🌈 Arco-Íris",5,"🌈"
    elseif string.find(n,"legendary") or string.find(n,"lendario") then
        return"🏆 Lendário",4,"🏆"
    elseif string.find(n,"rare") or string.find(n,"raro") then
        return"💎 Raro",3,"💎"
    elseif string.find(n,"epic") or string.find(n,"épico") then
        return"⚡ Épico",2,"⚡"
    else
        return"📦 Comum",1,"📦"
    end
end

local function acharChests()
    local encontrados={}
    local posChar=char:GetPivot().Position
    
    for _,obj in ipairs(workspace:GetDescendants()) do
        if isChestPermitido(obj) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local pos=obj:IsA("Model") and obj:GetPivot().Position or obj.Position
            if pos then
                local tipo,prio,emj=getTipo(obj.Name)
                local dist=(posChar-pos).Magnitude
                if dist<500 then
                    table.insert(encontrados,{obj=obj,pos=pos,dist=dist,tipo=tipo,prio=prio,emj=emj})
                end
            end
        end
    end
    
    table.sort(encontrados,function(a,b)
        if a.prio~=b.prio then return a.prio>b.prio end
        return a.dist<b.dist
    end)
    
    if #encontrados>0 then
        print("✅ Encontrado:",encontrados[1].tipo,math.floor(encontrados[1].dist),"m")
    else
        print("❌ Nenhum baú permitido encontrado!")
    end
    
    return encontrados
end

-- GUI (compacta com barra de velocidade)
local gui=Instance.new("ScreenGui")
gui.Name="ChestFinder"
gui.Parent=plr:WaitForChild("PlayerGui")

-- Bolinha flutuante
local bola=Instance.new("ImageButton")
bola.Size=UDim2.new(0,45,0,45)
bola.Position=UDim2.new(0,10,0,100)
bola.BackgroundColor3=ESC
bola.Image="rbxassetid://3926305904"
bola.ImageColor3=NEON
bola.Visible=false
bola.Parent=gui

local bolaC=Instance.new("UICorner")
bolaC.CornerRadius=UDim.new(1,0)
bolaC.Parent=bola

-- Frame principal
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,340,0,450)
frame.Position=UDim2.new(0.5,-170,0.5,-225)
frame.BackgroundColor3=ESC
frame.BackgroundTransparency=0.05
frame.BorderSizePixel=0
frame.Visible=true
frame.Parent=gui

local frameC=Instance.new("UICorner")
frameC.CornerRadius=UDim.new(0,10)
frameC.Parent=frame

local borda=Instance.new("Frame")
borda.Size=UDim2.new(1,0,1,0)
borda.BackgroundTransparency=1
borda.BorderSizePixel=2
borda.BorderColor3=NEON
borda.Parent=frame

-- Barra de título
local barra=Instance.new("Frame")
barra.Size=UDim2.new(1,0,0,30)
barra.BackgroundTransparency=1
barra.Parent=frame

local titulo=Instance.new("TextLabel")
titulo.Size=UDim2.new(1,-60,0,30)
titulo.Position=UDim2.new(0,5,0,0)
titulo.BackgroundTransparency=1
titulo.Text="🎁 Chest Finder v11.2"
titulo.TextColor3=NEON
titulo.TextSize=12
titulo.Font=Enum.Font.GothamBold
titulo.TextXAlignment=Enum.TextXAlignment.Left
titulo.Parent=barra

local mini=Instance.new("TextButton")
mini.Size=UDim2.new(0,25,0,25)
mini.Position=UDim2.new(1,-30,0,3)
mini.BackgroundColor3=Color3.fromRGB(40,40,50)
mini.Text="⬤"
mini.TextColor3=NEON
mini.TextSize=14
mini.Font=Enum.Font.GothamBold
mini.Parent=barra

local miniC=Instance.new("UICorner")
miniC.CornerRadius=UDim.new(0,5)
miniC.Parent=mini

local fechar=Instance.new("TextButton")
fechar.Size=UDim2.new(0,25,0,25)
fechar.Position=UDim2.new(1,-58,0,3)
fechar.BackgroundColor3=Color3.fromRGB(40,40,50)
fechar.Text="✕"
fechar.TextColor3=Color3.fromRGB(255,100,100)
fechar.TextSize=14
fechar.Font=Enum.Font.GothamBold
fechar.Parent=barra

local fecharC=Instance.new("UICorner")
fecharC.CornerRadius=UDim.new(0,5)
fecharC.Parent=fechar

-- Botão Auto Chest
local autoBtn=Instance.new("TextButton")
autoBtn.Size=UDim2.new(0,310,0,35)
autoBtn.Position=UDim2.new(0.5,-155,0,45)
autoBtn.BackgroundColor3=Color3.fromRGB(0,100,100)
autoBtn.Text="🔍 Auto Chest: ON"
autoBtn.TextColor3=Color3.fromRGB(255,255,255)
autoBtn.TextSize=13
autoBtn.Font=Enum.Font.GothamSemibold
autoBtn.Parent=frame

local autoC=Instance.new("UICorner")
autoC.CornerRadius=UDim.new(0,6)
autoC.Parent=autoBtn

-- Botão Anti-AFK
local afkBtn=Instance.new("TextButton")
afkBtn.Size=UDim2.new(0,310,0,35)
afkBtn.Position=UDim2.new(0.5,-155,0,88)
afkBtn.BackgroundColor3=Color3.fromRGB(30,30,40)
afkBtn.Text="💤 Anti-AFK: OFF"
afkBtn.TextColor3=Color3.fromRGB(200,200,200)
afkBtn.TextSize=13
afkBtn.Font=Enum.Font.GothamSemibold
afkBtn.Parent=frame

local afkC=Instance.new("UICorner")
afkC.CornerRadius=UDim.new(0,6)
afkC.Parent=afkBtn

-- 🎮 BARRA DE VELOCIDADE
local speedFrame=Instance.new("Frame")
speedFrame.Size=UDim2.new(0,310,0,50)
speedFrame.Position=UDim2.new(0.5,-155,0,133)
speedFrame.BackgroundColor3=Color3.fromRGB(25,25,35)
speedFrame.BackgroundTransparency=0.3
speedFrame.Parent=frame

local speedC2=Instance.new("UICorner")
speedC2.CornerRadius=UDim.new(0,6)
speedC2.Parent=speedFrame

local speedLabel=Instance.new("TextLabel")
speedLabel.Size=UDim2.new(0,60,1,0)
speedLabel.Position=UDim2.new(0,10,0,0)
speedLabel.BackgroundTransparency=1
speedLabel.Text="⚡ Velocidade:"
speedLabel.TextColor3=NEON
speedLabel.TextSize=11
speedLabel.Font=Enum.Font.GothamBold
speedLabel.TextXAlignment=Enum.TextXAlignment.Left
speedLabel.Parent=speedFrame

local sliderBg=Instance.new("Frame")
sliderBg.Size=UDim2.new(0,170,0,5)
sliderBg.Position=UDim2.new(0,75,0.5,-2.5)
sliderBg.BackgroundColor3=Color3.fromRGB(50,50,60)
sliderBg.BorderSizePixel=0
sliderBg.Parent=speedFrame

local sliderBgC=Instance.new("UICorner")
sliderBgC.CornerRadius=UDim.new(1,0)
sliderBgC.Parent=sliderBg

local sliderFill=Instance.new("Frame")
sliderFill.Size=UDim2.new((velocidade-10)/90,0,1,0)
sliderFill.BackgroundColor3=NEON
sliderFill.BorderSizePixel=0
sliderFill.Parent=sliderBg

local sliderBtn=Instance.new("TextButton")
sliderBtn.Size=UDim2.new(0,12,0,12)
sliderBtn.Position=UDim2.new((velocidade-10)/90,-6,0.5,-6)
sliderBtn.BackgroundColor3=NEON
sliderBtn.Text=""
sliderBtn.BorderSizePixel=0
sliderBtn.Parent=sliderBg

local speedValueBtn=Instance.new("TextButton")
speedValueBtn.Size=UDim2.new(0,45,0,28)
speedValueBtn.Position=UDim2.new(1,-50,0.5,-14)
speedValueBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
speedValueBtn.Text=tostring(velocidade)
speedValueBtn.TextColor3=NEON
speedValueBtn.TextSize=12
speedValueBtn.Font=Enum.Font.GothamBold
speedValueBtn.Parent=speedFrame

-- Slider arrastável
local sliderDrag=false
sliderBtn.MouseButton1Down:Connect(function() sliderDrag=true end)
U.InputChanged:Connect(function(input)
    if sliderDrag and input.UserInputType==Enum.UserInputType.MouseMovement then
        local pos=input.Position.X-sliderBg.AbsolutePosition.X
        local p=math.clamp(pos/sliderBg.AbsoluteSize.X,0,1)
        setSpeed(10+(p*90))
    end
end)
U.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then sliderDrag=false end
end)

-- Editar velocidade clicando no número
speedValueBtn.MouseButton1Click:Connect(function()
    local edit=Instance.new("TextBox")
    edit.Size=UDim2.new(1,0,1,0)
    edit.BackgroundColor3=Color3.fromRGB(30,30,40)
    edit.Text=tostring(velocidade)
    edit.TextColor3=NEON
    edit.TextSize=12
    edit.Font=Enum.Font.GothamBold
    edit.TextXAlignment=Enum.TextXAlignment.Center
    edit.Parent=speedValueBtn
    edit.FocusLost:Connect(function()
        local n=tonumber(edit.Text)
        if n then setSpeed(n) end
        edit:Destroy()
    end)
end)

-- Informações
local infoFrame=Instance.new("Frame")
infoFrame.Size=UDim2.new(0,310,0,50)
infoFrame.Position=UDim2.new(0.5,-155,0,193)
infoFrame.BackgroundColor3=Color3.fromRGB(25,25,35)
infoFrame.BackgroundTransparency=0.3
infoFrame.Parent=frame

local infoCorner=Instance.new("UICorner")
infoCorner.CornerRadius=UDim.new(0,6)
infoCorner.Parent=infoFrame

local infoText=Instance.new("TextLabel")
infoText.Size=UDim2.new(1,-10,1,-10)
infoText.Position=UDim2.new(0,5,0,5)
infoText.BackgroundTransparency=1
infoText.Text="🗑️ Deletando: Free Gift, Presente, Fuse, Shop, Grupo\n✅ Pegando: Common, Rare, Legendary, Rainbow"
infoText.TextColor3=Color3.fromRGB(200,200,200)
infoText.TextSize=9
infoText.TextWrapped=true
infoText.Font=Enum.Font.Gotham
infoText.Parent=infoFrame

-- Status
local statusFrame=Instance.new("Frame")
statusFrame.Size=UDim2.new(0,310,0,50)
statusFrame.Position=UDim2.new(0.5,-155,0,253)
statusFrame.BackgroundColor3=Color3.fromRGB(25,25,35)
statusFrame.BackgroundTransparency=0.3
statusFrame.Parent=frame

local statusCorner=Instance.new("UICorner")
statusCorner.CornerRadius=UDim.new(0,6)
statusCorner.Parent=statusFrame

local statusText=Instance.new("TextLabel")
statusText.Size=UDim2.new(1,-10,1,-10)
statusText.Position=UDim2.new(0,5,0,5)
statusText.BackgroundTransparency=1
statusText.Text="✅ Auto Chest ATIVADO!"
statusText.TextColor3=Color3.fromRGB(0,255,100)
statusText.TextSize=10
statusText.TextWrapped=true
statusText.Font=Enum.Font.Gotham
statusText.Parent=statusFrame

-- Contador
local contFrame=Instance.new("Frame")
contFrame.Size=UDim2.new(0,310,0,30)
contFrame.Position=UDim2.new(0.5,-155,0,313)
contFrame.BackgroundColor3=Color3.fromRGB(25,25,35)
contFrame.BackgroundTransparency=0.3
contFrame.Parent=frame

local contCorner=Instance.new("UICorner")
contCorner.CornerRadius=UDim.new(0,6)
contCorner.Parent=contFrame

local contText=Instance.new("TextLabel")
contText.Size=UDim2.new(1,-10,1,-10)
contText.Position=UDim2.new(0,5,0,5)
contText.BackgroundTransparency=1
contText.Text="📊 Coletados: 0"
contText.TextColor3=NEON
contText.TextSize=11
contText.Font=Enum.Font.Gotham
contText.Parent=contFrame

-- Botão reset velocidade
local resetBtn=Instance.new("TextButton")
resetBtn.Size=UDim2.new(0,90,0,28)
resetBtn.Position=UDim2.new(0.5,-45,0,355)
resetBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
resetBtn.Text="↺ Resetar (16)"
resetBtn.TextColor3=NEON
resetBtn.TextSize=10
resetBtn.Font=Enum.Font.Gotham
resetBtn.Parent=frame

local resetCorner=Instance.new("UICorner")
resetCorner.CornerRadius=UDim.new(0,5)
resetCorner.Parent=resetBtn

resetBtn.MouseButton1Click:Connect(function() setSpeed(16) end)

-- Notificação
local notifF=Instance.new("Frame")
notifF.Size=UDim2.new(0,250,0,45)
notifF.Position=UDim2.new(1,-270,0,50)
notifF.BackgroundColor3=Color3.fromRGB(30,30,40)
notifF.BackgroundTransparency=0.1
notifF.Visible=false
notifF.Parent=gui

local notifC=Instance.new("UICorner")
notifC.CornerRadius=UDim.new(0,6)
notifC.Parent=notifF

local notifT=Instance.new("TextLabel")
notifT.Size=UDim2.new(1,-10,1,-10)
notifT.Position=UDim2.new(0,5,0,5)
notifT.BackgroundTransparency=1
notifT.Text=""
notifT.TextColor3=NEON
notifT.TextSize=11
notifT.Font=Enum.Font.Gotham
notifT.Parent=notifF

local function avisar(msg)
    notifT.Text=msg
    notifF.Visible=true
    task.wait(2)
    notifF.Visible=false
end

-- Função de mover
local function mover(chest)
    if not chest or not hum then return end
    statusText.Text=chest.emj.." "..chest.tipo.." ("..math.floor(chest.dist).."m)"
    local path=S:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
    local ok=pcall(function() path:ComputeAsync(char:GetPivot().Position,chest.pos) end)
    if ok and path.Status==Enum.PathStatus.Success then
        for _,wp in ipairs(path:GetWaypoints()) do
            if not auto then break end
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(1)
        end
        if chest.obj and chest.obj.Parent and isChestPermitido(chest.obj) then
            coletados=coletados+1
            contText.Text="📊 Coletados: "..coletados
            avisar(chest.emj.." "..chest.tipo.." #"..coletados)
            statusText.Text="✅ "..chest.tipo.."!"
            local click=chest.obj:FindFirstChild("ClickDetector")
            if click then
                click:Click()
            else
                local parte=chest.obj:IsA("BasePart") and chest.obj or chest.obj:FindFirstChildWhichIsA("BasePart")
                if parte then fireclickdetector(parte) end
            end
        end
    else
        statusText.Text="⚠️ Caminho bloqueado!"
    end
end

-- Loop principal
local loop
local function iniciarLoop()
    if loop then task.cancel(loop) end
    loop=task.spawn(function()
        while auto do
            if hum and hum.Health>0 then
                -- Primeiro deleta os baús ruins
                deletarBausRuins()
                -- Depois procura os bons
                local chests=acharChests()
                if #chests>0 then
                    mover(chests[1])
                else
                    statusText.Text="🔍 Nenhum baú permitido..."
                end
            end
            task.wait(1)
        end
    end)
end

-- Arrastar UI
local arrastando=false
local arrastarInicio,frameInicio
barra.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        arrastando=true
        arrastarInicio=i.Position
        frameInicio=frame.Position
    end
end)
U.InputChanged:Connect(function(i)
    if arrastando and i.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=i.Position-arrastarInicio
        frame.Position=UDim2.new(frameInicio.X.Scale,frameInicio.X.Offset+delta.X,frameInicio.Y.Scale,frameInicio.Y.Offset+delta.Y)
    end
end)
U.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then arrastando=false end
end)

-- Arrastar bolinha
local bolaArrastando=false
local bolaInicio,bolaPosInicio
bola.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        bolaArrastando=true
        bolaInicio=i.Position
        bolaPosInicio=bola.Position
    end
end)
U.InputChanged:Connect(function(i)
    if bolaArrastando and i.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=i.Position-bolaInicio
        bola.Position=UDim2.new(bolaPosInicio.X.Scale,bolaPosInicio.X.Offset+delta.X,bolaPosInicio.Y.Scale,bolaPosInicio.Y.Offset+delta.Y)
    end
end)
U.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then bolaArrastando=false end
end)

-- Minimizar
mini.MouseButton1Click:Connect(function()
    if frame.Visible then
        frame.Visible=false
        bola.Visible=true
        avisar("📌 Minimizado")
    else
        frame.Visible=true
        bola.Visible=false
        avisar("📂 Restaurado")
    end
end)

fechar.MouseButton1Click:Connect(function()
    frame.Visible=false
    bola.Visible=true
    avisar("📁 Minimizado")
end)

bola.MouseButton1Click:Connect(function()
    frame.Visible=true
    bola.Visible=false
    avisar("📂 Restaurado")
end)

-- Toggle Auto Chest
autoBtn.MouseButton1Click:Connect(function()
    auto=not auto
    if auto then
        autoBtn.Text="🔍 Auto Chest: ON"
        autoBtn.BackgroundColor3=Color3.fromRGB(0,100,100)
        iniciarLoop()
        statusText.Text="✅ ATIVADO!"
        avisar("✅ Auto Chest ON - Deletando baús ruins")
    else
        autoBtn.Text="🔍 Auto Chest: OFF"
        autoBtn.BackgroundColor3=Color3.fromRGB(30,30,40)
        if loop then task.cancel(loop) end
        statusText.Text="⏸️ DESATIVADO"
        avisar("❌ Auto Chest OFF")
    end
end)

-- Anti AFK
local afkAtivo=false
local afkLoop
local function iniciarAFK()
    afkLoop=task.spawn(function()
        while afkAtivo do
            task.wait(240)
            if afkAtivo then
                local mouse=plr:GetMouse()
                if mouse then
                    local x=mouse.X
                    mouse.Move(x+1,mouse.Y)
                    task.wait(0.1)
                    mouse.Move(x,mouse.Y)
                end
                if hum then
                    hum:MoveTo(char:GetPivot().Position+Vector3.new(1,0,0))
                    task.wait(0.2)
                    hum:MoveTo(char:GetPivot().Position)
                end
            end
        end
    end)
end

afkBtn.MouseButton1Click:Connect(function()
    afkAtivo=not afkAtivo
    if afkAtivo t
