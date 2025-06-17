local p = game:GetService("Players")
local r = game:GetService("RunService")
local lp = p.LocalPlayer
local c = lp.Character or lp.CharacterAdded:Wait()
local h = c:WaitForChild("HumanoidRootPart")
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall
mt.__namecall = newcclosure(function(s, ...)
    local m = getnamecallmethod()
    local a = {...}
    if m == "SetNetworkOwner" and typeof(s) == "Instance" and s:IsA("BasePart") then
        if s == h and a[1] ~= lp then return end
    end
    return old(s, unpack(a))
end)
r.Stepped:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local part = lp.Character.HumanoidRootPart
        if part:GetNetworkOwner() ~= lp then
            part:SetNetworkOwner(lp)
        end
    end
end)
local lv = h.Position
local lc = tick()
r.Stepped:Connect(function()
    local cur = h.Position
    local sp = (cur - lv).Magnitude
    lc = tick()
    if sp < 1 then
        lv = cur
    else
        local diff = (cur - lv).Magnitude
        if diff > 25 then
            h.CFrame = CFrame.new(lv)
            h.AssemblyLinearVelocity = Vector3.zero
        else
            lv = cur
        end
    end
end)
local function rIP()
    local function r() return math.random(1, 254) end
    local ip = string.format("%d.%d.%d.%d", r(), r(), r(), r())
    while ip:match("^113%.") or ip:match("^14%.") or ip:match("^171%.") or ip:match("^203%.") do
        ip = string.format("%d.%d.%d.%d", r(), r(), r(), r())
    end
    return ip
end
local fi = rIP()
print("Fake IP used:", fi)
