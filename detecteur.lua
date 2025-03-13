-- On suppose que le coffre est devant la tortue
-- Utilisation de la bibliothèque Turtle pour l'interaction avec le jeu

local fs = require("fs")  -- Pour manipuler les fichiers

-- Fonction pour obtenir le nom sans namespace d'un objet
local function getNameWithoutNamespace(objectName)
    -- Suppose que le nom est séparé par ":"
    local nameWithoutNamespace = objectName:match("([^:]+)$")
    return nameWithoutNamespace
end

-- Fonction pour interagir avec le coffre et récupérer les items
local function getItemsFromChest()
    -- Regarder devant la tortue pour s'assurer qu'il y a un coffre
    turtle.inspect()  -- Inspecte l'objet devant (assumant que c'est un coffre)
    
    -- Liste pour stocker les noms des items
    local itemNames = {}
    
    -- On prend une estimation du nombre d'items (par exemple, 27 pour un coffre standard)
    for i = 1, 27 do
        local success, data = turtle.getItemDetail(i)  -- Essayer de récupérer l'item
        if success then
            local itemName = data.name  -- Récupérer le nom de l'objet
            table.insert(itemNames, getNameWithoutNamespace(itemName))  -- Ajouter sans namespace
        end
    end
    
    return itemNames
end

-- Fonction pour écrire les noms des items dans un fichier txt
local function writeItemNamesToFile(itemNames)
    local file = fs.open("minecraftCategory.txt", "w")  -- Crée ou ouvre un fichier
    for _, name in ipairs(itemNames) do
        file.writeLine(name.. " : 1")  -- Écrire chaque nom d'item
    end
    file.close()  -- Fermer le fichier
end

-- Fonction principale
local function main()
    local items = getItemsFromChest()  -- Récupérer les items
    writeItemNamesToFile(items)  -- Sauvegarder dans le fichier
    print("Les noms des items ont été enregistrés dans coffre_items.txt")
end

main()
