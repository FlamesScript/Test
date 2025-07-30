-- ========== SERVICES ==========
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

-- ========== PLAYER REFERENCES ==========
local player = Players.LocalPlayer
local PlayerGui = player:FindFirstChildWhichIsA("PlayerGui")

-- ========== NETWORK REFERENCES ==========
local Net = ReplicatedStorage.Packages.Net

-- ========== GAME IDENTIFIERS ==========
local Plots = Workspace.Plots
local PlaceId = game.PlaceId
local JobId = game.JobId

-- ========== GLOBAL SETTINGS ==========
getgenv().Settings = {
  StealHelperConn = nil,
	InfiniteJump = { Enabled = false, Min = 45, Max = 60, Cooldown = 0.05, Last = 0, Conn = nil },
	WalkSpeed = {
		SmallSpeedEnabled = false,
		SpeedBoostEnabled = false,
		MaxSpeedEnabled = false,
		SmallSpeed = 45,
		SpeedBoost = 72,
		MaxSpeed = 100,
		Conn = nil
	},
	AntiRagdoll = { Conn = nil },
	AntiTrap = { Enabled = false },
	Visuals = {
	  PlayerESP = { Enabled = false },
	  BestBrainRotESP = { Enabled = false },
	  PlotTimerESP = { Enabled = false }
	}
}

-- ========== CHARACTER FUNCTIONS ==========

--> LocalPlayer Plot
local function GetMyPlot()
    for _, plot in next, Plots:GetChildren() do
        if plot:FindFirstChild("YourBase", true) and 
        plot:FindFirstChild("YourBase", true).Enabled then
            return plot
        end
    end
    return nil
end

--> Character
local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

--> FindTool (func)
local function findTool(name)
    return player.Character:FindFirstChild(name) or player.Backpack:FindFirstChild(name)
end

local function ItemNames()
  return {
    "All Seeing Sentry",
    "Bee Launcher",
    "BeeHiveTemplate",
    "Body Swap Potion",
    "Coil Combo",
    "Dark Matter Slap",
    "Diamond Slap",
    "Emerald Slap",
    "Flame Slap",
    "Galaxy Slap",
    "Glitched Slap",
    "Gold Slap",
    "Gravity Coil",
    "Grapple Hook",
    "Heart Balloon",
    "Invisibility Cloak",
    "Iron Slap",
    "Laser Cape",
    "Magnet",
    "Medusa's Head",
    "Megaphone",
    "Nuclear Slap",
    "Paintball Gun",
    "Quantum Cloner",
    "Rage Table",
    "Rainbowrath Sword",
    "Ruby Slap",
    "Slap",
    "Speed Coil",
    "Splatter Slap",
    "Taser Gun",
    "Trap",
    "Web Slinger"
}
end

-- ========== MOVEMENT FUNCTIONS ==========

-- Updates the player's walkspeed based on settings
local function UpdateSpeed()
    local char = GetCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local targetSpeed = 32
    if Settings.WalkSpeed.SmallSpeedEnabled then
        targetSpeed = Settings.WalkSpeed.SmallSpeed
    elseif Settings.WalkSpeed.SpeedBoostEnabled then
        local tool = findTool("Coil")
        if tool then
            pcall(function() hum:EquipTool(tool) end)
            pcall(function() tool:Activate() end)
            targetSpeed = Settings.WalkSpeed.SpeedBoost
            pcall(function() hum:UnequipTools() end)
        end
    elseif Settings.WalkSpeed.MaxSpeedEnabled then
        local tool = findTool("Cloak")
        if tool then
            pcall(function() hum:EquipTool(tool) end)
            pcall(function() tool:Activate() end)
            targetSpeed = Settings.WalkSpeed.MaxSpeed
            pcall(function() hum:UnequipTools() end)
        end
    end
    
    if targetSpeed ~= Settings.WalkSpeed.SmallSpeed or Settings.WalkSpeed.SpeedBoost or Settings.WalkSpeed.MaxSpeed then return end
    hum.WalkSpeed = targetSpeed

    if Settings.WalkSpeed.Conn then
        Settings.WalkSpeed.Conn:Disconnect()
    end

    Settings.WalkSpeed.Conn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed ~= targetSpeed then
            hum.WalkSpeed = targetSpeed
        end
    end)
end

-- Connects character appearance to speed update
player.CharacterAppearanceLoaded:Connect(UpdateSpeed)

-- ========== WEB SLINGER FUNCTIONS ==========

-- Executes web sling action when prompted
local function ExecuteWebSlingAction()
    local Character = GetCharacter()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local WebSlinger = findTool("Web Slinger")
    
    if not WebSlinger then return end
    Humanoid:EquipTool(WebSlinger)
    Net["RE/UseItem"]:FireServer(Character.HumanoidRootPart.CFrame, Character.HumanoidRootPart, WebSlinger.Handle)
    Humanoid:GetPropertyChangedSignal("PlatformStand"):Once(function()
        if Humanoid.PlatformStand then
          Humanoid:ChangeState("Jumping")
          Humanoid.PlatformStand = false
        end
    end)
end

-- ========== ANTI-TRAP FUNCTIONS ==========

-- Scans for and removes trap objects
local function doAntiTrap()
    if not Settings.AntiTrap.Enabled then return end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and tostring(obj):lower():find("trap") then
            for _, v in pairs(obj:GetChildren()) do
                if v.Name:lower() == "open" and v:IsA("BasePart") then
                  v:Destroy()
                end
            end
        end
    end
end

-- Connects workspace changes to anti-trap
Workspace.ChildAdded:Connect(doAntiTrap)

-- ========== ESP FUNCTIONS ==========

-- Creates ESP for players
function ESP(plr, logic)
    task.spawn(function()
        -- Clean up existing ESP
        for i,v in pairs(CoreGui:GetChildren()) do
            if v.Name == plr.Name..'_ESP' then
                v:Destroy()
            end
        end
        
        if plr.Character and plr.Name ~= player.Name and not CoreGui:FindFirstChild(plr.Name..'_ESP') then
            local ESPholder = Instance.new("Folder")
            ESPholder.Name = plr.Name..'_ESP'
            ESPholder.Parent = CoreGui
            
            repeat wait(1) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid")
            
            -- Create box adornments for each body part
            for b,n in pairs (plr.Character:GetChildren()) do
                if (n:IsA("BasePart")) then
                    local a = Instance.new("BoxHandleAdornment")
                    a.Name = plr.Name
                    a.Parent = ESPholder
                    a.Adornee = n
                    a.AlwaysOnTop = true
                    a.ZIndex = 10
                    a.Size = n.Size
                    a.Transparency = 0.3
                    
                    if logic == true then
                        a.Color = BrickColor.new(plr.TeamColor == Players.LocalPlayer.TeamColor and "Bright green" or "Bright red")
                    else
                        a.Color = plr.TeamColor
                    end
                end
            end
            
            -- Create name tag above player's head
            if plr.Character and plr.Character:FindFirstChild('Head') then
                local BillboardGui = Instance.new("BillboardGui")
                local TextLabel = Instance.new("TextLabel")
                BillboardGui.Adornee = plr.Character.Head
                BillboardGui.Name = plr.Name
                BillboardGui.Parent = ESPholder
                BillboardGui.Size = UDim2.new(0, 100, 0, 150)
                BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
                BillboardGui.AlwaysOnTop = true
                TextLabel.Parent = BillboardGui
                TextLabel.BackgroundTransparency = 1
                TextLabel.Position = UDim2.new(0, 0, 0, -50)
                TextLabel.Size = UDim2.new(0, 100, 0, 100)
                TextLabel.Font = Enum.Font.SourceSansSemibold
                TextLabel.TextSize = 20
                TextLabel.TextColor3 = Color3.new(1, 1, 1)
                TextLabel.TextStrokeTransparency = 0
                TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
                TextLabel.Text = 'Name: '..plr.Name
                TextLabel.ZIndex = 10
                
                -- ESP update loop function
                local function espLoop()
                    if CoreGui:FindFirstChild(plr.Name..'_ESP') then
                        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                            local pos = math.floor((GetCharacter().HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude)
                            TextLabel.Text = 'Name: '..plr.Name..' | Studs: '..pos
                        end
                    else
                        teamChange:Disconnect()
                        addedFunc:Disconnect()
                        espLoopFunc:Disconnect()
                    end
                end
                
                -- Set up event connections
                local espLoopFunc = RunService.RenderStepped:Connect(espLoop)
                local teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
                    if Settings.Visuals.PlayerESP.Enabled then
                        espLoopFunc:Disconnect()
                        addedFunc:Disconnect()
                        ESPholder:Destroy()
                        repeat wait(1) until plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid")
                        ESP(plr, logic)
                        teamChange:Disconnect()
                    else
                        teamChange:Disconnect()
                    end
                end)
                
                local addedFunc = plr.CharacterAdded:Connect(function()
                    if Settings.Visuals.PlayerESP.Enabled then
                        espLoopFunc:Disconnect()
                        teamChange:Disconnect()
                        ESPholder:Destroy()
                        repeat wait(1) until plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid")
                        ESP(plr, logic)
                        addedFunc:Disconnect()
                    else
                        teamChange:Disconnect()
                        addedFunc:Disconnect()
                    end
                end)
            end
        end
    end)
end

local function parseEarn(str)
    local num = tonumber(str:match("%$([%d%.]+)"))
    local suf = str:match("([KMB])/s")
    if not num then return nil end
    if suf == "K" then num *= 1e3
    elseif suf == "M" then num *= 1e6
    elseif suf == "B" then num *= 1e9 end
    return num
end

-- Get best plot earnings
local function getPlotEarnings(plot)
    local pods = plot:FindFirstChild("AnimalPodiums")
    local bestDisplay, bestEarnTxt, bestVal = nil, nil, -math.huge
    local bestDeco, bestRarity = nil, ""
    local displayLabel, generationLabel, rarityLabel = nil, nil, nil
    
        if not pods then return end

    for _, pod in ipairs(pods:GetChildren()) do
        local display = pod:FindFirstChild("DisplayName", true)
        local generation = pod:FindFirstChild("Generation", true)
        local mutation = pod:FindFirstChild("Mutation", true)

        if generation then
            local earnVal = parseEarn(generation.Text)
            if earnVal and earnVal > bestVal then
                bestVal = earnVal
                bestDisplay = display and display.Text or "???"
                bestEarnTxt = generation.Text
                bestDeco = pod:FindFirstChild("Decorations", true)
                bestRarity = mutation and mutation.Text or ""
                displayLabel = display
                generationLabel = generation
                rarityLabel = mutation
            end
        end
    end

    return bestDisplay, bestEarnTxt, bestDeco, bestRarity, displayLabel, generationLabel, rarityLabel
end

-- Find best earning plot
local function findBestEarner()
    local bestVal = -math.huge
    local bestData = nil

    for _, plot in ipairs(Plots:GetChildren()) do
      if plot ~= GetMyPlot() then
        local display, earnTxt, deco, rarity, displayLabel, generationLabel, rarityLabel = getPlotEarnings(plot)
        if earnTxt then
            local val = parseEarn(earnTxt)
            if val and val > bestVal then
                bestVal = val
                bestData = {
                    plotName = plot.Name,
                    display = display,
                    earnTxt = earnTxt,
                    rarity = rarity,
                    deco = deco,
                    displayLabel = displayLabel,
                    generationLabel = generationLabel,
                    rarityLabel = rarityLabel
                }
            end
        end
      end
  end

    return bestData
end

local currentAdornee = nil

-- ESP Updater
RunService.Heartbeat:Connect(function()
    local best = findBestEarner()
    if not best or not best.deco then return end

    if currentAdornee ~= best.deco then
        -- Clean up old ESP
        if currentAdornee and currentAdornee:FindFirstChild("ESP") then
            currentAdornee.ESP:Destroy()
        end
        if currentAdornee and currentAdornee:FindFirstChildWhichIsA("Highlight") then
            currentAdornee:FindFirstChildWhichIsA("Highlight"):Destroy()
        end

        currentAdornee = best.deco

        -- Clean new if needed
        if best.deco:FindFirstChild("ESP") then best.deco.ESP:Destroy() end
        local oldHL = best.deco:FindFirstChildWhichIsA("Highlight")
        if oldHL then oldHL:Destroy() end

        -- Create Highlight
        local highlight = Instance.new("Highlight")
        highlight.Adornee = best.deco
        highlight.FillColor = Color3.fromRGB(0, 170, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = Settings.Visuals.BestBrainRotESP.Enabled
        highlight.Parent = best.deco

        -- Create Billboard GUI
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Adornee = best.deco
        billboard.Size = UDim2.new(0, 200, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 13, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = Settings.Visuals.BestBrainRotESP.Enabled
        billboard.Parent = best.deco

        local function makeLabel(order, text, source)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, (order - 1) * 20)
            label.BackgroundTransparency = 1
            label.TextColor3 = (source and source.TextColor3) or Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0.5
            label.Font = Enum.Font.SourceSansBold
            label.TextScaled = true
            label.Text = text
            label.Parent = billboard
        end

        makeLabel(1, best.rarity, best.rarityLabel)
        makeLabel(2, best.display, best.displayLabel)
        makeLabel(3, best.earnTxt, best.generationLabel)
    else
        -- Just update visibility
        if currentAdornee then
            local gui = currentAdornee:FindFirstChild("ESP")
            local hl = currentAdornee:FindFirstChildWhichIsA("Highlight")
            if gui then gui.Enabled = Settings.Visuals.BestBrainRotESP.Enabled end
            if hl then hl.Enabled = Settings.Visuals.BestBrainRotESP.Enabled end
        end
    end
end)

local function PlotTimers()
  local LastRemainingTimes = {}
  local LastUpdateTimestamps = {}

    while task.wait() and Settings.Visuals.PlotTimerESP.Enabled do
        for _, plot in ipairs(workspace.Plots:GetChildren()) do
            local hitbox = plot:FindFirstChild("Hitbox", true)
            local remaining = plot:FindFirstChild("RemainingTime", true)
            local yourBase = plot:FindFirstChild("YourBase", true)
            if hitbox and remaining and yourBase then
                local gui = hitbox:FindFirstChild("PlotLabel") or Instance.new("BillboardGui")
                gui.Name = "PlotLabel"
                gui.Adornee = hitbox
                gui.Size = UDim2.new(0, 100, 0, 30)
                gui.AlwaysOnTop = true
                gui.StudsOffset = Vector3.new(0, 3, 0)
                gui.Parent = hitbox

                local label = gui:FindFirstChild("TextLabel") or Instance.new("TextLabel", gui)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.TextColor3 = yourBase.Enabled and Color3.fromRGB(0, 249, 255) or Color3.fromRGB(180, 0, 255)

                local currentText = remaining.Text
                local lastText = LastRemainingTimes[plot]

                if currentText ~= lastText then
                    LastRemainingTimes[plot] = currentText
                    LastUpdateTimestamps[plot] = os.clock()
                end

                if currentText == "0s" then
                    label.Text = "Unlocked"
                elseif os.clock() - (LastUpdateTimestamps[plot] or 0) >= 5 then
                    label.Text = "Unclaimed"
                else
                    label.Text = "Time: " .. currentText
                end
            else
                LastRemainingTimes[plot] = nil
                LastUpdateTimestamps[plot] = nil
            end
        end
    end
end

local function ClearLabels()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        local hitbox = plot:FindFirstChild("Hitbox", true)
        if hitbox then
            local gui = hitbox:FindFirstChild("PlotLabel")
            if gui then gui:Destroy() end
        end
    end
end

-- ========== UI SETUP ==========

-- Load WindUI library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "Steal A Brainrot",
    Icon = "swords",
    Author = "by GodOfWar",
    Folder = "SAB",
    Size = UDim2.fromOffset(540, 300),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function() end,
    }
})

-- Customize UI open button
Window:EditOpenButton({
    Title = "Open UI",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Notification function
local function notify(title, content, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Icon = "droplet-off",
        Duration = duration or 5,
    })
end

-- ========== UI TABS ==========

-- Create tab sections
local Tabs = {
    Main = Window:Section({ Title = "Main Features", Icon = "bot", Opened = false }),
    Utility = Window:Section({ Title = "Utility", Icon = "box", Opened = false }),
    Configuration = Window:Section({ Title = "Configuration", Icon = "settings", Opened = false })
}

-- ========== BASE TAB ==========

local BaseTab = Tabs.Main:Tab({ Title = "Base", Icon = "house", Locked = false })

-- ========== PLAYER TAB ==========

local PlayerTab = Tabs.Main:Tab({ Title = "Player", Icon = "user", Locked = false })

-- Infinite Jump toggle
PlayerTab:Toggle({
    Title = "InfiniteJump",
    Desc = "Let you jump Infinitely",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        Settings.InfiniteJump.Enabled = state
        if state then
            if Settings.InfiniteJump.Conn then 
                Settings.InfiniteJump.Conn:Disconnect() 
            end
            Settings.InfiniteJump.Conn = UserInputService.JumpRequest:Connect(function()
                if not Settings.InfiniteJump.Enabled then return end
                local char = GetCharacter()
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end
                if tick() - Settings.InfiniteJump.Last < Settings.InfiniteJump.Cooldown then return end

                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Jumping then
                    local boost = math.random(Settings.InfiniteJump.Min * 10, Settings.InfiniteJump.Max * 10) / 10
                    root.Velocity = Vector3.new(root.Velocity.X, boost, root.Velocity.Z)
                    Settings.InfiniteJump.Last = tick()
                end
            end)
        elseif Settings.InfiniteJump.Conn then
            Settings.InfiniteJump.Conn:Disconnect()
            Settings.InfiniteJump.Conn = nil
        end
    end
})

-- Speed toggles
local Toggle_SmallSpeed, Toggle_SpeedBoost, Toggle_MaxSpeed

Toggle_SmallSpeed = PlayerTab:Toggle({
    Title = "Small Speed Boost",
    Desc = "Gives a small, constant speed boost",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        Settings.WalkSpeed.SmallSpeedEnabled = state
        if state then
            Settings.WalkSpeed.SpeedBoostEnabled = false
            Settings.WalkSpeed.MaxSpeedEnabled = false
            Toggle_SpeedBoost:Set(false)
            Toggle_MaxSpeed:Set(false)
        end
        UpdateSpeed()
    end,
})

Toggle_SpeedBoost = PlayerTab:Toggle({
    Title = "Speed Boost",
    Desc = "Boosts your speed if you have a Coil",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        Settings.WalkSpeed.SpeedBoostEnabled = state
        if state then
            Settings.WalkSpeed.SmallSpeedEnabled = false
            Settings.WalkSpeed.MaxSpeedEnabled = false
            Toggle_SmallSpeed:Set(false)
            Toggle_MaxSpeed:Set(false)
        end
        UpdateSpeed()
    end,
})

Toggle_MaxSpeed = PlayerTab:Toggle({
    Title = "Max Speed",
    Desc = "Gives max speed if you have a Cloak",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        Settings.WalkSpeed.MaxSpeedEnabled = state
        if state then
            Settings.WalkSpeed.SmallSpeedEnabled = false
            Settings.WalkSpeed.SpeedBoostEnabled = false
            Toggle_SmallSpeed:Set(false)
            Toggle_SpeedBoost:Set(false)
        end
        UpdateSpeed()
    end,
})

-- ========== Steal Helper ==========

local StealHelper = Tabs.Main:Tab({ Title = "Steal Helper", Icon = "crown", Locked = false })

-- Fix missing commas and proper callback structure in Steal Helper toggle
StealHelper:Toggle({
    Title = "Anti Hit",
    Desc = "Become unhittable for 10/s (Medusa's Head, Patched)",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        if state then
            local connection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                if prompt.Parent:IsA("Attachment") and prompt.ObjectText:lower() == "steal" then
                    ExecuteWebSlingAction()
                end
            end)
            -- Store connection for later disconnection
            Settings.StealHelperConn = connection
        else
            if Settings.StealHelperConn then
                Settings.StealHelperConn:Disconnect()
                Settings.StealHelperConn = nil
            end
        end
    end
})
-- ========== SERVER TAB ==========

local ServerTab = Tabs.Main:Tab({
    Title = "Server",
    Icon = "server",
    Locked = false,
})

-- Server age display
local ServerAgeDisplay = ServerTab:Input({
    Title = "Server Age",
    Desc = "How long this server has been running",
    Value = "Loading...",
    Type = "Textarea",
    Callback = function() end
})

-- Update server age display
task.spawn(function()
    while task.wait(1) do
        local total = math.floor(workspace.DistributedGameTime)
        local days = math.floor(total / 86400)
        local hours = math.floor((total % 86400) / 3600)
        local minutes = math.floor((total % 3600) / 60)
        local seconds = total % 60
        local timeStr = string.format("%02i:%02i:%02i:%02i", days, hours, minutes, seconds)
        ServerAgeDisplay:Set(timeStr)
    end
end)

-- Job ID display
ServerTab:Code({
    Title = "Job ID",
    Code = string.format("%q", game.JobId),
})

-- Join by Job ID
ServerTab:Input({
    Title = "Join Job ID",
    Desc = "Paste a valid Job ID to teleport",
    Placeholder = "Enter Job ID",
    Type = "Input",
    Callback = function(jobId)
        if jobId and jobId ~= "" then
            TeleportService:TeleportToPlaceInstance(PlaceId, jobId, player)
        end
    end
})

-- Server hop function
ServerTab:Button({
    Title = "Server Hop",
    Desc = "Hop to a new server",
    Callback = function()
        local Dialog = Window:Dialog({
            Icon = "message-circle-more",
            Title = "Confirm Rejoin Server",
            Content = "Do you want rejoin the server?",
            Buttons = {
                {
                    Title = "Yes",
                    Callback = function()
                        local servers = {}
                        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
                        local body = HttpService:JSONDecode(req)

                        if body and body.data then
                            for i, v in next, body.data do
                                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                                    table.insert(servers, 1, v.id)
                                end
                            end
                        end

                        if #servers > 0 then
                            TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
                        else
                            notify("Server Hop", "Couldn't find a server.")
                        end
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function() end,
                },
            },
        })
    end
})

-- Rejoin server function
ServerTab:Button({
    Title = "Rejoin Server",
    Desc = "Rejoin the current server",
    Callback = function()
        local Dialog = Window:Dialog({
            Icon = "message-circle-more",
            Title = "Confirm Rejoin Server",
            Content = "Do you want rejoin the server?",
            Buttons = {
                {
                    Title = "Yes",
                    Callback = function()
                        if #Players:GetPlayers() <= 1 then
                            player:Kick("\nRejoining...")
                            wait()
                            TeleportService:Teleport(PlaceId)
                        else
                            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
                        end
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function() end,
                },
            },
        })
    end
})

-- ========== VISUALS TAB ==========

local Visuals = Tabs.Utility:Tab({
    Title = "Visuals",
    Icon = "eye",
    Locked = false
})

-- Player ESP toggle
Visuals:Toggle({
    Title = "Player ESP",
    Desc = "",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        Settings.Visuals.PlayerESP.Enabled = state
        if state == true then
            for _, player in next, Players:GetPlayers() do
                if player ~= Players.LocalPlayer then
                    ESP(player, true)
                end
            end
        else
            for i, c in pairs(CoreGui:GetChildren()) do
                if string.sub(c.Name, -4) == '_ESP' then
                    c:Destroy()
                end
            end
        end
    end
})

Visuals:Toggle({
  Title = "Base Timer ESP",
  Desc = "",
  Type = "Checkbox",
  Default = false,
  Callback = function(state)
    Settings.Visuals.PlotTimerESP.Enabled = state
    if state then
      task.spawn(PlotTimers)
      else
      task.spawn(ClearLabels)
    end
  end
})

Visuals:Toggle({
  Title = "Highest Value Brainrot ESP",
	Desc = "Targets the pet generats the most money",
	Type = "Checkbox",
	Default = false,
	Callback = function(state)
    Settings.Visuals.BestBrainRotESP.Enabled = state
end
})

local MiscTab = Tabs.Utility:Tab({
  Title = "Misc",
  Icon = "bird",
  Locked = false
})

local itemsName = MiscTab:Dropdown({
    Title = "Select Item",
    Values = ItemNames(),
    Value = "",
    Multi = true,
    AllowNone = true,
    Callback = function(option) end
})

MiscTab:Button({
    Title = "Buy Item",
    Desc = "Buy the Selected Items",
    Callback = function()
        if itemsName.Value then
            for _, name in next, itemsName.Value do
                Net["RF/CoinsShopService/RequestBuy"]:FireServer(name)
            end
        end
    end
})

-- ========== CONFIG TAB ==========

local ConfigTab = Tabs.Configuration:Tab({
    Title = "Configs",
    Icon = "file-cog",
    Locked = false,
})

-- Config manager setup
local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("ConfigsData")

-- Save config button
ConfigTab:Button({
    Title = "Save",
    Desc = "Saves elements to config",
    Callback = function()
        myConfig:Save()
    end
})

-- Load config button
ConfigTab:Button({
    Title = "Load",
    Desc = "Loads elements from config",
    Callback = function()
        myConfig:Load()
    end,
})

-- Load config on startup
myConfig:Load()

