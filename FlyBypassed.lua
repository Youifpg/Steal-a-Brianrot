local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local FLYING = false
local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
local lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
local SPEED = 0
local iyflyspeed = 1
local vfly = false
local QEfly = true
local flyKeyDown, flyKeyUp

local function getRoot(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function sFLY()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = getRoot(char)
    local BG = Instance.new('BodyGyro')
    local BV = Instance.new('BodyVelocity')
    BG.P = 9e4
    BG.Parent = root
    BV.Parent = root
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.cframe = root.CFrame
    BV.velocity = Vector3.new(0,0,0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

    FLYING = true

    flyKeyDown = mouse.KeyDown:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = iyflyspeed
        elseif KEY:lower() == 's' then CONTROL.B = -iyflyspeed
        elseif KEY:lower() == 'a' then CONTROL.L = -iyflyspeed
        elseif KEY:lower() == 'd' then CONTROL.R = iyflyspeed
        elseif QEfly and KEY:lower() == 'e' then CONTROL.Q = iyflyspeed*2
        elseif QEfly and KEY:lower() == 'q' then CONTROL.E = -iyflyspeed*2 end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)

    flyKeyUp = mouse.KeyUp:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = 0
        elseif KEY:lower() == 's' then CONTROL.B = 0
        elseif KEY:lower() == 'a' then CONTROL.L = 0
        elseif KEY:lower() == 'd' then CONTROL.R = 0
        elseif KEY:lower() == 'e' then CONTROL.Q = 0
        elseif KEY:lower() == 'q' then CONTROL.E = 0 end
    end)

    task.spawn(function()
        repeat task.wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = true end
            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                SPEED = 50
            else
                SPEED = 0
            end
            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                BV.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E)*0.2, 0).p) - workspace.CurrentCamera.CFrame.p)) * SPEED
                lCONTROL = {F=CONTROL.F, B=CONTROL.B, L=CONTROL.L, R=CONTROL.R}
            elseif SPEED ~= 0 then
                BV.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E)*0.2, 0).p) - workspace.CurrentCamera.CFrame.p)) * SPEED
            else
                BV.velocity = Vector3.new(0,0,0)
            end
            BG.cframe = workspace.CurrentCamera.CFrame
        until not FLYING
        CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
        lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
        SPEED = 0
        BG:Destroy()
        BV:Destroy()
        if humanoid then humanoid.PlatformStand = false end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
    end)
end

local velocityHandlerName = "FlyVelocity"
local gyroHandlerName = "FlyGyro"
local mfly1, mfly2

local function unmobilefly(speaker)
    pcall(function()
        FLYING = false
        local root = getRoot(speaker.Character)
        if root:FindFirstChild(velocityHandlerName) then root[velocityHandlerName]:Destroy() end
        if root:FindFirstChild(gyroHandlerName) then root[gyroHandlerName]:Destroy() end
        local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        if mfly1 then mfly1:Disconnect() end
        if mfly2 then mfly2:Disconnect() end
    end)
end

local function mobilefly(speaker)
    unmobilefly(speaker)
    FLYING = true
    local root = getRoot(speaker.Character)
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3zero = Vector3.new(0,0,0)
    local v3inf = Vector3.new(9e9,9e9,9e9)
    local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero
    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50
    mfly1 = speaker.CharacterAdded:Connect(function()
        local root = getRoot(speaker.Character)
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3zero
        bv.Velocity = v3zero
        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50
    end)
    mfly2 = RunService.RenderStepped:Connect(function()
        root = getRoot(speaker.Character)
        camera = workspace.CurrentCamera
        local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local VelocityHandler = root[velocityHandlerName]
            local GyroHandler = root[gyroHandlerName]
            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            if not vfly then humanoid.PlatformStand = true end
            GyroHandler.CFrame = camera.CFrame
            VelocityHandler.Velocity = v3none
            local direction = controlModule:GetMoveVector()
            if direction.X ~= 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * iyflyspeed * 50)
            end
            if direction.Z ~= 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * iyflyspeed * 50)
            end
        end
    end)
end

local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false

local flyButton = Instance.new("TextButton", screenGui)
flyButton.Size = UDim2.new(0, 150, 0, 50)
flyButton.Position = UDim2.new(0.5, -75, 0.5, -25)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 20
flyButton.Text = "FLY : OFF"
flyButton.Name = "FlyToggleButton"

local uicorner = Instance.new("UICorner", flyButton)
uicorner.CornerRadius = UDim.new(0, 12)

local uistroke = Instance.new("UIStroke", flyButton)
uistroke.Thickness = 2
uistroke.Color = Color3.new(0, 0, 0)

local dragging = false
local dragInput, dragStart, startPos

flyButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = flyButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

flyButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		flyButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

flyButton.MouseButton1Click:Connect(function()
	if not FLYING then
		if not IsOnMobile then
			sFLY()
		else
			mobilefly(player)
		end
		FLYING = true
		flyButton.Text = "FLY : ON"
	else
		if not IsOnMobile then
			NOFLY()
		else
			unmobilefly(player)
		end
		FLYING = false
		flyButton.Text = "FLY : OFF"
	end
end)
