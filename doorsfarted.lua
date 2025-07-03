local pos1 = {x = 10, y = 64, z = 10}
local pos2 = {x = 20, y = 70, z = 20}

-- Nom du joueur leader
local leader = "lamastico"
local url1 = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/BRUIT1.dfpwm"
local url2 = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/Bruit2.dfpwm"
local url3 ="https://github.com/batyoplantix/minecraft/raw/refs/heads/main/Bruit3.dfpwm"
local url4 = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/bruit4.dfpwm"
local speaker = peripheral.wrap("speaker_1")
local redstoneRelay = peripheral.wrap("redstone_Relay_0")
local redstoneRelayTwo = peripheral.wrap("redstone_Relay_1")
local relayCheck = peripheral.wrap("redstone_Relay_2")
-- Nom du périphérique Player Detector (ex: "playerDetector_0")
local playerDetector = peripheral.wrap("playerDetector_0")
local triggerMessage = "labX"
local triggerLock = "lock"
function choisirAleatoirement()
    local options = {url1, url2, url3, url4}
    local index = math.random(1, #options)
    return options[index]
end

local function triggerRedOne()
    redstoneRelay.setOutput("back", true)  -- Changez "back" selon la face que vous utilisez
    sleep(1)
    redstoneRelay.setOutput("back", false)
end

local function triggerRedTwo()
    redstoneRelayTwo.setOutput("back", true)  -- Changez "back" selon la face que vous utilisez
    sleep(1)
    redstoneRelayTwo.setOutput("back", false)
end

local function checkRedstone()
    local droite = relayCheck.getInput("right")  -- Vérifie si redstone à droite
    local gauche = relayCheck.getInput("left")   -- Vérifie si redstone à gauche

    statusA(droite)
    statusB(gauche)
end

-- Fonction de déclenchement
function checkPlayersInZone()
    while true do
    local players = playerDetector.getPlayersInArea(pos1, pos2)

    for _, player in ipairs(players) do
        if player.name ~= leader then
        
            local decoder = dfpwm.make_decoder()
            local h = choisirAleatoirement()
            while true do
              local chunk = h.read(16 * 1024)
              if not chunk or #chunk == 0 then break end

              local buffer = decoder(chunk)
              while not speaker.playAudio(buffer) do
              os.pullEvent("speaker_audio_empty")
              end
            end
        end
    end
    end
end

function vocalChecks()
    while true do
    local event, username, message = os.pullEvent("chat")

    if message == triggerMessage and username == leader then
        triggerRedOne()
    end
    if message == triggerLock and username == leader then
        triggerRedTwo()
    end
    end
end

checkPlayersInZone()
