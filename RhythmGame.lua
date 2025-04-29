--Open Source :) (every explanation on spanish srry)
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Parámetros
local TOLERANCE       = 20      -- píxeles de tolerancia para “marvelous” y spam
local AutoPlayEnabled = false
local keyStates       = {}      -- para holds
local activeHold      = {}      -- nota que estamos manteniendo por lane
local endpointTouched = {}      -- flag para cada hold

-- Helper: centro de un GuiObject
local function getCenter(guiObj)
    local pos  = guiObj.AbsolutePosition
    local size = guiObj.AbsoluteSize
    return Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
end

-- Helper: dentro de tolerancia de centros
local function inWindow(c1, c2)
    return math.abs(c1.X - c2.X) <= TOLERANCE
       and math.abs(c1.Y - c2.Y) <= TOLERANCE
end

-- Simula tap rápido
local function tapKey(kc)
    VirtualInputManager:SendKeyEvent(true,  kc, false, game)
    VirtualInputManager:SendKeyEvent(false, kc, false, game)
end

-- Presionar/soltar para hold
local function pressKey(kc)
    if not keyStates[kc] then
        VirtualInputManager:SendKeyEvent(true, kc, false, game)
        keyStates[kc] = true
    end
end
local function releaseKey(kc)
    if keyStates[kc] then
        VirtualInputManager:SendKeyEvent(false, kc, false, game)
        keyStates[kc] = nil
    end
end

-- Construcción de la GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AutoPlayGUI"; screenGui.ResetOnSpawn = false
local frame = Instance.new("Frame", screenGui)
frame.Size, frame.Position = UDim2.new(0,200,0,100), UDim2.new(0,20,0,20)
frame.BackgroundColor3, frame.BackgroundTransparency = Color3.new(0,0,0), .3
local label = Instance.new("TextLabel", frame)
label.Size, label.Text = UDim2.new(1,0,0.5,0), "AutoPlay: Desactivado"
label.TextColor3, label.TextSize, label.BackgroundTransparency = Color3.new(1,1,1), 20, 1
local toggle = Instance.new("TextButton", frame)
toggle.Size, toggle.Position = UDim2.new(1,0,0.5,0), UDim2.new(0,0,0.5,0)
toggle.Text, toggle.TextColor3, toggle.TextSize = "Activar", Color3.new(1,1,1), 20
toggle.BackgroundColor3 = Color3.fromRGB(0,200,0)

toggle.MouseButton1Click:Connect(function()
    AutoPlayEnabled = not AutoPlayEnabled
    if AutoPlayEnabled then
        label.Text = "AutoPlay: Activado"
        toggle.Text = "Desactivar"
        toggle.BackgroundColor3 = Color3.fromRGB(200,0,0)
    else
        label.Text = "AutoPlay: Desactivado"
        toggle.Text = "Activar"
        toggle.BackgroundColor3 = Color3.fromRGB(0,200,0)
        -- limpiar estados
        for kc in pairs(keyStates) do releaseKey(kc) end
        keyStates, activeHold, endpointTouched = {}, {}, {}
    end
end)

-- Referencias a objetos de juego
local gameUI        = playerGui:WaitForChild("Game",5)
local holder        = gameUI and gameUI:WaitForChild("Holder",5)
local notesFolder   = holder and holder:WaitForChild("Notes",5)
local triggerFolder = holder and holder:WaitForChild("Trigger",5)
if not (notesFolder and triggerFolder) then
    warn("Falta Notes o Trigger")
    return
end

local lanes = {"1","2","3","4"}
local keyMap = {
    ["1"] = Enum.KeyCode.D,
    ["2"] = Enum.KeyCode.F,
    ["3"] = Enum.KeyCode.J,
    ["4"] = Enum.KeyCode.K,
}

-- Bucle principal
RunService.RenderStepped:Connect(function()
    if not AutoPlayEnabled then return end

    local notes = notesFolder:GetChildren()
    for _, lane in ipairs(lanes) do
        local trig      = triggerFolder:FindFirstChild(lane)
        if not (trig and trig:IsA("GuiObject") or trig:IsA("Folder")) then continue end

        local kc         = keyMap[lane]
        local trigCenter = getCenter(trig)
        local holding    = activeHold[lane]

        -- 1) Iniciar HOLD cuando la cabeza entra en ventana
        if not holding then
            for _, note in ipairs(notes) do
                if note.Name == lane and note:IsA("ImageLabel") then
                    local anchor   = note:FindFirstChild("Anchor")
                    local endpoint = anchor and anchor:FindFirstChild("Endpoint")
                    if anchor and endpoint then
                        local headCenter = getCenter(note)
                        if inWindow(headCenter, trigCenter) then
                            pressKey(kc)
                            activeHold[lane]      = note
                            endpointTouched[lane] = false
                            holding               = note
                            break
                        end
                    end
                end
            end
        end

        -- 2) Mantener y soltar HOLD
        if holding then
            local endpoint = holding.Anchor:FindFirstChild("Endpoint")
            if endpoint then
                local endCenter = getCenter(endpoint)
                if inWindow(endCenter, trigCenter) then
                    endpointTouched[lane] = true
                elseif endpointTouched[lane] then
                    releaseKey(kc)
                    activeHold[lane]      = nil
                    endpointTouched[lane] = nil
                    holding               = nil
                end
            end

        else
            -- 3) SPAM de taps: cada frame que la cabeza esté dentro de la ventana
            for _, note in ipairs(notes) do
                if note.Name == lane and note:IsA("ImageLabel") and not note:FindFirstChild("Anchor") then
                    local headCenter = getCenter(note)
                    if inWindow(headCenter, trigCenter) then
                        tapKey(kc)
                    end
                end
            end
        end
    end
end)
