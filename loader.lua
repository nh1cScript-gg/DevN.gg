-- DevN.gg GUI Library
-- Rayfield-style layout: pill tabs, inline values, dark rounded design

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
        local d = {}; for k,v in pairs(flags) do d[k]=v end
        writefile(getSavePath(), HttpService:JSONEncode(d))
    end)
end
local function loadConfig()
    local ok,r = pcall(function()
        if isfolder(saveFolder) and isfile(getSavePath()) then
            return HttpService:JSONDecode(readfile(getSavePath()))
        end return {}
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

-- ============================================================
-- THEMES
-- ============================================================
local Themes = {}
Themes.Default = {
    Background=Color3.fromRGB(25,25,25), Topbar=Color3.fromRGB(34,34,34),
    TextColor=Color3.fromRGB(240,240,240), TextMid=Color3.fromRGB(160,160,160),
    TextDim=Color3.fromRGB(90,90,90), Accent=Color3.fromRGB(58,163,255),
    AccentDark=Color3.fromRGB(30,100,180), Border=Color3.fromRGB(50,50,50),
    ElementBackground=Color3.fromRGB(35,35,35), ElementBackgroundHover=Color3.fromRGB(42,42,42),
    SecondaryElementBackground=Color3.fromRGB(28,28,28),
    ElementStroke=Color3.fromRGB(48,48,48), SecondaryElementStroke=Color3.fromRGB(40,40,40),
    SliderProgress=Color3.fromRGB(50,138,220), SliderStroke=Color3.fromRGB(58,163,255),
    ToggleEnabled=Color3.fromRGB(100,100,100), ToggleDisabled=Color3.fromRGB(60,60,60),
    ToggleEnabledStroke=Color3.fromRGB(120,120,120), ToggleDisabledStroke=Color3.fromRGB(55,55,55),
    DropdownSelected=Color3.fromRGB(42,42,42), DropdownUnselected=Color3.fromRGB(35,35,35),
    InputBackground=Color3.fromRGB(35,35,35), InputStroke=Color3.fromRGB(55,55,55),
    PlaceholderColor=Color3.fromRGB(100,100,100), NotificationBackground=Color3.fromRGB(30,30,30),
    TopAccent=Color3.fromRGB(58,163,255), SectionText=Color3.fromRGB(90,90,90),
    TabPill=Color3.fromRGB(42,42,42), TabPillSelected=Color3.fromRGB(58,58,58),
    BtnHover=Color3.fromRGB(42,42,42), BtnActive=Color3.fromRGB(50,50,50),
    ValueText=Color3.fromRGB(100,100,100),
}
Themes.AmberGlow = {
    Background=Color3.fromRGB(20,15,8), Topbar=Color3.fromRGB(28,20,10),
    TextColor=Color3.fromRGB(255,240,200), TextMid=Color3.fromRGB(200,160,80),
    TextDim=Color3.fromRGB(110,80,30), Accent=Color3.fromRGB(255,190,40),
    AccentDark=Color3.fromRGB(180,120,0), Border=Color3.fromRGB(60,44,14),
    ElementBackground=Color3.fromRGB(30,22,10), ElementBackgroundHover=Color3.fromRGB(38,28,12),
    SecondaryElementBackground=Color3.fromRGB(22,16,7),
    ElementStroke=Color3.fromRGB(60,44,14), SecondaryElementStroke=Color3.fromRGB(48,34,10),
    SliderProgress=Color3.fromRGB(220,150,0), SliderStroke=Color3.fromRGB(255,190,40),
    ToggleEnabled=Color3.fromRGB(160,110,0), ToggleDisabled=Color3.fromRGB(70,50,15),
    ToggleEnabledStroke=Color3.fromRGB(200,140,20), ToggleDisabledStroke=Color3.fromRGB(90,65,20),
    DropdownSelected=Color3.fromRGB(38,28,12), DropdownUnselected=Color3.fromRGB(28,20,8),
    InputBackground=Color3.fromRGB(28,20,8), InputStroke=Color3.fromRGB(70,52,16),
    PlaceholderColor=Color3.fromRGB(140,100,50), NotificationBackground=Color3.fromRGB(25,18,8),
    TopAccent=Color3.fromRGB(255,190,40), SectionText=Color3.fromRGB(140,100,40),
    TabPill=Color3.fromRGB(38,28,12), TabPillSelected=Color3.fromRGB(52,38,16),
    BtnHover=Color3.fromRGB(38,28,12), BtnActive=Color3.fromRGB(50,36,15),
    ValueText=Color3.fromRGB(160,120,50),
}
Themes.Amethyst = {
    Background=Color3.fromRGB(18,12,28), Topbar=Color3.fromRGB(24,16,38),
    TextColor=Color3.fromRGB(235,220,255), TextMid=Color3.fromRGB(170,130,220),
    TextDim=Color3.fromRGB(90,60,130), Accent=Color3.fromRGB(190,120,255),
    AccentDark=Color3.fromRGB(120,60,200), Border=Color3.fromRGB(58,36,90),
    ElementBackground=Color3.fromRGB(28,18,44), ElementBackgroundHover=Color3.fromRGB(34,22,54),
    SecondaryElementBackground=Color3.fromRGB(20,13,32),
    ElementStroke=Color3.fromRGB(58,36,90), SecondaryElementStroke=Color3.fromRGB(44,28,70),
    SliderProgress=Color3.fromRGB(150,80,230), SliderStroke=Color3.fromRGB(190,120,255),
    ToggleEnabled=Color3.fromRGB(110,60,180), ToggleDisabled=Color3.fromRGB(55,34,88),
    ToggleEnabledStroke=Color3.fromRGB(150,90,220), ToggleDisabledStroke=Color3.fromRGB(75,46,115),
    DropdownSelected=Color3.fromRGB(34,22,54), DropdownUnselected=Color3.fromRGB(24,16,38),
    InputBackground=Color3.fromRGB(24,16,38), InputStroke=Color3.fromRGB(70,44,108),
    PlaceholderColor=Color3.fromRGB(120,85,170), NotificationBackground=Color3.fromRGB(22,14,35),
    TopAccent=Color3.fromRGB(190,120,255), SectionText=Color3.fromRGB(110,75,160),
    TabPill=Color3.fromRGB(34,22,54), TabPillSelected=Color3.fromRGB(46,30,72),
    BtnHover=Color3.fromRGB(34,22,54), BtnActive=Color3.fromRGB(44,28,68),
    ValueText=Color3.fromRGB(140,100,190),
}
Themes.Bloom = {
    Background=Color3.fromRGB(22,10,18), Topbar=Color3.fromRGB(30,12,24),
    TextColor=Color3.fromRGB(255,230,240), TextMid=Color3.fromRGB(220,150,185),
    TextDim=Color3.fromRGB(110,55,82), Accent=Color3.fromRGB(255,120,180),
    AccentDark=Color3.fromRGB(180,60,110), Border=Color3.fromRGB(72,28,52),
    ElementBackground=Color3.fromRGB(32,14,26), ElementBackgroundHover=Color3.fromRGB(40,18,32),
    SecondaryElementBackground=Color3.fromRGB(24,10,18),
    ElementStroke=Color3.fromRGB(72,28,52), SecondaryElementStroke=Color3.fromRGB(55,20,40),
    SliderProgress=Color3.fromRGB(220,80,140), SliderStroke=Color3.fromRGB(255,120,180),
    ToggleEnabled=Color3.fromRGB(170,55,105), ToggleDisabled=Color3.fromRGB(80,30,55),
    ToggleEnabledStroke=Color3.fromRGB(210,80,135), ToggleDisabledStroke=Color3.fromRGB(105,40,72),
    DropdownSelected=Color3.fromRGB(40,18,32), DropdownUnselected=Color3.fromRGB(28,12,22),
    InputBackground=Color3.fromRGB(28,12,22), InputStroke=Color3.fromRGB(80,30,56),
    PlaceholderColor=Color3.fromRGB(160,90,125), NotificationBackground=Color3.fromRGB(26,12,20),
    TopAccent=Color3.fromRGB(255,120,180), SectionText=Color3.fromRGB(140,70,105),
    TabPill=Color3.fromRGB(40,18,32), TabPillSelected=Color3.fromRGB(54,24,42),
    BtnHover=Color3.fromRGB(40,18,32), BtnActive=Color3.fromRGB(52,22,40),
    ValueText=Color3.fromRGB(180,100,140),
}
Themes.DarkBlue = {
    Background=Color3.fromRGB(8,12,28), Topbar=Color3.fromRGB(12,16,38),
    TextColor=Color3.fromRGB(210,225,255), TextMid=Color3.fromRGB(140,170,240),
    TextDim=Color3.fromRGB(55,80,150), Accent=Color3.fromRGB(80,140,255),
    AccentDark=Color3.fromRGB(40,80,200), Border=Color3.fromRGB(26,42,100),
    ElementBackground=Color3.fromRGB(14,20,48), ElementBackgroundHover=Color3.fromRGB(18,26,60),
    SecondaryElementBackground=Color3.fromRGB(10,14,34),
    ElementStroke=Color3.fromRGB(26,42,100), SecondaryElementStroke=Color3.fromRGB(18,30,75),
    SliderProgress=Color3.fromRGB(50,100,230), SliderStroke=Color3.fromRGB(80,140,255),
    ToggleEnabled=Color3.fromRGB(35,75,180), ToggleDisabled=Color3.fromRGB(22,38,95),
    ToggleEnabledStroke=Color3.fromRGB(55,105,220), ToggleDisabledStroke=Color3.fromRGB(32,55,130),
    DropdownSelected=Color3.fromRGB(18,26,60), DropdownUnselected=Color3.fromRGB(12,18,44),
    InputBackground=Color3.fromRGB(12,18,44), InputStroke=Color3.fromRGB(32,52,120),
    PlaceholderColor=Color3.fromRGB(90,120,200), NotificationBackground=Color3.fromRGB(10,15,32),
    TopAccent=Color3.fromRGB(80,140,255), SectionText=Color3.fromRGB(60,90,170),
    TabPill=Color3.fromRGB(18,26,60), TabPillSelected=Color3.fromRGB(24,36,80),
    BtnHover=Color3.fromRGB(18,26,60), BtnActive=Color3.fromRGB(24,34,75),
    ValueText=Color3.fromRGB(110,145,215),
}
Themes.Green = {
    Background=Color3.fromRGB(8,18,10), Topbar=Color3.fromRGB(11,24,13),
    TextColor=Color3.fromRGB(210,255,220), TextMid=Color3.fromRGB(130,220,155),
    TextDim=Color3.fromRGB(45,110,62), Accent=Color3.fromRGB(65,230,105),
    AccentDark=Color3.fromRGB(30,155,65), Border=Color3.fromRGB(20,65,30),
    ElementBackground=Color3.fromRGB(12,28,15), ElementBackgroundHover=Color3.fromRGB(16,36,20),
    SecondaryElementBackground=Color3.fromRGB(9,20,11),
    ElementStroke=Color3.fromRGB(20,65,30), SecondaryElementStroke=Color3.fromRGB(15,48,22),
    SliderProgress=Color3.fromRGB(35,180,75), SliderStroke=Color3.fromRGB(65,230,105),
    ToggleEnabled=Color3.fromRGB(28,145,60), ToggleDisabled=Color3.fromRGB(16,60,28),
    ToggleEnabledStroke=Color3.fromRGB(45,185,80), ToggleDisabledStroke=Color3.fromRGB(22,82,38),
    DropdownSelected=Color3.fromRGB(16,36,20), DropdownUnselected=Color3.fromRGB(10,24,13),
    InputBackground=Color3.fromRGB(10,24,13), InputStroke=Color3.fromRGB(22,72,33),
    PlaceholderColor=Color3.fromRGB(80,160,105), NotificationBackground=Color3.fromRGB(10,22,12),
    TopAccent=Color3.fromRGB(65,230,105), SectionText=Color3.fromRGB(45,130,65),
    TabPill=Color3.fromRGB(16,36,20), TabPillSelected=Color3.fromRGB(22,48,27),
    BtnHover=Color3.fromRGB(16,36,20), BtnActive=Color3.fromRGB(22,46,26),
    ValueText=Color3.fromRGB(100,185,125),
}
Themes.Light = {
    Background=Color3.fromRGB(238,238,242), Topbar=Color3.fromRGB(228,228,234),
    TextColor=Color3.fromRGB(25,25,30), TextMid=Color3.fromRGB(90,90,110),
    TextDim=Color3.fromRGB(160,160,180), Accent=Color3.fromRGB(60,120,255),
    AccentDark=Color3.fromRGB(35,85,200), Border=Color3.fromRGB(205,205,215),
    ElementBackground=Color3.fromRGB(250,250,254), ElementBackgroundHover=Color3.fromRGB(240,240,248),
    SecondaryElementBackground=Color3.fromRGB(232,232,240),
    ElementStroke=Color3.fromRGB(208,208,220), SecondaryElementStroke=Color3.fromRGB(215,215,226),
    SliderProgress=Color3.fromRGB(60,120,240), SliderStroke=Color3.fromRGB(80,145,255),
    ToggleEnabled=Color3.fromRGB(155,155,175), ToggleDisabled=Color3.fromRGB(185,185,200),
    ToggleEnabledStroke=Color3.fromRGB(130,130,155), ToggleDisabledStroke=Color3.fromRGB(195,195,210),
    DropdownSelected=Color3.fromRGB(240,240,248), DropdownUnselected=Color3.fromRGB(250,250,254),
    InputBackground=Color3.fromRGB(250,250,254), InputStroke=Color3.fromRGB(200,200,215),
    PlaceholderColor=Color3.fromRGB(165,165,185), NotificationBackground=Color3.fromRGB(248,248,254),
    TopAccent=Color3.fromRGB(60,120,255), SectionText=Color3.fromRGB(130,130,155),
    TabPill=Color3.fromRGB(238,238,244), TabPillSelected=Color3.fromRGB(225,225,236),
    BtnHover=Color3.fromRGB(240,240,248), BtnActive=Color3.fromRGB(228,228,240),
    ValueText=Color3.fromRGB(140,140,165),
}
Themes.Ocean = {
    Background=Color3.fromRGB(6,15,25), Topbar=Color3.fromRGB(8,20,33),
    TextColor=Color3.fromRGB(190,230,255), TextMid=Color3.fromRGB(85,145,185),
    TextDim=Color3.fromRGB(35,80,110), Accent=Color3.fromRGB(80,200,255),
    AccentDark=Color3.fromRGB(40,130,190), Border=Color3.fromRGB(18,50,78),
    ElementBackground=Color3.fromRGB(10,25,40), ElementBackgroundHover=Color3.fromRGB(13,32,50),
    SecondaryElementBackground=Color3.fromRGB(7,18,30),
    ElementStroke=Color3.fromRGB(18,50,78), SecondaryElementStroke=Color3.fromRGB(12,36,58),
    SliderProgress=Color3.fromRGB(55,160,215), SliderStroke=Color3.fromRGB(80,200,255),
    ToggleEnabled=Color3.fromRGB(35,105,155), ToggleDisabled=Color3.fromRGB(15,45,72),
    ToggleEnabledStroke=Color3.fromRGB(55,145,200), ToggleDisabledStroke=Color3.fromRGB(22,65,100),
    DropdownSelected=Color3.fromRGB(13,32,50), DropdownUnselected=Color3.fromRGB(8,20,33),
    InputBackground=Color3.fromRGB(10,25,40), InputStroke=Color3.fromRGB(28,75,115),
    PlaceholderColor=Color3.fromRGB(65,120,160), NotificationBackground=Color3.fromRGB(10,25,40),
    TopAccent=Color3.fromRGB(80,200,255), SectionText=Color3.fromRGB(38,95,140),
    TabPill=Color3.fromRGB(13,32,50), TabPillSelected=Color3.fromRGB(18,44,68),
    BtnHover=Color3.fromRGB(13,32,50), BtnActive=Color3.fromRGB(18,44,68),
    ValueText=Color3.fromRGB(65,130,170),
}
Themes.Serenity = {
    Background=Color3.fromRGB(15,18,26), Topbar=Color3.fromRGB(19,23,34),
    TextColor=Color3.fromRGB(220,225,245), TextMid=Color3.fromRGB(140,148,185),
    TextDim=Color3.fromRGB(65,72,105), Accent=Color3.fromRGB(130,160,255),
    AccentDark=Color3.fromRGB(80,110,220), Border=Color3.fromRGB(34,40,65),
    ElementBackground=Color3.fromRGB(22,27,42), ElementBackgroundHover=Color3.fromRGB(27,33,52),
    SecondaryElementBackground=Color3.fromRGB(17,21,33),
    ElementStroke=Color3.fromRGB(34,40,65), SecondaryElementStroke=Color3.fromRGB(26,32,52),
    SliderProgress=Color3.fromRGB(100,130,235), SliderStroke=Color3.fromRGB(130,160,255),
    ToggleEnabled=Color3.fromRGB(70,90,185), ToggleDisabled=Color3.fromRGB(36,44,80),
    ToggleEnabledStroke=Color3.fromRGB(95,120,220), ToggleDisabledStroke=Color3.fromRGB(50,60,105),
    DropdownSelected=Color3.fromRGB(27,33,52), DropdownUnselected=Color3.fromRGB(19,23,36),
    InputBackground=Color3.fromRGB(19,23,36), InputStroke=Color3.fromRGB(40,48,78),
    PlaceholderColor=Color3.fromRGB(95,105,155), NotificationBackground=Color3.fromRGB(19,23,36),
    TopAccent=Color3.fromRGB(130,160,255), SectionText=Color3.fromRGB(72,84,138),
    TabPill=Color3.fromRGB(27,33,52), TabPillSelected=Color3.fromRGB(36,44,68),
    BtnHover=Color3.fromRGB(27,33,52), BtnActive=Color3.fromRGB(36,44,68),
    ValueText=Color3.fromRGB(105,118,170),
}

local C = {}
local function applyTheme(t)
    local src = (type(t)=="string" and Themes[t]) or (type(t)=="table" and t) or Themes.Default
    for k,v in pairs(src) do C[k]=v end
end
applyTheme("Default")

-- ============================================================
-- HELPERS
-- ============================================================
local FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.18, Enum.EasingStyle.Quint)
local function tw(o,i,p) TweenService:Create(o,i,p):Play() end
local function mkCorner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8); return c end
local function mkStroke(p,col,th,tr)
    local s=Instance.new("UIStroke",p); s.Color=col or C.Border; s.Thickness=th or 1; s.Transparency=tr or 0; return s
end
local function mkPadding(p,t,b,l,r)
    local pad=Instance.new("UIPadding",p)
    pad.PaddingTop=UDim.new(0,t or 0); pad.PaddingBottom=UDim.new(0,b or 0)
    pad.PaddingLeft=UDim.new(0,l or 0); pad.PaddingRight=UDim.new(0,r or 0)
    return pad
end

local mainFrame=nil; local guiVisible=true
local DevNgg={}; DevNgg.Flags=flags; DevNgg.Themes=Themes

function DevNgg:SetVisibility(v) guiVisible=v; if mainFrame then mainFrame.Visible=v end end
function DevNgg:IsVisible() return guiVisible end
function DevNgg:Destroy() if mainFrame then mainFrame.Parent:Destroy() end end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local notifGui=Instance.new("ScreenGui")
notifGui.Name="DevNggNotif"; notifGui.ResetOnSpawn=false
notifGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() notifGui.DisplayOrder=998 end)
pcall(function() notifGui.IgnoreGuiInset=true end)
safeParent(notifGui)

local notifHolder=Instance.new("Frame",notifGui)
notifHolder.Size=UDim2.new(0,295,1,0); notifHolder.Position=UDim2.new(1,-310,0,0)
notifHolder.BackgroundTransparency=1
local nl=Instance.new("UIListLayout",notifHolder)
nl.VerticalAlignment=Enum.VerticalAlignment.Bottom
nl.HorizontalAlignment=Enum.HorizontalAlignment.Right
nl.SortOrder=Enum.SortOrder.LayoutOrder; nl.Padding=UDim.new(0,8)
local np=Instance.new("UIPadding",notifHolder); np.PaddingBottom=UDim.new(0,20)

function DevNgg:Notify(cfg)
    local title=cfg.Title or "DevN.gg"; local content=cfg.Content or ""; local dur=cfg.Duration or 3
    local card=Instance.new("Frame",notifHolder)
    card.Size=UDim2.new(1,0,0,66); card.BackgroundColor3=C.NotificationBackground
    card.BackgroundTransparency=1; card.BorderSizePixel=0; card.ClipsDescendants=true
    mkCorner(card,10); local cs=mkStroke(card,C.Border,1,1)
    -- left accent bar
    local bar=Instance.new("Frame",card)
    bar.Size=UDim2.new(0,3,1,-14); bar.Position=UDim2.new(0,0,0,7)
    bar.BackgroundColor3=C.Accent; bar.BackgroundTransparency=1; bar.BorderSizePixel=0; mkCorner(bar,2)
    local t=Instance.new("TextLabel",card)
    t.Size=UDim2.new(1,-22,0,20); t.Position=UDim2.new(0,16,0,12)
    t.BackgroundTransparency=1; t.Text=title; t.TextColor3=C.TextColor
    t.TextTransparency=1; t.TextSize=13; t.Font=Enum.Font.GothamBold
    t.TextXAlignment=Enum.TextXAlignment.Left
    local sub=Instance.new("TextLabel",card)
    sub.Size=UDim2.new(1,-22,0,18); sub.Position=UDim2.new(0,16,0,34)
    sub.BackgroundTransparency=1; sub.Text=content; sub.TextColor3=C.TextMid
    sub.TextTransparency=1; sub.TextSize=11; sub.Font=Enum.Font.Gotham
    sub.TextXAlignment=Enum.TextXAlignment.Left; sub.TextWrapped=true
    local progBg=Instance.new("Frame",card)
    progBg.Size=UDim2.new(1,0,0,2); progBg.Position=UDim2.new(0,0,1,-2)
    progBg.BackgroundColor3=C.Border; progBg.BorderSizePixel=0
    local prog=Instance.new("Frame",progBg)
    prog.Size=UDim2.new(1,0,1,0); prog.BackgroundColor3=C.Accent; prog.BorderSizePixel=0
    tw(card,MED,{BackgroundTransparency=0}); tw(cs,MED,{Transparency=0})
    tw(bar,MED,{BackgroundTransparency=0}); tw(t,MED,{TextTransparency=0}); tw(sub,MED,{TextTransparency=0})
    tw(prog,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)})
    task.delay(dur,function()
        tw(card,MED,{BackgroundTransparency=1}); tw(cs,MED,{Transparency=1})
        tw(bar,MED,{BackgroundTransparency=1}); tw(t,MED,{TextTransparency=1}); tw(sub,MED,{TextTransparency=1})
        task.wait(0.22); card:Destroy()
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function DevNgg:CreateWindow(config)
    local wTitle  = config.Name or "DevN.gg"
    local wSub    = config.LoadingSubtitle or "Interface"
    local wVer    = config.Version or "v1.0"
    local togKey  = config.ToggleUIKeybind or "K"
    local theme   = config.Theme or "Default"
    applyTheme(theme)
    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder = config.ConfigurationSaving.FolderName or saveFolder
        saveFile   = config.ConfigurationSaving.FileName   or saveFile
    end

    local screenGui=Instance.new("ScreenGui")
    screenGui.Name="DevNggGUI"; screenGui.ResetOnSpawn=false
    screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.DisplayOrder=999 end)
    pcall(function() screenGui.IgnoreGuiInset=true end)
    safeParent(screenGui)
    if not screenGui.Parent then
        task.spawn(function()
            for _=1,10 do task.wait(0.5); safeParent(screenGui); if screenGui.Parent then break end end
        end)
    end

    -- MAIN WINDOW
    local main=Instance.new("Frame",screenGui)
    main.Name="Main"; main.Size=UDim2.new(0,500,0,440)
    main.Position=UDim2.new(0.5,-250,0.5,-220)
    main.BackgroundColor3=C.Background; main.BorderSizePixel=0; main.ClipsDescendants=false
    mkCorner(main,12); local mainStroke=mkStroke(main,C.Border,1)
    mainFrame=main

    -- Top accent line
    local topLine=Instance.new("Frame",main)
    topLine.Size=UDim2.new(1,-2,0,2); topLine.Position=UDim2.new(0,1,0,0)
    topLine.BackgroundColor3=C.TopAccent; topLine.BorderSizePixel=0; topLine.ZIndex=6
    mkCorner(topLine,12)

    -- TOPBAR
    local topbar=Instance.new("Frame",main)
    topbar.Size=UDim2.new(1,0,0,50); topbar.Position=UDim2.new(0,0,0,0)
    topbar.BackgroundColor3=C.Topbar; topbar.BorderSizePixel=0; topbar.ZIndex=2
    mkCorner(topbar,12)
    -- cover bottom corners of topbar
    local topbarCover=Instance.new("Frame",main)
    topbarCover.Size=UDim2.new(1,0,0,12); topbarCover.Position=UDim2.new(0,0,0,38)
    topbarCover.BackgroundColor3=C.Topbar; topbarCover.BorderSizePixel=0; topbarCover.ZIndex=2

    local titleLbl=Instance.new("TextLabel",topbar)
    titleLbl.Size=UDim2.new(1,-120,1,0); titleLbl.Position=UDim2.new(0,16,0,0)
    titleLbl.BackgroundTransparency=1; titleLbl.Text=wTitle
    titleLbl.TextColor3=C.TextColor; titleLbl.TextSize=14
    titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    titleLbl.ZIndex=3

    -- top-right buttons (search icon placeholder, settings, close)
    local function mkTopBtn(offsetX, sym, sz)
        local b=Instance.new("TextButton",topbar)
        b.Size=UDim2.new(0,sz or 28,0,sz or 28)
        b.Position=UDim2.new(1,offsetX,0.5,-(sz or 28)/2)
        b.BackgroundTransparency=1; b.Text=sym
        b.TextColor3=C.TextMid; b.TextSize=14
        b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0
        b.AutoButtonColor=false; b.ZIndex=10
        b.MouseEnter:Connect(function() tw(b,FAST,{TextColor3=C.TextColor}) end)
        b.MouseLeave:Connect(function() tw(b,FAST,{TextColor3=C.TextMid}) end)
        return b
    end
    local closeBtn=mkTopBtn(-12,"✕")
    local minBtn=mkTopBtn(-44,"─")
    closeBtn.MouseButton1Click:Connect(function() DevNgg:SetVisibility(false) end)

    -- Separator below topbar
    local sep1=Instance.new("Frame",main)
    sep1.Size=UDim2.new(1,0,0,1); sep1.Position=UDim2.new(0,0,0,50)
    sep1.BackgroundColor3=C.Border; sep1.BorderSizePixel=0; sep1.ZIndex=2

    -- TAB BAR — pill style like Rayfield
    local tabBar=Instance.new("Frame",main)
    tabBar.Name="TabBar"; tabBar.Size=UDim2.new(1,-24,0,34)
    tabBar.Position=UDim2.new(0,12,0,60); tabBar.BackgroundTransparency=1
    tabBar.BorderSizePixel=0; tabBar.ZIndex=3

    local tabList=Instance.new("UIListLayout",tabBar)
    tabList.FillDirection=Enum.FillDirection.Horizontal
    tabList.HorizontalAlignment=Enum.HorizontalAlignment.Left
    tabList.VerticalAlignment=Enum.VerticalAlignment.Center
    tabList.SortOrder=Enum.SortOrder.LayoutOrder; tabList.Padding=UDim.new(0,6)

    -- Separator below tab bar
    local sep2=Instance.new("Frame",main)
    sep2.Size=UDim2.new(1,0,0,1); sep2.Position=UDim2.new(0,0,0,102)
    sep2.BackgroundColor3=C.Border; sep2.BorderSizePixel=0; sep2.ZIndex=2

    -- CONTENT AREA
    local contentArea=Instance.new("Frame",main)
    contentArea.Name="ContentArea"; contentArea.Size=UDim2.new(1,0,1,-103)
    contentArea.Position=UDim2.new(0,0,0,103)
    contentArea.BackgroundTransparency=1; contentArea.ClipsDescendants=true; contentArea.ZIndex=2

    local minimized=false; local tabFrames={}; local tabButtons={}; local activeTab=nil

    local function switchTab(name)
        for n,f in pairs(tabFrames) do f.Visible=(n==name) end
        for n,b in pairs(tabButtons) do
            if n==name then
                tw(b,FAST,{BackgroundColor3=C.TabPillSelected})
                local l=b:FindFirstChildOfClass("TextLabel")
                if l then tw(l,FAST,{TextColor3=C.TextColor}) end
            else
                tw(b,FAST,{BackgroundColor3=C.TabPill})
                local l=b:FindFirstChildOfClass("TextLabel")
                if l then tw(l,FAST,{TextColor3=C.TextMid}) end
            end
        end
        activeTab=name
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        tabBar.Visible=not minimized; sep1.Visible=not minimized
        sep2.Visible=not minimized; contentArea.Visible=not minimized
        topbarCover.Visible=not minimized
        tw(main,MED,{Size=UDim2.new(0,500,0,minimized and 50 or 440)})
        minBtn.Text=minimized and "+" or "─"
    end)

    UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        pcall(function()
            local key=typeof(togKey)=="string" and Enum.KeyCode[togKey] or togKey
            if input.KeyCode==key then DevNgg:SetVisibility(not guiVisible) end
        end)
    end)

    -- Drag
    local dragging,dragStart,startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d=input.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    -- ============================================================
    -- WINDOW OBJECT
    -- ============================================================
    local Window={}

    function Window:ModifyTheme(t)
        applyTheme(t)
        main.BackgroundColor3=C.Background; mainStroke.Color=C.Border
        topbar.BackgroundColor3=C.Topbar; topbarCover.BackgroundColor3=C.Topbar
        sep1.BackgroundColor3=C.Border; sep2.BackgroundColor3=C.Border
        topLine.BackgroundColor3=C.TopAccent; titleLbl.TextColor3=C.TextColor
    end

    -- ============================================================
    -- CREATE TAB
    -- ============================================================
    function Window:CreateTab(name, _icon)
        -- Pill tab button
        local tabBtn=Instance.new("TextButton",tabBar)
        tabBtn.Name=name; tabBtn.Size=UDim2.new(0,0,1,0)
        tabBtn.AutomaticSize=Enum.AutomaticSize.X
        tabBtn.BackgroundColor3=C.TabPill; tabBtn.BorderSizePixel=0
        tabBtn.Text=""; tabBtn.AutoButtonColor=false; tabBtn.ZIndex=4
        mkCorner(tabBtn,20) -- full pill
        mkPadding(tabBtn,0,0,14,14)

        local tabLbl=Instance.new("TextLabel",tabBtn)
        tabLbl.Size=UDim2.new(1,0,1,0); tabLbl.BackgroundTransparency=1
        tabLbl.Text=name; tabLbl.TextColor3=C.TextMid
        tabLbl.TextSize=12; tabLbl.Font=Enum.Font.GothamSemibold
        tabLbl.TextXAlignment=Enum.TextXAlignment.Center; tabLbl.ZIndex=5

        tabBtn.MouseEnter:Connect(function()
            if activeTab~=name then tw(tabLbl,FAST,{TextColor3=C.TextColor}) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab~=name then tw(tabLbl,FAST,{TextColor3=C.TextMid}) end
        end)
        tabBtn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabButtons[name]=tabBtn

        -- Scroll frame for content
        local sf=Instance.new("ScrollingFrame",contentArea)
        sf.Name=name; sf.Size=UDim2.new(1,0,1,0)
        sf.BackgroundTransparency=1; sf.BorderSizePixel=0
        sf.ScrollBarThickness=3; sf.ScrollBarImageColor3=C.Border
        sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
        sf.Visible=false; sf.ZIndex=3

        local ll=Instance.new("UIListLayout",sf)
        ll.Padding=UDim.new(0,4); ll.HorizontalAlignment=Enum.HorizontalAlignment.Center
        ll.SortOrder=Enum.SortOrder.LayoutOrder

        mkPadding(sf,10,10,12,12)
        tabFrames[name]=sf
        if not activeTab then switchTab(name) end

        -- ============================================================
        -- TAB OBJECT
        -- ============================================================
        local Tab={}

        -- ELEMENT helper: creates the standard row container
        local function mkRow(height)
            local row=Instance.new("Frame",sf)
            row.Size=UDim2.new(1,0,0,height or 44)
            row.BackgroundColor3=C.ElementBackground
            row.BorderSizePixel=0; mkCorner(row,8)
            mkStroke(row,C.ElementStroke,1)
            return row
        end

        -- SECTION HEADER
        function Tab:CreateSection(sectionName)
            local row=Instance.new("Frame",sf)
            row.Size=UDim2.new(1,0,0,28); row.BackgroundTransparency=1
            local line=Instance.new("Frame",row)
            line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,0.5,0)
            line.BackgroundColor3=C.ElementStroke; line.BorderSizePixel=0
            local lbl=Instance.new("TextLabel",row)
            lbl.Size=UDim2.new(0,0,1,0); lbl.AutomaticSize=Enum.AutomaticSize.X
            lbl.BackgroundColor3=C.Background; lbl.BorderSizePixel=0
            lbl.Text="  "..sectionName:upper().."  "
            lbl.TextColor3=C.SectionText; lbl.TextSize=9
            lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left
            local Section={}
            function Section:Set(n) lbl.Text="  "..n:upper().."  " end
            return Section
        end

        -- DIVIDER
        function Tab:CreateDivider()
            local div=Instance.new("Frame",sf)
            div.Size=UDim2.new(1,0,0,1); div.BackgroundColor3=C.ElementStroke; div.BorderSizePixel=0
            local D={}; function D:Set(v) div.Visible=v end; return D
        end

        -- LABEL
        function Tab:CreateLabel(text,_icon,color,_ign)
            local row=mkRow(38)
            local lbl=Instance.new("TextLabel",row)
            lbl.Size=UDim2.new(1,-24,1,0); lbl.Position=UDim2.new(0,12,0,0)
            lbl.BackgroundTransparency=1; lbl.Text=text or "Label"
            lbl.TextColor3=color or C.TextMid; lbl.TextSize=13
            lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.TextWrapped=true
            local L={}
            function L:Set(t2,_,c2) if t2 then lbl.Text=t2 end; if c2 then lbl.TextColor3=c2 end end
            return L
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(cfg)
            local row=Instance.new("Frame",sf)
            row.Size=UDim2.new(1,0,0,0); row.AutomaticSize=Enum.AutomaticSize.Y
            row.BackgroundColor3=C.ElementBackground; row.BorderSizePixel=0
            mkCorner(row,8); mkStroke(row,C.ElementStroke,1)
            mkPadding(row,10,10,12,12)
            local wl=Instance.new("UIListLayout",row); wl.Padding=UDim.new(0,4)
            wl.SortOrder=Enum.SortOrder.LayoutOrder; wl.HorizontalAlignment=Enum.HorizontalAlignment.Left
            local tl=Instance.new("TextLabel",row)
            tl.Size=UDim2.new(1,0,0,0); tl.AutomaticSize=Enum.AutomaticSize.Y
            tl.BackgroundTransparency=1; tl.Text=cfg.Title or "Paragraph"
            tl.TextColor3=C.TextColor; tl.TextSize=13; tl.Font=Enum.Font.GothamBold
            tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextWrapped=true; tl.LayoutOrder=1
            local bl=Instance.new("TextLabel",row)
            bl.Size=UDim2.new(1,0,0,0); bl.AutomaticSize=Enum.AutomaticSize.Y
            bl.BackgroundTransparency=1; bl.Text=cfg.Content or ""
            bl.TextColor3=C.TextMid; bl.TextSize=12; bl.Font=Enum.Font.Gotham
            bl.TextXAlignment=Enum.TextXAlignment.Left; bl.TextWrapped=true; bl.LayoutOrder=2
            local P={}
            function P:Set(c2)
                if c2.Title then tl.Text=c2.Title end
                if c2.Content then bl.Text=c2.Content end
            end
            return P
        end

        -- BUTTON — name on left, "button" text on right like Rayfield
        function Tab:CreateButton(cfg)
            local row=mkRow(44)
            row.BackgroundColor3=C.ElementBackground

            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(1,-80,1,0); nameLbl.Position=UDim2.new(0,12,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Button"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            local rightLbl=Instance.new("TextLabel",row)
            rightLbl.Size=UDim2.new(0,70,1,0); rightLbl.Position=UDim2.new(1,-78,0,0)
            rightLbl.BackgroundTransparency=1; rightLbl.Text="button"
            rightLbl.TextColor3=C.ValueText; rightLbl.TextSize=12
            rightLbl.Font=Enum.Font.Gotham; rightLbl.TextXAlignment=Enum.TextXAlignment.Right

            -- make the whole row clickable
            local click=Instance.new("TextButton",row)
            click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1
            click.Text=""; click.AutoButtonColor=false; click.ZIndex=5

            click.MouseButton1Click:Connect(function()
                tw(row,FAST,{BackgroundColor3=C.BtnActive})
                task.delay(0.12,function() tw(row,MED,{BackgroundColor3=C.ElementBackground}) end)
                if cfg.Callback then cfg.Callback() end
            end)
            click.MouseEnter:Connect(function() tw(row,FAST,{BackgroundColor3=C.BtnHover}) end)
            click.MouseLeave:Connect(function() tw(row,FAST,{BackgroundColor3=C.ElementBackground}) end)

            local B={}; function B:Set(n) nameLbl.Text=n end; return B
        end

        -- TOGGLE — name left, pill toggle right like Rayfield screenshot
        function Tab:CreateToggle(cfg)
            local flag=cfg.Flag; local enabled=cfg.CurrentValue or false
            local row=mkRow(44)

            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(1,-62,1,0); nameLbl.Position=UDim2.new(0,12,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Toggle"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            -- Pill container
            local pill=Instance.new("Frame",row)
            pill.Size=UDim2.new(0,44,0,24); pill.Position=UDim2.new(1,-54,0.5,-12)
            pill.BackgroundColor3=C.ToggleDisabled; pill.BorderSizePixel=0; mkCorner(pill,12)
            local pStroke=mkStroke(pill,C.ToggleDisabledStroke,1)

            local knob=Instance.new("Frame",pill)
            knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,3,0.5,-9)
            knob.BackgroundColor3=C.TextMid; knob.BorderSizePixel=0; mkCorner(knob,9)

            local function setState(val,silent)
                enabled=val
                if flag then flags[flag]=val; if not silent then saveConfig() end end
                if val then
                    tw(pill,FAST,{BackgroundColor3=C.Accent})
                    tw(pStroke,FAST,{Color=C.Accent})
                    tw(knob,FAST,{Position=UDim2.new(0,23,0.5,-9),BackgroundColor3=Color3.fromRGB(255,255,255)})
                else
                    tw(pill,FAST,{BackgroundColor3=C.ToggleDisabled})
                    tw(pStroke,FAST,{Color=C.ToggleDisabledStroke})
                    tw(knob,FAST,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=C.TextMid})
                end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            if enabled then setState(true,true) end
            if flag then toggleSetters[flag]=setState end

            local click=Instance.new("TextButton",row)
            click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1
            click.Text=""; click.AutoButtonColor=false; click.ZIndex=5
            click.MouseButton1Click:Connect(function() setState(not enabled) end)
            click.MouseEnter:Connect(function() tw(row,FAST,{BackgroundColor3=C.BtnHover}) end)
            click.MouseLeave:Connect(function() tw(row,FAST,{BackgroundColor3=C.ElementBackground}) end)

            local T={}; T.CurrentValue=enabled
            function T:Set(v) setState(v,false) end
            return T
        end

        -- SLIDER — value shown inside filled bubble on track like Rayfield
        function Tab:CreateSlider(cfg)
            local flag=cfg.Flag
            local min=(cfg.Range and cfg.Range[1]) or 0
            local max=(cfg.Range and cfg.Range[2]) or 100
            local inc=cfg.Increment or 1
            local suffix=cfg.Suffix or ""
            local current=math.clamp(cfg.CurrentValue or min,min,max)

            local row=mkRow(54)

            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(1,-24,0,20); nameLbl.Position=UDim2.new(0,12,0,6)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Slider"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            -- Track background
            local trackBg=Instance.new("Frame",row)
            trackBg.Size=UDim2.new(1,-24,0,8); trackBg.Position=UDim2.new(0,12,0,34)
            trackBg.BackgroundColor3=C.SecondaryElementBackground; trackBg.BorderSizePixel=0
            mkCorner(trackBg,4); mkStroke(trackBg,C.ElementStroke,1)

            -- Filled portion
            local fill=Instance.new("Frame",trackBg)
            fill.BackgroundColor3=C.Accent; fill.BorderSizePixel=0
            local t0=(current-min)/math.max(max-min,0.001)
            fill.Size=UDim2.new(t0,0,1,0); mkCorner(fill,4)

            -- Value bubble on the fill
            local valBubble=Instance.new("Frame",trackBg)
            valBubble.Size=UDim2.new(0,38,0,20); valBubble.AnchorPoint=Vector2.new(0.5,0.5)
            valBubble.Position=UDim2.new(t0,0,0.5,0)
            valBubble.BackgroundColor3=C.Accent; valBubble.BorderSizePixel=0; mkCorner(valBubble,10)

            local valLbl=Instance.new("TextLabel",valBubble)
            valLbl.Size=UDim2.new(1,0,1,0); valLbl.BackgroundTransparency=1
            valLbl.Text=tostring(current); valLbl.TextColor3=Color3.fromRGB(255,255,255)
            valLbl.TextSize=11; valLbl.Font=Enum.Font.GothamBold
            valLbl.TextXAlignment=Enum.TextXAlignment.Center

            if suffix~="" then valLbl.Text=tostring(current).." "..suffix end
            if flag then flags[flag]=current end

            local function setSlider(val,silent)
                local snapped=math.floor((val-min)/inc+0.5)*inc+min
                snapped=math.clamp(snapped,min,max)
                current=snapped
                local t=(snapped-min)/math.max(max-min,0.001)
                tw(fill,FAST,{Size=UDim2.new(t,0,1,0)})
                tw(valBubble,FAST,{Position=UDim2.new(t,0,0.5,0)})
                valLbl.Text=suffix~="" and (tostring(snapped).." "..suffix) or tostring(snapped)
                if flag then flags[flag]=snapped end
                if not silent then saveConfig(); if cfg.Callback then cfg.Callback(snapped) end end
            end

            local sliding=false
            trackBg.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    sliding=true
                    setSlider(min+(i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X*(max-min))
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                    setSlider(min+(i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X*(max-min))
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
            end)

            local S={}; S.CurrentValue=current
            function S:Set(v) setSlider(v,false) end
            return S
        end

        -- DROPDOWN — value shown on right like "V1 ^"
        function Tab:CreateDropdown(cfg)
            local flag=cfg.Flag; local options=cfg.Options or {}
            local multi=cfg.MultipleOptions or false
            local selected=cfg.CurrentOption or {}
            if type(selected)=="string" then selected={selected} end

            local wrapper=Instance.new("Frame",sf)
            wrapper.Size=UDim2.new(1,0,0,0); wrapper.AutomaticSize=Enum.AutomaticSize.Y
            wrapper.BackgroundTransparency=1; wrapper.BorderSizePixel=0; wrapper.ClipsDescendants=false

            local hdrRow=mkRow(44)
            hdrRow.Parent=wrapper; hdrRow.Size=UDim2.new(1,0,0,44)

            local nameLbl=Instance.new("TextLabel",hdrRow)
            nameLbl.Size=UDim2.new(1,-100,1,0); nameLbl.Position=UDim2.new(0,12,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Dropdown"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            -- Right side: "V1 ^" style
            local rightArea=Instance.new("Frame",hdrRow)
            rightArea.Size=UDim2.new(0,90,1,0); rightArea.Position=UDim2.new(1,-96,0,0)
            rightArea.BackgroundTransparency=1

            local selLbl=Instance.new("TextLabel",rightArea)
            selLbl.Size=UDim2.new(1,-20,1,0); selLbl.Position=UDim2.new(0,0,0,0)
            selLbl.BackgroundTransparency=1; selLbl.TextColor3=C.ValueText
            selLbl.TextSize=12; selLbl.Font=Enum.Font.Gotham
            selLbl.TextXAlignment=Enum.TextXAlignment.Right

            local arrowLbl=Instance.new("TextLabel",rightArea)
            arrowLbl.Size=UDim2.new(0,18,1,0); arrowLbl.Position=UDim2.new(1,-18,0,0)
            arrowLbl.BackgroundTransparency=1; arrowLbl.Text="∧"
            arrowLbl.TextColor3=C.TextMid; arrowLbl.TextSize=12
            arrowLbl.Font=Enum.Font.GothamBold; arrowLbl.TextXAlignment=Enum.TextXAlignment.Center

            -- dropdown list
            local listFrame=Instance.new("Frame",wrapper)
            listFrame.Position=UDim2.new(0,0,0,48); listFrame.BackgroundColor3=C.ElementBackground
            listFrame.BorderSizePixel=0; listFrame.ClipsDescendants=true; listFrame.Visible=false
            listFrame.Size=UDim2.new(1,0,0,0)
            mkCorner(listFrame,8); mkStroke(listFrame,C.ElementStroke,1)
            local lll=Instance.new("UIListLayout",listFrame)
            lll.SortOrder=Enum.SortOrder.LayoutOrder; lll.Padding=UDim.new(0,2)
            mkPadding(listFrame,4,4,0,0)

            local open=false; local optBtns={}

            local function getSelText()
                if #selected==0 then return "None" end
                if #selected==1 then return selected[1] end
                return selected[1].." +"..tostring(#selected-1)
            end
            selLbl.Text=getSelText()

            local function isSel(o) for _,v in ipairs(selected) do if v==o then return true end end return false end

            local function refreshBtns()
                for opt,btn in pairs(optBtns) do
                    btn.BackgroundColor3=isSel(opt) and C.DropdownSelected or C.DropdownUnselected
                    local ol=btn:FindFirstChildOfClass("TextLabel")
                    if ol then ol.TextColor3=isSel(opt) and C.Accent or C.TextColor end
                end
                selLbl.Text=getSelText()
            end

            local function buildOptions(opts)
                for _,b in pairs(optBtns) do b:Destroy() end; optBtns={}
                for _,opt in ipairs(opts) do
                    local ob=Instance.new("TextButton",listFrame)
                    ob.Size=UDim2.new(1,-8,0,34); ob.BackgroundColor3=isSel(opt) and C.DropdownSelected or C.DropdownUnselected
                    ob.BorderSizePixel=0; ob.Text=""; ob.AutoButtonColor=false; mkCorner(ob,6)
                    local ol=Instance.new("TextLabel",ob)
                    ol.Size=UDim2.new(1,-20,1,0); ol.Position=UDim2.new(0,10,0,0)
                    ol.BackgroundTransparency=1; ol.Text=opt
                    ol.TextColor3=isSel(opt) and C.Accent or C.TextColor
                    ol.TextSize=13; ol.Font=Enum.Font.Gotham; ol.TextXAlignment=Enum.TextXAlignment.Left
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            if isSel(opt) then for i,v in ipairs(selected) do if v==opt then table.remove(selected,i);break end end
                            else table.insert(selected,opt) end
                        else selected={opt} end
                        refreshBtns()
                        if flag then flags[flag]=selected; saveConfig() end
                        if cfg.Callback then cfg.Callback(selected) end
                    end)
                    ob.MouseEnter:Connect(function() if not isSel(opt) then tw(ob,FAST,{BackgroundColor3=C.BtnHover}) end end)
                    ob.MouseLeave:Connect(function() ob.BackgroundColor3=isSel(opt) and C.DropdownSelected or C.DropdownUnselected end)
                    optBtns[opt]=ob
                end
                listFrame.Size=UDim2.new(1,0,0,math.min(#opts,6)*36+8)
            end
            buildOptions(options)

            local click=Instance.new("TextButton",hdrRow)
            click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1
            click.Text=""; click.AutoButtonColor=false; click.ZIndex=5
            click.MouseButton1Click:Connect(function()
                open=not open; listFrame.Visible=open
                tw(arrowLbl,FAST,{Text=open and "∨" or "∧",TextColor3=open and C.Accent or C.TextMid})
            end)
            click.MouseEnter:Connect(function() tw(hdrRow,FAST,{BackgroundColor3=C.BtnHover}) end)
            click.MouseLeave:Connect(function() tw(hdrRow,FAST,{BackgroundColor3=C.ElementBackground}) end)

            local D={}; D.CurrentOption=selected
            function D:Set(s) if type(s)=="string" then s={s} end; selected=s; refreshBtns()
                if flag then flags[flag]=selected;saveConfig() end; if cfg.Callback then cfg.Callback(selected) end end
            function D:Refresh(opts) options=opts; buildOptions(opts); refreshBtns() end
            return D
        end

        -- INPUT — name on left, box on right like Rayfield "placeholder"
        function Tab:CreateInput(cfg)
            local flag=cfg.Flag
            local row=mkRow(44)

            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(0.45,0,1,0); nameLbl.Position=UDim2.new(0,12,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Input"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            local boxWrap=Instance.new("Frame",row)
            boxWrap.Size=UDim2.new(0.5,-8,0,28); boxWrap.Position=UDim2.new(0.5,0,0.5,-14)
            boxWrap.BackgroundColor3=C.InputBackground; boxWrap.BorderSizePixel=0
            mkCorner(boxWrap,6); local bs=mkStroke(boxWrap,C.InputStroke,1)

            local box=Instance.new("TextBox",boxWrap)
            box.Size=UDim2.new(1,0,1,0); box.BackgroundTransparency=1
            box.Text=cfg.CurrentValue or cfg.Default or ""
            box.PlaceholderText=cfg.PlaceholderText or cfg.Placeholder or "placeholder"
            box.TextColor3=C.TextColor; box.PlaceholderColor3=C.PlaceholderColor
            box.TextSize=12; box.Font=Enum.Font.Gotham; box.ClearTextOnFocus=false
            mkPadding(box,0,0,8,8)

            box.Focused:Connect(function() tw(bs,FAST,{Color=C.Accent}) end)
            box.FocusLost:Connect(function(enter)
                tw(bs,FAST,{Color=C.InputStroke})
                if cfg.RemoveTextAfterFocusLost and not enter then box.Text="" end
                if flag then flags[flag]=box.Text;saveConfig() end
                if cfg.Callback then cfg.Callback(box.Text) end
            end)

            local I={}; I.CurrentValue=box.Text
            function I:Set(v) box.Text=v end; function I:GetValue() return box.Text end
            return I
        end
        Tab.CreateTextInput=Tab.CreateInput

        -- KEYBIND — name left, key badge right like "[T]"
        function Tab:CreateKeybind(cfg)
            local flag=cfg.Flag; local currentKey=cfg.CurrentKeybind or "None"
            local holdMode=cfg.HoldToInteract or false; local listening=false
            local row=mkRow(44)

            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(1,-80,1,0); nameLbl.Position=UDim2.new(0,12,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Keybind"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            -- Square key badge like Rayfield
            local badge=Instance.new("Frame",row)
            badge.Size=UDim2.new(0,32,0,32); badge.Position=UDim2.new(1,-42,0.5,-16)
            badge.BackgroundColor3=C.SecondaryElementBackground; badge.BorderSizePixel=0
            mkCorner(badge,6); mkStroke(badge,C.ElementStroke,1)

            local keyLbl=Instance.new("TextLabel",badge)
            keyLbl.Size=UDim2.new(1,0,1,0); keyLbl.BackgroundTransparency=1
            keyLbl.Text=#currentKey<=2 and currentKey or currentKey:sub(1,1)
            keyLbl.TextColor3=C.TextColor; keyLbl.TextSize=13
            keyLbl.Font=Enum.Font.GothamBold; keyLbl.TextXAlignment=Enum.TextXAlignment.Center

            local function setKey(k)
                currentKey=k; keyLbl.Text=#k<=2 and k or k:sub(1,1)
                keyLbl.TextColor3=C.TextColor
                if flag then flags[flag]=k;saveConfig() end
            end

            local click=Instance.new("TextButton",row)
            click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1
            click.Text=""; click.AutoButtonColor=false; click.ZIndex=5
            click.MouseButton1Click:Connect(function()
                listening=true; keyLbl.Text="?"; keyLbl.TextColor3=C.Accent
            end)
            click.MouseEnter:Connect(function() tw(row,FAST,{BackgroundColor3=C.BtnHover}) end)
            click.MouseLeave:Connect(function() tw(row,FAST,{BackgroundColor3=C.ElementBackground}) end)

            UserInputService.InputBegan:Connect(function(input,gp)
                if gp then return end
                if listening then
                    listening=false; local n=input.KeyCode.Name
                    if n~="Unknown" then setKey(n) end; return
                end
                if input.KeyCode.Name==currentKey then
                    if holdMode then if cfg.Callback then cfg.Callback(true) end
                    else if cfg.Callback then cfg.Callback(false) end end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if holdMode and input.KeyCode.Name==currentKey then
                    if cfg.Callback then cfg.Callback(false) end end
            end)

            local K={}; K.CurrentKeybind=currentKey
            function K:Set(k) setKey(k) end
            return K
        end

        -- COLOR PICKER — colored swatch on right
        function Tab:CreateColorPicker(cfg)
            local flag=cfg.Flag; local currentColor=cfg.Color or Color3.fromRGB(255,255,255)
            local pickerOpen=false
            local h,s,v=Color3.toHSV(currentColor)

            local wrapper=Instance.new("Frame",sf)
            wrapper.Size=UDim2.new(1,0,0,44); wrapper.BackgroundTransparency=1
            wrapper.BorderSizePixel=0; wrapper.ClipsDescendants=false

            local row=mkRow(44); row.Parent=wrapper; row.Size=UDim2.new(1,0,0,44)

            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(1,-70,1,0); nameLbl.Position=UDim2.new(0,12,0,0)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg.Name or "Color Picker"
            nameLbl.TextColor3=C.TextColor; nameLbl.TextSize=13
            nameLbl.Font=Enum.Font.GothamSemibold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

            -- Color swatch like Rayfield screenshot
            local swatch=Instance.new("TextButton",row)
            swatch.Size=UDim2.new(0,46,0,26); swatch.Position=UDim2.new(1,-54,0.5,-13)
            swatch.BackgroundColor3=currentColor; swatch.BorderSizePixel=0
            swatch.Text=""; swatch.AutoButtonColor=false; mkCorner(swatch,6)
            mkStroke(swatch,C.Border,1)

            -- Picker panel
            local panel=Instance.new("Frame",wrapper)
            panel.Size=UDim2.new(1,0,0,155); panel.Position=UDim2.new(0,0,0,48)
            panel.BackgroundColor3=C.ElementBackground; panel.BorderSizePixel=0
            panel.Visible=false; panel.ZIndex=20
            mkCorner(panel,8); mkStroke(panel,C.ElementStroke,1); mkPadding(panel,10,10,12,12)

            local function mkHSV(label,yp,init)
                local l=Instance.new("TextLabel",panel); l.Size=UDim2.new(0,12,0,14)
                l.Position=UDim2.new(0,0,0,yp); l.BackgroundTransparency=1; l.Text=label
                l.TextColor3=C.TextDim; l.TextSize=10; l.Font=Enum.Font.GothamBold; l.ZIndex=21
                local tr=Instance.new("Frame",panel); tr.Size=UDim2.new(1,-20,0,8)
                tr.Position=UDim2.new(0,18,0,yp+3); tr.BackgroundColor3=C.SecondaryElementBackground
                tr.BorderSizePixel=0; tr.ZIndex=21; mkCorner(tr,4)
                local fi=Instance.new("Frame",tr); fi.BackgroundColor3=C.Accent; fi.BorderSizePixel=0
                fi.Size=UDim2.new(init,0,1,0); fi.ZIndex=22; mkCorner(fi,4)
                return tr,fi
            end
            local hT,hF=mkHSV("H",0,h); local sT,sF=mkHSV("S",26,s); local vT,vF=mkHSV("V",52,v)

            local hexBox=Instance.new("TextBox",panel)
            hexBox.Size=UDim2.new(1,0,0,30); hexBox.Position=UDim2.new(0,0,0,82)
            hexBox.BackgroundColor3=C.InputBackground; hexBox.BorderSizePixel=0
            hexBox.TextColor3=C.TextColor; hexBox.PlaceholderColor3=C.PlaceholderColor
            hexBox.PlaceholderText="#FFFFFF"; hexBox.TextSize=12; hexBox.Font=Enum.Font.Gotham
            hexBox.ClearTextOnFocus=false; hexBox.ZIndex=21; mkCorner(hexBox,6)
            mkStroke(hexBox,C.InputStroke,1); mkPadding(hexBox,0,0,8,8)

            local function updateColor()
                currentColor=Color3.fromHSV(h,s,v); swatch.BackgroundColor3=currentColor
                local r2=math.floor(currentColor.R*255+0.5)
                local g2=math.floor(currentColor.G*255+0.5)
                local b2=math.floor(currentColor.B*255+0.5)
                hexBox.Text=string.format("#%02X%02X%02X",r2,g2,b2)
                hF.Size=UDim2.new(h,0,1,0); sF.Size=UDim2.new(s,0,1,0); vF.Size=UDim2.new(v,0,1,0)
                if flag then flags[flag]=currentColor;saveConfig() end
                if cfg.Callback then cfg.Callback(currentColor) end
            end
            updateColor()

            local function drag(track,onV)
                local dr=false
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        dr=true; onV(math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)) end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
                        onV(math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
            end
            drag(hT,function(val) h=val;updateColor() end)
            drag(sT,function(val) s=val;updateColor() end)
            drag(vT,function(val) v=val;updateColor() end)
            hexBox.FocusLost:Connect(function()
                local hex=hexBox.Text:gsub("#","")
                if #hex==6 then
                    local rn,gn,bn=tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16)
                    if rn and gn and bn then h,s,v=Color3.toHSV(Color3.fromRGB(rn,gn,bn)); updateColor() end
                end
            end)
            swatch.MouseButton1Click:Connect(function()
                pickerOpen=not pickerOpen; panel.Visible=pickerOpen
                wrapper.Size=UDim2.new(1,0,0,pickerOpen and 207 or 44)
            end)

            local CP={}; CP.CurrentColor=currentColor
            function CP:Set(c2) currentColor=c2; h,s,v=Color3.toHSV(c2); updateColor() end
            return CP
        end

        return Tab
    end

    function Window:LoadConfiguration()
        local saved=loadConfig()
        for flag,val in pairs(saved) do
            local setter=toggleSetters[flag]
            if setter and type(val)=="boolean" then setter(val,false) end
        end
    end

    return Window
end

return DevNgg
