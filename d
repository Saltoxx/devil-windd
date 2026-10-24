-- Devil Wind — money + cars
-- place 108964358879504

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local env = getgenv and getgenv() or _G

if env.DW_UI then
    pcall(function() env.DW_UI:Destroy() end)
    env.DW_UI = nil
end

for _, oldName in ipairs({ "DevilWind", "DevilWindPanel" }) do
    local old = PlayerGui:FindFirstChild(oldName)
    if old then
        old:Destroy()
    end
end

env.DW_FARM = env.DW_FARM or { running = false, calls = 0 }
env.DW_FARM.running = false
task.wait(0.2)

local THEME = {
    bg     = Color3.fromRGB(18, 20, 24),
    panel  = Color3.fromRGB(25, 28, 33),
    card   = Color3.fromRGB(33, 37, 43),
    stroke = Color3.fromRGB(52, 58, 66),
    text   = Color3.fromRGB(233, 237, 241),
    muted  = Color3.fromRGB(140, 148, 158),
    accent = Color3.fromRGB(72, 209, 132),
    danger = Color3.fromRGB(224, 94, 94),
}

local CONFIG = {
    Payout = 500,
    Interval = 0.08,
}

local State = { baseline = 0 }

local function new(class, props, parent)
    local instance = Instance.new(class)
    for key, value in pairs(props) do
        instance[key] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function money()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local value = stats and stats:FindFirstChild("Money")
    return value and value.Value or 0
end

State.baseline = money()

local function commas(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local out = s:reverse():gsub("%d%d%d", "%1,"):reverse()
    return (out:gsub("^,", ""))
end

local function corner(parent, radius)
    new("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, parent)
end

local function stroke(parent)
    new("UIStroke", {
        Color = THEME.stroke,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local gui = new("ScreenGui", {
    Name = "DevilWind",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)
env.DW_UI = gui

local window = new("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(460, 360),
    Position = UDim2.new(0.5, -230, 0.5, -180),
    BackgroundColor3 = THEME.bg,
    BorderSizePixel = 0,
    Active = true,
}, gui)
corner(window, 10)
stroke(window)

local header = new("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = THEME.panel,
    BorderSizePixel = 0,
    Active = true,
}, window)
corner(header, 10)

new("TextLabel", {
    Size = UDim2.new(0, 180, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "DEVIL WIND",
    TextSize = 14,
    TextColor3 = THEME.accent,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local balanceLabel = new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(1, -252, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    Text = "$0",
    TextSize = 14,
    TextColor3 = THEME.text,
    TextXAlignment = Enum.TextXAlignment.Right,
}, header)

local closeButton = new("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -36, 0, 7),
    BackgroundColor3 = THEME.card,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextSize = 12,
    TextColor3 = THEME.muted,
    BorderSizePixel = 0,
}, header)
corner(closeButton, 6)
closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

local tabBar = new("Frame", {
    Size = UDim2.new(1, -24, 0, 32),
    Position = UDim2.fromOffset(12, 52),
    BackgroundTransparency = 1,
}, window)

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local content = new("Frame", {
    Size = UDim2.new(1, -24, 1, -96),
    Position = UDim2.fromOffset(12, 90),
    BackgroundTransparency = 1,
}, window)

local pages = {}
local tabButtons = {}

local function selectTab(name)
    for tabName, tabPage in pairs(pages) do
        tabPage.Visible = tabName == name
        tabButtons[tabName].TextColor3 = tabName == name and THEME.accent or THEME.muted
        tabButtons[tabName].BackgroundColor3 = tabName == name and THEME.panel or THEME.card
    end
end

local function makeTab(name, order)
    local tabButton = new("TextButton", {
        Size = UDim2.fromOffset(96, 32),
        BackgroundColor3 = THEME.card,
        AutoButtonColor = true,
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextSize = 12,
        TextColor3 = THEME.muted,
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, tabBar)
    corner(tabButton, 6)

    local page = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
    }, content)

    pages[name] = page
    tabButtons[name] = tabButton

    tabButton.MouseButton1Click:Connect(function()
        selectTab(name)
    end)

    return page
end

local function label(parent, text, position, size, color, align)
    return new("TextLabel", {
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextSize = 12,
        TextColor3 = color or THEME.text,
        TextXAlignment = align or Enum.TextXAlignment.Left,
    }, parent)
end

local function button(parent, text, position, size, color)
    local b = new("TextButton", {
        Size = size,
        Position = position,
        BackgroundColor3 = color or THEME.card,
        AutoButtonColor = true,
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextSize = 12,
        TextColor3 = THEME.text,
        BorderSizePixel = 0,
    }, parent)
    corner(b, 6)
    return b
end

local function textbox(parent, text, position, size)
    local box = new("TextBox", {
        Size = size,
        Position = position,
        BackgroundColor3 = THEME.card,
        Font = Enum.Font.Code,
        Text = text,
        TextSize = 14,
        TextColor3 = THEME.text,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
    }, parent)
    corner(box, 6)
    stroke(box)
    return box
end

-- money ----------------------------------------------------------------

local moneyPage = makeTab("Money", 1)

local payoutBox = textbox(moneyPage, tostring(CONFIG.Payout), UDim2.fromOffset(0, 0), UDim2.fromOffset(120, 38))
label(moneyPage, "payout", UDim2.fromOffset(132, 0), UDim2.fromOffset(100, 38), THEME.muted)

local intervalBox = textbox(moneyPage, tostring(CONFIG.Interval), UDim2.fromOffset(0, 48), UDim2.fromOffset(120, 38))
label(moneyPage, "interval", UDim2.fromOffset(132, 48), UDim2.fromOffset(100, 38), THEME.muted)

local toggleButton = button(moneyPage, "START", UDim2.fromOffset(0, 100), UDim2.fromOffset(120, 40), THEME.accent)
toggleButton.TextColor3 = THEME.bg

local earnedLabel = label(moneyPage, "$0", UDim2.fromOffset(132, 100), UDim2.fromOffset(200, 40), THEME.muted)
local callLabel = label(moneyPage, "0 calls", UDim2.fromOffset(0, 152), UDim2.fromOffset(200, 20), THEME.muted)

-- cars -----------------------------------------------------------------

local carsPage = makeTab("Cars", 2)
local carScroll = new("ScrollingFrame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.stroke,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, carsPage)
new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, carScroll)

local spawnRemote = ReplicatedStorage:FindFirstChild("RequestCarSpawn")
local ok, data = pcall(function()
    return ReplicatedStorage:WaitForChild("GetVehicleData", 10):InvokeServer()
end)

local cars = (ok and type(data) == "table" and data.Cars) or {}
local ownedFolder = LocalPlayer:FindFirstChild("OwnedCars")

if #cars == 0 then
    label(carsPage, "catalog unavailable", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 20), THEME.danger)
else
    for index, car in ipairs(cars) do
        local frame = new("Frame", {
            Size = UDim2.new(1, -6, 0, 38),
            BackgroundColor3 = THEME.card,
            BorderSizePixel = 0,
            LayoutOrder = index,
        }, carScroll)
        corner(frame, 6)

        local owned = ownedFolder ~= nil and ownedFolder:FindFirstChild(car.Name) ~= nil

        label(frame, car.Name, UDim2.fromOffset(10, 0), UDim2.new(1, -180, 1, 0), THEME.text)
        label(frame, owned and "owned" or ("$" .. commas(car.Cost or 0)),
            UDim2.new(1, -170, 0, 0), UDim2.fromOffset(90, 38),
            owned and THEME.accent or THEME.muted, Enum.TextXAlignment.Right)

        local spawnButton = button(frame, "SPAWN", UDim2.new(1, -72, 0, 6), UDim2.fromOffset(62, 26), THEME.card)
        spawnButton.MouseButton1Click:Connect(function()
            if spawnRemote and spawnRemote.Parent then
                pcall(function()
                    spawnRemote:FireServer(car.Name)
                end)
            end
        end)
    end
end

-- farm -----------------------------------------------------------------

local pictureMoney = ReplicatedStorage:FindFirstChild("RequestPictureMoney")

local function startFarm()
    if env.DW_FARM.running or not pictureMoney then
        return false
    end

    env.DW_FARM.running = true
    State.baseline = money()

    task.spawn(function()
        while env.DW_FARM.running do
            if not pictureMoney.Parent then
                env.DW_FARM.running = false
                break
            end

            local fired = pcall(function()
                pictureMoney:FireServer(CONFIG.Payout)
            end)

            if fired then
                env.DW_FARM.calls = env.DW_FARM.calls + 1
            end

            task.wait(CONFIG.Interval)
        end
    end)

    return true
end

local function stopFarm()
    env.DW_FARM.running = false
end

toggleButton.MouseButton1Click:Connect(function()
    if env.DW_FARM.running then
        stopFarm()
    else
        CONFIG.Payout = math.floor(tonumber(payoutBox.Text) or CONFIG.Payout)
        CONFIG.Interval = math.max(tonumber(intervalBox.Text) or CONFIG.Interval, 0.02)
        payoutBox.Text = tostring(CONFIG.Payout)
        intervalBox.Text = tostring(CONFIG.Interval)
        startFarm()
    end
end)

task.spawn(function()
    while gui.Parent do
        local current = money()
        balanceLabel.Text = "$" .. commas(current)
        earnedLabel.Text = "+$" .. commas(current - State.baseline)
        callLabel.Text = string.format("%d calls", env.DW_FARM.calls)

        if env.DW_FARM.running then
            toggleButton.Text = "STOP"
            toggleButton.BackgroundColor3 = THEME.danger
        else
            toggleButton.Text = "START"
            toggleButton.BackgroundColor3 = THEME.accent
        end

        task.wait(0.2)
    end
end)

-- drag -----------------------------------------------------------------

local dragging = false
local dragStart, startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = window.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging or not window.Parent then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

selectTab("Money")

env.DEVILWIND = {
    Start = startFarm,
    Stop = stopFarm,
    Toggle = function()
        gui.Enabled = not gui.Enabled
    end,
}
