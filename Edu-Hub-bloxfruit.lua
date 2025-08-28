-- Edu Hub Advanced GUI with Teleport/NPC Selection and Tab Animation
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EduHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 600)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "Edu Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.Parent = mainFrame

-- Tab Buttons Frame
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1,0,0,50)
tabFrame.Position = UDim2.new(0,0,0,50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local function createTab(name, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 40)
    btn.Position = UDim2.new(0, xPos, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(100,0,0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = tabFrame
    return btn
end

local tabs = {
    Combat = createTab("Combat", 10),
    Farming = createTab("Farming", 110),
    Teleports = createTab("Teleports", 220),
    Extra = createTab("Extra", 330)
}

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,0,1,-100)
contentFrame.Position = UDim2.new(0,0,0,100)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Toggles table
local toggles = {}

-- Example icons (replace with your own decals)
local iconUrls = {
    AutoFarm = "rbxassetid://8561234567",
    AutoQuest = "rbxassetid://8561234568",
    AutoLevel = "rbxassetid://8561234569",
    AutoAbility = "rbxassetid://8561234570",
    AutoTeleport = "rbxassetid://8561234571",
    ExtraFun = "rbxassetid://8561234572"
}

-- Tab Containers
local tabContents = {}
for tabName,_ in pairs(tabs) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.Position = UDim2.new(1,0,0,0) -- start off-screen for animation
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = contentFrame
    tabContents[tabName] = frame
end

-- Button creator with icon
local function createButton(name, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85,0,0,50)
    btn.Position = UDim2.new(0.075,0,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(80,0,0)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = name..": OFF"
    btn.Parent = parent

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0,32,0,32)
    icon.Position = UDim2.new(0,5,0.5,-16)
    icon.BackgroundTransparency = 1
    icon.Image = iconUrls[name]
    icon.Parent = btn

    toggles[name] = false
    btn.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        btn.Text = toggles[name] and name..": ON" or name..": OFF"
    end)
end

-- Create buttons
createButton("AutoFarm", tabContents["Combat"])
createButton("AutoAbility", tabContents["Combat"])
createButton("AutoQuest", tabContents["Farming"])
createButton("AutoLevel", tabContents["Farming"])
createButton("AutoTeleport", tabContents["Teleports"])
createButton("ExtraFun", tabContents["Extra"])

-- Dropdowns for Teleport points
local function createDropdown(name, options, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9,0,0,30)
    frame.Position = UDim2.new(0.05,0,0,10)
    frame.BackgroundColor3 = Color3.fromRGB(60,0,0)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.Text = name..": "..options[1]
    label.Parent = frame

    local index = 1
    frame.MouseButton1Click = nil -- just visual, handled by label
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            index = index + 1
            if index > #options then index = 1 end
            label.Text = name..": "..options[index]
        end
    end)
    return function() return options[index] end
end

local getTeleport = createDropdown("Teleport", {"Island1","Island2","Island3"}, tabContents["Teleports"])
local getNPCTarget = createDropdown("NPC Target", {"Bandit","Pirate","Marine"}, tabContents["Combat"])

-- Tab switching with animation
local function switchTab(name)
    for tName, frame in pairs(tabContents) do
        if frame.Visible then
            TweenService:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(-1,0,0,0)}):Play()
            frame.Visible = false
        end
    end
    local newFrame = tabContents[name]
    newFrame.Position = UDim2.new(1,0,0,0)
    newFrame.Visible = true
    TweenService:Create(newFrame,TweenInfo.new(0.3),{Position=UDim2.new(0,0,0,0)}):Play()
end

for tabName, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- Default tab
switchTab("Combat")

-- Automation functions
local function attackNPC(npcName)
    local npcs = Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in pairs(npcs:GetChildren()) do
            if npc.Name == npcName and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health>0 and player.Character then
                player.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                npc.Humanoid:TakeDamage(10)
            end
        end
    end
end

local function autoFarm()
    local target = getNPCTarget()
    attackNPC(target)
end

local function takeQuest()
    local questGivers = Workspace:FindFirstChild("QuestGivers")
    if questGivers then
        for _, q in pairs(questGivers:GetChildren()) do
            if q:FindFirstChild("QuestScript") then
                q.QuestScript:FireServer(player)
            end
        end
    end
end

local function autoLevel()
    if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("XP") then
        player.leaderstats.XP.Value += 1
    end
end

local function useAbility()
    -- Example: trigger selected fruit/sword
end

local function teleportPlayer()
    local pointName = getTeleport()
    local tpPoint = Workspace:FindFirstChild("TeleportPoints") and Workspace.TeleportPoints:FindFirstChild(pointName)
    if tpPoint and player.Character then
        player.Character.HumanoidRootPart.CFrame = tpPoint.CFrame
    end
end

local function extraFun()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if toggles["AutoFarm"] then autoFarm() end
    if toggles["AutoQuest"] then takeQuest() end
    if toggles["AutoLevel"] then autoLevel() end
    if toggles["AutoAbility"] then useAbility() end
    if toggles["AutoTeleport"] then teleportPlayer() end
    if toggles["ExtraFun"] then extraFun() end
end)
