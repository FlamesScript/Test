local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Lighting = cloneref(game:GetService("Lighting"))

local player = Players.LocalPlayer

local Net = ReplicatedStorage.Packages.Net

local HubVerion = "v1.0.0"
local Plots = Workspace.Plots
local PlaceId = game.PlaceId
local JobId = game.JobId

-->> GLOBAL SETTINGS <<--
getgenv().Settings = {
    StealHelper = {AntihitConn = nil},
    InfiniteJump = {Conn = nil, AddedConn = nil},
    WalkSpeed = {
        SmallSpeed = 45,
        SpeedBoost = 72,
        MaxSpeed = 100,
        Conn = nil,
        AddedConn = nil
    },
    AntiRagdoll = {Conn = nil},
    AntiTrap = {Conn = nil},
    Visuals = {
        PlayerESP = {Enabled = false},
        BestBrainRotESP = {Enabled = false},
        PlotTimerESP = {Enabled = false}
    }
}

-->> {FUNCTIONS} <<--

-->> LocalPlayer Plot <<--
local function GetMyPlot()
    for _, plot in next, Plots:GetChildren() do
        if plot:FindFirstChild("YourBase", true) and plot:FindFirstChild("YourBase", true).Enabled then
            return plot
        end
    end
    return nil
end

-->> Character (func)
function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

--> FindTool (func)
local function findTool(name)
    return player.Character:FindFirstChild(name) or player.Backpack:FindFirstChild(name)
end

-- ========== ESP FUNCTIONS ==========

-- Creates ESP for players
function ESP(plr, logic)
    task.spawn(
        function()
            -- Clean up existing ESP
            for _, v in pairs(CoreGui:GetChildren()) do
                if v.Name == plr.Name .. "_ESP" then
                    v:Destroy()
                end
            end

            if plr.Character and plr.Name ~= player.Name and not CoreGui:FindFirstChild(plr.Name .. "_ESP") then
                local ESPholder = Instance.new("Folder")
                ESPholder.Name = plr.Name .. "_ESP"
                ESPholder.Parent = CoreGui

                repeat
                    task.wait(1)
                until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and
                    plr.Character:FindFirstChildOfClass("Humanoid")

                -- Box adornments
                for _, n in pairs(plr.Character:GetChildren()) do
                    if n:IsA("BasePart") then
                        local a = Instance.new("BoxHandleAdornment")
                        a.Name = plr.Name
                        a.Parent = ESPholder
                        a.Adornee = n
                        a.AlwaysOnTop = true
                        a.ZIndex = 10
                        a.Size = n.Size
                        a.Transparency = 0.3
                        a.Color =
                            BrickColor.new(
                            logic and (plr.TeamColor == player.TeamColor and "Bright green" or "Bright red") or "White"
                        )
                    end
                end

                -- Name tag
                if plr.Character and plr.Character:FindFirstChild("Head") then
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
                    TextLabel.ZIndex = 10
                    TextLabel.Text = "Name: " .. plr.Name

                    -- ESP loop
                    local function espLoop()
                        if CoreGui:FindFirstChild(plr.Name .. "_ESP") then
                            if
                                plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and
                                    plr.Character:FindFirstChildOfClass("Humanoid") and
                                    player.Character and
                                    player.Character:FindFirstChild("HumanoidRootPart") and
                                    player.Character:FindFirstChildOfClass("Humanoid")
                             then
                                local pos =
                                    math.floor(
                                    (GetCharacter().HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                                )
                                TextLabel.Text = "Name: " .. plr.Name .. " | Studs: " .. pos
                            end
                        else
                            -- Disconnect everything
                            if teamChange then
                                teamChange:Disconnect()
                            end
                            if addedFunc then
                                addedFunc:Disconnect()
                            end
                            if espLoopFunc then
                                espLoopFunc:Disconnect()
                            end
                            if plrAdded then
                                plrAdded:Disconnect()
                            end
                        end
                    end

                    local espLoopFunc = RunService.RenderStepped:Connect(espLoop)

                    local teamChange = nil
                    teamChange =
                        plr:GetPropertyChangedSignal("TeamColor"):Connect(
                        function()
                            if Settings.Visuals.PlayerESP.Enabled then
                                if espLoopFunc then
                                    espLoopFunc:Disconnect()
                                end
                                if addedFunc then
                                    addedFunc:Disconnect()
                                end
                                if plrAdded then
                                    plrAdded:Disconnect()
                                end
                                ESPholder:Destroy()
                                repeat
                                    task.wait(1)
                                until plr.Character:FindFirstChild("HumanoidRootPart") and
                                    plr.Character:FindFirstChildOfClass("Humanoid")
                                ESP(plr, logic)
                            end
                            if teamChange then
                                teamChange:Disconnect()
                            end
                        end
                    )

                    local addedFunc
                    addedFunc =
                        plr.CharacterAdded:Connect(
                        function()
                            if Settings.Visuals.PlayerESP.Enabled then
                                if espLoopFunc then
                                    espLoopFunc:Disconnect()
                                end
                                if teamChange then
                                    teamChange:Disconnect()
                                end
                                if plrAdded then
                                    plrAdded:Disconnect()
                                end
                                ESPholder:Destroy()
                                repeat
                                    task.wait(1)
                                until plr.Character:FindFirstChild("HumanoidRootPart") and
                                    plr.Character:FindFirstChildOfClass("Humanoid")
                                ESP(plr, logic)
                            end
                            if addedFunc then
                                addedFunc:Disconnect()
                            end
                        end
                    )

                    local plrAdded
                    plrAdded =
                        Players.PlayerAdded:Connect(
                        function(p)
                            if Settings.Visuals.PlayerESP.Enabled then
                                ESP(p, logic)
                            end
                        end
                    )
                end
            end
        end
    )
end

local function parseEarn(str)
	local num = tonumber(str:match("%$([%d%.]+)"))
	local suf = str:match("([KMB])/s")
	if not num then return nil end
	if suf == "K" then
		num = num * 1000
	elseif suf == "M" then
		num = num * 1000000
	elseif suf == "B" then
		num = num * 1000000000
	end
	return num
end

-- Get best plot earnings
local function getPlotEarnings(plot)
    local pods = plot:FindFirstChild("AnimalPodiums")
    local bestDisplay, bestEarnTxt, bestVal = nil, nil, -math.huge
    local bestDeco, bestRarity = nil, ""
    local displayLabel, generationLabel, rarityLabel = nil, nil, nil

    if not pods then
        return
    end

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
RunService.Heartbeat:Connect(
    function()
        local best = findBestEarner()
        if not best or not best.deco then
            return
        end

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
            if best.deco:FindFirstChild("ESP") then
                best.deco.ESP:Destroy()
            end
            local oldHL = best.deco:FindFirstChildWhichIsA("Highlight")
            if oldHL then
                oldHL:Destroy()
            end

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
                if gui then
                    gui.Enabled = Settings.Visuals.BestBrainRotESP.Enabled
                end
                if hl then
                    hl.Enabled = Settings.Visuals.BestBrainRotESP.Enabled
                end
            end
        end
    end
)

-- ========== UI SETUP ==========
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window =
    WindUI:CreateWindow(
    {
        Title = "Steal A Brainrot | {HubVerion}",
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
            Callback = function()
            end
        }
    }
)

-- Customize UI open button
Window:EditOpenButton(
    {
        Title = "Open UI",
        Icon = "monitor",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true
    }
)

local function notify(title, content, duration)
    WindUI:Notify(
        {
            Title = title,
            Content = content,
            Icon = "droplet-off",
            Duration = duration or 5
        }
    )
end

local Success, Error =
    pcall(
    function()
        --> Main TAB <--
        local MainTab = Window:Tab({Title = "Main", Icon = "house", Locked = false})

        -- ========== Steal Helper ==========

        local StealHelperTab = Window:Tab({Title = "Steal Helper", Icon = "crown", Locked = false})

        local Antihit_Toggle
        Antihit_Toggle =
            StealHelperTab:Toggle(
            {
                Title = "Anti Hit",
                Desc = "Become unhittable for 10/s",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state then
                        if not findTool("Web Slinger") then
                            Antihit_Toggle:Set(false)
                            notify("Steal-Helper Tab", "Web Slinger not found")
                            return
                        end

                        if Settings.StealHelper.AntihitConn then
                            Settings.StealHelper.AntihitConn:Disconnect()
                        end

                        Settings.StealHelper.AntihitConn =
                            ProximityPromptService.PromptButtonHoldBegan:Connect(
                            function(prompt)
                                if prompt.Parent:IsA("Attachment") and prompt.ObjectText:lower() == "steal" then
                                    local Character = GetCharacter()
                                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                                    local WebSlinger = findTool("Web Slinger")

                                    if not WebSlinger then
                                        return
                                    end
                                    Humanoid:EquipTool(WebSlinger)
                                    Net["RE/UseItem"]:FireServer(
                                        Character.HumanoidRootPart.CFrame,
                                        Character.HumanoidRootPart,
                                        WebSlinger.Handle
                                    )
                                    Humanoid:GetPropertyChangedSignal("PlatformStand"):Once(
                                        function()
                                            if Humanoid.PlatformStand then
                                                Humanoid:ChangeState("Jumping")
                                                Humanoid.PlatformStand = false
                                            end
                                        end
                                    )
                                end
                            end
                        )
                    else
                        if Settings.StealHelper.AntihitConn then
                            Settings.StealHelper.AntihitConn:Disconnect()
                        end
                    end
                end
            }
        )
    end
)

if not Success then
    warn("StealHelperTab: |", Error)
end

--> PLAYER TAB <--
local Success, Error =
    pcall(
    function()
        local PlayerTab = Window:Tab({Title = "Player", Icon = "user", Locked = false})

        local Toggle_SmallSpeed, Toggle_SpeedBoost, Toggle_MaxSpeed

        Toggle_SmallSpeed =
            PlayerTab:Toggle(
            {
                Title = "Small Speed Boost",
                Desc = "Gives a small, speed boost",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        Toggle_SpeedBoost:Set(false)
                        Toggle_MaxSpeed:Set(false)

                        if Settings.WalkSpeed.Conn then
                            Settings.WalkSpeed.Conn:Disconnect()
                        end
                        if Settings.WalkSpeed.AddedConn then
                            Settings.WalkSpeed.AddedConn:Disconnect()
                        end

                        local char = GetCharacter()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hum then
                            return
                        end

                        hum.WalkSpeed = Settings.WalkSpeed.SmallSpeed

                        Settings.WalkSpeed.Conn =
                            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(
                            function()
                                if hum.WalkSpeed ~= Settings.WalkSpeed.SmallSpeed then
                                    hum.WalkSpeed = Settings.WalkSpeed.SmallSpeed
                                end
                            end
                        )

                        Settings.WalkSpeed.AddedConn =
                            player.CharacterAppearanceLoaded:Connect(
                            function(newchar)
                                if state == true then
                                    char = newchar
                                    local hum = char:WaitForChild("Humanoid")
                                    hum.WalkSpeed = Settings.WalkSpeed.SmallSpeed

                                    if Settings.WalkSpeed.Conn then
                                        Settings.WalkSpeed.Conn:Disconnect()
                                    end
                                    Settings.WalkSpeed.Conn =
                                        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(
                                        function()
                                            if hum.WalkSpeed ~= Settings.WalkSpeed.SmallSpeed then
                                                hum.WalkSpeed = Settings.WalkSpeed.SmallSpeed
                                            end
                                        end
                                    )
                                end
                            end
                        )
                    else
                        if Settings.WalkSpeed.Conn then
                            Settings.WalkSpeed.Conn:Disconnect()
                        end
                        if Settings.WalkSpeed.AddedConn then
                            Settings.WalkSpeed.AddedConn:Disconnect()
                        end
                    end
                end
            }
        )

        Toggle_SpeedBoost =
            PlayerTab:Toggle(
            {
                Title = "Speed Boost",
                Desc = "Boosts your speed if you have a Coil",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        local tool = findTool("Coil")

                        if not tool then
                            Toggle_SpeedBoost:Set(false)
                            notify("PlayerTab", "Coil tool not found")
                            return
                        end

                        Toggle_SmallSpeed:Set(false)
                        Toggle_MaxSpeed:Set(false)

                        if Settings.WalkSpeed.Conn then
                            Settings.WalkSpeed.Conn:Disconnect()
                        end
                        if Settings.WalkSpeed.AddedConn then
                            Settings.WalkSpeed.AddedConn:Disconnect()
                        end

                        local char = GetCharacter()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hum then
                            return
                        end

                        hum:EquipTool(tool)
                        tool:Activate()
                        hum.WalkSpeed = Settings.WalkSpeed.SpeedBoost
                        hum:UnequipTools()

                        Settings.WalkSpeed.Conn =
                            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(
                            function()
                                if hum.WalkSpeed ~= Settings.WalkSpeed.SpeedBoost then
                                    hum.WalkSpeed = Settings.WalkSpeed.SpeedBoost
                                end
                            end
                        )

                        Settings.WalkSpeed.AddedConn =
                            player.CharacterAppearanceLoaded:Connect(
                            function(newchar)
                                if state == true then
                                    char = newchar
                                    local hum = char:WaitForChild("Humanoid")
                                    hum.WalkSpeed = Settings.WalkSpeed.SpeedBoost

                                    if Settings.WalkSpeed.Conn then
                                        Settings.WalkSpeed.Conn:Disconnect()
                                    end
                                    Settings.WalkSpeed.Conn =
                                        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(
                                        function()
                                            if hum.WalkSpeed ~= Settings.WalkSpeed.SpeedBoost then
                                                hum.WalkSpeed = Settings.WalkSpeed.SpeedBoost
                                            end
                                        end
                                    )
                                end
                            end
                        )
                    else
                        if Settings.WalkSpeed.Conn then
                            Settings.WalkSpeed.Conn:Disconnect()
                        end
                        if Settings.WalkSpeed.AddedConn then
                            Settings.WalkSpeed.AddedConn:Disconnect()
                        end
                    end
                end
            }
        )

        Toggle_MaxSpeed =
            PlayerTab:Toggle(
            {
                Title = "Max Speed",
                Desc = "Gives max speed if you have a Cloak",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        local tool = findTool("Cloak")

                        if not tool then
                            Toggle_MaxSpeed:Set(false)
                            notify("PlayerTab", "Cloak tool not found")
                            return
                        end

                        Toggle_SmallSpeed:Set(false)
                        Toggle_SpeedBoost:Set(false)

                        if Settings.WalkSpeed.Conn then
                            Settings.WalkSpeed.Conn:Disconnect()
                        end
                        if Settings.WalkSpeed.AddedConn then
                            Settings.WalkSpeed.AddedConn:Disconnect()
                        end

                        local char = GetCharacter()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hum then
                            return
                        end

                        hum:EquipTool(tool)
                        tool:Activate()
                        hum.WalkSpeed = Settings.WalkSpeed.MaxSpeed
                        hum:UnequipTools()

                        Settings.WalkSpeed.Conn =
                            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(
                            function()
                                if hum.WalkSpeed ~= Settings.WalkSpeed.MaxSpeed then
                                    hum.WalkSpeed = Settings.WalkSpeed.MaxSpeed
                                end
                            end
                        )

                        Settings.WalkSpeed.AddedConn =
                            player.CharacterAppearanceLoaded:Connect(
                            function(newchar)
                                if state == true then
                                    char = newchar
                                    local hum = char:WaitForChild("Humanoid")
                                    hum.WalkSpeed = Settings.WalkSpeed.MaxSpeed

                                    if Settings.WalkSpeed.Conn then
                                        Settings.WalkSpeed.Conn:Disconnect()
                                    end
                                    Settings.WalkSpeed.Conn =
                                        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(
                                        function()
                                            if hum.WalkSpeed ~= Settings.WalkSpeed.MaxSpeed then
                                                hum.WalkSpeed = Settings.WalkSpeed.MaxSpeed
                                            end
                                        end
                                    )
                                end
                            end
                        )
                    else
                        if Settings.WalkSpeed.Conn then
                            Settings.WalkSpeed.Conn:Disconnect()
                        end
                        if Settings.WalkSpeed.AddedConn then
                            Settings.WalkSpeed.AddedConn:Disconnect()
                        end
                    end
                end
            }
        )

        local EnableJumpPower_toggle

        -->> Infinite Jump toggle
        local InfiniteJump_toggle =
            PlayerTab:Toggle(
            {
                Title = "InfiniteJump",
                Desc = "",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        if Settings.InfiniteJump.Conn then
                            Settings.InfiniteJump.Conn:Disconnect()
                        end
                        if Settings.InfiniteJump.AddedConn then
                            Settings.InfiniteJump.AddedConn:Disconnect()
                        end

                        Settings.InfiniteJump.Conn =
                            UserInputService.JumpRequest:Connect(
                            function()
                                if not state then
                                    return
                                end
                                local char = GetCharacter()
                                local hum = char:FindFirstChildOfClass("Humanoid")

                                if hum then
                                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                    hum.HealthChanged:Once(
                                        function()
                                            hum.Health = 100
                                        end
                                    )
                                end
                            end
                        )

                        Settings.InfiniteJump.AddedConn =
                            player.CharacterAppearanceLoaded:Connect(
                            function(newchar)
                                if not state then
                                    return
                                end
                                char = newchar
                                local hum = char:WaitForChild("Humanoid")

                                if Settings.InfiniteJump.Conn then
                                    Settings.InfiniteJump.Conn:Disconnect()
                                end

                                Settings.InfiniteJump.Conn =
                                    UserInputService.JumpRequest:Connect(
                                    function()
                                        if not state then
                                            return
                                        end
                                        local char = GetCharacter()
                                        local hum = char:FindFirstChildOfClass("Humanoid")

                                        if hum then
                                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                            hum.HealthChanged:Once(
                                                function()
                                                    hum.Health = 100
                                                end
                                            )
                                        end
                                    end
                                )
                            end
                        )
                    else
                        if Settings.InfiniteJump.Conn then
                            Settings.InfiniteJump.Conn:Disconnect()
                        end
                        if Settings.InfiniteJump.AddedConn then
                            Settings.InfiniteJump.AddedConn:Disconnect()
                        end
                    end
                end
            }
        )

        PlayerTab:Slider(
            {
                Title = "Jump Boost",
                Step = 1,
                Value = {
                    Min = 50,
                    Max = 1000,
                    Default = 50
                },
                Callback = function(value)
                    getgenv().JumpBoostSliderValue = value
                end
            }
        )

        EnableJumpPower_toggle =
            PlayerTab:Toggle(
            {
                Title = "Enable JumpBoost",
                Desc = "",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        local char = GetCharacter()
                        local humanoid = char:FindFirstChildOfClass("Humanoid")

                        if not humanoid then
                            return
                        end

                        humanoid.UseJumpPower = true
                        humanoid.JumpPower = getgenv().JumpBoostSliderValue or 50

                        Settings.InfiniteJump.AddedConn =
                            player.CharacterAppearanceLoaded:Connect(
                            function(newchar)
                                if not state then
                                    return
                                end
                                char = newchar
                                local hum = char:WaitForChild("Humanoid")

                                humanoid.UseJumpPower = true
                                humanoid.JumpPower = getgenv().JumpBoostSliderValue or 50
                            end
                        )
                    else
                        local char = GetCharacter()
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.UseJumpPower = true
                            humanoid.JumpPower = 50
                        end
                        if Settings.InfiniteJump.AddedConn then
                            Settings.InfiniteJump.AddedConn:Disconnect()
                        end
                    end
                end
            }
        )
    end
)

if not Success then
    warn("PlayerTab: |", Error)
end

local Success, Error =
    pcall(
    function()
        local HelperTab = Window:Tab({Title = "Helper", Icon = "briefcase-medical", Locked = false})

        HelperTab:Toggle(
            {
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
                            if string.sub(c.Name, -4) == "_ESP" then
                                c:Destroy()
                            end
                        end
                    end
                end
            }
        )

        HelperTab:Toggle(
            {
                Title = "Lock Timer ESP",
                Desc = "",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        local LastRemainingTimes = {}
                        local LastUpdateTimestamps = {}

                        while task.wait() and state do
                            if not state then
                                break
                            end
                            for _, plot in ipairs(workspace.Plots:GetChildren()) do
                                local hitbox = plot:FindFirstChild("FriendPanel", true)
                                local remaining = plot:FindFirstChild("RemainingTime", true)
                                local yourBase = plot:FindFirstChild("YourBase", true)

                                if hitbox and remaining and yourBase then
                                    local gui = hitbox:FindFirstChild("PlotLabel")
                                    if not gui then
                                        gui = Instance.new("BillboardGui")
                                        gui.Name = "PlotLabel"
                                        gui.Adornee = hitbox
                                        gui.Size = UDim2.new(0, 100, 0, 30)
                                        gui.AlwaysOnTop = true
                                        gui.StudsOffset = Vector3.new(0, 3, 0)
                                        gui.Parent = hitbox

                                        local label = Instance.new("TextLabel")
                                        label.Name = "TextLabel"
                                        label.Size = UDim2.new(1, 0, 1, 0)
                                        label.BackgroundTransparency = 1
                                        label.TextScaled = true
                                        label.Font = Enum.Font.SourceSansSemibold
                                        label.Parent = gui

                                        local stroke = Instance.new("UIStroke")
                                        stroke.Thickness = 1
                                        stroke.Color = Color3.fromRGB(0, 0, 0)
                                        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                                        stroke.Parent = label
                                    end

                                    local label = gui:FindFirstChild("TextLabel")
                                    if label then
                                        label.TextColor3 =
                                            yourBase.Enabled and Color3.fromRGB(0, 255, 0) or
                                            Color3.fromRGB(255, 255, 255)

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
                                            label.Text = currentText
                                        end
                                    end
                                else
                                    LastRemainingTimes[plot] = nil
                                    LastUpdateTimestamps[plot] = nil
                                end
                            end
                        end
                    else
                        for _, plot in pairs(workspace.Plots:GetChildren()) do
                            local hitbox = plot:FindFirstChild("FriendPanel", true)
                            if hitbox then
                                local gui = hitbox:FindFirstChild("PlotLabel")
                                if gui then
                                    gui:Destroy()
                                end
                            end
                        end
                    end
                end
            }
        )

        HelperTab:Toggle(
            {
                Title = "Highest Value Brainrot ESP",
                Desc = "Targets the pet generats the most money",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    Settings.Visuals.BestBrainRotESP.Enabled = state
                end
            }
        )

        HelperTab:Toggle(
            {
                Title = "Anti Trap",
                Desc = "",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state == true then
                        if Settings.AntiTrap.Conn then
                            Settings.AntiTrap.Conn:Disconnect()
                        end

                        local function antiTrap()
                            for _, obj in pairs(Workspace:GetChildren()) do
                                if obj:IsA("Model") and obj.Name:lower() == ("trap") then
                                    for _, v in pairs(obj:GetChildren()) do
                                        if v.Name:lower() == ("open") and v:IsA("BasePart") then
                                            v:Destroy()
                                        end
                                    end
                                end
                            end
                        end

                        antiTrap()
                        Settings.AntiTrap.Conn = Workspace.ChildAdded:Connect(antiTrap)
                    else
                        if Settings.AntiTrap.Conn then
                            Settings.AntiTrap.Conn:Disconnect()
                        end
                    end
                end
            }
        )
    end
)

if not Success then
    warn("HelperTab: |", Error)
end

-->> SERVER TAB <<--
local Success, Error =
    pcall(
    function()
        local ServerTab =
            Window:Tab(
            {
                Title = "Server",
                Icon = "server",
                Locked = false
            }
        )

        -- Server age display
        local ServerTiming =
            ServerTab:Paragraph(
            {
                Title = "Server Timing",
                Desc = "N/A",
                Locked = false
            }
        )

        task.spawn(
            function()
                while task.wait(1) do
                    local total = math.floor(workspace.DistributedGameTime)
                    local days = math.floor(total / 86400)
                    local hours = math.floor((total % 86400) / 3600)
                    local minutes = math.floor((total % 3600) / 60)
                    local seconds = total % 60
                    local timeStr = string.format("%02i:%02i:%02i:%02i", days, hours, minutes, seconds)
                    ServerTiming:SetDesc(timeStr)
                end
            end
        )

        -- Job ID display
        ServerTab:Code(
            {
                Title = "Job ID",
                Code = string.format("%q", game.JobId)
            }
        )

        -- Join by Job ID
        ServerTab:Input(
            {
                Title = "Join Job ID",
                Desc = "Paste a valid Job ID to teleport",
                Placeholder = "Enter Job ID",
                Type = "Input",
                Callback = function(jobId)
                    if jobId and jobId ~= "" then
                        if #jobId == 36 then -- Basic validation for Job ID format
                            TeleportService:TeleportToPlaceInstance(PlaceId, jobId, player)
                        else
                            notify("Server", "Invalid Job ID format")
                        end
                    end
                end
            }
        )

        -- Server hop function
        ServerTab:Button(
            {
                Title = "Server Hop",
                Desc = "Hop to a new server",
                Callback = function()
                    local Dialog =
                        Window:Dialog(
                        {
                            Icon = "message-circle-more",
                            Title = "Confirm Rejoin Server",
                            Content = "Do you want rejoin the server?",
                            Buttons = {
                                {
                                    Title = "Yes",
                                    Callback = function()
                                        local servers = {}
                                        local success, req =
                                            pcall(
                                            function()
                                                return game:HttpGet(
                                                    "https://games.roblox.com/v1/games/" ..
                                                        PlaceId ..
                                                            "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
                                                )
                                            end
                                        )

                                        if success and req then
                                            local body = HttpService:JSONDecode(req)

                                            if body and body.data then
                                                for i, v in next, body.data do
                                                    if
                                                        type(v) == "table" and tonumber(v.playing) and
                                                            tonumber(v.maxPlayers) and
                                                            v.playing < v.maxPlayers and
                                                            v.id ~= JobId
                                                     then
                                                        table.insert(servers, 1, v.id)
                                                    end
                                                end
                                            end

                                            if #servers > 0 then
                                                TeleportService:TeleportToPlaceInstance(
                                                    PlaceId,
                                                    servers[math.random(1, #servers)],
                                                    Players.LocalPlayer
                                                )
                                            else
                                                notify("Server Hop", "Couldn't find a server.")
                                            end
                                        else
                                            notify("Server Hop", "Failed to fetch server list.")
                                        end
                                    end
                                },
                                {
                                    Title = "Cancel",
                                    Callback = function()
                                    end
                                }
                            }
                        }
                    )
                end
            }
        )

        -- Rejoin Server Btn
        ServerTab:Button(
            {
                Title = "Rejoin Server",
                Desc = "Rejoin the current server",
                Callback = function()
                    local Dialog =
                        Window:Dialog(
                        {
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
                                    Callback = function()
                                    end
                                }
                            }
                        }
                    )
                end
            }
        )

        -->> Low Graphics Toggle
        ServerTab:Toggle(
            {
                Title = "Low Graphics",
                Desc = "",
                Type = "Checkbox",
                Default = false,
                Callback = function(state)
                    if state then
                        local Terrain = workspace:FindFirstChildOfClass("Terrain")
                        Terrain.WaterWaveSize = 0
                        Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0
                        Terrain.WaterTransparency = 1

                        Lighting.GlobalShadows = false
                        Lighting.FogEnd = 9e9
                        Lighting.FogStart = 9e9

                        settings().Rendering.QualityLevel = 1

                        for _, v in pairs(game:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Material = "Plastic"
                                v.Reflectance = 0
                                v.BackSurface = "SmoothNoOutlines"
                                v.BottomSurface = "SmoothNoOutlines"
                                v.FrontSurface = "SmoothNoOutlines"
                                v.LeftSurface = "SmoothNoOutlines"
                                v.RightSurface = "SmoothNoOutlines"
                                v.TopSurface = "SmoothNoOutlines"
                            elseif v:IsA("Decal") then
                                v.Transparency = 1
                            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                                v.Lifetime = NumberRange.new(0)
                            end
                        end

                        for _, v in pairs(Lighting:GetDescendants()) do
                            if v:IsA("PostEffect") then
                                v.Enabled = false
                            end
                        end

                        workspace.DescendantAdded:Connect(
                            function(child)
                                task.spawn(
                                    function()
                                        if
                                            child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or
                                                child:IsA("Fire") or
                                                child:IsA("Beam")
                                         then
                                            RunService.Heartbeat:Wait()
                                            child:Destroy()
                                        end
                                    end
                                )
                            end
                        )
                    end
                end
            }
        )
    end
)

if not Success then
    warn("ServerTab: |", Error)
end

local ConfigTab =
    Window:Tab(
    {
        Title = "Configs",
        Icon = "file-cog",
        Locked = false
    }
)

-- Config manager setup
local ConfigManager = Window.ConfigManager

local myConfig = ConfigManager:CreateConfig("SaveData")

-- myConfig:Register()

-- Save config button
ConfigTab:Button(
    {
        Title = "Save",
        Desc = "Saves elements to config",
        Callback = function()
            local success, err =
                pcall(
                function()
                    myConfig:Save()
                end
            )
            notify("Config", success and "Settings saved successfully" or "Failed to save: " .. tostring(err))
        end
    }
)

-- Load config button
ConfigTab:Button(
    {
        Title = "Load",
        Desc = "Loads elements from config",
        Callback = function()
            local success, err =
                pcall(
                function()
                    myConfig:Load()
                end
            )
            notify("Config", success and "Settings loaded successfully" or "Failed to load: " .. tostring(err))
        end
    }
)
