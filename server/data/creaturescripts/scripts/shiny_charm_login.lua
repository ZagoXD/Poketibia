function onLogin(cid)
  if type(shinyCharmResumeOnLogin) == "function" then
    shinyCharmResumeOnLogin(cid)
  end

  registerCreatureEvent(cid, "ShinyCharmKill")

  if type(shinyCharmGetRemaining) == "function" then
    local rem = shinyCharmGetRemaining(cid)
    if rem > 0 then
      local pretty = (type(shinyCharmPrettyRemaining) == "function") and shinyCharmPrettyRemaining(cid) or "alguns instantes"
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        "voce tem um shiny charm ativo por " .. pretty .. ".")
    end
  end

  return true
end
