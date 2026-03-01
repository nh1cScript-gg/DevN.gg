-- DevN.gg GUI Library
-- loader.lua

local DevNgg = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local flags = {}
local toggleSetters = {}
local saveFolder = "DevNgg"
local saveFile = "config"

local function getSavePath()
    return saveFolder .. "/" .. saveFile .. ".json"
end

local function saveConfig()
    pcall(function()
        if not isfolder(saveFolder) then makefolder(saveFolder) end
        local data = {}
        for flag, val in pairs(flags) do data[flag] = val end
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

-- // Notifications (Rayfield style - bottom right, stacked)

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "DevNggNotif"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = playerGui

local notifContainer = Instance.new("Frame")
notifContainer.Name = "NotifContainer"
notifContainer.Size = UDim2.new(0, 300, 1, 0)
notifContainer.Position = UDim2.new(1, -316, 0, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = notifGui

local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Padding = UDim.new(0, 8)

local notifPadding = Instance.new("UIPadding", notifContainer)
notifPadding.PaddingBottom = UDim.new(0, 16)
notifPadding.PaddingRight = UDim.new(0, 8)

function DevNgg:Notify(config)
    local title    = config.Title or "DevN.gg"
    local content  = config.Content or ""
    local duration = config.Duration or 3

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    card.BorderSizePixel = 0
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.Parent = notifContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(50, 50, 50)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 1

    -- Grey transparent accent bar on left
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    accent.BackgroundTransparency = 0.4
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)

    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.Size = UDim2.new(1, -24, 0, 22)
    titleLbl.Position = UDim2.new(0, 14, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local contentLbl = Instance.new("TextLabel", card)
    contentLbl.Size = UDim2.new(1, -24, 0, 26)
    contentLbl.Position = UDim2.new(0, 14, 0, 30)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Text = content
    contentLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
    contentLbl.TextSize = 11
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextWrapped = true

    -- Progress bar
    local progressBg = Instance.new("Frame", card)
    progressBg.Size = UDim2.new(1, 0, 0, 2)
    progressBg.Position = UDim2.new(0, 0, 1, -2)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BorderSizePixel = 0

    local progressBar = Instance.new("Frame", progressBg)
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    progressBar.BorderSizePixel = 0

    -- Fade in
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { BackgroundTransparency = 0 }):Play()
    TweenService:Create(cardStroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()

    -- Progress drain
    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(card, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        TweenService:Create(titleLbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(contentLbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(accent, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        task.wait(0.35)
        card:Destroy()
    end)
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

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DevNggGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 320, 0, 70)
    main.Position = UDim2.new(0.5, -160, 0, 20)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(48, 48, 48)
    mainFrame = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 64)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 24)
    titleLabel.Position = UDim2.new(0, 14, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -80, 0, 18)
    subLabel.Position = UDim2.new(0, 14, 0, 36)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = windowSub .. "  •  " .. windowVersion
    subLabel.TextColor3 = Color3.fromRGB(75, 75, 75)
    subLabel.TextSize = 11
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = header

    local minimized = false
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -64, 0, 18)
    minBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.Parent = header
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 18)
    closeBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        DevNgg:SetVisibility(false)
    end)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -72)
    content.Position = UDim2.new(0, 0, 0, 72)
    content.BackgroundTransparency = 1
    content.Parent = main

    local listLayout = Instance.new("UIListLayout", content)
    listLayout.Padding = UDim.new(0, 6)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding", content)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 12)
    contentPadding.PaddingLeft = UDim.new(0, 14)
    contentPadding.PaddingRight = UDim.new(0, 14)

    local function updateSize()
        if minimized then return end
        local h = 72 + listLayout.AbsoluteContentSize.Y + 22
        TweenService:Create(main, TweenInfo.new(0.18), { Size = UDim2.new(0, 320, 0, h) }):Play()
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        TweenService:Create(main, TweenInfo.new(0.18), {
            Size = minimized
                and UDim2.new(0, 320, 0, 68)
                or  UDim2.new(0, 320, 0, 72 + listLayout.AbsoluteContentSize.Y + 22)
        }):Play()
        minBtn.Text = minimized and "+" or "−"
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local key = typeof(toggleKey) == "string" and Enum.KeyCode[toggleKey] or toggleKey
        if input.KeyCode == key then DevNgg:SetVisibility(not guiVisible) end
    end)

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

    local Window = {}

    function Window:CreateTab(name, icon)
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, 0, 0, 18)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = name:upper()
        tabLabel.TextColor3 = Color3.fromRGB(65, 65, 65)
        tabLabel.TextSize = 10
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
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = sectionName:upper()
            lbl.TextColor3 = Color3.fromRGB(65, 65, 65)
            lbl.TextSize = 10
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = content

            local Section = {}
            function Section:Set(newName) lbl.Text = newName:upper() end
            return Section
        end

        function Tab:CreateDivider()
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            div.BorderSizePixel = 0
            div.Parent = content

            local Divider = {}
            function Divider:Set(visible) div.Visible = visible end
            return Divider
        end

        function Tab:CreateToggle(config)
            local flag = config.Flag
            local currentValue = config.CurrentValue or false

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(40, 40, 40)

            local label = Instance.new("TextLabel", btn)
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 14, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Name or "Toggle"
            label.TextColor3 = Color3.fromRGB(190, 190, 190)
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left

            local pill = Instance.new("Frame", btn)
            pill.Size = UDim2.new(0, 40, 0, 22)
            pill.Position = UDim2.new(1, -54, 0.5, -11)
            pill.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pill.BorderSizePixel = 0
            Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", pill)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(0, 3, 0.5, -8)
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
                    Position = val and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = val and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
                }):Play()
                if not silent and config.Callback then config.Callback(val) end
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
            btn.Size = UDim2.new(1, 0, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.BorderSizePixel = 0
            btn.Text = config.Name or "Button"
            btn.TextColor3 = Color3.fromRGB(190, 190, 190)
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            btn.Parent = content
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
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

    function Window:LoadConfiguration()
        local saved = loadConfig()
        for flag, val in pairs(saved) do
            local setter = toggleSetters[flag]
            if setter and type(val) == "boolean" then
                setter(val, false)
            end
        end
    end

    updateSize()
    return Window
end

return DevNgg
