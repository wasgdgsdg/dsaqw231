local config = {
    ESPEnabled = true,
    RefreshRate = 0.1,
    MaxDistance = 2200,
    LineThickness = 1,
    LineColor = Color3.fromRGB(0, 0, 0),
    FillColor = Color3.fromRGB(255, 0, 0),
    FillTransparency = 0.3,
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

    local lines = {}

    -- Fill Box
    local fillBox = Drawing.new("Square")
    fillBox.Visible = false
    fillBox.Color = config.FillColor
    fillBox.Filled = true
    fillBox.Transparency = config.FillTransparency
    table.insert(lines, fillBox)

    -- Outline Box
    local outlineLines = {}
    for i = 1, 4 do
        local outlineLine = Drawing.new("Line")
        outlineLine.Thickness = config.LineThickness
        outlineLine.Color = config.LineColor
        outlineLine.Visible = false
        table.insert(outlineLines, outlineLine)
    end

    ESPStorage[player] = {fillBox, outlineLines}
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
            local humanoid = char:FindFirstChild("Humanoid")
            local esp = ESPStorage[player]

            if not esp then
                createESP(player)
                esp = ESPStorage[player]
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

            if onScreen and distance <= config.MaxDistance then
                local height = humanoid and humanoid.HipWidth or 5
                local scale = 1 / (screenPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local width = math.floor(4.5 * scale)
                local scaledHeight = math.floor(height * scale * 1.2)
                local x, y = math.floor(screenPos.X), math.floor(screenPos.Y)
                local xPos, yPos = math.floor(x - width / 2), math.floor(y - scaledHeight / 2)

                local sizeFactor = 1 - (distance / config.MaxDistance)
                width = math.max(math.floor(width * sizeFactor * 1.3), 6)
                scaledHeight = math.max(math.floor(scaledHeight * sizeFactor), 10)

                -- Box (Fill, Outline) 처리
                local fillBox = esp[1]
                fillBox.Position = Vector2.new(xPos, yPos)
                fillBox.Size = Vector2.new(width, scaledHeight)
                fillBox.Visible = true

                local outlineLines = esp[2]
                for i = 1, 4 do
                    outlineLines[i].Visible = true
                end

                -- Outline Box (4 lines)
                outlineLines[1].From = Vector2.new(xPos, yPos)
                outlineLines[1].To = Vector2.new(xPos + width, yPos)

                outlineLines[2].From = Vector2.new(xPos, yPos + scaledHeight)
                outlineLines[2].To = Vector2.new(xPos + width, yPos + scaledHeight)

                outlineLines[3].From = Vector2.new(xPos, yPos)
                outlineLines[3].To = Vector2.new(xPos, yPos + scaledHeight)

                outlineLines[4].From = Vector2.new(xPos + width, yPos)
                outlineLines[4].To = Vector2.new(xPos + width, yPos + scaledHeight)
            else
                for i = 1, 4 do
                    esp[i].Visible = false
                end
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
