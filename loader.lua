-- loader.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Loader = {}
Loader.__index = Loader

function Loader.new()
    local self = setmetatable({}, Loader)
    self.Gui = nil
    self.Running = false
    return self
end

function Loader:Start(config)
    if self.Running then return end
    self.Running = true

    config = config or {}
    local duration = config.Duration or 3

    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    self.Gui = gui

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(1,0,1,0)
    main.BackgroundColor3 = Color3.fromRGB(9,9,9)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,40)
    title.Position = UDim2.new(0,0,0.4,0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "DevN.gg"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextColor3 = Color3.new(1,1,1)

    local progressBG = Instance.new("Frame", main)
    progressBG.Size = UDim2.new(0.4,0,0,4)
    progressBG.Position = UDim2.new(0.3,0,0.5,0)
    progressBG.BackgroundColor3 = Color3.fromRGB(40,40,40)
    progressBG.BorderSizePixel = 0

    local fill = Instance.new("Frame", progressBG)
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.new(1,1,1)
    fill.BorderSizePixel = 0

    TweenService:Create(fill,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(1,0,1,0)}
    ):Play()

    task.delay(duration, function()
        self:Finish()
    end)
end

function Loader:Finish()
    if not self.Gui then return end
    self.Gui:Destroy()
    self.Running = false
end

return Loader
