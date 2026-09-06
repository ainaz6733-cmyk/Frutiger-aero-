-- FRUTIGER AERO MM2 HUB V9 (HARD LOCK CAM AIMBOT)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true
local AimbotEnabled = true
local Highlights = {}

-- ========================================================
-- ОПРЕДЕЛЕНИЕ РОЛЕЙ
-- ========================================================
local function getPlayerRole(player)
	if not player or not player.Character then return "Innocent" end
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	
	if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
		return "Murderer"
	elseif (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
		return "Sheriff"
	end
	return "Innocent"
end

local function getRoleColor(player)
	local role = getPlayerRole(player)
	if role == "Murderer" then return Color3.fromRGB(255, 0, 50) end
	if role == "Sheriff" then return Color3.fromRGB(0, 100, 255) end
	return Color3.fromRGB(0, 255, 100)
end

-- ========================================================
-- УМНЫЙ ВЫБОР ЦЕЛИ
-- ========================================================
local function getBestTarget()
	local localRole = getPlayerRole(LocalPlayer)
	local closestPlayer = nil
	local shortestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local targetPart = player.Character.HumanoidRootPart
				
				-- Дистанция между нами и целью
				local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
				local targetRole = getPlayerRole(player)
				
				if localRole == "Sheriff" and targetRole == "Murderer" then
					return player
				elseif localRole == "Murderer" then
					if targetRole == "Sheriff" then
						return player
					elseif targetRole == "Innocent" and distance < shortestDistance then
						shortestDistance = distance
						closestPlayer = player
					end
				elseif localRole == "Innocent" and targetRole == "Murderer" and distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

-- ========================================================
-- ЖЕСТКАЯ НАВОДКА КАМЕРЫ ДЛЯ ПЕРВОГО ЛИЦА И SHIFT LOCK
-- ========================================================
-- Используем RenderStepped, чтобы наводка происходила быстрее, чем игра обрабатывает джойстик телефона
RunService.RenderStepped:Connect(function()
	if AimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local target = getBestTarget()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local targetPart = target.Character.HumanoidRootPart
			
			-- Жестко фиксируем позицию камеры так, чтобы центральный кружочек смотрел прямо в корпус врага
			-- Это мгновенная наводка, которую управление мобилки не способно перебить
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
		end
	end
end)

-- ========================================================
-- СИСТЕМА ESP
-- ========================================================
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

local function applyESP(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		updatePlayerESP(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

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
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local TopLine = Instance.new("Frame")
TopLine.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TopLine.Size = UDim2.new(1, 0, 0, 5)
TopLine.Parent = MainFrame

local TopLineCorner = Instance.new("UICorner")
TopLineCorner.CornerRadius = UDim.new(0, 14)
TopLineCorner.Parent = TopLine

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.06, 0, 0.08, 0)
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "FRUTIGER AERO HUB V9"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 50)
CloseBtn.Position = UDim2.new(0.85, 0, 0.08, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 12
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

local DeltaIcon = Instance.new("ImageButton")
DeltaIcon.Name = "AeroHumanIcon"
DeltaIcon.Image = "rbxassetid://9824248563" 
DeltaIcon.ImageColor3 = Color3.fromRGB(0, 180, 255)
DeltaIcon.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
DeltaIcon.BackgroundTransparency = 0.2
DeltaIcon.Position = UDim2.new(0.02, 0, 0.45, 0)
DeltaIcon.Size = UDim2.new(0, 50, 0, 50)
DeltaIcon.Visible = false
DeltaIcon.Parent = ScreenGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = DeltaIcon

local EspToggle = Instance.new("TextButton")
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
EspToggle.Position = UDim2.new(0.06, 0, 0.32, 0)
EspToggle.Size = UDim2.new(0, 264, 0, 38)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.TextSize = 12
EspToggle.Parent = MainFrame

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 8)
EspCorner.Parent = EspToggle

local AimToggle = Instance.new("TextButton")
AimToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
AimToggle.Position = UDim2.new(0.06, 0, 0.62, 0)
AimToggle.Size = UDim2.new(0, 264, 0, 38)
AimToggle.Font = Enum.Font.GothamBold
AimToggle.Text = "ХАРД АИМБОТ: ВКЛ"
AimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimToggle.TextSize = 12
AimToggle.Parent = MainFrame

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 8)
AimCorner.Parent = AimToggle

-- Логика переключателей
EspToggle.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	if EspEnabled then
		EspToggle.Text = "ESP ПОДСВЕТКА: ВКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	else
		EspToggle.Text = "ESP ПОДСВЕТКА: ВЫКЛ"
		EspToggle.BackgroundColor3 = Color3.fromRGB(80, 90, 100)
	end
	for _, player in ipairs(Players:GetPlayers()) do
		updatePlayerESP(player)
	end
end)

AimToggle.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	if AimbotEnabled then
		AimToggle.Text = "ХАРД АИМБОТ: ВКЛ"
		AimToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	else
		AimToggle.Text = "ХАРД АИМБОТ: ВЫКЛ"
		AimToggle.BackgroundColor3 = Color3.fromRGB(80, 90, 100)
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
