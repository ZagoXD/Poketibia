function onSay(cid, words, param)
  param = (param or ""):lower()

  if param == "" or param == "help" then
    doPlayerSendTextMessage(cid, 20, "Comandos: !tournament register | !tournament leave | !tournament status | !tournament start")
    return true
  end

  if param == "register" then
    Tournament.register(cid)
    return true
  end

  if param == "leave" then
    Tournament.leave(cid)
    return true
  end

  if param == "status" then
    Tournament.status(cid)
    return true
  end

  if param == "start" then
    if getPlayerGroupId(cid) < 4 then
      doPlayerSendTextMessage(cid, 20, "Apenas staff pode iniciar o torneio.")
      return true
    end
    Tournament.start(cid)
    return true
  end

  doPlayerSendTextMessage(cid, 20, "Parametro invalido. Use: register, leave, status, start.")
  return true
end