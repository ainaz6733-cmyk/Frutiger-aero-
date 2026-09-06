-- FRUTIGER AERO MM2 HUB V4 (PERFECTLY OPTIMIZED)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true
local Highlights = {} -- Тут хранятся все созданные обводки

-- ОЧЕНЬ ПРОСТАЯ И БЫСТРАЯ ПРОВЕРКА РОЛИ (Только реальное оружие)
local function getRoleColor(player)
	if not player or not player.Character then return Color3.fromRGB(0, 255, 100) end
	
	-- Проверяем только то, что реально в руках или в рюкзаке прямо сейчас
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	
	if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
		return Color3.fromRGB(255, 0, 50) -- Красный (Убийца)
	elseif (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
		return Color3.fromRGB(0, 100, 255) -- Синий (Шериф)
	end
	
	return Color3.fromRGB(0, 255, 100) -- Зелёный (Мирный)
end

-- Функция обновления цвета для конкретного игрока
local function updatePlayerESP(player)
	if player == LocalPlayer or not player.Character then return end
	local char = player.Character
	
	local hl = char:FindFirstChild("DeltaHighlight")
	if not hl and EspEnabled then
		hl = Instance.new("Highlight")
		hl.Name = "DeltaHighlight"
		hl.OutlineTransparency = 0
		hl.FillTransparency = 0.6
		hl.Parent = char
		table.insert(Highlights, hl)
	end
	
	if hl then
		if EspEnabled then
			hl.Enabled = true
			local color = getRoleColor(player)
			hl.OutlineColor = color
			hl.FillColor = color
		else
			hl.Enabled = false
		end
	end
end

-- Слежка за добавлением персонажей
local function applyESP(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		updatePlayerESP(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- Быстрый и легкий таймер обновлений вместо тяжелого цикла
task.spawn(function()
	while task.wait(1) do
		for _, player in ipairs(Players:GetPlayers()) do
			updatePlayerESP(player)
		end
	end
end)

-- Подсветка упавшего пистолета
task.spawn(function()
	while task.wait(2) do
		local droppedGun = Workspace:FindFirstChild("GunDrop")
		if droppedGun and droppedGun:IsA("BasePart") then
			local gunHl = droppedGun:FindFirstChild("GunHighlight")
			if EspEnabled then
				if not gunHl then
					gunHl = Instance.new("Highlight")
					gunHl.Name = "GunHighlight"
					gunHl.OutlineColor = Color3.fromRGB(255, 215, 0)
					gunHl.FillColor = Color3.fromRGB(255, 215, 0)
					gunHl.FillTransparency = 0.3
					gunHl.OutlineTransparency = 0
					gunHl.Parent = droppedGun
				else
					gunHl.Enabled = true
				end
			else
				if gunHl then gunHl.Enabled = false end
			end
		end
	end
end)

-- ========================================================
-- ИНТЕРФЕЙС GUI
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 140)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "AeroBackground"
BackgroundImage.Image = "rbxassetid://12558661621"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.ImageTransparency = 0.3
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 14)
BgCorner.Parent = BackgroundImage

local TopLine = Instance.new("Frame")
TopLine.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
TopLine.Size = UDim2.new(1, 0, 0, 5)
TopLine.ZIndex = 1
TopLine.Parent = MainFrame

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 14)
TopLineCorner.Parent = TopLine

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.06, 0, 0.12, 0)
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "FRUTIGER AERO HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 0.8
CloseBtn.Position = UDim2.new(0.85, 0, 0.12, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 12
CloseBtn.ZIndex = 2
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

local DeltaIcon = Instance.new("TextButton")
DeltaIcon.Name = "DeltaIcon"
DeltaIcon.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
DeltaIcon.Position = UDim2.new(0.02, 0, 0.45, 0)
DeltaIcon.Size = UDim2.new(0, 45, 0, 45)
DeltaIcon.Font = Enum.Font.GothamBold
DeltaIcon.Text = "Δ"
DeltaIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
DeltaIcon.TextSize = 22
DeltaIcon.Visible = false
DeltaIcon.Parent = ScreenGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = DeltaIcon

local EspToggle = Instance.new("TextButton")
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
EspToggle.Position = UDim2.new(0.06, 0, 0.48, 0)
EspToggle.Size = UDim2.new(0, 264, 0, 40)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.TextSize = 12
EspToggle.ZIndex = 2
EspToggle.Parent = MainFrame

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 8)
EspCorner.Parent = EspToggle

-- МГНОВЕННАЯ ЛОГИКА НАЖАТИЯ (Теперь без лагов)
EspToggle.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	if EspEnabled then
		EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	else
		EspToggle.Text = "ESP ПОДСВЕТКА: ВЫКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(80, 90, 100)
	end
	-- Принудительно обновляем всех игроков сразу после клика
	for _, player in ipairs(Players:GetPlayers()) do
		updatePlayerESP(player)
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
