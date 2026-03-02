--[[
═══════════════════════════════════════════════════════════════
    DevN.gg Loader System — v1.0
    Modular, themeable, animated loading screen
    
    ARCHITECTURE:
    ┌─────────────────────────────────────────────────────┐
    │  Loader (Main Module)                               │
    │  ├── Theme       — color/font/radius tokens         │
    │  ├── Animator    — all tween helpers                │
    │  ├── Builder     — creates all UI instances         │
    │  └── Runner      — executes steps + cleanup         │
    └─────────────────────────────────────────────────────┘
    
    USAGE:
        local Loader = require(path.to.Loader)
        Loader:Start({
            Title    = "My Script",
            Subtitle = "by DevN",
            Steps    = {
                { Label = "Initializing...",    Duration = 0.8 },
                { Label = "Loading modules...", Duration = 1.2 },
                { Label = "Applying patches...",Duration = 0.6 },
                { Label = "Ready!",             Duration = 0.4 },
            },
            Theme    = "Dark",        -- "Dark" | "Light" | custom table
            OnDone   = function()
                -- your script starts here
            end,
        })
        
    DESIGN DECISIONS:
    • Single-file ModuleScript — no remote dependencies, works offline
    • Theme system uses token tables, not hardcoded colors anywhere
    • All UI built programmatically — no rbxmx, no Studio setup needed
    • Steps are plain data tables — easy to add/remove/reorder
    • Cleanup is guaranteed via pcall-wrapped Destroy, even on errors
    • Animator module is pure functions — stateless, easily testable
    • Builder returns a "frame bag" — named references, no searching
═══════════════════════════════════════════════════════════════
--]]

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════
-- MODULE
-- ═══════════════════════════════════════════════════════════
local Loader = {}
Loader.__index = Loader

-- ─────────────────────────────────────────────────────────
-- THEME SYSTEM
-- All color/font/size values live here — nothing hardcoded
-- in Builder or Animator. Swap the whole theme in one line.
-- ─────────────────────────────────────────────────────────
local Themes = {}

Themes.Dark = {
    -- Backgrounds
    Backdrop      = Color3.fromRGB(0,   0,   0),    -- fullscreen dim
    BackdropAlpha = 0.55,
    Card          = Color3.fromRGB(10,  10,  10),
    CardBorder    = Color3.fromRGB(30,  30,  30),
    BarBg         = Color3.fromRGB(22,  22,  22),
    BarFill       = Color3.fromRGB(220, 220, 220),
    BarFillDone   = Color3.fromRGB(120, 255, 160),  -- green flash on complete

    -- Text
    Title         = Color3.fromRGB(255, 255, 255),
    Subtitle      = Color3.fromRGB(100, 100, 100),
    StepLabel     = Color3.fromRGB(140, 140, 140),
    StepDone      = Color3.fromRGB(200, 200, 200),
    Version       = Color3.fromRGB(55,  55,  55),

    -- Misc
    Dot           = Color3.fromRGB(60,  60,  60),
    DotActive     = Color3.fromRGB(220, 220, 220),
    Shadow        = Color3.fromRGB(0,   0,   0),

    -- Typography
    FontTitle     = Enum.Font.GothamBold,
    FontSub       = Enum.Font.GothamSemibold,
    FontBody      = Enum.Font.Gotham,

    -- Shape
    CardRadius    = 14,
    BarRadius     = 4,
    DotRadius     = 6,

    -- Card size
    CardW         = 420,
    CardH         = 210,
}

Themes.Light = {
    Backdrop      = Color3.fromRGB(180, 180, 190),
    BackdropAlpha = 0.45,
    Card          = Color3.fromRGB(252, 252, 252),
    CardBorder    = Color3.fromRGB(210, 210, 210),
    BarBg         = Color3.fromRGB(225, 225, 225),
    BarFill       = Color3.fromRGB(30,  30,  30),
    BarFillDone   = Color3.fromRGB(40,  180, 100),

    Title         = Color3.fromRGB(15,  15,  15),
    Subtitle      = Color3.fromRGB(130, 130, 130),
    StepLabel     = Color3.fromRGB(110, 110, 110),
    StepDone      = Color3.fromRGB(30,  30,  30),
    Version       = Color3.fromRGB(190, 190, 190),

    Dot           = Color3.fromRGB(210, 210, 210),
    DotActive     = Color3.fromRGB(30,  30,  30),
    Shadow        = Color3.fromRGB(0,   0,   0),

    FontTitle     = Enum.Font.GothamBold,
    FontSub       = Enum.Font.GothamSemibold,
    FontBody      = Enum.Font.Gotham,

    CardRadius    = 14,
    BarRadius     = 4,
    DotRadius     = 6,

    CardW         = 420,
    CardH         = 210,
}

-- Resolve theme: string name OR custom table OR fallback to Dark
local function resolveTheme(input)
    if type(input) == "table" then
        -- Merge custom overrides onto Dark base so partial tables work
        local merged = {}
        for k, v in pairs(Themes.Dark) do merged[k] = v end
        for k, v in pairs(input)       do merged[k] = v end
        return merged
    end
    return Themes[input] or Themes.Dark
end

-- ─────────────────────────────────────────────────────────
-- ANIMATOR
-- Pure tween helpers — no state, just functions.
-- Everything goes through here so easing is consistent.
-- ─────────────────────────────────────────────────────────
local Animator = {}

local EASE_OUT  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_IN   = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local EASE_SLOW = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local LINEAR    = function(t) return TweenInfo.new(t, Enum.EasingStyle.Linear) end

function Animator.tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Fade in an object (BackgroundTransparency or ImageTransparency)
function Animator.fadeIn(obj, duration, targetAlpha)
    targetAlpha = targetAlpha or 0
    return Animator.tween(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint), {
        BackgroundTransparency = targetAlpha,
    })
end

function Animator.fadeOut(obj, duration, targetAlpha)
    targetAlpha = targetAlpha or 1
    return Animator.tween(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = targetAlpha,
    })
end

function Animator.fadeTextIn(obj, duration)
    obj.TextTransparency = 1
    return Animator.tween(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
    })
end

function Animator.fadeTextOut(obj, duration)
    return Animator.tween(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint), {
        TextTransparency = 1,
    })
end

-- Slide card in from bottom with fade
function Animator.slideIn(card, duration)
    card.Position = UDim2.new(0.5, -card.Size.X.Offset/2, 0.5, 30)
    card.BackgroundTransparency = 1
    Animator.tween(card, TweenInfo.new(duration or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position               = UDim2.new(0.5, -card.Size.X.Offset/2, 0.5, -card.Size.Y.Offset/2),
        BackgroundTransparency = 0,
    })
end

-- Slide card out upward with fade
function Animator.slideOut(card, duration)
    return Animator.tween(card, TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position               = UDim2.new(0.5, -card.Size.X.Offset/2, 0.5, -card.Size.Y.Offset/2 - 20),
        BackgroundTransparency = 1,
    })
end

-- Animate progress bar fill from current to target (0–1)
function Animator.setProgress(fillBar, target, duration)
    return Animator.tween(fillBar, LINEAR(duration or 0.4), {
        Size = UDim2.new(target, 0, 1, 0),
    })
end

-- Pulse dot to active color then back
function Animator.pulseDot(dot, activeColor, restColor)
    Animator.tween(dot, EASE_FAST, { BackgroundColor3 = activeColor })
    task.delay(0.18, function()
        Animator.tween(dot, EASE_SLOW, { BackgroundColor3 = restColor })
    end)
end

-- ─────────────────────────────────────────────────────────
-- BUILDER
-- Creates the entire UI tree programmatically.
-- Returns a "bag" table with named references to every
-- element that Runner needs to update.
-- ─────────────────────────────────────────────────────────
local Builder = {}

local function inst(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function uiCorner(parent, radius)
    inst("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function uiStroke(parent, color, thickness)
    inst("UIStroke", {
        Color     = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

function Builder.create(T)
    -- ScreenGui
    local gui = inst("ScreenGui", {
        Name             = "DevNggLoader",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 9999,
        IgnoreGuiInset   = true,
    })
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then
        pcall(function() gui.Parent = gethui() end)
    end
    if not gui.Parent then
        gui.Parent = PlayerGui
    end

    -- Backdrop (fullscreen dim)
    local backdrop = inst("Frame", {
        Name                   = "Backdrop",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3       = T.Backdrop,
        BackgroundTransparency = 1,   -- starts invisible, fades in
        BorderSizePixel        = 0,
        ZIndex                 = 1,
    }, gui)

    -- Shadow (slightly larger blurred card behind)
    local shadow = inst("ImageLabel", {
        Name                   = "Shadow",
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.new(0, T.CardW + 60, 0, T.CardH + 60),
        Position               = UDim2.new(0.5, 0, 0.5, 6),
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://6014054385",
        ImageColor3            = T.Shadow,
        ImageTransparency      = 0.5,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49, 49, 450, 450),
        ZIndex                 = 2,
    }, gui)

    -- Card
    local card = inst("Frame", {
        Name                   = "Card",
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.new(0, T.CardW, 0, T.CardH),
        Position               = UDim2.new(0.5, -T.CardW/2, 0.5, -T.CardH/2 + 30),
        BackgroundColor3       = T.Card,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 3,
    }, gui)
    uiCorner(card, T.CardRadius)
    uiStroke(card, T.CardBorder, 1)

    -- Left accent bar
    local accent = inst("Frame", {
        Name            = "Accent",
        Size            = UDim2.new(0, 2, 0, 36),
        Position        = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = T.DotActive,
        BorderSizePixel = 0,
        ZIndex          = 4,
    }, card)
    uiCorner(accent, 2)

    -- Title
    local title = inst("TextLabel", {
        Name                   = "Title",
        Size                   = UDim2.new(1, -36, 0, 26),
        Position               = UDim2.new(0, 18, 0, 22),
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = T.Title,
        TextTransparency       = 1,
        TextSize               = 20,
        Font                   = T.FontTitle,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
    }, card)

    -- Subtitle
    local subtitle = inst("TextLabel", {
        Name                   = "Subtitle",
        Size                   = UDim2.new(1, -36, 0, 16),
        Position               = UDim2.new(0, 18, 0, 50),
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = T.Subtitle,
        TextTransparency       = 1,
        TextSize               = 12,
        Font                   = T.FontSub,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
    }, card)

    -- Divider
    inst("Frame", {
        Name            = "Divider",
        Size            = UDim2.new(1, -36, 0, 1),
        Position        = UDim2.new(0, 18, 0, 80),
        BackgroundColor3 = T.CardBorder,
        BorderSizePixel = 0,
        ZIndex          = 4,
    }, card)

    -- Step label
    local stepLabel = inst("TextLabel", {
        Name                   = "StepLabel",
        Size                   = UDim2.new(1, -100, 0, 16),
        Position               = UDim2.new(0, 18, 0, 96),
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = T.StepLabel,
        TextTransparency       = 1,
        TextSize               = 11,
        Font                   = T.FontBody,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
    }, card)

    -- Step counter (e.g. "2 / 4")
    local stepCounter = inst("TextLabel", {
        Name                   = "StepCounter",
        Size                   = UDim2.new(0, 60, 0, 16),
        Position               = UDim2.new(1, -78, 0, 96),
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = T.Version,
        TextTransparency       = 1,
        TextSize               = 10,
        Font                   = T.FontBody,
        TextXAlignment         = Enum.TextXAlignment.Right,
        ZIndex                 = 4,
    }, card)

    -- Progress bar background
    local barBg = inst("Frame", {
        Name            = "BarBg",
        Size            = UDim2.new(1, -36, 0, 4),
        Position        = UDim2.new(0, 18, 0, 122),
        BackgroundColor3 = T.BarBg,
        BorderSizePixel = 0,
        ZIndex          = 4,
    }, card)
    uiCorner(barBg, T.BarRadius)

    -- Progress bar fill
    local barFill = inst("Frame", {
        Name            = "BarFill",
        Size            = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.BarFill,
        BorderSizePixel = 0,
        ZIndex          = 5,
        ClipsDescendants = false,
    }, barBg)
    uiCorner(barFill, T.BarRadius)

    -- Dots row
    local dotsFrame = inst("Frame", {
        Name                   = "DotsFrame",
        Size                   = UDim2.new(1, -36, 0, 12),
        Position               = UDim2.new(0, 18, 0, 140),
        BackgroundTransparency = 1,
        ZIndex                 = 4,
    }, card)

    local dotsLayout = inst("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 6),
    }, dotsFrame)

    -- Version / watermark
    local version = inst("TextLabel", {
        Name                   = "Version",
        Size                   = UDim2.new(1, -36, 0, 14),
        Position               = UDim2.new(0, 18, 1, -22),
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = T.Version,
        TextTransparency       = 1,
        TextSize               = 10,
        Font                   = T.FontBody,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 4,
    }, card)

    return {
        gui        = gui,
        backdrop   = backdrop,
        shadow     = shadow,
        card       = card,
        accent     = accent,
        title      = title,
        subtitle   = subtitle,
        stepLabel  = stepLabel,
        stepCounter= stepCounter,
        barBg      = barBg,
        barFill    = barFill,
        dotsFrame  = dotsFrame,
        version    = version,
        T          = T,
    }
end

-- Build dot indicators (one per step)
function Builder.buildDots(bag, count)
    local T    = bag.T
    local dots = {}
    for i = 1, count do
        local dot = inst("Frame", {
            Name            = "Dot_" .. i,
            Size            = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = T.Dot,
            BorderSizePixel = 0,
            LayoutOrder     = i,
            ZIndex          = 5,
        }, bag.dotsFrame)
        uiCorner(dot, T.DotRadius)
        dots[i] = dot
    end
    return dots
end

-- ─────────────────────────────────────────────────────────
-- RUNNER
-- Orchestrates the loading sequence:
--   1. Build UI
--   2. Animate intro
--   3. Loop through steps
--   4. Complete animation
--   5. Destroy everything
-- ─────────────────────────────────────────────────────────
local Runner = {}

-- Safely destroy the GUI — wrapped in pcall so errors
-- during teardown can't break the caller's OnDone callback
local function cleanup(gui)
    task.delay(0.1, function()
        pcall(function() gui:Destroy() end)
    end)
end

-- Cross-fade step label text smoothly
local function transitionLabel(label, newText, T)
    Animator.tween(label, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
        TextTransparency = 1,
        TextColor3       = T.StepLabel,
    })
    task.wait(0.15)
    label.Text = newText
    Animator.tween(label, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        TextColor3       = T.StepDone,
    })
end

function Runner.run(settings, bag, dots)
    local T     = bag.T
    local steps = settings.Steps or {}
    local total = #steps

    -- ── INTRO PHASE ──────────────────────────────────────
    -- Fade in backdrop
    Animator.fadeIn(bag.backdrop, 0.4, T.BackdropAlpha)

    -- Slide card in
    task.wait(0.1)
    Animator.slideIn(bag.card, 0.45)

    -- Fade in shadow
    Animator.tween(bag.shadow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
        ImageTransparency = 0.3,
    })

    task.wait(0.3)

    -- Reveal title + subtitle
    bag.title.Text    = settings.Title    or "Loading"
    bag.subtitle.Text = settings.Subtitle or ""
    bag.version.Text  = settings.Version  or ""

    Animator.fadeTextIn(bag.title,    0.3)
    task.wait(0.08)
    Animator.fadeTextIn(bag.subtitle, 0.25)
    task.wait(0.08)
    Animator.fadeTextIn(bag.version,  0.2)
    Animator.tween(bag.stepCounter, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
    })

    task.wait(0.35)

    -- ── STEP PHASE ───────────────────────────────────────
    for i, step in ipairs(steps) do
        local progress = i / total
        local duration = step.Duration or 0.8

        -- Update counter
        bag.stepCounter.Text = i .. " / " .. total

        -- Pulse dot
        if dots[i] then
            Animator.pulseDot(dots[i], T.DotActive, T.Dot)
        end

        -- Cross-fade step label
        transitionLabel(bag.stepLabel, step.Label or ("Step " .. i), T)

        -- Advance progress bar
        Animator.setProgress(bag.barFill, progress, duration * 0.7)

        -- Run optional step callback (e.g. actually load something)
        if step.Task then
            pcall(step.Task)
        end

        task.wait(duration)

        -- Mark dot as done
        if dots[i] then
            Animator.tween(dots[i], TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                BackgroundColor3 = T.DotActive,
                Size             = UDim2.new(0, 8, 0, 8),
            })
        end
    end

    -- ── COMPLETE PHASE ───────────────────────────────────
    -- Fill bar to 100% and flash green
    Animator.setProgress(bag.barFill, 1, 0.3)
    task.wait(0.1)
    Animator.tween(bag.barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundColor3 = T.BarFillDone,
    })

    -- Update label to done state
    transitionLabel(bag.stepLabel, settings.DoneLabel or "Done!", T)
    bag.stepCounter.Text = total .. " / " .. total

    task.wait(0.5)

    -- ── OUTRO PHASE ──────────────────────────────────────
    -- Fade out text
    Animator.fadeTextOut(bag.title,    0.2)
    Animator.fadeTextOut(bag.subtitle, 0.15)
    Animator.fadeTextOut(bag.stepLabel,0.15)
    task.wait(0.08)
    Animator.fadeTextOut(bag.stepCounter, 0.1)
    Animator.fadeTextOut(bag.version,     0.1)

    task.wait(0.25)

    -- Slide card out
    local slideOut = Animator.slideOut(bag.card, 0.35)
    Animator.fadeOut(bag.backdrop, 0.35, 1)
    Animator.tween(bag.shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        ImageTransparency = 1,
    })

    task.wait(0.4)

    -- ── CLEANUP ──────────────────────────────────────────
    cleanup(bag.gui)

    task.wait(0.15)

    -- Fire OnDone — caller's script starts here
    if settings.OnDone then
        pcall(settings.OnDone)
    end
end

-- ═══════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════

--[[
    Loader:Start(settings)
    
    settings = {
        Title     = "My Script",            -- Main heading
        Subtitle  = "by DevN",              -- Sub-heading
        Version   = "v1.0",                 -- Small watermark
        DoneLabel = "Ready!",               -- Final step text
        Theme     = "Dark",                 -- "Dark" | "Light" | table
        
        Steps = {
            { Label = "Initializing...",    Duration = 0.8  },
            { Label = "Loading modules...", Duration = 1.0  },
            { Label = "Applying hooks...",  Duration = 0.6,
              Task = function()
                  -- optional: run real work here during this step
                  -- e.g. require a module, set up connections
              end
            },
            { Label = "Ready!",             Duration = 0.3  },
        },
        
        OnDone = function()
            -- everything after this point runs when loader is gone
        end,
    }
--]]
function Loader:Start(settings)
    assert(type(settings) == "table", "Loader:Start() requires a settings table")

    local T   = resolveTheme(settings.Theme)
    local bag  = Builder.create(T)
    local dots = Builder.buildDots(bag, #(settings.Steps or {}))

    -- Run on a separate thread so :Start() returns immediately
    -- and doesn't yield the caller's script
    task.spawn(function()
        Runner.run(settings, bag, dots)
    end)
end

return Loader
