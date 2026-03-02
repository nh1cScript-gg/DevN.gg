-- loader.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local DevNgg = {}
DevNgg.__index = DevNgg

function DevNgg:CreateWindow(settings)
    settings = settings or {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "DevNgg_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(9,9,9)
    main.BorderSizePixel = 0
    main.Parent = gui

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = settings.Name or "DevN.gg"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = main

    -- Fade In
    main.BackgroundTransparency = 1
    TweenService:Create(
        main,
        TweenInfo.new(0.4),
        {BackgroundTransparency = 0}
    ):Play()

    local Window = {}

    function Window:CreateTab(tabName)
        local tab = Instance.new("TextLabel")
        tab.Size = UDim2.new(1, 0, 0, 30)
        tab.Position = UDim2.new(0, 0, 0, 50)
        tab.BackgroundTransparency = 1
        tab.Text = tabName
        tab.TextColor3 = Color3.new(1,1,1)
        tab.Font = Enum.Font.Gotham
        tab.TextSize = 16
        tab.Parent = main

        local TabFunctions = {}

        function TabFunctions:CreateToggle(name, default, callback)
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 200, 0, 30)
            toggle.Position = UDim2.new(0, 20, 0, 90)
            toggle.Text = name .. ": " .. tostring(default)
            toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
            toggle.TextColor3 = Color3.new(1,1,1)
            toggle.Parent = main

            local state = default

            toggle.MouseButton1Click:Connect(function()
                state = not state
                toggle.Text = name .. ": " .. tostring(state)
                if callback then
                    callback(state)
                end
            end)
        end

        return TabFunctions
    end

    return Window
end

return DevNgg
