-- DevN.gg GUI Library
-- loader.lua — Modern Minimalist Redesign

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

-- Xeno-compatible safe parent
local function safeParent(gui)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    ok = pcall(function() gui.Parent = gethui() end)
    if ok and gui.Parent then return end
    pcall(function() gui.Parent = playerGui end)
end

-- // Design Tokens
local C = {
    BG       = Color3.fromRGB(10, 10, 10),
    SURFACE  = Color3.fromRGB(16, 16, 16),
    SURFACE2 = Color3.fromRGB(20, 20, 20),
    BORDER   = Color3.fromRGB(30, 30, 30),
    BORDER2  = Color3.fromRGB(45, 45, 45),
    ACCENT   = Color3.fromRGB(255, 255, 255),
    ACCENT_D = Color3.fromRGB(70, 70, 70),
    TEXT     = Color3.fromRGB(215, 215, 215),
    TEXT_MID = Color3.fromRGB(110, 110, 110),
    TEXT_DIM = Color3.fromRGB(55, 55, 55),
    ON       = Color3.fromRGB(190, 255, 170),
    ON_PILL  = Color3.fromRGB(36, 36, 36),
    OFF_PILL = Color3.fromRGB(22, 22, 22),
    BTN      = Color3.fromRGB(16, 16, 16),
    BTN_HOV  = Color3.fromRGB(24, 24, 24),
    BTN_ACT  = Color3.fromRGB(32, 32, 32),
}

local FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.20, Enum.EasingStyle.Quint)

local function tw(obj, info, props) TweenService:Create(obj, info, props):Play() end

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function mkStroke(p, col, th, tr)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.BORDER
    s.Thickness = th or 1
    s.Transparency = tr or 0
    return s
end

local mainFrame = nil
local guiVisible = true

local DevNgg = {}

function DevNgg:SetVisibility(val)
    guiVisible = val
    if mainFrame then mainFrame.Visible = val end
end
function DevNgg:IsVisible() return guiVisible end
function DevNgg:Destroy()
    if mainFrame then mainFrame.Parent:Destroy() end
end

-- // Notifications

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "DevNggNotif"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() notifGui.DisplayOrder = 998 end)
pcall(function() notifGui.IgnoreGuiInset = true end)
safeParent(notifGui)

local notifHolder = Instance.new("Frame", notifGui)
notifHolder.Name = "NotifHolder"
notifHolder.Size = UDim2.new(0, 270, 1, 0)
notifHolder.Position = UDim2.new(1, -284, 0, 0)
notifHolder.BackgroundTransparency = 1

local notifList = Instance.new("UIListLayout", notifHolder)
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.Padding = UDim.new(0, 5)

local notifPad = Instance.new("UIPadding", notifHolder)
notifPad.PaddingBottom = UDim.new(0, 18)

function DevNgg:Notify(cfg)
    local title    = cfg.Title or "DevN.gg"
    local content  = cfg.Content or ""
    local duration = cfg.Duration or 3

    local card = Instance.new("Frame", notifHolder)
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = C.SURFACE
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    mkCorner(card, 8)
    local cs = mkStroke(card, C.BORDER, 1, 1)

    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 2, 0, 22)
    bar.Position = UDim2.new(0, 0, 0.5, -11)
    bar.BackgroundColor3 = C.ACCENT_D
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    mkCorner(bar, 2)

    local t = Instance.new("TextLabel", card)
    t.Size = UDim2.new(1, -18, 0, 18)
    t.Position = UDim2.new(0, 11, 0, 9)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.TEXT
    t.TextTransparency = 1
    t.TextSize = 12
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size = UDim2.new(1, -18, 0, 16)
    sub.Position = UDim2.new(0, 11, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = content
    sub.TextColor3 = C.TEXT_MID
    sub.TextTransparency = 1
    sub.TextSize = 10
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextWrapped = true

    local progBg = Instance.new("Frame", card)
    progBg.Size = UDim2.new(1, 0, 0, 1)
    progBg.Position = UDim2.new(0, 0, 1, -1)
    progBg.BackgroundColor3 = C.BORDER
    progBg.BorderSizePixel = 0

    local prog = Instance.new("Frame", progBg)
    prog.Size = UDim2.new(1, 0, 1, 0)
    prog.BackgroundColor3 = C.ACCENT_D
    prog.BorderSizePixel = 0

    tw(card, MED, { BackgroundTransparency = 0 })
    tw(cs,   MED, { Transparency = 0 })
    tw(bar,  MED, { BackgroundTransparency = 0 })
    tw(t,    MED, { TextTransparency = 0 })
    tw(sub,  MED, { TextTransparency = 0 })
    tw(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(duration, function()
        tw(card, MED, { BackgroundTransparency = 1 })
        tw(cs,   MED, { Transparency = 1 })
        tw(bar,  MED, { BackgroundTransparency = 1 })
        tw(t,    MED, { TextTransparency = 1 })
        tw(sub,  MED, { TextTransparency = 1 })
        task.wait(0.25)
        card:Destroy()
    end)
end

-- // CreateWindow

function DevNgg:CreateWindow(config)
    local windowTitle = config.Name or "DevN.gg"
    local windowSub   = config.LoadingSubtitle or "by DevN.gg"
    local windowVer   = config.Version or "v1.0"
    local toggleKey   = config.ToggleUIKeybind or "K"

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DevNggGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.DisplayOrder = 999 end)
    pcall(function() screenGui.IgnoreGuiInset = true end)
    safeParent(screenGui)

    if not screenGui.Parent then
        task.spawn(function()
            for i = 1, 10 do
                task.wait(0.5)
                safeParent(screenGui)
                if screenGui.Parent then break end
            end
        end)
    end

    -- Main frame
    local main = Instance.new("Frame", screenGui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 420, 0, 82)
    main.Position = UDim2.new(0.5, -210, 0, 22)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    mkCorner(main, 10)
    mkStroke(main, C.BORDER, 1)
    mainFrame = main

    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 76)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.ZIndex = 2

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(1, -110, 0, 26)
    titleLbl.Position = UDim2.new(0, 16, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = windowTitle
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 20
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", header)
    subLbl.Size = UDim2.new(1, -110, 0, 18)
    subLbl.Position = UDim2.new(0, 16, 0, 42)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = windowSub .. "  ·  " .. windowVer
    subLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    subLbl.TextSize = 13
    subLbl.Font = Enum.Font.GothamSemibold
    subLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Control buttons
    local function mkBtn(xPos, sym)
        local b = Instance.new("TextButton", main)
        b.Size = UDim2.new(0, 28, 0, 28)
        b.Position = UDim2.new(0, xPos, 0, 24)
        b.BackgroundColor3 = C.SURFACE2
        b.Text = sym
        b.TextColor3 = C.TEXT_DIM
        b.TextSize = 15
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex = 10
        mkCorner(b, 6)
        mkStroke(b, C.BORDER, 1)
        b.MouseEnter:Connect(function()
            tw(b, FAST, { TextColor3 = C.TEXT, BackgroundColor3 = C.BTN_HOV })
        end)
        b.MouseLeave:Connect(function()
            tw(b, FAST, { TextColor3 = C.TEXT_DIM, BackgroundColor3 = C.SURFACE2 })
        end)
        return b
    end

    local closeBtn = mkBtn(378, "×")
    local minBtn   = mkBtn(344, "−")

    closeBtn.MouseButton1Click:Connect(function()
        DevNgg:SetVisibility(false)
    end)

    -- Separator
    local sep = Instance.new("Frame", main)
    sep.Size = UDim2.new(1, -24, 0, 1)
    sep.Position = UDim2.new(0, 12, 0, 76)
    sep.BackgroundColor3 = C.BORDER
    sep.BorderSizePixel = 0
    sep.Visible = false

    -- Clip wrapper so content clips but buttons don't get cut
    local clipFrame = Instance.new("Frame", main)
    clipFrame.Name = "ClipFrame"
    clipFrame.Size = UDim2.new(1, 0, 1, 0)
    clipFrame.Position = UDim2.new(0, 0, 0, 0)
    clipFrame.BackgroundTransparency = 1
    clipFrame.ClipsDescendants = true
    clipFrame.ZIndex = 1

    -- Content
    local content = Instance.new("Frame", clipFrame)
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -84)
    content.Position = UDim2.new(0, 0, 0, 84)
    content.BackgroundTransparency = 1

    local listLayout = Instance.new("UIListLayout", content)
    listLayout.Padding = UDim.new(0, 3)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", content)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)

    local minimized = false

    local function updateSize()
        if minimized then return end
        local h = 84 + listLayout.AbsoluteContentSize.Y + 18
        tw(main,      TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 420, 0, h) })
        tw(clipFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 420, 0, h) })
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        sep.Visible = not minimized
        local targetH = minimized
            and 76
            or  (84 + listLayout.AbsoluteContentSize.Y + 18)
        tw(main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 420, 0, targetH) })
        tw(clipFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 420, 0, targetH) })
        minBtn.Text = minimized and "+" or "−"
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        pcall(function()
            local key = typeof(toggleKey) == "string" and Enum.KeyCode[toggleKey] or toggleKey
            if input.KeyCode == key then
                DevNgg:SetVisibility(not guiVisible)
            end
        end)
    end)

    -- Dragging
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Window = {}

    function Window:CreateTab(name, icon)
        local tabLbl = Instance.new("TextLabel", content)
        tabLbl.Size = UDim2.new(1, 0, 0, 14)
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text = name:upper()
        tabLbl.TextColor3 = C.TEXT_DIM
        tabLbl.TextSize = 9
        tabLbl.Font = Enum.Font.GothamBold
        tabLbl.TextXAlignment = Enum.TextXAlignment.Left

        local Tab = {}

        function Tab:CreateSection(sectionName)
            local row = Instance.new("Frame", content)
            row.Size = UDim2.new(1, 0, 0, 18)
            row.BackgroundTransparency = 1

            local line = Instance.new("Frame", row)
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0.5, 0)
            line.BackgroundColor3 = C.BORDER
            line.BorderSizePixel = 0

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0, 0, 1, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.X
            lbl.BackgroundColor3 = C.BG
            lbl.BorderSizePixel = 0
            lbl.Text = "  " .. sectionName:upper() .. "  "
            lbl.TextColor3 = C.TEXT_DIM
            lbl.TextSize = 9
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Section = {}
            function Section:Set(n) lbl.Text = "  " .. n:upper() .. "  " end
            return Section
        end

        function Tab:CreateDivider()
            local div = Instance.new("Frame", content)
            div.Size = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = C.BORDER
            div.BorderSizePixel = 0
            local Divider = {}
            function Divider:Set(v) div.Visible = v end
            return Divider
        end

        function Tab:CreateToggle(cfg)
            local flag = cfg.Flag
            local currentValue = cfg.CurrentValue or false

            local row = Instance.new("TextButton", content)
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = C.SURFACE
            row.BorderSizePixel = 0
            row.Text = ""
            row.AutoButtonColor = false
            mkCorner(row, 7)
            local rs = mkStroke(row, C.BORDER, 1)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -52, 1, 0)
            lbl.Position = UDim2.new(0, 11, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Name or "Toggle"
            lbl.TextColor3 = C.TEXT_MID
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local pill = Instance.new("Frame", row)
            pill.Size = UDim2.new(0, 36, 0, 20)
            pill.Position = UDim2.new(1, -50, 0.5, -10)
            pill.BackgroundColor3 = C.OFF_PILL
            pill.BorderSizePixel = 0
            mkCorner(pill, 10)
            mkStroke(pill, C.BORDER, 1)

            local knob = Instance.new("Frame", pill)
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(0, 3, 0.5, -7)
            knob.BackgroundColor3 = C.ACCENT_D
            knob.BorderSizePixel = 0
            mkCorner(knob, 7)

            local enabled = currentValue

            local function setState(val, silent)
                enabled = val
                if flag then
                    flags[flag] = val
                    if not silent then saveConfig() end
                end
                if val then
                    tw(pill, FAST, { BackgroundColor3 = C.ON_PILL })
                    tw(knob, FAST, { Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = C.ON })
                    tw(lbl,  FAST, { TextColor3 = C.TEXT })
                    tw(rs,   FAST, { Color = C.BORDER2 })
                else
                    tw(pill, FAST, { BackgroundColor3 = C.OFF_PILL })
                    tw(knob, FAST, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = C.ACCENT_D })
                    tw(lbl,  FAST, { TextColor3 = C.TEXT_MID })
                    tw(rs,   FAST, { Color = C.BORDER })
                end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            if enabled then setState(true, true) end
            if flag then toggleSetters[flag] = setState end

            row.MouseButton1Click:Connect(function() setState(not enabled) end)
            row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BTN_HOV }) end)
            row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundColor3 = C.SURFACE }) end)
        end

        function Tab:CreateButton(cfg)
            local btn = Instance.new("TextButton", content)
            btn.Size = UDim2.new(1, 0, 0, 46)
            btn.BackgroundColor3 = C.SURFACE
            btn.BorderSizePixel = 0
            btn.Text = cfg.Name or "Button"
            btn.TextColor3 = C.TEXT_MID
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            mkCorner(btn, 7)
            mkStroke(btn, C.BORDER, 1)

            btn.MouseButton1Click:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.BTN_ACT, TextColor3 = C.TEXT })
                task.delay(0.14, function()
                    tw(btn, MED, { BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_MID })
                end)
                if cfg.Callback then cfg.Callback() end
            end)
            btn.MouseEnter:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.BTN_HOV, TextColor3 = C.TEXT })
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_MID })
            end)
        end

        function Tab:CreateTextInput(cfg)
            local wrapper = Instance.new("Frame", content)
            wrapper.Size = UDim2.new(1, 0, 0, 58)
            wrapper.BackgroundTransparency = 1
            wrapper.BorderSizePixel = 0

            local lbl = Instance.new("TextLabel", wrapper)
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.Position = UDim2.new(0, 2, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Name or "Input"
            lbl.TextColor3 = C.TEXT_MID
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", wrapper)
            box.Size = UDim2.new(1, 0, 0, 36)
            box.Position = UDim2.new(0, 0, 0, 18)
            box.BackgroundColor3 = C.SURFACE
            box.BorderSizePixel = 0
            box.Text = cfg.Default or ""
            box.PlaceholderText = cfg.Placeholder or "Type here..."
            box.TextColor3 = C.TEXT
            box.PlaceholderColor3 = C.TEXT_DIM
            box.TextSize = 13
            box.Font = Enum.Font.Gotham
            box.ClearTextOnFocus = false
            mkCorner(box, 7)
            local bs = mkStroke(box, C.BORDER, 1)

            local pad = Instance.new("UIPadding", box)
            pad.PaddingLeft = UDim.new(0, 10)
            pad.PaddingRight = UDim.new(0, 10)

            box.Focused:Connect(function()
                tw(bs, FAST, { Color = C.BORDER2 })
            end)
            box.FocusLost:Connect(function()
                tw(bs, FAST, { Color = C.BORDER })
                if cfg.Callback then cfg.Callback(box.Text) end
            end)

            local Input = {}
            function Input:GetValue() return box.Text end
            function Input:SetValue(v) box.Text = v end
            return Input
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
