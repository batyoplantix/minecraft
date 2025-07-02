local pos1 = {x = 10, y = 64, z = 10}
local pos2 = {x = 20, y = 70, z = 20}

-- Nom du joueur leader
local leader = "lamastico"
local url1 = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/BRUIT1.dfpwm"
local url2 = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/Bruit2.dfpwm"
local url3 ="https://github.com/batyoplantix/minecraft/raw/refs/heads/main/Bruit3.dfpwm"
local url4 = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/bruit4.dfpwm"
local speaker = peripheral.wrap("speaker_1")
-- Nom du périphérique Player Detector (ex: "playerDetector_0")
local playerDetector = peripheral.wrap("playerDetector_0")

function choisirAleatoirement()
    local options = {url1, url2, url3, url4}
    local index = math.random(1, #options)
    return options[index]
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

checkPlayersInZone()
