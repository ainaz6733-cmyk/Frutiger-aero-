local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Чистим старый интерфейс, если он остался от прошлых запусков
if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

-- Переменные для переключателей (По умолчанию ВСЁ ВКЛЮЧЕНО)
local EspEnabled = true
local AutofarmEnabled = true

-- ========================================================
-- 1. ЛОГИКА ОПРЕДЕЛЕНИЯ РОЛЕЙ (Улучшенная)
-- ========================================================
local function getRoleColor(player)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	
	-- Ищем нож (Убийца)
	if (character and character:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife")) then
		return Color3.fromRGB(255, 0, 0) -- Красный
	-- Ищем пистолет (Шериф)
	elseif (character and character:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun")) then
		return Color3.fromRGB(0, 0, 255) -- Синий
	end
	
	return Color3.fromRGB(0, 255, 0) -- Зелёный (Невиновный)
end

-- Постоянное обновление ESP для каждого игрока
local function applyESP(player)
	if player == LocalPlayer then return end
	
	local function setupHighlight(character)
		task.wait(0.5) -- Даем персонажу прогрузиться
		
		local highlight = character:FindFirstChild("DeltaHighlight") or Instance.new("Highlight")
		highlight.Name = "DeltaHighlight"
		highlight.Parent = character
		highlight.OutlineTransparency = 0
		highlight.FillTransparency = 0.6
		
		-- Цикл обновления цвета и видимости
		task.spawn(function()
			while character and character:Parent() and highlight and highlight.Parent do
				if EspEnabled then
					highlight.Enabled = true
					local roleColor = getRoleColor(player)
					highlight.OutlineColor = roleColor
					highlight.FillColor = roleColor
				else
					highlight.Enabled = false
				end
				task.wait(0.5) -- Проверяем роли дважды в секунду
			end
		end)
	end
	
	if player.Character then setupHighlight(player.Character) end
	player.CharacterAdded:Connect(setupHighlight)
end

-- Запуск ESP для всех игроков в сессии
for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- ========================================================
-- 2. УЛУЧШЕННЫЙ АВТОФАРМ МОНЕТ
-- ========================================================
task.spawn(function()
	while task.wait(0.3) do
		if AutofarmEnabled then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local normal = Workspace:FindFirstChild("Normal")
			local coinContainer = normal and normal:FindFirstChild("CoinContainer")
			
			if hrp and coinContainer then
				for _, coin in ipairs(coinContainer:GetChildren()) do
					if coin:IsA("BasePart") then
						coin.CFrame = hrp.CFrame -- Притягиваем монету
					end
				end
			end
		end
	end
end)

-- ========================================================
-- 3. СОЗДАНИЕ КРАСИВОГО GUI ИНТЕРФЕЙСА
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главный фрейм меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.06, 0, 0.05, 0)
Title.Size = UDim2.new(0, 200, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "DELTA AI MEMU"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка Х (Свернуть)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- Маленький круглый значок Delta на экране
local DeltaIcon = Instance.new("TextButton")
DeltaIcon.Name = "DeltaIcon"
DeltaIcon.Parent = ScreenGui
DeltaIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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

-- --- КНОПКА ВКЛ/ВЫКЛ ESP ---
local EspToggle = Instance.new("TextButton")
EspToggle.Parent = MainFrame
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
EspToggle.Position = UDim2.new(0.06, 0, 0.3, 0)
EspToggle.Size = UDim2.new(0, 280, 0, 35)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.Text = "ESP СИЛУЭТЫ: ВКЛ"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.TextSize = 12

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 6)
EspCorner.Parent = EspToggle

-- --- КНОПКА ВКЛ/ВЫКЛ АВТОФАРМА ---
local FarmToggle = Instance.new("TextButton")
FarmToggle.Parent = MainFrame
FarmToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
FarmToggle.Position = UDim2.new(0.06, 0, 0.55, 0)
FarmToggle.Size = UDim2.new(0, 280, 0, 35)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.Text = "АВТО-СБОР МОНЕТ: ВКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggle.TextSize = 12

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 6)
FarmCorner.Parent = FarmToggle

-- ========================================================
-- 4. ВЗАИМОДЕЙСТВИЕ И ИНТЕРФЕЙСНЫЕ СКРИПТЫ
-- ========================================================

-- Переключатель ESP
EspToggle.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	if EspEnabled then
		EspToggle.Text = "ESP СИЛУЭТЫ: ВКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		EspToggle.Text = "ESP СИЛУЭТЫ: ВЫКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

-- Переключатель Автофарма
FarmToggle.MouseButton1Click:Connect(function()
	AutofarmEnabled = not AutofarmEnabled
	if AutofarmEnabled then
		FarmToggle.Text = "АВТО-СБОР МОНЕТ: ВКЛ"
		FarmToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		FarmToggle.Text = "АВТО-СБОР МОНЕТ: ВЫКЛ"
		FarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

-- Логика сворачивания в кружочек Delta
CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	DeltaIcon.Visible = true
end)

DeltaIcon.MouseButton1Click:Connect(function()
	DeltaIcon.Visible = false
	MainFrame.Visible = true
end)

print("Delta AI Hub: Обновление загружено!")
