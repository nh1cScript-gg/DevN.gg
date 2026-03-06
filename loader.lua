-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║                   DevN.gg  UI Library  v4.0                        ║
-- ║            Sidebar layout  ·  Navy #022658 theme                   ║
-- ║                  github.com/nh1cScript-gg/DevN.gg                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝

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

-- ══════════════════════════════════════════════════════════════
-- DROPDOWN TRACKER
-- ══════════════════════════════════════════════════════════════
local _openDropdowns = {}
local function closeAllDropdowns()
    for _, fn in ipairs(_openDropdowns) do pcall(fn) end
    table.clear(_openDropdowns)
end
local function registerDropdown(fn)   table.insert(_openDropdowns, fn) end
local function unregisterDropdown(fn)
    for i = #_openDropdowns, 1, -1 do
        if _openDropdowns[i] == fn then table.remove(_openDropdowns, i) end
    end
end

-- ══════════════════════════════════════════════════════════════
-- CONFIG PERSISTENCE
-- ══════════════════════════════════════════════════════════════
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

-- ══════════════════════════════════════════════════════════════
-- SAFE GUI PARENTING
-- ══════════════════════════════════════════════════════════════
local function safeParent(gui)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    ok = pcall(function() gui.Parent = gethui() end)
    if ok and gui.Parent then return end
    pcall(function() gui.Parent = playerGui end)
end

-- ══════════════════════════════════════════════════════════════
-- COLOUR PALETTE  —  Navy #022658 theme
-- ══════════════════════════════════════════════════════════════
local C = {
    -- Sidebar
    SIDEBAR       = Color3.fromRGB(2,   38,  88),   -- #022658 navy
    SIDEBAR_HDR   = Color3.fromRGB(1,   28,  66),   -- darker navy header
    SIDEBAR_BTN   = Color3.fromRGB(3,   48, 108),   -- tab button idle
    SIDEBAR_HOV   = Color3.fromRGB(4,   58, 128),   -- tab hover
    SIDEBAR_ACT   = Color3.fromRGB(255, 255, 255),  -- active tab bg
    SIDEBAR_ICON  = Color3.fromRGB(120, 160, 220),  -- idle icon/text
    SIDEBAR_IACT  = Color3.fromRGB(2,   38,  88),   -- active icon text (on white)
    SIDEBAR_LINE  = Color3.fromRGB(5,   60, 130),   -- divider lines

    -- Content panel
    BG            = Color3.fromRGB(10,  12,  18),   -- very dark bg
    SURFACE       = Color3.fromRGB(16,  20,  30),   -- card bg
    SURFACE2      = Color3.fromRGB(22,  28,  42),   -- elevated card
    SURFACE3      = Color3.fromRGB(28,  36,  54),   -- hover state

    -- Borders
    BORDER        = Color3.fromRGB(30,  45,  80),
    BORDER2       = Color3.fromRGB(50,  80, 140),

    -- Text
    TEXT          = Color3.fromRGB(220, 230, 255),
    TEXT_MID      = Color3.fromRGB(130, 160, 210),
    TEXT_DIM      = Color3.fromRGB(55,  75, 120),

    -- Accent
    ACCENT        = Color3.fromRGB(80,  140, 255),  -- bright blue
    ACCENT_SOFT   = Color3.fromRGB(40,  80,  180),

    -- States
    ON            = Color3.fromRGB(100, 220, 140),
    ON_PILL       = Color3.fromRGB(15,  60,  35),
    OFF_PILL      = Color3.fromRGB(18,  24,  40),

    -- Buttons
    BTN_HOV       = Color3.fromRGB(20,  28,  50),
    BTN_ACT       = Color3.fromRGB(30,  45,  80),

    -- Notifications
    NOTIF_BG      = Color3.fromRGB(12,  20,  40),

    -- Utility
    RED           = Color3.fromRGB(220,  60,  60),
    AMBER         = Color3.fromRGB(210, 170,  50),
    WHITE         = Color3.fromRGB(255, 255, 255),
    BLACK         = Color3.fromRGB(0,     0,   0),
}

local FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.20, Enum.EasingStyle.Quint)
local function tw(o, i, p) TweenService:Create(o, i, p):Play() end

-- ══════════════════════════════════════════════════════════════
-- INSTANCE HELPERS
-- ══════════════════════════════════════════════════════════════
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(parent, r)
    return make("UICorner", {CornerRadius = UDim.new(0, r or 6)}, parent)
end

local function stroke(parent, col, th, tr)
    local s = make("UIStroke", {
        Color        = col or C.BORDER,
        Thickness    = th  or 1,
        Transparency = tr  or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
    return s
end

local function pad(parent, t, b, l, r)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, parent)
end

local function listLayout(parent, spacing, dir, halign, valign)
    return make("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = dir    or Enum.FillDirection.Vertical,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = valign or Enum.VerticalAlignment.Top,
        Padding             = UDim.new(0, spacing or 0),
    }, parent)
end

-- ══════════════════════════════════════════════════════════════
-- MODULE
-- ══════════════════════════════════════════════════════════════
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
    if mainFrame and mainFrame.Parent then mainFrame.Parent:Destroy() end
end

-- ══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════
local notifGui = make("ScreenGui", {
    Name           = "DevNggNotif",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder   = 999,
})
pcall(function() notifGui.IgnoreGuiInset = true end)
safeParent(notifGui)

local nHolder = make("Frame", {
    Name                   = "NotifHolder",
    Size                   = UDim2.new(0, 290, 1, 0),
    Position               = UDim2.new(1, -304, 0, 0),
    BackgroundTransparency = 1,
}, notifGui)

local nLL = listLayout(nHolder, 6, Enum.FillDirection.Vertical,
    Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
pad(nHolder, 0, 20, 0, 0)

local activeNotifCount = 0
local MAX_NOTIFS       = 5

function DevNgg:Notify(cfg)
    if activeNotifCount >= MAX_NOTIFS then return end
    activeNotifCount += 1

    local title    = cfg.Title    or "DevN.gg"
    local content  = cfg.Content  or ""
    local duration = cfg.Duration or 3

    local card = make("Frame", {
        Size                   = UDim2.new(1, 0, 0, 68),
        BackgroundColor3       = C.NOTIF_BG,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
    }, nHolder)
    corner(card, 8)
    local cs = stroke(card, C.BORDER, 1, 1)

    -- Left accent bar
    local accentBar = make("Frame", {
        Size             = UDim2.new(0, 3, 0, 36),
        Position         = UDim2.new(0, 0, 0.5, -18),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
        BackgroundTransparency = 1,
    }, card)
    corner(accentBar, 2)

    local tLbl = make("TextLabel", {
        Size                   = UDim2.new(1, -22, 0, 20),
        Position               = UDim2.new(0, 14, 0, 12),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = C.TEXT,
        TextTransparency       = 1,
        TextSize               = 13,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
    }, card)

    local sLbl = make("TextLabel", {
        Size                   = UDim2.new(1, -22, 0, 18),
        Position               = UDim2.new(0, 14, 0, 34),
        BackgroundTransparency = 1,
        Text                   = content,
        TextColor3             = C.TEXT_MID,
        TextTransparency       = 1,
        TextSize               = 11,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
    }, card)

    -- Progress bar
    local progBg = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel  = 0,
    }, card)
    local progFill = make("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
    }, progBg)

    -- Animate in
    tw(card,      MED, {BackgroundTransparency = 0})
    tw(cs,        MED, {Transparency = 0})
    tw(accentBar, MED, {BackgroundTransparency = 0})
    tw(tLbl,      MED, {TextTransparency = 0})
    tw(sLbl,      MED, {TextTransparency = 0})
    tw(progFill, TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)})

    task.delay(duration, function()
        tw(card,      MED, {BackgroundTransparency = 1})
        tw(cs,        MED, {Transparency = 1})
        tw(accentBar, MED, {BackgroundTransparency = 1})
        tw(tLbl,      MED, {TextTransparency = 1})
        tw(sLbl,      MED, {TextTransparency = 1})
        task.wait(0.22)
        card:Destroy()
        activeNotifCount -= 1
    end)
end

-- ══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function DevNgg:CreateWindow(config)
    local winTitle  = config.Name            or "DevN.gg"
    local winSub    = config.LoadingSubtitle or "by DevN.gg"
    local winVer    = config.Version         or "v1.0"
    local toggleKey = config.ToggleUIKeybind or "K"
    local loadTitle = config.LoadingTitle    or winTitle
    local loadSub   = config.LoadingSubtitle or "Loading..."

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    -- Screen GUI
    local screenGui = make("ScreenGui", {
        Name           = "DevNggGUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 100,
    })
    pcall(function() screenGui.IgnoreGuiInset = true end)
    safeParent(screenGui)

    -- ── Loading Screen ────────────────────────────────────────────────────
    local loadFrame = make("Frame", {
        Name             = "LoadingScreen",
        Size             = UDim2.new(0, 380, 0, 140),
        Position         = UDim2.new(0.5, -190, 0.5, -70),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel  = 0,
        ZIndex           = 50,
    }, screenGui)
    corner(loadFrame, 10)
    stroke(loadFrame, C.BORDER2, 1)

    make("TextLabel", {
        Size                   = UDim2.new(1, -32, 0, 28),
        Position               = UDim2.new(0, 16, 0, 22),
        BackgroundTransparency = 1,
        Text                   = loadTitle,
        TextColor3             = C.WHITE,
        TextSize               = 18,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 51,
    }, loadFrame)

    make("TextLabel", {
        Size                   = UDim2.new(1, -32, 0, 16),
        Position               = UDim2.new(0, 16, 0, 54),
        BackgroundTransparency = 1,
        Text                   = loadSub,
        TextColor3             = C.SIDEBAR_ICON,
        TextSize               = 12,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 51,
    }, loadFrame)

    local progTrack = make("Frame", {
        Size             = UDim2.new(1, -32, 0, 3),
        Position         = UDim2.new(0, 16, 0, 90),
        BackgroundColor3 = C.SIDEBAR_LINE,
        BorderSizePixel  = 0,
        ZIndex           = 51,
    }, loadFrame)
    corner(progTrack, 2)

    local progBar = make("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.WHITE,
        BorderSizePixel  = 0,
        ZIndex           = 52,
    }, progTrack)
    corner(progBar, 2)

    local loadStatus = make("TextLabel", {
        Size                   = UDim2.new(1, -32, 0, 14),
        Position               = UDim2.new(0, 16, 0, 102),
        BackgroundTransparency = 1,
        Text                   = "Initialising...",
        TextColor3             = C.TEXT_DIM,
        TextSize               = 10,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 51,
    }, loadFrame)

    task.spawn(function()
        local steps = {
            {pct=0.25, msg="Loading components..."},
            {pct=0.60, msg="Applying theme..."},
            {pct=0.85, msg="Connecting services..."},
            {pct=1.00, msg="Ready!"},
        }
        for _, step in ipairs(steps) do
            tw(progBar, TweenInfo.new(0.32, Enum.EasingStyle.Quint),
                {Size = UDim2.new(step.pct, 0, 1, 0)})
            loadStatus.Text = step.msg
            task.wait(0.36)
        end
        task.wait(0.2)
        tw(loadFrame, MED, {BackgroundTransparency = 1})
        for _, d in ipairs(loadFrame:GetDescendants()) do
            if d:IsA("TextLabel") then tw(d, MED, {TextTransparency = 1})
            elseif d:IsA("Frame")  then tw(d, MED, {BackgroundTransparency = 1})
            end
        end
        task.wait(0.25)
        loadFrame:Destroy()
    end)

    -- ══════════════════════════════════════════════════════════
    -- MAIN WINDOW  (Sidebar + Content)
    -- Layout:
    --   [SIDEBAR 180px] [CONTENT fills rest]
    --   Total width: 620px,  Height: auto up to 580px
    -- ══════════════════════════════════════════════════════════
    local SIDEBAR_W  = 180
    local WIN_W      = 620
    local WIN_H_MIN  = 420

    local main = make("Frame", {
        Name             = "Main",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H_MIN),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H_MIN/2),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        Visible          = false,
    }, screenGui)
    corner(main, 10)
    stroke(main, C.BORDER, 1)
    mainFrame = main

    task.delay(1.8, function() main.Visible = true end)

    -- Drop shadow
    make("ImageLabel", {
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.new(1, 60, 1, 60),
        Position               = UDim2.new(0.5, 0, 0.5, 8),
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://6014054385",
        ImageColor3            = Color3.new(0,0,0),
        ImageTransparency      = 0.55,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49,49,450,450),
        ZIndex                 = 0,
    }, main)

    -- ── SIDEBAR ──────────────────────────────────────────────────────────
    local sidebar = make("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SIDEBAR_W, 1, 0),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        ClipsDescendants = true,
    }, main)
    corner(sidebar, 10)

    -- Right edge square corners (sidebar is on left)
    make("Frame", {
        Size             = UDim2.new(0, 10, 1, 0),
        Position         = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, sidebar)

    -- Sidebar header
    local sideHdr = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = C.SIDEBAR_HDR,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, sidebar)

    -- Title in sidebar
    make("TextLabel", {
        Size                   = UDim2.new(1, -16, 0, 24),
        Position               = UDim2.new(0, 12, 0, 16),
        BackgroundTransparency = 1,
        Text                   = winTitle,
        TextColor3             = C.WHITE,
        TextSize               = 16,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, sideHdr)

    make("TextLabel", {
        Size                   = UDim2.new(1, -16, 0, 14),
        Position               = UDim2.new(0, 12, 0, 42),
        BackgroundTransparency = 1,
        Text                   = winSub .. "  " .. winVer,
        TextColor3             = C.SIDEBAR_ICON,
        TextSize               = 10,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, sideHdr)

    -- Divider under header
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.SIDEBAR_LINE,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, sideHdr)

    -- Tab button container (scrollable for many tabs)
    local sideTabScroll = make("ScrollingFrame", {
        Size                   = UDim2.new(1, 0, 1, -118),
        Position               = UDim2.new(0, 0, 0, 81),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = C.SIDEBAR_LINE,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 4,
    }, sidebar)
    pad(sideTabScroll, 8, 8, 0, 0)
    listLayout(sideTabScroll, 3)

    -- Bottom sidebar area (keybind hint)
    local sideBottom = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        Position         = UDim2.new(0, 0, 1, -36),
        BackgroundColor3 = C.SIDEBAR_HDR,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, sidebar)
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.SIDEBAR_LINE,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, sideBottom)
    make("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "[ " .. toggleKey .. " ] Toggle",
        TextColor3             = C.TEXT_DIM,
        TextSize               = 10,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 5,
    }, sideBottom)

    -- ── CONTENT PANEL ────────────────────────────────────────────────────
    local contentPanel = make("Frame", {
        Name             = "ContentPanel",
        Size             = UDim2.new(1, -SIDEBAR_W, 1, 0),
        Position         = UDim2.new(0, SIDEBAR_W, 0, 0),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, main)
    corner(contentPanel, 10)
    -- Square left corners
    make("Frame", {
        Size             = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
    }, contentPanel)

    -- Content header bar
    local contentHdr = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = C.SURFACE,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, contentPanel)

    local tabTitleLbl = make("TextLabel", {
        Size                   = UDim2.new(1, -90, 1, 0),
        Position               = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = C.TEXT,
        TextSize               = 15,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
    }, contentHdr)

    -- Header separator
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, contentHdr)

    -- Close + Minimize buttons in content header
    local function mkCtrl(offX, sym, hoverCol)
        local b = make("TextButton", {
            Size             = UDim2.new(0, 26, 0, 26),
            Position         = UDim2.new(1, offX, 0.5, -13),
            BackgroundColor3 = C.SURFACE2,
            Text             = sym,
            TextColor3       = C.TEXT_DIM,
            TextSize         = 14,
            Font             = Enum.Font.GothamBold,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            ZIndex           = 10,
        }, contentHdr)
        corner(b, 5)
        stroke(b, C.BORDER, 1)
        b.MouseEnter:Connect(function()
            tw(b, FAST, {TextColor3=hoverCol or C.TEXT, BackgroundColor3=C.BTN_HOV})
        end)
        b.MouseLeave:Connect(function()
            tw(b, FAST, {TextColor3=C.TEXT_DIM, BackgroundColor3=C.SURFACE2})
        end)
        return b
    end

    local minimized = false
    local closeBtn  = mkCtrl(-36, "×", C.RED)
    local minBtn    = mkCtrl(-68, "−", C.AMBER)

    closeBtn.MouseButton1Click:Connect(function()
        DevNgg:SetVisibility(false)
    end)

    -- Content scroll area
    local contentClip = make("Frame", {
        Name             = "ContentClip",
        Size             = UDim2.new(1, 0, 1, -49),
        Position         = UDim2.new(0, 0, 0, 49),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 2,
    }, contentPanel)

    -- ── DRAGGING (drag the sidebar header) ──────────────────────────────
    local dragging, dragStart, startPos
    sideHdr.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = main.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            closeAllDropdowns()
            local d = input.Position - dragStart
            main.Position = UDim2.new(0, startPos.X + d.X, 0, startPos.Y + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        pcall(function()
            local key = typeof(toggleKey)=="string" and Enum.KeyCode[toggleKey] or toggleKey
            if input.KeyCode == key then
                DevNgg:SetVisibility(not guiVisible)
            end
        end)
    end)

    -- ══════════════════════════════════════════════════════════
    -- TAB SYSTEM
    -- ══════════════════════════════════════════════════════════
    local tabs      = {}
    local activeTab = nil
    local tabCount  = 0

    local function updateWindowHeight()
        if not activeTab or minimized then return end
        local contentH = activeTab.listLayout.AbsoluteContentSize.Y
        local h = math.clamp(contentH + 49 + 24, WIN_H_MIN, 580)
        tw(main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {Size = UDim2.new(0, WIN_W, 0, h)})
    end

    local function switchTab(tab)
        closeAllDropdowns()
        for _, t in ipairs(tabs) do
            t.content.Visible = false
            -- idle state: dark bg, muted text
            tw(t.sideBtn, FAST, {BackgroundColor3 = C.SIDEBAR, TextColor3 = C.SIDEBAR_ICON})
            if t.sideBtnAccent then
                tw(t.sideBtnAccent, FAST, {BackgroundTransparency = 1})
            end
        end
        tab.content.Visible = true
        activeTab = tab
        tabTitleLbl.Text = tab.name
        -- active state: white pill
        tw(tab.sideBtn, FAST, {BackgroundColor3 = C.SIDEBAR_ACT, TextColor3 = C.SIDEBAR_IACT})
        if tab.sideBtnAccent then
            tw(tab.sideBtnAccent, FAST, {BackgroundTransparency = 0})
        end
        updateWindowHeight()
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        closeAllDropdowns()
        contentClip.Visible = not minimized
        if minimized then
            tw(main, TweenInfo.new(0.18, Enum.EasingStyle.Quint),
                {Size = UDim2.new(0, WIN_W, 0, 48)})
            contentPanel.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
            sideTabScroll.Visible = false
            sideBottom.Visible    = false
        else
            sideTabScroll.Visible = true
            sideBottom.Visible    = true
            updateWindowHeight()
        end
        minBtn.Text = minimized and "+" or "−"
    end)

    -- ══════════════════════════════════════════════════════════
    -- WINDOW OBJECT
    -- ══════════════════════════════════════════════════════════
    local Window = {}

    function Window:CreateTab(name, _icon)
        tabCount += 1
        local tabIndex = tabCount

        -- ── Sidebar button ────────────────────────────────────────────────
        local sBtn = make("TextButton", {
            Name             = name,
            Size             = UDim2.new(1, -16, 0, 36),
            Position         = UDim2.new(0, 8, 0, 0),
            BackgroundColor3 = C.SIDEBAR,
            BorderSizePixel  = 0,
            Text             = "  " .. name,
            TextColor3       = C.SIDEBAR_ICON,
            TextSize         = 12,
            Font             = Enum.Font.GothamSemibold,
            AutoButtonColor  = false,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LayoutOrder      = tabIndex,
            ZIndex           = 5,
        }, sideTabScroll)
        corner(sBtn, 6)

        -- Active left accent bar
        local sBtnAccent = make("Frame", {
            Size             = UDim2.new(0, 3, 0, 20),
            Position         = UDim2.new(0, 0, 0.5, -10),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel  = 0,
            BackgroundTransparency = 1,
            ZIndex           = 6,
        }, sBtn)
        corner(sBtnAccent, 2)

        sBtn.MouseEnter:Connect(function()
            if activeTab and activeTab.sideBtn == sBtn then return end
            tw(sBtn, FAST, {BackgroundColor3 = C.SIDEBAR_HOV, TextColor3 = C.TEXT})
        end)
        sBtn.MouseLeave:Connect(function()
            if activeTab and activeTab.sideBtn == sBtn then return end
            tw(sBtn, FAST, {BackgroundColor3 = C.SIDEBAR, TextColor3 = C.SIDEBAR_ICON})
        end)

        -- ── Content ScrollingFrame ────────────────────────────────────────
        local tabContent = make("ScrollingFrame", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = C.BORDER2,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = false,
            ZIndex                 = 2,
        }, contentClip)

        local tabLL = make("UIListLayout", {
            SortOrder           = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding             = UDim.new(0, 4),
        }, tabContent)

        pad(tabContent, 12, 16, 12, 12)

        local tabData = {
            name        = name,
            sideBtn     = sBtn,
            sideBtnAccent = sBtnAccent,
            content     = tabContent,
            listLayout  = tabLL,
        }
        table.insert(tabs, tabData)

        sBtn.MouseButton1Click:Connect(function() switchTab(tabData) end)

        tabLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if activeTab == tabData then updateWindowHeight() end
        end)

        if tabCount == 1 then
            task.defer(function() switchTab(tabData) end)
        end

        local content = tabContent

        -- ════════════════════════════════════════════════════════
        -- TAB ELEMENT BUILDERS
        -- ════════════════════════════════════════════════════════
        local Tab = {}

        -- ── Section ──────────────────────────────────────────────────────
        function Tab:CreateSection(sName)
            local row = make("Frame", {
                Size                   = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
            }, content)

            make("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = C.BORDER,
                BorderSizePixel  = 0,
            }, row)

            local pill = make("Frame", {
                BackgroundColor3 = C.SIDEBAR,
                BorderSizePixel  = 0,
                AutomaticSize    = Enum.AutomaticSize.X,
                Size             = UDim2.new(0, 0, 1, 0),
            }, row)
            corner(pill, 4)

            make("TextLabel", {
                BackgroundTransparency = 1,
                AutomaticSize          = Enum.AutomaticSize.X,
                Size                   = UDim2.new(0, 0, 1, 0),
                Text                   = "  " .. sName:upper() .. "  ",
                TextColor3             = C.ACCENT,
                TextSize               = 9,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, pill)

            local S = {}
            function S:Set(n)
                pill:FindFirstChildOfClass("TextLabel").Text = "  " .. n:upper() .. "  "
            end
            return S
        end

        -- ── Divider ───────────────────────────────────────────────────────
        function Tab:CreateDivider()
            local div = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = C.BORDER,
                BorderSizePixel  = 0,
            }, content)
            local D = {}
            function D:Set(v) div.Visible = v end
            return D
        end

        -- ── Label ─────────────────────────────────────────────────────────
        function Tab:CreateLabel(cfg)
            local f = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
            }, content)
            corner(f, 6)
            stroke(f, C.BORDER, 1)

            local lbl = make("TextLabel", {
                Size                   = UDim2.new(1, -20, 1, 0),
                Position               = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text                   = cfg.Text or "",
                TextColor3             = C.TEXT_MID,
                TextSize               = 12,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
            }, f)

            local L = {}
            function L:Set(t)      lbl.Text       = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            return L
        end

        -- ── Paragraph ─────────────────────────────────────────────────────
        function Tab:CreateParagraph(cfg)
            local f = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
            }, content)
            corner(f, 6)
            stroke(f, C.BORDER, 1)

            local inner = make("Frame", {
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
            }, f)
            pad(inner, 10, 10, 12, 12)
            local ll = make("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4)}, inner)

            local tLbl = make("TextLabel", {
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text          = cfg.Title   or "",
                TextColor3    = C.TEXT,
                TextSize      = 13,
                Font          = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped   = true,
                LayoutOrder   = 1,
            }, inner)

            local bLbl = make("TextLabel", {
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text          = cfg.Content or "",
                TextColor3    = C.TEXT_MID,
                TextSize      = 12,
                Font          = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped   = true,
                LayoutOrder   = 2,
            }, inner)

            local P = {}
            function P:Set(t, b)       tLbl.Text = t or tLbl.Text; bLbl.Text = b or bLbl.Text end
            function P:SetTitle(t)     tLbl.Text = t end
            function P:SetContent(b)   bLbl.Text = b end
            return P
        end

        -- ── Toggle ────────────────────────────────────────────────────────
        function Tab:CreateToggle(cfg)
            local flag    = cfg.Flag
            local enabled = cfg.CurrentValue or false

            local row = make("TextButton", {
                Size             = UDim2.new(1, 0, 0, 46),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
                Text             = "",
                AutoButtonColor  = false,
            }, content)
            corner(row, 6)
            local rs = stroke(row, C.BORDER, 1)

            -- Left accent stripe
            local stripe = make("Frame", {
                Size             = UDim2.new(0, 3, 0, 28),
                Position         = UDim2.new(0, 0, 0.5, -14),
                BackgroundColor3 = C.ACCENT,
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
            }, row)
            corner(stripe, 2)

            local lbl = make("TextLabel", {
                Size                   = UDim2.new(1, -62, 1, 0),
                Position               = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text                   = cfg.Name or "Toggle",
                TextColor3             = C.TEXT_MID,
                TextSize               = 13,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, row)

            local pill = make("Frame", {
                Size             = UDim2.new(0, 38, 0, 20),
                Position         = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = C.OFF_PILL,
                BorderSizePixel  = 0,
            }, row)
            corner(pill, 10)
            stroke(pill, C.BORDER, 1)

            local knob = make("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = C.TEXT_DIM,
                BorderSizePixel  = 0,
            }, pill)
            corner(knob, 7)

            local function setState(val, silent)
                enabled = val
                if flag then
                    flags[flag] = val
                    if not silent then saveConfig() end
                end
                if val then
                    tw(pill,   FAST, {BackgroundColor3 = C.ON_PILL})
                    tw(knob,   FAST, {Position = UDim2.new(0, 21, 0.5, -7), BackgroundColor3 = C.ON})
                    tw(lbl,    FAST, {TextColor3 = C.TEXT})
                    tw(stripe, FAST, {BackgroundTransparency = 0})
                    tw(rs,     FAST, {Color = C.ACCENT_SOFT})
                    tw(row,    FAST, {BackgroundColor3 = C.SURFACE2})
                else
                    tw(pill,   FAST, {BackgroundColor3 = C.OFF_PILL})
                    tw(knob,   FAST, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = C.TEXT_DIM})
                    tw(lbl,    FAST, {TextColor3 = C.TEXT_MID})
                    tw(stripe, FAST, {BackgroundTransparency = 1})
                    tw(rs,     FAST, {Color = C.BORDER})
                    tw(row,    FAST, {BackgroundColor3 = C.SURFACE})
                end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            if enabled then setState(true, true) end
            if flag then toggleSetters[flag] = setState end

            row.MouseButton1Click:Connect(function() setState(not enabled) end)
            row.MouseEnter:Connect(function()
                if not enabled then tw(row, FAST, {BackgroundColor3 = C.BTN_HOV}) end
            end)
            row.MouseLeave:Connect(function()
                if not enabled then tw(row, FAST, {BackgroundColor3 = C.SURFACE}) end
            end)
        end

        -- ── Button ────────────────────────────────────────────────────────
        function Tab:CreateButton(cfg)
            local btn = make("TextButton", {
                Size             = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
                Text             = cfg.Name or "Button",
                TextColor3       = C.TEXT_MID,
                TextSize         = 13,
                Font             = Enum.Font.Gotham,
                AutoButtonColor  = false,
            }, content)
            corner(btn, 6)
            local bs = stroke(btn, C.BORDER, 1)

            btn.MouseButton1Click:Connect(function()
                tw(btn, FAST, {BackgroundColor3 = C.BTN_ACT, TextColor3 = C.TEXT})
                tw(bs,  FAST, {Color = C.BORDER2})
                task.delay(0.14, function()
                    tw(btn, MED, {BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_MID})
                    tw(bs,  MED, {Color = C.BORDER})
                end)
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            btn.MouseEnter:Connect(function()
                tw(btn, FAST, {BackgroundColor3 = C.BTN_HOV, TextColor3 = C.TEXT})
                tw(bs,  FAST, {Color = C.BORDER2})
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, FAST, {BackgroundColor3 = C.SURFACE, TextColor3 = C.TEXT_MID})
                tw(bs,  MED,  {Color = C.BORDER})
            end)
        end

        -- ── TextInput ─────────────────────────────────────────────────────
        function Tab:CreateTextInput(cfg)
            local wrapper = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 62),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
            }, content)

            make("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 16),
                Position               = UDim2.new(0, 2, 0, 0),
                BackgroundTransparency = 1,
                Text                   = cfg.Name or "Input",
                TextColor3             = C.TEXT_MID,
                TextSize               = 11,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, wrapper)

            local box = make("TextBox", {
                Size              = UDim2.new(1, 0, 0, 38),
                Position          = UDim2.new(0, 0, 0, 20),
                BackgroundColor3  = C.SURFACE,
                BorderSizePixel   = 0,
                Text              = cfg.Default     or "",
                PlaceholderText   = cfg.Placeholder or "Type here...",
                TextColor3        = C.TEXT,
                PlaceholderColor3 = C.TEXT_DIM,
                TextSize          = 13,
                Font              = Enum.Font.Gotham,
                ClearTextOnFocus  = false,
            }, wrapper)
            corner(box, 6)
            local bs = stroke(box, C.BORDER, 1)
            pad(box, 0, 0, 10, 10)

            box.Focused:Connect(function()    tw(bs, FAST, {Color = C.ACCENT_SOFT}) end)
            box.FocusLost:Connect(function()
                tw(bs, FAST, {Color = C.BORDER})
                if cfg.Callback then cfg.Callback(box.Text) end
            end)

            local I = {}
            function I:GetValue() return box.Text end
            function I:SetValue(v) box.Text = v end
            function I:Clear()     box.Text = "" end
            return I
        end

        -- ── Slider ────────────────────────────────────────────────────────
        function Tab:CreateSlider(cfg)
            local flag    = cfg.Flag
            local min     = cfg.Min       or 0
            local max     = cfg.Max       or 100
            local inc     = cfg.Increment or 1
            local suffix  = cfg.Suffix    or ""
            local value   = math.clamp(cfg.Default or min, min, max)
            local dragging = false
            local dragConn = nil

            local wrapper = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
            }, content)
            corner(wrapper, 6)
            local ws = stroke(wrapper, C.BORDER, 1)

            make("TextLabel", {
                Size                   = UDim2.new(1, -80, 0, 20),
                Position               = UDim2.new(0, 11, 0, 8),
                BackgroundTransparency = 1,
                Text                   = cfg.Name or "Slider",
                TextColor3             = C.TEXT_MID,
                TextSize               = 13,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, wrapper)

            local valLbl = make("TextLabel", {
                Size                   = UDim2.new(0, 68, 0, 20),
                Position               = UDim2.new(1, -78, 0, 8),
                BackgroundTransparency = 1,
                TextColor3             = C.ACCENT,
                TextSize               = 12,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Right,
            }, wrapper)

            local track = make("Frame", {
                Size             = UDim2.new(1, -22, 0, 4),
                Position         = UDim2.new(0, 11, 0, 40),
                BackgroundColor3 = C.BORDER,
                BorderSizePixel  = 0,
            }, wrapper)
            corner(track, 2)

            local fill = make("Frame", {
                Size             = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = C.ACCENT,
                BorderSizePixel  = 0,
            }, track)
            corner(fill, 2)

            local knob = make("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = C.WHITE,
                BorderSizePixel  = 0,
            }, track)
            corner(knob, 6)

            local interact = make("TextButton", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = "",
                ZIndex                 = 5,
            }, wrapper)

            local function updateVisual(v)
                local ratio = (v - min) / (max - min)
                tw(fill, FAST, {Size = UDim2.new(ratio, 0, 1, 0)})
                tw(knob, FAST, {Position = UDim2.new(ratio, 0, 0.5, 0)})
                valLbl.Text = tostring(v) .. suffix
            end

            local function setValue(v, silent)
                local q = math.floor(v / inc + 0.5) * inc
                local c = math.clamp(math.floor(q * 1e7 + 0.5) / 1e7, min, max)
                if c == value then return end
                value = c
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
                tw(ws, FAST, {Color = C.ACCENT_SOFT})
                if dragConn then dragConn:Disconnect() end
                dragConn = RunService.Heartbeat:Connect(function()
                    if dragging then seekMouse()
                    else
                        dragConn:Disconnect(); dragConn = nil
                        tw(ws, FAST, {Color = C.BORDER})
                        saveConfig()
                    end
                end)
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            interact.MouseEnter:Connect(function() tw(wrapper, FAST, {BackgroundColor3=C.BTN_HOV}) end)
            interact.MouseLeave:Connect(function()
                if not dragging then tw(wrapper, FAST, {BackgroundColor3=C.SURFACE}) end
            end)

            -- Init
            local ir = (value - min)/(max - min)
            fill.Size     = UDim2.new(ir, 0, 1, 0)
            knob.Position = UDim2.new(ir, 0, 0.5, 0)
            valLbl.Text   = tostring(value) .. suffix
            if flag then flags[flag] = value end

            local Sl = {}
            function Sl:Set(v, s) setValue(v, s) end
            function Sl:Get()     return value   end
            return Sl
        end

        -- ── Keybind ───────────────────────────────────────────────────────
        function Tab:CreateKeybind(cfg)
            local flag       = cfg.Flag
            local currentKey = cfg.Default or Enum.KeyCode.Unknown
            local listening  = false
            local holdConn   = nil
            local blacklist  = {[Enum.KeyCode.Unknown]=true}
            if cfg.Blacklist then
                for _, k in ipairs(cfg.Blacklist) do blacklist[k] = true end
            end

            local wrapper = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 46),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
            }, content)
            corner(wrapper, 6)
            local ws = stroke(wrapper, C.BORDER, 1)

            make("TextLabel", {
                Size                   = UDim2.new(1, -110, 1, 0),
                Position               = UDim2.new(0, 11, 0, 0),
                BackgroundTransparency = 1,
                Text                   = cfg.Name or "Keybind",
                TextColor3             = C.TEXT_MID,
                TextSize               = 13,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, wrapper)

            local badge = make("Frame", {
                Size             = UDim2.new(0, 86, 0, 26),
                Position         = UDim2.new(1, -98, 0.5, -13),
                BackgroundColor3 = C.SURFACE2,
                BorderSizePixel  = 0,
            }, wrapper)
            corner(badge, 5)
            local bs = stroke(badge, C.BORDER, 1)

            local keyLbl = make("TextLabel", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3             = C.TEXT_MID,
                TextSize               = 11,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Center,
            }, badge)

            local interact = make("TextButton", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = "",
                ZIndex                 = 5,
            }, wrapper)

            local function keyName(kc)
                if kc == Enum.KeyCode.Unknown then return "None" end
                local s = tostring(kc)
                local d = s:find("%.[^%.]*$")
                return d and s:sub(d+1) or s
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
                tw(bs,      FAST, {Color=C.BORDER})
                tw(badge,   FAST, {BackgroundColor3=C.SURFACE2})
                tw(ws,      FAST, {Color=C.BORDER})
                tw(wrapper, FAST, {BackgroundColor3=C.SURFACE})
            end

            local function startListening()
                listening   = true
                keyLbl.Text = "..."
                tw(bs,    FAST, {Color=C.ACCENT_SOFT})
                tw(badge, FAST, {BackgroundColor3=C.BTN_ACT})
                tw(ws,    FAST, {Color=C.ACCENT_SOFT})
            end

            interact.MouseButton1Click:Connect(function()
                if listening then stopListening() else startListening() end
            end)
            interact.MouseEnter:Connect(function() tw(wrapper,FAST,{BackgroundColor3=C.BTN_HOV}) end)
            interact.MouseLeave:Connect(function()
                if not listening then tw(wrapper,FAST,{BackgroundColor3=C.SURFACE}) end
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if listening then
                    if not blacklist[input.KeyCode] then
                        setKey(input.KeyCode, false)
                        stopListening()
                    end
                    return
                end
                if input.KeyCode ~= currentKey or gpe then return end
                if cfg.HoldToInteract then
                    local held = true
                    if holdConn then holdConn:Disconnect() end
                    holdConn = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.KeyCode == currentKey then
                            held = false
                            holdConn:Disconnect(); holdConn = nil
                            pcall(cfg.Callback, false)
                        end
                    end)
                    pcall(cfg.Callback, true)
                else
                    pcall(cfg.Callback, currentKey)
                end
            end)

            setKey(currentKey, true)

            local KB = {}
            function KB:Set(kc, s) setKey(kc, s) end
            function KB:Get()      return currentKey end
            return KB
        end

        -- ── Dropdown ──────────────────────────────────────────────────────
        function Tab:CreateDropdown(cfg)
            local options  = cfg.Options or {}
            local selected = cfg.Default or ""
            local isOpen   = false

            local wrapper = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 62),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                ClipsDescendants = false,
            }, content)

            make("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 16),
                Position               = UDim2.new(0, 2, 0, 0),
                BackgroundTransparency = 1,
                Text                   = cfg.Name or "Dropdown",
                TextColor3             = C.TEXT_MID,
                TextSize               = 11,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, wrapper)

            local btn = make("TextButton", {
                Size             = UDim2.new(1, 0, 0, 38),
                Position         = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
                Text             = selected ~= "" and selected or "Select...",
                TextColor3       = selected ~= "" and C.TEXT or C.TEXT_DIM,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                AutoButtonColor  = false,
                TextXAlignment   = Enum.TextXAlignment.Left,
            }, wrapper)
            corner(btn, 6)
            local bs = stroke(btn, C.BORDER, 1)
            pad(btn, 0, 0, 10, 28)

            make("TextLabel", {
                Size                   = UDim2.new(0, 22, 1, 0),
                Position               = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text                   = "▾",
                TextColor3             = C.TEXT_DIM,
                TextSize               = 12,
                Font                   = Enum.Font.GothamBold,
            }, btn)

            -- Dropdown list rendered in screenGui to escape clipping
            local dropList = make("Frame", {
                BackgroundColor3 = C.SURFACE2,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 60,
            }, screenGui)
            corner(dropList, 6)
            stroke(dropList, C.BORDER2, 1)

            local dropSF = make("ScrollingFrame", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                ScrollBarThickness     = 2,
                ScrollBarImageColor3   = C.BORDER2,
                CanvasSize             = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize    = Enum.AutomaticSize.Y,
                ZIndex                 = 61,
            }, dropList)

            local dropLL = make("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1)}, dropSF)
            pad(dropSF, 4, 4, 0, 0)

            local Dropdown = {}

            local function closeDropdown()
                if not isOpen then return end
                isOpen = false
                dropList.Visible = false
                tw(bs,  FAST, {Color=C.BORDER})
                tw(btn, FAST, {BackgroundColor3=C.SURFACE})
                btn:FindFirstChildOfClass("TextLabel").Text = "▾"
                unregisterDropdown(closeDropdown)
            end

            local function refreshList()
                for _, c in ipairs(dropSF:GetChildren()) do
                    if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
                end
                if #options == 0 then
                    make("TextLabel", {
                        Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
                        Text="  (empty)", TextColor3=C.TEXT_DIM, TextSize=11,
                        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=62,
                    }, dropSF)
                else
                    for i, opt in ipairs(options) do
                        local isSel = opt == selected
                        local item = make("TextButton", {
                            Size             = UDim2.new(1, 0, 0, 34),
                            BackgroundColor3 = C.SURFACE2,
                            BorderSizePixel  = 0,
                            Text             = "  " .. opt,
                            TextColor3       = isSel and C.TEXT or C.TEXT_MID,
                            TextSize         = 12,
                            Font             = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                            AutoButtonColor  = false,
                            TextXAlignment   = Enum.TextXAlignment.Left,
                            LayoutOrder      = i,
                            ZIndex           = 62,
                        }, dropSF)
                        if isSel then
                            local bar = make("Frame", {
                                Size=UDim2.new(0,2,0,16), Position=UDim2.new(0,0,0.5,-8),
                                BackgroundColor3=C.ACCENT, BorderSizePixel=0, ZIndex=63,
                            }, item)
                            corner(bar, 1)
                        end
                        item.MouseEnter:Connect(function()
                            tw(item, FAST, {BackgroundColor3=C.BTN_HOV, TextColor3=C.TEXT})
                        end)
                        item.MouseLeave:Connect(function()
                            tw(item, FAST, {BackgroundColor3=C.SURFACE2, TextColor3=isSel and C.TEXT or C.TEXT_MID})
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
                local h = math.min(math.max(#options,1)*34+8, 200)
                dropList.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, h)
            end

            btn.MouseButton1Click:Connect(function()
                if isOpen then closeDropdown() return end
                closeAllDropdowns()
                isOpen = true
                registerDropdown(closeDropdown)
                refreshList()
                local ap = btn.AbsolutePosition
                local as = btn.AbsoluteSize
                local lh = math.min(math.max(#options,1)*34+8, 200)
                dropList.Size     = UDim2.new(0, as.X, 0, lh)
                dropList.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 4)
                dropList.Visible  = true
                tw(bs,  FAST, {Color=C.ACCENT_SOFT})
                tw(btn, FAST, {BackgroundColor3=C.BTN_HOV})
                btn:FindFirstChildOfClass("TextLabel").Text = "▴"
            end)
            btn.MouseEnter:Connect(function() tw(btn,FAST,{BackgroundColor3=C.BTN_HOV}) end)
            btn.MouseLeave:Connect(function()
                if not isOpen then tw(btn,FAST,{BackgroundColor3=C.SURFACE}) end
            end)

            function Dropdown:SetOptions(o)
                options = o
                local ok2 = false
                for _, v in ipairs(options) do if v==selected then ok2=true break end end
                if not ok2 then selected=""; btn.Text="Select..."; btn.TextColor3=C.TEXT_DIM end
                if isOpen then refreshList() end
            end
            function Dropdown:AddOption(o)
                for _, v in ipairs(options) do if v==o then return end end
                table.insert(options,o); if isOpen then refreshList() end
            end
            function Dropdown:RemoveOption(o)
                for i,v in ipairs(options) do
                    if v==o then
                        table.remove(options,i)
                        if selected==o then selected=""; btn.Text="Select..."; btn.TextColor3=C.TEXT_DIM end
                        if isOpen then refreshList() end
                        return
                    end
                end
            end
            function Dropdown:GetSelected() return selected end
            function Dropdown:GetOptions()  return options  end
            function Dropdown:SetSelected(v)
                selected=v; btn.Text=v~="" and v or "Select..."
                btn.TextColor3=v~="" and C.TEXT or C.TEXT_DIM
            end
            function Dropdown:Close() closeDropdown() end
            return Dropdown
        end

        -- ── ColorPicker ───────────────────────────────────────────────────
        function Tab:CreateColorPicker(cfg)
            local flag  = cfg.Flag
            local color = cfg.Default or Color3.fromRGB(80,140,255)
            local h, s, v = color:ToHSV()
            local isOpen = false

            local row = make("TextButton", {
                Size             = UDim2.new(1, 0, 0, 46),
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
                Text             = "",
                AutoButtonColor  = false,
            }, content)
            corner(row, 6)
            local rs = stroke(row, C.BORDER, 1)

            make("TextLabel", {
                Size                   = UDim2.new(1, -70, 1, 0),
                Position               = UDim2.new(0, 11, 0, 0),
                BackgroundTransparency = 1,
                Text                   = cfg.Name or "Color",
                TextColor3             = C.TEXT_MID,
                TextSize               = 13,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
            }, row)

            local swatch = make("Frame", {
                Size             = UDim2.new(0, 28, 0, 16),
                Position         = UDim2.new(1, -50, 0.5, -8),
                BackgroundColor3 = color,
                BorderSizePixel  = 0,
            }, row)
            corner(swatch, 4)
            stroke(swatch, C.BORDER, 1)

            make("TextLabel", {
                Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-18,0,0),
                BackgroundTransparency=1, Text="▾", TextColor3=C.TEXT_DIM,
                TextSize=12, Font=Enum.Font.GothamBold,
            }, row)

            local panel = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 172),
                BackgroundColor3 = C.SURFACE2,
                BorderSizePixel  = 0,
                Visible          = false,
            }, content)
            corner(panel, 6)
            stroke(panel, C.BORDER, 1)
            pad(panel, 9, 9, 9, 9)

            local svBox = make("Frame", {
                Size             = UDim2.new(1, -28, 1, -38),
                BackgroundColor3 = Color3.fromHSV(h,1,1),
                BorderSizePixel  = 0,
            }, panel)
            corner(svBox, 5)

            local wGrad = make("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            }, svBox)

            local bOver = make("Frame", {
                Size             = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel  = 0,
            }, svBox)
            corner(bOver, 5)
            make("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,1),
                    NumberSequenceKeypoint.new(1,0),
                }),
                Rotation = 90,
            }, bOver)

            local svKnob = make("Frame", {
                Size             = UDim2.new(0,10,0,10),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(s,0,1-v,0),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel  = 0,
                ZIndex           = 5,
            }, svBox)
            corner(svKnob, 6)
            stroke(svKnob, Color3.new(0,0,0), 1)

            local hueBar = make("Frame", {
                Size             = UDim2.new(0,14,1,-38),
                Position         = UDim2.new(1,-14,0,0),
                BorderSizePixel  = 0,
            }, panel)
            corner(hueBar, 3)
            stroke(hueBar, C.BORDER, 1)

            make("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1,1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                    ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1,1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1,1)),
                }),
                Rotation = 90,
            }, hueBar)

            local hKnob = make("Frame", {
                Size             = UDim2.new(1,4,0,4),
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(0.5,0,h,0),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel  = 0,
                ZIndex           = 5,
            }, hueBar)
            corner(hKnob, 2)
            stroke(hKnob, Color3.new(0,0,0), 1)

            local hexBox = make("TextBox", {
                Size              = UDim2.new(1,0,0,26),
                Position          = UDim2.new(0,0,1,-26),
                BackgroundColor3  = C.SURFACE,
                BorderSizePixel   = 0,
                TextColor3        = C.TEXT,
                PlaceholderColor3 = C.TEXT_DIM,
                PlaceholderText   = "#RRGGBB",
                TextSize          = 12,
                Font              = Enum.Font.GothamBold,
                ClearTextOnFocus  = false,
                TextXAlignment    = Enum.TextXAlignment.Center,
            }, panel)
            corner(hexBox, 5)
            local hbs = stroke(hexBox, C.BORDER, 1)

            local function toHex(c3)
                return string.format("#%02X%02X%02X",
                    math.floor(c3.R*255+.5), math.floor(c3.G*255+.5), math.floor(c3.B*255+.5))
            end

            local function updateAll()
                local col = Color3.fromHSV(h,s,v)
                color = col
                swatch.BackgroundColor3 = col
                svBox.BackgroundColor3  = Color3.fromHSV(h,1,1)
                svKnob.Position         = UDim2.new(s,0,1-v,0)
                hKnob.Position          = UDim2.new(0.5,0,h,0)
                hexBox.Text             = toHex(col)
                if flag then flags[flag] = {R=col.R,G=col.G,B=col.B} end
                if cfg.Callback then pcall(cfg.Callback, col) end
            end

            -- SV drag
            local svDrag = false
            local svInt = make("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=4,
            }, svBox)
            svInt.MouseButton1Down:Connect(function() svDrag=true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end
            end)
            RunService.Heartbeat:Connect(function()
                if not svDrag then return end
                local m=UserInputService:GetMouseLocation()
                local a=svBox.AbsolutePosition; local sz=svBox.AbsoluteSize
                s=math.clamp((m.X-a.X)/sz.X,0,1)
                v=1-math.clamp((m.Y-a.Y)/sz.Y,0,1)
                updateAll()
            end)

            -- Hue drag
            local hueDrag = false
            local hInt = make("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=4,
            }, hueBar)
            hInt.MouseButton1Down:Connect(function() hueDrag=true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
            end)
            RunService.Heartbeat:Connect(function()
                if not hueDrag then return end
                local m=UserInputService:GetMouseLocation()
                local a=hueBar.AbsolutePosition; local sz=hueBar.AbsoluteSize
                h=math.clamp((m.Y-a.Y)/sz.Y,0,1)
                updateAll()
            end)

            hexBox.Focused:Connect(function()   tw(hbs,FAST,{Color=C.ACCENT_SOFT}) end)
            hexBox.FocusLost:Connect(function()
                tw(hbs,FAST,{Color=C.BORDER})
                local t=hexBox.Text:gsub("#","")
                if #t==6 then
                    local r2=tonumber(t:sub(1,2),16)
                    local g2=tonumber(t:sub(3,4),16)
                    local b2=tonumber(t:sub(5,6),16)
                    if r2 and g2 and b2 then
                        h,s,v=Color3.fromRGB(r2,g2,b2):ToHSV()
                        updateAll()
                    end
                end
            end)

            row.MouseButton1Click:Connect(function()
                isOpen=not isOpen; panel.Visible=isOpen
                row:FindFirstChildOfClass("TextLabel", true).Text = isOpen and "▴" or "▾"
                if isOpen then
                    updateAll()
                    tw(rs,row, FAST,{Color=C.ACCENT_SOFT})
                    tw(row,FAST,{BackgroundColor3=C.BTN_HOV})
                else
                    tw(rs,FAST,{Color=C.BORDER})
                    tw(row,FAST,{BackgroundColor3=C.SURFACE})
                end
            end)
            row.MouseEnter:Connect(function() tw(row,FAST,{BackgroundColor3=C.BTN_HOV}) end)
            row.MouseLeave:Connect(function()
                if not isOpen then tw(row,FAST,{BackgroundColor3=C.SURFACE}) end
            end)

            updateAll()

            local CP = {}
            function CP:Set(c3, silent)
                color=c3; h,s,v=c3:ToHSV(); updateAll()
                if not silent and cfg.Callback then pcall(cfg.Callback,c3) end
            end
            function CP:Get() return color end
            return CP
        end

        return Tab
    end

    -- ── Window helpers ─────────────────────────────────────────────────────
    function Window:GetFlag(flag)    return flags[flag] end

    function Window:SetToggle(flag, value)
        local setter = toggleSetters[flag]
        if setter then setter(value, false) end
    end

    function Window:LoadConfiguration()
        local saved = loadConfig()
        for flag, val in pairs(saved) do
            local setter = toggleSetters[flag]
            if setter and type(val)=="boolean" then setter(val, true) end
        end
    end

    return Window
end

return DevNgg
