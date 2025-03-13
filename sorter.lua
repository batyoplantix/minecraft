local function loadConfig()
    local config = {}
    local file = fs.open("triable.txt", "r")
    if file then
        for line in file.readAll():gmatch("[^]+") do
            local name, group = line:match("(%S+)%s*:%s*(%S+)")
            if name and group then
                config[name] = group
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
                data[key] = tonumber(value) or value
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

local function sendToGroup(chestTable, inevntory, slot, groupNumber)
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
                  sendToGroup(chestTable, ineventory, slot, groupNumber)
                end
            end
        else
            print("Erreur : Impossible d'accéder au coffre " .. chest)
        end
    end
end

local function mainLoop()
    while true do
        local chestTable = loadConfig()
        trier(chestTable)
        --handleRepair(chestTable)
        os.sleep(10) -- Pause avant la prochaine itération
    end
end

mainLoop()