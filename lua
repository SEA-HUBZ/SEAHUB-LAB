local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Titans

-- Local queue teleport setup and remote execution from URL
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
    queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SEA-HUBZ/SEAHUB-LAB/main/lua', true))()")
end

-- Flags and cooldowns
local embedSent = false
local cooldownTime = 0.5 -- Cooldown time in seconds
local lastSentTime = 0 -- Timestamp of the last sent webhook

-- Function to initiate Titan ripper logic
local function initTitanRipper()
    -- Task to call remote functions periodically, wrapped in pcall to handle errors
    task.spawn(function()
        while true do
            pcall(function()
                game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "23")
            end)
            pcall(function()
                game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Skills", "Usage", "14")
            end)
            pcall(function()
                game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("Functions", "Retry", "Add")
            end)
            task.wait(0.01)  -- Reduced to 0.01
        end
    end)
end

-- Initialize Titan ripper
initTitanRipper()

-- Find Fake_Head and Titans Folder in Workspace
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

-- Update Titans' properties: Move to Fake_Head, resize Nape, and make Titan invisible
RunService.Heartbeat:Connect(function()
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
                    nape.CanCollide = false  -- Disable collision
                end
            end
        end

        -- Make the entire Titan invisible
        for _, descendant in ipairs(titan:GetDescendants()) do
            if descendant:IsA("BasePart") or descendant:IsA("Decal") then
                descendant.Transparency = 1
            elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
                descendant.Enabled = false
            end
        end

        print("Titan moved to Fake_Head, resized, and made invisible.")
    end
end)

-- Main loop using RenderStepped with cooldown
RunService.RenderStepped:Connect(function()
    local currentTime = tick()

    -- Ensure a cooldown is respected for sending logic
    if not embedSent and (currentTime - lastSentTime >= cooldownTime) then
        print("Sending Titan Ripper logic...")
        embedSent = true
        lastSentTime = currentTime
    end
    task.wait(0.01)  -- Reduced to 0.01
end)

-- Additional task to destroy specific objects and particles
task.spawn(function()
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
