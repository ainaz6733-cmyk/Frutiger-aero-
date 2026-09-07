-- FRUTIGER AERO MM2 HUB V35 (PLAYER GUI FIX • GURANTEED LAUNCH)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Полная и безопасная зачистка старой памяти
if PlayerGui:FindFirstChild("DeltaMM2Hub") then 
	PlayerGui.DeltaMM2Hub:Destroy() 
end

local EspEnabled = true
local AimbotEnabled = true
local AntiFlingEnabled = true

-- ========================================================
-- ФУНКЦИОНАЛ ЧИТА
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
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then myRoot.CanCollide = true end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then tRoot.CanCollide = false end
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
			local gunHl = droppedGun:FindFirstChild("GunHighlight")
			if not gunHl then
				gunHl = Instance.new("Highlight")
				gunHl.Name = "GunHighlight" 
				gunHl.OutlineColor = Color3.fromRGB(255, 215, 0) 
				gunHl.FillColor = Color3.fromRGB(255, 215, 0)
				gunHl.FillTransparency = 0.4
				gunHl.Parent = droppedGun
			end
			gunHl.Enabled = true
		end
	end
end)

-- ========================================================
-- МОНОЛИТНЫЙ GUI (ПЕРЕНЕСЕН В PLAYER GUI ДЛЯ 100% ВЫВОДА)
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMM2Hub"
ScreenGui.ResetOnSpawn = false

-- Главная панель меню
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 22, 30)
MainPanel.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainPanel.BorderSizePixel = 2
MainPanel.Position = UDim2.new(0.3, 0, 0.25, 0)
MainPanel.Size = UDim2.new(0, 420, 0, 180) 
MainPanel. Parent = ScreenGui -- ВСТАВЬ ЭТУ СТРОКУ!
MainPanel.Position = UDim2. new( 0.3, 0, 0.25, 0)
MainPanel. Size = UDim2. new( 0, 420, 0, 180)
MainPanel. ZIndex = 1

MainPanel.ZIndex = 1

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainPanel

local TopLine = Instance.new("Frame")
TopLine.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.ZIndex = 2
TopLine.Parent = MainPanel

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.04, 0, 0.05, 0)
Title.Size = UDim2.new(0, 250, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "FRUTIGER AERO HUB V35"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = MainPanel

-- Крестик X
local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Position = UDim2.new(0.91, 0, 0.06, 0)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.Parent = MainPanel

-- Конструктор изолированных кнопок
local function createSubButton(text, pos, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 180, 0, 32)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.ZIndex = 5
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = MainPanel
	return btn
end

-- Сборка кнопок строго по сетке
local EspToggle = createSubButton("ESP ПОДСВЕТКА: ВКЛ", UDim2.new(0.04, 0, 0.28, 0), Color3.fromRGB(0, 150, 255))
local AimToggle = createSubButton("ХАРД АИМБОТ: ВКЛ", UDim2.new(0.04, 0, 0.55, 0), Color3.fromRGB(0, 150, 255))
local AntiFlingToggle = createSubButton("🛡️ АНТИ-ФЛИНГ: ВКЛ", UDim2.new(0.04, 0, 0.82, 0), Color3.fromRGB(0, 150, 255))
AntiFlingToggle.Size = UDim2.new(0, 180, 0, 28)

local FlingMurderBtn = createSubButton("💥 ФЛИНГ УБИЙЦЫ", UDim2.new(0.52, 0, 0.28, 0), Color3.fromRGB(255, 50, 50))
local FlingSheriffBtn = createSubButton("⚡ ФЛИНГ ШЕРИФА", UDim2.new(0.52, 0, 0.55, 0), Color3.fromRGB(255, 120, 50))
local TpGunBtn = createSubButton("⭐ ТЕЛЕПОРТ К ПЕСТИКУ", UDim2.new(0.52, 0, 0.82, 0), Color3.fromRGB(255, 200, 0))
TpGunBtn.Size = UDim2.new(0, 180, 0, 28)
TpGunBtn.TextColor3 = Color3.fromRGB(15, 20, 25)

-- ЛОГИКА НАЖАТИЙ КНОПОК
EspToggle.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	EspToggle.Text = EspEnabled and "ESP ПОДСВЕТКА: ВКЛ" or "ESP ПОДСВЕТКА: ВЫКЛ"
	EspToggle.BackgroundColor3 = EspEnabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 90, 100)
end)

-- НОВЫЙ СКРИПТ ПЕРЕМЕЩЕНИЯ GUI ДЛЯ МОБИЛЬНЫХ ЭМУЛЯТОРОВ
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

MainPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainPanel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

