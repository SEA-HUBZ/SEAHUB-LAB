local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
    pcall(function()
        queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()")
    end)
end

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
                        humanoidRootPart.Position = fakeHead.Position
                        nape.Position = fakeHead.Position
                        nape.Size = Vector3.new(9300, 9300, 9300)
                    end
                end
            end
        end
    end)
end

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

updateTitansPosition()
invokeServerRequests()

local function deleteSpecificObjects()
    local objectsToDelete = {
        workspace.Climbable:FindFirstChild("Buildings"),
        workspace.Climbable:FindFirstChild("Walls"),
        workspace.Unclimbable:FindFirstChild("Trees"),
        workspace.Unclimbable:FindFirstChild("Reloads"),
        workspace.Unclimbable:FindFirstChild("Props"),
        workspace.Unclimbable:FindFirstChild("Platforms")
    }

    for _, object in pairs(objectsToDelete) do
        pcall(function()
            if object then
                object:Destroy()
            end
        end)
    end
end

local function removeSounds(object)
    if object:IsA("Sound") then
        pcall(function()
            object:Destroy()
        end)
    end
end

local function removeVisualEffects(object, isExcluded)
    if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Decal") then
        if not isExcluded then
            pcall(function()
                object:Destroy()
            end)
        end
    end

    if object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") or object:IsA("Light") then
        if not isExcluded then
            pcall(function()
                object.Brightness = 0
                object.Enabled = false
            end)
        end
    end

    if not isExcluded and (object:IsA("MeshPart") or object:IsA("SpecialMesh")) then
        pcall(function()
            object:Destroy()
        end)
    end
end

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

local function deleteDebris()
    for _, object in pairs(workspace.Debris:GetChildren()) do
        pcall(function()
            object:Destroy()
        end)
    end
end

local function resetLighting()
    local lighting = game:GetService("Lighting")

    pcall(function()
        lighting.FogEnd = 100000
    end)

    pcall(function()
        lighting.FogColor = Color3.fromRGB(255, 255, 255)
    end)

    pcall(function()
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
    end)

    pcall(function()
        lighting.Brightness = 2
    end)

    pcall(function()
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end)

    pcall(function()
        lighting.IndirectLightingMultiplier = 1
    end)

    pcall(function()
        lighting.Sky = nil
    end)

    pcall(function()
        lighting.TimeOfDay = "14:00:00"
    end)

    pcall(function()
        lighting.ClockTime = 12
    end)
end

-- Replace the deleteSpecificAssets function with the updated one
local function deleteSpecificAssets()
    local pathsToDelete = {
        game:GetService("ReplicatedStorage").Assets.Objects,
        game:GetService("ReplicatedStorage").Assets.Poofs,
        game:GetService("ReplicatedStorage").Assets.Rarities,
        game:GetService("ReplicatedStorage").Assets.Particles
    }

    -- Delete all children of the specified paths
    for _, path in pairs(pathsToDelete) do
        for _, child in pairs(path:GetChildren()) do
            pcall(function()
                child:Destroy()
            end)
        end
    end

    -- Delete all skills except "DrillThrust" and "TorrentialSteel"
    local skillsFolder = game:GetService("ReplicatedStorage").Assets.Skills
    for _, skill in pairs(skillsFolder:GetChildren()) do
        if skill.Name ~= "DrillThrust" and skill.Name ~= "TorrentialSteel" then
            pcall(function()
                skill:Destroy()
            end)
        end
    end
end

task.spawn(function()
    for _, object in pairs(workspace:GetDescendants()) do
        local isExcluded = isExcludedObject(object)

        pcall(function()
            removeVisualEffects(object, isExcluded)
        end)

        if not isExcluded then
            pcall(function()
                removeSounds(object)
            end)
        end
    end

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            pcall(function()
                for _, object in pairs(player.Character:GetDescendants()) do
                    removeSounds(object)
                    removeVisualEffects(object, true)
                end)
            end)
        end
    end

    deleteDebris()
    deleteSpecificObjects()
    resetLighting()

    -- Delete specific assets
    deleteSpecificAssets()
end)
