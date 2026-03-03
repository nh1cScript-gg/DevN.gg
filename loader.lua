-- DevN.gg GUI Library
-- loader.lua — v3.0
-- Added from v2.1:
--   • Loading screen (title, subtitle, animated progress bar)
--   • CreateSlider    — Heartbeat drag, fires callback only on value change
--   • CreateKeybind   — one InputBegan conn, listening mode, hold support
--   • CreateParagraph — title + body, auto-sizing
--   • CreateColorPicker — HSV square + hue bar + hex input, fully code-built
--   • RunService added for Slider/ColorPicker drag loops

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
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
    local winTitle   = config.Name            or "DevN.gg"
    local winSub     = config.LoadingSubtitle or "by DevN.gg"
    local winVer     = config.Version         or "v1.0"
    local toggleKey  = config.ToggleUIKeybind or "K"
    local loadTitle  = config.LoadingTitle    or winTitle
    local loadSub    = config.LoadingSubtitle or "Loading..."

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

    -- ── Loading Screen ────────────────────────────────────────────────────
    local loadFrame = Instance.new("Frame", screenGui)
    loadFrame.Name             = "LoadingScreen"
    loadFrame.Size             = UDim2.new(0, 360, 0, 130)
    loadFrame.Position         = UDim2.new(0.5, -180, 0.5, -65)
    loadFrame.BackgroundColor3 = C.BG
    loadFrame.BorderSizePixel  = 0
    loadFrame.ZIndex           = 50
    corner(loadFrame, 10)
    stroke(loadFrame, C.BORDER, 1)

    local loadShadow = Instance.new("ImageLabel", loadFrame)
    loadShadow.AnchorPoint            = Vector2.new(0.5, 0.5)
    loadShadow.Size                   = UDim2.new(1, 54, 1, 54)
    loadShadow.Position               = UDim2.new(0.5, 0, 0.5, 7)
    loadShadow.BackgroundTransparency = 1
    loadShadow.Image                  = "rbxassetid://6014054385"
    loadShadow.ImageColor3            = Color3.new(0, 0, 0)
    loadShadow.ImageTransparency      = 0.65
    loadShadow.ScaleType              = Enum.ScaleType.Slice
    loadShadow.SliceCenter            = Rect.new(49, 49, 450, 450)
    loadShadow.ZIndex                 = 49

    local loadTitleLbl = Instance.new("TextLabel", loadFrame)
    loadTitleLbl.Size                   = UDim2.new(1, -32, 0, 26)
    loadTitleLbl.Position               = UDim2.new(0, 16, 0, 20)
    loadTitleLbl.BackgroundTransparency = 1
    loadTitleLbl.Text                   = loadTitle
    loadTitleLbl.TextColor3             = C.TEXT
    loadTitleLbl.TextSize               = 17
    loadTitleLbl.Font                   = Enum.Font.GothamBold
    loadTitleLbl.TextXAlignment         = Enum.TextXAlignment.Center
    loadTitleLbl.ZIndex                 = 51

    local loadSubLbl = Instance.new("TextLabel", loadFrame)
    loadSubLbl.Size                   = UDim2.new(1, -32, 0, 16)
    loadSubLbl.Position               = UDim2.new(0, 16, 0, 50)
    loadSubLbl.BackgroundTransparency = 1
    loadSubLbl.Text                   = loadSub
    loadSubLbl.TextColor3             = C.TEXT_MID
    loadSubLbl.TextSize               = 12
    loadSubLbl.Font                   = Enum.Font.Gotham
    loadSubLbl.TextXAlignment         = Enum.TextXAlignment.Center
    loadSubLbl.ZIndex                 = 51

    local progTrack = Instance.new("Frame", loadFrame)
    progTrack.Size             = UDim2.new(1, -32, 0, 3)
    progTrack.Position         = UDim2.new(0, 16, 0, 84)
    progTrack.BackgroundColor3 = C.BORDER
    progTrack.BorderSizePixel  = 0
    progTrack.ZIndex           = 51
    corner(progTrack, 2)

    local progBar = Instance.new("Frame", progTrack)
    progBar.Size             = UDim2.new(0, 0, 1, 0)
    progBar.BackgroundColor3 = C.ACCENT_D
    progBar.BorderSizePixel  = 0
    progBar.ZIndex           = 52
    corner(progBar, 2)

    local loadStatus = Instance.new("TextLabel", loadFrame)
    loadStatus.Size                   = UDim2.new(1, -32, 0, 14)
    loadStatus.Position               = UDim2.new(0, 16, 0, 94)
    loadStatus.BackgroundTransparency = 1
    loadStatus.Text                   = "Initialising..."
    loadStatus.TextColor3             = C.TEXT_DIM
    loadStatus.TextSize               = 10
    loadStatus.Font                   = Enum.Font.Gotham
    loadStatus.TextXAlignment         = Enum.TextXAlignment.Center
    loadStatus.ZIndex                 = 51

    -- Animate progress bar then destroy loading screen
    task.spawn(function()
        local steps = {
            { pct = 0.25, msg = "Loading components..."  },
            { pct = 0.60, msg = "Applying theme..."      },
            { pct = 0.85, msg = "Connecting services..." },
            { pct = 1.00, msg = "Done!"                  },
        }
        for _, step in ipairs(steps) do
            tw(progBar, TweenInfo.new(0.32, Enum.EasingStyle.Quint),
                { Size = UDim2.new(step.pct, 0, 1, 0) })
            loadStatus.Text = step.msg
            task.wait(0.35)
        end
        task.wait(0.18)
        -- fade out
        for _, c in ipairs(loadFrame:GetDescendants()) do
            if c:IsA("TextLabel") then
                tw(c, MED, { TextTransparency = 1 })
            elseif c:IsA("Frame") then
                tw(c, MED, { BackgroundTransparency = 1 })
            elseif c:IsA("ImageLabel") then
                tw(c, MED, { ImageTransparency = 1 })
            end
        end
        tw(loadFrame, MED, { BackgroundTransparency = 1 })
        task.wait(0.25)
        loadFrame:Destroy()
    end)

    -- ── Main frame ────────────────────────────────────────────────────────
    local main = Instance.new("Frame", screenGui)
    main.Name             = "Main"
    main.Size             = UDim2.new(0, 530, 0, 80)
    main.Position         = UDim2.new(0.5, -265, 0, 22)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel  = 0
    main.ClipsDescendants = false
    main.Visible          = false   -- hidden until loading done
    corner(main, 10)
    stroke(main, C.BORDER, 1)
    mainFrame = main

    -- Show main after loading animation finishes
    task.delay(1.75, function() main.Visible = true end)

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

        -- ── Section ───────────────────────────────────────────────────────
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

        -- ── Divider ───────────────────────────────────────────────────────
        function Tab:CreateDivider()
            local div = Instance.new("Frame", content)
            div.Size             = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = C.BORDER
            div.BorderSizePixel  = 0
            local D = {}
            function D:Set(v) div.Visible = v end
            return D
        end

        -- ── Label ─────────────────────────────────────────────────────────
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
            function L:Set(t)      lbl.Text       = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            return L
        end

        -- ── Paragraph (NEW) ───────────────────────────────────────────────
        function Tab:CreateParagraph(cfg)
            local f = Instance.new("Frame", content)
            f.Size             = UDim2.new(1, 0, 0, 0)
            f.AutomaticSize    = Enum.AutomaticSize.Y
            f.BackgroundColor3 = C.SURFACE
            f.BorderSizePixel  = 0
            corner(f, 7)
            stroke(f, C.BORDER, 1)

            local inner = Instance.new("Frame", f)
            inner.Size                   = UDim2.new(1, 0, 0, 0)
            inner.AutomaticSize          = Enum.AutomaticSize.Y
            inner.BackgroundTransparency = 1
            pad(inner, 10, 10, 11, 11)

            local ll = Instance.new("UIListLayout", inner)
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            ll.Padding   = UDim.new(0, 4)

            local titleLbl2 = Instance.new("TextLabel", inner)
            titleLbl2.Size                   = UDim2.new(1, 0, 0, 0)
            titleLbl2.AutomaticSize          = Enum.AutomaticSize.Y
            titleLbl2.BackgroundTransparency = 1
            titleLbl2.Text                   = cfg.Title or ""
            titleLbl2.TextColor3             = C.TEXT
            titleLbl2.TextSize               = 13
            titleLbl2.Font                   = Enum.Font.GothamBold
            titleLbl2.TextXAlignment         = Enum.TextXAlignment.Left
            titleLbl2.TextWrapped            = true
            titleLbl2.LayoutOrder            = 1

            local bodyLbl = Instance.new("TextLabel", inner)
            bodyLbl.Size                   = UDim2.new(1, 0, 0, 0)
            bodyLbl.AutomaticSize          = Enum.AutomaticSize.Y
            bodyLbl.BackgroundTransparency = 1
            bodyLbl.Text                   = cfg.Content or ""
            bodyLbl.TextColor3             = C.TEXT_MID
            bodyLbl.TextSize               = 12
            bodyLbl.Font                   = Enum.Font.Gotham
            bodyLbl.TextXAlignment         = Enum.TextXAlignment.Left
            bodyLbl.TextWrapped            = true
            bodyLbl.LayoutOrder            = 2

            local P = {}
            function P:Set(t, b)
                titleLbl2.Text = t or titleLbl2.Text
                bodyLbl.Text   = b or bodyLbl.Text
            end
            function P:SetTitle(t)   titleLbl2.Text = t end
            function P:SetContent(b) bodyLbl.Text   = b end
            return P
        end

        -- ── Toggle ────────────────────────────────────────────────────────
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

        -- ── Button ────────────────────────────────────────────────────────
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
                tw(bs,  MED, { Color = C.BORDER })
            end)
        end

        -- ── TextInput ─────────────────────────────────────────────────────
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
            function I:Clear()     box.Text = "" end
            return I
        end

        -- ── Slider (NEW) ──────────────────────────────────────────────────
        -- Heartbeat connection only lives while mouse is held — zero idle cost
        function Tab:CreateSlider(cfg)
            local flag     = cfg.Flag
            local min      = cfg.Min       or 0
            local max      = cfg.Max       or 100
            local inc      = cfg.Increment or 1
            local suffix   = cfg.Suffix    or ""
            local value    = math.clamp(cfg.Default or min, min, max)
            local dragging = false
            local dragConn = nil

            local wrapper = Instance.new("Frame", content)
            wrapper.Size             = UDim2.new(1, 0, 0, 58)
            wrapper.BackgroundColor3 = C.SURFACE
            wrapper.BorderSizePixel  = 0
            corner(wrapper, 7)
            local ws = stroke(wrapper, C.BORDER, 1)

            local nameLbl = Instance.new("TextLabel", wrapper)
            nameLbl.Size                   = UDim2.new(1, -80, 0, 20)
            nameLbl.Position               = UDim2.new(0, 11, 0, 8)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text                   = cfg.Name or "Slider"
            nameLbl.TextColor3             = C.TEXT_MID
            nameLbl.TextSize               = 13
            nameLbl.Font                   = Enum.Font.Gotham
            nameLbl.TextXAlignment         = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel", wrapper)
            valLbl.Size                   = UDim2.new(0, 70, 0, 20)
            valLbl.Position               = UDim2.new(1, -80, 0, 8)
            valLbl.BackgroundTransparency = 1
            valLbl.TextColor3             = C.TEXT_DIM
            valLbl.TextSize               = 12
            valLbl.Font                   = Enum.Font.GothamBold
            valLbl.TextXAlignment         = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", wrapper)
            track.Size             = UDim2.new(1, -22, 0, 4)
            track.Position         = UDim2.new(0, 11, 0, 40)
            track.BackgroundColor3 = C.BORDER
            track.BorderSizePixel  = 0
            corner(track, 2)

            local fill = Instance.new("Frame", track)
            fill.Size             = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = C.ACCENT_D
            fill.BorderSizePixel  = 0
            corner(fill, 2)

            local knob = Instance.new("Frame", track)
            knob.Size             = UDim2.new(0, 10, 0, 10)
            knob.AnchorPoint      = Vector2.new(0.5, 0.5)
            knob.Position         = UDim2.new(0, 0, 0.5, 0)
            knob.BackgroundColor3 = C.TEXT_MID
            knob.BorderSizePixel  = 0
            corner(knob, 6)

            -- Invisible full-size interact layer
            local interact = Instance.new("TextButton", wrapper)
            interact.Size                   = UDim2.new(1, 0, 1, 0)
            interact.BackgroundTransparency = 1
            interact.Text                   = ""
            interact.ZIndex                 = 5

            local function updateVisual(v)
                local ratio = (v - min) / (max - min)
                tw(fill,  FAST, { Size     = UDim2.new(ratio, 0, 1, 0) })
                tw(knob,  FAST, { Position = UDim2.new(ratio, 0, 0.5, 0) })
                valLbl.Text = tostring(v) .. suffix
            end

            local function setValue(v, silent)
                -- quantise to increment
                local q       = math.floor(v / inc + 0.5) * inc
                local clamped = math.clamp(
                    math.floor(q * 1e7 + 0.5) / 1e7,  -- floating point safety
                    min, max)
                if clamped == value then return end
                value = clamped
                updateVisual(value)
                if flag then
                    flags[flag] = value
                    if not silent then saveConfig() end
                end
                if not silent and cfg.Callback then cfg.Callback(value) end
            end

            local function seekMouse()
                local mX = UserInputService:GetMouseLocation().X
                local tX = track.AbsolutePosition.X
                local tW = track.AbsoluteSize.X
                if tW <= 0 then return end
                setValue(min + math.clamp((mX - tX) / tW, 0, 1) * (max - min))
            end

            interact.MouseButton1Down:Connect(function()
                dragging = true
                tw(ws, FAST, { Color = C.BORDER2 })
                if dragConn then dragConn:Disconnect() end
                dragConn = RunService.Heartbeat:Connect(function()
                    if dragging then
                        seekMouse()
                    else
                        dragConn:Disconnect()
                        dragConn = nil
                        tw(ws, FAST, { Color = C.BORDER })
                        saveConfig()
                    end
                end)
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            interact.MouseEnter:Connect(function()
                tw(wrapper, FAST, { BackgroundColor3 = C.BTN_HOV })
            end)
            interact.MouseLeave:Connect(function()
                if not dragging then tw(wrapper, FAST, { BackgroundColor3 = C.SURFACE }) end
            end)

            -- Init
            local initRatio = (value - min) / (max - min)
            fill.Size     = UDim2.new(initRatio, 0, 1, 0)
            knob.Position = UDim2.new(initRatio, 0, 0.5, 0)
            valLbl.Text   = tostring(value) .. suffix
            if flag then flags[flag] = value end

            local Slider = {}
            function Slider:Set(v, silent) setValue(v, silent) end
            function Slider:Get()          return value         end
            return Slider
        end

        -- ── Keybind (NEW) ─────────────────────────────────────────────────
        -- Single InputBegan connection; listening mode captures one key then disconnects
        function Tab:CreateKeybind(cfg)
            local flag       = cfg.Flag
            local currentKey = cfg.Default or Enum.KeyCode.Unknown
            local listening  = false
            local holdConn   = nil

            local blacklist  = { [Enum.KeyCode.Unknown] = true }
            if cfg.Blacklist then
                for _, k in ipairs(cfg.Blacklist) do blacklist[k] = true end
            end

            local wrapper = Instance.new("Frame", content)
            wrapper.Size             = UDim2.new(1, 0, 0, 46)
            wrapper.BackgroundColor3 = C.SURFACE
            wrapper.BorderSizePixel  = 0
            corner(wrapper, 7)
            local ws = stroke(wrapper, C.BORDER, 1)

            local nameLbl = Instance.new("TextLabel", wrapper)
            nameLbl.Size                   = UDim2.new(1, -110, 1, 0)
            nameLbl.Position               = UDim2.new(0, 11, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text                   = cfg.Name or "Keybind"
            nameLbl.TextColor3             = C.TEXT_MID
            nameLbl.TextSize               = 13
            nameLbl.Font                   = Enum.Font.Gotham
            nameLbl.TextXAlignment         = Enum.TextXAlignment.Left

            local badge = Instance.new("Frame", wrapper)
            badge.Size             = UDim2.new(0, 88, 0, 26)
            badge.Position         = UDim2.new(1, -100, 0.5, -13)
            badge.BackgroundColor3 = C.SURFACE2
            badge.BorderSizePixel  = 0
            corner(badge, 5)
            local bs = stroke(badge, C.BORDER, 1)

            local keyLbl = Instance.new("TextLabel", badge)
            keyLbl.Size                   = UDim2.fromScale(1, 1)
            keyLbl.BackgroundTransparency = 1
            keyLbl.TextColor3             = C.TEXT_MID
            keyLbl.TextSize               = 11
            keyLbl.Font                   = Enum.Font.GothamBold
            keyLbl.TextXAlignment         = Enum.TextXAlignment.Center

            local interact = Instance.new("TextButton", wrapper)
            interact.Size                   = UDim2.fromScale(1, 1)
            interact.BackgroundTransparency = 1
            interact.Text                   = ""
            interact.ZIndex                 = 5

            local function keyName(kc)
                if kc == Enum.KeyCode.Unknown then return "None" end
                local s   = tostring(kc)
                local dot = s:find("%.[^%.]*$")
                return dot and s:sub(dot + 1) or s
            end

            local function setKey(kc, silent)
                currentKey  = kc
                keyLbl.Text = keyName(kc)
                if flag then
                    flags[flag] = keyName(kc)
                    if not silent then saveConfig() end
                end
                if not silent and cfg.Callback then cfg.Callback(kc) end
            end

            local function stopListening()
                listening   = false
                keyLbl.Text = keyName(currentKey)
                tw(bs,    FAST, { Color = C.BORDER })
                tw(badge, FAST, { BackgroundColor3 = C.SURFACE2 })
                tw(ws,    FAST, { Color = C.BORDER })
                tw(wrapper, FAST, { BackgroundColor3 = C.SURFACE })
            end

            local function startListening()
                listening   = true
                keyLbl.Text = "..."
                tw(bs,    FAST, { Color = C.BORDER2 })
                tw(badge, FAST, { BackgroundColor3 = C.BTN_ACT })
                tw(ws,    FAST, { Color = C.BORDER2 })
            end

            interact.MouseButton1Click:Connect(function()
                if listening then stopListening() else startListening() end
            end)
            interact.MouseEnter:Connect(function()
                tw(wrapper, FAST, { BackgroundColor3 = C.BTN_HOV })
            end)
            interact.MouseLeave:Connect(function()
                if not listening then tw(wrapper, FAST, { BackgroundColor3 = C.SURFACE }) end
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

                -- Capture new binding
                if listening then
                    if not blacklist[input.KeyCode] then
                        setKey(input.KeyCode, false)
                        stopListening()
                    end
                    return
                end

                -- Fire callback
                if input.KeyCode ~= currentKey or gpe then return end

                if cfg.HoldToInteract then
                    local held = true
                    if holdConn then holdConn:Disconnect() end
                    holdConn = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.KeyCode == currentKey then
                            held = false
                            holdConn:Disconnect()
                            holdConn = nil
                            pcall(cfg.Callback, false)
                        end
                    end)
                    pcall(cfg.Callback, true)
                else
                    pcall(cfg.Callback, currentKey)
                end
            end)

            setKey(currentKey, true)

            local Keybind = {}
            function Keybind:Set(kc, silent) setKey(kc, silent) end
            function Keybind:Get()           return currentKey   end
            return Keybind
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

            -- v2.1: always rebuilds regardless of open state
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

            function Dropdown:AddOption(opt)
                for _, o in ipairs(options) do
                    if o == opt then return end
                end
                table.insert(options, opt)
                refreshList()
            end

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

        -- ── ColorPicker (NEW) ─────────────────────────────────────────────
        -- Collapsed swatch row → expands to HSV square + hue bar + hex input
        -- Everything is pure Lua Instance.new — no asset IDs required
        function Tab:CreateColorPicker(cfg)
            local flag    = cfg.Flag
            local color   = cfg.Default or Color3.fromRGB(255, 100, 100)
            local h, s, v = color:ToHSV()
            local isOpen  = false

            -- ── Collapsed row ─────────────────────────────────────────────
            local row = Instance.new("TextButton", content)
            row.Size             = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = C.SURFACE
            row.BorderSizePixel  = 0
            row.Text             = ""
            row.AutoButtonColor  = false
            corner(row, 7)
            local rs = stroke(row, C.BORDER, 1)

            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size                   = UDim2.new(1, -70, 1, 0)
            nameLbl.Position               = UDim2.new(0, 11, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text                   = cfg.Name or "Color"
            nameLbl.TextColor3             = C.TEXT_MID
            nameLbl.TextSize               = 13
            nameLbl.Font                   = Enum.Font.Gotham
            nameLbl.TextXAlignment         = Enum.TextXAlignment.Left

            local swatch = Instance.new("Frame", row)
            swatch.Size             = UDim2.new(0, 30, 0, 18)
            swatch.Position         = UDim2.new(1, -50, 0.5, -9)
            swatch.BorderSizePixel  = 0
            corner(swatch, 4)
            stroke(swatch, C.BORDER, 1)

            local chevron = Instance.new("TextLabel", row)
            chevron.Size                   = UDim2.new(0, 14, 1, 0)
            chevron.Position               = UDim2.new(1, -18, 0, 0)
            chevron.BackgroundTransparency = 1
            chevron.Text                   = "▾"
            chevron.TextColor3             = C.TEXT_DIM
            chevron.TextSize               = 12
            chevron.Font                   = Enum.Font.GothamBold

            -- ── Expanded panel ────────────────────────────────────────────
            local panel = Instance.new("Frame", content)
            panel.Size             = UDim2.new(1, 0, 0, 168)
            panel.BackgroundColor3 = C.SURFACE2
            panel.BorderSizePixel  = 0
            panel.Visible          = false
            corner(panel, 7)
            stroke(panel, C.BORDER, 1)
            pad(panel, 9, 9, 9, 9)

            -- SV box (colour square)
            local svBox = Instance.new("Frame", panel)
            svBox.Size             = UDim2.new(1, -28, 1, -38)
            svBox.Position         = UDim2.new(0, 0, 0, 0)
            svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svBox.BorderSizePixel  = 0
            corner(svBox, 5)

            -- White-to-transparent (left → right = saturation)
            local wGrad = Instance.new("UIGradient", svBox)
            wGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
            })
            wGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })

            -- Black overlay top-to-bottom (value axis)
            local blackOverlay = Instance.new("Frame", svBox)
            blackOverlay.Size             = UDim2.fromScale(1, 1)
            blackOverlay.BackgroundColor3 = Color3.new(0,0,0)
            blackOverlay.BorderSizePixel  = 0
            corner(blackOverlay, 5)
            local bGrad = Instance.new("UIGradient", blackOverlay)
            bGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            })
            bGrad.Rotation = 90

            -- Knob inside SV box
            local svKnob = Instance.new("Frame", svBox)
            svKnob.Size             = UDim2.new(0, 10, 0, 10)
            svKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
            svKnob.Position         = UDim2.new(s, 0, 1 - v, 0)
            svKnob.BackgroundColor3 = Color3.new(1,1,1)
            svKnob.BorderSizePixel  = 0
            svKnob.ZIndex           = 5
            corner(svKnob, 6)
            stroke(svKnob, Color3.new(0,0,0), 1)

            -- Hue bar (right side)
            local hueBar = Instance.new("Frame", panel)
            hueBar.Size             = UDim2.new(0, 14, 1, -38)
            hueBar.Position         = UDim2.new(1, -14, 0, 0)
            hueBar.BorderSizePixel  = 0
            corner(hueBar, 3)
            stroke(hueBar, C.BORDER, 1)

            local hueGrad = Instance.new("UIGradient", hueBar)
            hueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
            })
            hueGrad.Rotation = 90

            local hueKnob = Instance.new("Frame", hueBar)
            hueKnob.Size             = UDim2.new(1, 4, 0, 4)
            hueKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
            hueKnob.Position         = UDim2.new(0.5, 0, h, 0)
            hueKnob.BackgroundColor3 = Color3.new(1,1,1)
            hueKnob.BorderSizePixel  = 0
            hueKnob.ZIndex           = 5
            corner(hueKnob, 2)
            stroke(hueKnob, Color3.new(0,0,0), 1)

            -- Hex input
            local hexBox = Instance.new("TextBox", panel)
            hexBox.Size              = UDim2.new(1, 0, 0, 26)
            hexBox.Position          = UDim2.new(0, 0, 1, -26)
            hexBox.BackgroundColor3  = C.SURFACE
            hexBox.BorderSizePixel   = 0
            hexBox.TextColor3        = C.TEXT
            hexBox.PlaceholderColor3 = C.TEXT_DIM
            hexBox.PlaceholderText   = "#RRGGBB"
            hexBox.TextSize          = 12
            hexBox.Font              = Enum.Font.GothamBold
            hexBox.ClearTextOnFocus  = false
            hexBox.TextXAlignment    = Enum.TextXAlignment.Center
            corner(hexBox, 5)
            local hbs = stroke(hexBox, C.BORDER, 1)

            local function toHex(c3)
                return string.format("#%02X%02X%02X",
                    math.floor(c3.R * 255 + 0.5),
                    math.floor(c3.G * 255 + 0.5),
                    math.floor(c3.B * 255 + 0.5))
            end

            local function updateAll()
                local col = Color3.fromHSV(h, s, v)
                color = col
                swatch.BackgroundColor3 = col
                svBox.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
                svKnob.Position         = UDim2.new(s, 0, 1 - v, 0)
                hueKnob.Position        = UDim2.new(0.5, 0, h, 0)
                hexBox.Text             = toHex(col)
                if flag then flags[flag] = { R = col.R, G = col.G, B = col.B } end
                if cfg.Callback then pcall(cfg.Callback, col) end
            end

            -- SV drag
            local svDragging = false
            local svInteract = Instance.new("TextButton", svBox)
            svInteract.Size                   = UDim2.fromScale(1, 1)
            svInteract.BackgroundTransparency = 1
            svInteract.Text                   = ""
            svInteract.ZIndex                 = 4

            svInteract.MouseButton1Down:Connect(function()  svDragging = true  end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDragging  = false
                end
            end)
            RunService.Heartbeat:Connect(function()
                if not svDragging then return end
                local mPos  = UserInputService:GetMouseLocation()
                local aPos  = svBox.AbsolutePosition
                local aSize = svBox.AbsoluteSize
                s = math.clamp((mPos.X - aPos.X) / aSize.X, 0, 1)
                v = 1 - math.clamp((mPos.Y - aPos.Y) / aSize.Y, 0, 1)
                updateAll()
            end)

            -- Hue drag
            local hueDragging = false
            local hueInteract = Instance.new("TextButton", hueBar)
            hueInteract.Size                   = UDim2.fromScale(1, 1)
            hueInteract.BackgroundTransparency = 1
            hueInteract.Text                   = ""
            hueInteract.ZIndex                 = 4

            hueInteract.MouseButton1Down:Connect(function() hueDragging = true  end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = false
                end
            end)
            RunService.Heartbeat:Connect(function()
                if not hueDragging then return end
                local mPos  = UserInputService:GetMouseLocation()
                local aPos  = hueBar.AbsolutePosition
                local aSize = hueBar.AbsoluteSize
                h = math.clamp((mPos.Y - aPos.Y) / aSize.Y, 0, 1)
                updateAll()
            end)

            -- Hex commit on focus lost
            hexBox.Focused:Connect(function()  tw(hbs, FAST, { Color = C.BORDER2 }) end)
            hexBox.FocusLost:Connect(function()
                tw(hbs, FAST, { Color = C.BORDER })
                local txt = hexBox.Text:gsub("#", "")
                if #txt == 6 then
                    local r = tonumber(txt:sub(1,2), 16)
                    local g = tonumber(txt:sub(3,4), 16)
                    local b = tonumber(txt:sub(5,6), 16)
                    if r and g and b then
                        h, s, v = Color3.fromRGB(r, g, b):ToHSV()
                        updateAll()
                    end
                end
            end)

            -- Toggle open / close
            row.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                panel.Visible = isOpen
                chevron.Text  = isOpen and "▴" or "▾"
                if isOpen then
                    updateAll()
                    tw(rs, FAST, { Color = C.BORDER2 })
                    tw(row, FAST, { BackgroundColor3 = C.BTN_HOV })
                else
                    tw(rs, FAST, { Color = C.BORDER })
                    tw(row, FAST, { BackgroundColor3 = C.SURFACE })
                end
            end)
            row.MouseEnter:Connect(function()
                tw(row, FAST, { BackgroundColor3 = C.BTN_HOV })
            end)
            row.MouseLeave:Connect(function()
                if not isOpen then tw(row, FAST, { BackgroundColor3 = C.SURFACE }) end
            end)

            updateAll()

            local CP = {}
            function CP:Set(c3, silent)
                color = c3
                h, s, v = c3:ToHSV()
                updateAll()
                if not silent and cfg.Callback then pcall(cfg.Callback, c3) end
            end
            function CP:Get() return color end
            return CP
        end

        return Tab
    end

    -- ── Window helpers ────────────────────────────────────────────────────
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
            if setter and type(val) == "boolean" then setter(val, true) end
        end
    end

    return Window
end

return DevNgg
