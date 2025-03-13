local repairChest = peripheral.wrap("minecraft:chest_0")

local function loadConfig()
    local config = {}
    local file = fs.open("triable.txt", "r")
    if file then
        for line in file.readAll():gmatch("([^\n]+)") do
            local name, group = line:match("(%S+)%s*:%s*(%S+)")
            if name and group then
                config["minecraft:"..name] = tonumber(group)
            end
        end
        file.close()
    else
        print("Erreur : Impossible de charger le fichier triable.txt")
    end
    return config
end

local function loadFile(filename)
    local data = {}
    local file = fs.open(filename, "r")
    if file then
        for line in file.readAll():gmatch("[^\n]+") do
            local key, value = line:match("(%S+)%s*:%s*(%S+)")
            if key and value then
                data[key] = tonumber(value)
            end
        end
        file.close()
    else
        print("Erreur : Impossible de charger le fichier " .. filename)
    end
    return data
end

local function determine(item, classement, minecraftCategory)
    local namespace, itemName = item:match("([^:]+):([^:]+)")
    if not namespace or not itemName then
        return 0
    end
    local group = classement[namespace] or 0
    if group == 0 then
        group = minecraftCategory[itemName] or 0
    end
    return group
end

local function sendToGroup(chestTable, inventory, slot, groupNumber)
    for targetChest, targetGroup in pairs(chestTable) do
        if targetGroup == groupNumber then
            if inventory and inventory.pushItems(targetChest, slot) > 0 then
                return true
            end
        end
    end
    return false
end

local function trier(chestTable)
    local classement = loadFile("classement.txt")
    local minecraftCategory = loadFile("minecraftCategory.txt")
    
    for chest, group in pairs(chestTable) do
        local inventory = peripheral.wrap(chest)
        if inventory then
            for slot, item in pairs(inventory.list()) do
                local groupNumber = determine(item.name, classement, minecraftCategory)
                if group ~= groupNumber then
                  sendToGroup(chestTable, inventory, slot, groupNumber)
                end
            end
        else
            print("Erreur : Impossible d'accéder au coffre " .. chest)
        end
    end
end

local function handleRepair(chestTable, repairChest)
    for chest, _ in pairs(chestTable) do
        local inventory = peripheral.wrap(chest)
        if inventory then
            for slot, item in pairs(inventory.list()) do
                if item.durability and item.damage / item.maxDamage < 0.9 then
                    inventory.pushItems(peripheral.getName(repairChest), slot)
                end
            end
        end
    end
    
    local repairInventory = peripheral.wrap(peripheral.getName(repairChest))
    if repairInventory then
        for slot, item in pairs(repairInventory.list()) do
            if item.durability and item.damage <= 1 then
                sendToGroup(chestTable, repairInventory, slot, 0)
            end
        end
    end
end

local function mainLoop()
    while true do
        local chestTable = loadConfig()
        trier(chestTable)
        handleRepair(chestTable , repairChest)
        os.sleep(10) -- Pause avant la prochaine itération
    end
end

mainLoop()
