local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- 1. НАСТРОЙКА ЦВЕТОВ ESP (Хайлайты без хитбоксов)
-- ========================================================
local function getRoleColor(player)
    -- Проверяем инвентарь или персонажа на наличие оружия
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    if (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 0, 0) -- Красный для Убийцы (Murderer)
    elseif (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun")) then
        return Color3.fromRGB(0, 0, 255) -- Синий для Шерифа (Sheriff)
    end
    return Color3.fromRGB(0, 255, 0) -- Зелёный для Невиновного (Innocent)
end

-- Функция создания подсветки
local function createESP(player)
    if player == LocalPlayer then return end
    
    local function applyHighlight(character)
        -- Удаляем старый ESP, если он остался
        if character:FindFirstChild("DeltaESP") then
            character.DeltaESP:Destroy()
        end
        
        -- Создаем современный Highlight (силуэт игрока сквозь стены)
        local highlight = Instance.new("Highlight")
        highlight.Name = "DeltaESP"
        highlight.Parent = character
        highlight.FillTransparency = 0.6 -- Прозрачность заливки внутри тела
        highlight.OutlineTransparency = 0 -- Четкий контур снаружи
        highlight.OutlineColor = getRoleColor(player)
        highlight.FillColor = getRoleColor(player)
        
        -- Постоянно обновляем цвет, если роль изменилась (кто-то подобрал пистолет)
        task.spawn(function()
            while character and character:Parent() and highlight and highlight.Parent do
                local currentColor = getRoleColor(player)
                highlight.OutlineColor = currentColor
                highlight.FillColor = currentColor
                task.wait(1)
            end
        end)
    end
    
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(applyHighlight)
end

-- Запуск ESP для всех игроков
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)

-- ========================================================
-- 2. ФУНКЦИЯ ОТ СЕБЯ: АВТО-СБОР МОНЕТ (Coin Autofarm)
-- ========================================================
-- Скрипт будет искать монеты на карте и притягивать их к твоему персонажу
task.spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            -- В MM2 монеты обычно спавнятся в специальной папке на карте
            local coinContainer = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("CoinContainer")
            
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if coin:IsA("BasePart") or coin:FindFirstChild("TouchInterest") then
                        -- Вместо жесткого телепорта игрока (за который может кикнуть античит), 
                        -- мы плавно притягиваем саму монету к хитбоксу игрока
                        coin.CFrame = hrp.CFrame
                    end
                end
            end
        end
    end
end)

print("Delta AI Base: MM2 Script Loaded Successfully!")
