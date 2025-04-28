local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")

local wallHopEnabled = false
local isPerformingWallHop = false

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
titleLabel.Text = "Kai's Automatic Wallhop"
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

-- Función para detectar una pared frente al jugador
local function isWallInFront()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = Workspace:Raycast(rootPart.Position, rootPart.CFrame.LookVector * 2, raycastParams)
    if raycastResult and raycastResult.Instance then
        return true
    end
    return false
end

-- Wall-Hop automático con giro después del movimiento
local function performWallHop()
    if not wallHopEnabled or isPerformingWallHop then return end
    isPerformingWallHop = true

    while wallHopEnabled and isWallInFront() do
        humanoid.Jump = true
        rootPart.Velocity = Vector3.new(0, 60, 0) -- Potencia ajustada para el Wall-Hop

        -- Esperar antes de girar para que el Wall-Hop se complete
        task.wait(0)

        -- Giro suave después del Wall-Hop
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(-35), 0)

        -- Delay para hacer el movimiento más humano
        task.wait(0.4)
    end

    isPerformingWallHop = false
end

RunService.Heartbeat:Connect(function()
    if wallHopEnabled then
        performWallHop()
    end
end)
