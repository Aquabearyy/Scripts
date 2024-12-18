local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

game:GetService("TeleportService"):QueueOnTeleport([[
    wait(1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/temp/main/noUI.lua"))()
]])

local MaxDistance = 500
local inLobbyPlayers = {}

local function toggleTableAttribute(attribute, value)
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) then
            gcVal[attribute] = value
        end
    end
end

toggleTableAttribute("ShootCooldown", 0)
toggleTableAttribute("ShootSpread", 0)
toggleTableAttribute("ShootRecoil", 0)

if CoreGui:FindFirstChild("CircleUI") then
    CoreGui.CircleUI:Destroy()
end

local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Folder"
espFolder.Parent = CoreGui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CircleUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 300)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 2
uiStroke.Parent = frame

local function updateLobbyCheck()
    while wait(0.5) do
        inLobbyPlayers = {}
        if workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Hub") then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    for _, part in pairs(workspace.Lobby.Hub:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local distance = (hrp.Position - part.Position).Magnitude
                            if distance <= 20 then
                                inLobbyPlayers[player] = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

local function isInLobby(player)
    return inLobbyPlayers[player] == true
end

local function createESP(player)
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP_" .. player.Name
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(4, 0, 6, 0)
    esp.StudsOffset = Vector3.new(0, 0, 0)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = esp
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
    nameLabel.Position = UDim2.new(0, 0, -0.25, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Parent = frame
    
    esp.Parent = espFolder
    return esp
end

local function isAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function updateESP()
    for _, esp in pairs(espFolder:GetChildren()) do
        esp:Destroy()
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and player.Character:FindFirstChild("HumanoidRootPart") then
            if not isInLobby(player) and not isInLobby(LocalPlayer) then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= MaxDistance then
                    local esp = createESP(player)
                    esp.Adornee = player.Character
                end
            end
        end
    end
end

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, false, true)
    return hitPart and hitPart:IsDescendantOf(part.Parent)
end

local function isPlayerInCircle(player)
    if not isAlive(player) or isInLobby(player) or isInLobby(LocalPlayer) then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    if distance > MaxDistance then return false end
    
    if player.Character and player.Character:FindFirstChild("Head") then
        local screenPoint, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
        if onScreen then
            local circleCenter = Vector2.new(frame.AbsolutePosition.X + frame.AbsoluteSize.X/2, 
                                           frame.AbsolutePosition.Y + frame.AbsoluteSize.Y/2)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - circleCenter).Magnitude
            return distance <= frame.AbsoluteSize.X/2 and isVisible(player.Character.Head)
        end
    end
    return false
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and player.Character:FindFirstChild("HumanoidRootPart") then
            if not isInLobby(player) and not isInLobby(LocalPlayer) then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= MaxDistance then
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                    if onScreen then
                        local circleCenter = Vector2.new(frame.AbsolutePosition.X + frame.AbsoluteSize.X/2, 
                                                       frame.AbsolutePosition.Y + frame.AbsoluteSize.Y/2)
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - circleCenter).Magnitude
                        
                        if distance <= frame.AbsoluteSize.X/2 and isVisible(player.Character.Head) then
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local originalCFrame = nil

coroutine.wrap(updateLobbyCheck)()

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        updateESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isAlive(player) and not isInLobby(player) and not isInLobby(LocalPlayer) then
                if isPlayerInCircle(player) then
                    mouse1click()
                    break
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = getClosestPlayer()
        if target then
            originalCFrame = Camera.CFrame
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
            task.wait()
            mouse1click()
            task.wait()
            if originalCFrame then
                Camera.CFrame = originalCFrame
            end
        end
    end
end)
