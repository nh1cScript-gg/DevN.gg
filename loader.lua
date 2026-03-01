-- DevN.gg GUI Library
-- loader.lua — Ocean Redesign with Tabs

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

local function safeParent(gui)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    ok = pcall(function() gui.Parent = gethui() end)
    if ok and gui.Parent then return end
    pcall(function() gui.Parent = playerGui end)
end

-- // Ocean Design Tokens
local C = {
    BG        = Color3.fromRGB(6, 15, 25),
    SURFACE   = Color3.fromRGB(10, 25, 40),
    SURFACE2  = Color3.fromRGB(13, 32, 50),
    SURFACE3  = Color3.fromRGB(8, 20, 33),
    BORDER    = Color3.fromRGB(20, 55, 85),
    BORDER2   = Color3.fromRGB(35, 90, 130),
    ACCENT    = Color3.fromRGB(80, 200, 255),
    ACCENT_D  = Color3.fromRGB(40, 130, 190),
    TEXT      = Color3.fromRGB(190, 230, 255),
    TEXT_MID  = Color3.fromRGB(85, 145, 185),
    TEXT_DIM  = Color3.fromRGB(35, 80, 110),
    ON        = Color3.fromRGB(80, 255, 210),
    ON_PILL   = Color3.fromRGB(8, 50, 70),
    OFF_PILL  = Color3.fromRGB(8, 22, 35),
    BTN       = Color3.fromRGB(10, 25, 40),
    BTN_HOV   = Color3.fromRGB(15, 42, 65),
    BTN_ACT   = Color3.fromRGB(22, 60, 90),
    TAB_SEL   = Color3.fromRGB(15, 42, 65),
    TAB_UNSEL = Color3.fromRGB(8, 20, 33),
    TOPBAR    = Color3.fromRGB(8, 20, 33),
}

local FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.20, Enum.EasingStyle.Quint)
local SLOW = TweenInfo.new(0.30, Enum.EasingStyle.Quint)

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

local function mkGradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    return g
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
notifHolder.Size = UDim2.new(0, 280, 1, 0)
notifHolder.Position = UDim2.new(1, -295, 0, 0)
notifHolder.BackgroundTransparency = 1

local notifList = Instance.new("UIListLayout", notifHolder)
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.Padding = UDim.new(0, 6)

local notifPad = Instance.new("UIPadding", notifHolder)
notifPad.PaddingBottom = UDim.new(0, 18)

function DevNgg:Notify(cfg)
    local title    = cfg.Title or "DevN.gg"
    local content  = cfg.Content or ""
    local duration = cfg.Duration or 3

    local card = Instance.new("Frame", notifHolder)
    card.Size = UDim2.new(1, 0, 0, 58)
    card.BackgroundColor3 = C.SURFACE
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    mkCorner(card, 10)
    local cs = mkStroke(card, C.BORDER, 1, 1)

    -- Accent left bar
    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = C.ACCENT
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    mkCorner(bar, 2)

    -- Subtle gradient background
    local gBg = Instance.new("Frame", card)
    gBg.Size = UDim2.new(1, 0, 1, 0)
    gBg.BackgroundColor3 = C.ACCENT
    gBg.BackgroundTransparency = 0.96
    gBg.BorderSizePixel = 0

    local t = Instance.new("TextLabel", card)
    t.Size = UDim2.new(1, -22, 0, 20)
    t.Position = UDim2.new(0, 14, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.TEXT
    t.TextTransparency = 1
    t.TextSize = 13
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size = UDim2.new(1, -22, 0, 16)
    sub.Position = UDim2.new(0, 14, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text = content
    sub.TextColor3 = C.TEXT_MID
    sub.TextTransparency = 1
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextWrapped = true

    local progBg = Instance.new("Frame", card)
    progBg.Size = UDim2.new(1, 0, 0, 2)
    progBg.Position = UDim2.new(0, 0, 1, -2)
    progBg.BackgroundColor3 = C.BORDER
    progBg.BorderSizePixel = 0

    local prog = Instance.new("Frame", progBg)
    prog.Size = UDim2.new(1, 0, 1, 0)
    prog.BackgroundColor3 = C.ACCENT
    prog.BorderSizePixel = 0
    mkGradient(prog, C.ACCENT, Color3.fromRGB(40, 130, 190), 0)

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

    -- // Main frame
    local main = Instance.new("Frame", screenGui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 480, 0, 340)
    main.Position = UDim2.new(0.5, -240, 0.5, -170)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    mkCorner(main, 12)
    mkStroke(main, C.BORDER, 1)
    mainFrame = main

    -- Subtle top gradient accent
    local topAccent = Instance.new("Frame", main)
    topAccent.Size = UDim2.new(1, 0, 0, 2)
    topAccent.Position = UDim2.new(0, 0, 0, 0)
    topAccent.BackgroundColor3 = C.ACCENT
    topAccent.BorderSizePixel = 0
    mkCorner(topAccent, 12)
    mkGradient(topAccent, C.ACCENT, Color3.fromRGB(40, 130, 190), 0)

    -- // Topbar
    local topbar = Instance.new("Frame", main)
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 52)
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BackgroundColor3 = C.TOPBAR
    topbar.BorderSizePixel = 0
    mkCorner(topbar, 12)

    -- Cover bottom corners of topbar
    local topbarFill = Instance.new("Frame", main)
    topbarFill.Size = UDim2.new(1, 0, 0, 8)
    topbarFill.Position = UDim2.new(0, 0, 0, 46)
    topbarFill.BackgroundColor3 = C.TOPBAR
    topbarFill.BorderSizePixel = 0

    local titleLbl = Instance.new("TextLabel", topbar)
    titleLbl.Size = UDim2.new(1, -120, 0, 28)
    titleLbl.Position = UDim2.new(0, 16, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = windowTitle
    titleLbl.TextColor3 = C.TEXT
    titleLbl.TextSize = 16
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", topbar)
    subLbl.Size = UDim2.new(0, 200, 0, 14)
    subLbl.Position = UDim2.new(0, 16, 0, 34)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = windowSub .. "  ·  " .. windowVer
    subLbl.TextColor3 = C.TEXT_DIM
    subLbl.TextSize = 11
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Control buttons
    local function mkBtn(xOffset, sym)
        local b = Instance.new("TextButton", topbar)
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(1, xOffset, 0.5, -13)
        b.BackgroundColor3 = C.SURFACE2
        b.Text = sym
        b.TextColor3 = C.TEXT_DIM
        b.TextSize = 14
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

    local closeBtn = mkBtn(-12, "×")
    local minBtn   = mkBtn(-44, "−")

    closeBtn.MouseButton1Click:Connect(function()
        DevNgg:SetVisibility(false)
    end)

    -- // Tab bar
    local tabBar = Instance.new("Frame", main)
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(0, 140, 1, -54)
    tabBar.Position = UDim2.new(0, 0, 0, 54)
    tabBar.BackgroundColor3 = C.SURFACE3
    tabBar.BorderSizePixel = 0

    -- Bottom-left corner rounding
    local tabBarCorner = Instance.new("UICorner", tabBar)
    tabBarCorner.CornerRadius = UDim.new(0, 12)

    -- Fill top-right corner
    local tabBarFill = Instance.new("Frame", tabBar)
    tabBarFill.Size = UDim2.new(0, 12, 1, 0)
    tabBarFill.Position = UDim2.new(1, -12, 0, 0)
    tabBarFill.BackgroundColor3 = C.SURFACE3
    tabBarFill.BorderSizePixel = 0

    local tabList = Instance.new("UIListLayout", tabBar)
    tabList.Padding = UDim.new(0, 2)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.SortOrder = Enum.SortOrder.LayoutOrder

    local tabPad = Instance.new("UIPadding", tabBar)
    tabPad.PaddingTop = UDim.new(0, 10)
    tabPad.PaddingLeft = UDim.new(0, 8)
    tabPad.PaddingRight = UDim.new(0, 8)

    -- Divider between tab bar and content
    local divider = Instance.new("Frame", main)
    divider.Size = UDim2.new(0, 1, 1, -54)
    divider.Position = UDim2.new(0, 140, 0, 54)
    divider.BackgroundColor3 = C.BORDER
    divider.BorderSizePixel = 0

    -- // Content area
    local contentArea = Instance.new("Frame", main)
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -141, 1, -54)
    contentArea.Position = UDim2.new(0, 141, 0, 54)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true

    local minimized = false
    local tabFrames = {}
    local tabButtons = {}
    local activeTab = nil

    local function switchTab(name)
        for n, frame in pairs(tabFrames) do
            frame.Visible = (n == name)
        end
        for n, btn in pairs(tabButtons) do
            if n == name then
                tw(btn, FAST, { BackgroundColor3 = C.TAB_SEL })
                local lbl = btn:FindFirstChildOfClass("TextLabel")
                if lbl then tw(lbl, FAST, { TextColor3 = C.TEXT }) end
                local sel = btn:FindFirstChild("Selector")
                if sel then tw(sel, FAST, { BackgroundTransparency = 0 }) end
            else
                tw(btn, FAST, { BackgroundColor3 = C.TAB_UNSEL })
                local lbl = btn:FindFirstChildOfClass("TextLabel")
                if lbl then tw(lbl, FAST, { TextColor3 = C.TEXT_DIM }) end
                local sel = btn:FindFirstChild("Selector")
                if sel then tw(sel, FAST, { BackgroundTransparency = 1 }) end
            end
        end
        activeTab = name
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tabBar.Visible = not minimized
        tabBarFill.Visible = not minimized
        divider.Visible = not minimized
        contentArea.Visible = not minimized
        topbarFill.Visible = not minimized
        local targetH = minimized and 52 or 340
        tw(main, MED, { Size = UDim2.new(0, 480, 0, targetH) })
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
    topbar.InputBegan:Connect(function(input)
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
        -- Tab button in sidebar
        local tabBtn = Instance.new("TextButton", tabBar)
        tabBtn.Name = name
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.BackgroundColor3 = C.TAB_UNSEL
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        mkCorner(tabBtn, 8)

        -- Active selector bar
        local selector = Instance.new("Frame", tabBtn)
        selector.Name = "Selector"
        selector.Size = UDim2.new(0, 3, 0, 18)
        selector.Position = UDim2.new(0, 0, 0.5, -9)
        selector.BackgroundColor3 = C.ACCENT
        selector.BorderSizePixel = 0
        selector.BackgroundTransparency = 1
        mkCorner(selector, 2)

        local tabLbl = Instance.new("TextLabel", tabBtn)
        tabLbl.Size = UDim2.new(1, -10, 1, 0)
        tabLbl.Position = UDim2.new(0, 10, 0, 0)
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text = name
        tabLbl.TextColor3 = C.TEXT_DIM
        tabLbl.TextSize = 12
        tabLbl.Font = Enum.Font.GothamSemibold
        tabLbl.TextXAlignment = Enum.TextXAlignment.Left

        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                tw(tabBtn, FAST, { BackgroundColor3 = C.BTN_HOV })
                tw(tabLbl, FAST, { TextColor3 = C.TEXT_MID })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                tw(tabBtn, FAST, { BackgroundColor3 = C.TAB_UNSEL })
                tw(tabLbl, FAST, { TextColor3 = C.TEXT_DIM })
            end
        end)
        tabBtn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)

        tabButtons[name] = tabBtn

        -- Scrollable content frame for this tab
        local scrollFrame = Instance.new("ScrollingFrame", contentArea)
        scrollFrame.Name = name
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.Position = UDim2.new(0, 0, 0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = C.ACCENT_D
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Visible = false

        local listLayout = Instance.new("UIListLayout", scrollFrame)
        listLayout.Padding = UDim.new(0, 4)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local pad = Instance.new("UIPadding", scrollFrame)
        pad.PaddingTop    = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft   = UDim.new(0, 10)
        pad.PaddingRight  = UDim.new(0, 14)

        tabFrames[name] = scrollFrame

        -- Auto select first tab
        if not activeTab then
            switchTab(name)
        end

        local Tab = {}

        function Tab:CreateSection(sectionName)
            local row = Instance.new("Frame", scrollFrame)
            row.Size = UDim2.new(1, 0, 0, 22)
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
            lbl.TextColor3 = C.ACCENT_D
            lbl.TextSize = 9
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Section = {}
            function Section:Set(n) lbl.Text = "  " .. n:upper() .. "  " end
            return Section
        end

        function Tab:CreateDivider()
            local div = Instance.new("Frame", scrollFrame)
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

            local row = Instance.new("TextButton", scrollFrame)
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = C.SURFACE
            row.BorderSizePixel = 0
            row.Text = ""
            row.AutoButtonColor = false
            mkCorner(row, 8)
            local rs = mkStroke(row, C.BORDER, 1)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -58, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Name or "Toggle"
            lbl.TextColor3 = C.TEXT_MID
            lbl.TextSize = 13
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local pill = Instance.new("Frame", row)
            pill.Size = UDim2.new(0, 38, 0, 20)
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
                    tw(knob, FAST, { Position = UDim2.new(0, 21, 0.5, -7), BackgroundColor3 = C.ON })
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
            local btn = Instance.new("TextButton", scrollFrame)
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = C.SURFACE
            btn.BorderSizePixel = 0
            btn.Text = cfg.Name or "Button"
            btn.TextColor3 = C.TEXT_MID
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            mkCorner(btn, 8)
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
            local wrapper = Instance.new("Frame", scrollFrame)
            wrapper.Size = UDim2.new(1, 0, 0, 62)
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
            box.Size = UDim2.new(1, 0, 0, 38)
            box.Position = UDim2.new(0, 0, 0, 20)
            box.BackgroundColor3 = C.SURFACE
            box.BorderSizePixel = 0
            box.Text = cfg.Default or ""
            box.PlaceholderText = cfg.Placeholder or "Type here..."
            box.TextColor3 = C.TEXT
            box.PlaceholderColor3 = C.TEXT_DIM
            box.TextSize = 13
            box.Font = Enum.Font.Gotham
            box.ClearTextOnFocus = false
            mkCorner(box, 8)
            local bs = mkStroke(box, C.BORDER, 1)

            local pad = Instance.new("UIPadding", box)
            pad.PaddingLeft  = UDim.new(0, 10)
            pad.PaddingRight = UDim.new(0, 10)

            box.Focused:Connect(function()
                tw(bs, FAST, { Color = C.ACCENT })
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

    return Window
end

return DevNgg
