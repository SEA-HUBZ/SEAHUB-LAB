local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
    queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()")
end

local StartTime = tick()

if game:IsLoaded() then
    print("Game is loaded.")
else
    game.Loaded:Wait()
end

-- Wait for the character to load
while task.wait(0.1) do
    if not pcall(function() return game.Players.LocalPlayer.Character.Main.W end) then
        print("Character not loaded.")
    else
        print("Character is loaded.")
        break
    end
end

-- Function to update Titans' position based on Fake_Head
local function updateTitansPosition()
    local fakeHead = game.Workspace:FindFirstChild("Fake_Head")
    local titansFolder = game.Workspace:FindFirstChild("Titans")

    if not fakeHead then
        warn("Fake_Head not found in Workspace.")
        return
    end

    if not titansFolder then
        warn("Titans folder not found in Workspace.")
        return
    end

    for _, titan in ipairs(titansFolder:GetChildren()) do
        local humanoidRootPart = titan:FindFirstChild("HumanoidRootPart")
        local hitboxes = titan:FindFirstChild("Hitboxes")

        if humanoidRootPart and hitboxes then
            local hit = hitboxes:FindFirstChild("Hit")
            if hit then
                local nape = hit:FindFirstChild("Nape")
                if nape and nape:IsA("Part") then
                    humanoidRootPart.Position = fakeHead.Position
                    nape.Position = fakeHead.Position
                    nape.Size = Vector3.new(9300, 9300, 9300)
                end
            end
        end
    end
end

-- Function to invoke skills
local function invokeSkills()
    task.spawn(function()
        while true do
            game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "23")
            task.wait(0.02)
            game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "14")
            task.wait(0.1)
            game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("Functions", "Retry", "Add") -- Missing InvokeServer added
            task.wait(0.1)
        end
    end)
end

-- Wait for Titans to load and execute the Titan logic (duplicated for faster execution)
local function waitForTitansAndExecute()
    while true do
        if not pcall(function()
            local Titans = game.Workspace.Titans
            return Titans:FindFirstChildOfClass("Model").Hitboxes.Hit
        end) then
            print("Titans not loaded.")
        else
            print("Titans is loaded.")
            updateTitansPosition()
            invokeSkills()
            break
        end
        task.wait(0.1) -- This ensures the loop runs continuously until Titans are loaded
    end
end

-- Duplicate the logic for Titans loading and execution
waitForTitansAndExecute()  -- First execution
waitForTitansAndExecute()  -- Second execution for faster execution

-- Cleanup tasks
task.spawn(function()
    local lighting = game:GetService("Lighting")
    for _, object in pairs(lighting:GetChildren()) do
        object:Destroy()
    end

    local climbableFolder = workspace:FindFirstChild("Climbable")
    local unclimbableFolder = workspace:FindFirstChild("Unclimbable")
    if climbableFolder then climbableFolder:Destroy() end
    if unclimbableFolder then unclimbableFolder:Destroy() end
end)

-- Reset lighting settings
local function resetLighting()
    local lighting = game:GetService("Lighting")
    lighting.FogEnd = 100000
    lighting.FogColor = Color3.fromRGB(255, 255, 255)
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
    lighting.Brightness = 2
    lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    lighting.Sky = nil
    lighting.TimeOfDay = "14:00:00"
    lighting.ClockTime = 12
end

resetLighting()

-- Continuous debris deletion
local function deleteDebris()
    game:GetService("RunService").Heartbeat:Connect(function()
        local debrisChildren = workspace.Debris:GetChildren()
        if #debrisChildren == 0 then
            print("Waiting for Children to Appear")
        else
            for _, object in pairs(debrisChildren) do
                object:Destroy()
            end
        end
    end)
end

deleteDebris()

print(string.format("Start time: %.4f seconds", tick() - StartTime))
