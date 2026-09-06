-- FRUTIGER AERO MM2 HUB V11 (ESP + HARD AIM + FLING + TP + ANTI-FLING)
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
local AntiFlingEnabled = true -- По умолчанию защита ВКЛЮЧЕНА
local Highlights = {}

-- ========================================================
-- СИСТЕМА АНТИ-ФЛИНГА (ANTI-FLING PROTECTION)
-- ========================================================
-- Отключает физическое столкновение с другими персонажами, чтобы тебя не флинганули
RunService.Stepped:Connect(function()
	if AntiFlingEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = true -- Твоё тело стоит прочно
			end
		end
		
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in ipairs(player.Character:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = false -- Чужие персонажи проходят сквозь тебя
					end
				end
			end
		end
	end
end)

-- ========================================================
-- ФУНКЦИИ ТЕЛЕПОРТА
-- ========================================================
local function teleportToRole(roleName)
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local bp = player:FindFirstChild("Backpack")
			local pChar = player.Character
			local isTarget = false
			
			if roleName == "Murderer" and ((bp and bp:FindFirstChild("Knife")) or (pChar and pChar:FindFirstChild("Knife"))) then
				isTarget = true
			elseif roleName == "Sheriff" and ((bp and bp:FindFirstChild("Gun")) or (pChar and pChar:FindFirstChild("Gun"))) then
				isTarget = true
			end
			
			if isTarget then
				myHrp.CFrame = pChar.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
				return
			end
		end
	end
end

local function teleportToGun()
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	local droppedGun = Workspace:FindFirstChild("GunDrop")
	
	if myHrp and droppedGun and droppedGun:IsA("BasePart") then
		myHrp.CFrame = droppedGun.CFrame * CFrame.new(0, 2, 0)
	end
end

-- ========================================================
-- МОЩНЫЙ ФЛИНГ (FLING SYSTEM)
-- ========================================================
local function flingTarget(targetPlayer)
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	local tChar = targetPlayer and targetPlayer.Character
	local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
	
	if myHrp and tHrp then
		local oldCFrame = myHrp.CFrame
		
		-- Временно выключаем анти-флинг для себя, чтобы физика сработала на врага
		local oldAntiFling = AntiFlingEnabled
		AntiFlingEnabled = false
		
		local bV = Instance.new("BodyAngularVelocity")
		bV.MaxTorque = Vector3.new(1, 1, 1) * math.huge
		bV.AngularVelocity = Vector3.new(0, 99999, 0)
		bV.Parent = myHrp
		
		for i = 1, 25 do
			if tHrp and myHrp then
				myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0.3)
			end
			RunService.Heartbeat:Wait()
		end
		
		bV:Destroy()
		myHrp.CFrame = oldCFrame
		AntiFlingEnabled = oldAntiFling -- Возвращаем защиту
	end
end

local function flingRole(roleName)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local bp = player:FindFirstChild("Backpack")
			local char = player.Character
			
			if roleName == "Murderer" and ((bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))) then
				flingTarget(player)
				return
			elseif roleName == "Sheriff" and ((bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))) then
				flingTarget(player)
				return
			end
		end
	end
end

-- ========================================================
-- ОПРЕДЕЛЕНИЕ РОЛЕЙ И ЖЕСТКИЙ АИМ (ИЗ V9)
-- ========================================================
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
				elseif targetRole == "Murderer" and distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
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

-- ========================================================
-- ПОДСВЕТКА ИГРОКОВ И УПАВШЕГО ПИСТОЛЕТА
-- ========================================================
local function updatePlayerESP(player)
	if player == LocalPlayer or not player.Character then return end
	local char = player.Character
	
	-- Подсветка пестика в руках живого Шерифа (Синий неон)
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
-- НОВЫЙ GUI ИНТЕРФЕЙС V11 (МАКСИМАЛЬНЫЙ)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 340) -- Ещё больше места под новые кнопки
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

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.06, 0, 0.04, 0)
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "FRUTIGER AERO HUB V11"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 50)
