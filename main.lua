local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Очистка старых меню
if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true

-- ========================================================
-- 1. НАДЁЖНЫЙ СКАНЕР РОЛЕЙ (ПО НАЛИЧИЮ ОРУЖИЯ В ХИТБОКСЕ)
-- ========================================================
local function getPlayerRole(player)
	if not player then return "Innocent" end
	local char = player.Character
	local bp = player:FindFirstChild("Backpack")
	
	-- Проверяем Убийцу (в руках или в рюкзаке)
	if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
		return "Murderer"
	end
	
	-- Проверяем Шерифа (в руках или в рюкзаке)
	if (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
		return "Sheriff"
	end
	
	-- Ищем оружие на самом теле персонажа (когда оно убрано в кобуру/за спину)
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Tool") then
				if item.Name == "Knife" then return "Murderer" end
				if item.Name == "Gun" then return "Sheriff" end
			end
		end
	end
	
	return "Innocent"
end

local function getRoleColor(player)
	local role = getPlayerRole(player)
	if role == "Murderer" then
		return Color3.fromRGB(255, 0, 50) -- Красный для Убийцы
	elseif role == "Sheriff" then
		return Color3.fromRGB(0, 100, 255) -- Синий для Шерифа
	end
	return Color3.fromRGB(0, 255, 100) -- Зелёный для Мирных
end

-- ========================================================
-- 2. ОБНОВЛЕННАЯ СИСТЕМА ESP И ДЕТЕКТОР УПАВШЕГО ПИСТОЛЕТА
-- ========================================================
local function applyESP(player)
	if player == LocalPlayer then return end
	
	local function setupHighlight(character)
		task.wait(0.5)
		if character:FindFirstChild("DeltaHighlight") then
			character.DeltaHighlight:Destroy()
		end
		
		local hl = Instance.new("Highlight")
		hl.Name = "DeltaHighlight"
		hl.Parent = character
		hl.OutlineTransparency = 0
		hl.FillTransparency = 0.5
		
		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not character or not character:Parent() or not hl or not hl.Parent then
				if conn then conn:Disconnect() end
				return
			end
			if EspEnabled then
				hl.Enabled = true
				local c = getRoleColor(player)
				hl.OutlineColor = c
				hl.FillColor = c
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

-- ПОДСФЕТКА УПАВШЕГО ПИСТОЛЕТА (GUN ESP)
task.spawn(function()
	while task.wait(1) do
		if EspEnabled then
			-- Ищем пистолет на полу карты (в MM2 он обычно падает прямо в Workspace)
			local droppedGun = Workspace:FindFirstChild("GunDrop")
			if droppedGun and droppedGun:IsA("BasePart") then
				if not droppedGun:FindFirstChild("GunHighlight") then
					local gunHl = Instance.new("Highlight")
					gunHl.Name = "GunHighlight"
					gunHl.Parent = droppedGun
					gunHl.OutlineColor = Color3.fromRGB(255, 215, 0) -- Яркий золотой/жёлтый цвет
					gunHl.FillColor = Color3.fromRGB(255, 215, 0)
					gunHl.FillTransparency = 0.3
					gunHl.OutlineTransparency = 0
				end
			end
		end
	end
end)

-- ========================================================
-- 3. ИНТЕРФЕЙС GUI
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 140)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local TopLine = Instance.new("Frame")
TopLine.Parent = MainFrame
TopLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
TopLine.Size = UDim2.new(1, 0, 0, 4)

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 12)
TopLineCorner.Parent = TopLine

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.06, 0, 0.1, 0)
Title.Size = UDim2.new(0, 180, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "DELTA ESP BASE v3"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

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
