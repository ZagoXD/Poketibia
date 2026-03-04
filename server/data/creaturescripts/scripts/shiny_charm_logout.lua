function onLogout(cid)
  if type(shinyCharmPauseOnLogout) == "function" then
    shinyCharmPauseOnLogout(cid)
  end
  return true
end
