--[[ TESTE - Chest Finder v13.0 SIMPLIFICADO --]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Criar GUI de teste
local gui = Instance.new("ScreenGui")
gui.Name = "ChestFinderTest"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
frame.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🧪 TESTE - Clique nos Botões"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.BackgroundTransparency = 1
title.Parent = frame

-- Botão 1
local btn1 = Instance.new("TextButton")
btn1.Size = UDim2.new(0, 200, 0, 40)
btn1.Position = UDim2.new(0.5, -100, 0, 50)
btn1.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
btn1.Text = "🔍 Botão 1"
btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
btn1.Parent = frame

-- Botão 2
local btn2 = Instance.new("TextButton")
btn2.Size = UDim2.new(0, 200, 0, 40)
btn2.Position = UDim2.new(0.5, -100, 0, 110)
btn2.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
btn2.Text = "💤 Botão 2"
btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
btn2.Parent = frame

-- Eventos dos botões
btn1.MouseButton1Click:Connect(function()
    print("🔘 BOTÃO 1 CLICADO!")
    btn1.Text = "✅ Clicado!"
    task.wait(0.5)
    btn1.Text = "🔍 Botão 1"
end)

btn2.MouseButton1Click:Connect(function()
    print("🔘 BOTÃO 2 CLICADO!")
    btn2.Text = "✅ Clicado!"
    task.wait(0.5)
    btn2.Text = "💤 Botão 2"
end)

print("✅ GUI de teste criada! Clique nos botões e veja o console (F9)")
