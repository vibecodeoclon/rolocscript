local P = game:GetService("Players").LocalPlayer
local UIS, RS = game:GetService("UserInputService"), game:GetService("RunService")
local speed, isFlying, bv, bg, conn = 50, false, nil, nil, nil

local gui = P:WaitForChild("PlayerGui"):FindFirstChild("FGui") or Instance.new("ScreenGui", P.PlayerGui)
gui.Name = "FGui"; gui.ResetOnSpawn = false

local mf = gui:FindFirstChild("MF") or Instance.new("Frame", gui)
mf.Name, mf.Size, mf.Position, mf.BackgroundColor3, mf.Active = "MF", UDim2.new(0,180,0,70), UDim2.new(1,-200,0,20), Color3.fromRGB(30,30,30), true

local tl = mf:FindFirstChild("TL") or Instance.new("TextLabel", mf)
tl.Name, tl.Size, tl.BackgroundColor3, tl.TextColor3, tl.Text, tl.Font, tl.TextSize = "TL", UDim2.new(1,0,0,30), Color3.fromRGB(40,40,40), Color3.new(1,1,1), " Tốc độ bay (Phím H):", Enum.Font.SourceSansBold, 14

local si = mf:FindFirstChild("SI") or Instance.new("TextBox", mf)
si.Name, si.Size, si.Position, si.BackgroundColor3, si.TextColor3, si.Text, si.Font, si.TextSize = "SI", UDim2.new(1,0,0,40), UDim2.new(0,0,0,30), Color3.fromRGB(50,50,50), Color3.new(1,1,1), "50", Enum.Font.SourceSansBold, 18

si:GetPropertyChangedSignal("Text"):Connect(function() speed = tonumber(si.Text) or speed end)

local drag, dragStart, startPos
mf.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag, dragStart, startPos = true, i.Position, mf.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        mf.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local function stopFlight()
    isFlying = false
    if conn then conn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    if P.Character and P.Character:FindFirstChild("Humanoid") then P.Character.Humanoid.PlatformStand = false end
end

UIS.InputBegan:Connect(function(i, p)
    if p or i.KeyCode ~= Enum.KeyCode.H then return end
    local char, root = P.Character, P.Character and P.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if isFlying then stopFlight() else
        isFlying, char.Humanoid.PlatformStand = true, true
        bv, bg = Instance.new("BodyVelocity", root), Instance.new("BodyGyro", root)
        bv.MaxForce, bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(math.huge, math.huge, math.huge)

        conn = RS.RenderStepped:Connect(function()
            if not char.Parent then stopFlight() return end
            local cam = workspace.CurrentCamera.CFrame
            
            local k = function(key) return UIS:IsKeyDown(key) and 1 or 0 end
            local move = (cam.LookVector * (k(Enum.KeyCode.W) - k(Enum.KeyCode.S)))
                       + (cam.RightVector * (k(Enum.KeyCode.D) - k(Enum.KeyCode.A)))
                       + (Vector3.new(0,1,0) * (k(Enum.KeyCode.Space) - k(Enum.KeyCode.LeftControl)))

            bv.Velocity, bg.CFrame = move * speed, cam
        end)
    end
end)

P.CharacterAdded:Connect(stopFlight)
