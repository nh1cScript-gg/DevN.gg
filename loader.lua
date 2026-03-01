-- DevN.gg GUI Library
-- loader.lua
-- Load with:
-- local DevNgg = https://raw.githubusercontent.com/nh1cScript-gg/DevN.gg/main/loader.lua

local DevNgg = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Config storage
local flags = {}
local toggleSetters = {}
local saveFolder = "DevNgg"
local saveFile = "config"

-- // Save & Load

local function getSavePath()
    return saveFolder .. "/" .. saveFile .. ".json"
end

local function saveConfig()
    pcall(function()
        if not isfolder(saveFolder) then makefolder(saveFolder) end
        local data = {}
        for flag, val in pairs(flags) do
            data[flag] = val
        end
        writefile(getSavePath(), HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    local ok, result = pcall(function()
        if isfolder(saveFolder) and isfile(getSavePath()) then
            return HttpService:JSONDecode(readfile(getSavePath()))
        end
        return {}
    end)
    return (ok and result) or {}
end

-- // Visibility

local mainFrame = nil
local guiVisible = true

function DevNgg:SetVisibility(val)
    guiVisible = val
    if mainFrame then mainFrame.Visible = val end
end

function DevNgg:IsVisible()
    return guiVisible
end

function DevNgg:Destroy()
    if mainFrame then mainFrame.Parent:Destroy() end
end

-- // Notify

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "DevNggNotif"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = playerGui

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 250, 0, 48)
notifFrame.Position = UDim2.new(0.5, -125, 1, -64)
notifFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
notifFrame.BorderSizePixel = 0
notifFrame.BackgroundTransparency = 1
notifFrame.Parent = notifGui
Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)

local notifStroke = Instance.new("UIStroke", notifFrame)
notifStroke.Color = Color3.fromRGB(55, 55, 55)
notifStroke.Thickness = 1
notifStroke.Transparency = 1

local notifTitle = Instance.new("TextLabel", notifFrame)
notifTitle.Size = UDim2.new(1, -16, 0, 20)
notifTitle.Position = UDim2.new(0, 10, 0, 4)
notifTitle.BackgroundTransparency = 1
notifTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
notifTitle.TextSize = 11
notifTitle.Font = Enum.Font.GothamBold
notifTitle.TextXAlignment = Enum.TextXAlignment.Left
notifTitle.Text = ""

local notifContent = Instance.new("TextLabel", notifFrame)
notifContent.Size = UDim2.new(1, -16, 0, 18)
notifContent.Position = UDim2.new(0, 10, 0, 24)
notifContent.BackgroundTransparency = 1
notifContent.TextColor3 = Color3.fromRGB(130, 130, 130)
notifContent.TextSize = 10
notifContent.Font = Enum.Font.Gotham
notifContent.TextXAlignment = Enum.TextXAlignment.Left
notifContent.TextWrapped = true
notifContent.Text = ""

local notifQueue = {}
local notifBusy = false

local function runNotifQueue()
    if notifBusy then return end
    notifBusy = true
    task.spawn(function()
        while #notifQueue > 0 do
            local item = table.remove(notifQueue, 1)
            notifTitle.Text = item.title or ""
            notifContent.Text = item.content or ""
            TweenService:Create(notifFrame, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
            TweenService:Create(notifStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
            task.wait(item.duration or 3)
            TweenService:Create(notifFrame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(notifStroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
            task.wait(0.3)
        end
        notifBusy = false
    end)
end

function DevNgg:Notify(config)
    table.insert(notifQueue, {
        title = config.Title or "DevN.gg",
        content = config.Content or "",
        duration = config.Duration or 3,
    })
    runNotifQueue()
end

-- // LoadConfiguration

function DevNgg:LoadConfiguration()
    local saved = loadConfig()
    for flag, val in pairs(saved) do
        local setter = toggleSetters[flag]
        if setter and type(val) == "boolean" then
            setter(val, false)
        end
    end
end

-- // CreateWindow

function DevNgg:CreateWindow(config)
    local windowTitle   = config.Name or "DevN.gg"
    local windowSub     = config.LoadingSubtitle or "by DevN.gg"
    local windowVersion = config.Version or "v1.0"
    local toggleKey     = config.ToggleUIKeybind or "K"

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    -- Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DevNggGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 240, 0, 60)
    main.Position = UDim2.new(0.5, -120, 0, 16)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(48, 48, 48)
    mainFrame = main

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 56)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    -- Fix header bottom rounded corners
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 20)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    -- Subtitle + version
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -70, 0, 16)
    subLabel.Position = UDim2.new(0, 12, 0, 30)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = windowSub .. "  •  " .. windowVersion
    subLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = header

    -- Minimize button
    local minimized = false
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -56, 0, 16)
    minBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    minBtn.TextSize = 15
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.Parent = header
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 16)
    closeBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        DevNgg:SetVisibility(false)
    end)

    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -64)
    content.Position = UDim2.new(0, 0, 0, 64)
    content.BackgroundTransparency = 1
    content.Parent = main

    local listLayout = Instance.new("UIListLayout", content)
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding", content)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 12)
    contentPadding.PaddingRight = UDim.new(0, 12)

    -- Auto resize
    local function updateSize()
        if minimized then return end
        local h = 64 + listLayout.AbsoluteContentSize.Y + 18
        TweenService:Create(main, TweenInfo.new(0.18), {
            Size = UDim2.new(0, 240, 0, h)
        }):Play()
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    -- Minimize logic
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        TweenService:Create(main, TweenInfo.new(0.18), {
            Size = minimized
                and UDim2.new(0, 240, 0, 60)
                or  UDim2.new(0, 240, 0, 64 + listLayout.AbsoluteContentSize.Y + 18)
        }):Play()
        minBtn.Text = minimized and "+" or "−"
    end)

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local key = typeof(toggleKey) == "string" and Enum.KeyCode[toggleKey] or toggleKey
        if input.KeyCode == key then
            DevNgg:SetVisibility(not guiVisible)
        end
    end)

    -- Drag
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Window object
    local Window = {}

    function Window:CreateTab(name, icon)
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, 0, 0, 16)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = name:upper()
        tabLabel.TextColor3 = Color3.fromRGB(65, 65, 65)
        tabLabel.TextSize = 9
        tabLabel.Font = Enum.Font.GothamBold
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = content

        local Tab = {}

        function Tab:CreateSection(sectionName)
            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            sep.BorderSizePixel = 0
            sep.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = sectionName:upper()
            lbl.TextColor3 = Color3.fromRGB(65, 65, 65)
            lbl.TextSize = 9
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = content

            local Section = {}
            function Section:Set(newName)
                lbl.Text = newName:upper()
            end
            return Section
        end

        function Tab:CreateDivider()
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            div.BorderSizePixel = 0
            div.Parent = content

            local Divider = {}
            function Divider:Set(visible)
                div.Visible = visible
            end
            return Divider
        end

        function Tab:CreateToggle(config)
            local flag = config.Flag
            local currentValue = config.CurrentValue or false

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(40, 40, 40)

            local label = Instance.new("TextLabel", btn)
            label.Size = UDim2.new(1, -52, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Name or "Toggle"
            label.TextColor3 = Color3.fromRGB(185, 185, 185)
            label.TextSize = 11
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left

            local pill = Instance.new("Frame", btn)
            pill.Size = UDim2.new(0, 34, 0, 19)
            pill.Position = UDim2.new(1, -46, 0.5, -9)
            pill.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pill.BorderSizePixel = 0
            Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", pill)
            knob.Size = UDim2.new(0, 13, 0, 13)
            knob.Position = UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            knob.BorderSizePixel = 0
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local enabled = currentValue

            local function setState(val, silent)
                enabled = val
                if flag then
                    flags[flag] = val
                    if not silent then saveConfig() end
                end
                TweenService:Create(pill, TweenInfo.new(0.15), {
                    BackgroundColor3 = val and Color3.fromRGB(75, 195, 115) or Color3.fromRGB(45, 45, 45)
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Position = val and UDim2.new(0, 18, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = val and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
                }):Play()
                if not silent and config.Callback then
                    config.Callback(val)
                end
            end

            if enabled then setState(true, true) end
            if flag then toggleSetters[flag] = setState end

            btn.MouseButton1Click:Connect(function() setState(not enabled) end)
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
            end)
        end

        function Tab:CreateButton(config)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.BorderSizePixel = 0
            btn.Text = config.Name or "Button"
            btn.TextColor3 = Color3.fromRGB(185, 185, 185)
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(40, 40, 40)

            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.07), { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }):Play()
                task.delay(0.12, function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
                end)
                if config.Callback then config.Callback() end
            end)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
            end)
        end

        return Tab
    end

    updateSize()
    return Window
end

return DevNgg
