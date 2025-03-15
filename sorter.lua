monitor = peripheral.wrap("top") --on attend un ecran de control sur le dessus
mainConfig = "main.txt" --nom du fichier indiquant tout les fichier de gestion
wifi = peripheral.wrap("bottom") --on attend que il y a un wireless modem ou ender modem en dessous de l'ordinateur
channel = 666 --channel de gestion du système
newChestConfig = {} --cette variable servira a changer le group des coffre a vif
needAssignement = false -- cette variable sert a determiner si on doit modifier le fichier de type triable
usersRequest = {} --tableau contenant tout les requete de ressource par joueur
users = {} --tableau contenant le coffre a envoyé les requête

local function determine(item, classement, minecraftCategory , modedException)
    
    local namespace, itemName = item:match("([^:]+):([^:]+)")
    if (modedException[item] or 0) ~= 0 then
        return modedException[item]
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

local function takeRequest(identifier, itemName, quantity)
    if not usersRequest[identifier] then
        usersRequest[identifier] = {}
    end
    usersRequest[identifier][itemName] = (usersRequest[identifier][itemName] or 0) + tonumber(quantity)
end

local function processRequest(chestTable)
    for identifier, requests in pairs(usersRequest) do
        for itemName, quantity in pairs(requests) do
            local groupNumber = determine(itemName, classement, minecraftCategory, modedException)
            for chest, group in pairs(chestTable) do
                if group == groupNumber then
                    local inventory = peripheral.wrap(chest)
                    if inventory then
                        for slot, item in pairs(inventory.list()) do
                            if item.name == itemName then
                                local sentAmount = inventory.pushItems(users[identifier], slot, quantity)
                                quantity = quantity - sentAmount
                                if quantity <= 0 then
                                    usersRequest[identifier][itemName] = nil
                                    break
                                else
                                    usersRequest[identifier][itemName] = quantity
                                end
                            end
                        end
                    end
                end
            end
            if next(usersRequest[identifier]) == nil then
                usersRequest[identifier] = nil
            end
        end
    end
end

local function updateChestConfig(storageName, groupNumber)
    local triableFile = chargedConfig["triable"]
    local updatedConfig = {}
    local file = fs.open(triableFile, "r")
    if file then
        for line in file.readAll():gmatch("([^\n]+)") do
            local name, group = line:match("(%S+)%s*:%s*(%S+)")
            if name then
                updatedConfig[name] = tonumber(group)
            end
        end
        file.close()
    end
    
    -- Met à jour ou ajoute la nouvelle configuration
    updatedConfig[storageName] = tonumber(groupNumber)
    newChestConfig = updatedConfig
    needAssignement = true
end

local function updateTriable()
    local triableFile = chargedConfig["triable"]
    fs.delete(triableFile)
    file = fs.open(triableFile, "w")
    if file then
        for name, group in pairs(newChestConfig) do
            file.writeLine(name .. " : " .. group )
        end
        file.close()
    else
        print("Erreur : Impossible d'écrire dans le fichier de trie")
    end
end

local function loadUsersConfig(chargedConfig)
    local file = fs.open(chargedConfig["users"], "r")
    if file then
        for line in file.readAll():gmatch("([^\n]+)") do
            local name, chest = line:match("(%S+)%s*:%s*(%S+)")
            if name and chest then
                users[name] = chest
                usersRequest[name] = {}
            end
        end
        file.close()
    else
        print("Erreur : Impossible de charger le fichier users")
    end
end

local function loadMainConfig(mainConfig)
    local chargedConfig = {}
    local file = fs.open(mainConfig, "r")
    if file then
        for line in file.readAll():gmatch("([^\n]+)") do
            local name, fichier = line:match("(%S+)%s*:%s*(%S+)")
            if name and fichier then
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
    local file = fs.open(chargedConfig, "r")
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

local function loadException(filename)
    local data = {}
    local file = fs.open(filename, "r")
    if file then
        for line in file.readAll():gmatch("[^\n]+") do
            local key, value = line:match("(%S+:%S+)%s*:%s*(%d+)")
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



local function sendToGroup(chestTable, inventory, slot, groupNumber)
    for targetChest, targetGroup in pairs(chestTable) do
        if targetGroup == groupNumber then
            if inventory and inventory.pushItems(targetChest, slot) > 0 then
                return true
            end
        end
    end
    monitor.scroll(10)
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
            monitor.scroll(10)
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
                    monitor.scroll(10)
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
                monitor.scroll(10)
                monitor.write(item.name .. " a fini de être reparer!")
                sendToGroup(chestTable, repairInventory, slot, 0)
            end
        end
    end
end

local function mainLoop()
    while true do
        local chestTable = loadTriableConfig(chargedConfig["triable"])
        trier(chestTable , classement , minecraftCategory , modedException)
        if chargedConfig["repairChest"] then
            handleRepair(chestTable , chargedConfig["repairChest"])
        end
        trier(chestTable , classement , minecraftCategory , modedException)
        if needAssignement then
            updateTriable()
            needAssignement = false
        end
        processRequest(chestTable)
        os.sleep(2) -- Pause avant la prochaine itération
    end
end

local function parseMessage(message)
    local params = {}
    for param in message:gmatch('([%w_:]+)') do
        table.insert(params, param)
    end
    return unpack(params) -- Retourne chaque élément individuellement
end

local function networkingLoop() --actuelle non implémenté
    wifi.open(channel)
    local event, side, chanel, replyChannel, message, distance
    while true do
    repeat
          event, side, chanel, replyChannel, message, distance = os.pullEvent("modem_message")
    until chanel == channel
        local commande , paramOne , paramTwo , paramThree , ParamFour = parseMessage(message)
        if commande == "determine" then
            if paramOne then
              local groupNumber = determine(paramOne ,classement, minecraftCategory , modedException)
              wifi.transmit(replyChannel , channel , groupNumber)
            end
        elseif commande == "assign" then 
            if paramOne and paramTwo then
            updateChestConfig(paramOne , paramTwo)
            end
        elseif commande == "request" then
            if paramOne and paramTwo and paramThree then
                if determine(paramTwo ,classement, minecraftCategory , modedException) ~= 0 then
                takeRequest(paramOne , paramTwo , paramThree)
                monitor.scroll(10)
                monitor.write("utilisateur:"..paramOne.." a reserver :"..paramTwo .. " * "..paramThree)
                end
            end
        end
    end
end

chargedConfig = loadMainConfig(mainConfig)
if chargedConfig then 
    classement = loadFile(chargedConfig["classement"])
    minecraftCategory = loadFile(chargedConfig["minecraftCategory"])
    modedException = loadException(chargedConfig["modException"])
    loadUsersConfig(chargedConfig)
end

parallel.waitForAll(mainLoop, networkingLoop)
