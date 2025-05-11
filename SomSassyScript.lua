if not isfolder("AdvancedUIMods") then
    makefolder("AdvancedUIMods")
end

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Crear la interfaz principal (UI Maker)
local ui = Instance.new("ScreenGui")
ui.Name = "AdvancedUIMaker"
ui.ResetOnSpawn = false
ui.Parent = PlayerGui

-- Frame principal del UI Maker
local mainFrame = Instance.new("Frame", ui)
mainFrame.Size = UDim2.new(0, 600, 0, 500)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Título del UI Maker
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Roblox UI Maker"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

-- Panel de pestañas lateral (izquierdo)
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.Size = UDim2.new(0, 120, 1, -40)
tabContainer.BackgroundColor3 = Color3.fromRGB(45,45,45)
tabContainer.BorderSizePixel = 0

-- Frame para el contenido de cada pestaña (derecha)
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Position = UDim2.new(0, 120, 0, 40)
contentFrame.Size = UDim2.new(0, 480, 1, -40)
contentFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
contentFrame.BorderSizePixel = 0

local tabs = {"Main", "Mods", "Installed"}
local currentTab = "Main"

-- Función para extraer la información mínima desde el código de un mod
local function parseModInfo(modCode)
    local modName = modCode:match('ModName%s*=%s*"(.-)"')
    local creator = modCode:match('Creator%s*=%s*"(.-)"')
    local version = modCode:match('Version%s*=%s*"(.-)"')
    return modName, creator, version
end

-- Función para actualizar la interfaz según la pestaña seleccionada
local updateUI
updateUI = function()
    -- Limpiar el contenido previo
    for _, child in ipairs(contentFrame:GetChildren()) do
        child:Destroy()
    end

    if currentTab == "Main" then
        ----------------------------------------------------
        -- Pestaña MAIN: Ejecutar código y panel "palette" de elementos GUI --
        ----------------------------------------------------
        local instructions = Instance.new("TextLabel", contentFrame)
        instructions.Size = UDim2.new(0.45, -20, 0, 40)
        instructions.Position = UDim2.new(0, 10, 0, 10)
        instructions.Text = "Escribe código que cree elementos GUI. Usa 'parent' como contenedor temporal."
        instructions.TextWrapped = true
        instructions.TextColor3 = Color3.new(1,1,1)
        instructions.BackgroundTransparency = 1
        instructions.Font = Enum.Font.SourceSans
        instructions.TextSize = 14

        local editorBox = Instance.new("TextBox", contentFrame)
        editorBox.Position = UDim2.new(0, 10, 0, 60)
        editorBox.Size = UDim2.new(0.45, -20, 0.55, -70)
        editorBox.Text = "-- Ejemplo:\n-- local btn = Instance.new('TextButton', parent)\n-- btn.Text = 'Hola'\n-- btn.Size = UDim2.new(0,100,0,50)"
        editorBox.ClearTextOnFocus = false
        editorBox.MultiLine = true
        editorBox.Font = Enum.Font.Code
        editorBox.TextSize = 14
        editorBox.TextColor3 = Color3.new(1,1,1)
        editorBox.BackgroundColor3 = Color3.fromRGB(35,35,35)

        local executeButton = Instance.new("TextButton", contentFrame)
        executeButton.Position = UDim2.new(0, 10, 0.63, 0)
        executeButton.Size = UDim2.new(0.22, -15, 0, 30)
        executeButton.Text = "Ejecutar Código"
        executeButton.TextColor3 = Color3.new(1,1,1)
        executeButton.BackgroundColor3 = Color3.fromRGB(60,255,60)
        executeButton.Font = Enum.Font.SourceSans
        executeButton.TextSize = 16
        executeButton.MouseButton1Click:Connect(function()
            local code = editorBox.Text
            local tempUI = PlayerGui:FindFirstChild("TemporaryExecutedUI")
            if not tempUI then
                tempUI = Instance.new("ScreenGui")
                tempUI.Name = "TemporaryExecutedUI"
                tempUI.Parent = PlayerGui
            end
            local func, err = loadstring("local parent = game.Players.LocalPlayer:WaitForChild('PlayerGui'):FindFirstChild('TemporaryExecutedUI')\n" .. code)
            if func then
                local success, execErr = pcall(func)
                if success then
                    print("Código ejecutado correctamente.")
                else
                    print("Error en la ejecución: " .. execErr)
                end
            else
                print("Error al compilar el código: " .. err)
            end
        end)

        local deleteExecutedUIButton = Instance.new("TextButton", contentFrame)
        deleteExecutedUIButton.Position = UDim2.new(0, 10 + (0.22 * 480) + 10, 0.63, 0)
        deleteExecutedUIButton.Size = UDim2.new(0.22, -15, 0, 30)
        deleteExecutedUIButton.Text = "Borrar UI Ejecutada"
        deleteExecutedUIButton.TextColor3 = Color3.new(1,1,1)
        deleteExecutedUIButton.BackgroundColor3 = Color3.fromRGB(255,60,60)
        deleteExecutedUIButton.Font = Enum.Font.SourceSans
        deleteExecutedUIButton.TextSize = 16
        deleteExecutedUIButton.MouseButton1Click:Connect(function()
            local tempUI = PlayerGui:FindFirstChild("TemporaryExecutedUI")
            if tempUI then
                tempUI:Destroy()
                print("UI ejecutada borrada.")
            else
                print("No existe UI ejecutada para borrar.")
            end
        end)
        
        -- Panel "palette" para insertar fragmentos de código de todos los elementos GUI existentes
        local paletteFrame = Instance.new("Frame", contentFrame)
        paletteFrame.Position = UDim2.new(0.5, 10, 0, 10)
        paletteFrame.Size = UDim2.new(0.48, -20, 0.9, -20)
        paletteFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
        paletteFrame.BorderSizePixel = 0

        local paletteTitle = Instance.new("TextLabel", paletteFrame)
        paletteTitle.Size = UDim2.new(1, -20, 0, 30)
        paletteTitle.Position = UDim2.new(0, 10, 0, 0)
        paletteTitle.Text = "Elementos de la GUI"
        paletteTitle.TextColor3 = Color3.new(1,1,1)
        paletteTitle.BackgroundTransparency = 1
        paletteTitle.Font = Enum.Font.SourceSansBold
        paletteTitle.TextSize = 18

        -- Tabla con todos los elementos GUI disponibles y sus snippets
        local guiElements = {
            {Name = "ScreenGui", Snippet = "local obj = Instance.new('ScreenGui', parent)\nobj.Name = 'ScreenGui'"},
            {Name = "SurfaceGui", Snippet = "local obj = Instance.new('SurfaceGui', parent)\nobj.Name = 'SurfaceGui'"},
            {Name = "BillboardGui", Snippet = "local obj = Instance.new('BillboardGui', parent)\nobj.Name = 'BillboardGui'"},
            {Name = "Frame", Snippet = "local obj = Instance.new('Frame', parent)\nobj.Size = UDim2.new(0,100,0,100)\nobj.BackgroundColor3 = Color3.new(1,1,1)"},
            {Name = "ImageLabel", Snippet = "local obj = Instance.new('ImageLabel', parent)\nobj.Image = 'rbxassetid://1234567'\nobj.Size = UDim2.new(0,100,0,100)"},
            {Name = "ImageButton", Snippet = "local obj = Instance.new('ImageButton', parent)\nobj.Image = 'rbxassetid://1234567'\nobj.Size = UDim2.new(0,100,0,100)"},
            {Name = "TextLabel", Snippet = "local obj = Instance.new('TextLabel', parent)\nobj.Text = 'Sample Text'\nobj.Size = UDim2.new(0,200,0,50)"},
            {Name = "TextBox", Snippet = "local obj = Instance.new('TextBox', parent)\nobj.Text = 'Enter text'\nobj.Size = UDim2.new(0,200,0,50)"},
            {Name = "TextButton", Snippet = "local obj = Instance.new('TextButton', parent)\nobj.Text = 'Click Me'\nobj.Size = UDim2.new(0,150,0,50)"},
            {Name = "ScrollingFrame", Snippet = "local obj = Instance.new('ScrollingFrame', parent)\nobj.Size = UDim2.new(0,200,0,200)\nobj.CanvasSize = UDim2.new(0,0,2,0)"},
            {Name = "UIGridLayout", Snippet = "local obj = Instance.new('UIGridLayout', parent)\nobj.CellSize = UDim2.new(0,100,0,100)"},
            {Name = "UIListLayout", Snippet = "local obj = Instance.new('UIListLayout', parent)"},
            {Name = "UIPadding", Snippet = "local obj = Instance.new('UIPadding', parent)\nobj.PaddingTop = UDim.new(0,10)"},
            {Name = "UICorner", Snippet = "local obj = Instance.new('UICorner', parent)\nobj.CornerRadius = UDim.new(0,10)"},
            {Name = "UIStroke", Snippet = "local obj = Instance.new('UIStroke', parent)\nobj.Color = Color3.new(0,0,0)"},
            {Name = "UIGradient", Snippet = "local obj = Instance.new('UIGradient', parent)"},
            {Name = "UIAspectRatioConstraint", Snippet = "local obj = Instance.new('UIAspectRatioConstraint', parent)"}
        }

        local buttonHeight = 30
        for i, element in ipairs(guiElements) do
            local btn = Instance.new("TextButton", paletteFrame)
            btn.Size = UDim2.new(1, -20, 0, buttonHeight)
            btn.Position = UDim2.new(0, 10, 0, 30 + (i-1)*(buttonHeight+5))
            btn.Text = element.Name
            btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.MouseButton1Click:Connect(function()
                editorBox.Text = editorBox.Text .. "\n" .. element.Snippet
            end)
        end

    elseif currentTab == "Mods" then
        ----------------------------------------------------
        -- Pestaña MODS: Crear y guardar mods usando funciones de archivo --
        ----------------------------------------------------
        local modInstructions = Instance.new("TextLabel", contentFrame)
        modInstructions.Size = UDim2.new(1, -20, 0, 60)
        modInstructions.Position = UDim2.new(0, 10, 0, 10)
        modInstructions.Text = "Para crear un mod, ingresa código que tenga la siguiente estructura mínima:\nModName = \"NombreDelMod\"\nCreator = \"tu_usuario\"\nVersion = \"1.0\"\nLuego, presiona 'Añadir Mod'."
        modInstructions.TextColor3 = Color3.new(1,1,1)
        modInstructions.BackgroundTransparency = 1
        modInstructions.Font = Enum.Font.SourceSans
        modInstructions.TextSize = 14
        modInstructions.TextWrapped = true

        local modCodeBox = Instance.new("TextBox", contentFrame)
        modCodeBox.Position = UDim2.new(0, 10, 0, 80)
        modCodeBox.Size = UDim2.new(1, -20, 0.6, -90)
        modCodeBox.Text = "-- Ingresa el código del mod aquí\n-- Estructura mínima:\n-- ModName = \"NombreDelMod\"\n-- Creator = \"tu_usuario\"\n-- Version = \"1.0\""
        modCodeBox.ClearTextOnFocus = false
        modCodeBox.MultiLine = true
        modCodeBox.Font = Enum.Font.Code
        modCodeBox.TextSize = 14
        modCodeBox.TextColor3 = Color3.new(1,1,1)
        modCodeBox.BackgroundColor3 = Color3.fromRGB(35,35,35)

        local addModButton = Instance.new("TextButton", contentFrame)
        addModButton.Position = UDim2.new(0, 10, 0, 0.7 * contentFrame.AbsoluteSize.Y)
        addModButton.Size = UDim2.new(1, -20, 0, 30)
        addModButton.Text = "Añadir Mod"
        addModButton.TextColor3 = Color3.new(1,1,1)
        addModButton.BackgroundColor3 = Color3.fromRGB(60,255,60)
        addModButton.Font = Enum.Font.SourceSans
        addModButton.TextSize = 16
        addModButton.MouseButton1Click:Connect(function()
            local modCode = modCodeBox.Text
            local modName, creator, version = parseModInfo(modCode)
            if modName and creator and version then
                local filePath = "AdvancedUIMods/" .. modName .. ".lua"
                if isfile(filePath) then
                    print("Ya existe un mod con ese nombre.")
                    return
                end
                writefile(filePath, modCode)
                print("Mod añadido: " .. modName)
                modCodeBox.Text = "-- Ingresa el código del mod aquí\n-- Estructura mínima:\n-- ModName = \"NombreDelMod\"\n-- Creator = \"tu_usuario\"\n-- Version = \"1.0\""
                updateUI()
            else
                print("El código del mod no es válido. Asegúrate de incluir ModName, Creator y Version.")
            end
        end)

    elseif currentTab == "Installed" then
        ----------------------------------------------------
        -- Pestaña INSTALLED: Listar mods guardados y opciones de carga/borrado --
        ----------------------------------------------------
        local modFiles = listfiles("AdvancedUIMods") or {}
        local yOffset = 10
        
        for _, modFile in ipairs(modFiles) do
            local modCode = readfile(modFile)
            local modName, creator, version = parseModInfo(modCode)
            modName = modName or modFile:match("AdvancedUIMods/(.+)%.lua")
            creator = creator or "Desconocido"
            version = version or "?"
            
            local modFrame = Instance.new("Frame", contentFrame)
            modFrame.Size = UDim2.new(1, -20, 0, 50)
            modFrame.Position = UDim2.new(0, 10, 0, yOffset)
            modFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
            modFrame.BorderSizePixel = 0

            local modNameLabel = Instance.new("TextLabel", modFrame)
            modNameLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
            modNameLabel.Position = UDim2.new(0, 10, 0, 0)
            modNameLabel.Text = modName
            modNameLabel.TextColor3 = Color3.new(1,1,1)
            modNameLabel.BackgroundTransparency = 1
            modNameLabel.Font = Enum.Font.SourceSansBold
            modNameLabel.TextSize = 20

            local modInfoLabel = Instance.new("TextLabel", modFrame)
            modInfoLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
            modInfoLabel.Position = UDim2.new(0, 10, 0.5, 0)
            modInfoLabel.Text = creator .. " - " .. version
            modInfoLabel.TextColor3 = Color3.new(1,1,1)
            modInfoLabel.BackgroundTransparency = 1
            modInfoLabel.Font = Enum.Font.SourceSans
            modInfoLabel.TextSize = 14

            local loadModButton = Instance.new("TextButton", modFrame)
            loadModButton.Size = UDim2.new(0.2, -5, 1, -10)
            loadModButton.Position = UDim2.new(0.75, 5, 0, 5)
            loadModButton.Text = "Cargar"
            loadModButton.TextColor3 = Color3.new(1,1,1)
            loadModButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
            loadModButton.Font = Enum.Font.SourceSans
            loadModButton.TextSize = 14
            loadModButton.MouseButton1Click:Connect(function()
                local func, err = loadfile(modFile)
                if func then
                    local ok, err2 = pcall(func)
                    if ok then
                        print("Mod cargado: " .. modName)
                    else
                        print("Error al ejecutar mod (" .. modName .. "): " .. err2)
                    end
                else
                    print("Error al cargar mod (" .. modName .. "): " .. err)
                end
            end)
            
            local deleteModButton = Instance.new("TextButton", modFrame)
            deleteModButton.Size = UDim2.new(0.2, -5, 1, -10)
            deleteModButton.Position = UDim2.new(0.55, 5, 0, 5)
            deleteModButton.Text = "Borrar"
            deleteModButton.TextColor3 = Color3.new(1,1,1)
            deleteModButton.BackgroundColor3 = Color3.fromRGB(255,60,60)
            deleteModButton.Font = Enum.Font.SourceSans
            deleteModButton.TextSize = 14
            deleteModButton.MouseButton1Click:Connect(function()
                delfile(modFile)
                print("Mod borrado: " .. modName)
                updateUI()
            end)
            
            yOffset = yOffset + 60
        end
    end
end

-- Crear botones de las pestañas en el panel lateral
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton", tabContainer)
    tabButton.Size = UDim2.new(1, 0, 0, 50)
    tabButton.Position = UDim2.new(0, 0, 0, (i-1)*50)
    tabButton.Text = tabName
    tabButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    tabButton.TextColor3 = Color3.new(1,1,1)
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 18
    tabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, btn in ipairs(tabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            end
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
        updateUI()
    end)
end

-- Cargar la pestaña "Main" por defecto
updateUI()
