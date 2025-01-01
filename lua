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

-- Function to wait for Titans to load and execute logic
local function waitForTitansAndExecute()
    while true do
        if not pcall(function()
            local Titans = game.Workspace.Titans
            return Titans:FindFirstChildOfClass("Model").Hitboxes.Hit
        end) then
            print("Titans not loaded.")
        else
            print("Titans are loaded.")
            updateTitansPosition() -- Execute the Titans logic
            break
        end
        task.wait(0.1) -- This ensures the loop runs continuously until Titans are loaded
    end
end

-- Function to invoke server requests for skills (S_Skills)
local function invokeSkillsRequests()
    waitForTitansAndExecute() -- Wait for Titans to load before running skills requests

    -- Skills requests loop after Titans are loaded
    while true do
        game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "23")
        task.wait(0.02)
        game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "14")
        task.wait(0.1)
    end
end

-- Function to invoke server requests for retry (Functions, Retry, Add)
local function invokeRetryRequest()
    while true do
        game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("Functions", "Retry", "Add")
        task.wait(0.1)
    end
end

-- Function to delete Climbable, Unclimbable folders, and specific assets
local function deleteClimbableUnclimbableAndAssets()
    -- Delete Climbable and Unclimbable folders
    local climbableFolder = workspace:FindFirstChild("Climbable")
    local unclimbableFolder = workspace:FindFirstChild("Unclimbable")

    if climbableFolder then
        climbableFolder:Destroy()
    end

    if unclimbableFolder then
        unclimbableFolder:Destroy()
    end

    -- Delete parent objects from ReplicatedStorage
    local pathsToDelete = {
        game:GetService("ReplicatedStorage").Assets.Objects,
        game:GetService("ReplicatedStorage").Assets.Poofs,
        game:GetService("ReplicatedStorage").Assets.Rarities,
        game:GetService("ReplicatedStorage").Assets.Particles,
        game:GetService("ReplicatedStorage").Assets.Effects,
        game:GetService("ReplicatedStorage").Assets.Cutscenes,
        game:GetService("ReplicatedStorage").Assets.Customisation,
        game:GetService("ReplicatedStorage").Assets.Constraints,
        game:GetService("ReplicatedStorage").Assets.Cannisters,
        game:GetService("ReplicatedStorage").Assets.Blades,
        game:GetService("ReplicatedStorage").Assets.Auras,
        game:GetService("ReplicatedStorage").Assets.Artifacts,
        game:GetService("ReplicatedStorage").Assets["3DMGs"]
    }

    for _, path in pairs(pathsToDelete) do
        if path then
            path:Destroy()
        end
    end

    -- Delete specific skills except DrillThrust and TorrentialSteel
    local skillsFolder = game:GetService("ReplicatedStorage").Assets.Skills
    for _, skill in pairs(skillsFolder:GetChildren()) do
        if skill.Name ~= "DrillThrust" and skill.Name ~= "TorrentialSteel" then
            skill:Destroy()
        end
    end
end

-- Function to remove visual effects (excluding certain objects)
local function removeVisualEffects(object, isExcluded)
    if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Decal") then
        if not isExcluded then
            object:Destroy()
        end
    end

    if object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") or object:IsA("Light") then
        if not isExcluded then
            object.Brightness = 0
            object.Enabled = false
        end
    end

    if not isExcluded and (object:IsA("MeshPart") or object:IsA("SpecialMesh")) then
        object:Destroy()
    end
end

-- Function to check if an object should be excluded
local function isExcludedObject(object)
    if object.Parent and object.Parent:IsA("Model") and object.Parent:FindFirstChild("Humanoid") then
        return true
    end
    if object:IsDescendantOf(workspace.Titans) then
        return true
    end
    if object:IsDescendantOf(workspace.Points) then
        return true
    end
    return false
end

-- Function to reset lighting settings
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

-- This function deletes debris and checks if there are no children
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

-- Start debris deletion first
task.spawn(function()
    deleteDebris() -- Delete debris first
end)

-- Cleanup tasks before debris
task.spawn(function()
    -- Invoke server requests for skills (after Titans are loaded)
    invokeSkillsRequests() -- First loop for skills requests

    -- Delete assets and folders
    deleteClimbableUnclimbableAndAssets()

    -- Reset lighting settings
    resetLighting()

    -- Remove visual effects in workspace
    for _, object in pairs(workspace:GetDescendants()) do
        local isExcluded = isExcludedObject(object)
        removeVisualEffects(object, isExcluded)
    end

    -- Remove visual effects in player characters
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            for _, object in pairs(player.Character:GetDescendants()) do
                removeVisualEffects(object, true)
            end
        end
    end
end)

-- Start retry server requests in a separate loop
task.spawn(function()
    invokeRetryRequest() -- Separate loop for retry requests
end)

-- Print the start time for the script's execution
print(string.format("Start time: %.4f seconds", tick() - StartTime))
