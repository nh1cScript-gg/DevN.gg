-- DevN.gg GUI Library
-- loader.lua — Full Rayfield-Compatible (Themes + All Elements)

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

local function safeParent(gui)
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    ok = pcall(function() gui.Parent = gethui() end)
    if ok and gui.Parent then return end
    pcall(function() gui.Parent = playerGui end)
end

-- =====================================================================
-- THEMES  (all 9 Rayfield identifiers + custom table support)
-- =====================================================================

local Themes = {}

Themes.Default = {
    Background = Color3.fromRGB(25,25,25),          Topbar = Color3.fromRGB(34,34,34),
    TextColor  = Color3.fromRGB(240,240,240),        TextMid = Color3.fromRGB(160,160,160),
    TextDim    = Color3.fromRGB(90,90,90),            Accent = Color3.fromRGB(58,163,255),
    AccentDark = Color3.fromRGB(30,100,180),          Border = Color3.fromRGB(50,50,50),
    Border2    = Color3.fromRGB(80,80,80),
    ElementBackground      = Color3.fromRGB(35,35,35),
    ElementBackgroundHover = Color3.fromRGB(40,40,40),
    SecondaryElementBackground = Color3.fromRGB(25,25,25),
    ElementStroke          = Color3.fromRGB(50,50,50),
    SecondaryElementStroke = Color3.fromRGB(40,40,40),
    SliderBackground = Color3.fromRGB(50,138,220),   SliderProgress = Color3.fromRGB(50,138,220),
    SliderStroke     = Color3.fromRGB(58,163,255),
    ToggleBackground = Color3.fromRGB(30,30,30),     ToggleEnabled  = Color3.fromRGB(0,146,214),
    ToggleDisabled   = Color3.fromRGB(100,100,100),  ToggleEnabledStroke  = Color3.fromRGB(0,170,255),
    ToggleDisabledStroke = Color3.fromRGB(125,125,125),
    DropdownSelected   = Color3.fromRGB(40,40,40),   DropdownUnselected = Color3.fromRGB(30,30,30),
    InputBackground    = Color3.fromRGB(30,30,30),   InputStroke        = Color3.fromRGB(65,65,65),
    PlaceholderColor   = Color3.fromRGB(178,178,178),
    NotificationBackground = Color3.fromRGB(20,20,20),
    TopAccent = Color3.fromRGB(58,163,255),           SectionText = Color3.fromRGB(120,120,120),
    BtnHover  = Color3.fromRGB(40,40,40),             BtnActive   = Color3.fromRGB(55,55,55),
}

Themes.AmberGlow = {
    Background = Color3.fromRGB(20,15,8),           Topbar = Color3.fromRGB(30,22,10),
    TextColor  = Color3.fromRGB(255,240,200),        TextMid = Color3.fromRGB(200,160,80),
    TextDim    = Color3.fromRGB(110,80,30),           Accent = Color3.fromRGB(255,190,40),
    AccentDark = Color3.fromRGB(180,120,0),           Border = Color3.fromRGB(70,50,15),
    Border2    = Color3.fromRGB(110,80,25),
    ElementBackground      = Color3.fromRGB(30,22,10),
    ElementBackgroundHover = Color3.fromRGB(42,30,12),
    SecondaryElementBackground = Color3.fromRGB(20,15,6),
    ElementStroke          = Color3.fromRGB(70,50,15),
    SecondaryElementStroke = Color3.fromRGB(55,38,10),
    SliderBackground = Color3.fromRGB(200,130,0),   SliderProgress = Color3.fromRGB(255,180,30),
    SliderStroke     = Color3.fromRGB(255,200,60),
    ToggleBackground = Color3.fromRGB(28,20,8),     ToggleEnabled  = Color3.fromRGB(220,150,0),
    ToggleDisabled   = Color3.fromRGB(90,65,20),    ToggleEnabledStroke  = Color3.fromRGB(255,190,40),
    ToggleDisabledStroke = Color3.fromRGB(110,80,25),
    DropdownSelected   = Color3.fromRGB(40,28,10),  DropdownUnselected = Color3.fromRGB(28,20,8),
    InputBackground    = Color3.fromRGB(28,20,8),   InputStroke        = Color3.fromRGB(80,58,18),
    PlaceholderColor   = Color3.fromRGB(160,120,60),
    NotificationBackground = Color3.fromRGB(25,18,8),
    TopAccent = Color3.fromRGB(255,190,40),          SectionText = Color3.fromRGB(160,120,50),
    BtnHover  = Color3.fromRGB(42,30,12),            BtnActive   = Color3.fromRGB(55,40,16),
}

Themes.Amethyst = {
    Background = Color3.fromRGB(18,12,28),          Topbar = Color3.fromRGB(26,18,40),
    TextColor  = Color3.fromRGB(235,220,255),        TextMid = Color3.fromRGB(170,130,220),
    TextDim    = Color3.fromRGB(90,60,130),           Accent = Color3.fromRGB(190,120,255),
    AccentDark = Color3.fromRGB(120,60,200),          Border = Color3.fromRGB(65,40,100),
    Border2    = Color3.fromRGB(100,65,150),
    ElementBackground      = Color3.fromRGB(28,18,44),
    ElementBackgroundHover = Color3.fromRGB(38,25,60),
    SecondaryElementBackground = Color3.fromRGB(18,11,30),
    ElementStroke          = Color3.fromRGB(65,40,100),
    SecondaryElementStroke = Color3.fromRGB(50,30,78),
    SliderBackground = Color3.fromRGB(130,70,220),  SliderProgress = Color3.fromRGB(170,100,255),
    SliderStroke     = Color3.fromRGB(200,140,255),
    ToggleBackground = Color3.fromRGB(25,15,40),    ToggleEnabled  = Color3.fromRGB(150,80,230),
    ToggleDisabled   = Color3.fromRGB(75,45,110),   ToggleEnabledStroke  = Color3.fromRGB(190,120,255),
    ToggleDisabledStroke = Color3.fromRGB(100,60,145),
    DropdownSelected   = Color3.fromRGB(38,24,60),  DropdownUnselected = Color3.fromRGB(25,15,40),
    InputBackground    = Color3.fromRGB(25,15,40),  InputStroke        = Color3.fromRGB(80,48,120),
    PlaceholderColor   = Color3.fromRGB(140,100,190),
    NotificationBackground = Color3.fromRGB(22,14,35),
    TopAccent = Color3.fromRGB(190,120,255),         SectionText = Color3.fromRGB(130,90,180),
    BtnHover  = Color3.fromRGB(38,25,60),            BtnActive   = Color3.fromRGB(50,34,78),
}

Themes.Bloom = {
    Background = Color3.fromRGB(22,10,18),          Topbar = Color3.fromRGB(32,14,26),
    TextColor  = Color3.fromRGB(255,230,240),        TextMid = Color3.fromRGB(220,150,185),
    TextDim    = Color3.fromRGB(110,55,82),           Accent = Color3.fromRGB(255,120,180),
    AccentDark = Color3.fromRGB(180,60,110),          Border = Color3.fromRGB(80,32,58),
    Border2    = Color3.fromRGB(120,50,88),
    ElementBackground      = Color3.fromRGB(32,14,26),
    ElementBackgroundHover = Color3.fromRGB(46,20,36),
    SecondaryElementBackground = Color3.fromRGB(20,9,16),
    ElementStroke          = Color3.fromRGB(80,32,58),
    SecondaryElementStroke = Color3.fromRGB(60,24,44),
    SliderBackground = Color3.fromRGB(200,70,130),  SliderProgress = Color3.fromRGB(255,110,170),
    SliderStroke     = Color3.fromRGB(255,140,190),
    ToggleBackground = Color3.fromRGB(28,12,22),    ToggleEnabled  = Color3.fromRGB(230,80,140),
    ToggleDisabled   = Color3.fromRGB(100,38,70),   ToggleEnabledStroke  = Color3.fromRGB(255,120,175),
    ToggleDisabledStroke = Color3.fromRGB(130,50,88),
    DropdownSelected   = Color3.fromRGB(44,18,34),  DropdownUnselected = Color3.fromRGB(28,12,22),
    InputBackground    = Color3.fromRGB(28,12,22),  InputStroke        = Color3.fromRGB(90,36,64),
    PlaceholderColor   = Color3.fromRGB(180,100,140),
    NotificationBackground = Color3.fromRGB(26,12,20),
    TopAccent = Color3.fromRGB(255,120,180),         SectionText = Color3.fromRGB(160,80,120),
    BtnHover  = Color3.fromRGB(46,20,36),            BtnActive   = Color3.fromRGB(60,26,46),
}

Themes.DarkBlue = {
    Background = Color3.fromRGB(8,12,28),           Topbar = Color3.fromRGB(12,18,40),
    TextColor  = Color3.fromRGB(210,225,255),        TextMid = Color3.fromRGB(140,170,240),
    TextDim    = Color3.fromRGB(55,80,150),           Accent = Color3.fromRGB(80,140,255),
    AccentDark = Color3.fromRGB(40,80,200),           Border = Color3.fromRGB(30,48,110),
    Border2    = Color3.fromRGB(55,85,165),
    ElementBackground      = Color3.fromRGB(14,20,48),
    ElementBackgroundHover = Color3.fromRGB(20,30,68),
    SecondaryElementBackground = Color3.fromRGB(8,12,32),
    ElementStroke          = Color3.fromRGB(30,48,110),
    SecondaryElementStroke = Color3.fromRGB(22,35,85),
    SliderBackground = Color3.fromRGB(40,80,200),   SliderProgress = Color3.fromRGB(70,120,255),
    SliderStroke     = Color3.fromRGB(100,150,255),
    ToggleBackground = Color3.fromRGB(12,18,44),    ToggleEnabled  = Color3.fromRGB(50,100,230),
    ToggleDisabled   = Color3.fromRGB(35,55,120),   ToggleEnabledStroke  = Color3.fromRGB(80,140,255),
    ToggleDisabledStroke = Color3.fromRGB(50,75,155),
    DropdownSelected   = Color3.fromRGB(20,30,65),  DropdownUnselected = Color3.fromRGB(12,18,44),
    InputBackground    = Color3.fromRGB(12,18,44),  InputStroke        = Color3.fromRGB(38,60,135),
    PlaceholderColor   = Color3.fromRGB(110,140,210),
    NotificationBackground = Color3.fromRGB(10,15,32),
    TopAccent = Color3.fromRGB(80,140,255),          SectionText = Color3.fromRGB(70,105,185),
    BtnHover  = Color3.fromRGB(20,30,68),            BtnActive   = Color3.fromRGB(28,42,90),
}

Themes.Green = {
    Background = Color3.fromRGB(8,18,10),           Topbar = Color3.fromRGB(12,26,15),
    TextColor  = Color3.fromRGB(210,255,220),        TextMid = Color3.fromRGB(130,220,155),
    TextDim    = Color3.fromRGB(45,110,62),           Accent = Color3.fromRGB(65,230,105),
    AccentDark = Color3.fromRGB(30,155,65),           Border = Color3.fromRGB(25,75,35),
    Border2    = Color3.fromRGB(45,120,58),
    ElementBackground      = Color3.fromRGB(12,28,15),
    ElementBackgroundHover = Color3.fromRGB(18,40,22),
    SecondaryElementBackground = Color3.fromRGB(8,18,10),
    ElementStroke          = Color3.fromRGB(25,75,35),
    SecondaryElementStroke = Color3.fromRGB(18,55,25),
    SliderBackground = Color3.fromRGB(30,160,70),   SliderProgress = Color3.fromRGB(50,210,95),
    SliderStroke     = Color3.fromRGB(70,240,115),
    ToggleBackground = Color3.fromRGB(10,25,13),    ToggleEnabled  = Color3.fromRGB(40,190,80),
    ToggleDisabled   = Color3.fromRGB(25,75,38),    ToggleEnabledStroke  = Color3.fromRGB(65,230,105),
    ToggleDisabledStroke = Color3.fromRGB(35,100,50),
    DropdownSelected   = Color3.fromRGB(18,40,22),  DropdownUnselected = Color3.fromRGB(10,25,13),
    InputBackground    = Color3.fromRGB(10,25,13),  InputStroke        = Color3.fromRGB(30,88,42),
    PlaceholderColor   = Color3.fromRGB(100,180,120),
    NotificationBackground = Color3.fromRGB(10,22,12),
    TopAccent = Color3.fromRGB(65,230,105),          SectionText = Color3.fromRGB(55,155,75),
    BtnHover  = Color3.fromRGB(18,40,22),            BtnActive   = Color3.fromRGB(25,52,30),
}

Themes.Light = {
    Background = Color3.fromRGB(240,240,245),       Topbar = Color3.fromRGB(228,228,235),
    TextColor  = Color3.fromRGB(30,30,30),           TextMid = Color3.fromRGB(80,80,110),
    TextDim    = Color3.fromRGB(155,155,185),         Accent = Color3.fromRGB(70,130,255),
    AccentDark = Color3.fromRGB(40,90,200),           Border = Color3.fromRGB(200,200,215),
    Border2    = Color3.fromRGB(160,160,185),
    ElementBackground      = Color3.fromRGB(250,250,255),
    ElementBackgroundHover = Color3.fromRGB(235,235,245),
    SecondaryElementBackground = Color3.fromRGB(230,230,240),
    ElementStroke          = Color3.fromRGB(200,200,215),
    SecondaryElementStroke = Color3.fromRGB(210,210,225),
    SliderBackground = Color3.fromRGB(70,130,230),  SliderProgress = Color3.fromRGB(70,130,230),
    SliderStroke     = Color3.fromRGB(90,155,255),
    ToggleBackground = Color3.fromRGB(210,210,225), ToggleEnabled  = Color3.fromRGB(60,130,240),
    ToggleDisabled   = Color3.fromRGB(170,170,185), ToggleEnabledStroke  = Color3.fromRGB(80,150,255),
    ToggleDisabledStroke = Color3.fromRGB(190,190,205),
    DropdownSelected   = Color3.fromRGB(235,235,248), DropdownUnselected = Color3.fromRGB(248,248,255),
    InputBackground    = Color3.fromRGB(248,248,255), InputStroke        = Color3.fromRGB(195,195,215),
    PlaceholderColor   = Color3.fromRGB(155,155,175),
    NotificationBackground = Color3.fromRGB(250,250,255),
    TopAccent = Color3.fromRGB(70,130,255),          SectionText = Color3.fromRGB(120,120,160),
    BtnHover  = Color3.fromRGB(235,235,245),         BtnActive   = Color3.fromRGB(220,220,235),
}

Themes.Ocean = {
    Background = Color3.fromRGB(6,15,25),           Topbar = Color3.fromRGB(8,20,33),
    TextColor  = Color3.fromRGB(190,230,255),        TextMid = Color3.fromRGB(85,145,185),
    TextDim    = Color3.fromRGB(35,80,110),           Accent = Color3.fromRGB(80,200,255),
    AccentDark = Color3.fromRGB(40,130,190),          Border = Color3.fromRGB(20,55,85),
    Border2    = Color3.fromRGB(35,90,130),
    ElementBackground      = Color3.fromRGB(10,25,40),
    ElementBackgroundHover = Color3.fromRGB(15,42,65),
    SecondaryElementBackground = Color3.fromRGB(8,20,33),
    ElementStroke          = Color3.fromRGB(20,55,85),
    SecondaryElementStroke = Color3.fromRGB(13,38,60),
    SliderBackground = Color3.fromRGB(40,130,190),  SliderProgress = Color3.fromRGB(80,200,255),
    SliderStroke     = Color3.fromRGB(100,215,255),
    ToggleBackground = Color3.fromRGB(8,20,33),     ToggleEnabled  = Color3.fromRGB(80,255,210),
    ToggleDisabled   = Color3.fromRGB(20,55,80),    ToggleEnabledStroke  = Color3.fromRGB(80,200,255),
    ToggleDisabledStroke = Color3.fromRGB(35,80,115),
    DropdownSelected   = Color3.fromRGB(13,32,50),  DropdownUnselected = Color3.fromRGB(8,20,33),
    InputBackground    = Color3.fromRGB(10,25,40),  InputStroke        = Color3.fromRGB(35,90,130),
    PlaceholderColor   = Color3.fromRGB(85,145,185),
    NotificationBackground = Color3.fromRGB(10,25,40),
    TopAccent = Color3.fromRGB(80,200,255),          SectionText = Color3.fromRGB(40,110,155),
    BtnHover  = Color3.fromRGB(15,42,65),            BtnActive   = Color3.fromRGB(22,60,90),
}

Themes.Serenity = {
    Background = Color3.fromRGB(15,18,26),          Topbar = Color3.fromRGB(20,24,35),
    TextColor  = Color3.fromRGB(220,225,245),        TextMid = Color3.fromRGB(140,148,185),
    TextDim    = Color3.fromRGB(65,72,105),           Accent = Color3.fromRGB(130,160,255),
    AccentDark = Color3.fromRGB(80,110,220),          Border = Color3.fromRGB(38,44,72),
    Border2    = Color3.fromRGB(65,75,120),
    ElementBackground      = Color3.fromRGB(22,27,42),
    ElementBackgroundHover = Color3.fromRGB(30,36,56),
    SecondaryElementBackground = Color3.fromRGB(16,20,32),
    ElementStroke          = Color3.fromRGB(38,44,72),
    SecondaryElementStroke = Color3.fromRGB(28,34,56),
    SliderBackground = Color3.fromRGB(80,100,210),  SliderProgress = Color3.fromRGB(130,160,255),
    SliderStroke     = Color3.fromRGB(155,180,255),
    ToggleBackground = Color3.fromRGB(18,22,36),    ToggleEnabled  = Color3.fromRGB(120,150,255),
    ToggleDisabled   = Color3.fromRGB(48,56,90),    ToggleEnabledStroke  = Color3.fromRGB(150,175,255),
    ToggleDisabledStroke = Color3.fromRGB(68,78,120),
    DropdownSelected   = Color3.fromRGB(28,34,55),  DropdownUnselected = Color3.fromRGB(18,22,36),
    InputBackground    = Color3.fromRGB(18,22,36),  InputStroke        = Color3.fromRGB(50,60,95),
    PlaceholderColor   = Color3.fromRGB(110,120,165),
    NotificationBackground = Color3.fromRGB(18,22,36),
    TopAccent = Color3.fromRGB(130,160,255),         SectionText = Color3.fromRGB(80,95,155),
    BtnHover  = Color3.fromRGB(30,36,56),            BtnActive   = Color3.fromRGB(40,48,74),
}

-- Live color table
local C = {}
local function applyTheme(t)
    local src = (type(t) == "string" and Themes[t]) or (type(t) == "table" and t) or Themes.Ocean
    for k, v in pairs(src) do C[k] = v end
end
applyTheme("Ocean")

-- =====================================================================
-- HELPERS
-- =====================================================================

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
    s.Color        = col or C.Border
    s.Thickness    = th or 1
    s.Transparency = tr or 0
    return s
end

-- =====================================================================
-- DEVNGG OBJECT
-- =====================================================================

local mainFrame  = nil
local guiVisible = true

local DevNgg   = {}
DevNgg.Flags   = flags
DevNgg.Themes  = Themes

function DevNgg:SetVisibility(val)
    guiVisible = val
    if mainFrame then mainFrame.Visible = val end
end
function DevNgg:IsVisible() return guiVisible end
function DevNgg:Destroy()
    if mainFrame then mainFrame.Parent:Destroy() end
end

-- =====================================================================
-- NOTIFICATIONS
-- =====================================================================

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "DevNggNotif"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() notifGui.DisplayOrder = 998 end)
pcall(function() notifGui.IgnoreGuiInset = true end)
safeParent(notifGui)

local notifHolder = Instance.new("Frame", notifGui)
notifHolder.Name                 = "NotifHolder"
notifHolder.Size                 = UDim2.new(0, 290, 1, 0)
notifHolder.Position             = UDim2.new(1, -305, 0, 0)
notifHolder.BackgroundTransparency = 1

local notifList = Instance.new("UIListLayout", notifHolder)
notifList.VerticalAlignment   = Enum.VerticalAlignment.Bottom
notifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifList.SortOrder           = Enum.SortOrder.LayoutOrder
notifList.Padding             = UDim.new(0, 6)

local notifPad = Instance.new("UIPadding", notifHolder)
notifPad.PaddingBottom = UDim.new(0, 18)

function DevNgg:Notify(cfg)
    local title    = cfg.Title    or "DevN.gg"
    local content  = cfg.Content  or ""
    local duration = cfg.Duration or 3

    local card = Instance.new("Frame", notifHolder)
    card.Size                 = UDim2.new(1, 0, 0, 62)
    card.BackgroundColor3     = C.NotificationBackground
    card.BackgroundTransparency = 1
    card.BorderSizePixel      = 0
    card.ClipsDescendants     = true
    mkCorner(card, 10)
    local cs = mkStroke(card, C.Border, 1, 1)

    local bar = Instance.new("Frame", card)
    bar.Size                 = UDim2.new(0, 3, 1, -16)
    bar.Position             = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3     = C.Accent
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel      = 0
    mkCorner(bar, 2)

    local gBg = Instance.new("Frame", card)
    gBg.Size             = UDim2.new(1, 0, 1, 0)
    gBg.BackgroundColor3 = C.Accent
    gBg.BackgroundTransparency = 0.95
    gBg.BorderSizePixel  = 0

    local t = Instance.new("TextLabel", card)
    t.Size             = UDim2.new(1, -22, 0, 20)
    t.Position         = UDim2.new(0, 14, 0, 10)
    t.BackgroundTransparency = 1
    t.Text             = title
    t.TextColor3       = C.TextColor
    t.TextTransparency = 1
    t.TextSize         = 13
    t.Font             = Enum.Font.GothamBold
    t.TextXAlignment   = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size             = UDim2.new(1, -22, 0, 18)
    sub.Position         = UDim2.new(0, 14, 0, 32)
    sub.BackgroundTransparency = 1
    sub.Text             = content
    sub.TextColor3       = C.TextMid
    sub.TextTransparency = 1
    sub.TextSize         = 11
    sub.Font             = Enum.Font.Gotham
    sub.TextXAlignment   = Enum.TextXAlignment.Left
    sub.TextWrapped      = true

    local progBg = Instance.new("Frame", card)
    progBg.Size             = UDim2.new(1, 0, 0, 2)
    progBg.Position         = UDim2.new(0, 0, 1, -2)
    progBg.BackgroundColor3 = C.Border
    progBg.BorderSizePixel  = 0

    local prog = Instance.new("Frame", progBg)
    prog.Size             = UDim2.new(1, 0, 1, 0)
    prog.BackgroundColor3 = C.Accent
    prog.BorderSizePixel  = 0

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

-- =====================================================================
-- CREATE WINDOW
-- =====================================================================

function DevNgg:CreateWindow(config)
    local windowTitle = config.Name            or "DevN.gg"
    local windowSub   = config.LoadingSubtitle or "by DevN.gg"
    local windowVer   = config.Version         or "v1.0"
    local toggleKey   = config.ToggleUIKeybind or "K"
    local themeCfg    = config.Theme           or "Ocean"

    applyTheme(themeCfg)

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name              = "DevNggGUI"
    screenGui.ResetOnSpawn      = false
    screenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.DisplayOrder = 999 end)
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
    main.Size             = UDim2.new(0, 480, 0, 400)
    main.Position         = UDim2.new(0.5, -240, 0.5, -200)
    main.BackgroundColor3 = C.Background
    main.BorderSizePixel  = 0
    main.ClipsDescendants = true
    mkCorner(main, 12)
    local mainStroke = mkStroke(main, C.Border, 1)
    mainFrame = main

    local topAccentLine = Instance.new("Frame", main)
    topAccentLine.Size             = UDim2.new(1, 0, 0, 2)
    topAccentLine.BackgroundColor3 = C.TopAccent
    topAccentLine.BorderSizePixel  = 0
    topAccentLine.ZIndex           = 5

    -- Header
    local header = Instance.new("Frame", main)
    header.Size             = UDim2.new(1, 0, 0, 48)
    header.Position         = UDim2.new(0, 0, 0, 2)
    header.BackgroundColor3 = C.Topbar
    header.BorderSizePixel  = 0

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size             = UDim2.new(1, -110, 1, 0)
    titleLbl.Position         = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text             = windowTitle
    titleLbl.TextColor3       = C.TextColor
    titleLbl.TextSize         = 15
    titleLbl.Font             = Enum.Font.GothamBold
    titleLbl.TextXAlignment   = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", header)
    subLbl.Size             = UDim2.new(0, 220, 0, 14)
    subLbl.Position         = UDim2.new(0, 14, 1, -16)
    subLbl.BackgroundTransparency = 1
    subLbl.Text             = windowSub .. "  ·  " .. windowVer
    subLbl.TextColor3       = C.TextDim
    subLbl.TextSize         = 10
    subLbl.Font             = Enum.Font.Gotham
    subLbl.TextXAlignment   = Enum.TextXAlignment.Left

    local function mkBtn(xOffset, sym)
        local b = Instance.new("TextButton", header)
        b.Size             = UDim2.new(0, 24, 0, 24)
        b.Position         = UDim2.new(1, xOffset, 0.5, -12)
        b.BackgroundColor3 = C.ElementBackground
        b.Text             = sym
        b.TextColor3       = C.TextDim
        b.TextSize         = 13
        b.Font             = Enum.Font.GothamBold
        b.BorderSizePixel  = 0
        b.AutoButtonColor  = false
        b.ZIndex           = 10
        mkCorner(b, 6)
        mkStroke(b, C.Border, 1)
        b.MouseEnter:Connect(function() tw(b, FAST, { TextColor3 = C.TextColor, BackgroundColor3 = C.BtnHover }) end)
        b.MouseLeave:Connect(function() tw(b, FAST, { TextColor3 = C.TextDim, BackgroundColor3 = C.ElementBackground }) end)
        return b
    end

    local closeBtn = mkBtn(-10, "×")
    local minBtn   = mkBtn(-40, "−")

    closeBtn.MouseButton1Click:Connect(function() DevNgg:SetVisibility(false) end)

    local headerSep = Instance.new("Frame", main)
    headerSep.Size             = UDim2.new(1, 0, 0, 1)
    headerSep.Position         = UDim2.new(0, 0, 0, 50)
    headerSep.BackgroundColor3 = C.Border
    headerSep.BorderSizePixel  = 0

    -- Tab bar
    local tabBar = Instance.new("Frame", main)
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(1, 0, 0, 36)
    tabBar.Position         = UDim2.new(0, 0, 0, 51)
    tabBar.BackgroundColor3 = C.Topbar
    tabBar.BorderSizePixel  = 0

    local tabBarList = Instance.new("UIListLayout", tabBar)
    tabBarList.FillDirection      = Enum.FillDirection.Horizontal
    tabBarList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabBarList.VerticalAlignment  = Enum.VerticalAlignment.Center
    tabBarList.SortOrder          = Enum.SortOrder.LayoutOrder
    tabBarList.Padding            = UDim.new(0, 0)

    local tabBarPad = Instance.new("UIPadding", tabBar)
    tabBarPad.PaddingLeft = UDim.new(0, 8)

    local tabSep = Instance.new("Frame", main)
    tabSep.Size             = UDim2.new(1, 0, 0, 1)
    tabSep.Position         = UDim2.new(0, 0, 0, 87)
    tabSep.BackgroundColor3 = C.Border
    tabSep.BorderSizePixel  = 0

    local contentArea = Instance.new("Frame", main)
    contentArea.Name             = "ContentArea"
    contentArea.Size             = UDim2.new(1, 0, 1, -88)
    contentArea.Position         = UDim2.new(0, 0, 0, 88)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true

    local minimized    = false
    local tabFrames    = {}
    local tabButtons   = {}
    local tabUnderlines = {}
    local activeTab    = nil

    local function switchTab(name)
        for n, frame in pairs(tabFrames) do frame.Visible = (n == name) end
        for n, btn in pairs(tabButtons) do
            local lbl = btn:FindFirstChildOfClass("TextLabel")
            local ul  = tabUnderlines[n]
            if n == name then
                if lbl then tw(lbl, FAST, { TextColor3 = C.Accent }) end
                if ul  then tw(ul,  FAST, { BackgroundTransparency = 0 }) end
            else
                if lbl then tw(lbl, FAST, { TextColor3 = C.TextDim }) end
                if ul  then tw(ul,  FAST, { BackgroundTransparency = 1 }) end
            end
        end
        activeTab = name
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tabBar.Visible    = not minimized
        tabSep.Visible    = not minimized
        headerSep.Visible = not minimized
        contentArea.Visible = not minimized
        tw(main, MED, { Size = UDim2.new(0, 480, 0, minimized and 50 or 400) })
        minBtn.Text = minimized and "+" or "−"
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        pcall(function()
            local key = typeof(toggleKey) == "string" and Enum.KeyCode[toggleKey] or toggleKey
            if input.KeyCode == key then DevNgg:SetVisibility(not guiVisible) end
        end)
    end)

    -- Drag
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

    -- =================================================================
    -- WINDOW OBJECT
    -- =================================================================

    local Window = {}

    -- ModifyTheme — matches Rayfield API: Window:ModifyTheme('ThemeIdentifier') or custom table
    function Window:ModifyTheme(t)
        applyTheme(t)
        main.BackgroundColor3      = C.Background
        mainStroke.Color           = C.Border
        header.BackgroundColor3    = C.Topbar
        tabBar.BackgroundColor3    = C.Topbar
        headerSep.BackgroundColor3 = C.Border
        tabSep.BackgroundColor3    = C.Border
        topAccentLine.BackgroundColor3 = C.TopAccent
        titleLbl.TextColor3        = C.TextColor
        subLbl.TextColor3          = C.TextDim
    end

    -- =================================================================
    -- CREATE TAB
    -- =================================================================

    function Window:CreateTab(name, _icon)
        local tabBtn = Instance.new("TextButton", tabBar)
        tabBtn.Name             = name
        tabBtn.Size             = UDim2.new(0, 0, 1, 0)
        tabBtn.AutomaticSize    = Enum.AutomaticSize.X
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel  = 0
        tabBtn.Text             = ""
        tabBtn.AutoButtonColor  = false

        local tabPad = Instance.new("UIPadding", tabBtn)
        tabPad.PaddingLeft  = UDim.new(0, 14)
        tabPad.PaddingRight = UDim.new(0, 14)

        local tabLbl = Instance.new("TextLabel", tabBtn)
        tabLbl.Size               = UDim2.new(1, 0, 1, -4)
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text               = name
        tabLbl.TextColor3         = C.TextDim
        tabLbl.TextSize           = 12
        tabLbl.Font               = Enum.Font.GothamSemibold
        tabLbl.TextXAlignment     = Enum.TextXAlignment.Center

        local underline = Instance.new("Frame", tabBtn)
        underline.Name                 = "Underline"
        underline.Size                 = UDim2.new(1, -16, 0, 2)
        underline.Position             = UDim2.new(0, 8, 1, -2)
        underline.BackgroundColor3     = C.Accent
        underline.BorderSizePixel      = 0
        underline.BackgroundTransparency = 1
        mkCorner(underline, 2)

        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= name then tw(tabLbl, FAST, { TextColor3 = C.TextMid }) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= name then tw(tabLbl, FAST, { TextColor3 = C.TextDim }) end
        end)
        tabBtn.MouseButton1Click:Connect(function() switchTab(name) end)

        tabButtons[name]    = tabBtn
        tabUnderlines[name] = underline

        local scrollFrame = Instance.new("ScrollingFrame", contentArea)
        scrollFrame.Name                = name
        scrollFrame.Size                = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel     = 0
        scrollFrame.ScrollBarThickness  = 3
        scrollFrame.ScrollBarImageColor3 = C.AccentDark
        scrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Visible             = false

        local listLayout = Instance.new("UIListLayout", scrollFrame)
        listLayout.Padding             = UDim.new(0, 6)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.SortOrder           = Enum.SortOrder.LayoutOrder

        local pad = Instance.new("UIPadding", scrollFrame)
        pad.PaddingTop    = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft   = UDim.new(0, 12)
        pad.PaddingRight  = UDim.new(0, 16)

        tabFrames[name] = scrollFrame
        if not activeTab then switchTab(name) end

        -- =============================================================
        -- TAB OBJECT
        -- =============================================================

        local Tab = {}

        -- SECTION
        function Tab:CreateSection(sectionName)
            local row = Instance.new("Frame", scrollFrame)
            row.Size                = UDim2.new(1, 0, 0, 26)
            row.BackgroundTransparency = 1

            local line = Instance.new("Frame", row)
            line.Size             = UDim2.new(1, 0, 0, 1)
            line.Position         = UDim2.new(0, 0, 0.5, 0)
            line.BackgroundColor3 = C.Border
            line.BorderSizePixel  = 0

            local lbl = Instance.new("TextLabel", row)
            lbl.Size             = UDim2.new(0, 0, 1, 0)
            lbl.AutomaticSize    = Enum.AutomaticSize.X
            lbl.BackgroundColor3 = C.Background
            lbl.BorderSizePixel  = 0
            lbl.Text             = "  " .. sectionName:upper() .. "  "
            lbl.TextColor3       = C.SectionText
            lbl.TextSize         = 9
            lbl.Font             = Enum.Font.GothamBold
            lbl.TextXAlignment   = Enum.TextXAlignment.Left

            local Section = {}
            function Section:Set(n) lbl.Text = "  " .. n:upper() .. "  " end
            return Section
        end

        -- DIVIDER
        function Tab:CreateDivider()
            local div = Instance.new("Frame", scrollFrame)
            div.Size             = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = C.Border
            div.BorderSizePixel  = 0
            local Divider = {}
            function Divider:Set(v) div.Visible = v end
            return Divider
        end

        -- LABEL  — Tab:CreateLabel("Text", icon, Color3, ignoreTheme)
        function Tab:CreateLabel(text, _icon, color, _ignoreTheme)
            local row = Instance.new("Frame", scrollFrame)
            row.Size             = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = C.ElementBackground
            row.BorderSizePixel  = 0
            mkCorner(row, 8)
            mkStroke(row, C.ElementStroke, 1)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size             = UDim2.new(1, -24, 1, 0)
            lbl.Position         = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text             = text or "Label"
            lbl.TextColor3       = color or C.TextColor
            lbl.TextSize         = 13
            lbl.Font             = Enum.Font.Gotham
            lbl.TextXAlignment   = Enum.TextXAlignment.Left
            lbl.TextWrapped      = true

            local Label = {}
            function Label:Set(newText, _ic, newColor, _ign)
                if newText  then lbl.Text      = newText  end
                if newColor then lbl.TextColor3 = newColor end
            end
            return Label
        end

        -- PARAGRAPH  — Tab:CreateParagraph({Title="", Content=""})
        function Tab:CreateParagraph(cfg)
            local wrapper = Instance.new("Frame", scrollFrame)
            wrapper.Size             = UDim2.new(1, 0, 0, 0)
            wrapper.AutomaticSize    = Enum.AutomaticSize.Y
            wrapper.BackgroundColor3 = C.ElementBackground
            wrapper.BorderSizePixel  = 0
            mkCorner(wrapper, 8)
            mkStroke(wrapper, C.ElementStroke, 1)

            local wPad = Instance.new("UIPadding", wrapper)
            wPad.PaddingTop    = UDim.new(0, 10)
            wPad.PaddingBottom = UDim.new(0, 10)
            wPad.PaddingLeft   = UDim.new(0, 12)
            wPad.PaddingRight  = UDim.new(0, 12)

            local wList = Instance.new("UIListLayout", wrapper)
            wList.Padding             = UDim.new(0, 4)
            wList.SortOrder           = Enum.SortOrder.LayoutOrder
            wList.HorizontalAlignment = Enum.HorizontalAlignment.Left

            local titleLb = Instance.new("TextLabel", wrapper)
            titleLb.Size             = UDim2.new(1, 0, 0, 0)
            titleLb.AutomaticSize    = Enum.AutomaticSize.Y
            titleLb.BackgroundTransparency = 1
            titleLb.Text             = cfg.Title or "Paragraph"
            titleLb.TextColor3       = C.TextColor
            titleLb.TextSize         = 13
            titleLb.Font             = Enum.Font.GothamBold
            titleLb.TextXAlignment   = Enum.TextXAlignment.Left
            titleLb.TextWrapped      = true
            titleLb.LayoutOrder      = 1

            local bodyLb = Instance.new("TextLabel", wrapper)
            bodyLb.Size             = UDim2.new(1, 0, 0, 0)
            bodyLb.AutomaticSize    = Enum.AutomaticSize.Y
            bodyLb.BackgroundTransparency = 1
            bodyLb.Text             = cfg.Content or ""
            bodyLb.TextColor3       = C.TextMid
            bodyLb.TextSize         = 12
            bodyLb.Font             = Enum.Font.Gotham
            bodyLb.TextXAlignment   = Enum.TextXAlignment.Left
            bodyLb.TextWrapped      = true
            bodyLb.LayoutOrder      = 2

            local Paragraph = {}
            function Paragraph:Set(newCfg)
                if newCfg.Title   then titleLb.Text = newCfg.Title   end
                if newCfg.Content then bodyLb.Text  = newCfg.Content end
            end
            return Paragraph
        end

        -- BUTTON
        function Tab:CreateButton(cfg)
            local btn = Instance.new("TextButton", scrollFrame)
            btn.Size             = UDim2.new(1, 0, 0, 42)
            btn.BackgroundColor3 = C.ElementBackground
            btn.BorderSizePixel  = 0
            btn.Text             = cfg.Name or "Button"
            btn.TextColor3       = C.TextMid
            btn.TextSize         = 13
            btn.Font             = Enum.Font.Gotham
            btn.AutoButtonColor  = false
            mkCorner(btn, 8)
            mkStroke(btn, C.ElementStroke, 1)

            btn.MouseButton1Click:Connect(function()
                tw(btn, FAST, { BackgroundColor3 = C.BtnActive, TextColor3 = C.TextColor })
                task.delay(0.14, function()
                    tw(btn, MED, { BackgroundColor3 = C.ElementBackground, TextColor3 = C.TextMid })
                end)
                if cfg.Callback then cfg.Callback() end
            end)
            btn.MouseEnter:Connect(function() tw(btn, FAST, { BackgroundColor3 = C.BtnHover, TextColor3 = C.TextColor }) end)
            btn.MouseLeave:Connect(function() tw(btn, FAST, { BackgroundColor3 = C.ElementBackground, TextColor3 = C.TextMid }) end)

            local Button = {}
            function Button:Set(newName) btn.Text = newName end
            return Button
        end

        -- TOGGLE
        function Tab:CreateToggle(cfg)
            local flag         = cfg.Flag
            local currentValue = cfg.CurrentValue or false

            local row = Instance.new("TextButton", scrollFrame)
            row.Size             = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = C.ElementBackground
            row.BorderSizePixel  = 0
            row.Text             = ""
            row.AutoButtonColor  = false
            mkCorner(row, 8)
            local rs = mkStroke(row, C.ElementStroke, 1)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size             = UDim2.new(1, -62, 1, 0)
            lbl.Position         = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text             = cfg.Name or "Toggle"
            lbl.TextColor3       = C.TextMid
            lbl.TextSize         = 13
            lbl.Font             = Enum.Font.Gotham
            lbl.TextXAlignment   = Enum.TextXAlignment.Left

            local pill = Instance.new("Frame", row)
            pill.Size             = UDim2.new(0, 40, 0, 22)
            pill.Position         = UDim2.new(1, -52, 0.5, -11)
            pill.BackgroundColor3 = C.ToggleBackground
            pill.BorderSizePixel  = 0
            mkCorner(pill, 11)
            local pillStroke = mkStroke(pill, C.ToggleDisabledStroke, 1)

            local knob = Instance.new("Frame", pill)
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = C.AccentDark
            knob.BorderSizePixel  = 0
            mkCorner(knob, 8)

            local enabled = currentValue

            local function setState(val, silent)
                enabled = val
                if flag then
                    flags[flag] = val
                    if not silent then saveConfig() end
                end
                if val then
                    tw(pill, FAST, { BackgroundColor3 = C.ToggleEnabled })
                    tw(pillStroke, FAST, { Color = C.ToggleEnabledStroke })
                    tw(knob, FAST, { Position = UDim2.new(0, 21, 0.5, -8), BackgroundColor3 = C.TextColor })
                    tw(lbl,  FAST, { TextColor3 = C.TextColor })
                    tw(rs,   FAST, { Color = C.Border2 })
                else
                    tw(pill, FAST, { BackgroundColor3 = C.ToggleBackground })
                    tw(pillStroke, FAST, { Color = C.ToggleDisabledStroke })
                    tw(knob, FAST, { Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = C.AccentDark })
                    tw(lbl,  FAST, { TextColor3 = C.TextMid })
                    tw(rs,   FAST, { Color = C.ElementStroke })
                end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            if enabled then setState(true, true) end
            if flag then toggleSetters[flag] = setState end

            row.MouseButton1Click:Connect(function() setState(not enabled) end)
            row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BtnHover }) end)
            row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundColor3 = C.ElementBackground }) end)

            local Toggle = {}
            Toggle.CurrentValue = enabled
            function Toggle:Set(val) setState(val, false) end
            return Toggle
        end

        -- SLIDER
        function Tab:CreateSlider(cfg)
            local flag    = cfg.Flag
            local min     = (cfg.Range and cfg.Range[1]) or 0
            local max     = (cfg.Range and cfg.Range[2]) or 100
            local inc     = cfg.Increment   or 1
            local suffix  = cfg.Suffix      or ""
            local current = math.clamp(cfg.CurrentValue or min, min, max)

            local wrapper = Instance.new("Frame", scrollFrame)
            wrapper.Size             = UDim2.new(1, 0, 0, 58)
            wrapper.BackgroundColor3 = C.ElementBackground
            wrapper.BorderSizePixel  = 0
            mkCorner(wrapper, 8)
            mkStroke(wrapper, C.ElementStroke, 1)

            local nameLbl = Instance.new("TextLabel", wrapper)
            nameLbl.Size             = UDim2.new(1, -80, 0, 20)
            nameLbl.Position         = UDim2.new(0, 12, 0, 8)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text             = cfg.Name or "Slider"
            nameLbl.TextColor3       = C.TextMid
            nameLbl.TextSize         = 13
            nameLbl.Font             = Enum.Font.Gotham
            nameLbl.TextXAlignment   = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel", wrapper)
            valLbl.Size             = UDim2.new(0, 70, 0, 20)
            valLbl.Position         = UDim2.new(1, -78, 0, 8)
            valLbl.BackgroundTransparency = 1
            valLbl.Text             = tostring(current) .. (suffix ~= "" and " " .. suffix or "")
            valLbl.TextColor3       = C.Accent
            valLbl.TextSize         = 12
            valLbl.Font             = Enum.Font.GothamBold
            valLbl.TextXAlignment   = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", wrapper)
            track.Size             = UDim2.new(1, -24, 0, 6)
            track.Position         = UDim2.new(0, 12, 0, 38)
            track.BackgroundColor3 = C.SecondaryElementBackground
            track.BorderSizePixel  = 0
            mkCorner(track, 3)
            mkStroke(track, C.SliderStroke, 1)

            local fill = Instance.new("Frame", track)
            fill.BackgroundColor3 = C.SliderProgress
            fill.BorderSizePixel  = 0
            fill.Size             = UDim2.new((current - min) / math.max(max - min, 0.001), 0, 1, 0)
            mkCorner(fill, 3)

            local knob = Instance.new("Frame", fill)
            knob.AnchorPoint      = Vector2.new(1, 0.5)
            knob.Position         = UDim2.new(1, 0, 0.5, 0)
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.BackgroundColor3 = C.Accent
            knob.BorderSizePixel  = 0
            mkCorner(knob, 6)

            if flag then flags[flag] = current end

            local function setSlider(val, silent)
                local snapped = math.floor((val - min) / inc + 0.5) * inc + min
                snapped = math.clamp(snapped, min, max)
                current = snapped
                local t = (snapped - min) / math.max(max - min, 0.001)
                tw(fill, FAST, { Size = UDim2.new(t, 0, 1, 0) })
                valLbl.Text = tostring(snapped) .. (suffix ~= "" and " " .. suffix or "")
                if flag then flags[flag] = snapped end
                if not silent then
                    saveConfig()
                    if cfg.Callback then cfg.Callback(snapped) end
                end
            end

            local sliding = false
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    setSlider(min + rel * (max - min))
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    setSlider(min + rel * (max - min))
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)

            local Slider = {}
            Slider.CurrentValue = current
            function Slider:Set(val) setSlider(val, false) end
            return Slider
        end

        -- INPUT (Adaptive TextBox)  — Tab:CreateInput(cfg)
        function Tab:CreateInput(cfg)
            local flag = cfg.Flag

            local wrapper = Instance.new("Frame", scrollFrame)
            wrapper.Size                = UDim2.new(1, 0, 0, 66)
            wrapper.BackgroundTransparency = 1
            wrapper.BorderSizePixel     = 0

            local nameLbl = Instance.new("TextLabel", wrapper)
            nameLbl.Size             = UDim2.new(1, 0, 0, 16)
            nameLbl.Position         = UDim2.new(0, 2, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text             = cfg.Name or "Input"
            nameLbl.TextColor3       = C.TextMid
            nameLbl.TextSize         = 11
            nameLbl.Font             = Enum.Font.GothamBold
            nameLbl.TextXAlignment   = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", wrapper)
            box.Size              = UDim2.new(1, 0, 0, 42)
            box.Position          = UDim2.new(0, 0, 0, 20)
            box.BackgroundColor3  = C.InputBackground
            box.BorderSizePixel   = 0
            box.Text              = cfg.CurrentValue or cfg.Default or ""
            box.PlaceholderText   = cfg.PlaceholderText or cfg.Placeholder or "Type here..."
            box.TextColor3        = C.TextColor
            box.PlaceholderColor3 = C.PlaceholderColor
            box.TextSize          = 13
            box.Font              = Enum.Font.Gotham
            box.ClearTextOnFocus  = false
            mkCorner(box, 8)
            local bs = mkStroke(box, C.InputStroke, 1)

            local boxPad = Instance.new("UIPadding", box)
            boxPad.PaddingLeft  = UDim.new(0, 10)
            boxPad.PaddingRight = UDim.new(0, 10)

            box.Focused:Connect(function() tw(bs, FAST, { Color = C.Accent }) end)
            box.FocusLost:Connect(function(enterPressed)
                tw(bs, FAST, { Color = C.InputStroke })
                if cfg.RemoveTextAfterFocusLost and not enterPressed then box.Text = "" end
                if flag then flags[flag] = box.Text; saveConfig() end
                if cfg.Callback then cfg.Callback(box.Text) end
            end)

            local Input = {}
            Input.CurrentValue = box.Text
            function Input:Set(v) box.Text = v end
            function Input:GetValue() return box.Text end
            return Input
        end

        -- Alias (old API compat)
        Tab.CreateTextInput = Tab.CreateInput

        -- DROPDOWN
        function Tab:CreateDropdown(cfg)
            local flag     = cfg.Flag
            local options  = cfg.Options or {}
            local multi    = cfg.MultipleOptions or false
            local selected = cfg.CurrentOption or {}
            if type(selected) == "string" then selected = { selected } end

            local wrapper = Instance.new("Frame", scrollFrame)
            wrapper.Size                = UDim2.new(1, 0, 0, 0)
            wrapper.AutomaticSize       = Enum.AutomaticSize.Y
            wrapper.BackgroundTransparency = 1
            wrapper.BorderSizePixel     = 0
            wrapper.ClipsDescendants    = false

            local nameLbl = Instance.new("TextLabel", wrapper)
            nameLbl.Size                = UDim2.new(1, 0, 0, 18)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text                = cfg.Name or "Dropdown"
            nameLbl.TextColor3          = C.TextMid
            nameLbl.TextSize            = 11
            nameLbl.Font                = Enum.Font.GothamBold
            nameLbl.TextXAlignment      = Enum.TextXAlignment.Left

            local hdr = Instance.new("TextButton", wrapper)
            hdr.Size             = UDim2.new(1, 0, 0, 40)
            hdr.Position         = UDim2.new(0, 0, 0, 20)
            hdr.BackgroundColor3 = C.DropdownUnselected
            hdr.BorderSizePixel  = 0
            hdr.Text             = ""
            hdr.AutoButtonColor  = false
            mkCorner(hdr, 8)
            local hs = mkStroke(hdr, C.ElementStroke, 1)

            local selLbl = Instance.new("TextLabel", hdr)
            selLbl.Size             = UDim2.new(1, -36, 1, 0)
            selLbl.Position         = UDim2.new(0, 12, 0, 0)
            selLbl.BackgroundTransparency = 1
            selLbl.TextColor3       = C.TextColor
            selLbl.TextSize         = 13
            selLbl.Font             = Enum.Font.Gotham
            selLbl.TextXAlignment   = Enum.TextXAlignment.Left

            local arrow = Instance.new("TextLabel", hdr)
            arrow.Size             = UDim2.new(0, 20, 1, 0)
            arrow.Position         = UDim2.new(1, -26, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text             = "▾"
            arrow.TextColor3       = C.TextDim
            arrow.TextSize         = 14
            arrow.Font             = Enum.Font.GothamBold
            arrow.TextXAlignment   = Enum.TextXAlignment.Center

            local listFrame = Instance.new("Frame", wrapper)
            listFrame.Position         = UDim2.new(0, 0, 0, 62)
            listFrame.BackgroundColor3 = C.DropdownUnselected
            listFrame.BorderSizePixel  = 0
            listFrame.ClipsDescendants = true
            listFrame.Visible          = false
            listFrame.Size             = UDim2.new(1, 0, 0, 0)
            mkCorner(listFrame, 8)
            mkStroke(listFrame, C.ElementStroke, 1)

            local listLayout = Instance.new("UIListLayout", listFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding   = UDim.new(0, 2)

            local listPad = Instance.new("UIPadding", listFrame)
            listPad.PaddingTop    = UDim.new(0, 4)
            listPad.PaddingBottom = UDim.new(0, 4)

            local open      = false
            local optionBtns = {}

            local function getSelText()
                if #selected == 0 then return "Select..." end
                return table.concat(selected, ", ")
            end
            selLbl.Text = getSelText()

            local function isSelected(opt)
                for _, v in ipairs(selected) do if v == opt then return true end end
                return false
            end

            local function refreshBtns()
                for opt, btn in pairs(optionBtns) do
                    btn.BackgroundColor3 = isSelected(opt) and C.DropdownSelected or C.DropdownUnselected
                    local ol = btn:FindFirstChildOfClass("TextLabel")
                    if ol then ol.TextColor3 = isSelected(opt) and C.Accent or C.TextColor end
                end
                selLbl.Text = getSelText()
            end

            local function buildOptions(opts)
                for _, btn in pairs(optionBtns) do btn:Destroy() end
                optionBtns = {}
                for _, opt in ipairs(opts) do
                    local ob = Instance.new("TextButton", listFrame)
                    ob.Size             = UDim2.new(1, -8, 0, 34)
                    ob.BackgroundColor3 = isSelected(opt) and C.DropdownSelected or C.DropdownUnselected
                    ob.BorderSizePixel  = 0
                    ob.Text             = ""
                    ob.AutoButtonColor  = false
                    mkCorner(ob, 6)

                    local ol = Instance.new("TextLabel", ob)
                    ol.Size             = UDim2.new(1, -20, 1, 0)
                    ol.Position         = UDim2.new(0, 10, 0, 0)
                    ol.BackgroundTransparency = 1
                    ol.Text             = opt
                    ol.TextColor3       = isSelected(opt) and C.Accent or C.TextColor
                    ol.TextSize         = 13
                    ol.Font             = Enum.Font.Gotham
                    ol.TextXAlignment   = Enum.TextXAlignment.Left

                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            if isSelected(opt) then
                                for i, v in ipairs(selected) do
                                    if v == opt then table.remove(selected, i); break end
                                end
                            else
                                table.insert(selected, opt)
                            end
                        else
                            selected = { opt }
                        end
                        refreshBtns()
                        if flag then flags[flag] = selected; saveConfig() end
                        if cfg.Callback then cfg.Callback(selected) end
                    end)
                    ob.MouseEnter:Connect(function()
                        if not isSelected(opt) then tw(ob, FAST, { BackgroundColor3 = C.BtnHover }) end
                    end)
                    ob.MouseLeave:Connect(function()
                        ob.BackgroundColor3 = isSelected(opt) and C.DropdownSelected or C.DropdownUnselected
                    end)
                    optionBtns[opt] = ob
                end
                listFrame.Size = UDim2.new(1, 0, 0, math.min(#opts, 6) * 36 + 8)
            end

            buildOptions(options)

            hdr.MouseButton1Click:Connect(function()
                open = not open
                listFrame.Visible = open
                tw(arrow, FAST, { TextColor3 = open and C.Accent or C.TextDim })
                tw(hs,    FAST, { Color = open and C.Accent or C.ElementStroke })
            end)
            hdr.MouseEnter:Connect(function() tw(hdr, FAST, { BackgroundColor3 = C.BtnHover }) end)
            hdr.MouseLeave:Connect(function() tw(hdr, FAST, { BackgroundColor3 = C.DropdownUnselected }) end)

            local Dropdown = {}
            Dropdown.CurrentOption = selected
            function Dropdown:Set(newSelected)
                if type(newSelected) == "string" then newSelected = { newSelected } end
                selected = newSelected
                refreshBtns()
                if flag then flags[flag] = selected; saveConfig() end
                if cfg.Callback then cfg.Callback(selected) end
            end
            function Dropdown:Refresh(newOptions)
                options = newOptions
                buildOptions(newOptions)
                refreshBtns()
            end
            return Dropdown
        end

        -- KEYBIND
        function Tab:CreateKeybind(cfg)
            local flag       = cfg.Flag
            local currentKey = cfg.CurrentKeybind or "None"
            local holdMode   = cfg.HoldToInteract  or false
            local listening  = false

            local row = Instance.new("TextButton", scrollFrame)
            row.Size             = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = C.ElementBackground
            row.BorderSizePixel  = 0
            row.Text             = ""
            row.AutoButtonColor  = false
            mkCorner(row, 8)
            mkStroke(row, C.ElementStroke, 1)

            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size             = UDim2.new(1, -100, 1, 0)
            nameLbl.Position         = UDim2.new(0, 12, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text             = cfg.Name or "Keybind"
            nameLbl.TextColor3       = C.TextMid
            nameLbl.TextSize         = 13
            nameLbl.Font             = Enum.Font.Gotham
            nameLbl.TextXAlignment   = Enum.TextXAlignment.Left

            local keyBadge = Instance.new("TextButton", row)
            keyBadge.Size             = UDim2.new(0, 84, 0, 28)
            keyBadge.Position         = UDim2.new(1, -92, 0.5, -14)
            keyBadge.BackgroundColor3 = C.SecondaryElementBackground
            keyBadge.BorderSizePixel  = 0
            keyBadge.Text             = currentKey
            keyBadge.TextColor3       = C.Accent
            keyBadge.TextSize         = 12
            keyBadge.Font             = Enum.Font.GothamBold
            keyBadge.AutoButtonColor  = false
            mkCorner(keyBadge, 6)
            mkStroke(keyBadge, C.Border, 1)

            local function setKey(k)
                currentKey = k
                keyBadge.Text       = k
                keyBadge.TextColor3 = C.Accent
                if flag then flags[flag] = k; saveConfig() end
            end

            keyBadge.MouseButton1Click:Connect(function()
                listening           = true
                keyBadge.Text       = "..."
                keyBadge.TextColor3 = C.TextDim
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if listening then
                    listening = false
                    local n = input.KeyCode.Name
                    if n ~= "Unknown" then setKey(n) end
                    return
                end
                if input.KeyCode.Name == currentKey then
                    if holdMode then
                        if cfg.Callback then cfg.Callback(true) end
                    else
                        if cfg.Callback then cfg.Callback(false) end
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if holdMode and input.KeyCode.Name == currentKey then
                    if cfg.Callback then cfg.Callback(false) end
                end
            end)

            row.MouseEnter:Connect(function() tw(row, FAST, { BackgroundColor3 = C.BtnHover }) end)
            row.MouseLeave:Connect(function() tw(row, FAST, { BackgroundColor3 = C.ElementBackground }) end)

            local Keybind = {}
            Keybind.CurrentKeybind = currentKey
            function Keybind:Set(k) setKey(k) end
            return Keybind
        end

        -- COLOR PICKER
        function Tab:CreateColorPicker(cfg)
            local flag         = cfg.Flag
            local currentColor = cfg.Color or Color3.fromRGB(255, 255, 255)
            local pickerOpen   = false

            local wrapper = Instance.new("Frame", scrollFrame)
            wrapper.Size             = UDim2.new(1, 0, 0, 46)
            wrapper.BackgroundColor3 = C.ElementBackground
            wrapper.BorderSizePixel  = 0
            wrapper.ClipsDescendants = false
            mkCorner(wrapper, 8)
            mkStroke(wrapper, C.ElementStroke, 1)

            local nameLbl = Instance.new("TextLabel", wrapper)
            nameLbl.Size             = UDim2.new(1, -70, 1, 0)
            nameLbl.Position         = UDim2.new(0, 12, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text             = cfg.Name or "Color Picker"
            nameLbl.TextColor3       = C.TextMid
            nameLbl.TextSize         = 13
            nameLbl.Font             = Enum.Font.Gotham
            nameLbl.TextXAlignment   = Enum.TextXAlignment.Left

            local preview = Instance.new("TextButton", wrapper)
            preview.Size             = UDim2.new(0, 50, 0, 28)
            preview.Position         = UDim2.new(1, -58, 0.5, -14)
            preview.BackgroundColor3 = currentColor
            preview.BorderSizePixel  = 0
            preview.Text             = ""
            preview.AutoButtonColor  = false
            mkCorner(preview, 6)
            mkStroke(preview, C.Border, 1)

            local panel = Instance.new("Frame", wrapper)
            panel.Size             = UDim2.new(1, 0, 0, 160)
            panel.Position         = UDim2.new(0, 0, 1, 6)
            panel.BackgroundColor3 = C.SecondaryElementBackground
            panel.BorderSizePixel  = 0
            panel.Visible          = false
            panel.ZIndex           = 20
            mkCorner(panel, 8)
            mkStroke(panel, C.Border, 1)

            local pPad = Instance.new("UIPadding", panel)
            pPad.PaddingTop    = UDim.new(0, 10)
            pPad.PaddingBottom = UDim.new(0, 10)
            pPad.PaddingLeft   = UDim.new(0, 12)
            pPad.PaddingRight  = UDim.new(0, 12)

            local h, s, v = Color3.toHSV(currentColor)

            local function mkHSVSlider(label, yPos, initVal)
                local l = Instance.new("TextLabel", panel)
                l.Size             = UDim2.new(0, 12, 0, 14)
                l.Position         = UDim2.new(0, 0, 0, yPos)
                l.BackgroundTransparency = 1
                l.Text             = label
                l.TextColor3       = C.TextDim
                l.TextSize         = 10
                l.Font             = Enum.Font.GothamBold
                l.ZIndex           = 21

                local tr = Instance.new("Frame", panel)
                tr.Size             = UDim2.new(1, -20, 0, 8)
                tr.Position         = UDim2.new(0, 18, 0, yPos + 3)
                tr.BackgroundColor3 = C.Border
                tr.BorderSizePixel  = 0
                tr.ZIndex           = 21
                mkCorner(tr, 4)

                local fi = Instance.new("Frame", tr)
                fi.BackgroundColor3 = C.Accent
                fi.BorderSizePixel  = 0
                fi.Size             = UDim2.new(initVal, 0, 1, 0)
                fi.ZIndex           = 22
                mkCorner(fi, 4)

                return tr, fi
            end

            local hTrack, hFill = mkHSVSlider("H", 0,  h)
            local sTrack, sFill = mkHSVSlider("S", 26, s)
            local vTrack, vFill = mkHSVSlider("V", 52, v)

            local hexBox = Instance.new("TextBox", panel)
            hexBox.Size             = UDim2.new(1, 0, 0, 30)
            hexBox.Position         = UDim2.new(0, 0, 0, 82)
            hexBox.BackgroundColor3 = C.InputBackground
            hexBox.BorderSizePixel  = 0
            hexBox.TextColor3       = C.TextColor
            hexBox.PlaceholderColor3 = C.PlaceholderColor
            hexBox.PlaceholderText  = "#FFFFFF"
            hexBox.TextSize         = 12
            hexBox.Font             = Enum.Font.Gotham
            hexBox.ClearTextOnFocus = false
            hexBox.ZIndex           = 21
            mkCorner(hexBox, 6)
            mkStroke(hexBox, C.InputStroke, 1)

            local function updateColor()
                currentColor = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = currentColor
                local r = math.floor(currentColor.R * 255 + 0.5)
                local g = math.floor(currentColor.G * 255 + 0.5)
                local b = math.floor(currentColor.B * 255 + 0.5)
                hexBox.Text = string.format("#%02X%02X%02X", r, g, b)
                hFill.Size  = UDim2.new(h, 0, 1, 0)
                sFill.Size  = UDim2.new(s, 0, 1, 0)
                vFill.Size  = UDim2.new(v, 0, 1, 0)
                if flag then flags[flag] = currentColor; saveConfig() end
                if cfg.Callback then cfg.Callback(currentColor) end
            end
            updateColor()

            local function makeDragLogic(track, onVal)
                local draggingCP = false
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingCP = true
                        onVal(math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingCP and input.UserInputType == Enum.UserInputType.MouseMovement then
                        onVal(math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCP = false end
                end)
            end

            makeDragLogic(hTrack, function(val) h = val; updateColor() end)
            makeDragLogic(sTrack, function(val) s = val; updateColor() end)
            makeDragLogic(vTrack, function(val) v = val; updateColor() end)

            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#", "")
                if #hex == 6 then
                    local rn = tonumber(hex:sub(1,2), 16)
                    local gn = tonumber(hex:sub(3,4), 16)
                    local bn = tonumber(hex:sub(5,6), 16)
                    if rn and gn and bn then
                        h, s, v = Color3.toHSV(Color3.fromRGB(rn, gn, bn))
                        updateColor()
                    end
                end
            end)

            preview.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                panel.Visible = pickerOpen
                wrapper.Size  = UDim2.new(1, 0, 0, pickerOpen and 216 or 46)
            end)

            local ColorPicker = {}
            ColorPicker.CurrentColor = currentColor
            function ColorPicker:Set(color)
                currentColor = color
                h, s, v = Color3.toHSV(color)
                updateColor()
            end
            return ColorPicker
        end

        return Tab
    end

    -- Load saved config
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
