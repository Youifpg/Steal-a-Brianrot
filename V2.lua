-- not mine

-- Ambil Player dan PlayerGui
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variabel
local isRunning = false
local cancelFlag = false

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PadatGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Frame utama (diperkecil sedikit)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 160, 0, 100) -- ↓ Ukuran lebih kecil
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- UI Style
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.2

local padding = Instance.new("UIPadding", mainFrame)
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingLeft = UDim.new(0, 6)
padding.PaddingRight = UDim.new(0, 6)

local layout = Instance.new("UIListLayout", mainFrame)
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Ready"
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

-- Tombol Steal
local stealButton = Instance.new("TextButton")
stealButton.Size = UDim2.new(1, 0, 0, 26)
stealButton.BackgroundColor3 = Color3.fromRGB( 17, 144, 210)
stealButton.Font = Enum.Font.GothamBold
stealButton.TextSize = 12
stealButton.TextColor3 = Color3.new(1, 1, 1)
stealButton.Text = "Click Steal"
stealButton.Parent = mainFrame
Instance.new("UICorner", stealButton).CornerRadius = UDim.new(0, 6)

-- Tombol Reset
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(1, 0, 0, 22)
resetButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 12
resetButton.TextColor3 = Color3.new(1, 1, 1)
resetButton.Text = "Refresh"
resetButton.Parent = mainFrame
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 6)

-- Fungsi utama
local function fireTouch()
	if isRunning then return end
	isRunning = true
	cancelFlag = false
	stealButton.Text = "Processing..."
	stealButton.AutoButtonColor = false
	stealButton.BackgroundTransparency = 0.5
	stealButton.Active = false
	resetButton.Active = true

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		statusLabel.Text = "HRP not found"
		isRunning = false
		stealButton.Text = "Click Steal"
		stealButton.BackgroundTransparency = 0
		stealButton.AutoButtonColor = true
		stealButton.Active = true
		return
	end

	for i = 1, 20 do
		if cancelFlag then
			statusLabel.Text = "successfully Refresh"
			break
		end
		statusLabel.Text = "waiting " .. tostring(math.floor((2 - (i - 1) * 0.1) * 10) / 10) .. "s"
		task.wait(0.1)
	end

	if not cancelFlag then
		for i = 1, 20 do
			if cancelFlag then
				statusLabel.Text = "successfully Refresh"
				break
			end
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == "DeliveryHitbox" then
					pcall(function()
						firetouchinterest(hrp, obj, 0)
						task.wait(0.13)
						firetouchinterest(hrp, obj, 1)
					end)
				end
			end
		end
	end

	if cancelFlag then
		statusLabel.Text = "successfully Refresh"
	else
		statusLabel.Text = "Ready"
	end

	isRunning = false
	stealButton.Text = "Click Steal"
	stealButton.BackgroundTransparency = 0
	stealButton.AutoButtonColor = true
	stealButton.Active = true
end

-- Event tombol
stealButton.MouseButton1Click:Connect(fireTouch)
resetButton.MouseButton1Click:Connect(function()
	if isRunning then
		cancelFlag = true
	else
		statusLabel.Text = "not found" 
	end
end)
