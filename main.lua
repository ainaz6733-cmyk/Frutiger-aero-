-- [[ Скрипт-загрузчик Frutiger Aero ]] --
local p = game.Players.LocalPlayer
local active = true

local function applyMesh(tool)
    -- Проверяем по внутренним звукам, что это именно классический пестик, а не нож
    if tool:IsA("Tool") and not tool.Name:lower():find("knife") and tool:FindFirstChild("Handle") then
        local m = tool.Handle:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", tool.Handle)
        if m then
            if active then
                -- Подтягиваем облегченный ID винтовки из базы данных
                m.MeshId = "rbxassetid://4400465814"
                m.TextureId = "rbxassetid://4400465922"
                m.Scale = Vector3.new(2.2, 2.2, 2.2)
                tool.Grip = CFrame.new(0, -0.4, -0.8) * CFrame.Angles(0, math.rad(90), 0)
            else
                -- Твой рабочий сброс на оригинал
                m.MeshId = ""
                m.TextureId = ""
                m.Scale = Vector3.new(1, 1, 1)
                tool.Grip = CFrame.new(0, 0, 0)
            end
        end
    end
end

-- Постоянное фоновое обновление через Heartbeat
game:GetService("RunService").Heartbeat:Connect(function()
    if p.Character then
        for _, item in pairs(p.Character:GetChildren()) do applyMesh(item) end
    end
end)

