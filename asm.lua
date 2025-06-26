local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local detector = peripheral.find("playerDetector")

if not speaker then error("Aucun périphérique speaker détecté") end
if not detector then error("Aucun périphérique playerDetector détecté") end

-- Ouverture du canal rednet
local side = nil
for _, s in ipairs(rs.getSides()) do
    if peripheral.getType(s) == "modem" then
        rednet.open(s)
        side = s
        break
    end
end

if not side then error("Aucun modem détecté pour rednet") end
while true do
-- Attente d’un signal sur le canal 666
print("En attente d'une activation sur le canal 666...")
while true do
    local id, message, proto = rednet.receive(5)
    if id and proto == nil and tonumber(message) == 666 then
        print("Signal reçu sur le canal 666, activation de la détection de joueur.")
        break
    end
end

-- Détection de joueur
print("En attente d'un joueur dans un rayon de 20 blocs...")
while true do
    local players = detector.getPlayersInRange(20)
    if players and #players > 0 then
        print("Joueur détecté : " .. players[1])
        break
    end
    sleep(1)
end

-- Lecture audio
local url = "https://github.com/batyoplantix/minecraft/raw/refs/heads/main/sound_bomb.dfpwm"
local h = http.get(url)
if not h then error("Échec du téléchargement de l'audio") end

local decoder = dfpwm.make_decoder()
while true do
    local chunk = h.read(16 * 1024)
    if not chunk or #chunk == 0 then break end

    local buffer = decoder(chunk)
    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end

speaker.stop()
print("Lecture terminée.")
end
