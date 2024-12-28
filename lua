local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local queue teleport setup and remote execution from URL
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
    pcall(function()
        queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()")
    end)
end

-- Flags and cooldowns
local embedSent = false
local cooldownTime = 0.5 -- Cooldown time in seconds
local lastSentTime = 0 -- Timestamp of the last sent webhook

-- Find Fake_Head and Titans Folder in Workspace
local fakeHead, titansFolder
pcall(function()
    fakeHead = game.Workspace:FindFirstChild("Fake_Head")
    titansFolder = game.Workspace:FindFirstChild("Titans")
end)

if not fakeHead then
    warn("Fake_Head not found in Workspace.")
    return
end

if not titansFolder then
    warn("Titans folder not found in Workspace.")
    return
end

-- Update Titans' properties
RunService.Heartbeat:Connect(function()
    pcall(function()
        for _, titan in ipairs(titansFolder:GetChildren()) do
            local hitboxes = titan:FindFirstChild("Hitboxes")
            if hitboxes then
                local hit = hitboxes:FindFirstChild("Hit")
                if hit then
                    local nape = hit:FindFirstChild("Nape")
                    if nape and nape:IsA("Part") then
                        -- Set the Nape's position to Fake_Head and resize it
                        nape:PivotTo(fakeHead.CFrame)
                        nape.Size = Vector3.new(10000, 10000, 10000)
                    end
                end
            end

            -- Disable collision and make the entire Titan invisible
            for _, descendant in ipairs(titan:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.CanCollide = false -- Disable collision for all BaseParts
                    descendant.Transparency = 1 -- Make invisible
                elseif descendant:IsA("Decal") then
                    descendant.Transparency = 1 -- Make decals invisible
                elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
                    descendant.Enabled = false -- Disable particle effects and beams
                end
            end
        end
    end)
end)

-- Function to initiate Titan ripper logic
local function initTitanRipper()
    task.spawn(function()
        while true do
            pcall(function()
                -- Ensure Titans are updated before invoking skills
                for _, titan in ipairs(titansFolder:GetChildren()) do
                    for _, descendant in ipairs(titan:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            descendant.CanCollide = false
                        end
                    end
                end

                -- Invoke server functions for skills
                ReplicatedStorage.Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "23")
                ReplicatedStorage.Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "14")
                ReplicatedStorage.Assets.Remotes.GET:InvokeServer("Functions", "Retry", "Add")
            end)

            task.wait(0.01)
        end
    end)
end

-- Initialize Titan ripper
pcall(initTitanRipper)

-- Main loop with cooldown
RunService.RenderStepped:Connect(function()
    pcall(function()
        local currentTime = tick()
        if not embedSent and (currentTime - lastSentTime >= cooldownTime) then
            print("Sending Titan Ripper logic...")
            embedSent = true
            lastSentTime = currentTime
        end
    end)

    task.wait(0.01)
end)

-- Additional task to destroy specific objects and particles
task.spawn(function()
    pcall(function()
        if workspace:FindFirstChild("Climbable") then
            workspace.Climbable:Destroy()
            workspace.Unclimbable.Background:Destroy()
            workspace.Unclimbable.Trees:Destroy()
            workspace.Unclimbable.Tree_Colliders:Destroy()
            workspace.Unclimbable.Props:Destroy()
            
            for _, Part in ipairs(game:GetDescendants()) do
                if Part:IsA("ParticleEmitter") then
                    Part:Destroy()
                elseif Part:FindFirstAncestor("Lighting") then
                    Part:Destroy()
                end
                task.wait(0.01)
            end
        end
    end)
end)
