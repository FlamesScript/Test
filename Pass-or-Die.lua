local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesScript/Master/refs/heads/main/SimpleLib.lua"))()

local window = library:CreateWindow("Pass or Die")

getgenv().a5 = nil

local directions = { "Forward", "Left", "Right" }
local event = game:GetService("ReplicatedStorage").Gameplay.Core.Default.Remotes.Pass
local bombsFolder = workspace:FindFirstChild("Bombs")

window:AddToggle({
    text = "Auto Pass",
    state = false,
    callback = function(state)
        getgenv().a5 = state
        if state then
            -- Start loop only when toggled on
            task.spawn(function()
                while getgenv().a5 and task.wait() do
                    if bombsFolder and #bombsFolder:GetChildren() >= 1 then
                        local randomDirection = directions[math.random(1, #directions)]
                        event:InvokeServer(randomDirection)
                    end
                end
            end)
        end
    end
})

window:AddLabel({ text = "Made By: FlamesEvo " })

library:Init()
