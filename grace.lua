local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
    Title = "BEARWARE",
    Subtitle = "#1 GRACE Script",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 2,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightShift,
    AcrylicBlur = false,
})

local tabGroups = {
    TabGroup1 = Window:TabGroup()
}

local tabs = {
    Main = tabGroups.TabGroup1:Tab({ Name = "Main", Image = "rbxassetid://10734923549" }),
}

local sections = {
    MainSection1 = tabs.Main:Section({ Side = "Left" }),
    MainSection2 = tabs.Main:Section({ Side = "Right" }),
    ConfigSection = tabs.Main:Section({ Side = "Left" }),
}

local fullbrightEnabled = false
local originalBrightness
local originalClockTime
local originalFogEnd
local originalGlobalShadows
local originalOutdoorAmbient

sections.MainSection2:Toggle({
    Name = "No Acceleration",
    Default = false,
    Callback = function(value)
        local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        if value then
            local existingProperties = rootPart.CustomPhysicalProperties or PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
            rootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
        else
            local existingProperties = rootPart.CustomPhysicalProperties or PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
            rootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
        end
    end,
}, "NoAccelToggle")

sections.MainSection1:Toggle({
    Name = "FullBright",
    Default = false,
    Callback = function(value)
        fullbrightEnabled = value
        local lighting = game:GetService("Lighting")
        if fullbrightEnabled then
            originalBrightness = lighting.Brightness
            originalClockTime = lighting.ClockTime
            originalFogEnd = lighting.FogEnd
            originalGlobalShadows = lighting.GlobalShadows
            originalOutdoorAmbient = lighting.OutdoorAmbient

            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            lighting.Brightness = originalBrightness or 1
            lighting.ClockTime = originalClockTime or 14
            lighting.FogEnd = originalFogEnd or 100000
            lighting.GlobalShadows = originalGlobalShadows or true
            lighting.OutdoorAmbient = originalOutdoorAmbient or Color3.new(0.5, 0.5, 0.5)
        end
    end,
}, "FullBrightToggle")

local noFogEnabled = false
local originalFogStart
local originalFogColor

sections.MainSection1:Toggle({
    Name = "No Fog",
    Default = false,
    Callback = function(value)
        noFogEnabled = value
        local lighting = game:GetService("Lighting")
        if noFogEnabled then
            originalFogStart = lighting.FogStart
            originalFogColor = lighting.FogColor

            lighting.FogStart = 100000
            lighting.FogColor = Color3.new(1, 1, 1)
        else
            lighting.FogStart = originalFogStart or 0
            lighting.FogColor = originalFogColor or Color3.new(0.5, 0.5, 0.5)
        end
    end,
}, "NoFogToggle")

local RunService = game:GetService("RunService")
local speedEnabled = false
local speedValue = 16
local speedLoop

sections.MainSection2:Toggle({
    Name = "WalkSpeed",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        if speedEnabled then
            if speedLoop then speedLoop:Disconnect() end
            speedLoop = RunService.Heartbeat:Connect(function()
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
            end)
        else
            if speedLoop then
                speedLoop:Disconnect()
                speedLoop = nil
            end
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
}, "WalkSpeedToggle")

sections.MainSection2:Slider({
    Name = "WalkSpeed Value",
    Default = 16,
    Minimum = 16,
    Maximum = 100,
    DisplayMethod = "Value",
    Precision = 0,
    Callback = function(Value)
        speedValue = Value
    end,
}, "WalkSpeedSlider")

MacLib:SetFolder("BEARWARE")

sections.ConfigSection:Button({
    Name = "Save Config",
    Callback = function()
        MacLib:SaveConfig("CurrentConfig")
        Window:Notify({
            Title = "BEARWARE",
            Description = "Config saved successfully!",
            Lifetime = 5
        })
    end,
})

sections.ConfigSection:Button({
    Name = "Load Config",
    Callback = function()
        MacLib:LoadConfig("CurrentConfig")
        Window:Notify({
            Title = "BEARWARE",
            Description = "Config loaded successfully!",
            Lifetime = 5
        })
    end,
})

sections.ConfigSection:Button({
    Name = "Auto Load Config",
    Callback = function()
        MacLib:LoadAutoLoadConfig()
        Window:Notify({
            Title = "BEARWARE",
            Description = "Auto Load Config enabled!",
            Lifetime = 5
        })
    end,
})

sections.ConfigSection:Button({
    Name = "Reset Config",
    Callback = function()
        MacLib:ResetConfig()
        Window:Notify({
            Title = "BEARWARE",
            Description = "Config reset successfully!",
            Lifetime = 5
        })
    end,
})

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if speedEnabled then
        char:WaitForChild("Humanoid").WalkSpeed = speedValue
    end
end)

tabs.Main:Select()
MacLib:LoadAutoLoadConfig()
