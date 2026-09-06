-- FRUTIGER AERO MM2 HUB V14 (LIGHTWEIGHT KAVO VERSION)
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
local AntiFlingEnabled = true
local Highlights = {}

-- Подгружаем Kavo UI из быстрого внешнего источника (всего одна строка!)
local KavoLibrary = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- Создаем меню (Frutiger Aero стиль — Aqua тема)
local Window = KavoLibrary.CreateLib("FRUTIGER AERO HUB V14", "Aqua")

-- СОЗДАЕМ РАЗДЕЛЫ (ВКЛАДКИ СЛЕВА)
local Tab1 = Window:NewTab("Главная")
local Tab2 = Window:NewTab("Бой (Fling)")
local Tab3 = Window:NewTab("Телепорты")

-- Создаем секции внутри вкладок
local Section1 = Tab1:NewSection("Основные функции")
local Section2 = Tab2:NewSection("Физика уничтожения")
local Section3 = Tab3:NewSection("Перемещение")

-- ========================================================
-- ЛОГИКА ФУНКЦИЙ (АНТИ-ФЛИНГ, ТП, ФЛИНГ, АИМ, ESP)
-- ========================================================
RunService.Stepped:Connect(function()
	if AntiFlingEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in ipairs(player.Character:GetChildren()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end
	end
end)

local function teleportToRole(roleName)
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local bp = player:FindFirstChild("Backpack")
			local pChar = player.Character
			local isTarget = false
			if roleName == "Murderer" and ((bp and bp:FindFirstChild("Knife")) or (pChar and pChar:FindFirstChild("Knife"))) then isTarget = true
			elseif roleName == "Sheriff" and ((bp and bp:FindFirstChild("Gun")) or (pChar and pChar:FindFirstChild("Gun"))) then isTarget = true end
			if isTarget then myHrp.CFrame = pChar.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) return end
		end
	end
end

local function teleportToGun()
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	local droppedGun = Workspace:FindFirstChild("GunDrop")
	if myHrp and droppedGun and droppedGun:IsA("BasePart") then myHrp.CFrame = droppedGun.CFrame * CFrame.new(0, 2, 0) end
end

local function flingTarget(targetPlayer)
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	local tChar = targetPlayer and targetPlayer.Character
	local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if myHrp and tHrp then
		local oldCFrame = myHrp.CFrame
		local oldAntiFling = AntiFlingEnabled
		AntiFlingEnabled = false
		local bV = Instance.new("BodyAngularVelocity")
		bV.MaxTorque = Vector3.new(1, 1, 1) * math.huge
		bV.AngularVelocity = Vector3.new(0, 99999, 0)
		bV.Parent = myHrp
		for i = 1, 25 do if tHrp and myHrp then myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0.3) end RunService.Heartbeat:Wait() end
		bV:Destroy() myHrp.CFrame = oldCFrame AntiFlingEnabled = oldAntiFling
	end
end

local function flingRole(roleName)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local bp = player:FindFirstChild("Backpack")
			local char = player.Character
			if roleName == "Murderer" and ((bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))) then flingTarget(player) return
			elseif roleName == "Sheriff" and ((bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))) then flingTarget(player) return end
		end
	end
end

local function getPlayerRole(player)
	if not player or not player.Character then return "Innocent" end
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then return "Murderer" end
	if (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then return "Sheriff" end
	return "Innocent"
end

local function getRoleColor(player)
	local role = getPlayerRole(player)
	if role == "Murderer" then return Color3.fromRGB(255, 0, 50) end
	if role == "Sheriff" then return Color3.fromRGB(0, 100, 255) end
	return Color3.fromRGB(0, 255, 100)
end

local function getBestTarget()
	local localRole = getPlayerRole(LocalPlayer)
	local closestPlayer = nil
	local shortestDistance = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local targetPart = player.Character.HumanoidRootPart
				local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
				local targetRole = getPlayerRole(player)
				if localRole == "Sheriff" and targetRole == "Murderer" then return player
				elseif localRole == "Murderer" and targetRole == "Sheriff" then return player
				elseif targetRole == "Murderer" and distance < shortestDistance then shortestDistance = distance closestPlayer = player end
			end
		end
	end
	return closestPlayer
end

RunService.RenderStepped:Connect(function()
	if AimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local target = getBestTarget()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
		end
	end
end)

local function updatePlayerESP(player)
	if player == LocalPlayer or not player.Character then return end
	local char = player.Character
	local gunInHand = char:FindFirstChild("Gun")
	if gunInHand and not gunInHand:FindFirstChild("GunGlow") then
		local glow = Instance.new("BoxHandleAdornment")
		glow.Name = "GunGlow"
		glow.Size = Vector3.new(1.2, 2.2, 1.2)
		glow.Color3 = Color3.fromRGB(0, 150, 255)
		glow.AlwaysOnTop = true
		glow.Adornee = gunInHand:FindFirstChild("Handle") or gunInHand
		glow.Parent = gunInHand
	end
	local hl = char:FindFirstChild("DeltaHighlight")
	if not hl and EspEnabled then
		hl = Instance.new("Highlight")
		hl.Name = "DeltaHighlight"
		hl.Parent = char
	end
	if hl then
		hl.Enabled = EspEnabled
		local color = getRoleColor(player)
		hl.OutlineColor = color
		hl.FillColor = color
	end
end

task.spawn(function()
	while task.wait(1) do
		for _, player in ipairs(Players:GetPlayers()) do updatePlayerESP(player) end
		local droppedGun = Workspace:FindFirstChild("GunDrop")
		if droppedGun and droppedGun:IsA("BasePart") then
			local gunHl = droppedGun:FindFirstChild("GunHighlight")
			if EspEnabled then
				if not gunHl then
					gunHl = Instance.new("Highlight")
					gunHl.Name = "GunHighlight"
					gunHl.OutlineColor = Color3.fromRGB(255, 215, 0)
					gunHl.Parent = droppedGun
					local billboard = Instance.new("BillboardGui")
					billboard.Name = "GunArrow"
					billboard.Size = UDim2.new(0, 60, 0, 60)
					billboard.AlwaysOnTop = true
					billboard.StudsOffset = Vector3.new(0, 3, 0)
					local text = Instance.new("TextLabel")
					text.Size = UDim2.new(1, 0, 1, 0)
					text.Text = "⬇ ПЕСТИК ТУТ! ⬇"
					text.TextColor3 = Color3.fromRGB(255, 215, 0)
					text.Font = Enum.Font.GothamBold
					text.TextSize = 14
					text.BackgroundTransparency = 1
					text.Parent = billboard
					billboard.Parent = droppedGun
				end
			end
		end
	end
end)

-- ========================================================
-- НАПОЛНЕНИЕ КНОПКАМИ СЕКЦИЙ ИНТЕРФЕЙСА
-- ========================================================
Section1:NewToggle("ESP Подсветка Ролей", "Включает силуэты сквозь стены", function(state)
	EspEnabled = state
	for _, p in ipairs(Players:GetPlayers()) do updatePlayerESP(p) end
end)

Section1:NewToggle("Хард Аимбот (Shift Lock)", "Автоприцел от 1-го лица", function(state)
	AimbotEnabled = state
end)

Section1:NewToggle("Защита от флинга (Anti-Fling)", "Игнорирует чужой флинг", function(state)
	AntiFlingEnabled = state
end)

Section2:NewButton("💥 Флинг Убийцы", "Уничтожить маньяка раунда", function()
	flingRole("Murderer")
end)

Section2:NewButton("⚡ Флинг Шерифа", "Выбить пистолет из рук шерифа", function()
	flingRole("Sheriff")
end)

Section3:NewButton("⭐ Телепорт к Пестику", "Переместиться к пушке на полу", function()
	teleportToGun()
end)

Section3:NewButton("👣 Телепорт к Маньяку", "Прыгнуть за спину к убийце", function()
	teleportToRole("Murderer")
end)
