local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game.CoreGui
local kiwi = CoreGui:FindFirstChild("kiwiGui")

if kiwi then
    kiwi:Destroy()
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "kiwiGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.Position = UDim2.new(0.4, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.Active = true
Frame.Draggable = true

local frameUICorner = Instance.new("UICorner", Frame)
frameUICorner.Name = "frameUICorner"
frameUICorner.CornerRadius = UDim.new(0, 10)  
frameUICorner.Parent = Frame 

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 20)
ToggleButton.Text = "Spam: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(240, 240, 240)
ToggleButton.TextScaled = true

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(0, 200, 0, 30)
Label.Position = UDim2.new(0, 10, 0, 70)
Label.Text = "Made by FlamesEvo"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.BackgroundTransparency = 1
Label.TextScaled = true

-- Variables
local Spamming = false
local gold = workspace:FindFirstChild("Gudock") -- Ensure it exists
local lplr, chr = game:GetService("Players").LocalPlayer, nil
local function getchr()
    return lplr.Character or lplr.CharacterAdded:Wait()
 end
 pchr = getchr()
 
 local hrp = pchr:FindFirstChild("HumanoidRootPart")
  if hrp and gold then
  hrp.CFrame = gold.CFrame * CFrame.new(10, 0, 0)
end
  
-- Function to spam Touch Interest safely and extremely fast
local function spamTouch()
    while Spamming do
        for _, part in pairs(workspace:GetChildren()) do
            if not Spamming then return end -- **Exit if toggled off**
            chr = getchr()
            if part:IsA("BasePart") and part:FindFirstChildWhichIsA("TouchTransmitter") and part.Name == "사라지는 파트" and part.CanCollide = true then
                firetouchinterest(chr.HumanoidRootPart, part, 0)
                firetouchinterest(chr.HumanoidRootPart, part, 1)

                if gold and gold:IsA("BasePart") and gold.CanCollide == true then
                    firetouchinterest(chr.HumanoidRootPart, gold, 0)
                    firetouchinterest(chr.HumanoidRootPart, gold, 1)
                end
            end
        end
        task.wait(0.1) -- Prevents freezing
    end
end

-- Toggle Spam
ToggleButton.MouseButton1Click:Connect(function()
    Spamming = not Spamming
    ToggleButton.Text = Spamming and "Spam: ON" or "Spam: OFF"
    ToggleButton.BackgroundColor3 = Spamming and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    if Spamming then
        task.spawn(spamTouch) -- Runs in a separate thread, but can stop when toggled
    end
end)

lplr.CharacterAppearanceLoaded:Connect(function()
    local chr = getchr()
    local hrp = chr:WaitForChild("HumanoidRootPart")
    if hrp and gold then
        hrp.CFrame = gold.CFrame * CFrame.new(10, 0, 0)
    end
end)
