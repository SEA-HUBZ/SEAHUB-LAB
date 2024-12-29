local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
    pcall(function()
        queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()")
    end)
end

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
        if object then
            object:Destroy()
        end
    end
end

local function removeSounds(object)
    if object:IsA("Sound") then
        object:Destroy()
    end
end

local function removeVisualEffects(object, isExcluded)
    if not isExcluded then
        if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Decal") then
            object:Destroy()
        elseif object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") or object:IsA("Light") then
            object.Brightness = 0
            object.Enabled = false
        elseif object:IsA("MeshPart") or object:IsA("SpecialMesh") then
            object:Destroy()
        end
    end
end

local function isExcludedObject(object)
    return object:IsDescendantOf(workspace.Titans) or object:IsDescendantOf(workspace.Points) or 
           (object.Parent and object.Parent:IsA("Model") and object.Parent:FindFirstChild("Humanoid"))
end

local function deleteDebris()
    for _, object in pairs(workspace.Debris:GetChildren()) do
        object:Destroy()
    end
end

local function updateTitansPosition()
    local fakeHead = workspace:FindFirstChild("Fake_Head")
    local titansFolder = workspace:FindFirstChild("Titans")

    if not fakeHead or not titansFolder then return end

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
            local replicatedStorage = game:GetService("ReplicatedStorage")
            replicatedStorage.Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "23")
            task.wait(0.02)
            replicatedStorage.Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "14")
            task.wait(0.1)
            replicatedStorage.Assets.Remotes.GET:InvokeServer("Functions", "Retry", "Add")
            task.wait(0.1)
        end
    end)
end

local function resetLighting()
    local lighting = game:GetService("Lighting")
    lighting.FogEnd = 100000
    lighting.FogColor = Color3.fromRGB(255, 255, 255)
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
    lighting.Brightness = 2
    lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    lighting.IndirectLightingMultiplier = 1
    lighting.Sky = nil
    lighting.TimeOfDay = "14:00:00"
    lighting.ClockTime = 12
end

-- Run all functions concurrently
task.spawn(function()
    for _, object in pairs(workspace:GetDescendants()) do
        local isExcluded = isExcludedObject(object)
        removeVisualEffects(object, isExcluded)
        if not isExcluded then
            removeSounds(object)
        end
    end

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            for _, object in pairs(player.Character:GetDescendants()) do
                removeSounds(object)
                removeVisualEffects(object, true)
            end
        end
    end
end)

task.spawn(deleteDebris)
task.spawn(deleteSpecificObjects)
task.spawn(updateTitansPosition)
task.spawn(invokeServerRequests)
task.spawn(resetLighting)
