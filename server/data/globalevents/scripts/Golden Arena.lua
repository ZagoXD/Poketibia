function onTimer(cid, interval, lastExecution) 

doBroadcastMessage("A Golden Arena comeca em 10 minutos! Preparem-se!")
addEvent(doBroadcastMessage, 300000, "Golden Arena comeca em 5 minutos!\nEsperamos que os participantes ja estejam preparados!") 
addEvent(puxaParticipantes, 480000)  	
addEvent(doWave, 600000, true) --alterado v1.8       --480000 / 600000

return true
end