local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Полная очистка старых версий
if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true

-- ========================================================
-- 1. НАДЁЖНОЕ ОПРЕДЕЛЕНИЕ РОЛЕЙ (ПО МЕТОДУ VORTEX HUB)
-- ========================================================
-- Скрипт проверяет не только наличие оружия в руках, но и заглядывает 
-- во внутренние папки данных раунда MM2
local function getPlayerRole(player)
    if not player then return "Innocent" end
    
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    -- Проверка на Убийцу
    if (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    
    -- Проверка на Шерифа/Героя
    if (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    
    -- Дополнительная проверка через логику MM2 (ищем эффекты и скрытые свойства)
    if player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("Role") then
        local roleValue = player.PlayerData.Role.Value
        if roleValue == "Murderer" then return "Murderer" end
        if roleValue == "Sheriff" or roleValue == "Hero" then return "Sheriff" end
    end
    
    return "Innocent"
end

local function getRoleColor(player)
    local role = getPlayerRole(player)
    if role == "Murderer" then
        return Color3.fromRGB(255, 0, 50) -- Насыщенный красный
    elseif role == "Sheriff" then
        return Color3.fromRGB(0, 100, 255) -- Яркий синий
    end
    return Color3.fromRGB(0, 255, 100) -- Зелёный для мирных
end

-- ========================================================
-- 2. СИСТЕМА ESP (АККУРАТНЫЕ ХАЙЛАЙТЫ)
-- ========================================================
local function applyESP(player)
	if player == LocalPlayer then return end
	
	local function setupHighlight(character)
		task.wait(0.2)
		
		-- Удаляем старый, если он забагался
		if character:FindFirstChild("DeltaHighlight") then
			character.DeltaHighlight:Destroy()
		end
		
		local highlight = Instance.new("Highlight")
		highlight.Name = "DeltaHighlight"
		highlight.Parent = character
		highlight.OutlineTransparency = 0
		highlight.FillTransparency = 0.5
		
		-- Цикл постоянного контроля роли и переключателя GUI
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not character or not character:Parent() or not highlight or not highlight.Parent then
				if connection then connection:Disconnect() end
				return
			end
			
			if EspEnabled then
				highlight.Enabled = true
				local color = getRoleColor(player)
				highlight.OutlineColor = color
				highlight.FillColor = color
			else
				highlight.Enabled = false
			end
		end)
	end
	
	if player.Character then setupHighlight(player.Character) end
	player.CharacterAdded:Connect(setupHighlight)
end

-- Запуск на всех игроков
for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- ========================================================
-- 3. ОБНОВЛЕННЫЙ GUI (БЕЗ ФАРМА)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 140) -- Сделали компактнее, так как фарм убран
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Неоновая полоска сверху для стиля
local TopLine = Instance.new("Frame")
TopLine.Parent = MainFrame
TopLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
TopLine.Size = UDim2.new(1, 0, 0, 4)

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 12)
TopLineCorner.Parent = TopLine

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.06, 0, 0.1, 0)
Title.Size = UDim2.new(0, 180, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "DELTA ESP BASE"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка Х (Сворачивание)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
CloseBtn.Position = UDim2.new(0.85, 0, 0.1, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- Круглая иконка Delta
local DeltaIcon = Instance.new("TextButton")
DeltaIcon.Name = "DeltaIcon"
DeltaIcon.Parent = ScreenGui
DeltaIcon.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
DeltaIcon.Position = UDim2.new(0.02, 0, 0.45, 0)
DeltaIcon.Size = UDim2.new(0, 45, 0, 45)
DeltaIcon.Font = Enum.Font.GothamBold
DeltaIcon.Text = "Δ"
DeltaIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
DeltaIcon.TextSize = 22
DeltaIcon.Visible = false

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = DeltaIcon

-- Кнопка переключения ESP
local EspToggle = Instance.new("TextButton")
EspToggle.Parent = MainFrame
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
EspToggle.Position = UDim2.new(0.06, 0, 0.45, 0)
EspToggle.Size = UDim2.new(0, 264, 0, 40)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.TextSize = 12

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 8)
EspCorner.Parent = EspToggle

-- ========================================================
-- 4. ИНТЕРФЕЙСНАЯ ЛОГИКА
-- ========================================================
EspToggle.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	if EspEnabled then
		EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		EspToggle.Text = "ESP ПОДСВЕТКА: ВЫКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	DeltaIcon.Visible = true
end)

DeltaIcon.MouseButton1Click:Connect(function()
	DeltaIcon.Visible = false
	MainFrame.Visible = true
end)

print("Delta Hub: Скрипт успешно обновлён до версии v2!")
