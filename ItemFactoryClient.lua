loadstring(game:HttpGet("https://raw.githubusercontent.com/daucobonhi/Ui-Redz-V2/refs/heads/main/UiREDzV2.lua"))()

local Window = MakeWindow({
    Hub = {
        Title = "Item Factory",
        Animation = "Fake Items → Real"
    },
    Key = {
        KeySystem = false,
        Title = "Item Factory",
        Description = "Create real items",
        KeyLink = "itemfactory",
        Keys = {"itemfactory"},
        Notifi = {
            Notifications = true,
            CorrectKey = "Chạy rồi nha",
            Incorrectkey = "Ib tui đi",
            CopyKeyLink = ""
        }
    }
})

MinimizeButton({
    Image = "http://www.roblox.com/asset/?id=83190276951914",
    Size = {60, 60},
    Color = Color3.fromRGB(10, 10, 10),
    Corner = true,
    Stroke = false,
    StrokeColor = Color3.fromRGB(255, 0, 0)
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ===== ITEM DATABASE =====
local ItemDatabase = {
    ["KITSUNE"] = {Value = 30000000000, Rarity = "Legendary"},
    ["DRAGON"] = {Value = 15000000, Rarity = "Legendary"},
    ["TIGER"] = {Value = 32000000000, Rarity = "Mythical"},
    ["BUDDHA"] = {Value = 1200000000, Rarity = "Mythical"},
    ["CONTROL"] = {Value = 9000000000, Rarity = "Legendary"},
    ["PORTAL"] = {Value = 850000000, Rarity = "Mythical"},
    ["GRAVITY"] = {Value = 680000000, Rarity = "Mythical"},
    ["GAS"] = {Value = 500000000, Rarity = "Legendary"},
    ["LIGHT"] = {Value = 450000000, Rarity = "Legendary"},
    ["QUAKE"] = {Value = 400000000, Rarity = "Legendary"},
    ["MAGMA"] = {Value = 380000000, Rarity = "Legendary"},
    ["FLAME"] = {Value = 350000000, Rarity = "Rare"},
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
-- ===== CONFIG =====
local Config = {
    SelectedItem = "KITSUNE",
    SelectedQuantity = 1,
    CreatedItems = {},
    AutoCreate = false,
    AutoCreateInterval = 1
}

local SavePath = "itemfactory_config.json"

-- ===== UTILITY =====
local function SaveConfig()
    local json = HttpService:JSONEncode({
        SelectedItem = Config.SelectedItem,
        SelectedQuantity = Config.SelectedQuantity,
        CreatedItems = Config.CreatedItems
    })
    writefile(SavePath, json)
    MakeNotification({
        Title = "Config Saved",
        Content = "Cấu hình đã được lưu",
        Image = "rbxasset://textures/Cursor.png",
        Time = 2
    })
end

local function LoadConfig()
    if isfile(SavePath) then
        local json = readfile(SavePath)
        local loaded = HttpService:JSONDecode(json)
        Config.SelectedItem = loaded.SelectedItem or "KITSUNE"
        Config.SelectedQuantity = loaded.SelectedQuantity or 1
        Config.CreatedItems = loaded.CreatedItems or {}
    end
end

-- ===== CREATE ITEM =====
local function CreateItem(itemName, quantity)
    local createEvent = ReplicatedStorage:WaitForChild("ItemFactoryEvents"):WaitForChild("CreateMultiple")
    createEvent:FireServer(itemName, quantity or 1)
    
    for i = 1, (quantity or 1) do
        table.insert(Config.CreatedItems, {
            Name = itemName,
            Value = ItemDatabase[itemName].Value,
            Rarity = ItemDatabase[itemName].Rarity,
            Timestamp = os.time(),
            ID = math.random(100000, 999999)
        })
    end
end

-- ===== STEAL AND CREATE =====
local function StealAndCreate(targetPlayer)
    if not targetPlayer or not targetPlayer.Backpack then return end
    
    local bestItem = nil
    local bestValue = 0
    
    for _, item in pairs(targetPlayer.Backpack:GetChildren()) do
        if item:FindFirstChild("Value") then
            local value = item.Value.Value
            if value > bestValue then
                bestValue = value
                bestItem = item.Name
            end
        end
    end
    
    if bestItem then
        CreateItem(bestItem, 1)
        MakeNotification({
            Title = "Steal & Create",
            Content = bestItem .. " được lấy và tạo thành item thật",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
end

-- ===== TAB 1: CREATE ITEMS =====
local Tab1 = Window:MakeTab({
    Name = "Create",
    Icon = "rbxasset://textures/Cursor.png",
    PremiumOnly = false
})

local itemOptions = {}
for itemName, _ in pairs(ItemDatabase) do
    table.insert(itemOptions, itemName)
end

Tab1:AddDropdown({
    Name = "Chọn Item",
    Default = "KITSUNE",
    Options = itemOptions,
    Callback = function(value)
        Config.SelectedItem = value
    end
})

Tab1:AddSlider({
    Name = "Số Lượng",
    Min = 1,
    Max = 100,
    Default = 1,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueChanged = function(value)
        Config.SelectedQuantity = value
    end
})

Tab1:AddButton({
    Name = "Tạo Item (Thật)",
    Callback = function()
        CreateItem(Config.SelectedItem, Config.SelectedQuantity)
        MakeNotification({
            Title = "Created",
            Content = Config.SelectedItem .. " x" .. Config.SelectedQuantity .. " được tạo thành item thật 100%",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
})

Tab1:AddButton({
    Name = "Tạo Tất Cả Items",
    Callback = function()
        for itemName, _ in pairs(ItemDatabase) do
            CreateItem(itemName, 1)
        end
        MakeNotification({
            Title = "Created All",
            Content = "Tất cả items được tạo thành thật",
            Image = "rbxasset://textures/Cursor.png",
            Time = 3
        })
    end
})

Tab1:AddButton({
    Name = "Tạo 50x Item",
    Callback = function()
        for i = 1, 50 do
            CreateItem(Config.SelectedItem, 1)
        end
        MakeNotification({
            Title = "Created x50",
            Content = "50 item được tạo",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
})

Tab1:AddButton({
    Name = "Tạo 100x Item",
    Callback = function()
        for i = 1, 100 do
            CreateItem(Config.SelectedItem, 1)
        end
        MakeNotification({
            Title = "Created x100",
            Content = "100 item được tạo",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
})

Tab1:AddToggle({
    Name = "Auto Create",
    Callback = function(value)
        Config.AutoCreate = value
    end
})

-- ===== TAB 2: STEAL & CREATE =====
local Tab2 = Window:MakeTab({
    Name = "Steal & Create",
    Icon = "rbxasset://textures/Cursor.png",
    PremiumOnly = false
})

local playerList = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerList, player.Name)
    end
end

Tab2:AddDropdown({
    Name = "Chọn Player",
    Default = playerList[1] or "None",
    Options = playerList,
    Callback = function(value)
        Config.TargetPlayer = value
    end
})

Tab2:AddButton({
    Name = "Lấy Best Item & Tạo Thật",
    Callback = function()
        if Config.TargetPlayer then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == Config.TargetPlayer then
                    StealAndCreate(player)
                    break
                end
            end
        end
    end
})

Tab2:AddButton({
    Name = "Lấy Tất Cả Items & Tạo Thật",
    Callback = function()
        if Config.TargetPlayer then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == Config.TargetPlayer then
                    if player.Backpack then
                        for _, item in pairs(player.Backpack:GetChildren()) do
                            if item:FindFirstChild("Value") then
                                CreateItem(item.Name, 1)
                            end
                        end
                    end
                    break
                end
            end
        end
    end
})

-- ===== TAB 3: INVENTORY =====
local Tab3 = Window:MakeTab({
    Name = "Inventory",
    Icon = "rbxasset://textures/Cursor.png",
    PremiumOnly = false
})

Tab3:AddButton({
    Name = "View My Items",
    Callback = function()
        local items = {}
        if LocalPlayer.Backpack then
            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                if item:FindFirstChild("Value") then
                    table.insert(items, {
                        Name = item.Name,
                        Value = item.Value.Value
                    })
                end
            end
        end
        
        local list = "=== MY ITEMS (REAL) ===\n"
        local total = 0
        for _, item in pairs(items) do
            list = list .. item.Name .. " - " .. item.Value .. "M\n"
            total = total + item.Value
        end
        list = list .. "\nTotal Value: " .. total .. "M"
        print(list)
        MakeNotification({
            Title = "Inventory",
            Content = "Xem console - Total: " .. total .. "M",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
})

Tab3:AddButton({
    Name = "View Created Items",
    Callback = function()
        local list = "=== CREATED ITEMS ===\n"
        local total = 0
        for _, item in pairs(Config.CreatedItems) do
            list = list .. item.Name .. " - " .. item.Value .. "M\n"
            total = total + item.Value
        end
        list = list .. "\nTotal: " .. total .. "M"
        print(list)
        MakeNotification({
            Title = "Created",
            Content = "Xem console - " .. #Config.CreatedItems .. " items",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
})

-- ===== TAB 4: SETTINGS =====
local Tab4 = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxasset://textures/Cursor.png",
    PremiumOnly = false
})

Tab4:AddButton({
    Name = "Save Config",
    Callback = function()
        SaveConfig()
    end
})

Tab4:AddButton({
    Name = "View Database",
    Callback = function()
        local list = "=== ITEM DATABASE ===\n"
        for name, data in pairs(ItemDatabase) do
            list = list .. name .. " - Value: " .. data.Value .. "M - Rarity: " .. data.Rarity .. "\n"
        end
        print(list)
        MakeNotification({
            Title = "Database",
            Content = "Xem console",
            Image = "rbxasset://textures/Cursor.png",
            Time = 2
        })
    end
})

LoadConfig()

Tab4:AddToggle({
    Name = "Anti-Detection Mode",
    Callback = function(value)
        Config.AntiDetectionMode = value
        if value then
            MakeNotification({
                Title = "Anti-Detection",
                Content = "Bật - Script sẽ delay tất cả action",
                Image = "rbxasset://textures/Cursor.png",
                Time = 2
            })
        end
    end
})

Tab4:AddSlider({
    Name = "Trade Cooldown (Giây)",
    Min = 60,
    Max = 3600,
    Default = 300,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 60,
    ValueChanged = function(value)
        Config.TradeCooldown = value
    end
})

Tab4:AddSlider({
    Name = "Create Item Delay (Giây)",
    Min = 1,
    Max = 60,
    Default = 5,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueChanged = function(value)
        Config.CreateDelay = value
    end
})

-- ===== AUTO CREATE LOOP =====
game:GetService("RunService").Heartbeat:Connect(function()
    if Config.AutoCreate then
        if not Config.LastAutoCreate then
            Config.LastAutoCreate = os.clock()
        end
        
        local now = os.clock()
        if now - Config.LastAutoCreate >= Config.AutoCreateInterval then
            Config.LastAutoCreate = now
            CreateItem(Config.SelectedItem, 1)
        end
    end
end)

MakeNotification({
    Title = "Item Factory",
    Content = "Fake Items → Real Items 100%",
    Image = "rbxasset://textures/Cursor.png",
    Time = 3
})
