-- Open Source :)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gameUI = playerGui:WaitForChild("Game", 5)
if not gameUI then
    warn("Nil.")
    return
end

local holder = gameUI:WaitForChild("Holder", 5)
if not holder then
    warn("Nil")
    return
end

local notesFolder = holder:WaitForChild("Notes", 5)
local triggerFolder = holder:WaitForChild("Trigger", 5)
if not (notesFolder and triggerFolder) then
    warn("Nil")
    return
end

local keyMap = {
    ["1"] = Enum.KeyCode.D,
    ["2"] = Enum.KeyCode.F,
    ["3"] = Enum.KeyCode.J,
    ["4"] = Enum.KeyCode.K,
}

local AUTOPLAYER_ENABLED = true    
local TOLERANCE = 15              
local spamInterval = 0         

local lanes = { "1", "2", "3", "4" }

local activeHolds = {}      
local lastTapTimes = {}     

local function getCenter(guiObj)
    local pos = guiObj.AbsolutePosition
    local size = guiObj.AbsoluteSize
    return Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
end

local function isOverlapping(obj1, obj2)
    local center1 = getCenter(obj1)
    local center2 = getCenter(obj2)
    return (math.abs(center1.X - center2.X) <= TOLERANCE and math.abs(center1.Y - center2.Y) <= TOLERANCE)
end

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

RunService.RenderStepped:Connect(function()
    if not AUTOPLAYER_ENABLED then return end

    local allNotes = notesFolder:GetChildren()

    for _, lane in ipairs(lanes) do
        local trigger = triggerFolder:FindFirstChild(lane)
        if trigger and trigger:IsA("ImageLabel") then
            local normalOverlap = false
            local holdOverlap = false

            for _, note in ipairs(allNotes) do
                if note:IsA("ImageLabel") and note.Name == lane then
                    if isOverlapping(note, trigger) then
                   if note:FindFirstChild("Hold") and note:FindFirstChild("Attachment") then
                            holdOverlap = true
                            break  
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
                if not activeHolds[lane] then
                    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                    activeHolds[lane] = true
                    print("AutoPlay: HOLD started in lane " .. lane)
                    end
                else
                if activeHolds[lane] then
                    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    activeHolds[lane] = nil
                    print("AutoPlay: HOLD ended in lane " .. lane)
                end

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
