local ItemFactory = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== ITEM DATABASE =====
local ItemDatabase = {
    ["KITSUNE"] = {Value = 30000000000, Rarity = "Legendary", Name = "Kitsune", Model = "Fruit"},
    ["DRAGON"] = {Value = 15000000, Rarity = "Legendary", Name = "Dragon", Model = "Fruit"},
    ["TIGER"] = {Value = 32000000000, Rarity = "Mythical", Name = "Tiger", Model = "Fruit"},
    ["BUDDHA"] = {Value = 1200000000, Rarity = "Mythical", Name = "Buddha", Model = "Fruit"},
    ["CONTROL"] = {Value = 9000000000, Rarity = "Legendary", Name = "Control", Model = "Fruit"},
    ["PORTAL"] = {Value = 850000000, Rarity = "Mythical", Name = "Portal", Model = "Fruit"},
    ["GRAVITY"] = {Value = 680000000, Rarity = "Mythical", Name = "Gravity", Model = "Fruit"},
    ["GAS"] = {Value = 500000000, Rarity = "Legendary", Name = "Gas", Model = "Fruit"},
    ["LIGHT"] = {Value = 450000000, Rarity = "Legendary", Name = "Light", Model = "Fruit"},
    ["QUAKE"] = {Value = 400000000, Rarity = "Legendary", Name = "Quake", Model = "Fruit"},
    ["MAGMA"] = {Value = 380000000, Rarity = "Legendary", Name = "Magma", Model = "Fruit"},
    ["FLAME"] = {Value = 350000000, Rarity = "Rare", Name = "Flame", Model = "Fruit"},
}

-- ===== CREATE REAL ITEM =====
local function CreateRealItem(itemDefinitionId, player)
    if not ItemDatabase[itemDefinitionId] then
        return nil, "Item không tồn tại"
    end
    
    local itemData = ItemDatabase[itemDefinitionId]
    
    -- Tạo folder item (giống real item trong game)
    local itemFolder = Instance.new("Folder")
    itemFolder.Name = itemDefinitionId
    itemFolder.Parent = player.Backpack
    
    -- Thêm attributes (server set, client không thể sửa)
    local valueObj = Instance.new("IntValue")
    valueObj.Name = "Value"
    valueObj.Value = itemData.Value
    valueObj.Parent = itemFolder
    
    local rarityObj = Instance.new("StringValue")
    rarityObj.Name = "Rarity"
    rarityObj.Value = itemData.Rarity
    rarityObj.Parent = itemFolder
    
    local typeObj = Instance.new("StringValue")
    typeObj.Name = "Type"
    typeObj.Value = "Item"
    typeObj.Parent = itemFolder
    
    -- Thêm model visual (fake visual nhưng trong game)
    local model = Instance.new("Part")
    model.Name = "Model"
    model.Shape = Enum.PartType.Ball
    model.Size = Vector3.new(1, 1, 1)
    model.CanCollide = false
    model.CanTouch = false
    model.TopSurface = Enum.SurfaceType.Smooth
    model.BottomSurface = Enum.SurfaceType.Smooth
    model.Material = Enum.Material.Neon
    model.Color = Color3.fromRGB(255, 200, 0) -- Gold color
    model.Parent = itemFolder
    
    -- Tag item (server authoritative)
    local tag = Instance.new("StringValue")
    tag.Name = "IsServerCreated"
    tag.Value = "TRUE"
    tag.Parent = itemFolder
    
    return itemFolder, "Tạo thành công"
end

-- ===== CREATE MULTIPLE ITEMS =====
local function CreateMultipleItems(itemDefinitionId, quantity, player)
    local created = {}
    for i = 1, quantity do
        local item, msg = CreateRealItem(itemDefinitionId, player)
        if item then
            table.insert(created, item)
        end
    end
    return created
end

-- ===== REMOTE EVENTS =====
local ItemFactoryFolder = Instance.new("Folder")
ItemFactoryFolder.Name = "ItemFactoryEvents"
ItemFactoryFolder.Parent = ReplicatedStorage

local CreateItemEvent = Instance.new("RemoteEvent")
CreateItemEvent.Name = "CreateItem"
CreateItemEvent.Parent = ItemFactoryFolder

local CreateMultipleEvent = Instance.new("RemoteEvent")
CreateMultipleEvent.Name = "CreateMultiple"
CreateMultipleEvent.Parent = ItemFactoryFolder

local GetPlayerItemsEvent = Instance.new("RemoteFunction")
GetPlayerItemsEvent.Name = "GetPlayerItems"
GetPlayerItemsEvent.Parent = ItemFactoryFolder

local DeleteItemEvent = Instance.new("RemoteEvent")
DeleteItemEvent.Name = "DeleteItem"
DeleteItemEvent.Parent = ItemFactoryFolder

-- ===== EVENT HANDLERS =====
CreateItemEvent.OnServerEvent:Connect(function(player, itemDefinitionId)
    if not player.Character or not player.Backpack then
        return
    end
    
    local item, msg = CreateRealItem(itemDefinitionId, player)
    if item then
        print("[FACTORY] Item " .. itemDefinitionId .. " được tạo cho " .. player.Name)
        CreateItemEvent:FireClient(player, {
            Status = "SUCCESS",
            ItemName = itemDefinitionId,
            Message = "Item được tạo thành công"
        })
    else
        CreateItemEvent:FireClient(player, {
            Status = "FAILED",
            Message = msg
        })
    end
end)

CreateMultipleEvent.OnServerEvent:Connect(function(player, itemDefinitionId, quantity)
    if not player.Character or not player.Backpack then
        return
    end
    
    local items, msg = CreateMultipleItems(itemDefinitionId, quantity, player)
    if #items > 0 then
        print("[FACTORY] " .. #items .. "x " .. itemDefinitionId .. " được tạo cho " .. player.Name)
        CreateMultipleEvent:FireClient(player, {
            Status = "SUCCESS",
            ItemName = itemDefinitionId,
            Quantity = #items,
            Message = #items .. " item được tạo thành công"
        })
    else
        CreateMultipleEvent:FireClient(player, {
            Status = "FAILED",
            Message = "Không thể tạo item"
        })
    end
end)

GetPlayerItemsEvent.OnServerInvoke = function(player, targetPlayerName)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if not targetPlayer or not targetPlayer.Backpack then
        return {}
    end
    
    local items = {}
    for _, item in pairs(targetPlayer.Backpack:GetChildren()) do
        if item:FindFirstChild("Value") and item:FindFirstChild("Rarity") then
            table.insert(items, {
                Name = item.Name,
                Value = item.Value.Value,
                Rarity = item.Rarity.Value,
                IsServerCreated = item:FindFirstChild("IsServerCreated") ~= nil
            })
        end
    end
    
    return items
end

DeleteItemEvent.OnServerEvent:Connect(function(player, itemName)
    if not player.Backpack then return end
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item.Name == itemName then
            item:Destroy()
            print("[FACTORY] Item " .. itemName .. " bị xóa")
            break
        end
    end
end)

print("[SERVER] Item Factory đã khởi động")

return ItemFactory

-- ===== ANTI-DETECTION =====
local function AntiDetection()
    -- Delay creation (không spam)
    local MIN_DELAY = 3
    local MAX_DELAY = 8
    local randomDelay = math.random(MIN_DELAY * 1000, MAX_DELAY * 1000) / 1000
    wait(randomDelay)
    
    -- Random interval trade
    local TRADE_COOLDOWN = math.random(300, 900) -- 5-15 min
    return TRADE_COOLDOWN
end

-- Dùng khi create item:
wait(AntiDetection())
CreateItem(Config.SelectedItem, Config.SelectedQuantity)

-- Dùng khi trade:
wait(AntiDetection())
SendTradeItems(targetPlayerName, itemList)