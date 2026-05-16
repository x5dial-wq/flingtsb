-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
local MainPanel = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local PlayerList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TeleportButton = Instance.new("TextButton")

-- Floating Toggle Button Components
local ToggleButton = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")

-- Safe Parent Injection
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
local targetParent = success and coreGui or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
ScreenGui.Parent = targetParent
ScreenGui.ResetOnSpawn = false

-- Theme Configurations
local BG_DARK = Color3.fromRGB(24, 24, 24)
local HEADER_DARK = Color3.fromRGB(18, 18, 18)
local BUTTON_GREEN = Color3.fromRGB(46, 154, 56)
local LIST_ITEM_DARK = Color3.fromRGB(34, 34, 34)
local LIST_ITEM_SELECTED = Color3.fromRGB(45, 45, 45)

-- ==========================================
-- FLOATING TOGGLE BUTTON (Mobile Friendly)
-- ==========================================
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = HEADER_DARK
ToggleButton.BorderSizePixel = 0
-- Positioned safely on the left side of the screen, adjustable by dragging if needed
ToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "TG"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Active = true
ToggleButton.Draggable = true -- Allows mobile users to move the toggle button anywhere

ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Main Panel Window Layout
MainPanel.Name = "MainPanel"
MainPanel.Parent = ScreenGui
MainPanel.BackgroundColor3 = BG_DARK
MainPanel.BorderSizePixel = 0
MainPanel.Position = UDim2.new(0.5, -125, 0.5, -150)
MainPanel.Size = UDim2.new(0, 250, 0, 300)
MainPanel.Active = true
MainPanel.Draggable = true

-- Header Title
Title.Name = "Title"
Title.Parent = MainPanel
Title.BackgroundColor3 = HEADER_DARK
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Player Teleport GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

-- Scrollable Player List Area
PlayerList.Name = "PlayerList"
PlayerList.Parent = MainPanel
PlayerList.BackgroundTransparency = 1
PlayerList.BorderSizePixel = 0
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.Size = UDim2.new(1, -10, 1, -80)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 8
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)

UIListLayout.Parent = PlayerList
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 2)

-- Dynamic Teleport Bottom Button
TeleportButton.Name = "TeleportButton"
TeleportButton.Parent = MainPanel
TeleportButton.BackgroundColor3 = BUTTON_GREEN
TeleportButton.BorderSizePixel = 0
TeleportButton.Position = UDim2.new(0, 5, 1, -40)
TeleportButton.Size = UDim2.new(1, -10, 0, 35)
TeleportButton.Font = Enum.Font.SourceSansBold
TeleportButton.Text = "Select a player"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextSize = 15

-- State variables
local selectedPlayer = nil
local listButtons = {}

-- Hide / Unhide Logic Connected to the Toggle Button
ToggleButton.MouseButton1Click:Connect(function()
	MainPanel.Visible = not MainPanel.Visible
end)

-- Function to update the bottom green action button state
local function updateButtonText()
	if selectedPlayer then
		TeleportButton.Text = "Teleport to: " .. selectedPlayer.Name
	else
		TeleportButton.Text = "Select a player"
	end
end

-- Refresh and build the active player list buttons
local function refreshPlayerList()
	for _, btn in pairs(listButtons) do
		btn:Destroy()
	end
	listButtons = {}

	local players = game:GetService("Players"):GetPlayers()
	local localPlayer = game:GetService("Players").LocalPlayer

	for _, player in ipairs(players) do
		if player ~= localPlayer then
			local pBtn = Instance.new("TextButton")
			pBtn.Name = player.Name
			pBtn.Parent = PlayerList
			pBtn.BackgroundColor3 = (selectedPlayer == player) and LIST_ITEM_SELECTED or LIST_ITEM_DARK
			pBtn.BorderSizePixel = 0
			pBtn.Size = UDim2.new(1, 0, 0, 30)
			pBtn.Font = Enum.Font.SourceSans
			pBtn.Text = player.Name
			pBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			pBtn.TextSize = 14
			
			pBtn.MouseButton1Click:Connect(function()
				selectedPlayer = player
				updateButtonText()
				refreshPlayerList()
			end)
			
			table.insert(listButtons, pBtn)
		end
	end
	
	PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

game:GetService("Players").PlayerAdded:Connect(refreshPlayerList)
game:GetService("Players").PlayerRemoving:Connect(function(player)
	if selectedPlayer == player then
		selectedPlayer = nil
		updateButtonText()
	end
	refreshPlayerList()
end)

-- Teleport Logic Execution 
local function executeGoto(targetPlayer)
	local localPlayer = game:GetService("Players").LocalPlayer
	if targetPlayer and targetPlayer.Character and localPlayer.Character then
		local myRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		local myHumanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		
		if myRoot and targetRoot and myHumanoid then
			myHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
			-- Teleports exactly 2 studs to the left relative to their current orientation
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(-2, 0, 0)
		end
	end
end

-- Bind the UI button click to the execution logic block
TeleportButton.MouseButton1Click:Connect(function()
	if selectedPlayer then
		executeGoto(selectedPlayer)
	end
end)

-- Initialize visual state layout
refreshPlayerList()
