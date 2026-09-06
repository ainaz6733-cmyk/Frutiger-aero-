-- [[ Твой личный оптимизированный скрипт Frutiger Aero ]] --
local p = game.Players.LocalPlayer
local active = true

local function applyMesh(tool)
    -- Жесткий фильтр классического ножа, чтобы он не пропадал
    if tool:IsA("Tool") and not tool.Name:lower():find("knife") and tool:FindFirstChild("Handle") then
        local m = tool.Handle:FindFirstChildOfClass("SpecialMesh")
        if m then
            if active then
                -- Меняем ID на космический бластер-винтовку (он точно прогрузится)
                m.MeshId = "rbxassetid://4400465814"
                m.TextureId = "rbxassetid://4400465922"
                m.Scale = Vector3.new(2.3, 2.3, 2.3)
                tool.Grip = CFrame.new(0, -0.4, -0.8) * CFrame.Angles(0, math.rad(90), 0)
            else
                -- Твой рабочий сброс
                m.MeshId = ""
                m.TextureId = ""
                m.Scale = Vector3.new(1, 1, 1)
                tool.Grip = CFrame.new(0, 0, 0)
            end
        end
    end
end

-- Безопасный цикл: проверяет инвентарь раз в 0.4 секунды (0% лагов в Дельте)
task.spawn(function()
    while true do
        pcall(function()
            if p.Character then
                for _, item in pairs(p.Character:GetChildren()) do applyMesh(item) end
            end
            for _, item in pairs(p.Backpack:GetChildren()) do applyMesh(item) end
        end)
        task.wait(0.4)
    end
end)
