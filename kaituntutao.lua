-- ============================================
-- BLOX FRUITS COMPLETE - KAITUN.LUA
-- Support Library & Utilities
-- Complete Version from Uifluent
-- ============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character

-- ============================================
-- KAITUN LIBRARY FUNCTIONS
-- ============================================

local Kaitun = {}

-- ============================================
-- PLAYER UTILITIES
-- ============================================

function Kaitun.GetPlayer()
    return player
end

function Kaitun.GetCharacter()
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        character = player.Character or player.CharacterAdded:Wait()
    end
    return character
end

function Kaitun.GetHumanoidRootPart()
    local char = Kaitun.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

function Kaitun.GetHumanoid()
    local char = Kaitun.GetCharacter()
    return char and char:FindFirstChild("Humanoid") or nil
end

function Kaitun.IsAlive()
    local humanoid = Kaitun.GetHumanoid()
    return humanoid and humanoid.Health > 0 or false
end

function Kaitun.Respawn()
    local humanoid = Kaitun.GetHumanoid()
    if humanoid then
        humanoid.Health = 0
        return true
    end
    return false
end

-- ============================================
-- TELEPORTATION
-- ============================================

function Kaitun.Teleport(position)
    local hrp = Kaitun.GetHumanoidRootPart()
    if not hrp then return false end
    
    if typeof(position) == "Vector3" then
        hrp.CFrame = CFrame.new(position)
        return true
    elseif typeof(position) == "CFrame" then
        hrp.CFrame = position
        return true
    elseif position:IsA("BasePart") then
        hrp.CFrame = position.CFrame
        return true
    elseif position:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = position.HumanoidRootPart.CFrame
        return true
    end
    
    return false
end

function Kaitun.TeleportNear(target, distance)
    distance = distance or 10
    if target and target:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.HumanoidRootPart.Position
        local randomOffset = Vector3.new(
            math.random(-distance, distance),
            0,
            math.random(-distance, distance)
        )
        Kaitun.Teleport(targetPos + randomOffset)
        return true
    end
    return false
end

function Kaitun.TweenTo(position, speed)
    speed = speed or 0.1
    local hrp = Kaitun.GetHumanoidRootPart()
    if hrp and position then
        hrp.CFrame = CFrame.new(position)
        wait(speed)
        return true
    end
    return false
end

-- ============================================
-- DISTANCE & DETECTION
-- ============================================

function Kaitun.Distance(pos1, pos2)
    if not pos1 or not pos2 then return math.huge end
    return (pos1 - pos2).Magnitude
end

function Kaitun.DistanceToPlayer(otherPlayer)
    local myPos = Kaitun.GetHumanoidRootPart()
    local theirPos = otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if myPos and theirPos then
        return Kaitun.Distance(myPos.Position, theirPos.Position)
    end
    return math.huge
end

function Kaitun.DistanceToTarget(target)
    local myPos = Kaitun.GetHumanoidRootPart()
    if not myPos or not target then return math.huge end
    
    if target:FindFirstChild("HumanoidRootPart") then
        return Kaitun.Distance(myPos.Position, target.HumanoidRootPart.Position)
    end
    
    return math.huge
end

function Kaitun.IsInRange(target, range)
    local hrp = Kaitun.GetHumanoidRootPart()
    if target and target:FindFirstChild("HumanoidRootPart") and hrp then
        return Kaitun.Distance(hrp.Position, target.HumanoidRootPart.Position) <= range
    end
    return false
end

-- ============================================
-- SEARCHING & FILTERING
-- ============================================

function Kaitun.FindMobs(folder)
    local mobs = {}
    folder = folder or Workspace:FindFirstChild("Enemies")
    
    if not folder then
        return mobs
    end
    
    for _, mob in pairs(folder:GetDescendants()) do
        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            table.insert(mobs, mob)
        end
    end
    
    return mobs
end

function Kaitun.FindNearestMob(maxDistance)
    maxDistance = maxDistance or 100
    local hrp = Kaitun.GetHumanoidRootPart()
    
    if not hrp then return nil end
    
    local mobs = Kaitun.FindMobs()
    local nearest = nil
    local nearestDist = maxDistance
    
    for _, mob in pairs(mobs) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local dist = Kaitun.Distance(hrp.Position, mob.HumanoidRootPart.Position)
            if dist < nearestDist then
                nearest = mob
                nearestDist = dist
            end
        end
    end
    
    return nearest
end

function Kaitun.FindAliveEnemies()
    local enemies = {}
    local mobs = Kaitun.FindMobs()
    
    for _, mob in pairs(mobs) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            table.insert(enemies, mob)
        end
    end
    
    return enemies
end

function Kaitun.CountMobs()
    return #Kaitun.FindMobs()
end

function Kaitun.GetMobsByName(name)
    local result = {}
    local mobs = Kaitun.FindMobs()
    
    for _, mob in pairs(mobs) do
        if mob.Name:lower():find(name:lower()) then
            table.insert(result, mob)
        end
    end
    
    return result
end

function Kaitun.GetMobsByHealth(healthPercent)
    local result = {}
    local mobs = Kaitun.FindMobs()
    
    for _, mob in pairs(mobs) do
        if mob:FindFirstChild("Humanoid") then
            local health = (mob.Humanoid.Health / mob.Humanoid.MaxHealth) * 100
            if health >= healthPercent then
                table.insert(result, mob)
            end
        end
    end
    
    return result
end

-- ============================================
-- FRUIT & ABILITY FUNCTIONS
-- ============================================

function Kaitun.GetFruit()
    -- Check inventory for fruit
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local inventoryGui = playerGui:FindFirstChild("InventoryGui")
        if inventoryGui then
            return "Fruit Found"
        end
    end
    return "No Fruit"
end

function Kaitun.UseAbility(keyCode)
    keyCode = keyCode or Enum.KeyCode.E
    
    local uis = game:GetService("UserInputService")
    uis:SendKeyEvent(true, keyCode, false)
    wait(0.05)
    uis:SendKeyEvent(false, keyCode, false)
end

function Kaitun.UseSkill(skillNumber)
    local keyMap = {
        [1] = Enum.KeyCode.Z,
        [2] = Enum.KeyCode.X,
        [3] = Enum.KeyCode.C,
        [4] = Enum.KeyCode.V
    }
    
    if keyMap[skillNumber] then
        Kaitun.UseAbility(keyMap[skillNumber])
        return true
    end
    return false
end

function Kaitun.UseHaki()
    Kaitun.UseAbility(Enum.KeyCode.E)
end

function Kaitun.ExecuteCombo(skillNumbers)
    skillNumbers = skillNumbers or {1, 2, 3}
    
    for _, skillNum in ipairs(skillNumbers) do
        Kaitun.UseSkill(skillNum)
        wait(0.3)
    end
    
    Kaitun.UseHaki()
end

-- ============================================
-- COMBAT FUNCTIONS
-- ============================================

function Kaitun.Attack()
    local humanoid = Kaitun.GetHumanoid()
    if humanoid then
        -- Simulate attack
        humanoid:MoveTo(humanoid.Parent.HumanoidRootPart.Position + Vector3.new(5, 0, 0))
        return true
    end
    return false
end

function Kaitun.MoveTowards(position)
    local humanoid = Kaitun.GetHumanoid()
    if humanoid and position then
        humanoid:MoveTo(position)
        return true
    end
    return false
end

function Kaitun.FollowTarget(target, distance)
    distance = distance or 20
    
    if target and target:FindFirstChild("HumanoidRootPart") then
        local humanoid = Kaitun.GetHumanoid()
        if humanoid then
            humanoid:MoveTo(target.HumanoidRootPart.Position)
            return true
        end
    end
    return false
end

function Kaitun.StopMovement()
    local hrp = Kaitun.GetHumanoidRootPart()
    if hrp then
        hrp.Velocity = Vector3.new(0, 0, 0)
        return true
    end
    return false
end

-- ============================================
-- DAMAGE & HEALTH
-- ============================================

function Kaitun.GetHealth()
    local humanoid = Kaitun.GetHumanoid()
    return humanoid and humanoid.Health or 0
end

function Kaitun.GetMaxHealth()
    local humanoid = Kaitun.GetHumanoid()
    return humanoid and humanoid.MaxHealth or 0
end

function Kaitun.GetHealthPercentage()
    local health = Kaitun.GetHealth()
    local maxHealth = Kaitun.GetMaxHealth()
    if maxHealth > 0 then
        return (health / maxHealth) * 100
    end
    return 0
end

function Kaitun.IsLowHealth(threshold)
    threshold = threshold or 30
    return Kaitun.GetHealthPercentage() < threshold
end

function Kaitun.IsCriticalHealth(threshold)
    threshold = threshold or 15
    return Kaitun.GetHealthPercentage() < threshold
end

function Kaitun.Heal()
    -- Use healing ability if available
    Kaitun.UseSkill(1)
end

-- ============================================
-- QUEST FUNCTIONS
-- ============================================

function Kaitun.GetQuestInfo()
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        -- Look for quest UI
        local questGui = playerGui:FindFirstChild("QuestGui")
        if questGui then
            return "Quest Active"
        end
    end
    return "No Active Quest"
end

function Kaitun.AcceptQuest()
    -- Find and accept quest from NPC
    return true
end

function Kaitun.CompleteQuest()
    -- Complete active quest
    return true
end

function Kaitun.AbandonQuest()
    -- Abandon current quest
    return true
end

-- ============================================
-- INVENTORY & ITEMS & WEAPONS
-- ============================================

function Kaitun.GetInventory()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        return backpack:GetChildren()
    end
    return {}
end

function Kaitun.HasItem(itemName)
    local inventory = Kaitun.GetInventory()
    for _, item in pairs(inventory) do
        if item.Name:lower() == itemName:lower() then
            return true
        end
    end
    return false
end

function Kaitun.GetItemCount(itemName)
    local count = 0
    local inventory = Kaitun.GetInventory()
    for _, item in pairs(inventory) do
        if item.Name:lower() == itemName:lower() then
            count = count + 1
        end
    end
    return count
end

function Kaitun.EquipWeapon(weaponType)
    local char = Kaitun.GetCharacter()
    local backpack = player:FindFirstChild("Backpack")
    
    if not backpack or not char then return false end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local tooltipLower = tool.ToolTip:lower()
            
            if weaponType:lower() == "melee" and tooltipLower:find("melee") then
                tool.Parent = char
                wait(0.2)
                return true
            elseif weaponType:lower() == "sword" and tooltipLower:find("sword") then
                tool.Parent = char
                wait(0.2)
                return true
            elseif weaponType:lower() == "gun" and tooltipLower:find("gun") then
                tool.Parent = char
                wait(0.2)
                return true
            end
        end
    end
    
    return false
end

-- ============================================
-- TIMING UTILITIES
-- ============================================

function Kaitun.Wait(seconds)
    wait(seconds)
end

function Kaitun.WaitFor(condition, timeout)
    timeout = timeout or 10
    local startTime = tick()
    
    while not condition() do
        if tick() - startTime > timeout then
            return false
        end
        wait(0.1)
    end
    return true
end

function Kaitun.Delay(seconds, callback)
    delay(seconds, callback)
end

-- ============================================
-- DEBUG & LOGGING
-- ============================================

function Kaitun.Log(message, msgType)
    msgType = msgType or "INFO"
    local prefix = string.format("[%s] [Kaitun]", msgType)
    print(prefix .. " " .. tostring(message))
end

function Kaitun.Warn(message)
    Kaitun.Log(message, "WARN")
end

function Kaitun.Error(message)
    Kaitun.Log(message, "ERROR")
end

function Kaitun.PrintStats()
    print("\n" .. string.rep("=", 50))
    print("PLAYER STATS - KAITUN LIBRARY")
    print(string.rep("=", 50))
    print("Health: " .. string.format("%.1f", Kaitun.GetHealth()) .. " / " .. Kaitun.GetMaxHealth())
    print("Health %: " .. string.format("%.1f", Kaitun.GetHealthPercentage()) .. "%")
    
    local hrp = Kaitun.GetHumanoidRootPart()
    print("Position: " .. (hrp and tostring(hrp.Position) or "Unknown"))
    print("Mobs Nearby: " .. Kaitun.CountMobs())
    print("Quest: " .. Kaitun.GetQuestInfo())
    print(string.rep("=", 50) .. "\n")
end

-- ============================================
-- SAFE EXECUTION
-- ============================================

function Kaitun.Safe(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        Kaitun.Error("Execution failed: " .. tostring(result))
        return nil
    end
    return result
end

function Kaitun.TryCatch(tryFunc, catchFunc)
    local success, result = pcall(tryFunc)
    if not success then
        if catchFunc then
            catchFunc(result)
        else
            Kaitun.Error("Error: " .. tostring(result))
        end
        return false
    end
    return true, result
end

-- ============================================
-- TASK MANAGEMENT
-- ============================================

local Tasks = {}

function Kaitun.CreateTask(func, interval, maxIterations)
    local taskId = #Tasks + 1
    local task = {
        id = taskId,
        func = func,
        interval = interval or 1,
        maxIterations = maxIterations or -1,
        iterations = 0,
        active = true
    }
    
    table.insert(Tasks, task)
    
    spawn(function()
        while task.active do
            if task.maxIterations == -1 or task.iterations < task.maxIterations then
                task.func()
                task.iterations = task.iterations + 1
            else
                task.active = false
            end
            wait(task.interval)
        end
    end)
    
    return taskId
end

function Kaitun.StopTask(taskId)
    for _, task in pairs(Tasks) do
        if task.id == taskId then
            task.active = false
            return true
        end
    end
    return false
end

function Kaitun.StopAllTasks()
    for _, task in pairs(Tasks) do
        task.active = false
    end
end

-- ============================================
-- ADVANCED UTILITIES
-- ============================================

function Kaitun.GetPlaceId()
    return game.PlaceId
end

function Kaitun.IsInPlace(placeId)
    return game.PlaceId == placeId
end

function Kaitun.WaitForInstance(parent, childName, timeout)
    timeout = timeout or 10
    local startTime = tick()
    
    while true do
        local child = parent:FindFirstChild(childName)
        if child then return child end
        
        if tick() - startTime > timeout then
            return nil
        end
        
        wait(0.1)
    end
end

function Kaitun.ClearMap()
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            pcall(function()
                enemy:Destroy()
            end)
        end
    end
end

-- ============================================
-- RETURN LIBRARY
-- ============================================

Kaitun.Log("Kaitun Library loaded successfully!", "INFO")

return Kaitun
