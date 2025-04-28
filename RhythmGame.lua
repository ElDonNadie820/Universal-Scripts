local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Se espera que la GUI del juego tenga esta estructura:
-- PlayerGui -> Game -> Holder -> { Notes (ImageLabels), Trigger (ImageLabels) }
local gameUI = playerGui:WaitForChild("Game", 5)
if not gameUI then
    warn("No se encontró 'Game' en PlayerGui.")
    return
end

local holder = gameUI:WaitForChild("Holder", 5)
if not holder then
    warn("No se encontró 'Holder' dentro de 'Game'.")
    return
end

local notesFolder = holder:WaitForChild("Notes", 5)
local triggerFolder = holder:WaitForChild("Trigger", 5)
if not (notesFolder and triggerFolder) then
    warn("No se encontraron las carpetas 'Notes' o 'Trigger'.")
    return
end

-- Mapeo de teclas, por carril: "1" → D, "2" → F, "3" → J, "4" → K
local keyMap = {
    ["1"] = Enum.KeyCode.D,
    ["2"] = Enum.KeyCode.F,
    ["3"] = Enum.KeyCode.J,
    ["4"] = Enum.KeyCode.K,
}

-- Configuración del AutoPlay
local AUTOPLAYER_ENABLED = true    -- Activo si es true
local TOLERANCE = 15              -- Tolerancia en píxeles para detectar overlapping
local spamInterval = 0         -- Intervalo entre taps para notas normales

-- Procesamiento por carril: lista de carriles
local lanes = { "1", "2", "3", "4" }

-- Tablas para seguimiento por carril:
-- Para NOTAS HOLD: indica si en ese carril ya se ha enviado el "key down"
local activeHolds = {}      
-- Para spam de notas normales: almacena el tiempo de la última pulsación
local lastTapTimes = {}     

-----------------------------------------
-- Funciones de Utilidad
-----------------------------------------
-- Devuelve el centro absoluto de un objeto GUI (ImageLabel)
local function getCenter(guiObj)
    local pos = guiObj.AbsolutePosition
    local size = guiObj.AbsoluteSize
    return Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
end

-- Comprueba si dos objetos (la nota y su trigger) se solapan (por sus centros) según la tolerancia
local function isOverlapping(obj1, obj2)
    local center1 = getCenter(obj1)
    local center2 = getCenter(obj2)
    return (math.abs(center1.X - center2.X) <= TOLERANCE and math.abs(center1.Y - center2.Y) <= TOLERANCE)
end

-- Simula un tap (pulsación breve) para un carril normal
local function simulateTap(lane)
    local keyCode = keyMap[lane]
    if keyCode then
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(spamInterval)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        -- Depuración:
        print("AutoPlay: Spam tap en carril " .. lane .. " (" .. keyCode.Name .. ")")
    end
end

-----------------------------------------
-- Bucle Principal: Procesamiento por Carril
-----------------------------------------
RunService.RenderStepped:Connect(function()
    if not AUTOPLAYER_ENABLED then return end

    -- Obtiene la lista de todas las notas una sola vez por frame
    local allNotes = notesFolder:GetChildren()

    -- Procesa cada carril por separado
    for _, lane in ipairs(lanes) do
        local trigger = triggerFolder:FindFirstChild(lane)
        if trigger and trigger:IsA("ImageLabel") then
            local normalOverlap = false
            local holdOverlap = false

            -- Filtra las notas del carril actual
            for _, note in ipairs(allNotes) do
                if note:IsA("ImageLabel") and note.Name == lane then
                    if isOverlapping(note, trigger) then
                        -- Si la nota tiene tanto "Hold" como "Attachment", se considera HOLD
                        if note:FindFirstChild("Hold") and note:FindFirstChild("Attachment") then
                            holdOverlap = true
                            break  -- Se prioriza el hold si hay alguna nota de hold en este carril.
                        else
                            normalOverlap = true
                        end
                    end
                end
            end

            local keyCode = keyMap[lane]
            if not keyCode then
                continue
            end

            if holdOverlap then
                -- Notas HOLD: mantener la tecla presionada
                if not activeHolds[lane] then
                    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                    activeHolds[lane] = true
                    print("AutoPlay: HOLD inicia en carril " .. lane)
                end
                -- Se mantiene la tecla presionada hasta que deje de haber overlapping
            else
                -- Si no hay nota HOLD, liberar la tecla si estuviera activada
                if activeHolds[lane] then
                    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    activeHolds[lane] = nil
                    print("AutoPlay: HOLD finalizada en carril " .. lane)
                end

                -- Si hay notas normales (spam) overlapping, se simula spam
                if normalOverlap then
                    local currentTime = tick()
                    if (not lastTapTimes[lane]) or (currentTime - lastTapTimes[lane] >= spamInterval) then
                        simulateTap(lane)
                        lastTapTimes[lane] = currentTime
                    end
                else
                    lastTapTimes[lane] = nil
                end

            end
        end
    end
end)
