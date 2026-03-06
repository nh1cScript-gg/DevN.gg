loadstring('function LPH_NO_VIRTUALIZE(f) return f end;')()

local cloneref = cloneref or function(s) return s end
local TweenService = cloneref(game:GetService('TweenService'))
local UserInput = cloneref(game:GetService('UserInputService'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local setclip = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
local getgenv = getgenv or function() return shared end

local DISCORD = 'discord.gg/NUvUBqpY'
local KEY_URL = 'https://ads.luarmor.net/get_key?for=DevNGG_Linkvertise-spFShuBrrikz'
local KEY_FILE = 'DevNGG_Key.txt'
local HUB_NAME = 'DevN.GG'
local scriptId = 'b21e1a3cb48e19e563afc194037d1234'

-- DO NOT load luarmor here yet, load it only when key is submitted
local function saveKey(k) if writefile then pcall(function() writefile(KEY_FILE, k) end) end end
local function getSavedKey()
    if not isfile then return nil end
    local ok, r = pcall(function() if isfile(KEY_FILE) then return readfile(KEY_FILE) end end)
    if ok and r and #r > 5 then return r end
    return nil
end
local function delKey() if delfile then pcall(function() if isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end end) end end

local function randomName(n)
    local c='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local r='' for i=1,n or 12 do r=r..c:sub(math.random(1,#c),math.random(1,#c)) end return r
end

-- BUILD GUI FIRST before any luarmor calls
local sg = Instance.new('ScreenGui')
sg.Name = randomName(16)
if protect_gui then protect_gui(sg) end
sg.Parent = CoreGui
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.ResetOnSpawn = false

local frame = Instance.new('Frame')
frame.Name = randomName(12)
frame.Parent = sg
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
frame.BackgroundTransparency = 0.05
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 400, 0, 240)
Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 12)

local fs = Instance.new('UIStroke')
fs.Color = Color3.fromRGB(139, 92, 246)
fs.Thickness = 1.5
fs.Transparency = 0.4
fs.Parent = frame

local title = Instance.new('TextLabel')
title.Parent = frame
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 18, 0, 14)
title.Size = UDim2.new(0, 200, 0, 26)
title.Font = Enum.Font.GothamBlack
title.Text = HUB_NAME
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new('TextButton')
closeBtn.Parent = frame
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(1, -32, 0, 10)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = 'X'
closeBtn.TextColor3 = Color3.fromRGB(120, 120, 140)
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false

local div = Instance.new('Frame')
div.Parent = frame
div.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
div.BorderSizePixel = 0
div.Position = UDim2.new(0, 0, 0, 46)
div.Size = UDim2.new(1, 0, 0, 1)

local subtitle = Instance.new('TextLabel')
subtitle.Parent = frame
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 20, 0, 54)
subtitle.Size = UDim2.new(1, -40, 0, 28)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = 'Enter your key below. Need one? Click Get Key!'
subtitle.TextColor3 = Color3.fromRGB(120, 120, 140)
subtitle.TextSize = 11
subtitle.TextWrapped = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local inputFrame = Instance.new('Frame')
inputFrame.Parent = frame
inputFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
inputFrame.Position = UDim2.new(0, 20, 0, 88)
inputFrame.Size = UDim2.new(1, -40, 0, 38)
Instance.new('UICorner', inputFrame).CornerRadius = UDim.new(0, 8)
local inputStroke = Instance.new('UIStroke')
inputStroke.Color = Color3.fromRGB(50, 50, 65)
inputStroke.Parent = inputFrame

local keyInput = Instance.new('TextBox')
keyInput.Parent = inputFrame
keyInput.BackgroundTransparency = 1
keyInput.Position = UDim2.new(0, 12, 0, 0)
keyInput.Size = UDim2.new(1, -24, 1, 0)
keyInput.Font = Enum.Font.Gotham
keyInput.PlaceholderColor3 = Color3.fromRGB(85, 85, 105)
keyInput.PlaceholderText = 'Enter your key here...'
keyInput.Text = getSavedKey() or ''
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.TextSize = 13
keyInput.TextXAlignment = Enum.TextXAlignment.Left
keyInput.ClearTextOnFocus = false

local statusLabel = Instance.new('TextLabel')
statusLabel.Parent = frame
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 0, 0, 130)
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.Text = ''
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 11

local function makeBtn(txt, pos, sz, col)
    local b = Instance.new('TextButton')
    b.Parent = frame
    b.BackgroundColor3 = col
    b.BackgroundTransparency = 0.4
    b.Position = pos
    b.Size = sz
    b.Font = Enum.Font.GothamBold
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextSize = 12
    b.AutoButtonColor = false
    Instance.new('UICorner', b).CornerRadius = UDim.new(0, 8)
    local s = Instance.new('UIStroke')
    s.Color = col s.Transparency = 0.3 s.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(.15),{BackgroundTransparency=0.15}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.15),{BackgroundTransparency=0.4}):Play() end)
    return b
end

local checkBtn  = makeBtn('✔ Check Key', UDim2.new(0,20,0,152),  UDim2.new(0.45,-24,0,36), Color3.fromRGB(139,92,246))
local discordBtn= makeBtn('💬 Discord',  UDim2.new(0.45,4,0,152), UDim2.new(0.27,-4,0,36),  Color3.fromRGB(88,101,242))
local getKeyBtn = makeBtn('🔗 Get Key',  UDim2.new(0.72,8,0,152), UDim2.new(0.28,-28,0,36), Color3.fromRGB(255,140,0))

-- Drag
local drag,ds,sp,li
frame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true ds=i.Position sp=frame.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
frame.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then li=i end end)
UserInput.InputChanged:Connect(function(i)
    if i==li and drag then local d=i.Position-ds frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end
end)

keyInput.Focused:Connect(function() TweenService:Create(inputStroke,TweenInfo.new(.15),{Color=Color3.fromRGB(139,92,246)}):Play() end)
keyInput.FocusLost:Connect(function() TweenService:Create(inputStroke,TweenInfo.new(.15),{Color=Color3.fromRGB(50,50,65)}):Play() end)

local function setStatus(msg, col)
    statusLabel.TextColor3 = col or Color3.fromRGB(255,100,100)
    statusLabel.Text = msg
    task.delay(3, function() if statusLabel.Text == msg then statusLabel.Text = '' end end)
end

local function closeGUI(cb)
    TweenService:Create(frame,TweenInfo.new(.2),{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1}):Play()
    task.wait(.22) sg:Destroy() if cb then cb() end
end

closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(.15),{TextColor3=Color3.fromRGB(255,70,70)}):Play() end)
closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(.15),{TextColor3=Color3.fromRGB(120,120,140)}):Play() end)
closeBtn.MouseButton1Click:Connect(function() closeGUI() end)

discordBtn.MouseButton1Click:Connect(function()
    if setclip then setclip('https://'..DISCORD) end
    setStatus('Discord copied!', Color3.fromRGB(87,242,135))
end)

getKeyBtn.MouseButton1Click:Connect(function()
    if setclip then setclip(KEY_URL) end
    setStatus('Key link copied!', Color3.fromRGB(87,242,135))
end)

local ERRS = {
    KEY_EXPIRED='Key expired! Get a new one.',
    KEY_BANNED='Key is banned.',
    KEY_HWID_LOCKED='HWID mismatch! Get a new key.',
    KEY_INCORRECT='Key not found! Check it or get a new one.',
    KEY_INVALID='Invalid key format.',
    SCRIPT_ID_INCORRECT='Config error - contact support.',
    INVALID_EXECUTOR='Executor not supported.',
    SECURITY_ERROR='Security error. Try again.',
    TIME_ERROR='Sync your system clock.',
    UNKNOWN_ERROR='Server error. Try again later.',
}

checkBtn.MouseButton1Click:Connect(function()
    local k = keyInput.Text
    if k=='' or #k<10 then setStatus('Please enter a valid key!') return end
    setStatus('Validating...', Color3.fromRGB(130,130,150))

    task.spawn(function()
        -- Load luarmor ONLY when user clicks Check Key
        local ok0, lm = pcall(function()
            return loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()
        end)
        if not ok0 then setStatus('Failed to reach server. Try again.') return end
        lm.script_id = scriptId

        local ok, r = pcall(function() return lm.check_key(k) end)
        if not ok then setStatus('Error checking key. Try again.') return end

        if r.code == 'KEY_VALID' then
            setStatus('Key valid! Loading '..HUB_NAME..'...', Color3.fromRGB(87,242,135))
            getgenv().script_key = k
            saveKey(k)
            task.wait(1.2)
            closeGUI(function() lm.load_script() end)
        else
            delKey()
            setStatus(ERRS[r.code] or 'Error: '..(r.code or 'Unknown'))
        end
    end)
end)

-- Open animation
frame.Size = UDim2.new(0,0,0,0)
frame.BackgroundTransparency = 1
TweenService:Create(frame,TweenInfo.new(.3,Enum.EasingStyle.Back),{Size=UDim2.new(0,400,0,240),BackgroundTransparency=0.05}):Play()
