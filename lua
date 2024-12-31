local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
    queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()")
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

-- Function to delete Climbable, Unclimbable folders and specific assets
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

    -- Delete specific assets from ReplicatedStorage
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
        for _, child in pairs(path:GetChildren()) do
            child:Destroy()
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

-- Function to reset lighting settings (removed IndirectLightingMultiplier)
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

    for _, object in pairs(workspace:GetDescendants()) do
        local isExcluded = isExcludedObject(object)
        removeVisualEffects(object, isExcluded)
    end

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            for _, object in pairs(player.Character:GetDescendants()) do
                removeVisualEffects(object, true)
            end
        end
    end
end)

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

-- Start cleanup and continuous debris deletion
task.spawn(function()
    deleteDebris() -- Delete debris last
end)

-- Initialize server requests
task.spawn(function()
    invokeServerRequests() -- Invoke server requests second to last
end)
