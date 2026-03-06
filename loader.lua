-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║                  DevN.gg  UI Library  v4.3                         ║
-- ║        Frosted Glass  ·  Soft Navy  ·  Minimalist                  ║
-- ║             github.com/nh1cScript-gg/DevN.gg                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")

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
    for _,fn in ipairs(_openDropdowns) do pcall(fn) end
    table.clear(_openDropdowns)
end
local function registerDropdown(fn)   table.insert(_openDropdowns,fn) end
local function unregisterDropdown(fn)
    for i=#_openDropdowns,1,-1 do
        if _openDropdowns[i]==fn then table.remove(_openDropdowns,i) end
    end
end

-- ══════════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════════
local function getSavePath() return saveFolder.."/"..saveFile..".json" end
local function saveConfig()
    pcall(function()
        if not isfolder(saveFolder) then makefolder(saveFolder) end
        local d={}; for k,v in pairs(flags) do d[k]=v end
        writefile(getSavePath(),HttpService:JSONEncode(d))
    end)
end
local function loadConfig()
    local ok,r=pcall(function()
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
    -- Try CoreGui first (works in most executors)
    local ok=pcall(function() gui.Parent=game:GetService("CoreGui") end)
    if ok and gui.Parent then return end
    -- Fallback to gethui() if available
    ok=pcall(function() gui.Parent=gethui() end)
    if ok and gui.Parent then return end
    -- Last resort: PlayerGui
    gui.Parent=playerGui
end

-- ══════════════════════════════════════════════════════════════
-- COLOURS  — Frosted glass navy theme
-- HIGH BackgroundTransparency (0.45-0.55) so the blurred game
-- world is VISIBLE behind every panel.
-- ══════════════════════════════════════════════════════════════
local C = {
    NAVY         = Color3.fromRGB(3,   34,  80),   -- #022658 base navy
    DARK         = Color3.fromRGB(6,   14,  38),   -- darker navy for content
    HDR          = Color3.fromRGB(2,   20,  56),   -- header/footer tint

    TAB_ON_BG    = Color3.fromRGB(255, 255, 255),  -- active tab: white pill
    TAB_ON_FG    = Color3.fromRGB(3,   34,  80),   -- active tab: navy text
    TAB_OFF      = Color3.fromRGB(175, 208, 255),  -- idle tab text

    BORDER       = Color3.fromRGB(90,  130, 210),  -- subtle border
    BORDER_FOC   = Color3.fromRGB(168, 207, 255),  -- focused border

    -- TEXT — all bright for legibility on glass
    TXT_A        = Color3.fromRGB(255, 255, 255),  -- white: titles, active
    TXT_B        = Color3.fromRGB(205, 222, 255),  -- soft white: labels
    TXT_C        = Color3.fromRGB(130, 165, 220),  -- muted: hints, footer

    -- Accent
    ACCENT       = Color3.fromRGB(168, 207, 255),  -- pale periwinkle

    -- Toggle
    TOG_ON       = Color3.fromRGB(150, 225, 175),  -- soft mint
    TOG_ON_BG    = Color3.fromRGB(10,  44,  26),
    TOG_OFF_BG   = Color3.fromRGB(8,   12,  28),
    TOG_KNOB_OFF = Color3.fromRGB(110, 140, 190),

    -- Interactions
    HOV          = Color3.fromRGB(18,  48, 108),
    ACT          = Color3.fromRGB(30,  68, 148),

    RED          = Color3.fromRGB(255, 105, 105),
    AMBER        = Color3.fromRGB(255, 195,  75),
}

-- Transparency — HIGH so glass effect is actually visible
local T = {
    SIDE   = 0.46,  -- sidebar
    CONT   = 0.50,  -- content panel
    SURF   = 0.52,  -- cards / rows
    HDR    = 0.40,  -- header strips
    NOTIF  = 0.30,
    CTRL   = 0.55,  -- window control buttons
}

local FAST = TweenInfo.new(0.10,Enum.EasingStyle.Quint)
local MED  = TweenInfo.new(0.20,Enum.EasingStyle.Quint)
local function tw(o,i,p) TweenService:Create(o,i,p):Play() end

-- Safe font lookup — GothamLight/RobotoMono may not exist in all executors
local function safeFont(name, fallback)
    local ok,f=pcall(function() return Enum.Font[name] end)
    return (ok and f) or Enum.Font[fallback]
end
local F = {
    TITLE = Enum.Font.GothamBold,
    HEAD  = Enum.Font.GothamSemibold,
    BODY  = Enum.Font.Gotham,
    LIGHT = safeFont("GothamLight",   "Gotham"),
    MONO  = safeFont("RobotoMono",    "Code"),
}

-- ══════════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════════
local function make(class,props,parent)
    local obj=Instance.new(class)
    for k,v in pairs(props or {}) do obj[k]=v end
    if parent then obj.Parent=parent end
    return obj
end
local function corner(p,r) make("UICorner",{CornerRadius=UDim.new(0,r or 8)},p) end
local function stroke(p,col,th,tr)
    return make("UIStroke",{
        Color=col or C.BORDER, Thickness=th or 1, Transparency=tr or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    },p)
end
local function pad(p,t,b,l,r)
    make("UIPadding",{
        PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),
        PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),
    },p)
end
local function listL(p,sp,dir,ha,va)
    return make("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirection=dir or Enum.FillDirection.Vertical,
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment=va or Enum.VerticalAlignment.Top,
        Padding=UDim.new(0,sp or 0),
    },p)
end

-- ══════════════════════════════════════════════════════════════
-- MODULE
-- ══════════════════════════════════════════════════════════════
local mainFrame  = nil
local blurEffect = nil
local guiVisible = true
local DevNgg     = {}

-- Blur (strength 18 — strongly frosted)
pcall(function()
    for _,c in ipairs(Lighting:GetChildren()) do
        if c:IsA("BlurEffect") and c.Name=="DevNggBlur" then c:Destroy() end
    end
    blurEffect=make("BlurEffect",{Name="DevNggBlur",Size=0},Lighting)
end)

local function setBlur(on)
    pcall(function()
        if blurEffect then
            tw(blurEffect,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Size=on and 18 or 0})
        end
    end)
end

function DevNgg:SetVisibility(val)
    guiVisible=val
    if mainFrame then mainFrame.Visible=val end
    setBlur(val)
    if not val then closeAllDropdowns() end
end
function DevNgg:IsVisible() return guiVisible end
function DevNgg:Destroy()
    pcall(function() if blurEffect then blurEffect:Destroy() end end)
    pcall(function() if mainFrame and mainFrame.Parent then mainFrame.Parent:Destroy() end end)
end

-- ══════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════
local notifGui=make("ScreenGui",{
    Name="DevNggNotif",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999,
})
pcall(function() notifGui.IgnoreGuiInset=true end)
safeParent(notifGui)

local nHolder=make("Frame",{
    Size=UDim2.new(0,285,1,0),Position=UDim2.new(1,-298,0,0),
    BackgroundTransparency=1,
},notifGui)
listL(nHolder,6,Enum.FillDirection.Vertical,
    Enum.HorizontalAlignment.Right,Enum.VerticalAlignment.Bottom)
pad(nHolder,0,18,0,0)

local nCount=0

function DevNgg:Notify(cfg)
    if nCount>=5 then return end; nCount+=1
    local title=cfg.Title or "DevN.gg"
    local body =cfg.Content or ""
    local dur  =cfg.Duration or 3

    local card=make("Frame",{
        Size=UDim2.new(1,0,0,66),BackgroundColor3=C.NAVY,
        BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,
    },nHolder); corner(card,10)
    local cs=stroke(card,C.BORDER,1,1)

    local bar=make("Frame",{
        Size=UDim2.new(0,3,0,32),Position=UDim2.new(0,0,0.5,-16),
        BackgroundColor3=C.ACCENT,BackgroundTransparency=1,BorderSizePixel=0,
    },card); corner(bar,2)

    local tL=make("TextLabel",{
        Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,14,0,11),
        BackgroundTransparency=1,Text=title,TextColor3=C.TXT_A,
        TextTransparency=1,TextSize=13,Font=F.HEAD,
        TextXAlignment=Enum.TextXAlignment.Left,
    },card)
    local sL=make("TextLabel",{
        Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,14,0,33),
        BackgroundTransparency=1,Text=body,TextColor3=C.TXT_B,
        TextTransparency=1,TextSize=11,Font=F.BODY,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
    },card)
    local pb=make("Frame",{
        Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=C.BORDER,BorderSizePixel=0,
    },card)
    local pf=make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.ACCENT,BorderSizePixel=0},pb)

    tw(card,MED,{BackgroundTransparency=T.NOTIF})
    tw(cs,MED,{Transparency=0}); tw(bar,MED,{BackgroundTransparency=0})
    tw(tL,MED,{TextTransparency=0}); tw(sL,MED,{TextTransparency=0})
    tw(pf,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)})

    task.delay(dur,function()
        tw(card,MED,{BackgroundTransparency=1}); tw(cs,MED,{Transparency=1})
        tw(bar,MED,{BackgroundTransparency=1})
        tw(tL,MED,{TextTransparency=1}); tw(sL,MED,{TextTransparency=1})
        task.wait(0.22); card:Destroy(); nCount-=1
    end)
end

-- ══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function DevNgg:CreateWindow(config)
    local winTitle  = config.Name              or "DevN.gg"
    local winSub    = config.Subtitle          or "by DevN.gg"
    local winVer    = config.Version           or "v1.0"
    local toggleKey = config.ToggleUIKeybind   or "K"
    local loadTitle = config.LoadingTitle      or winTitle
    local loadSub   = config.LoadingSubtitle   or "Loading..."

    if config.ConfigurationSaving and config.ConfigurationSaving.Enabled then
        saveFolder=config.ConfigurationSaving.FolderName or saveFolder
        saveFile  =config.ConfigurationSaving.FileName   or saveFile
    end

    -- ── ScreenGui ─────────────────────────────────────────────
    local sg=make("ScreenGui",{
        Name="DevNggGUI",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=100,
    })
    pcall(function() sg.IgnoreGuiInset=true end)
    safeParent(sg)

    -- ── Loading bar ───────────────────────────────────────────
    -- Shown immediately (no delay), destroyed after ~1.5s
    local lf=make("Frame",{
        Size=UDim2.new(0,340,0,110),Position=UDim2.new(0.5,-170,0.5,-55),
        BackgroundColor3=C.NAVY,BackgroundTransparency=T.SIDE,
        BorderSizePixel=0,ZIndex=50,
    },sg); corner(lf,12); stroke(lf,C.BORDER,1,0.4)

    make("TextLabel",{
        Size=UDim2.new(1,-28,0,22),Position=UDim2.new(0,14,0,16),
        BackgroundTransparency=1,Text=loadTitle,TextColor3=C.TXT_A,
        TextSize=16,Font=F.TITLE,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=51,
    },lf)
    make("TextLabel",{
        Size=UDim2.new(1,-28,0,14),Position=UDim2.new(0,14,0,42),
        BackgroundTransparency=1,Text=loadSub,TextColor3=C.TXT_C,
        TextSize=11,Font=F.LIGHT,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=51,
    },lf)

    local pt=make("Frame",{
        Size=UDim2.new(1,-28,0,2),Position=UDim2.new(0,14,0,68),
        BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=51,
    },lf); corner(pt,2)
    local pBar=make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.ACCENT,BorderSizePixel=0,ZIndex=52},pt)
    corner(pBar,2)

    local lStat=make("TextLabel",{
        Size=UDim2.new(1,-28,0,14),Position=UDim2.new(0,14,0,78),
        BackgroundTransparency=1,Text="Loading...",TextColor3=C.TXT_C,
        TextSize=10,Font=F.LIGHT,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=51,
    },lf)

    -- ── Main window ────────────────────────────────────────────
    local SW=175; local WW=610; local WH=420

    local main=make("Frame",{
        Name="Main",Size=UDim2.new(0,WW,0,WH),
        Position=UDim2.new(0.5,-WW/2,0.5,-WH/2),
        BackgroundColor3=C.DARK,BackgroundTransparency=T.CONT,
        BorderSizePixel=0,ClipsDescendants=false,
        Visible=false,  -- shown after loading finishes
    },sg)
    corner(main,12); stroke(main,C.BORDER,1,0.5)
    mainFrame=main

    -- Shadow
    make("ImageLabel",{
        AnchorPoint=Vector2.new(0.5,0.5),
        Size=UDim2.new(1,80,1,80),Position=UDim2.new(0.5,0,0.5,12),
        BackgroundTransparency=1,Image="rbxassetid://6014054385",
        ImageColor3=Color3.fromRGB(0,10,40),ImageTransparency=0.5,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,
    },main)

    -- ── Sidebar ────────────────────────────────────────────────
    local side=make("Frame",{
        Name="Sidebar",Size=UDim2.new(0,SW,1,0),
        BackgroundColor3=C.NAVY,BackgroundTransparency=T.SIDE,
        BorderSizePixel=0,ZIndex=3,ClipsDescendants=true,
    },main); corner(side,12)

    -- Square the right edge of sidebar
    make("Frame",{
        Size=UDim2.new(0,12,1,0),Position=UDim2.new(1,-12,0,0),
        BackgroundColor3=C.NAVY,BackgroundTransparency=T.SIDE,
        BorderSizePixel=0,ZIndex=4,
    },side)
    -- Right divider
    make("Frame",{
        Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=C.BORDER,BackgroundTransparency=0.6,BorderSizePixel=0,ZIndex=5,
    },side)

    -- Sidebar header (drag handle)
    local sHdr=make("Frame",{
        Size=UDim2.new(1,0,0,76),BackgroundColor3=C.HDR,
        BackgroundTransparency=T.HDR,BorderSizePixel=0,ZIndex=5,
    },side)
    make("TextLabel",{
        Size=UDim2.new(1,-14,0,20),Position=UDim2.new(0,12,0,15),
        BackgroundTransparency=1,Text=winTitle,TextColor3=C.TXT_A,
        TextSize=15,Font=F.TITLE,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
    },sHdr)
    make("TextLabel",{
        Size=UDim2.new(1,-14,0,14),Position=UDim2.new(0,12,0,39),
        BackgroundTransparency=1,Text=winSub.."  "..winVer,TextColor3=C.TXT_C,
        TextSize=10,Font=F.LIGHT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
    },sHdr)
    make("Frame",{
        Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-1),
        BackgroundColor3=C.BORDER,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=6,
    },sHdr)

    -- Tab scroll
    local sScroll=make("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-113),Position=UDim2.new(0,0,0,77),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=C.BORDER,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=4,
    },side); pad(sScroll,8,8,0,0); listL(sScroll,2)

    -- Sidebar footer
    local sFoot=make("Frame",{
        Size=UDim2.new(1,0,0,35),Position=UDim2.new(0,0,1,-35),
        BackgroundColor3=C.HDR,BackgroundTransparency=T.HDR,BorderSizePixel=0,ZIndex=4,
    },side)
    make("Frame",{
        Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),
        BackgroundColor3=C.BORDER,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=5,
    },sFoot)
    make("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="[ "..toggleKey.." ]  Toggle",TextColor3=C.TXT_C,
        TextSize=10,Font=F.LIGHT,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5,
    },sFoot)

    -- ── Content panel ──────────────────────────────────────────
    local cPanel=make("Frame",{
        Name="Content",Size=UDim2.new(1,-SW,1,0),Position=UDim2.new(0,SW,0,0),
        BackgroundColor3=C.DARK,BackgroundTransparency=T.CONT,
        BorderSizePixel=0,ClipsDescendants=true,
    },main); corner(cPanel,12)
    -- Square left edge
    make("Frame",{
        Size=UDim2.new(0,12,1,0),BackgroundColor3=C.DARK,
        BackgroundTransparency=T.CONT,BorderSizePixel=0,
    },cPanel)

    -- Content header
    local cHdr=make("Frame",{
        Size=UDim2.new(1,0,0,48),BackgroundColor3=C.HDR,
        BackgroundTransparency=T.HDR,BorderSizePixel=0,ZIndex=3,
    },cPanel)
    local tabTitleLbl=make("TextLabel",{
        Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text="",TextColor3=C.TXT_A,
        TextSize=15,Font=F.HEAD,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4,
    },cHdr)
    make("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),
        BackgroundColor3=C.BORDER,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=4,
    },cHdr)

    -- Window controls (close / minimise)
    local function mkBtn(offX,sym,hcol)
        local b=make("TextButton",{
            Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,offX,0.5,-13),
            BackgroundColor3=C.NAVY,BackgroundTransparency=T.CTRL,
            Text=sym,TextColor3=C.TXT_C,TextSize=14,Font=F.HEAD,
            BorderSizePixel=0,AutoButtonColor=false,ZIndex=10,
        },cHdr); corner(b,5); stroke(b,C.BORDER,1,0.5)
        b.MouseEnter:Connect(function()
            tw(b,FAST,{TextColor3=hcol,BackgroundColor3=C.HOV,BackgroundTransparency=0.2})
        end)
        b.MouseLeave:Connect(function()
            tw(b,FAST,{TextColor3=C.TXT_C,BackgroundColor3=C.NAVY,BackgroundTransparency=T.CTRL})
        end)
        return b
    end
    local minimized=false
    local closeBtn=mkBtn(-36,"×",C.RED)
    local minBtn  =mkBtn(-68,"−",C.AMBER)
    closeBtn.MouseButton1Click:Connect(function() DevNgg:SetVisibility(false) end)

    local cClip=make("Frame",{
        Size=UDim2.new(1,0,1,-49),Position=UDim2.new(0,0,0,49),
        BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2,
    },cPanel)

    -- ── Drag ──────────────────────────────────────────────────
    local dragging,dragStart,startPos
    sHdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=i.Position; startPos=main.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            closeAllDropdowns()
            local d=i.Position-dragStart
            main.Position=UDim2.new(0,startPos.X+d.X,0,startPos.Y+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        pcall(function()
            local key=typeof(toggleKey)=="string" and Enum.KeyCode[toggleKey] or toggleKey
            if i.KeyCode==key then DevNgg:SetVisibility(not guiVisible) end
        end)
    end)

    -- ── Loading animation then show main ───────────────────────
    -- Run synchronously so nothing can silently error and skip showing the GUI
    task.spawn(function()
        local steps={
            {p=0.3,m="Loading components..."},
            {p=0.6,m="Applying theme..."},
            {p=0.85,m="Connecting..."},
            {p=1.0,m="Ready!"},
        }
        for _,s in ipairs(steps) do
            pcall(function()
                tw(pBar,TweenInfo.new(0.28,Enum.EasingStyle.Quint),{Size=UDim2.new(s.p,0,1,0)})
                lStat.Text=s.m
            end)
            task.wait(0.30)
        end
        task.wait(0.15)

        -- *** Show main window FIRST, then fade out loader ***
        main.Visible=true
        setBlur(true)

        -- Fade out loader
        pcall(function()
            for _,d in ipairs(lf:GetDescendants()) do
                if d:IsA("TextLabel") then tw(d,MED,{TextTransparency=1})
                elseif d:IsA("Frame") then tw(d,MED,{BackgroundTransparency=1}) end
            end
            tw(lf,MED,{BackgroundTransparency=1})
        end)
        task.wait(0.25)
        pcall(function() lf:Destroy() end)
    end)

    -- ══════════════════════════════════════════════════════════
    -- TAB SYSTEM
    -- ══════════════════════════════════════════════════════════
    local tabs={};local activeTab=nil;local tabCount=0

    local function updateH()
        if not activeTab or minimized then return end
        local h=math.clamp(activeTab.ll.AbsoluteContentSize.Y+49+24,WH,580)
        tw(main,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(0,WW,0,h)})
    end

    local function switchTab(tab)
        closeAllDropdowns()
        for _,t in ipairs(tabs) do
            t.content.Visible=false
            tw(t.btn,FAST,{
                BackgroundColor3=C.NAVY,BackgroundTransparency=1,TextColor3=C.TAB_OFF,
            })
            if t.acc then tw(t.acc,FAST,{BackgroundTransparency=1}) end
        end
        tab.content.Visible=true; activeTab=tab
        tabTitleLbl.Text=tab.name
        tw(tab.btn,FAST,{
            BackgroundColor3=C.TAB_ON_BG,BackgroundTransparency=0,TextColor3=C.TAB_ON_FG,
        })
        if tab.acc then tw(tab.acc,FAST,{BackgroundTransparency=0}) end
        updateH()
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized; closeAllDropdowns()
        cClip.Visible=not minimized
        sScroll.Visible=not minimized; sFoot.Visible=not minimized
        if minimized then
            tw(main,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(0,WW,0,48)})
        else updateH() end
        minBtn.Text=minimized and "+" or "−"
    end)

    -- ══════════════════════════════════════════════════════════
    -- WINDOW OBJECT
    -- ══════════════════════════════════════════════════════════
    local Window={}

    function Window:CreateTab(name,_icon)
        tabCount+=1; local idx=tabCount

        -- Sidebar button
        local sBtn=make("TextButton",{
            Name=name,Size=UDim2.new(1,-14,0,36),Position=UDim2.new(0,7,0,0),
            BackgroundColor3=C.TAB_ON_BG,BackgroundTransparency=1,
            BorderSizePixel=0,Text="  "..name,
            TextColor3=C.TAB_OFF,TextSize=12,Font=F.HEAD,
            AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left,
            LayoutOrder=idx,ZIndex=5,
        },sScroll); corner(sBtn,7)

        local sAcc=make("Frame",{
            Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,0,0.5,-9),
            BackgroundColor3=C.ACCENT,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=6,
        },sBtn); corner(sAcc,2)

        sBtn.MouseEnter:Connect(function()
            if activeTab and activeTab.btn==sBtn then return end
            tw(sBtn,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.3,TextColor3=C.TXT_B})
        end)
        sBtn.MouseLeave:Connect(function()
            if activeTab and activeTab.btn==sBtn then return end
            tw(sBtn,FAST,{BackgroundColor3=C.NAVY,BackgroundTransparency=1,TextColor3=C.TAB_OFF})
        end)

        -- Content scroll
        local tSF=make("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER,
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false,ZIndex=2,
        },cClip)
        local tLL=make("UIListLayout",{
            SortOrder=Enum.SortOrder.LayoutOrder,
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            Padding=UDim.new(0,5),
        },tSF); pad(tSF,12,18,12,12)

        local tabData={name=name,btn=sBtn,acc=sAcc,content=tSF,ll=tLL}
        table.insert(tabs,tabData)
        sBtn.MouseButton1Click:Connect(function() switchTab(tabData) end)
        tLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if activeTab==tabData then updateH() end
        end)
        if tabCount==1 then task.defer(function() switchTab(tabData) end) end

        local content=tSF
        local Tab={}

        -- ────────────────────────────────────────────────────
        -- ELEMENTS
        -- ────────────────────────────────────────────────────

        function Tab:CreateSection(sName)
            local row=make("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},content)
            make("Frame",{
                Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0.5,0),
                BackgroundColor3=C.BORDER,BackgroundTransparency=0.5,BorderSizePixel=0,
            },row)
            local pill=make("Frame",{
                BackgroundColor3=C.NAVY,BackgroundTransparency=0.2,
                BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),
            },row); corner(pill,5)
            make("TextLabel",{
                BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,
                Size=UDim2.new(0,0,1,0),Text="  "..sName:upper().."  ",
                TextColor3=C.ACCENT,TextSize=9,Font=F.HEAD,
                TextXAlignment=Enum.TextXAlignment.Left,
            },pill)
            local S={}
            function S:Set(n) pill:FindFirstChildOfClass("TextLabel").Text="  "..n:upper().."  " end
            return S
        end

        function Tab:CreateDivider()
            local d=make("Frame",{
                Size=UDim2.new(1,0,0,1),BackgroundColor3=C.BORDER,
                BackgroundTransparency=0.5,BorderSizePixel=0,
            },content)
            local D={}; function D:Set(v) d.Visible=v end; return D
        end

        function Tab:CreateLabel(cfg)
            local f=make("Frame",{
                Size=UDim2.new(1,0,0,38),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,
            },content); corner(f,8); stroke(f,C.BORDER,1,0.5)
            local lbl=make("TextLabel",{
                Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=cfg.Text or "",TextColor3=C.TXT_B,
                TextSize=12,Font=F.BODY,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
            },f)
            local L={}
            function L:Set(t) lbl.Text=t end
            function L:SetColor(c) lbl.TextColor3=c end
            return L
        end

        function Tab:CreateParagraph(cfg)
            local f=make("Frame",{
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF,BorderSizePixel=0,
            },content); corner(f,8); stroke(f,C.BORDER,1,0.5)
            local inner=make("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},f)
            pad(inner,10,10,12,12)
            make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},inner)
            local tL=make("TextLabel",{
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1,Text=cfg.Title or "",TextColor3=C.TXT_A,
                TextSize=13,Font=F.HEAD,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true,LayoutOrder=1,
            },inner)
            local bL=make("TextLabel",{
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1,Text=cfg.Content or "",TextColor3=C.TXT_B,
                TextSize=12,Font=F.BODY,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true,LayoutOrder=2,
            },inner)
            local P={}
            function P:Set(t,b)      tL.Text=t or tL.Text; bL.Text=b or bL.Text end
            function P:SetTitle(t)   tL.Text=t end
            function P:SetContent(b) bL.Text=b end
            return P
        end

        function Tab:CreateToggle(cfg)
            local flag=cfg.Flag; local enabled=cfg.CurrentValue or false

            local row=make("TextButton",{
                Size=UDim2.new(1,0,0,48),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,Text="",AutoButtonColor=false,
            },content); corner(row,8)
            local rs=stroke(row,C.BORDER,1,0.5)

            local stripe=make("Frame",{
                Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,0.5,-13),
                BackgroundColor3=C.ACCENT,BackgroundTransparency=1,BorderSizePixel=0,
            },row); corner(stripe,2)

            local lbl=make("TextLabel",{
                Size=UDim2.new(1,-68,1,0),Position=UDim2.new(0,14,0,0),
                BackgroundTransparency=1,Text=cfg.Name or "Toggle",
                TextColor3=C.TXT_B,TextSize=13,Font=F.BODY,
                TextXAlignment=Enum.TextXAlignment.Left,
            },row)

            local pill=make("Frame",{
                Size=UDim2.new(0,40,0,22),Position=UDim2.new(1,-52,0.5,-11),
                BackgroundColor3=C.TOG_OFF_BG,BorderSizePixel=0,
            },row); corner(pill,11); stroke(pill,C.BORDER,1,0.4)

            local knob=make("Frame",{
                Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8),
                BackgroundColor3=C.TOG_KNOB_OFF,BorderSizePixel=0,
            },pill); corner(knob,8)

            local function setState(val,silent)
                enabled=val
                if flag then flags[flag]=val; if not silent then saveConfig() end end
                if val then
                    tw(pill,FAST,{BackgroundColor3=C.TOG_ON_BG})
                    tw(knob,FAST,{Position=UDim2.new(0,21,0.5,-8),BackgroundColor3=C.TOG_ON})
                    tw(lbl,FAST,{TextColor3=C.TXT_A})
                    tw(stripe,FAST,{BackgroundTransparency=0})
                    tw(rs,FAST,{Color=C.ACCENT,Transparency=0.2})
                    tw(row,FAST,{BackgroundColor3=C.NAVY,BackgroundTransparency=T.SURF-0.08})
                else
                    tw(pill,FAST,{BackgroundColor3=C.TOG_OFF_BG})
                    tw(knob,FAST,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=C.TOG_KNOB_OFF})
                    tw(lbl,FAST,{TextColor3=C.TXT_B})
                    tw(stripe,FAST,{BackgroundTransparency=1})
                    tw(rs,FAST,{Color=C.BORDER,Transparency=0.5})
                    tw(row,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF})
                end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            if enabled then setState(true,true) end
            if flag then toggleSetters[flag]=setState end
            row.MouseButton1Click:Connect(function() setState(not enabled) end)
            row.MouseEnter:Connect(function()
                if not enabled then tw(row,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.25}) end
            end)
            row.MouseLeave:Connect(function()
                if not enabled then tw(row,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF}) end
            end)
        end

        function Tab:CreateButton(cfg)
            local btn=make("TextButton",{
                Size=UDim2.new(1,0,0,44),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,
                Text=cfg.Name or "Button",TextColor3=C.TXT_B,
                TextSize=13,Font=F.HEAD,AutoButtonColor=false,
            },content); corner(btn,8)
            local bs=stroke(btn,C.BORDER,1,0.5)
            btn.MouseButton1Click:Connect(function()
                tw(btn,FAST,{BackgroundColor3=C.ACT,BackgroundTransparency=0.1,TextColor3=C.TXT_A})
                tw(bs,FAST,{Color=C.BORDER_FOC,Transparency=0})
                task.delay(0.14,function()
                    tw(btn,MED,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF,TextColor3=C.TXT_B})
                    tw(bs,MED,{Color=C.BORDER,Transparency=0.5})
                end)
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            btn.MouseEnter:Connect(function()
                tw(btn,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2,TextColor3=C.TXT_A})
                tw(bs,FAST,{Color=C.BORDER_FOC,Transparency=0})
            end)
            btn.MouseLeave:Connect(function()
                tw(btn,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF,TextColor3=C.TXT_B})
                tw(bs,MED,{Color=C.BORDER,Transparency=0.5})
            end)
        end

        function Tab:CreateTextInput(cfg)
            local w=make("Frame",{Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,BorderSizePixel=0},content)
            make("TextLabel",{
                Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,2,0,0),
                BackgroundTransparency=1,Text=cfg.Name or "Input",TextColor3=C.TXT_B,
                TextSize=11,Font=F.HEAD,TextXAlignment=Enum.TextXAlignment.Left,
            },w)
            local box=make("TextBox",{
                Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,20),
                BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF,BorderSizePixel=0,
                Text=cfg.Default or "",PlaceholderText=cfg.Placeholder or "Type here...",
                TextColor3=C.TXT_A,PlaceholderColor3=C.TXT_C,
                TextSize=13,Font=F.BODY,ClearTextOnFocus=false,
            },w); corner(box,8)
            local bs=stroke(box,C.BORDER,1,0.5); pad(box,0,0,12,12)
            box.Focused:Connect(function()   tw(bs,FAST,{Color=C.BORDER_FOC,Transparency=0}) end)
            box.FocusLost:Connect(function()
                tw(bs,FAST,{Color=C.BORDER,Transparency=0.5})
                if cfg.Callback then cfg.Callback(box.Text) end
            end)
            local I={}
            function I:GetValue() return box.Text end
            function I:SetValue(v) box.Text=v end
            function I:Clear()    box.Text="" end
            return I
        end

        function Tab:CreateSlider(cfg)
            local flag=cfg.Flag; local mn=cfg.Min or 0; local mx=cfg.Max or 100
            local inc=cfg.Increment or 1; local sfx=cfg.Suffix or ""
            local val=math.clamp(cfg.Default or mn,mn,mx)
            local drag=false; local dc=nil

            local w=make("Frame",{
                Size=UDim2.new(1,0,0,60),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,
            },content); corner(w,8); local ws=stroke(w,C.BORDER,1,0.5)

            make("TextLabel",{
                Size=UDim2.new(1,-82,0,20),Position=UDim2.new(0,12,0,8),
                BackgroundTransparency=1,Text=cfg.Name or "Slider",TextColor3=C.TXT_B,
                TextSize=13,Font=F.BODY,TextXAlignment=Enum.TextXAlignment.Left,
            },w)
            local vL=make("TextLabel",{
                Size=UDim2.new(0,70,0,20),Position=UDim2.new(1,-80,0,8),
                BackgroundTransparency=1,TextColor3=C.ACCENT,
                TextSize=13,Font=F.HEAD,TextXAlignment=Enum.TextXAlignment.Right,
            },w)

            local tr=make("Frame",{
                Size=UDim2.new(1,-24,0,4),Position=UDim2.new(0,12,0,42),
                BackgroundColor3=C.BORDER,BackgroundTransparency=0.3,BorderSizePixel=0,
            },w); corner(tr,2)
            local fi=make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.ACCENT,BorderSizePixel=0},tr)
            corner(fi,2)
            local kn=make("Frame",{
                Size=UDim2.new(0,12,0,12),AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.TXT_A,BorderSizePixel=0,
            },tr); corner(kn,6)

            local int=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},w)

            local function setV(v,silent)
                local q=math.floor(v/inc+0.5)*inc
                local c2=math.clamp(math.floor(q*1e7+0.5)/1e7,mn,mx)
                if c2==val then return end; val=c2
                local r=(val-mn)/(mx-mn)
                tw(fi,FAST,{Size=UDim2.new(r,0,1,0)}); tw(kn,FAST,{Position=UDim2.new(r,0,0.5,0)})
                vL.Text=tostring(val)..sfx
                if flag then flags[flag]=val; if not silent then saveConfig() end end
                if not silent and cfg.Callback then cfg.Callback(val) end
            end

            int.MouseButton1Down:Connect(function()
                drag=true; tw(ws,FAST,{Color=C.BORDER_FOC,Transparency=0})
                if dc then dc:Disconnect() end
                dc=RunService.Heartbeat:Connect(function()
                    if drag then
                        local mX=UserInputService:GetMouseLocation().X
                        local tX=tr.AbsolutePosition.X; local tW=tr.AbsoluteSize.X
                        if tW>0 then setV(mn+math.clamp((mX-tX)/tW,0,1)*(mx-mn)) end
                    else dc:Disconnect();dc=nil;tw(ws,FAST,{Color=C.BORDER,Transparency=0.5});saveConfig() end
                end)
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
            end)
            int.MouseEnter:Connect(function() tw(w,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2}) end)
            int.MouseLeave:Connect(function()
                if not drag then tw(w,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF}) end
            end)

            local ir=(val-mn)/(mx-mn)
            fi.Size=UDim2.new(ir,0,1,0); kn.Position=UDim2.new(ir,0,0.5,0)
            vL.Text=tostring(val)..sfx; if flag then flags[flag]=val end

            local Sl={}; function Sl:Set(v,s) setV(v,s) end; function Sl:Get() return val end; return Sl
        end

        function Tab:CreateKeybind(cfg)
            local flag=cfg.Flag; local ck=cfg.Default or Enum.KeyCode.Unknown
            local listening=false; local hc=nil
            local bl={[Enum.KeyCode.Unknown]=true}
            if cfg.Blacklist then for _,k in ipairs(cfg.Blacklist) do bl[k]=true end end

            local w=make("Frame",{
                Size=UDim2.new(1,0,0,48),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,
            },content); corner(w,8); local ws=stroke(w,C.BORDER,1,0.5)

            make("TextLabel",{
                Size=UDim2.new(1,-112,1,0),Position=UDim2.new(0,12,0,0),
                BackgroundTransparency=1,Text=cfg.Name or "Keybind",TextColor3=C.TXT_B,
                TextSize=13,Font=F.BODY,TextXAlignment=Enum.TextXAlignment.Left,
            },w)

            local bdg=make("Frame",{
                Size=UDim2.new(0,88,0,28),Position=UDim2.new(1,-100,0.5,-14),
                BackgroundColor3=C.NAVY,BackgroundTransparency=0.35,BorderSizePixel=0,
            },w); corner(bdg,6); local bs=stroke(bdg,C.BORDER,1,0.4)

            local kLbl=make("TextLabel",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=C.TXT_B,
                TextSize=11,Font=F.HEAD,TextXAlignment=Enum.TextXAlignment.Center,
            },bdg)

            local int=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},w)

            local function kname(kc)
                if kc==Enum.KeyCode.Unknown then return "None" end
                local s2=tostring(kc); local d2=s2:find("%.[^%.]*$"); return d2 and s2:sub(d2+1) or s2
            end
            local function sk(kc,silent)
                ck=kc; kLbl.Text=kname(kc)
                if flag then flags[flag]=kname(kc); if not silent then saveConfig() end end
                if not silent and cfg.Callback then cfg.Callback(kc) end
            end
            local function stopL()
                listening=false; kLbl.Text=kname(ck)
                tw(bs,FAST,{Color=C.BORDER,Transparency=0.4}); tw(bdg,FAST,{BackgroundColor3=C.NAVY,BackgroundTransparency=0.35})
                tw(ws,FAST,{Color=C.BORDER,Transparency=0.5}); tw(w,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF})
            end
            local function startL()
                listening=true; kLbl.Text="..."
                tw(bs,FAST,{Color=C.BORDER_FOC,Transparency=0}); tw(bdg,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2})
                tw(ws,FAST,{Color=C.BORDER_FOC,Transparency=0})
            end

            int.MouseButton1Click:Connect(function() if listening then stopL() else startL() end end)
            int.MouseEnter:Connect(function() tw(w,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2}) end)
            int.MouseLeave:Connect(function()
                if not listening then tw(w,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF}) end
            end)

            UserInputService.InputBegan:Connect(function(input,gpe)
                if input.UserInputType~=Enum.UserInputType.Keyboard then return end
                if listening then
                    if not bl[input.KeyCode] then sk(input.KeyCode,false); stopL() end; return
                end
                if input.KeyCode~=ck or gpe then return end
                if cfg.HoldToInteract then
                    if hc then hc:Disconnect() end
                    hc=UserInputService.InputEnded:Connect(function(e)
                        if e.KeyCode==ck then hc:Disconnect();hc=nil;pcall(cfg.Callback,false) end
                    end); pcall(cfg.Callback,true)
                else pcall(cfg.Callback,ck) end
            end)

            sk(ck,true)
            local KB={}; function KB:Set(kc,s) sk(kc,s) end; function KB:Get() return ck end; return KB
        end

        function Tab:CreateDropdown(cfg)
            local options=cfg.Options or {}; local selected=cfg.Default or ""; local isOpen=false

            local w=make("Frame",{Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false},content)
            make("TextLabel",{
                Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,2,0,0),
                BackgroundTransparency=1,Text=cfg.Name or "Dropdown",TextColor3=C.TXT_B,
                TextSize=11,Font=F.HEAD,TextXAlignment=Enum.TextXAlignment.Left,
            },w)
            local btn=make("TextButton",{
                Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,20),
                BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF,BorderSizePixel=0,
                Text=selected~="" and selected or "Select...",
                TextColor3=selected~="" and C.TXT_A or C.TXT_C,
                TextSize=12,Font=F.BODY,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left,
            },w); corner(btn,8); local bs=stroke(btn,C.BORDER,1,0.5); pad(btn,0,0,12,30)

            local arrow=make("TextLabel",{
                Size=UDim2.new(0,24,1,0),Position=UDim2.new(1,-26,0,0),
                BackgroundTransparency=1,Text="▾",TextColor3=C.TXT_C,TextSize=12,Font=F.HEAD,
            },btn)

            local dl=make("Frame",{
                BackgroundColor3=C.DARK,BackgroundTransparency=0.18,
                BorderSizePixel=0,Visible=false,ZIndex=60,
            },sg); corner(dl,8); stroke(dl,C.BORDER_FOC,1,0.3)

            local dsf=make("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
                ScrollBarThickness=2,ScrollBarImageColor3=C.BORDER,
                CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=61,
            },dl)
            make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)},dsf)
            pad(dsf,4,4,0,0)

            local DD={}
            local function close2()
                if not isOpen then return end; isOpen=false; dl.Visible=false
                tw(bs,FAST,{Color=C.BORDER,Transparency=0.5})
                tw(btn,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF})
                arrow.Text="▾"; unregisterDropdown(close2)
            end
            local function refresh2()
                for _,ch in ipairs(dsf:GetChildren()) do
                    if ch:IsA("TextButton") or ch:IsA("TextLabel") then ch:Destroy() end
                end
                if #options==0 then
                    make("TextLabel",{
                        Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,
                        Text="  (empty)",TextColor3=C.TXT_C,TextSize=11,Font=F.LIGHT,
                        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=62,
                    },dsf)
                else
                    for i,opt in ipairs(options) do
                        local sel=opt==selected
                        local item=make("TextButton",{
                            Size=UDim2.new(1,0,0,36),
                            BackgroundColor3=C.DARK,BackgroundTransparency=0.12,BorderSizePixel=0,
                            Text="  "..opt,TextColor3=sel and C.TXT_A or C.TXT_B,
                            TextSize=12,Font=sel and F.HEAD or F.BODY,
                            AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left,
                            LayoutOrder=i,ZIndex=62,
                        },dsf)
                        if sel then
                            local bar=make("Frame",{
                                Size=UDim2.new(0,2,0,18),Position=UDim2.new(0,0,0.5,-9),
                                BackgroundColor3=C.ACCENT,BorderSizePixel=0,ZIndex=63,
                            },item); corner(bar,1)
                        end
                        item.MouseEnter:Connect(function()
                            tw(item,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.1,TextColor3=C.TXT_A})
                        end)
                        item.MouseLeave:Connect(function()
                            tw(item,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=0.12,TextColor3=sel and C.TXT_A or C.TXT_B})
                        end)
                        item.MouseButton1Click:Connect(function()
                            selected=opt; btn.Text=opt; btn.TextColor3=C.TXT_A; close2()
                            if cfg.Callback then cfg.Callback(opt) end
                        end)
                    end
                end
                dl.Size=UDim2.new(0,btn.AbsoluteSize.X,0,math.min(math.max(#options,1)*36+8,200))
            end

            btn.MouseButton1Click:Connect(function()
                if isOpen then close2() return end
                closeAllDropdowns(); isOpen=true; registerDropdown(close2); refresh2()
                local ap=btn.AbsolutePosition; local as=btn.AbsoluteSize
                dl.Size=UDim2.new(0,as.X,0,math.min(math.max(#options,1)*36+8,200))
                dl.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4); dl.Visible=true
                tw(bs,FAST,{Color=C.BORDER_FOC,Transparency=0})
                tw(btn,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2})
                arrow.Text="▴"
            end)
            btn.MouseEnter:Connect(function() tw(btn,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2}) end)
            btn.MouseLeave:Connect(function()
                if not isOpen then tw(btn,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF}) end
            end)

            function DD:SetOptions(o)
                options=o; local ok2=false
                for _,v in ipairs(options) do if v==selected then ok2=true break end end
                if not ok2 then selected=""; btn.Text="Select..."; btn.TextColor3=C.TXT_C end
                if isOpen then refresh2() end
            end
            function DD:AddOption(o)
                for _,v in ipairs(options) do if v==o then return end end
                table.insert(options,o); if isOpen then refresh2() end
            end
            function DD:RemoveOption(o)
                for i,v in ipairs(options) do
                    if v==o then
                        table.remove(options,i)
                        if selected==o then selected="";btn.Text="Select...";btn.TextColor3=C.TXT_C end
                        if isOpen then refresh2() end; return
                    end
                end
            end
            function DD:GetSelected() return selected end
            function DD:GetOptions()  return options  end
            function DD:SetSelected(v)
                selected=v; btn.Text=v~="" and v or "Select..."
                btn.TextColor3=v~="" and C.TXT_A or C.TXT_C
            end
            function DD:Close() close2() end
            return DD
        end

        function Tab:CreateColorPicker(cfg)
            local flag=cfg.Flag; local color=cfg.Default or Color3.fromRGB(168,207,255)
            local h,s,v=color:ToHSV(); local isOpen=false

            local row=make("TextButton",{
                Size=UDim2.new(1,0,0,48),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,Text="",AutoButtonColor=false,
            },content); corner(row,8); local rs=stroke(row,C.BORDER,1,0.5)

            make("TextLabel",{
                Size=UDim2.new(1,-72,1,0),Position=UDim2.new(0,12,0,0),
                BackgroundTransparency=1,Text=cfg.Name or "Color",TextColor3=C.TXT_B,
                TextSize=13,Font=F.BODY,TextXAlignment=Enum.TextXAlignment.Left,
            },row)
            local sw=make("Frame",{
                Size=UDim2.new(0,28,0,16),Position=UDim2.new(1,-50,0.5,-8),
                BackgroundColor3=color,BorderSizePixel=0,
            },row); corner(sw,5); stroke(sw,C.BORDER,1,0.4)
            make("TextLabel",{
                Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-18,0,0),
                BackgroundTransparency=1,Text="▾",TextColor3=C.TXT_C,TextSize=12,Font=F.HEAD,
            },row)

            local panel=make("Frame",{
                Size=UDim2.new(1,0,0,174),BackgroundColor3=C.DARK,
                BackgroundTransparency=T.SURF,BorderSizePixel=0,Visible=false,
            },content); corner(panel,8); stroke(panel,C.BORDER,1,0.5); pad(panel,9,9,9,9)

            local svB=make("Frame",{Size=UDim2.new(1,-28,1,-38),BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0},panel)
            corner(svB,5)
            make("UIGradient",{
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}),
            },svB)
            local bo=make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0},svB)
            corner(bo,5)
            make("UIGradient",{
                Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),Rotation=90,
            },bo)
            local svK=make("Frame",{
                Size=UDim2.new(0,12,0,12),AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(s,0,1-v,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=5,
            },svB); corner(svK,7); stroke(svK,Color3.new(0,0,0),1)

            local hB=make("Frame",{Size=UDim2.new(0,14,1,-38),Position=UDim2.new(1,-14,0,0),BorderSizePixel=0},panel)
            corner(hB,3); stroke(hB,C.BORDER,1,0.4)
            make("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,1,1)),
                    ColorSequenceKeypoint.new(0.17,Color3.fromHSV(0.17,1,1)),
                    ColorSequenceKeypoint.new(0.33,Color3.fromHSV(0.33,1,1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                    ColorSequenceKeypoint.new(0.67,Color3.fromHSV(0.67,1,1)),
                    ColorSequenceKeypoint.new(0.83,Color3.fromHSV(0.83,1,1)),
                    ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,1,1)),
                }),Rotation=90,
            },hB)
            local hK=make("Frame",{
                Size=UDim2.new(1,4,0,4),AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(0.5,0,h,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=5,
            },hB); corner(hK,2); stroke(hK,Color3.new(0,0,0),1)

            local hx=make("TextBox",{
                Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,1,-26),
                BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF,BorderSizePixel=0,
                TextColor3=C.TXT_A,PlaceholderColor3=C.TXT_C,PlaceholderText="#RRGGBB",
                TextSize=12,Font=F.MONO,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Center,
            },panel); corner(hx,5); local hbs=stroke(hx,C.BORDER,1,0.5)

            local function toHex(c3)
                return string.format("#%02X%02X%02X",
                    math.floor(c3.R*255+.5),math.floor(c3.G*255+.5),math.floor(c3.B*255+.5))
            end
            local function updAll()
                local col=Color3.fromHSV(h,s,v); color=col
                sw.BackgroundColor3=col; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                svK.Position=UDim2.new(s,0,1-v,0); hK.Position=UDim2.new(0.5,0,h,0)
                hx.Text=toHex(col)
                if flag then flags[flag]={R=col.R,G=col.G,B=col.B} end
                if cfg.Callback then pcall(cfg.Callback,col) end
            end

            local svD=false
            local sI=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=4},svB)
            sI.MouseButton1Down:Connect(function() svD=true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then svD=false end
            end)
            RunService.Heartbeat:Connect(function()
                if not svD then return end
                local m=UserInputService:GetMouseLocation()
                local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                s=math.clamp((m.X-a.X)/sz.X,0,1); v=1-math.clamp((m.Y-a.Y)/sz.Y,0,1); updAll()
            end)
            local hD=false
            local hI=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=4},hB)
            hI.MouseButton1Down:Connect(function() hD=true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then hD=false end
            end)
            RunService.Heartbeat:Connect(function()
                if not hD then return end
                local m=UserInputService:GetMouseLocation()
                local a=hB.AbsolutePosition; local sz=hB.AbsoluteSize
                h=math.clamp((m.Y-a.Y)/sz.Y,0,1); updAll()
            end)
            hx.Focused:Connect(function()  tw(hbs,FAST,{Color=C.BORDER_FOC,Transparency=0}) end)
            hx.FocusLost:Connect(function()
                tw(hbs,FAST,{Color=C.BORDER,Transparency=0.5})
                local t2=hx.Text:gsub("#","")
                if #t2==6 then
                    local r2=tonumber(t2:sub(1,2),16)
                    local g2=tonumber(t2:sub(3,4),16)
                    local b2=tonumber(t2:sub(5,6),16)
                    if r2 and g2 and b2 then h,s,v=Color3.fromRGB(r2,g2,b2):ToHSV(); updAll() end
                end
            end)
            row.MouseButton1Click:Connect(function()
                isOpen=not isOpen; panel.Visible=isOpen
                local chv=row:FindFirstChild("TextLabel",true)
                if chv and chv.Text~=cfg.Name and chv.Text~="" then chv.Text=isOpen and "▴" or "▾" end
                if isOpen then
                    updAll()
                    tw(rs,FAST,{Color=C.BORDER_FOC,Transparency=0})
                    tw(row,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2})
                else
                    tw(rs,FAST,{Color=C.BORDER,Transparency=0.5})
                    tw(row,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF})
                end
            end)
            row.MouseEnter:Connect(function() tw(row,FAST,{BackgroundColor3=C.HOV,BackgroundTransparency=0.2}) end)
            row.MouseLeave:Connect(function()
                if not isOpen then tw(row,FAST,{BackgroundColor3=C.DARK,BackgroundTransparency=T.SURF}) end
            end)
            updAll()
            local CP={}
            function CP:Set(c3,silent)
                color=c3; h,s,v=c3:ToHSV(); updAll()
                if not silent and cfg.Callback then pcall(cfg.Callback,c3) end
            end
            function CP:Get() return color end
            return CP
        end

        return Tab
    end

    -- ── Window helpers ─────────────────────────────────────────
    function Window:GetFlag(flag)    return flags[flag] end
    function Window:SetToggle(flag,value)
        local setter=toggleSetters[flag]; if setter then setter(value,false) end
    end
    function Window:LoadConfiguration()
        local saved=loadConfig()
        for flag,val in pairs(saved) do
            local setter=toggleSetters[flag]
            if setter and type(val)=="boolean" then setter(val,true) end
        end
    end

    return Window
end

return DevNgg
