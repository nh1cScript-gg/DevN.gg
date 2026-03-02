-- DevN.gg GUI Library
-- loader.lua — v2.1 | Fixed + Refactored
-- Changes from v2.0:
--   • SetOptions() always rebuilds list even when dropdown is closed (MAIN FIX)
--   • SetOptions() auto-resets selected if value no longer in list
--   • Added Dropdown:AddOption(opt) — add single item without full rebuild
--   • Added Dropdown:RemoveOption(opt) — remove single item by value
--   • Added Dropdown:GetOptions() — returns current options table
--   • Added Window:GetFlag(flag) — read current toggle state from script
--   • Notification cap: max 5 stacked at once, extras are dropped
--   • Label:SetColor(c) added for dynamic text color

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local flags         = {}
local toggleSetters = {}
local saveFolder    = "DevNgg"
local saveFile      = "config"

-- ── Global dropdown tracker ───────────────────────────────────────────────
local _openDropdowns = {}

local function closeAllDropdowns()
    for _, fn in ipairs(_openDropdowns) do pcall(fn) end
    table.clear(_openDropdowns)
end

local function registerDropdown(closeFn)
    table.insert(_openDropdowns, closeFn)
end

local function unregisterDropdown(closeFn)
    for i = #_openDropdowns, 1, -1 do
        if _openDropdowns[i] == closeFn then
            table.remove(_openDropdowns, i)
        end
    end
end

-- ── Config persistence ────────────────────────────────────────────────────
local function getSavePath() return saveFolder .. "/" .. saveFile .. ".json" end

local function saveConfig()
    pcall(function()
        if not isfolder(saveFolder) then makefolder(saveFolder) end
        local data = {}
        for k, v in pairs(flags) do data[k] = v end
        writefile(getSavePath(), HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    local ok, r = pcall(function()
        if isfolder(saveFolder) and isfile(getSavePath()) then
            return HttpService:JSONDecode(readfile(getSavePath()))
        end
        return {}
    end)
    return (ok and r) or {}
end

-- ── Safe GUI parenting ────────────────────────────────────────────────────
local function safeParent(gui)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    ok = pcall(function() gui.Parent = gethui() end)
    if ok and gui.Parent then return end
    pcall(function() gui.Parent = playerGui end)
end

-- ── Design Tokens ─────────────────────────────────────────────────────────
local C = {
    BG       = Color3.fromRGB(9,  9,  9),
    SURFACE  = Color3.fromRGB(15, 15, 15),
    SURFACE2 = Color3.fromRGB(20, 20, 20),
    SURFACE3 = Color3.fromRGB(26, 26, 26),
    BORDER   = Color3.fromRGB(32, 32, 32),
    BORDER2  = Color3.fromRGB(52, 52, 52),
    ACCENT   = Color3.fromRGB(255,255,255),
    ACCENT_D = Color3.fromRGB(90, 90, 90),
    TEXT     = Color3.fromRGB(225,225,225),
    TEXT_MID = Color3.fromRGB(120,120,120),
    TEXT_DIM = Color3.fromRGB(52, 52, 52),
    ON       = Color3.fromRGB(170,255,140),
    ON_PILL  = Color3.fromRGB(30, 46, 26),
    OFF_PILL = Color3.fromRGB(20, 20, 20),
    BTN_HOV  = Color3.fromRGB(22, 22, 22),
    BTN_ACT  = Color3.fromRGB(34, 34, 34),
    RED      = Color3.fromRGB(220, 60, 60),
    AMBER    = Color3.fromRGB(210,170, 50),
}

local FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.20, Enum.EasingStyle.Quint)

local function tw(o, i, p) TweenService:Create(o, i, p):Play() end

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke", p)
    s.Color        = col or C.BORDER
    s.Thickness    = th  or 1
    s.Transparency = tr  or 0
    return s
end

local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    return u
end

-- ── Module ────────────────────────────────────────────────────────────────
local mainFrame  = nil
local guiVisible = true
local DevNgg     = {}

function DevNgg:SetVisibility(val)
    guiVisible = val
    if mainFrame then mainFrame.Visible = val end
    if not val then closeAllDropdowns() end
end
function DevNgg:IsVisible() return guiVisible end
function DevNgg:Destroy()
    if mainFrame then mainFrame.Parent:Destroy() end
end

-- ── Notification (max 5 stacked) ──────────────────────────────────────────
local notifGui = Instance.new("ScreenGui")
notifGui.Name             = "DevNggNotif"
notifGui.ResetOnSpawn     = false
notifGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
pcall(function() notifGui.DisplayOrder   = 999 end)
pcall(function() notifGui.IgnoreGuiInset = true end)
safeParent(notifGui)

local nHolder = Instance.new("Frame", notifGui)
nHolder.Name                   = "NotifHolder"
nHolder.Size                   = UDim2.new(0, 278, 1, 0)
nHolder.Position               = UDim2.new(1, -292, 0, 0)
nHolder.BackgroundTransparency = 1

local nLayout = Instance.new("UIListLayout", nHolder)
nLayout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
nLayout.SortOrder           = Enum.SortOrder.LayoutOrder
nLayout.Padding             = UDim.new(0, 6)

local nPad = Instance.new("UIPadding", nHolder)
nPad.PaddingBottom = UDim.new(0, 20)

local activeNotifCount = 0
local MAX_NOTIFS = 5

function DevNgg:Notify(cfg)
    if activeNotifCount >= MAX_NOTIFS then return end
    activeNotifCount += 1

    local title    = cfg.Title    or "DevN.gg"
    local content  = cfg.Content  or ""
    local duration = cfg.Duration or 3

    local card = Instance.new("Frame", nHolder)
    card.Size                   = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3       = C.SURFACE
    card.BackgroundTransparency = 1
    card.BorderSizePixel        = 0
    card.ClipsDescendants       = true
    corner(card, 9)
    local cs = stroke(card, C.BORDER2, 1, 1)

    local bar = Instance.new("Frame", card)
    bar.Size                   = UDim2.new(0, 2, 0, 26)
    bar.Position               = UDim2.new(0, 0, 0.5, -13)
    bar.BackgroundColor3       = C.ACCENT_D
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel        = 0
    corner(bar, 1)

    local tLbl = Instance.new("TextLabel", card)
    tLbl.Size                   = UDim2.new(1, -18, 0, 20)
    tLbl.Position               = UDim2.new(0, 13, 0, 10)
    tLbl.BackgroundTransparency = 1
    tLbl.Text                   = title
    tLbl.TextColor3             = C.TEXT
    tLbl.TextTransparency       = 1
    tLbl.TextSize               = 13
    tLbl.Font                   = Enum.Font.GothamBold
    tLbl.TextXAlignment         = Enum.TextXAlignment.Left

    local sLbl = Instance.new("TextLabel", card)
    sLbl.Size                   = UDim2.new(1, -18, 0, 16)
    sLbl.Position               = UDim2.new(0, 13, 0, 31)
    sLbl.BackgroundTransparency = 1
    sLbl.Text                   = content
    sLbl.TextColor3             = C.TEXT_MID
    sLbl.TextTransparency       = 1
    sLbl.TextSize               = 11
    sLbl.Font                   = Enum.Font.Gotham
    sLbl.TextXAlignment         = Enum.TextXAlignment.Left
    sLbl.TextWrapped            = true

    local progBg = Instance.new("Frame", card)
    progBg.Size             = UDim2.new(1, 0, 0, 1)
    progBg.Position         = UDim2.new(0, 0, 1, -1)
    progBg.BackgroundColor3 = C.BORDER
    progBg.BorderSizePixel  = 0

    local progFill = Instance.new("Frame", progBg)
    progFill.Size             = UDim2.new(1, 0, 1, 0)
    progFill.BackgroundColor3 = C.ACCENT_D
    progFill.BorderSizePixel  = 0

    tw(card,  MED, { BackgroundTransparency = 0 })
    tw(cs,    MED, { Transparency = 0 })
    tw(bar,   MED, { BackgroundTransparency = 0 })
    tw(tLbl,  MED, { TextTransparency = 0 })
    tw(sLbl,  MED, { TextTransparency = 0 })
    tw(progFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(duration, function()
        tw(card,  MED, { BackgroundTransparency = 1 })
        tw(cs,    MED, { Transparency = 1 })
        tw(bar,   MED, { BackgroundTransparency = 1 })
        tw(tLbl,  MED, { TextTransparency = 1 })
        tw(sLbl,  MED, { TextTransparency = 1 })
        task.wait(0.22)
        card:Destroy()
        activeNotifCount -= 1
    end)
end

-- ── CreateWindow ──────────────────────────────────────────────────────────
function DevNgg:CreateWindow(config)
    local winTitle  = config.Name            or "DevN.gg"
    local winSub    = config.LoadingSubtitle or "by DevN.gg"
    local winVer    = config.Version         or "v1.0"
    local toggleKey = config.ToggleUIKeybind or "K"

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name             = "DevNggGUI"
    screenGui.ResetOnSpawn     = false
    screenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.DisplayOrder   = 999 end)
    pcall(function() screenGui.IgnoreGuiInset = true end)
    safeParent(screenGui)

    if not screenGui.Parent then
        task.spawn(function()
            for _ = 1, 10 do
                task.wait(0.5)
                safeParent(screenGui)
                if screenGui.Parent then break end
            end
        end)
    end

    -- Main frame
    local main = Instance.new("Frame", screenGui)
    main.Name             = "Main"
    main.Size             = UDim2.new(0, 530, 0, 80)
    main.Position         = UDim2.new(0.5, -265, 0, 22)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel  = 0
    main.ClipsDescendants = false
    corner(main, 10)
    stroke(main, C.BORDER, 1)
    mainFrame = main

    -- Shadow
    local shadow = Instance.new("ImageLabel", main)
    shadow.AnchorPoint            = Vector2.new(0.5, 0.5)
    shadow.Size                   = UDim2.new(1, 54, 1, 54)
    shadow.Position               = UDim2.new(0.5, 0, 0.5, 7)
    shadow.BackgroundTransparency = 1
    shadow.Image                  = "rbxassetid://6014054385"
    shadow.ImageColor3            = Color3.new(0, 0, 0)
    shadow.ImageTransparency      = 0.65
    shadow.ScaleType              = Enum.ScaleType.Slice
    shadow.SliceCenter            = Rect.new(49, 49, 450, 450)
    shadow.ZIndex                 = 0

    -- Header
    local header = Instance.new("Frame", main)
    header.Size                   = UDim2.new(1, 0, 0, 74)
    header.BackgroundTransparency = 1
    header.ZIndex                 = 2

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size                   = UDim2.new(1, -110, 0, 28)
    titleLbl.Position               = UDim2.new(0, 16, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                   = winTitle
    titleLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize               = 19
    titleLbl.Font                   = Enum.Font.GothamBold
    titleLbl.TextXAlignment         = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", header)
    subLbl.Size                   = UDim2.new(1, -110, 0, 17)
    subLbl.Position               = UDim2.new(0, 16, 0, 42)
    subLbl.BackgroundTransparency = 1
    subLbl.Text                   = winSub .. "  ·  " .. winVer
    subLbl.TextColor3             = C.TEXT_MID
    subLbl.TextSize               = 12
    subLbl.Font                   = Enum.Font.GothamSemibold
    subLbl.TextXAlignment         = Enum.TextXAlignment.Left

    -- Control buttons
    local function mkCtrl(offX, sym, hoverCol)
        local b = Instance.new("TextButton", main)
        b.Size             = UDim2.new(0, 26, 0, 26)
        b.Position         = UDim2.new(1, offX, 0, 24)
        b.BackgroundColor3 = C.SURFACE2
        b.Text             = sym
        b.TextColor3       = C.TEXT_DIM
        b.TextSize         = 14
        b.Font             = Enum.Font.GothamBold
        b.BorderSizePixel  = 0
        b.AutoButtonColor  = false
        b.ZIndex           = 10
        corner(b, 5)
        stroke(b, C.BORDER, 1)
        b.MouseEnter:Connect(function() tw(b, FAST, { TextColor3 = hoverCol or C.TEXT, BackgroundColor3 = C.BTN_HOV }) end)
        b.MouseLeave:Connect(function() tw(b, FAST, { TextColor3 = C.TEXT_DIM, BackgroundColor3 = C.SURFACE2 }) end)
        return b
    end

    local closeBtn = mkCtrl(-38, "×", C.RED)
    local minBtn   = mkCtrl(-70, "−", C.AMBER)

    -- × hides GUI; press K to bring it back
    closeBtn.MouseButton1Click:Connect(function()
        DevNgg:SetVisibility(false)
    end)

    -- Header separator
    local headerSep = Instance.new("Frame", main)
    headerSep.Size             = UDim2.new(1, 0, 0, 1)
    headerSep.Position         = UDim2.new(0, 0, 0, 74)
    headerSep.BackgroundColor3 = C.BORDER
    headerSep.BorderSizePixel  = 0

    -- Tab bar
    local tabBar = Instance.new("Frame", main)
    tabBar.Size             = UDim2.new(1, 0, 0, 36)
    tabBar.Position         = UDim2.new(0, 0, 0, 75)
    tabBar.BackgroundColor3 = C.SURFACE
    tabBar.BorderSizePixel  = 0

    local tabBarLayout = Instance.new("UIListLayout", tabBar)
    tabBarLayout.FillDirection  = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder      = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding        = UDim.new(0, 0)

    local tabBarSep = Instance.new("Frame", main)
    tabBarSep.Size             = UDim2.new(1, 0, 0, 1)
    tabBarSep.Position         = UDim2.new(0, 0, 0, 111)
    tabBarSep.BackgroundColor3 = C.BORDER
    tabBarSep.BorderSizePixel  = 0

    -- Content clip
    local clipFrame = Instance.new("Frame", main)
    clipFrame.Name                   = "ClipFrame"
    clipFrame.Size                   = UDim2.new(1, 0, 1, -112)
    clipFrame.Position               = UDim2.new(0, 0, 0, 112)
    clipFrame.BackgroundTransparency = 1
    clipFrame.ClipsDescendants       = true

    local minimized = false
    local tabs      = {}
    local activeTab = nil
    local tabCount  = 0

    local function switchTab(tab)
        closeAllDropdowns()
        for _, t in ipairs(tabs) do
            t.content.Visible = false
            tw(t.btn, FAST, { BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_DIM })
            t.indicator.BackgroundTransparency = 1
        end
        tab.content.Visible = true
        activeTab = tab
        tw(tab.btn, FAST, { BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT })
        tab.indicator.BackgroundTransparency = 0
        local h = math.min(112 + tab.listLayout.AbsoluteContentSize.Y + 20, 600)
        main.Size      = UDim2.new(0, 530, 0, h)
        clipFrame.Size = UDim2.new(1, 0, 0, h - 112)
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        closeAllDropdowns()
        tabBar.Visible    = not minimized
        tabBarSep.Visible = not minimized
        clipFrame.Visible = not minimized
        headerSep.Visible = not minimized
        if minimized then
            tw(main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 530, 0, 74) })
        else
            if activeTab then
                local h = math.min(112 + activeTab.listLayout.AbsoluteContentSize.Y + 20, 600)
                tw(main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 530, 0, h) })
                clipFrame.Size = UDim2.new(1, 0, 0, h - 112)
            end
        end
        minBtn.Text = minimized and "+" or "−"
    end)

    -- K key toggles GUI — works even after × close
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        pcall(function()
            local key = typeof(toggleKey) == "string" and Enum.KeyCode[toggleKey] or toggleKey
            if input.KeyCode == key then
                DevNgg:SetVisibility(not guiVisible)
            end
        end)
    end)

    -- Drag
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            closeAllDropdowns()
            local d = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local Window = {}

    -- ── CreateTab ─────────────────────────────────────────────────────────
    function Window:CreateTab(name, _icon)
        tabCount += 1
        local tabIndex = tabCount

        local btn = Instance.new("TextButton", tabBar)
        btn.Size             = UDim2.new(0, 0, 1, 0)
        btn.AutomaticSize    = Enum.AutomaticSize.X
        btn.BackgroundColor3 = C.SURFACE
        btn.BorderSizePixel  = 0
        btn.Text             = "  " .. name .. "  "
        btn.TextColor3       = C.TEXT_DIM
        btn.TextSize         = 12
        btn.Font             = Enum.Font.GothamSemibold
        btn.AutoButtonColor  = false
        btn.LayoutOrder      = tabIndex

        local indicator = Instance.new("Frame", btn)
        indicator.Size                   = UDim2.new(1, 0, 0, 2)
        indicator.Position               = UDim2.new(0, 0, 1, -2)
        indicator.BackgroundColor3       = C.ACCENT
        indicator.BorderSizePixel        = 0
        indicator.BackgroundTransparency = 1

        local tabContent = Instance.new("ScrollingFrame", clipFrame)
        tabContent.Size                   = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel        = 0
        tabContent.ScrollBarThickness     = 3
        tabContent.ScrollBarImageColor3   = C.BORDER2
        tabContent.CanvasSize             = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        tabContent.Visible                = false

        local tabLL = Instance.new("UIListLayout", tabContent)
        tabLL.Padding             = UDim.new(0, 3)
        tabLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabLL.SortOrder           = Enum.SortOrder.LayoutOrder

        local tabPad = Instance.new("UIPadding", tabContent)
        tabPad.PaddingTop    = UDim.new(0, 9)
        tabPad.PaddingBottom = UDim.new(0, 12)
        tabPad.PaddingLeft   = UDim.new(0, 10)
        tabPad.PaddingRight  = UDim.new(0, 10)

        local tabData = { btn = btn, content = tabContent, listLayout = tabLL, indicator = indicator }
        table.insert(tabs, tabData)

        if tabCount == 1 then task.defer(function() switchTab(tabData) end) end

        tabLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if activeTab == tabData and not minimized then
                local h = math.min(112 + tabLL.AbsoluteContentSize.Y + 20, 600)
                main.Size      = UDim2.new(0, 530, 0, h)
                clipFrame.Size = UDim2.new(1, 0, 0, h - 112)
            end
        end)

        btn.MouseButton1Click:Connect(function() switchTab(tabData) end)
        btn.MouseEnter:Connect(function()
            if activeTab ~= tabData then tw(btn, FAST, { TextColor3 = C.TEXT_MID }) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= tabData then tw(btn, FAST, { TextColor3 = C.TEXT_DIM }) end
        end)

        local content = tabContent
        local Tab = {}

        -- Section
        function Tab:CreateSection(sName)
            local row = Instance.new("Frame", content)
            row.Size                   = UDim2.new(1, 0, 0, 20)
            row.BackgroundTransparency = 1

            local line = Instance.new("Frame", row)
            line.Size             = UDim2.new(1, 0, 0, 1)
            line.Position         = UDim2.new(0, 0, 0.5, 0)
            line.BackgroundColor3 = C.BORDER
            line.BorderSizePixel  = 0

            local bg = Instance.new("Frame", row)
            bg.BackgroundColor3 = C.BG
            bg.BorderSizePixel  = 0
            bg.AutomaticSize    = Enum.AutomaticSize.X
            bg.Size             = UDim2.new(0, 0, 1, 0)

            local lbl = Instance.new("TextLabel", bg)
            lbl.BackgroundTransparency = 1
            lbl.AutomaticSize          = Enum.AutomaticSize.X
            lbl.Size                   = UDim2.new(0, 0, 1, 0)
            lbl.Text                   = "  " .. sName:upper() .. "  "
            lbl.TextColor3             = C.TEXT_DIM
            lbl.TextSize               = 9
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextXAlignment         = Enum.TextXAlignment.Left

            local S = {}
            function S:Set(n) lbl.Text = "  " .. n:upper() .. "  " end
            return S
        end

        -- Divider
        function Tab:CreateDivider()
            local div = Instance.new("Frame", content)
            div.Size             = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = C.BORDER
            div.BorderSizePixel  = 0
            local D = {}
            function D:Set(v) div.Visible = v end
            return D
        end

        -- Label
        function Tab:CreateLabel(cfg)
            local f = Instance.new("Frame", content)
            f.Size             = UDim2.new(1, 0, 0, 36)
            f.BackgroundColor3 = C.SURFACE
            f.BorderSizePixel  = 0
            corner(f, 7)
            stroke(f, C.BORDER, 1)

            local lbl = Instance.new("TextLabel", f)
            lbl.Size                   = UDim2.new(1, -22, 1, 0)
            lbl.Position               = UDim2.new(0, 11, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = cfg.Text or ""
            lbl.TextColor3             = C.TEXT_MID
            lbl.TextSize               = 12
            lbl.Font                   = Enum.Font.Gotham
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.TextWrapped            = true

            local L = {}
            function L:Set(t) lbl.Text = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            return L
        end

        -- Toggle
        function Tab:CreateToggle(cfg)
            local flag    = cfg.Flag
            local enabled = cfg.CurrentValue or false

            local row = Instance.new("TextButton", content)
            row.Size             = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = C.SURFACE
            row.BorderSizePixel  = 0
            row.Text             = ""
            row.AutoButtonColor  = false
            corner(row, 7)
            local rs = stroke(row, C.BORDER, 1)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size                   = UDim2.new(1, -58, 1, 0)
            lbl.Position               = UDim2.new(0, 11, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = cfg.Name or "Toggle"
            lbl.TextColor3             = C.TEXT_MID
            lbl.TextSize               = 13
            lbl.Font                   = Enum.Font.Gotham
            lbl.TextXAlignment         = Enum.TextXAlignment.Left

            local pill = Instance.new("Frame", row)
            pill.Size             = UDim2.new(0, 38, 0, 21)
            pill.Position         = UDim2.new(1, -52, 0.5, -10.5)
            pill.BackgroundColor3 = C.OFF_PILL
            pill.BorderSizePixel  = 0
            corner(pill, 11)
            stroke(pill, C.BORDER, 1)

            local knob = Instance.new("Frame", pill)
            knob.Size             = UDim2.new(0, 15, 0, 15)
            knob.Position         = UDim2.new(0, 3, 0.5, -7.5)
            knob.BackgroundColor3 = C.ACCENT_D
            knob.BorderSizePixel  = 0
            corner(knob, 8)

            local function setState(val, silent)
                enabled = val
                if flag then
                    flags[flag] = val
                    if not silent then saveConfig() end
                end
                if val then
                    tw(pill, FAST, { BackgroundColor3 = C.ON_PILL })
                    tw(knob, FAST, { Position = UDim2.new(0, 20, 0.5, -7.5), BackgroundColor3 = C.ON })
                    tw(lbl,  FAST, { TextColor3 = C.TEXT })
                    tw(rs,   FAST, { Color = C.BORDER2 })
                    tw(row,  FAST, { BackgroundColor3 = C.SURFACE2 })
                else
                    tw(pill, FAST, { BackgroundColor3 = C.OFF_PILL })
                    tw(knob, FAST, { Position = UDim2.new(0, 3, 0.5, -7.5), BackgroundColor3 = C.ACCENT_D })
                    tw(lbl,  FAST, { TextColor3 = C.TEXT_MID })
                    tw(rs,   FAST, { Color = C.BORDER })
                    tw(row,  FAST, { BackgroundColor3 = C.SURFACE })
                end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            if enabled then setState(true, true) end
            if flag then toggleSetters[flag] = setState end

            row.MouseButton1Click:Connect(function() setState(not enabled) end)
            row.MouseEnter:Connect(function()
                if not enabled then tw(row, FAST, { BackgroundColor3 = C.BTN_HOV }) end
            end)
            row.MouseLeave:Connect(function()
                if not enabled then tw(row, FAST, { BackgroundColor3 = C.SURFACE }) end
            end)
        end

        -- Button
        function Tab:CreateButton(cfg)
            local btn = Instance.new("TextButton", content)
            btn.Size             = UDim2.new(1, 0, 0, 44)
            btn.BackgroundColor3 = C.SURFACE
            btn.BorderSizePixel  = 0
            btn.Text             = cfg.Name or "Button"
            btn.TextColor3       = C.TEXT_MID
            btn.TextSize         = 13
            btn.Font             = Enum.Font.Gotham
            btn.AutoButtonColor  = false
            corner(btn, 7)
            local bs = stroke(btn, C.BORDER, 1)

            btn.MouseButton1Click:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.BTN_ACT, TextColor3 = C.TEXT })
                tw(bs,  FAST, { Color = C.BORDER2 })
                task.delay(0.14, function()
                    tw(btn, MED, { BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_MID })
                    tw(bs,  MED, { Color = C.BORDER })
                end)
                if cfg.Callback then cfg.Callback() end
            end)
            btn.MouseEnter:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.BTN_HOV, TextColor3 = C.TEXT })
                tw(bs,  FAST, { Color = C.BORDER2 })
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_MID })
                tw(bs,  FAST, { Color = C.BORDER })
            end)
        end

        -- TextInput
        function Tab:CreateTextInput(cfg)
            local wrapper = Instance.new("Frame", content)
            wrapper.Size                   = UDim2.new(1, 0, 0, 60)
            wrapper.BackgroundTransparency = 1
            wrapper.BorderSizePixel        = 0

            local lbl = Instance.new("TextLabel", wrapper)
            lbl.Size                   = UDim2.new(1, 0, 0, 16)
            lbl.Position               = UDim2.new(0, 2, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = cfg.Name or "Input"
            lbl.TextColor3             = C.TEXT_MID
            lbl.TextSize               = 11
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextXAlignment         = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", wrapper)
            box.Size              = UDim2.new(1, 0, 0, 38)
            box.Position          = UDim2.new(0, 0, 0, 19)
            box.BackgroundColor3  = C.SURFACE
            box.BorderSizePixel   = 0
            box.Text              = cfg.Default or ""
            box.PlaceholderText   = cfg.Placeholder or "Type here..."
            box.TextColor3        = C.TEXT
            box.PlaceholderColor3 = C.TEXT_DIM
            box.TextSize          = 13
            box.Font              = Enum.Font.Gotham
            box.ClearTextOnFocus  = false
            corner(box, 7)
            local bs = stroke(box, C.BORDER, 1)
            pad(box, 0, 0, 10, 10)

            box.Focused:Connect(function()  tw(bs, FAST, { Color = C.BORDER2 }) end)
            box.FocusLost:Connect(function()
                tw(bs, FAST, { Color = C.BORDER })
                if cfg.Callback then cfg.Callback(box.Text) end
            end)

            local I = {}
            function I:GetValue() return box.Text end
            function I:SetValue(v) box.Text = v end
            function I:Clear() box.Text = "" end
            return I
        end

        -- ── Dropdown ──────────────────────────────────────────────────────
        function Tab:CreateDropdown(cfg)
            local options  = cfg.Options or {}
            local selected = cfg.Default or ""
            local isOpen   = false

            local wrapper = Instance.new("Frame", content)
            wrapper.Size                   = UDim2.new(1, 0, 0, 60)
            wrapper.BackgroundTransparency = 1
            wrapper.BorderSizePixel        = 0
            wrapper.ClipsDescendants       = false

            local lbl = Instance.new("TextLabel", wrapper)
            lbl.Size                   = UDim2.new(1, 0, 0, 16)
            lbl.Position               = UDim2.new(0, 2, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = cfg.Name or "Dropdown"
            lbl.TextColor3             = C.TEXT_MID
            lbl.TextSize               = 11
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextXAlignment         = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton", wrapper)
            btn.Size             = UDim2.new(1, 0, 0, 38)
            btn.Position         = UDim2.new(0, 0, 0, 19)
            btn.BackgroundColor3 = C.SURFACE
            btn.BorderSizePixel  = 0
            btn.Text             = selected ~= "" and selected or "Select..."
            btn.TextColor3       = selected ~= "" and C.TEXT or C.TEXT_DIM
            btn.TextSize         = 12
            btn.Font             = Enum.Font.Gotham
            btn.AutoButtonColor  = false
            btn.TextXAlignment   = Enum.TextXAlignment.Left
            corner(btn, 7)
            local bs = stroke(btn, C.BORDER, 1)
            pad(btn, 0, 0, 10, 28)

            local arrow = Instance.new("TextLabel", btn)
            arrow.Size                   = UDim2.new(0, 24, 1, 0)
            arrow.Position               = UDim2.new(1, -26, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text                   = "▾"
            arrow.TextColor3             = C.TEXT_DIM
            arrow.TextSize               = 12
            arrow.Font                   = Enum.Font.GothamBold

            local dropList = Instance.new("Frame", screenGui)
            dropList.BackgroundColor3 = C.SURFACE2
            dropList.BorderSizePixel  = 0
            dropList.Visible          = false
            dropList.ZIndex           = 60
            corner(dropList, 7)
            stroke(dropList, C.BORDER2, 1)

            local dropSF = Instance.new("ScrollingFrame", dropList)
            dropSF.Size                   = UDim2.new(1, 0, 1, 0)
            dropSF.BackgroundTransparency = 1
            dropSF.BorderSizePixel        = 0
            dropSF.ScrollBarThickness     = 2
            dropSF.ScrollBarImageColor3   = C.BORDER2
            dropSF.CanvasSize             = UDim2.new(0, 0, 0, 0)
            dropSF.AutomaticCanvasSize    = Enum.AutomaticSize.Y
            dropSF.ZIndex                 = 61

            local dropLL = Instance.new("UIListLayout", dropSF)
            dropLL.SortOrder = Enum.SortOrder.LayoutOrder
            dropLL.Padding   = UDim.new(0, 1)

            local dropPad2 = Instance.new("UIPadding", dropSF)
            dropPad2.PaddingTop    = UDim.new(0, 4)
            dropPad2.PaddingBottom = UDim.new(0, 4)

            local Dropdown = {}

            local function closeDropdown()
                if not isOpen then return end
                isOpen = false
                dropList.Visible = false
                tw(bs,  FAST, { Color = C.BORDER })
                tw(btn, FAST, { BackgroundColor3 = C.SURFACE })
                arrow.Text = "▾"
                unregisterDropdown(closeDropdown)
            end

            -- Always rebuilds the visual list (v2.1 fix — no isOpen gate)
            local function refreshList()
                for _, c in ipairs(dropSF:GetChildren()) do
                    if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
                end
                if #options == 0 then
                    local e = Instance.new("TextLabel", dropSF)
                    e.Size                   = UDim2.new(1, 0, 0, 32)
                    e.BackgroundTransparency = 1
                    e.Text                   = "  (empty)"
                    e.TextColor3             = C.TEXT_DIM
                    e.TextSize               = 11
                    e.Font                   = Enum.Font.Gotham
                    e.TextXAlignment         = Enum.TextXAlignment.Left
                    e.ZIndex                 = 62
                else
                    for i, opt in ipairs(options) do
                        local isSel = opt == selected
                        local item = Instance.new("TextButton", dropSF)
                        item.Size             = UDim2.new(1, 0, 0, 34)
                        item.BackgroundColor3 = C.SURFACE2
                        item.BorderSizePixel  = 0
                        item.Text             = "  " .. opt
                        item.TextColor3       = isSel and C.TEXT or C.TEXT_MID
                        item.TextSize         = 12
                        item.Font             = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
                        item.TextXAlignment   = Enum.TextXAlignment.Left
                        item.AutoButtonColor  = false
                        item.LayoutOrder      = i
                        item.ZIndex           = 62

                        if isSel then
                            local selBar = Instance.new("Frame", item)
                            selBar.Size             = UDim2.new(0, 2, 0, 16)
                            selBar.Position         = UDim2.new(0, 0, 0.5, -8)
                            selBar.BackgroundColor3 = C.ACCENT_D
                            selBar.BorderSizePixel  = 0
                            selBar.ZIndex           = 63
                        end

                        item.MouseEnter:Connect(function()
                            tw(item, FAST, { BackgroundColor3 = C.BTN_HOV, TextColor3 = C.TEXT })
                        end)
                        item.MouseLeave:Connect(function()
                            tw(item, FAST, { BackgroundColor3 = C.SURFACE2, TextColor3 = isSel and C.TEXT or C.TEXT_MID })
                        end)
                        item.MouseButton1Click:Connect(function()
                            selected       = opt
                            btn.Text       = opt
                            btn.TextColor3 = C.TEXT
                            closeDropdown()
                            if cfg.Callback then cfg.Callback(opt) end
                        end)
                    end
                end
                local listH = math.min(math.max(#options, 1) * 34 + 8, 196)
                dropList.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, listH)
            end

            btn.MouseButton1Click:Connect(function()
                if isOpen then closeDropdown() return end
                closeAllDropdowns()
                isOpen = true
                registerDropdown(closeDropdown)
                refreshList()
                local absPos  = btn.AbsolutePosition
                local absSize = btn.AbsoluteSize
                local listH   = math.min(math.max(#options, 1) * 34 + 8, 196)
                dropList.Size     = UDim2.new(0, absSize.X, 0, listH)
                dropList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                dropList.Visible  = true
                tw(bs,  FAST, { Color = C.BORDER2 })
                tw(btn, FAST, { BackgroundColor3 = C.BTN_HOV })
                arrow.Text = "▴"
            end)

            btn.MouseEnter:Connect(function() tw(btn, FAST, { BackgroundColor3 = C.BTN_HOV }) end)
            btn.MouseLeave:Connect(function()
                if not isOpen then tw(btn, FAST, { BackgroundColor3 = C.SURFACE }) end
            end)

            -- v2.1: always rebuilds, resets selected if no longer valid
            function Dropdown:SetOptions(newOpts)
                options = newOpts
                local stillValid = false
                for _, o in ipairs(options) do
                    if o == selected then stillValid = true break end
                end
                if not stillValid then
                    selected       = ""
                    btn.Text       = "Select..."
                    btn.TextColor3 = C.TEXT_DIM
                end
                refreshList()
            end

            -- Add a single item without full SetOptions rebuild
            function Dropdown:AddOption(opt)
                for _, o in ipairs(options) do
                    if o == opt then return end
                end
                table.insert(options, opt)
                refreshList()
            end

            -- Remove a single item by value
            function Dropdown:RemoveOption(opt)
                for i, o in ipairs(options) do
                    if o == opt then
                        table.remove(options, i)
                        if selected == opt then
                            selected       = ""
                            btn.Text       = "Select..."
                            btn.TextColor3 = C.TEXT_DIM
                        end
                        refreshList()
                        return
                    end
                end
            end

            function Dropdown:GetSelected() return selected end
            function Dropdown:GetOptions()  return options  end

            function Dropdown:SetSelected(val)
                selected       = val
                btn.Text       = val ~= "" and val or "Select..."
                btn.TextColor3 = val ~= "" and C.TEXT or C.TEXT_DIM
            end

            function Dropdown:Close() closeDropdown() end

            return Dropdown
        end

        return Tab
    end

    -- Read current flag value from outside
    function Window:GetFlag(flag)
        return flags[flag]
    end

    function Window:SetToggle(flag, value)
        local setter = toggleSetters[flag]
        if setter then setter(value, false) end
    end

    function Window:LoadConfiguration()
        local saved = loadConfig()
        for flag, val in pairs(saved) do
            local setter = toggleSetters[flag]
            if setter and type(val) == "boolean" then setter(val, false) end
        end
    end

    return Window
end

return DevNgg
