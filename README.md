local config = {
    ESPEnabled = true,
    RefreshRate = 0.1,
    MaxDistance = 2200,
    FontSize = 12,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPStorage = {}

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end

    local nameTag = Drawing.new("Text")
    nameTag.Size = config.FontSize
    nameTag.Color = config.TextColor
    nameTag.Outline = true
    nameTag.OutlineColor = config.TextOutlineColor
    nameTag.Visible = false

    ESPStorage[player] = {nameTag}
end

local function removeESP(player)
    local lines = ESPStorage[player]
    if lines then
        for _, obj in ipairs(lines) do
            obj:Remove()
        end
        ESPStorage[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local esp = ESPStorage[player]

            if not esp then
                createESP(player)
                esp = ESPStorage[player]
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

            if onScreen and distance <= config.MaxDistance then
                local x, y = math.floor(screenPos.X), math.floor(screenPos.Y)
                local nameTag = esp[1]
                nameTag.Text = string.upper(player.Name)
                nameTag.Position = Vector2.new(x - nameTag.TextBounds.X / 2, y - 18)
                nameTag.Visible = true
            else
                esp[1].Visible = false
            end
        elseif ESPStorage[player] then
            removeESP(player)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if config.ESPEnabled then
        updateESP()
    end
end)
