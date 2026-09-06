-- FRUTIGER AERO MM2 HUB V19.1 (BLISS XP BACKGROUND)
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

-- ========================================================
-- ФУНКЦИОНАЛ (ТП, ФЛИНГ С ВОЗВРАТОМ, АИМ, ESP)
-- ========================================================
local function findDroppedGun()
	return Workspace:FindFirstChild("GunDrop", true)
end

local AWP_MESH_ID = "rbxassetid://430310237"
local AWP_TEXTURE_ID = "rbxassetid://430310255"

local function applyAwpSkin(tool)
	if not tool:IsA("Tool") then return end
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
				mesh.Scale = Vector3.new(0.08, 0.08, 0.08)
			end
		end
	end
end

local function monitorWeapons(char)
	char.ChildAdded:Connect(function(child)
		task.wait(0.2)
		applyAwpSkin(child)
	end)
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
		
		for i = 1, 15 do
			if tHrp and myHrp then myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0.1) end
			RunService.Heartbeat:Wait()
		end
		
		bV:Destroy()
		task.wait(0.1)
		myHrp.CFrame = oldCFrame
		AntiFlingEnabled = oldAntiFling
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
	if myHrp and droppedGun and droppedGun:IsA("BasePart") then myHrp.CFrame = droppedGun.CFrame * CFrame.new(0, 2, 0) end
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
		if droppedGun and droppedGun:IsA("BasePart") then
			local gunHl = droppedGun:FindFirstChild("GunHighlight")
			if EspEnabled and not gunHl then
				gunHl = Instance.new("Highlight")
				gunHl.Name = "GunHighlight"
				gunHl.OutlineColor = Color3.fromRGB(255, 215, 0)
				gunHl.Parent = droppedGun
			end
		end
	end
end)

-- ========================================================
-- ГЛЯНЦЕВОЕ ОКНО С ХОЛМАМИ WINDOWS XP (BLISS) На ФОНЕ
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 170, 0, 265)
MainPanel.Position = UDim2.new(0.02, 0, 0.15, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainPanel.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainPanel.BorderSizePixel = 2
MainPanel.Active = true
MainPanel.Draggable = true
MainFrame = MainPanel
MainPanel.ClipsDescendants = true
MainPanel.ZIndex = 1
MainPanel.Parent = ScreenGui
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

-- 🌄 НАЛОЖЕНИЕ ХОЛМОВ WINDOWS XP Bliss
local BlissBackground = Instance.new("ImageLabel", MainPanel)
BlissBackground.Name = "BlissBg"
BlissBackground.Size = UDim2.new(1, 0, 1, 0)
BlissBackground.Image = "rbxassetid://132148783" -- Официальный рабочий ID текстуры Bliss (XP Hills) в Roblox
BlissBackground.ImageTransparency = 0.45 -- Идеальный баланс, чтобы кнопки были сочными
BlissBackground.ScaleType = Enum.ScaleType.Crop
BlissBackground.ZIndex = 2 -- Под кнопками

-- Заголовок
local Label = Instance.new("TextLabel", MainPanel)
Label.Text = "AERO HUB BLISS"
Label.Size = UDim2.new(1, 0, 0, 25)
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Font = Enum.Font.GothamBold Label.TextSize = 11 Label.BackgroundTransparency = 1
Label.ZIndex = 4

local CloseBtn = Instance.new("TextButton", MainPanel)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(0.83, 0, 0.02, 0)
CloseBtn.Text = "X" CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold CloseBtn.TextSize = 11
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local DeltaIcon = Instance.new("ImageButton", ScreenGui)
DeltaIcon.Name = "AeroHumanIcon"
DeltaIcon.Image = "rbxassetid://9824248563" 
DeltaIcon.ImageColor3 = Color3.fromRGB(0, 180, 255)
DeltaIcon.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
DeltaIcon.Position = UDim2.new(0.02, 0, 0.45, 0)
DeltaIcon.Size = UDim2.new(0, 50, 0, 50)
DeltaIcon.ZIndex = 10
DeltaIcon.Visible = false
Instance.new("UICorner", DeltaIcon).CornerRadius = UDim.new(1, 0)

local function createSubButton(text, pos, color, callback)
	local btn = Instance.new("TextButton", MainPanel)
	btn.Size = UDim2.new(0, 146, 0, 28)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold btn.TextSize = 10
	btn.ZIndex = 5 -- Поверх картинок
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	
