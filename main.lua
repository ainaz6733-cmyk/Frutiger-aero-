-- FRUTIGER AERO MM2 HUB V22.1 (TEXT GUI - 100% FIXED)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Полная очистка прошлых зависших версий
if CoreGui:FindFirstChild("DeltaMM2Hub") then
	CoreGui.DeltaMM2Hub:Destroy()
end

local EspEnabled = true
local AimbotEnabled = true
local AntiFlingEnabled = true

-- ========================================================
-- ФУНКЦИОНАЛ ЧИТА (ВСЕ РАБОЧИЕ ИСПРАВЛЕННЫЕ СКРИПТЫ)
-- ========================================================
local function findDroppedGun()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "GunDrop" and obj:IsA("BasePart") then 
			return obj
		elseif obj.Name == "Gun" and obj:IsA("Model") and obj:FindFirstChild("Handle") then 
			return obj:FindFirstChild("Handle") 
		end
	end
	return nil
end

local AWP_MESH_ID = "rbxassetid://430310237"
local AWP_TEXTURE_ID = "rbxassetid://430310255"

local function applyAwpSkin(tool)
	if not tool or not tool:IsA("Tool") then return end
	if tool.Name == "Gun" or tool:FindFirstChild("GunCmd") or tool:FindFirstChild("GunServer") then
		local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("MeshPart") or tool:FindFirstChildOfClass("SpecialMesh")
		if handle then
			if handle:IsA("MeshPart") then 
				handle.MeshId = AWP_MESH_ID 
				handle.TextureID = AWP_TEXTURE_ID
			elseif handle:IsA("SpecialMesh") then 
				handle.MeshId = AWP_MESH_ID 
				handle.TextureId = AWP_TEXTURE_ID
			else
				local mesh = handle:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", handle)
				mesh.MeshId = AWP_MESH_ID 
				mesh.TextureId = AWP_TEXTURE_ID 
				mesh.Scale = Vector3.new(0.07, 0.07, 0.07)
			end
		end
	end
end

local function monitorWeapons(char)
	char.ChildAdded:Connect(function(child) task.wait(0.3) applyAwpSkin(child) end)
end
if LocalPlayer.Character then monitorWeapons(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(monitorWeapons)

task.spawn(function()
	while task.wait(1) do
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if bp then 
			for _, tool in ipairs(bp:GetChildren()) do applyAwpSkin(tool) end 
		end
	end
end)

local function flingTarget(targetPlayer)
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	local tHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if myHrp and tHrp then
		local oldCFrame = myHrp.CFrame
		local oldAntiFling = AntiFlingEnabled
		AntiFlingEnabled = false
		local bV = Instance.new("BodyAngularVelocity")
		bV.MaxTorque = Vector3.new(1, 1, 1) * math.huge 
		bV.AngularVelocity = Vector3.new(0, 99999, 0) 
		bV.Parent = myHrp
		for i = 1, 12 do 
			if tHrp and myHrp then myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0.1) end 
			RunService.Heartbeat:Wait() 
		end
		bV:Destroy() 
		task.wait(0.05) 
		myHrp.CFrame = oldCFrame 
		AntiFlingEnabled = oldAntiFling
	end
end

local function flingRole(roleName)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local bp = player:FindFirstChild("Backpack")
			local char = player.Character
			if roleName == "Murderer" and ((bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))) then 
				flingTarget(player) return
			elseif roleName == "Sheriff" and ((bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))) then 
				flingTarget(player) return 
			end
		end
	end
end

RunService.Stepped:Connect(function()
	if AntiFlingEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in ipairs(player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
			end
		end
	end
end)

local function teleportToGun()
	local char = LocalPlayer.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	local droppedGun = findDroppedGun()
	if myHrp and droppedGun then myHrp.CFrame = droppedGun.CFrame * CFrame.new(0, 2, 0) end
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
		local droppedGun = findDroppedGun()
		if droppedGun and EspEnabled then
			local gunHl = droppedGun:FindFirstChild("GunHighlight") or Instance.new("Highlight", droppedGun)
			gunHl.Name = "GunHighlight" gunHl.OutlineColor = Color3.fromRGB(255, 215, 0) gunHl.Enabled = true
		end
	end
end)

-- ========================================================
-- НЕУБИВАЕМЫЙ ТЕКСТОВЫЙ GUI ИНТЕРФЕЙС (100% ФИКС ЗАПУСКА)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Базовый контейнер для списка (полностью прозрачный)
local MenuHolder = Instance.new("Frame")
MenuHolder.Name = "MenuHolder"
MenuHolder.Size = UDim2.new(0, 180, 0, 240)
MenuHolder.Position = UDim2.new(0.02, 0, 0.15, 0)
MenuHolder.BackgroundTransparency = 1
MenuHolder.Parent = ScreenGui

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)
UIList.Parent = MenuHolder

-- Круглая кнопка Дельты для раскрытия меню
local OpenLabel = Instance.new("TextButton")
OpenLabel.Size = UDim2.new(0, 45, 0, 45)
OpenLabel.Position = UDim2.new(0.02, 0, 0.45, 0)
OpenLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
OpenLabel.Text = "[ Δ ]"
OpenLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
OpenLabel.Font = Enum.Font.GothamBold
OpenLabel.TextSize = 14
OpenLabel.Visible = false
OpenLabel.Parent = ScreenGui
Instance.new("UICorner", OpenLabel).CornerRadius = UDim.new(1, 0)

-- Функция создания надежных текстовых кнопок
local function createTextButton(text, color, order, callback)
	local label = Instance.new("TextButton")
	label.Size = UDim2.new(0, 175, 0, 30)
	label.BackgroundColor3 = color
	label.BackgroundTransparency = 0.2 -- Глянцевое стекло Frutiger
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.LayoutOrder = order
	label.Parent = MenuHolder
	
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
	
	label.MouseButton1Click:Connect(function()
		callback(label)
	end)
	return label
end

-- Создаем кнопки с исправленным синтаксисом (теперь без ошибок)
local CloseToggle = createTextButton("[ ❌ ЗАКРЫТЬ МЕНЮ ]", Color3.fromRGB(255, 50, 50), 1, function()
	MenuHolder.Visible = false
	OpenLabel.Visible = true
end)

local EspToggle = createTextButton("🔵 ESP ПОДСВЕТКА: ВКЛ", Color3.fromRGB(0, 150, 255), 2, function(self)
	EspEnabled = not EspEnabled
	self.Text = EspEnabled and "🔵 ESP ПОДСВЕТКА: ВКЛ" or "⚪ ESP ПОДСВЕТКА: ВЫКЛ"
	self.BackgroundColor3 = EspEnabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(70, 80, 90)
end)

local AimToggle = createTextButton("🔵 ХАРД АИМБОТ: ВКЛ", Color3.fromRGB(0, 150, 255), 3, function(self)
	AimbotEnabled = not AimbotEnabled
	self.Text = AimbotEnabled and "🔵 ХАРД АИМБОТ: ВКЛ" or "⚪ ХАРД АИМБОТ: ВЫКЛ"
		
