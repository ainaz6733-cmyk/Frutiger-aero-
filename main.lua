-- FRUTIGER AERO MM2 HUB V13 (KAVO UI EDITION - 100% FIXED)
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
-- ВШИТАЯ БИБЛИОТЕКА KAVO UI (РАБОТАЕТ АВТОНОМНО)
-- ========================================================
local KavoLibrary = {}
function KavoLibrary:CreateMenu()
	local KavoGui = Instance.new("ScreenGui", CoreGui)
	KavoGui.Name = "DeltaMM2Hub"
	
	local Main = Instance.new("Frame", KavoGui)
	Main.Size = UDim2.new(0, 340, 0, 220)
	Main.Position = UDim2.new(0.3, 0, 0.25, 0)
	MainFrame = Main
	Main.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	Main.Active = true Main.Draggable = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	
	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1, 0, 0, 30)
	Top.BackgroundTransparency = 1
	
	local Line = Instance.new("Frame", Main)
	Line.Size = UDim2.new(1, 0, 0, 3)
	Line.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
	
	local Title = Instance.new("TextLabel", Top)
	Title.Text = "  FRUTIGER AERO HUB V13"
	Title.Size = UDim2.new(0.7, 0, 1, 0)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold Title.TextSize = 13 Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1
	
	local Close = Instance.new("TextButton", Top)
	Close.Text = "X" Close.Size = UDim2.new(0, 24, 0, 24) Close.Position = UDim2.new(0.9, 0, 0.1, 0)
	Close.BackgroundColor3 = Color3.fromRGB(40, 45, 50) Close.TextColor3 = Color3.fromRGB(255, 75, 75)
	Close.Font = Enum.Font.GothamBold Close.TextSize = 12 Instance.new("UICorner", Close)
	
	local TabsFrame = Instance.new("Frame", Main)
	TabsFrame.Size = UDim2.new(0, 90, 1, -35) TabsFrame.Position = UDim2.new(0, 5, 0, 32) TabsFrame.BackgroundTransparency = 1
	local TabsList = Instance.new("UIListLayout", TabsFrame) TabsList.Padding = UDim.new(0, 4)
	
	local PagesFrame = Instance.new("Frame", Main)
	PagesFrame.Size = UDim2.new(1, -105, 1, -40) PagesFrame.Position = UDim2.new(0, 100, 0, 35) PagesFrame.BackgroundTransparency = 1

	local DeltaIcon = Instance.new("ImageButton", KavoGui)
	DeltaIcon.Image = "rbxassetid://9824248563" DeltaIcon.ImageColor3 = Color3.fromRGB(0, 180, 255)
	DeltaIcon.BackgroundColor3 = Color3.fromRGB(15, 20, 25) DeltaIcon.BackgroundTransparency = 0.2
	DeltaIcon.Position = UDim2.new(0.02, 0, 0.45, 0) DeltaIcon.Size = UDim2.new(0, 50, 0, 50) DeltaIcon.Visible = false
	Instance.new("UICorner", DeltaIcon)

	Close.MouseButton1Click:Connect(function() Main.Visible = false DeltaIcon.Visible = true end)
	
