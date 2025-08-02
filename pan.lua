local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))

local player = Players.LocalPlayer

function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local toggled = false

local function CreateToggle(uiButton, callback)
    uiButton.MouseButton1Click:Connect(
        function()
            toggled = not toggled
            callback(toggled)
        end
    )
end

local G2L = {}

G2L["CoolBoyGui_1"] = Instance.new("ScreenGui", gethui and gethui() or CoreGui)
G2L["CoolBoyGui_1"]["DisplayOrder"] = 20
G2L["CoolBoyGui_1"]["Name"] = [[CoolBoyGui]]
G2L["CoolBoyGui_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
G2L["CoolBoyGui_1"]["ResetOnSpawn"] = false

G2L["MainFrame_2"] = Instance.new("Frame", G2L["CoolBoyGui_1"])
G2L["MainFrame_2"]["Active"] = true
G2L["MainFrame_2"]["BorderSizePixel"] = 0
G2L["MainFrame_2"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31)
G2L["MainFrame_2"]["Size"] = UDim2.new(0.16913, 0, 0.36909, 0)
G2L["MainFrame_2"]["Position"] = UDim2.new(0.43905, 0, 0.22868, 0)
G2L["MainFrame_2"]["Name"] = [[MainFrame]]
G2L["MainFrame_2"]["Draggable"] = true

G2L["UICorner_3"] = Instance.new("UICorner", G2L["MainFrame_2"])

G2L["TextButton2_4"] = Instance.new("TextButton", G2L["MainFrame_2"])
G2L["TextButton2_4"]["TextStrokeTransparency"] = 0
G2L["TextButton2_4"]["BorderSizePixel"] = 0
G2L["TextButton2_4"]["TextSize"] = 18
G2L["TextButton2_4"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextButton2_4"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 51)
G2L["TextButton2_4"]["FontFace"] =
    Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
G2L["TextButton2_4"]["Size"] = UDim2.new(0.9, 0, 0.2, 0)
G2L["TextButton2_4"]["Name"] = "Server Hop"
G2L["TextButton2_4"]["Position"] = UDim2.new(0.05051, 0, 0.55, 0)
G2L["TextButton2_4"]["Active"] = true

G2L["UICorner_5"] = Instance.new("UICorner", G2L["TextButton2_4"])

G2L["TextLabel_6"] = Instance.new("TextLabel", G2L["MainFrame_2"])
G2L["TextLabel_6"]["TextWrapped"] = false
G2L["TextLabel_6"]["Active"] = true
G2L["TextLabel_6"]["TextStrokeTransparency"] = 0
G2L["TextLabel_6"]["BorderSizePixel"] = 0
G2L["TextLabel_6"]["TextSize"] = 20
G2L["TextLabel_6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel_6"]["FontFace"] =
    Font.new([[rbxasset://fonts/families/LuckiestGuy.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
G2L["TextLabel_6"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextLabel_6"]["BackgroundTransparency"] = 1
G2L["TextLabel_6"]["Size"] = UDim2.new(1, 0, 0.15, 0)
G2L["TextLabel_6"]["Text"] = [[Steal A Brainrot]]

G2L["TextButton_7"] = Instance.new("TextButton", G2L["MainFrame_2"])
G2L["TextButton_7"]["TextStrokeTransparency"] = 0
G2L["TextButton_7"]["BorderSizePixel"] = 0
G2L["TextButton_7"]["TextSize"] = 18
G2L["TextButton_7"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
G2L["TextButton_7"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 51)
G2L["TextButton_7"]["FontFace"] =
    Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
G2L["TextButton_7"]["Size"] = UDim2.new(0.9, 0, 0.2, 0)
G2L["TextButton_7"]["Position"] = UDim2.new(0.05051, 0, 0.27826, 0)
G2L["TextButton_7"]["Text"] = [[Start]]

G2L["UICorner_8"] = Instance.new("UICorner", G2L["TextButton_7"])

G2L["UIAspectRatioConstraint_9"] = Instance.new("UIAspectRatioConstraint", G2L["MainFrame_2"])
G2L["UIAspectRatioConstraint_9"]["AspectRatio"] = 1.07609

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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

CreateToggle(
    G2L["TextButton_7"],
    function(state)
        local conn = nil

        if state == true then
            if conn then
                conn:Disconnect()
            end

            conn =
                ProximityPromptService.PromptTriggered:Connect(
                function(prompt)
                    if ((prompt:GetAttribute("Steal") == "Steal") or (prompt.ActionText == "Steal")) and state then
                        local char = GetCharacter()
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        local rootPart = char:FindFirstChild("HumanoidRootPart")

                        rootPart.Anchored = true
                        G2L["TextButton_7"]["Text"] = "Stop"

                        humanoid.StateChanged:Once(
                            function(_, newState)
                                if
                                    newState == Enum.HumanoidStateType.Physics or
                                        newState == Enum.HumanoidStateType.Ragdoll or
                                        newState == Enum.HumanoidStateType.FallingDown
                                 then
                                    for _, v in workspace:GetDescendants() do
                                        if v:IsA("ProximityPrompt") then
                                            local obj = v.Parent
                                            local distance = (char.HumanoidRootPart.Position - obj.WorldPosition).Magnitude
                                            if distance > 5 then
                                                pcall(
                                                    function()
                                                        v:InputHoldBegin()
                                                    end
                                                )
                                            else
                                                rootPart.Anchored = false
                                                G2L["TextButton_7"]["Text"] = "Start"
                                            end
                                        end
                                    end
                                end
                            end
                        )
                    end
                end
            )
        else
            GetCharacter():FindFirstChild("HumanoidRootPart").Anchored = false
        end
    end
)

CreateToggle(
    G2L["TextButton2_4"],
    function(state)
        local servers = {}
        local PlaceId = game.PlaceId
        local JobId = game.JobId

        local success, req =
            pcall(
            function()
                return game:HttpGet(
                    "https://games.roblox.com/v1/games/" ..
                        PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
                )
            end
        )

        if success and req then
            local body = HttpService:JSONDecode(req)

            if body and body.data then
                for _, v in ipairs(body.data) do
                    if
                        type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and
                            v.playing < v.maxPlayers and
                            v.id ~= JobId
                     then
                        table.insert(servers, v.id)
                    end
                end
            end

            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
            else
                notify("Server Hop", "Couldn't find a server.")
            end
        else
            notify("Server Hop", "Failed to fetch server list.")
        end
    end
)

local function parseEarn(str)
    local num = tonumber(str:match("%$([%d%.]+)"))
    local suf = str:match("([KMB])/s")
    if not num then
        return nil
    end
    if suf == "K" then
        num = num * 1000
    elseif suf == "M" then
        num = num * 1000000
    elseif suf == "B" then
        num = num * 1000000000
    end
    return num
end

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

local Plots = workspace.Plots

local function GetMyPlot()
    for _, plot in next, Plots:GetChildren() do
        if plot:FindFirstChild("YourBase", true) and plot:FindFirstChild("YourBase", true).Enabled then
            return plot
        end
    end
    return nil
end

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
local BestBrainRotESP = true

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
            highlight.Enabled = BestBrainRotESP
            highlight.Parent = best.deco

            -- Create Billboard GUI
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP"
            billboard.Adornee = best.deco
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 13, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = BestBrainRotESP
            billboard.Parent = best.deco

            local function makeLabel(order, text, source)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Position = UDim2.new(0, 0, 0, (order - 1) * 20)
                label.BackgroundTransparency = 1
                label.TextColor3 = (source and source.TextColor3) or Color3.new(1, 1, 1)
                label.TextStrokeTransparency = 0.5
                label.Font = Enum.Font.SourceSansSemibold
                label.TextStrokeTransparency = 0
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
                    gui.Enabled = BestBrainRotESP
                end
                if hl then
                    hl.Enabled = BestBrainRotESP
                end
            end
        end
    end
)
