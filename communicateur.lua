local modem = peripheral.find("modem")
if not modem then
    error("Aucun modem détecté. Assurez-vous qu'un modem est connecté.")
end

local channel = 666 
modem.open(channel)

while true do
    print("Entrez un message à envoyer :")
    local userMessage = read()
    
    modem.transmit(channel, channel, userMessage)
    print("Message envoyé sur le canal " .. channel)
    
    local timer = os.startTimer(7)
    while true do
        local event, side, receivedChannel, replyChannel, message, distance = os.pullEvent()
        
        if event == "modem_message" and receivedChannel == channel then
            print("Réponse reçue: " .. tostring(message))
            break
        elseif event == "timer" and side == timer then
            print("Aucune réponse reçue après 7 secondes.")
            break
        end
    end
    
    sleep(1) -- Petite pause avant de recommencer
end
