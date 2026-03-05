loadstring('function LPH_NO_VIRTUALIZE(f) return f end;')()

-- Services
local cloneref = cloneref or function(s) return s end
local TweenService = cloneref(game:GetService('TweenService'))
local UserInput    = cloneref(game:GetService('UserInputService'))
local Players      = cloneref(game:GetService('Players'))
local CoreGui      = cloneref(game:GetService('CoreGui'))

-- Utilities
local setclip = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
local getgenv = getgenv or function() return shared end

-- Config (EDIT THESE)
local DISCORD   = 'discord.gg/NUvUBqpY'
local KEY_URL   = 'https://your-key-link.com/getkey' -- << add your key link here
local LOGO_URL  = 'https://your-logo-url.com/logo.png' -- << add your logo here
local LOGO_FILE = 'DevNGG.png'
local KEY_FILE  = 'DevNGG_Key.txt'
local HUB_NAME  = 'DevN.GG'

-- Luarmor setup
local luarmor = loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()

-- Game ID -> Script ID map (add your games here)
local scriptIds = {
    -- [GameId] = 'script_id_here',
}

local PROJECT_ID = '4d4ed9c55a9a9940554f89cadf145d52'
local scriptId   = '2042ba1c01e9a8fea6fca11f79fc1346'

-- Key save/load helpers
local function getSavedKey()
    if not isfile then return nil end
    local ok, result = pcall(function()
        if isfile(KEY_FILE) then return readfile(KEY_FILE) end
        return nil
    end)
    if ok and result and #result > 5 then return result end
    return nil
end

local function saveKey(key)
    if not writefile then return end
    pcall(function() writefile(KEY_FILE, key) end)
end

local function deleteSavedKey()
    if not delfile then return end
    pcall(function()
        if isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end
    end)
end

-- Auto authenticate on launch
local function tryAutoAuth()
    local envKey   = script_key or _G.script_key or _G['%USER_KEY%'] or getgenv().script_key or _G.LuarmorKey or _G.luarmor_key
    local savedKey = getSavedKey()

    if type(envKey) ~= 'string' then envKey = nil end
    if type(savedKey) ~= 'string' then savedKey = nil end
    if envKey and (envKey:find('%%') or #envKey < 10) then envKey = nil end

    local key = envKey or savedKey
    if not key or #key < 10 then return false end

    luarmor.script_id = scriptId
    local ok, result = pcall(function() return luarmor.check_key(key) end)
    if not ok or not result then return false end

    if result.code == 'KEY_VALID' then
        getgenv().script_key = key
        saveKey(key)
        luarmor.load_script()
        return true
    else
        deleteSavedKey()
        return false
    end
end

if tryAutoAuth() then return end

-- Random name generator (anti-detection)
local function randomName(length)
    local chars  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = ''
    for i = 1, length or 12 do
        local index = math.random(1, #chars)
        result = result .. chars:sub(index, index)
    end
    return result
end

-- Load logo
local logoAsset
if writefile and isfile and getcustomasset then
    pcall(function()
        if not isfile(LOGO_FILE) then
            writefile(LOGO_FILE, game:HttpGet(LOGO_URL))
        end
        logoAsset = getcustomasset(LOGO_FILE)
    end)
end

-- GUI setup
local screenGui = Instance.new('ScreenGui')
screenGui.Name = randomName(16)
if protect_gui then protect_gui(screenGui) end
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Main frame
local frame = Instance.new('Frame')
frame.Name = randomName(12)
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
frame.BackgroundTransparency = 0.15
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 400, 0, 240)
Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 12)

local frameStroke = Instance.new('UIStroke')
frameStroke.Color = Color3.fromRGB(70, 50, 120)
frameStroke.Thickness = 1.5
frameStroke.Transparency = 0.5
frameStroke.Parent = frame

-- Shadow layers
local shadowContainer = Instance.new('Frame')
shadowContainer.Name = randomName(8)
shadowContainer.Parent = frame
shadowContainer.BackgroundTransparency = 1
shadowContainer.Size = UDim2.new(1, 0, 1, 0)
shadowContainer.ZIndex = 0

for i = 1, 3 do
    local shadow = Instance.new('Frame')
    shadow.Name = randomName(6)
    shadow.Parent = shadowContainer
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.88 + (i * 0.03)
    shadow.Position = UDim2.new(0.5, 0, 0.5, i * 2)
    shadow.Size = UDim2.new(1, i * 4, 1, i * 4)
    shadow.ZIndex = 0
    Instance.new('UICorner', shadow).CornerRadius = UDim.new(0, 12 + i)
end

-- Logo
local logo = Instance.new('ImageLabel')
logo.Name = randomName(8)
logo.Parent = frame
logo.BackgroundTransparency = 1
logo.Position = UDim2.new(0, 18, 0, 11)
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Image = logoAsset or ''
logo.ScaleType = Enum.ScaleType.Fit

-- Title
local title = Instance.new('TextLabel')
title.Name = randomName(8)
title.Parent = frame
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 56, 0, 14)
title.Size = UDim2.new(0, 200, 0, 26)
title.Font = Enum.Font.GothamBlack
title.Text = HUB_NAME
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new('TextButton')
closeBtn.Name = randomName(8)
closeBtn.Parent = frame
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(1, -32, 0, 10)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = 'X'
closeBtn.TextColor3 = Color3.fromRGB(120, 120, 140)
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false

-- Subtitle
local subtitle = Instance.new('TextLabel')
subtitle.Name = randomName(8)
subtitle.Parent = frame
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 20, 0, 48)
subtitle.Size = UDim2.new(1, -40, 0, 26)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = 'Having trouble getting a key or checking your key?\nJoin our Discord server for assistance!'
subtitle.TextColor3 = Color3.fromRGB(120, 120, 140)
subtitle.TextSize = 11
subtitle.TextWrapped = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.LineHeight = 1.2

-- Key input container
local inputFrame = Instance.new('Frame')
inputFrame.Name = randomName(8)
inputFrame.Parent = frame
inputFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
inputFrame.Position = UDim2.new(0, 20, 0, 76)
inputFrame.Size = UDim2.new(1, -40, 0, 38)
Instance.new('UICorner', inputFrame).CornerRadius = UDim.new(0, 8)

local inputStroke = Instance.new('UIStroke')
inputStroke.Color = Color3.fromRGB(50, 50, 65)
inputStroke.Parent = inputFrame

-- Key input box
local keyInput = Instance.new('TextBox')
keyInput.Name = randomName(8)
keyInput.Parent = inputFrame
keyInput.BackgroundTransparency = 1
keyInput.Position = UDim2.new(0, 12, 0, 0)
keyInput.Size = UDim2.new(1, -24, 1, 0)
keyInput.Font = Enum.Font.Gotham
keyInput.PlaceholderColor3 = Color3.fromRGB(85, 85, 105)
keyInput.PlaceholderText = 'Enter your key here...'
keyInput.Text = ''
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.TextSize = 13
keyInput.TextXAlignment = Enum.TextXAlignment.Left

-- Check Key button
local checkBtn = Instance.new('TextButton')
checkBtn.Name = randomName(8)
checkBtn.Parent = frame
checkBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
checkBtn.BackgroundTransparency = 0.4
checkBtn.Position = UDim2.new(0, 20, 0, 122)
checkBtn.Size = UDim2.new(1, -40, 0, 36)
checkBtn.Font = Enum.Font.GothamBold
checkBtn.Text = 'Check Key'
checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
checkBtn.TextSize = 13
checkBtn.AutoButtonColor = false
Instance.new('UICorner', checkBtn).CornerRadius = UDim.new(0, 8)

local checkStroke = Instance.new('UIStroke')
checkStroke.Color = Color3.fromRGB(140, 100, 220)
checkStroke.Transparency = 0.3
checkStroke.Parent = checkBtn

-- Status label
local statusLabel = Instance.new('TextLabel')
statusLabel.Name = randomName(8)
statusLabel.Parent = frame
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 0, 0, 160)
statusLabel.Size = UDim2.new(1, 0, 0, 14)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.Text = ''
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 10

-- Support button
local supportBtn = Instance.new('TextButton')
supportBtn.Name = randomName(8)
supportBtn.Parent = frame
supportBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
supportBtn.BackgroundTransparency = 0.4
supportBtn.Position = UDim2.new(0, 20, 0, 178)
supportBtn.Size = UDim2.new(0.5, -24, 0, 36)
supportBtn.Font = Enum.Font.GothamBold
supportBtn.Text = 'Support'
supportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
supportBtn.TextSize = 12
supportBtn.AutoButtonColor = false
Instance.new('UICorner', supportBtn).CornerRadius = UDim.new(0, 8)

local supportStroke = Instance.new('UIStroke')
supportStroke.Color = Color3.fromRGB(140, 100, 220)
supportStroke.Transparency = 0.3
supportStroke.Parent = supportBtn

-- Get Key button
local getKeyBtn = Instance.new('TextButton')
getKeyBtn.Name = randomName(8)
getKeyBtn.Parent = frame
getKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
getKeyBtn.BackgroundTransparency = 0.4
getKeyBtn.Position = UDim2.new(0.5, 4, 0, 178)
getKeyBtn.Size = UDim2.new(0.5, -24, 0, 36)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.Text = 'Get Key'
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.TextSize = 12
getKeyBtn.AutoButtonColor = false
Instance.new('UICorner', getKeyBtn).CornerRadius = UDim.new(0, 8)

local getKeyStroke = Instance.new('UIStroke')
getKeyStroke.Color = Color3.fromRGB(140, 100, 220)
getKeyStroke.Transparency = 0.3
getKeyStroke.Parent = getKeyBtn

-- Drag logic
local dragging, lastInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        lastInput = input
    end
end)

UserInput.InputChanged:Connect(function(input)
    if input == lastInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tween helper
local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad), props):Play()
end

-- Hover effects
closeBtn.MouseEnter:Connect(function()   tween(closeBtn,   {TextColor3 = Color3.fromRGB(255, 70, 70)}) end)
closeBtn.MouseLeave:Connect(function()   tween(closeBtn,   {TextColor3 = Color3.fromRGB(120, 120, 140)}) end)

checkBtn.MouseEnter:Connect(function()   tween(checkBtn,   {BackgroundTransparency = 0.2}) tween(checkStroke,   {Transparency = 0}) end)
checkBtn.MouseLeave:Connect(function()   tween(checkBtn,   {BackgroundTransparency = 0.4}) tween(checkStroke,   {Transparency = 0.3}) end)

supportBtn.MouseEnter:Connect(function() tween(supportBtn, {BackgroundTransparency = 0.2}) tween(supportStroke, {Transparency = 0}) end)
supportBtn.MouseLeave:Connect(function() tween(supportBtn, {BackgroundTransparency = 0.4}) tween(supportStroke, {Transparency = 0.3}) end)

getKeyBtn.MouseEnter:Connect(function()  tween(getKeyBtn,  {BackgroundTransparency = 0.2}) tween(getKeyStroke,  {Transparency = 0}) end)
getKeyBtn.MouseLeave:Connect(function()  tween(getKeyBtn,  {BackgroundTransparency = 0.4}) tween(getKeyStroke,  {Transparency = 0.3}) end)

keyInput.Focused:Connect(function()
    tween(inputStroke, {Color = Color3.fromRGB(139, 92, 246)})
    tween(inputFrame,  {BackgroundColor3 = Color3.fromRGB(32, 32, 42)})
end)
keyInput.FocusLost:Connect(function()
    tween(inputStroke, {Color = Color3.fromRGB(50, 50, 65)})
    tween(inputFrame,  {BackgroundColor3 = Color3.fromRGB(26, 26, 34)})
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    tween(frame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
    task.wait(0.2)
    screenGui:Destroy()
end)

-- Support button
supportBtn.MouseButton1Click:Connect(function()
    if setclip then setclip('https://' .. DISCORD) end
    statusLabel.TextColor3 = Color3.fromRGB(87, 242, 135)
    statusLabel.Text = 'Discord link copied!'
    task.delay(2, function() statusLabel.Text = '' end)
end)

-- Get Key button
getKeyBtn.MouseButton1Click:Connect(function()
    if setclip then setclip(KEY_URL) end
    statusLabel.TextColor3 = Color3.fromRGB(87, 242, 135)
    statusLabel.Text = 'Key link copied!'
    task.delay(2, function() statusLabel.Text = '' end)
end)

-- Check Key button
checkBtn.MouseButton1Click:Connect(function()
    local key = keyInput.Text

    if key == '' or #key < 10 then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = 'Please enter a valid key!'
        return
    end

    statusLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
    statusLabel.Text = 'Validating...'
    luarmor.script_id = scriptId

    local ok, result = pcall(function() return luarmor.check_key(key) end)

    if not ok then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = 'Error checking key. Try again.'
        return
    end

    local errors = {
        KEY_EXPIRED         = 'Your key has expired! Please get a new key.',
        KEY_BANNED          = 'This key has been banned and cannot be used anymore.',
        KEY_HWID_LOCKED     = 'Key is locked to another device! Reset your HWID or get a new key.',
        KEY_INCORRECT       = 'This key does not exist! Double-check your key or get a new one.',
        KEY_INVALID         = 'Invalid key format! Key is empty, too short, or too long.',
        SCRIPT_ID_INCORRECT = 'Script configuration error - please contact support on Discord!',
        SCRIPT_ID_INVALID   = 'Script configuration error - please contact support on Discord!',
        INVALID_EXECUTOR    = 'Your executor is not supported! Try using a different executor.',
        SECURITY_ERROR      = 'Security validation failed! Request was blocked by Cloudflare.',
        TIME_ERROR          = 'Your system time is incorrect! Sync your clock and try again.',
        UNKNOWN_ERROR       = 'Server error! Try again later or contact support on Discord.',
    }

    if result.code == 'KEY_VALID' then
        statusLabel.TextColor3 = Color3.fromRGB(87, 242, 135)
        statusLabel.Text = 'Key valid! Loading script...'
        getgenv().script_key = key
        saveKey(key)
        task.wait(1)
        tween(frame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        screenGui:Destroy()
        luarmor.load_script()
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = errors[result.code] or ('Unknown error: ' .. (result.message or result.code or 'Unknown') .. ' - contact support!')
    end
end)

-- Open animation
frame.Size = UDim2.new(0, 0, 0, 0)
frame.BackgroundTransparency = 1
tween(frame, {Size = UDim2.new(0, 400, 0, 240), BackgroundTransparency = 0.05}, 0.3)
