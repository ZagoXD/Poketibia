function onLogin(cid)
  if type(megaCharmResumeOnLogin) == "function" then
    megaCharmResumeOnLogin(cid)
  end

  registerCreatureEvent(cid, "MegaCharmKill")

  if type(megaCharmGetRemaining) == "function" then
    local rem = megaCharmGetRemaining(cid)
    if rem > 0 then
      local pretty = (type(megaCharmPrettyRemaining) == "function") and megaCharmPrettyRemaining(cid) or "alguns instantes"
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        "voce tem um mega charm ativo por " .. pretty .. ".")
    end
  end

  return true
end
