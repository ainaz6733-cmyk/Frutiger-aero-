-- FRUTIGER AERO MM2 HUB V6 (PRO AIMBOT + ESP)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true
local AimbotEnabled = true
local IsHoldingScreen = false -- Проверка, зажат ли экран (для активации аима)
local Highlights = {}

-- ========================================================
-- ОПРЕДЕЛЕНИЕ РОЛЕЙ И ЦВЕТОВ
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
-- ПРОВЕРКА ВИДИМОСТИ ЦЕЛИ (RAYCAST БЕЗ СТЕН)
-- ========================================================
local function isVisible(targetPart)
	local origin = Camera.CFrame.Position
	local direction = targetPart.Position - origin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	-- Игнорируем себя и персонажа цели при проверке препятствий
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
	
	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result == nil -- Если на пути луча ничего нет, цель видна
end

-- ========================================================
-- УМНЫЙ ВЫБОР ЦЕЛИ ДЛЯ АИМБОТА
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
				local targetRole = getPlayerRole(player)
				
				-- Проверяем дистанцию на экране (от центра экрана до игрока)
				local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen and isVisible(targetPart) then
					local screenSize = Camera.ViewportSize
					local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					
					-- Логика Шерифа: фокус только на живого Маньяка
					if localRole == "Sheriff" and targetRole == "Murderer" then
						return player
					end
					
					-- Логика Маньяка: сначала Шериф, потом мирные
					if localRole == "Murderer" then
						if targetRole == "Sheriff" then
							return player
						elseif targetRole == "Innocent" and distance < shortestDistance then
							shortestDistance = distance
							closestPlayer = player
						end
					end
					
					-- Логика Мирного: целимся в маньяка для защиты
					if localRole == "Innocent" and targetRole == "Murderer" and distance < shortestDistance then
						shortestDistance = distance
						closestPlayer = player
					end
				end
			end
		end
	end
	return closestPlayer
end

-- Слежка за тапами по экрану на мобилке
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		IsHoldingScreen = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		IsHoldingScreen = false
	end
end)

-- Плавный цикл наводки без тряски
RunService.RenderStepped:Connect(function()
	if AimbotEnabled and IsHoldingScreen and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local target = getBestTarget()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local targetPart = target.Character.HumanoidRootPart
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
			-- Сглаживание 0.12 (Камера плавно прилипает к корпусу)
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.12)
		end
	end
end)

-- ========================================================
-- СИСТЕМА ESP И ПОДСВЕТКА ОРУЖИЯ
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

-- Подсветка упавшей пушки
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
-- ИНТЕРФЕЙС GUI С СИНИМ ЧЕЛОВЕЧКОМ
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 190)
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
Title.Position = UDim2.new(0.06, 0, 0.08, 0)
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "FRUTIGER AERO HUB V6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 0.8
CloseBtn.Position = UDim2.new(0.85, 0, 0.08, 0)
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

local DeltaIcon = Instance.new("ImageButton")
DeltaIcon.Name = "AeroHumanIcon"
DeltaIcon.Image = "rbxassetid://9824248563" 
DeltaIcon.ImageColor3 = Color3.fromRGB(0, 180, 255)
DeltaIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
