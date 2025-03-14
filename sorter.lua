local monitor = peripheral.wrap("top") --on attend un ecran de control sur le dessus
local mainConfig = "main.txt" --nom du fichier indiquant tout les fichier de gestion
local wifi = peripheral.wrap("bottom") --on attend que il y a un wireless modem ou ender modem en dessous de l'ordinateur
local channel = 666 --channel de gestion du système
local newChestConfig = {} --cette variable servira a changer le group des coffre a vif

local function loadMainConfig(mainConfig)
    local chargedConfig = {}
    local file = fs.open(mainConfig, "r")
    if file then
        for line in file.readAll():gmatch("([^\n]+)") do
            local name, fichier = line:match("(%S+)%s*:%s*(%S+)")
            if name and group then
                chargedConfig[name] = fichier
            end
        end
        file.close()
    else
        print("Erreur : Impossible de charger le fichier main Config")
    end
    return chargedConfig
end

local function loadTriableConfig(chargedConfig)
    local config = {}
    local file = fs.open(chargedConfig["triable"], "r")
    if file then
        for line in file.readAll():gmatch("([^\n]+)") do
            local name, group = line:match("(%S+)%s*:%s*(%S+)")
            if name and group then
                config[name] = tonumber(group)
            end
        end
        file.close()
    else
        print("Erreur : Impossible de charger le fichier de trie")
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

local function determine(item, classement, minecraftCategory , modedException)
    
    local namespace, itemName = item:match("([^:]+):([^:]+)")
    if (modedException[item.name] or 0) ~= 0 then
        return modedException[item.name]
    end
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
    monitor.scroll(-10)
    monitor.write("item group:".. groupNumber .." est plein!!!")
    return false
end

local function trier(chestTable )
    
    
    for chest, group in pairs(chestTable) do
        local inventory = peripheral.wrap(chest)
        if inventory then
            for slot, item in pairs(inventory.list()) do
                local groupNumber = determine(item.name, classement, minecraftCategory , modedException)
                if group ~= groupNumber then
                  sendToGroup(chestTable, inventory, slot, groupNumber)
                end
            end
        else
            monitor.scroll(-10)
            monitor.write("le stockage :"..chest.." est inategnable")
        end
    end
end

local function handleRepair(chestTable, repairChest)
    for chest, _ in pairs(chestTable) do
        local inventory = peripheral.wrap(chest)
        if inventory then
            for slot, item in pairs(inventory.list()) do
                if item.durability and (item.damage or 0) / (item.maxDamage or 1) > 0.2 then
                    monitor.scroll(-10)
                    monitor.write("envoie de ".. item.name .. " a la reparation!")
                    inventory.pushItems(peripheral.getName(repairChest), slot)
                end
            end
        end
    end
    
    local repairInventory = peripheral.wrap(repairChest)
    if repairInventory then
        for slot, item in pairs(repairInventory.list()) do
            if item.durability and (item.damage or 0) == 0 then
                monitor.scroll(-10)
                monitor.write(item.name .. " a fini de être reparer!")
                sendToGroup(chestTable, repairInventory, slot, 0)
            end
        end
    end
end

local function mainLoop()
    local chargedConfig = loadMainConfig(mainConfig)
    if chargedConfig then 
        classement = loadFile(chargedConfig["classement")
        minecraftCategory = loadFile(chargedConfig["minecraftCategory"])
        modedException = loadFile(chargedConfig["modException"])
    end
    while true do
        local chestTable = loadTriableConfig(chargedConfig)
        trier(chestTable , classement , minecraftCategory , modedException)
        if chargedConfig["repairChest"] then
            handleRepair(chestTable , chargedConfig["repairChest"])
        end
        trier(chestTable , classement , minecraftCategory , modedException)
        os.sleep(2) -- Pause avant la prochaine itération
    end
end

local function networkingLoop() --actuelle non implémenté
    wifi.open(channel)
    local event, side, chanel, replyChannel, message, distance
    while true do
    repeat
          event, side, chanel, replyChannel, message, distance = os.pullEvent("modem_message")
    until chanel == channel
        --local commande , paramOne , paramTwo , paramThree , ParamFour = message a decomposer tout les parametre doit être separer par des espace sauf si le parammetre est entouré de guillemet
    end
end


parallel.waitForAll(mainLoop, networkingLoop)
