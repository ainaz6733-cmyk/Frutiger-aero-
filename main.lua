-- FRUTIGER AERO MM2 HUB V3 (MOBILE OPTIMIZED)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true

-- Логика ролей
local function getRoleColor(player)
	if not player or not player.Character then return Color3.fromRGB(0, 255, 100) end
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	
	if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
		return Color3.fromRGB(255, 0, 50) -- Красный
	elseif (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
		return Color3.fromRGB(0, 100, 255) -- Синий
	end
	
	local normalFolder = Workspace:FindFirstChild("Normal")
	if normalFolder then
		local knifeModel = normalFolder:FindFirstChild("Knife")
		local gunModel = normalFolder:FindFirstChild("Gun")
		if knifeModel and knifeModel:FindFirstChild("Player") and knifeModel.Player.Value == player.Name then return Color3.fromRGB(255, 0, 50) end
		if gunModel and gunModel:FindFirstChild("Player") and gunModel.Player.Value == player.Name then return Color3.fromRGB(0, 100, 255) end
	end
	return Color3.fromRGB(0, 255, 100) -- Зелёный
end

-- Система ESP
local function applyESP(player)
	if player == LocalPlayer then return end
	local function setupHighlight(character)
		task.wait(0.5)
		if character:FindFirstChild("DeltaHighlight") then character.DeltaHighlight:Destroy() end
		
		local hl = Instance.new("Highlight")
		hl.Name = "DeltaHighlight"
		hl.OutlineTransparency = 0
		hl.FillTransparency = 0.6
		hl.Parent = character
		
		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not character or not character:Parent() or not hl or not hl.Parent then
				if conn then conn:Disconnect() end
				return
			end
			if EspEnabled then
				hl.Enabled = true
				local color = getRoleColor(player)
				hl.OutlineColor = color
				hl.FillColor = color
			else
				hl.Enabled = false
			end
		end)
	end
	if player.Character then setupHighlight(player.Character) end
	player.CharacterAdded:Connect(setupHighlight)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- Подсветка упавшего пистолета
task.spawn(function()
	while task.wait(1) do
		if EspEnabled then
			local droppedGun = Workspace:FindFirstChild("GunDrop")
			if droppedGun and droppedGun:IsA("BasePart") then
				if not droppedGun:FindFirstChild("GunHighlight") then
					local gunHl = Instance.new("Highlight")
					gunHl.Name = "GunHighlight"
					gunHl.OutlineColor = Color3.fromRGB(255, 215, 0)
					gunHl.FillColor = Color3.fromRGB(255, 215, 0)
					gunHl.FillTransparency = 0.3
					gunHl.OutlineTransparency = 0
					gunHl.Parent = droppedGun
				end
			end
		end
	end
end)

-- ========================================================
-- ГЛЯНЦЕВЫЙ FRUTIGER AERO ИНТЕРФЕЙС GUI
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
MainFrame.ClipsDescendants = true -- Скрывает лишнее по краям
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- ФОНОВАЯ КАРТИНКА (Frutiger Aero Текстура)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "AeroBackground"
BackgroundImage.Image = "rbxassetid://12558661621" -- Оригинальная Frutiger Aero текстура неба и травы
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.ImageTransparency = 0.3 -- Плавное наложение на тёмный фон
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 0 -- Задний план
BackgroundImage.Parent = MainFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 14)
BgCorner.Parent = BackgroundImage

-- Стеклянная неоновая полоска сверху
local TopLine = Instance.new("Frame")
TopLine.BackgroundColor3 = Color3.fromRGB(0, 220, 255) -- Лазурный эко-цвет
TopLine.Size = UDim2.new(1, 0, 0, 5)
TopLine.ZIndex = 1
TopLine.Parent = MainFrame

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 14)
TopLineCorner.Parent = TopLine

-- Заголовок
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

-- Тень под текстом для читаемости на фоне травы
local TitleShadow = Instance.new("TextLabel")
TitleShadow.BackgroundTransparency = 1
TitleShadow.Position = UDim2.new(0.06, 1, 0.12, 1)
TitleShadow.Size = UDim2.new(0, 200, 0, 25)
TitleShadow.Font = Enum.Font.GothamBold
TitleShadow.Text = "FRUTIGER AERO HUB"
TitleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleShadow.TextSize = 14
TitleShadow.TextTransparency = 0.5
TitleShadow.TextXAlignment = Enum.TextXAlignment.Left
TitleShadow.ZIndex = 1
TitleShadow.Parent = MainFrame

-- Кнопка Х (Сворачивание)
local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 0.8 -- Эффект стекла
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

-- Круглая иконка Delta
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

-- Кнопка переключения ESP (Аэро-голубая)
local EspToggle = Instance.new("TextButton")
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Лазурный глянцевый
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

-- Логика кнопок
EspToggle.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	if EspEnabled then
		EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	else
		EspToggle.Text = "ESP ПОДСВЕТКА: ВЫКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(80, 90, 100)
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
