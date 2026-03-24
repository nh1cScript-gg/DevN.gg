-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║               SailorPiece UI Library  v3.6                          ║
-- ║        Dark Sidebar  ·  Clean Rows  ·  iOS Toggles                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════
-- MOBILE DETECTION
-- ══════════════════════════════════════════════════════════════
local function isMobile()
    if not UserInputService.TouchEnabled then return false end
    if UserInputService.MouseEnabled then return false end
    local vp = workspace.CurrentCamera.ViewportSize
    return math.min(vp.X, vp.Y) < 600
end
local function uiScale() return isMobile() and 1.3 or 1.0 end
local function px(n) return math.floor(n * uiScale()) end

local flags         = {}
local toggleSetters = {}
local saveFolder    = "SailorPiece"
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
-- CONFIG SAVE / LOAD
-- ══════════════════════════════════════════════════════════════
local function getSavePath() return saveFolder .. "/" .. saveFile .. ".json" end
local function saveConfig()
    pcall(function()
        if not isfolder(saveFolder) then makefolder(saveFolder) end
        local d = {}
        for k, v in pairs(flags) do d[k] = v end
        writefile(getSavePath(), HttpService:JSONEncode(d))
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
-- SAFE GUI PARENT
-- ══════════════════════════════════════════════════════════════
local function safeParent(gui)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    ok = pcall(function() gui.Parent = gethui() end)
    if ok and gui.Parent then return end
    gui.Parent = playerGui
end

-- ══════════════════════════════════════════════════════════════
-- COLOUR PALETTE  — matches reference image exactly
-- Dark near-black base, white text, blue accent toggles
-- ══════════════════════════════════════════════════════════════
local C = {
    -- Backgrounds
    BG_WINDOW   = Color3.fromRGB(18,  18,  20),   -- main window #121214
    BG_SIDEBAR  = Color3.fromRGB(22,  22,  25),   -- sidebar slightly lighter
    BG_CONTENT  = Color3.fromRGB(18,  18,  20),   -- content area
    BG_ROW      = Color3.fromRGB(28,  28,  32),   -- row / card background
    BG_ROW_HOV  = Color3.fromRGB(36,  36,  42),   -- row hover
    BG_INPUT    = Color3.fromRGB(32,  32,  38),   -- textbox / dropdown bg

    -- Sidebar
    SIDE_TAB_ON  = Color3.fromRGB(35,  35,  42),  -- active tab bg
    SIDE_ACCENT  = Color3.fromRGB(78, 150, 255),  -- left accent bar (blue)

    -- Text
    TXT_A = Color3.fromRGB(255, 255, 255),  -- primary white
    TXT_B = Color3.fromRGB(160, 160, 175),  -- secondary muted
    TXT_C = Color3.fromRGB(100, 100, 115),  -- tertiary / placeholder

    -- Section headers (bold white in reference)
    SECTION_FG = Color3.fromRGB(255, 255, 255),

    -- Toggle
    TOG_ON      = Color3.fromRGB(48,  140, 255),  -- iOS blue
    TOG_ON_TRK  = Color3.fromRGB(30,   90, 200),
    TOG_OFF_TRK = Color3.fromRGB(55,   55,  65),
    TOG_KNOB    = Color3.fromRGB(255, 255, 255),

    -- Borders
    BORDER      = Color3.fromRGB(45,  45,  55),
    BORDER_FOC  = Color3.fromRGB(78, 150, 255),

    -- Title bar
    TITLE_BG    = Color3.fromRGB(14,  14,  16),
    TITLE_BTN   = Color3.fromRGB(55,  55,  65),

    -- Accent
    ACCENT      = Color3.fromRGB(78, 150, 255),

    RED   = Color3.fromRGB(255,  80,  80),
    AMBER = Color3.fromRGB(255, 185,  60),
}

-- No transparency on main panels — solid dark like the reference
local T = {
    SOLID = 0,
    ROW   = 0,
    SIDE  = 0,
}

local FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quint)
local function tw(o, i, p) TweenService:Create(o, i, p):Play() end

-- Fonts
local F = {
    TITLE = Enum.Font.GothamBold,
    HEAD  = Enum.Font.GothamSemibold,
    BODY  = Enum.Font.Gotham,
    LIGHT = Enum.Font.Gotham,
}
local function safeFont(name, fallback)
    local ok, f = pcall(function() return Enum.Font[name] end)
    return (ok and f) or Enum.Font[fallback]
end
F.LIGHT = safeFont("GothamLight", "Gotham")

-- ══════════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════════
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end
local function corner(p, r) make("UICorner", { CornerRadius = UDim.new(0, r or 6) }, p) end
local function stroke(p, col, th, tr)
    return make("UIStroke", {
        Color = col or C.BORDER, Thickness = th or 1, Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end
local function pad(p, t, b, l, r)
    make("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0), PaddingRight  = UDim.new(0, r or 0),
    }, p)
end
local function listL(p, sp, dir, ha, va)
    return make("UIListLayout", {
        SortOrder          = Enum.SortOrder.LayoutOrder,
        FillDirection      = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment  = va or Enum.VerticalAlignment.Top,
        Padding            = UDim.new(0, sp or 0),
    }, p)
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
    pcall(function()
        if mainFrame and mainFrame.Parent then mainFrame.Parent:Destroy() end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- NOTIFICATIONS  (top-right toast, matching dark theme)
-- ══════════════════════════════════════════════════════════════
local notifGui = make("ScreenGui", {
    Name = "SPNotif", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
pcall(function() notifGui.IgnoreGuiInset = true end)
safeParent(notifGui)

local nHolder = make("Frame", {
    Size = UDim2.new(0, 280, 1, 0),
    Position = UDim2.new(1, -292, 0, 0),
    BackgroundTransparency = 1,
}, notifGui)
listL(nHolder, 6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
pad(nHolder, 0, 12, 0, 0)

local nCount = 0

function DevNgg:Notify(cfg)
    if nCount >= 5 then return end
    nCount = nCount + 1
    local title = cfg.Title    or "SailorPiece"
    local body  = cfg.Content  or ""
    local dur   = cfg.Duration or 3

    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.BG_ROW,
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    }, nHolder)
    corner(card, 8)
    local cs = stroke(card, C.BORDER, 1, 1)

    -- blue left accent bar
    local bar = make("Frame", {
        Size = UDim2.new(0, 3, 0, 36),
        Position = UDim2.new(0, 0, 0.5, -18),
        BackgroundColor3 = C.ACCENT, BackgroundTransparency = 1, BorderSizePixel = 0,
    }, card)
    corner(bar, 2)

    local tL = make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1, Text = title, TextColor3 = C.TXT_A,
        TextTransparency = 1, TextSize = 13, Font = F.HEAD,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local sL = make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 12, 0, 32),
        BackgroundTransparency = 1, Text = body, TextColor3 = C.TXT_B,
        TextTransparency = 1, TextSize = 11, Font = F.BODY,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
    }, card)
    local pb = make("Frame", {
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = C.BORDER, BorderSizePixel = 0,
    }, card)
    local pf = make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.ACCENT, BorderSizePixel = 0 }, pb)

    tw(card, MED, { BackgroundTransparency = 0 })
    tw(cs,   MED, { Transparency = 0 })
    tw(bar,  MED, { BackgroundTransparency = 0 })
    tw(tL,   MED, { TextTransparency = 0 })
    tw(sL,   MED, { TextTransparency = 0 })
    tw(pf, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(dur, function()
        tw(card, MED, { BackgroundTransparency = 1 })
        tw(cs,   MED, { Transparency = 1 })
        tw(bar,  MED, { BackgroundTransparency = 1 })
        tw(tL,   MED, { TextTransparency = 1 })
        tw(sL,   MED, { TextTransparency = 1 })
        task.wait(0.25)
        card:Destroy()
        nCount = nCount - 1
    end)
end

-- ══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function DevNgg:CreateWindow(config)
    local winTitle  = config.Name             or "SailorPiece"
    local winSub    = config.Subtitle         or ""
    local winVer    = config.Version          or "v1.0"
    local toggleKey = config.ToggleUIKeybind  or "K"
    local loadTitle = config.LoadingTitle     or winTitle
    local loadSub   = config.LoadingSubtitle  or "Loading..."

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    -- ── ScreenGui ──────────────────────────────────────────────
    local sg = make("ScreenGui", {
        Name = "SailorPieceGUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100,
    })
    pcall(function() sg.IgnoreGuiInset = true end)
    safeParent(sg)

    -- ── Loading screen ─────────────────────────────────────────
    local lf = make("Frame", {
        Size = UDim2.new(0, 340, 0, 120),
        Position = UDim2.new(0.5, -170, 0.5, -60),
        BackgroundColor3 = C.BG_ROW, BorderSizePixel = 0, ZIndex = 50,
    }, sg)
    corner(lf, 10)
    stroke(lf, C.BORDER, 1, 0)

    make("TextLabel", {
        Size = UDim2.new(1, -28, 0, 24), Position = UDim2.new(0, 14, 0, 18),
        BackgroundTransparency = 1, Text = loadTitle, TextColor3 = C.TXT_A,
        TextSize = 17, Font = F.TITLE, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 51,
    }, lf)
    make("TextLabel", {
        Size = UDim2.new(1, -28, 0, 14), Position = UDim2.new(0, 14, 0, 46),
        BackgroundTransparency = 1, Text = loadSub, TextColor3 = C.TXT_C,
        TextSize = 11, Font = F.LIGHT, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 51,
    }, lf)
    local pt = make("Frame", {
        Size = UDim2.new(1, -28, 0, 3), Position = UDim2.new(0, 14, 0, 72),
        BackgroundColor3 = C.BORDER, BorderSizePixel = 0, ZIndex = 51,
    }, lf)
    corner(pt, 2)
    local pBar = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.ACCENT,
        BorderSizePixel = 0, ZIndex = 52,
    }, pt)
    corner(pBar, 2)
    local lStat = make("TextLabel", {
        Size = UDim2.new(1, -28, 0, 14), Position = UDim2.new(0, 14, 0, 83),
        BackgroundTransparency = 1, Text = "Initializing...", TextColor3 = C.TXT_C,
        TextSize = 10, Font = F.LIGHT, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 51,
    }, lf)

    -- ── Main window dimensions ─────────────────────────────────
    local mobile = isMobile()
    local vp     = workspace.CurrentCamera.ViewportSize

    local SW, WW, WH
    if not mobile then
        SW = 180; WW = 640; WH = 440
    else
        SW = 130; WW = math.min(math.floor(vp.X * 0.95), 360); WH = math.floor(vp.Y * 0.75)
    end

    local main = make("Frame", {
        Name = "Main",
        Size = UDim2.new(0, WW, 0, WH),
        Position = UDim2.new(0.5, -WW/2, 0.5, -WH/2),
        BackgroundColor3 = C.BG_WINDOW, BorderSizePixel = 0,
        ClipsDescendants = false, Visible = false,
    }, sg)
    corner(main, 10)
    stroke(main, C.BORDER, 1, 0)
    mainFrame = main

    -- Drop shadow
    make("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014054385",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
    }, main)

    -- ── Title bar ──────────────────────────────────────────────
    local TBAR_H = mobile and 36 or 42
    local titleBar = make("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, TBAR_H),
        BackgroundColor3 = C.TITLE_BG, BorderSizePixel = 0, ZIndex = 10,
    }, main)
    -- Round only top corners
    corner(titleBar, 10)
    -- Mask bottom corners with a fill strip
    make("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = C.TITLE_BG, BorderSizePixel = 0, ZIndex = 10,
    }, titleBar)

    -- Title text: "🗡 Alter Update🔥| Sailor Piece Script v3.6"
    local titleText = ("🗡 " .. winTitle .. " " .. winVer)
    make("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = C.TXT_B, TextSize = mobile and 11 or 12,
        Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    }, titleBar)

    -- Window control buttons (– □ ×)
    local btnSz = mobile and 20 or 24
    local function mkCtrlBtn(idx, sym, hcol)
        local offX = -(btnSz + (idx - 1) * (btnSz + 4) + 8)
        local b = make("TextButton", {
            Size = UDim2.new(0, btnSz, 0, btnSz),
            Position = UDim2.new(1, offX, 0.5, -btnSz / 2),
            BackgroundColor3 = C.TITLE_BTN, Text = sym,
            TextColor3 = C.TXT_B, TextSize = mobile and 11 or 13,
            Font = F.HEAD, BorderSizePixel = 0,
            AutoButtonColor = false, ZIndex = 12,
        }, titleBar)
        corner(b, 4)
        b.MouseEnter:Connect(function() tw(b, FAST, { TextColor3 = hcol, BackgroundColor3 = C.BG_ROW_HOV }) end)
        b.MouseLeave:Connect(function() tw(b, FAST, { TextColor3 = C.TXT_B, BackgroundColor3 = C.TITLE_BTN }) end)
        return b
    end
    local closeBtn = mkCtrlBtn(1, "×", C.RED)
    local minBtn   = mkCtrlBtn(2, "□", C.TXT_B)
    local minBtn2  = mkCtrlBtn(3, "−", C.AMBER)

    local _closeDebounce = false
    local function doClose()
        if _closeDebounce then return end
        _closeDebounce = true
        DevNgg:SetVisibility(false)
        task.delay(0.4, function() _closeDebounce = false end)
    end
    closeBtn.MouseButton1Click:Connect(doClose)
    closeBtn.TouchTap:Connect(doClose)

    -- Separator under title bar
    make("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, TBAR_H),
        BackgroundColor3 = C.BORDER, BorderSizePixel = 0, ZIndex = 10,
    }, main)

    -- ── Sidebar ────────────────────────────────────────────────
    local sideTop = TBAR_H + 1
    local side = make("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SW, 1, -sideTop),
        Position = UDim2.new(0, 0, 0, sideTop),
        BackgroundColor3 = C.BG_SIDEBAR,
        BorderSizePixel = 0, ZIndex = 5, ClipsDescendants = true,
    }, main)
    -- Round bottom-left corner only
    corner(side, 10)
    make("Frame", {
        Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.BG_SIDEBAR, BorderSizePixel = 0, ZIndex = 6,
    }, side)
    make("Frame", {
        Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = C.BG_SIDEBAR, BorderSizePixel = 0, ZIndex = 6,
    }, side)

    -- Right separator line of sidebar
    make("Frame", {
        Size = UDim2.new(0, 1, 1, -sideTop),
        Position = UDim2.new(0, SW, 0, sideTop),
        BackgroundColor3 = C.BORDER, BorderSizePixel = 0, ZIndex = 8,
    }, main)

    -- Tab scroll area inside sidebar
    local sScroll = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.ACCENT,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ElasticBehavior = Enum.ElasticBehavior.Always, ZIndex = 6,
    }, side)
    listL(sScroll, 2)
    pad(sScroll, 6, 6, 0, 0)

    -- Sidebar footer
    local sFoot = make("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 1, -32),
        BackgroundColor3 = C.BG_SIDEBAR, BorderSizePixel = 0, ZIndex = 6,
    }, side)
    make("Frame", {
        Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = C.BORDER, BorderSizePixel = 0, ZIndex = 7,
    }, sFoot)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "[ " .. toggleKey .. " ] Toggle",
        TextColor3 = C.TXT_C, TextSize = 10, Font = F.LIGHT,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 7,
    }, sFoot)

    -- ── Content panel ──────────────────────────────────────────
    local cPanel = make("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -SW - 1, 1, -sideTop),
        Position = UDim2.new(0, SW + 1, 0, sideTop),
        BackgroundColor3 = C.BG_CONTENT,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, main)
    corner(cPanel, 10)
    make("Frame", {
        Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.BG_CONTENT, BorderSizePixel = 0, ZIndex = 2,
    }, cPanel)

    -- Content header strip (shows active tab name)
    local cHdr = make("Frame", {
        Size = UDim2.new(1, 0, 0, mobile and 38 or 46),
        BackgroundColor3 = C.BG_CONTENT, BorderSizePixel = 0, ZIndex = 3,
    }, cPanel)
    local tabTitleLbl = make("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Text = "",
        TextColor3 = C.TXT_A, TextSize = mobile and 18 or 22,
        Font = F.TITLE, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
    }, cHdr)
    make("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 1, -1),
        BackgroundColor3 = C.BORDER, BorderSizePixel = 0, ZIndex = 4,
    }, cHdr)

    -- Content scrolling area
    local cHdrH = mobile and 38 or 46
    local cClip = make("Frame", {
        Size = UDim2.new(1, 0, 1, -cHdrH),
        Position = UDim2.new(0, 0, 0, cHdrH),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2,
    }, cPanel)
    local cScroll = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.ACCENT,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ElasticBehavior = Enum.ElasticBehavior.Always,
    }, cClip)
    listL(cScroll, 0)
    pad(cScroll, 10, 14, 14, 14)

    -- ── Drag ───────────────────────────────────────────────────
    local dragging = false
    local relative = Vector2.zero
    local guiInsetOffset = Vector2.zero
    pcall(function()
        local gs = game:GetService("GuiService")
        if sg.IgnoreGuiInset then guiInsetOffset = gs:GetGuiInset() end
    end)
    local function startDrag(input, processed)
        if processed then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true
            relative = main.AbsolutePosition + main.AbsoluteSize * main.AnchorPoint
                       - UserInputService:GetMouseLocation()
        end
    end
    titleBar.InputBegan:Connect(startDrag)
    UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local pos = UserInputService:GetMouseLocation() + relative + guiInsetOffset
            main.Position = UDim2.fromOffset(pos.X, pos.Y)
        end
    end)

    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        pcall(function()
            local key = typeof(toggleKey) == "string" and Enum.KeyCode[toggleKey] or toggleKey
            if i.KeyCode == key then DevNgg:SetVisibility(not guiVisible) end
        end)
    end)

    -- ── Loading animation then reveal ──────────────────────────
    task.spawn(function()
        local steps = {
            { p = 0.25, m = "Loading components..." },
            { p = 0.55, m = "Applying theme..." },
            { p = 0.80, m = "Connecting remotes..." },
            { p = 1.00, m = "Ready!" },
        }
        for _, s in ipairs(steps) do
            pcall(function()
                tw(pBar, TweenInfo.new(0.28, Enum.EasingStyle.Quint), { Size = UDim2.new(s.p, 0, 1, 0) })
                lStat.Text = s.m
            end)
            task.wait(0.28)
        end
        task.wait(0.1)
        main.Visible = true
        for _, d in ipairs(lf:GetDescendants()) do
            if d:IsA("TextLabel") then tw(d, MED, { TextTransparency = 1 })
            elseif d:IsA("Frame")  then tw(d, MED, { BackgroundTransparency = 1 }) end
        end
        tw(lf, MED, { BackgroundTransparency = 1 })
        task.wait(0.28)
        pcall(function() lf:Destroy() end)
    end)

    -- ══════════════════════════════════════════════════════════
    -- TAB SYSTEM
    -- ══════════════════════════════════════════════════════════
    local tabs      = {}
    local activeTab = nil
    local tabCount  = 0

    local function switchTab(tab)
        closeAllDropdowns()
        for _, t in ipairs(tabs) do
            t.content.Visible = false
            tw(t.btn, FAST, { BackgroundColor3 = C.BG_SIDEBAR, BackgroundTransparency = 0 })
            tw(t.btnLbl, FAST, { TextColor3 = C.TXT_C })
            if t.accent then t.accent.Visible = false end
            if t.btnIcon then tw(t.btnIcon, FAST, { TextColor3 = C.TXT_C }) end
        end
        tab.content.Visible = true
        activeTab = tab
        tabTitleLbl.Text = tab.name
        tw(tab.btn, FAST, { BackgroundColor3 = C.SIDE_TAB_ON, BackgroundTransparency = 0 })
        tw(tab.btnLbl, FAST, { TextColor3 = C.TXT_A })
        if tab.accent then tab.accent.Visible = true end
        if tab.btnIcon then tw(tab.btnIcon, FAST, { TextColor3 = C.TXT_A }) end
    end

    -- Window object
    local Window = {}

    function Window:CreateTab(name, icon)
        tabCount = tabCount + 1

        -- Sidebar button
        local tabH = mobile and 40 or 44
        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, tabH),
            BackgroundColor3 = C.BG_SIDEBAR, BackgroundTransparency = 0,
            Text = "", BorderSizePixel = 0, AutoButtonColor = false,
            LayoutOrder = tabCount, ZIndex = 7,
        }, sScroll)

        -- Blue left accent bar (visible when active)
        local accent = make("Frame", {
            Size = UDim2.new(0, 3, 0, 22),
            Position = UDim2.new(0, 0, 0.5, -11),
            BackgroundColor3 = C.SIDE_ACCENT, BorderSizePixel = 0,
            Visible = false, ZIndex = 8,
        }, btn)
        corner(accent, 2)

        -- Icon label (emoji/text icon)
        local iconLbl = nil
        if icon and icon ~= "" then
            iconLbl = make("TextLabel", {
                Size = UDim2.new(0, 22, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = icon,
                TextColor3 = C.TXT_C, TextSize = mobile and 14 or 16,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 8,
            }, btn)
        end

        local lblOffX = icon and (mobile and 36 or 36) or 14
        local nameLbl = make("TextLabel", {
            Size = UDim2.new(1, -(lblOffX + 8), 1, 0),
            Position = UDim2.new(0, lblOffX, 0, 0),
            BackgroundTransparency = 1, Text = name,
            TextColor3 = C.TXT_C, TextSize = mobile and 12 or 13,
            Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8,
        }, btn)

        btn.MouseEnter:Connect(function()
            if activeTab and activeTab.btn == btn then return end
            tw(btn, FAST, { BackgroundColor3 = C.BG_ROW_HOV })
        end)
        btn.MouseLeave:Connect(function()
            if activeTab and activeTab.btn == btn then return end
            tw(btn, FAST, { BackgroundColor3 = C.BG_SIDEBAR })
        end)

        -- Content frame for this tab (inside cScroll)
        local content = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Visible = false, AutomaticSize = Enum.AutomaticSize.Y,
        }, cScroll)
        listL(content, 0)

        local Tab = { name = name, btn = btn, btnLbl = nameLbl, btnIcon = iconLbl, accent = accent, content = content }
        table.insert(tabs, Tab)

        btn.MouseButton1Click:Connect(function() switchTab(Tab) end)

        if tabCount == 1 then
            task.defer(function() switchTab(Tab) end)
        end

        -- ──────────────────────────────────────────────────────
        -- ELEMENT BUILDERS
        -- ──────────────────────────────────────────────────────

        -- Section header (bold white title like in the reference)
        function Tab:CreateSection(title)
            local sec = make("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, content)
            pad(sec, 16, 4, 0, 0)

            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, mobile and 24 or 28),
                BackgroundTransparency = 1, Text = title,
                TextColor3 = C.SECTION_FG, TextSize = mobile and 15 or 18,
                Font = F.TITLE, TextXAlignment = Enum.TextXAlignment.Left,
            }, sec)
            return sec
        end

        -- Toggle row (iOS-style pill on the right)
        function Tab:CreateToggle(cfg)
            local flag    = cfg.Flag
            local curVal  = cfg.CurrentValue or false
            local state   = curVal
            if flag and flags[flag] ~= nil then state = flags[flag] end

            local ROW_H = mobile and 42 or 48
            local row = make("Frame", {
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.BG_ROW, BackgroundTransparency = 0,
                BorderSizePixel = 0,
            }, content)
            corner(row, 6)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.BORDER, BackgroundTransparency = 0.6,
                BorderSizePixel = 0,
            }, row)

            make("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Toggle",
                TextColor3 = C.TXT_B, TextSize = mobile and 12 or 13,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            -- iOS toggle track
            local TRK_W = mobile and 40 or 46
            local TRK_H = mobile and 22 or 26
            local trk = make("Frame", {
                Size = UDim2.new(0, TRK_W, 0, TRK_H),
                Position = UDim2.new(1, -(TRK_W + 12), 0.5, -TRK_H / 2),
                BackgroundColor3 = state and C.TOG_ON or C.TOG_OFF_TRK,
                BorderSizePixel = 0,
            }, row)
            corner(trk, TRK_H / 2)

            local KNOB_S = TRK_H - 4
            local knob = make("Frame", {
                Size = UDim2.new(0, KNOB_S, 0, KNOB_S),
                Position = state and UDim2.new(1, -(KNOB_S + 2), 0.5, -KNOB_S / 2)
                                  or UDim2.new(0, 2, 0.5, -KNOB_S / 2),
                BackgroundColor3 = C.TOG_KNOB, BorderSizePixel = 0, ZIndex = 2,
            }, trk)
            corner(knob, KNOB_S / 2)

            local function setState(val, silent)
                state = val
                if flag then flags[flag] = val end
                tw(trk, FAST, { BackgroundColor3 = val and C.TOG_ON or C.TOG_OFF_TRK })
                tw(knob, FAST, {
                    Position = val and UDim2.new(1, -(KNOB_S + 2), 0.5, -KNOB_S / 2)
                                    or UDim2.new(0, 2, 0.5, -KNOB_S / 2),
                })
                if not silent and cfg.Callback then pcall(cfg.Callback, val) end
                if not silent then saveConfig() end
            end

            if flag then toggleSetters[flag] = setState end

            local clickArea = make("TextButton", {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Text = "", ZIndex = 3,
            }, row)
            clickArea.MouseButton1Click:Connect(function() setState(not state) end)

            row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BG_ROW_HOV }) end)
            row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BG_ROW }) end)

            local T2 = {}
            function T2:Set(v, silent) setState(v, silent) end
            function T2:Get() return state end
            return T2
        end

        -- Button
        function Tab:CreateButton(cfg)
            local ROW_H = mobile and 40 or 46
            local row = make("TextButton", {
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.BG_ROW, BackgroundTransparency = 0,
                Text = "", BorderSizePixel = 0, AutoButtonColor = false,
            }, content)
            corner(row, 6)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.BORDER, BackgroundTransparency = 0.6, BorderSizePixel = 0,
            }, row)

            make("TextLabel", {
                Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1, Text = cfg.Name or "Button",
                TextColor3 = C.ACCENT, TextSize = mobile and 12 or 13,
                Font = F.HEAD, TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            -- Chevron right
            make("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1, Text = "›",
                TextColor3 = C.TXT_C, TextSize = 18, Font = F.HEAD,
            }, row)

            row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BG_ROW_HOV }) end)
            row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BG_ROW }) end)
            row.MouseButton1Down:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BG_ROW }) end)
            row.MouseButton1Click:Connect(function()
                tw(row, FAST, { BackgroundColor3 = C.BG_ROW_HOV })
                if cfg.Callback then pcall(cfg.Callback) end
            end)
        end

        -- Slider
        function Tab:CreateSlider(cfg)
            local min     = cfg.Min      or 0
            local max     = cfg.Max      or 100
            local inc     = cfg.Increment or 1
            local default = cfg.Default  or min
            local suffix  = cfg.Suffix   or ""
            local flag    = cfg.Flag
            local val     = default
            if flag and flags[flag] ~= nil then val = flags[flag] end

            local ROW_H = mobile and 56 or 64
            local row = make("Frame", {
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.BG_ROW, BorderSizePixel = 0,
            }, content)
            corner(row, 6)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.BORDER, BackgroundTransparency = 0.6, BorderSizePixel = 0,
            }, row)

            local valLbl = make("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -70, 0, mobile and 8 or 10),
                BackgroundTransparency = 1, Text = tostring(val) .. suffix,
                TextColor3 = C.ACCENT, TextSize = 12, Font = F.HEAD,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, row)
            make("TextLabel", {
                Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 14, 0, mobile and 8 or 10),
                BackgroundTransparency = 1, Text = cfg.Name or "Slider",
                TextColor3 = C.TXT_B, TextSize = mobile and 12 or 13,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            -- Track
            local trackY = mobile and 36 or 42
            local track = make("Frame", {
                Size = UDim2.new(1, -28, 0, 4),
                Position = UDim2.new(0, 14, 0, trackY),
                BackgroundColor3 = C.TOG_OFF_TRK, BorderSizePixel = 0,
            }, row)
            corner(track, 2)
            local function getPct() return (val - min) / math.max(max - min, 0.001) end
            local fill = make("Frame", {
                Size = UDim2.new(getPct(), 0, 1, 0),
                BackgroundColor3 = C.ACCENT, BorderSizePixel = 0,
            }, track)
            corner(fill, 2)

            -- Knob
            local knob2 = make("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(getPct(), -7, 0.5, -7),
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2,
            }, track)
            corner(knob2, 7)
            stroke(knob2, C.ACCENT, 2, 0)

            local function updateSlider(newVal)
                if inc > 0 then newVal = math.floor((newVal - min) / inc + 0.5) * inc + min end
                val = math.clamp(newVal, min, max)
                if flag then flags[flag] = val end
                local p = getPct()
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob2.Position = UDim2.new(p, -7, 0.5, -7)
                valLbl.Text = tostring(val) .. suffix
                if cfg.Callback then pcall(cfg.Callback, val) end
                saveConfig()
            end

            local draggingSlider = false
            local hitbox = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0.5, -11),
                BackgroundTransparency = 1, Text = "", ZIndex = 3,
            }, track)
            hitbox.MouseButton1Down:Connect(function() draggingSlider = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
            end)
            RunService.Heartbeat:Connect(function()
                if not draggingSlider then return end
                local m   = UserInputService:GetMouseLocation()
                local a   = track.AbsolutePosition
                local sz  = track.AbsoluteSize
                local pct = math.clamp((m.X - a.X) / sz.X, 0, 1)
                updateSlider(min + pct * (max - min))
            end)
            updateSlider(val)
        end

        -- Dropdown (inline right label + list, matching reference style)
        function Tab:CreateDropdown(cfg)
            local options  = cfg.Options  or {}
            local flag     = cfg.Flag
            local selected = cfg.Default  or (options[1] or "")
            if flag and flags[flag] ~= nil then selected = flags[flag] end

            local ROW_H = mobile and 42 or 48
            local row = make("Frame", {
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.BG_ROW, BorderSizePixel = 0,
                ClipsDescendants = false,
            }, content)
            corner(row, 6)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.BORDER, BackgroundTransparency = 0.6, BorderSizePixel = 0,
            }, row)

            make("TextLabel", {
                Size = UDim2.new(0.5, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1, Text = cfg.Name or "Dropdown",
                TextColor3 = C.TXT_B, TextSize = mobile and 12 or 13,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            -- Right side: selected value + chevron
            local valLbl2 = make("TextLabel", {
                Size = UDim2.new(0.45, -24, 1, 0),
                Position = UDim2.new(0.5, 4, 0, 0),
                BackgroundTransparency = 1, Text = selected,
                TextColor3 = C.TXT_B, TextSize = mobile and 11 or 12,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Right,
            }, row)
            make("TextLabel", {
                Size = UDim2.new(0, 18, 1, 0), Position = UDim2.new(1, -22, 0, 0),
                BackgroundTransparency = 1, Text = "⌄",
                TextColor3 = C.TXT_C, TextSize = 14, Font = F.HEAD,
            }, row)

            -- Dropdown list (opens below)
            local listH   = math.min(#options, 6) * (mobile and 32 or 36)
            local dropList = make("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, listH),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = C.BG_INPUT, BorderSizePixel = 0,
                Visible = false, ZIndex = 20,
                ScrollBarThickness = 2, ScrollBarImageColor3 = C.ACCENT,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ClipsDescendants = true,
            }, row)
            corner(dropList, 6)
            stroke(dropList, C.BORDER, 1, 0)
            listL(dropList, 0)

            local ITEM_H = mobile and 32 or 36
            for _, opt in ipairs(options) do
                local item = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, ITEM_H),
                    BackgroundColor3 = C.BG_INPUT, BackgroundTransparency = 0,
                    Text = "", BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 21,
                }, dropList)
                local iLbl = make("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1, Text = opt,
                    TextColor3 = opt == selected and C.TXT_A or C.TXT_B,
                    TextSize = mobile and 11 or 12, Font = F.BODY,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
                }, item)
                -- Active indicator dot
                local dot = make("Frame", {
                    Size = UDim2.new(0, 6, 0, 6),
                    Position = UDim2.new(1, -14, 0.5, -3),
                    BackgroundColor3 = C.ACCENT, BorderSizePixel = 0,
                    Visible = opt == selected, ZIndex = 22,
                }, item)
                corner(dot, 3)

                item.MouseEnter:Connect(function() tw(item, FAST, { BackgroundColor3 = C.BG_ROW_HOV }) end)
                item.MouseLeave:Connect(function() tw(item, FAST, { BackgroundColor3 = C.BG_INPUT }) end)
                item.MouseButton1Click:Connect(function()
                    selected = opt
                    valLbl2.Text = opt
                    if flag then flags[flag] = opt end
                    if cfg.Callback then pcall(cfg.Callback, opt) end
                    saveConfig()
                    -- Update all dots and labels
                    for _, child in ipairs(dropList:GetChildren()) do
                        if child:IsA("TextButton") then
                            local cl = child:FindFirstChildOfClass("TextLabel")
                            local cd = child:FindFirstChildOfClass("Frame")
                            if cl then
                                tw(cl, FAST, { TextColor3 = cl.Text == opt and C.TXT_A or C.TXT_B })
                            end
                            if cd then cd.Visible = (cl and cl.Text == opt) end
                        end
                    end
                    dropList.Visible = false
                    unregisterDropdown(function() dropList.Visible = false end)
                end)
            end

            local isOpen = false
            local function close2()
                isOpen = false; dropList.Visible = false
                tw(row, FAST, { BackgroundColor3 = C.BG_ROW })
            end

            local clickBtn = make("TextButton", {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Text = "", ZIndex = 5,
            }, row)
            clickBtn.MouseButton1Click:Connect(function()
                if isOpen then
                    close2()
                else
                    closeAllDropdowns()
                    isOpen = true; dropList.Visible = true
                    tw(row, FAST, { BackgroundColor3 = C.BG_ROW_HOV })
                    registerDropdown(close2)
                end
            end)
            row.MouseEnter:Connect(function()
                if not isOpen then tw(row, FAST, { BackgroundColor3 = C.BG_ROW_HOV }) end
            end)
            row.MouseLeave:Connect(function()
                if not isOpen then tw(row, FAST, { BackgroundColor3 = C.BG_ROW }) end
            end)

            local DD = {}
            function DD:SetSelected(v)
                selected = v; valLbl2.Text = v
            end
            function DD:GetSelected() return selected end
            function DD:Close() close2() end
            return DD
        end

        -- TextInput
        function Tab:CreateTextInput(cfg)
            local flag = cfg.Flag
            local ROW_H = mobile and 42 or 48

            local row = make("Frame", {
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.BG_ROW, BorderSizePixel = 0,
            }, content)
            corner(row, 6)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.BORDER, BackgroundTransparency = 0.6, BorderSizePixel = 0,
            }, row)

            make("TextLabel", {
                Size = UDim2.new(0.4, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1, Text = cfg.Name or "Input",
                TextColor3 = C.TXT_B, TextSize = mobile and 12 or 13,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            local box = make("TextBox", {
                Size = UDim2.new(0.55, -12, 0, mobile and 28 or 32),
                Position = UDim2.new(0.4, 4, 0.5, -(mobile and 14 or 16)),
                BackgroundColor3 = C.BG_INPUT, BorderSizePixel = 0,
                Text = cfg.Default or "",
                PlaceholderText = cfg.Placeholder or "",
                PlaceholderColor3 = C.TXT_C,
                TextColor3 = C.TXT_A, TextSize = mobile and 11 or 12,
                Font = F.BODY, ClearTextOnFocus = false,
            }, row)
            corner(box, 5)
            local bs = stroke(box, C.BORDER, 1, 0)
            pad(box, 0, 0, 8, 8)

            box.Focused:Connect(function()
                tw(bs, FAST, { Color = C.BORDER_FOC })
            end)
            box.FocusLost:Connect(function(enterPressed)
                tw(bs, FAST, { Color = C.BORDER })
                if flag then flags[flag] = box.Text end
                if cfg.Callback then pcall(cfg.Callback, box.Text) end
            end)
        end

        -- ColorPicker (compact, matching dark style)
        function Tab:CreateColorPicker(cfg)
            local flag  = cfg.Flag
            local color = cfg.Default or Color3.fromRGB(78, 150, 255)
            local h, s, v = color:ToHSV()
            local isOpen = false

            local ROW_H = mobile and 40 or 46
            local row = make("TextButton", {
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.BG_ROW, BackgroundTransparency = 0,
                Text = "", BorderSizePixel = 0, AutoButtonColor = false,
            }, content)
            corner(row, 6)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.BORDER, BackgroundTransparency = 0.6, BorderSizePixel = 0,
            }, row)

            make("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1, Text = cfg.Name or "Color",
                TextColor3 = C.TXT_B, TextSize = mobile and 12 or 13,
                Font = F.BODY, TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            local sw = make("Frame", {
                Size = UDim2.new(0, mobile and 24 or 30, 0, mobile and 14 or 18),
                Position = UDim2.new(1, -(mobile and 48 or 54), 0.5, -(mobile and 7 or 9)),
                BackgroundColor3 = color, BorderSizePixel = 0,
            }, row)
            corner(sw, 4)
            stroke(sw, C.BORDER, 1, 0)

            make("TextLabel", {
                Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency = 1, Text = "⌄",
                TextColor3 = C.TXT_C, TextSize = 14, Font = F.HEAD,
            }, row)

            local cpH = mobile and 136 or 168
            local panel = make("Frame", {
                Size = UDim2.new(1, 0, 0, cpH), BackgroundColor3 = C.BG_INPUT,
                BackgroundTransparency = 0, BorderSizePixel = 0, Visible = false,
            }, content)
            corner(panel, 6)
            stroke(panel, C.BORDER, 1, 0)
            pad(panel, 8, 8, 8, 8)

            local svB = make("Frame", {
                Size = UDim2.new(1, -28, 1, -38),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0,
            }, panel)
            corner(svB, 4)
            make("UIGradient", {
                Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1)) }),
                Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) }),
            }, svB)
            local bo = make("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), BorderSizePixel = 0 }, svB)
            corner(bo, 4)
            make("UIGradient", {
                Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) }), Rotation = 90,
            }, bo)
            local svK = make("Frame", {
                Size = UDim2.new(0,12,0,12), AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(s, 0, 1-v, 0),
                BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 5,
            }, svB)
            corner(svK, 6)
            stroke(svK, Color3.new(0,0,0), 1)

            local hB = make("Frame", {
                Size = UDim2.new(0, 14, 1, -38), Position = UDim2.new(1, -14, 0, 0), BorderSizePixel = 0,
            }, panel)
            corner(hB, 3)
            make("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,   1,1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                    ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1,1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1,1)),
                }), Rotation = 90,
            }, hB)
            local hK = make("Frame", {
                Size = UDim2.new(1,4,0,4), AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(0.5, 0, h, 0),
                BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 5,
            }, hB)
            corner(hK, 2)
            stroke(hK, Color3.new(0,0,0), 1)

            local hx = make("TextBox", {
                Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 1, -24),
                BackgroundColor3 = C.BG_ROW, BorderSizePixel = 0,
                TextColor3 = C.TXT_A, PlaceholderColor3 = C.TXT_C,
                PlaceholderText = "#RRGGBB", TextSize = 11, Font = F.BODY,
                ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Center,
            }, panel)
            corner(hx, 4)
            local hbs = stroke(hx, C.BORDER, 1, 0)

            local function toHex(c3)
                return string.format("#%02X%02X%02X",
                    math.floor(c3.R*255+.5), math.floor(c3.G*255+.5), math.floor(c3.B*255+.5))
            end
            local function updAll()
                local col = Color3.fromHSV(h, s, v); color = col
                sw.BackgroundColor3 = col
                svB.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                svK.Position = UDim2.new(s, 0, 1-v, 0)
                hK.Position  = UDim2.new(0.5, 0, h, 0)
                hx.Text = toHex(col)
                if flag then flags[flag] = { R=col.R, G=col.G, B=col.B } end
                if cfg.Callback then pcall(cfg.Callback, col) end
            end

            local svD = false
            local sI = make("TextButton", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=4 }, svB)
            sI.MouseButton1Down:Connect(function() svD = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then svD = false end
            end)
            RunService.Heartbeat:Connect(function()
                if not svD then return end
                local m = UserInputService:GetMouseLocation()
                local a = svB.AbsolutePosition; local sz = svB.AbsoluteSize
                s = math.clamp((m.X-a.X)/sz.X, 0, 1)
                v = 1 - math.clamp((m.Y-a.Y)/sz.Y, 0, 1)
                updAll()
            end)
            local hD = false
            local hI = make("TextButton", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=4 }, hB)
            hI.MouseButton1Down:Connect(function() hD = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then hD = false end
            end)
            RunService.Heartbeat:Connect(function()
                if not hD then return end
                local m = UserInputService:GetMouseLocation()
                local a = hB.AbsolutePosition; local sz = hB.AbsoluteSize
                h = math.clamp((m.Y-a.Y)/sz.Y, 0, 1)
                updAll()
            end)
            hx.Focused:Connect(function()  tw(hbs, FAST, { Color = C.BORDER_FOC }) end)
            hx.FocusLost:Connect(function()
                tw(hbs, FAST, { Color = C.BORDER })
                local t2 = hx.Text:gsub("#","")
                if #t2 == 6 then
                    local r2 = tonumber(t2:sub(1,2), 16)
                    local g2 = tonumber(t2:sub(3,4), 16)
                    local b2 = tonumber(t2:sub(5,6), 16)
                    if r2 and g2 and b2 then h,s,v = Color3.fromRGB(r2,g2,b2):ToHSV(); updAll() end
                end
            end)
            row.MouseButton1Click:Connect(function()
                isOpen = not isOpen; panel.Visible = isOpen
                tw(row, FAST, { BackgroundColor3 = isOpen and C.BG_ROW_HOV or C.BG_ROW })
                if isOpen then updAll() end
            end)
            row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BG_ROW_HOV }) end)
            row.MouseLeave:Connect(function()
                if not isOpen then tw(row, FAST, { BackgroundColor3 = C.BG_ROW }) end
            end)
            updAll()

            local CP = {}
            function CP:Set(c3, silent)
                color = c3; h,s,v = c3:ToHSV(); updAll()
                if not silent and cfg.Callback then pcall(cfg.Callback, c3) end
            end
            function CP:Get() return color end
            return CP
        end

        return Tab
    end

    -- Window helpers
    function Window:GetFlag(flag)    return flags[flag] end
    function Window:SetToggle(flag, value)
        local setter = toggleSetters[flag]
        if setter then setter(value, false) end
    end
    function Window:LoadConfiguration()
        local saved = loadConfig()
        for flag2, val in pairs(saved) do
            local setter = toggleSetters[flag2]
            if setter and type(val) == "boolean" then setter(val, true) end
        end
    end

    return Window
end

return DevNgg
