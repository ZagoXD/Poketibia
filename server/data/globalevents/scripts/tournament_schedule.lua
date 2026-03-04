function onTimer(cid, interval, lastExecution)
    if Tournament and Tournament.isRunning and Tournament.isRunning() then
        return true
    end

    doBroadcastMessage("O Torneio comeca em 10 minutos! Registre-se!")
    addEvent(doBroadcastMessage, 300000, "O Torneio comeca em 5 minutos! Preparem-se!")
    addEvent(function()
        if Tournament and Tournament.closeAndPull then
            Tournament.closeAndPull()
        end
    end, 480000)
    addEvent(function()
        if Tournament and Tournament.startIfReady then
            Tournament.startIfReady()
        end
    end, 600000)

    return true
end
