loadstring('    function LPH_NO_VIRTUALIZE(f) return f end;\n')()

-- ── DUPLICATE PREVENTION ─────────────────────────────────────
-- If this loader already ran in this server session, stop here.
-- Prevents double-loading when Xeno auto exec fires multiple times.
local _genv = getgenv and getgenv() or shared
if _genv.__devngg_loaded then return end
_genv.__devngg_loaded = true

-- ── WAIT FOR GAME TO FULLY LOAD ──────────────────────────────
-- Xeno auto exec fires before the game is ready — wait for it.
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(3) -- extra buffer for ReplicatedStorage and remotes to populate
-- ─────────────────────────────────────────────────────────────

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
local SCRIPT_ID = 'b21e1a3cb48e19e563afc194037d1234'
local SCRIPT_URL = 'https://raw.githubusercontent.com/nh1cScript-gg/DevN.gg/main/devn.gg'

local function saveKey(k)
    -- Save to both file and getgenv so it survives server hops
    if writefile then pcall(function() writefile(KEY_FILE,k) end) end
    pcall(function() (getgenv and getgenv() or shared).__devngg_key = k end)
    pcall(function() _G.__devngg_key = k end)
end
local function getSavedKey()
    -- Try getgenv first (survives server hops even if file system doesn't)
    local envKey = pcall(function()
        return (getgenv and getgenv() or shared).__devngg_key
    end) and (getgenv and getgenv() or shared).__devngg_key or nil
    if type(envKey) == 'string' and #envKey > 5 then return envKey end
    -- Fallback to _G
    if type(_G.__devngg_key) == 'string' and #_G.__devngg_key > 5 then return _G.__devngg_key end
    -- Fallback to file
    if not isfile then return nil end
    local ok,r=pcall(function() if isfile(KEY_FILE) then return readfile(KEY_FILE) end end)
    if ok and r and #r>5 then return r end return nil
end
local function delKey()
    if delfile then pcall(function() if isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end end) end
end

local function rn(n)
    local c='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local r='' for i=1,n or 12 do r=r..c:sub(math.random(1,#c),math.random(1,#c)) end return r
end

-- ── AUTO-LOAD: same pattern as LuminHub ──────────────────────
local function tryAutoAuth()
    -- If already validated this session, skip straight to loading
    local _ge = getgenv and getgenv() or shared
    if _ge.__devngg_key_valid and _ge.__devngg_key then
        _ge.__devngg_loaded = nil
        loadstring(game:HttpGet(SCRIPT_URL))()
        return true
    end
    -- grab key from any possible source
    local envKey = script_key or _G.script_key or (getgenv and getgenv().script_key) or _G.__devngg_key or (_ge.__devngg_key) or nil
    local savedKey = getSavedKey()
    if type(envKey) ~= 'string' then envKey = nil end
    if type(savedKey) ~= 'string' then savedKey = nil end
    -- ignore obviously bad keys
    if envKey and #envKey < 10 then envKey = nil end
    local key = envKey or savedKey
    if not key or #key < 10 then return false end
    -- validate silently
    local lmOk, lm = pcall(function()
        return loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()
    end)
    if not lmOk or not lm then return false end
    lm.script_id = SCRIPT_ID
    local ok, r = pcall(function() return lm.check_key(key) end)
    if not ok or not r then return false end
    if r.code == 'KEY_VALID' then
        getgenv().script_key = key
        _G.script_key = key
        saveKey(key)
        -- Mark as validated so next hop skips re-validation
        local _genv2 = getgenv and getgenv() or shared
        _genv2.__devngg_key = key
        _genv2.__devngg_key_valid = true
        _genv2.__devngg_loaded = nil
        loadstring(game:HttpGet(SCRIPT_URL))()
        return true
    else
        delKey()
        return false
    end
end

-- If key is valid → skip GUI entirely and load straight away
if tryAutoAuth() then return end

local function buildAndShowGUI()

-- BUILD GUI
local sg=Instance.new('ScreenGui') sg.Name=rn(16)
if protect_gui then protect_gui(sg) end
sg.Parent=CoreGui sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling sg.ResetOnSpawn=false

local fr=Instance.new('Frame') fr.Name=rn(12) fr.Parent=sg
fr.AnchorPoint=Vector2.new(.5,.5) fr.BackgroundColor3=Color3.fromRGB(16,16,22)
fr.BackgroundTransparency=0.05 fr.Position=UDim2.fromScale(.5,1.6)
fr.Size=UDim2.fromOffset(400,240) fr.BorderSizePixel=0
Instance.new('UICorner',fr).CornerRadius=UDim.new(0,12)
local fs=Instance.new('UIStroke') fs.Color=Color3.fromRGB(139,92,246) fs.Thickness=1.5 fs.Transparency=.4 fs.Parent=fr

local title=Instance.new('TextLabel') title.Parent=fr title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(18,14) title.Size=UDim2.new(.7,0,0,26)
title.Font=Enum.Font.GothamBlack title.Text=HUB_NAME
title.TextColor3=Color3.fromRGB(255,255,255) title.TextSize=20 title.TextXAlignment=Enum.TextXAlignment.Left

local cb=Instance.new('TextButton') cb.Parent=fr cb.BackgroundTransparency=1
cb.AnchorPoint=Vector2.new(1,.5) cb.Position=UDim2.new(1,-14,.0,20)
cb.Size=UDim2.fromOffset(22,22) cb.Font=Enum.Font.GothamBold cb.Text='✕'
cb.TextColor3=Color3.fromRGB(120,120,140) cb.TextSize=14 cb.AutoButtonColor=false

Instance.new('Frame',fr).BackgroundColor3=Color3.fromRGB(40,40,55)
local dv=fr:FindFirstChildOfClass('Frame') dv.BorderSizePixel=0
dv.Position=UDim2.new(0,0,0,46) dv.Size=UDim2.new(1,0,0,1)

local sub=Instance.new('TextLabel') sub.Parent=fr sub.BackgroundTransparency=1
sub.Position=UDim2.fromOffset(18,54) sub.Size=UDim2.new(1,-36,0,28)
sub.Font=Enum.Font.Gotham sub.Text='Enter your key below or click Get Key!'
sub.TextColor3=Color3.fromRGB(110,110,135) sub.TextSize=11
sub.TextWrapped=true sub.TextXAlignment=Enum.TextXAlignment.Left

local inf=Instance.new('Frame') inf.Parent=fr inf.BackgroundColor3=Color3.fromRGB(26,26,34)
inf.Position=UDim2.fromOffset(18,88) inf.Size=UDim2.new(1,-36,0,40) inf.BorderSizePixel=0
Instance.new('UICorner',inf).CornerRadius=UDim.new(0,8)
local ins=Instance.new('UIStroke') ins.Color=Color3.fromRGB(50,50,65) ins.Parent=inf

local ki=Instance.new('TextBox') ki.Parent=inf ki.BackgroundTransparency=1
ki.Position=UDim2.fromOffset(12,0) ki.Size=UDim2.new(1,-24,1,0)
ki.Font=Enum.Font.Gotham ki.PlaceholderText='Enter your key here...'
ki.PlaceholderColor3=Color3.fromRGB(85,85,105) ki.Text=getSavedKey() or ''
ki.TextColor3=Color3.fromRGB(255,255,255) ki.TextSize=13
ki.TextXAlignment=Enum.TextXAlignment.Left ki.ClearTextOnFocus=false

local sl=Instance.new('TextLabel') sl.Parent=fr sl.BackgroundTransparency=1
sl.Position=UDim2.fromOffset(0,132) sl.Size=UDim2.new(1,0,0,16)
sl.Font=Enum.Font.GothamMedium sl.Text='' sl.TextColor3=Color3.fromRGB(255,100,100)
sl.TextSize=11 sl.TextXAlignment=Enum.TextXAlignment.Center

local function mkb(txt,pos,sz,col)
    local b=Instance.new('TextButton') b.Parent=fr b.BackgroundColor3=col
    b.BackgroundTransparency=.35 b.Position=pos b.Size=sz
    b.Font=Enum.Font.GothamBold b.Text=txt b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=12 b.AutoButtonColor=false b.BorderSizePixel=0
    Instance.new('UICorner',b).CornerRadius=UDim.new(0,8)
    local s=Instance.new('UIStroke') s.Color=col s.Transparency=.4 s.Parent=b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(.15),{BackgroundTransparency=.1}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.15),{BackgroundTransparency=.35}):Play() end)
    return b
end

local ckb=mkb('✔  Check Key',  UDim2.fromOffset(18,152),  UDim2.new(.45,-22,0,36), Color3.fromRGB(139,92,246))
local dcb=mkb('💬  Discord',   UDim2.new(.45,6,0,152),     UDim2.new(.27,-4,0,36),  Color3.fromRGB(88,101,242))
local gkb=mkb('🔗  Get Key',   UDim2.new(.72,10,0,152),    UDim2.new(.28,-28,0,36), Color3.fromRGB(255,140,0))

-- Drag
local drag,ds,sp,li
fr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true ds=i.Position sp=fr.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
fr.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then li=i end end)
UserInput.InputChanged:Connect(function(i)
    if i==li and drag then local d=i.Position-ds
        fr.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end
end)

ki.Focused:Connect(function() TweenService:Create(ins,TweenInfo.new(.15),{Color=Color3.fromRGB(139,92,246)}):Play() end)
ki.FocusLost:Connect(function() TweenService:Create(ins,TweenInfo.new(.15),{Color=Color3.fromRGB(50,50,65)}):Play() end)
cb.MouseEnter:Connect(function() TweenService:Create(cb,TweenInfo.new(.15),{TextColor3=Color3.fromRGB(255,70,70)}):Play() end)
cb.MouseLeave:Connect(function() TweenService:Create(cb,TweenInfo.new(.15),{TextColor3=Color3.fromRGB(120,120,140)}):Play() end)

local function ss(m,c,p)
    sl.TextColor3=c or Color3.fromRGB(255,100,100) sl.Text=m
    if not p then task.delay(3,function() if sl.Text==m then sl.Text='' end end) end
end

local function closeGUI(fn)
    TweenService:Create(fr,TweenInfo.new(.2),{Position=UDim2.fromScale(.5,1.6),BackgroundTransparency=1}):Play()
    task.wait(.22) sg:Destroy() if fn then fn() end
end

cb.MouseButton1Click:Connect(function() closeGUI() end)
dcb.MouseButton1Click:Connect(function()
    if setclip then setclip('https://'..DISCORD) end
    ss('Discord copied!',Color3.fromRGB(87,242,135))
end)
gkb.MouseButton1Click:Connect(function()
    if setclip then setclip(KEY_URL) end
    ss('Key link copied!',Color3.fromRGB(87,242,135))
end)

local ERRS={
    KEY_EXPIRED='Key expired! Get a new one.',KEY_BANNED='Key is banned.',
    KEY_HWID_LOCKED='HWID mismatch! Get a new key.',KEY_INCORRECT='Key not found!',
    KEY_INVALID='Invalid key format.',SCRIPT_ID_INCORRECT='Config error.',
    INVALID_EXECUTOR='Executor not supported.',SECURITY_ERROR='Security error.',
    TIME_ERROR='Sync your clock.',UNKNOWN_ERROR='Server error.',
}

ckb.MouseButton1Click:Connect(function()
    local k=ki.Text
    if k==''or #k<10 then ss('Please enter a valid key!') return end
    ss('Validating...',Color3.fromRGB(130,130,150),true)
    task.spawn(function()
        local ok0,lm=pcall(function()
            return loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()
        end)
        if not ok0 then ss('Failed to reach server.') return end
        lm.script_id=SCRIPT_ID
        local ok,r=pcall(function() return lm.check_key(k) end)
        if not ok then ss('Error checking key. Try again.') return end
        if r.code=='KEY_VALID' then
            ss('✅ Key valid! Loading '..HUB_NAME..'...',Color3.fromRGB(87,242,135),true)
            getgenv().script_key=k _G.script_key=k saveKey(k)
            local _genv3 = getgenv and getgenv() or shared
            _genv3.__devngg_key = k
            _genv3.__devngg_key_valid = true
            _genv3.__devngg_loaded = nil
            task.wait(1.2)
            closeGUI(function()
                loadstring(game:HttpGet(SCRIPT_URL))()
            end)
        else
            delKey()
            ss(ERRS[r.code]or'Error: '..(r.code or'Unknown'))
        end
    end)
end)

-- Open animation
TweenService:Create(fr,TweenInfo.new(.3,Enum.EasingStyle.Back),{Position=UDim2.fromScale(.5,.5),BackgroundTransparency=.05}):Play()

end -- end of buildAndShowGUI()

-- No valid saved key — show the GUI
buildAndShowGUI()
