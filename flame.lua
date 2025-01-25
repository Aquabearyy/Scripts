local Library = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

function Library:CreateWindow()
    local GUI = {
        CurrentTab = nil,
        Tabs = {},
        Items = {}
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FLAME"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 1
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.249, 0, 0.279, 0)
    Main.Size = UDim2.new(0.503, 0, 0.399, 0)
    Main.Parent = ScreenGui
    
    local MainContent = Instance.new("Frame")
    MainContent.Name = "Main"
    MainContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainContent.BorderSizePixel = 0
    MainContent.Position = UDim2.new(0.019, 0, 0.128, 0)
    MainContent.Size = UDim2.new(0.57, 0, 0.948, 0)
    MainContent.Parent = Main
    
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 61, 61))
    }
    MainGradient.Rotation = -45
    MainGradient.Parent = MainContent
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainContent
    
    local MainAspect = Instance.new("UIAspectRatioConstraint")
    MainAspect.AspectRatio = 1.507
    MainAspect.Parent = MainContent
    
    local Tabs = Instance.new("Folder")
    Tabs.Name = "Tabs"
    Tabs.Parent = MainContent
    
    local Items = Instance.new("Folder")
    Items.Name = "Items"
    Items.Parent = MainContent
    
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UserInfo.BorderSizePixel = 0
    UserInfo.Position = UDim2.new(0.602, 0, 0.128, 0)
    UserInfo.Size = UDim2.new(0.378, 0, 0.948, 0)
    UserInfo.Parent = Main
    
    local UserInfoCorner = Instance.new("UICorner")
    UserInfoCorner.CornerRadius = UDim.new(0, 12)
    UserInfoCorner.Parent = UserInfo
    
    local UserInfoGradient = Instance.new("UIGradient")
    UserInfoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 61, 61))
    }
    UserInfoGradient.Rotation = -45
    UserInfoGradient.Parent = UserInfo
    
    local PlayerImage = Instance.new("ImageLabel")
    PlayerImage.BorderSizePixel = 0
    PlayerImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlayerImage.Position = UDim2.new(0.091, 0, 0.027, 0)
    PlayerImage.Size = UDim2.new(0.822, 0, 0.822, 0)
    PlayerImage.Parent = UserInfo
    PlayerImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. game.Players.LocalPlayer.UserId .. "&w=420&h=420"
    
    local PlayerImageCorner = Instance.new("UICorner")
    PlayerImageCorner.CornerRadius = UDim.new(0, 12)
    PlayerImageCorner.Parent = PlayerImage
    
    local Username = Instance.new("TextLabel")
    Username.Name = "username"
    Username.BackgroundTransparency = 1
    Username.Position = UDim2.new(0.253, 0, 0.879, 0)
    Username.Size = UDim2.new(0.493, 0, 0.096, 0)
    Username.Font = Enum.Font.DenkOne
    Username.Text = game.Players.LocalPlayer.Name
    Username.TextColor3 = Color3.fromRGB(255, 255, 255)
    Username.TextScaled = true
    Username.TextTransparency = 0.2
    Username.Parent = UserInfo
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "Bar"
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BorderSizePixel = 0
    TitleBar.Position = UDim2.new(0.019, 0, 0.022, 0)
    TitleBar.Size = UDim2.new(0.96, 0, 0.082, 0)
    TitleBar.Parent = Main
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12)
    TitleBarCorner.Parent = TitleBar
    
    local TitleBarGradient = Instance.new("UIGradient")
    TitleBarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 61, 61))
    }
    TitleBarGradient.Rotation = -45
    TitleBarGradient.Parent = TitleBar
    
    local Logo = Instance.new("ImageLabel")
    Logo.BorderSizePixel = 0
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0.016, 0, 0.146, 0)
    Logo.Size = UDim2.new(0.027, 0, 0.72, 0)
    Logo.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "FLAME"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.055, 0, 0.027, 0)
    Title.Size = UDim2.new(0.125, 0, 0.973, 0)
    Title.Font = Enum.Font.DenkOne
    Title.Text = "FLAME"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local function CreateDrag(bar)
        local dragToggle, dragSpeed, dragStart, startPos = nil, 0.25, nil, nil
        
        local function updateInput(input)
            local delta = input.Position - dragStart
            local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(Main, TweenInfo.new(dragSpeed), {Position = position}):Play()
        end
        
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                dragToggle = true
                dragStart = input.Position
                startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragToggle then
                    updateInput(input)
                end
            end
        end)
    end
    
    CreateDrag(TitleBar)
    
    function GUI:CreateTab(name)
        local tab = {
            Items = {}
        }
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BorderSizePixel = 0
        TabButton.Position = UDim2.new(0.015 + (#GUI.Tabs * 0.145), 0, 0.027, 0)
        TabButton.Size = UDim2.new(0.127, 0, 0.082, 0)
        TabButton.Font = Enum.Font.FredokaOne
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.TextScaled = true
        TabButton.Parent = Tabs
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 999)
        TabButtonCorner.Parent = TabButton
        
        local TabFolder = Instance.new("Folder")
        TabFolder.Name = name .. "Tab"
        TabFolder.Parent = Items
        
        TabButton.MouseButton1Click:Connect(function()
            for _, item in pairs(Items:GetChildren()) do
                item.Visible = false
            end
            TabFolder.Visible = true
        end)
        
        function tab:CreateToggle(name, callback)
            local toggle = {Enabled = false}
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = name
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Position = UDim2.new(0.016, 0, 0.142 + (#tab.Items * 0.127), 0)
            ToggleFrame.Size = UDim2.new(0.965, 0, 0.11, 0)
            ToggleFrame.Parent = TabFolder
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0.013, 0, 0, 0)
            ToggleLabel.Size = UDim2.new(0.834, 0, 1, 0)
            ToggleLabel.Font = Enum.Font.DenkOne
            ToggleLabel.Text = name
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextScaled = true
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("Frame")
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 83, 83)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Position = UDim2.new(0.872, 0, 0.1, 0)
            ToggleButton.Size = UDim2.new(0.122, 0, 0.76, 0)
            ToggleButton.Parent = ToggleFrame
            
            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(0, 999)
            ToggleButtonCorner.Parent = ToggleButton
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Position = UDim2.new(0.169, 0, 0.099, 0)
            ToggleIndicator.Size = UDim2.new(0.4, 0, 0.8, 0)
            ToggleIndicator.Parent = ToggleButton
            
            local ToggleIndicatorCorner = Instance.new("UICorner")
            ToggleIndicatorCorner.CornerRadius = UDim.new(0, 999)
            ToggleIndicatorCorner.Parent = ToggleIndicator
            
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle.Enabled = not toggle.Enabled
                    TweenService:Create(ToggleButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = toggle.Enabled and Color3.fromRGB(86, 255, 128) or Color3.fromRGB(255, 83, 83)
                    }):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.1), {
                        Position = toggle.Enabled and UDim2.new(0.477, 0, 0.099, 0) or UDim2.new(0.169, 0, 0.099, 0)
                    }):Play()
                    callback(toggle.Enabled)
                end
            end)
            
            table.insert(tab.Items, toggle)
            return toggle
        end
        
        function tab:CreateButton(name, callback)
            local button = {}
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = name
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Position = UDim2.new(0.016, 0, 0.142 + (#tab.Items * 0.127), 0)
            ButtonFrame.Size = UDim2.new(0.965, 0, 0.11, 0)
            ButtonFrame.Parent = TabFolder
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.Parent = ButtonFrame

            local ButtonLabel = Instance.new("TextButton")
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Position = UDim2.new(0.013, 0, 0, 0)
            ButtonLabel.Size = UDim2.new(0.974, 0, 1, 0)
            ButtonLabel.Font = Enum.Font.DenkOne
            ButtonLabel.Text = name
            ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonLabel.TextScaled = true
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.Parent = ButtonFrame
            
            ButtonLabel.MouseButton1Click:Connect(callback)
            
            table.insert(tab.Items, button)
            return button
            end
            
            function tab:CreateKeybind(name, default, callback)
                local keybind = {
                    Key = default
                }
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Name = name
                KeybindFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Position = UDim2.new(0.016, 0, 0.142 + (#tab.Items * 0.127), 0)
                KeybindFrame.Size = UDim2.new(0.965, 0, 0.11, 0)
                KeybindFrame.Parent = TabFolder
                
                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.Parent = KeybindFrame
                
                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Position = UDim2.new(0.013, 0, 0, 0)
                KeybindLabel.Size = UDim2.new(0.834, 0, 1, 0)
                KeybindLabel.Font = Enum.Font.DenkOne
                KeybindLabel.Text = name
                KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeybindLabel.TextScaled = true
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.Parent = KeybindFrame
                
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                KeybindButton.BackgroundTransparency = 0.15
                KeybindButton.Position = UDim2.new(0.913, 0, 0.05, 0)
                KeybindButton.Size = UDim2.new(0.066, 0, 0.875, 0)
                KeybindButton.Font = Enum.Font.Oswald
                KeybindButton.Text = default.Name
                KeybindButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                KeybindButton.TextScaled = true
                KeybindButton.Parent = KeybindFrame
                
                local KeybindButtonCorner = Instance.new("UICorner")
                KeybindButtonCorner.Parent = KeybindButton
                
                local listening = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                    
                    local connection
                    connection = UIS.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybind.Key = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            listening = false
                            connection:Disconnect()
                        end
                    end)
                end)
                
                UIS.InputBegan:Connect(function(input)
                    if not listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == keybind.Key then
                            callback()
                        end
                    end
                end)
                
                table.insert(tab.Items, keybind)
                return keybind
            end
            
            table.insert(GUI.Tabs, tab)
            return tab
            end
            
            return GUI
            end
            
            return Library
