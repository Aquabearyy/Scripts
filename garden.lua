local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

local Window = MacLib:Window({
    Title = "Farm Finder",
    Subtitle = "Find your farm index",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 2,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

local tabGroups = {
    TabGroup1 = Window:TabGroup()
}

local tabs = {
    Main = tabGroups.TabGroup1:Tab({ Name = "Farm Finder", Image = "rbxassetid://10734950309" })
}

local sections = {
    MainSection = tabs.Main:Section({ Side = "Left" })
}

sections.MainSection:Header({
    Name = "Farm Index Finder"
})

local farmIndexValue = nil

local function findPlayerFarmIndex()
    local farmFolder = workspace:FindFirstChild("Farm")
    if not farmFolder then
        Window:Notify({
            Title = "Error",
            Description = "No Farm folder found in workspace",
            Lifetime = 5
        })
        return nil
    end
    
    local farmArray = farmFolder:GetChildren()
    
    for i = 1, #farmArray do
        local success, result = pcall(function()
            local farm = farmArray[i]
            
            if farm and farm:FindFirstChild("Important") and 
               farm.Important:FindFirstChild("Data") and 
               farm.Important.Data:FindFirstChild("Owner") then
                
                local ownerValue = farm.Important.Data.Owner
                
                if ownerValue:IsA("StringValue") and ownerValue.Value == LocalPlayer.Name then
                    return i
                end
            end
            return nil
        end)
        
        if success and result then
            return result
        end
    end
    
    Window:Notify({
        Title = "Error",
        Description = "Couldn't find your farm",
        Lifetime = 5
    })
    return nil
end

local function verifyFarmOwnership()
    if not farmIndexValue then
        farmIndexValue = findPlayerFarmIndex()
        return farmIndexValue ~= nil
    end
    
    local farmFolder = workspace:FindFirstChild("Farm")
    if not farmFolder then return false end
    
    local farmArray = farmFolder:GetChildren()
    if farmIndexValue > #farmArray then
        farmIndexValue = findPlayerFarmIndex()
        return farmIndexValue ~= nil
    end
    
    local success, result = pcall(function()
        local farm = farmArray[farmIndexValue]
        if farm and farm.Important and farm.Important.Data and farm.Important.Data.Owner then
            return farm.Important.Data.Owner.Value == LocalPlayer.Name
        end
        return false
    end)
    
    if not success or not result then
        farmIndexValue = findPlayerFarmIndex()
        return farmIndexValue ~= nil
    end
    
    return true
end

sections.MainSection:Divider()

sections.MainSection:Header({
    Name = "Auto Collector"
})

local collectionCooldown = 0.1
local autoCollectActive = false
local autoCollectThread = nil

sections.MainSection:Slider({
    Name = "Collection Cooldown",
    Default = 0.1,
    Minimum = 0.01,
    Maximum = 0.5,
    Precision = 2,
    DisplayMethod = "Value",
    Callback = function(value)
        collectionCooldown = value
    end
})

local freezeRootPartToggle = nil

local function collectPlants()
    if not farmIndexValue then return end
    
    local farmFolder = workspace:FindFirstChild("Farm")
    if not farmFolder then return end
    
    local farmArray = farmFolder:GetChildren()
    if farmIndexValue > #farmArray then return end
    
    local farm = farmArray[farmIndexValue]
    if not farm then return end
    
    local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
    if not plantsFolder then return end
    
    for _, plant in pairs(plantsFolder:GetDescendants()) do
        if plant:IsA("ProximityPrompt") and autoCollectActive then
            local parentPart = plant.Parent
            if parentPart and parentPart:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Anchor the character
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
                
                -- Teleport to the plant
                LocalPlayer.Character.HumanoidRootPart.CFrame = parentPart.CFrame + Vector3.new(0, 3, 0)
                wait(0.2)
                
                -- Simulate holding E key
                keypress(0x45) -- E key
                wait(collectionCooldown)
                keyrelease(0x45) -- Release E key
                
                wait(0.1)
            end
        end
    end
end

sections.MainSection:Toggle({
    Name = "Auto Collect Plants",
    Default = false,
    Callback = function(value)
        autoCollectActive = value
        
        if value then
            if not farmIndexValue then
                farmIndexValue = findPlayerFarmIndex()
                if not farmIndexValue then
                    Window:Notify({
                        Title = "Error",
                        Description = "Couldn't find your farm",
                        Lifetime = 5
                    })
                    autoCollectActive = false
                    return
                end
            end
            
            Window:Notify({
                Title = "Auto Collect",
                Description = "Started auto collecting plants",
                Lifetime = 5
            })
            
            -- Automatically anchor character when auto-collect is enabled
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
            end
            
            if autoCollectThread then
                task.cancel(autoCollectThread)
            end
            
            autoCollectThread = task.spawn(function()
                while autoCollectActive do
                    collectPlants()
                    task.wait(0.5)
                end
            end)
        else
            if autoCollectThread then
                task.cancel(autoCollectThread)
                autoCollectThread = nil
            end
            
            -- Unanchor character when auto-collect is disabled
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
            
            Window:Notify({
                Title = "Auto Collect",
                Description = "Stopped auto collecting plants",
                Lifetime = 5
            })
        end
    end,
})

farmIndexValue = findPlayerFarmIndex()

spawn(function()
    while true do
        verifyFarmOwnership()
        wait(15)
    end
end)

tabs.Main:Select()
