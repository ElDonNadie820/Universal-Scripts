local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")

local wallHopEnabled = false
local dragging = false
local dragStart, startPos

-- Creación de GUI compacta y movible
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Text = "Kai's Wall-Hop"
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Parent = frame

local function createButton(text, pos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, pos)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.Parent = frame
    button.MouseButton1Click:Connect(callback)
end

createButton("Activar/Desactivar Wall-Hop", 30, function()
    wallHopEnabled = not wallHopEnabled
end)

createButton("Eliminar GUI", 70, function()
    screenGui:Destroy()
end)

-- Hacer la GUI completamente movible
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Wall-Hop y Ladder-Flick automático sin delay, con giro reducido y dirección fija
local function performWallHop()
    if not wallHopEnabled then return end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(rootPart.Position, rootPart.CFrame.LookVector * 2, raycastParams)
    if raycastResult and raycastResult.Instance then
        humanoid.Jump = true
        rootPart.Velocity = Vector3.new(0, 60, 0) -- Potencia ajustada para mejor movimiento

        -- Giro más suave y controlado
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
        RunService.Heartbeat:Wait()
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(-20), 0)

        -- Ajustar la orientación del personaje y cámara hacia adelante
        local forwardDirection = Vector3.new(rootPart.CFrame.LookVector.X, 0, rootPart.CFrame.LookVector.Z).Unit
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + forwardDirection)
    end
end

-- Activar Wall-Hop y Ladder-Flick cada vez que el jugador salte cerca de una pared
UIS.JumpRequest:Connect(function()
    if wallHopEnabled then
        performWallHop()
    end
end)
