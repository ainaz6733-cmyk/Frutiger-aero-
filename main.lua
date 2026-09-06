-- FRUTIGER AERO MM2 HUB V16 (SYSTEM CORE GUI EDITION)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Полная очистка прошлых багнутых версий интерфейса
if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true
local AimbotEnabled = true
local AntiFlingEnabled = true
local Highlights = {}

-- ========================================================
-- ФУНКЦИОНАЛ (АНТИ-ФЛИНГ, ТП, ФЛИНГ, АИМ, ESP)
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
-- АБСОЛЮТНО НОВЫЙ ИНТЕРФЕЙС ИЗ ОФИЦИАЛЬНЫХ КНОПОК РОБЛОКСА
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Функция для быстрого создания неубиваемых системных кнопок
local function createSystemButton(text, pos, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 140, 0, 32)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.ZIndex = 10
	btn.Active = true
	btn.Parent = ScreenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Расставляем кнопки аккуратными парами на экране (они 100% прогрузятся!)
local EspBtn = createSystemButton("ESP: ВКЛ", UDim2.new(0.02, 0, 0.15, 0), Color3.fromRGB(0, 150, 255), function()
	EspEnabled = not EspEnabled
	_G.EspBtn.Text = EspEnabled and "ESP: ВКЛ" or "ESP: ВЫКЛ"
	_G.EspBtn.BackgroundColor3 = EspEnabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 90, 100)
end)
_G.EspBtn = EspBtn

local AimBtn = createSystemButton("АИМБОТ: ВКЛ", UDim2.new(0.02, 0, 0.22, 0), Color3.fromRGB(0, 150, 255), function()
	AimbotEnabled = not AimbotEnabled
	_G.AimBtn.Text = AimbotEnabled and "АИМБОТ: ВКЛ" or "АИМБОТ: ВЫКЛ"
	_G.AimBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 90, 100)
end)
_G.AimBtn = AimBtn

createSystemButton("💥 ФЛИНГ МАНЬЯКА", UDim2.new(0.02, 0, 0.29, 0), Color3.fromRGB(255, 50, 50), function()
	flingRole("Murderer")
end)

createSystemButton("⚡ ФЛИНГ ШЕРИФА", UDim2.new(0.02, 0, 0.36, 0), Color3.fromRGB(255, 120, 50), function()
	flingRole("Sheriff")
end)

createSystemButton("⭐ ТП К ПЕСТИКУ", UDim2.new(0.02, 0, 0.43, 0), Color3.fromRGB(255, 200, 0), function()
	teleportToGun()
end)
