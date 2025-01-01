local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

if queueteleport then
    queueteleport("loadstring(game:HttpGet('https://pastebin.com/xVF8B9n7', true))()") -- New Pastebin first
    queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()") -- Original loadstring
end

-- Function to update Titans' position based on Fake_Head or specific CFrame for a PlaceId
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

    game:GetService("RunService").Heartbeat:Connect(function()
        for _, titan in ipairs(titansFolder:GetChildren()) do
            local humanoidRootPart = titan:FindFirstChild("HumanoidRootPart")
            local hitboxes = titan:FindFirstChild("Hitboxes")
            
            if humanoidRootPart and hitboxes then
                local hit = hitboxes:FindFirstChild("Hit")
                if hit then
                    local nape = hit:FindFirstChild("Nape")
                    if nape and nape:IsA("Part") then
                        if game.PlaceId == 13379349730 then
                            nape.Position = Vector3.new(512, 173, 774)
                        else
                            humanoidRootPart.Position = fakeHead.Position
                            nape.Position = fakeHead.Position
                            nape.Size = Vector3.new(9300, 9300, 9300)
                        end
                    end
                end
            end
        end
    end)
end

-- Function to delete all children of Lighting
local function deleteLightingChildren()
    local lighting = game:GetService("Lighting")

    for _, object in pairs(lighting:GetChildren()) do
        object:Destroy()
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

-- Function to invoke server requests
local function invokeServerRequests()
    task.spawn(function()
        while true do
            game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "23")
            task.wait(0.02)
            game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "14")
            task.wait(0.1)
            game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("Functions", "Retry", "Add")
            task.wait(0.1)
        end
    end)
end

-- Cleanup tasks before debris
task.spawn(function()
    updateTitansPosition() -- Run first
    deleteLightingChildren()
    deleteClimbableUnclimbableAndAssets()
    resetLighting()
end)

-- This function deletes debris and checks if there are no children
task.spawn(function()
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
end)

-- Initialize server requests
task.spawn(function()
    invokeServerRequests() -- Run after cleanup tasks
end)
