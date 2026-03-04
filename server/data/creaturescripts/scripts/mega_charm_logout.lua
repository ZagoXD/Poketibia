function onLogout(cid)
  if type(megaCharmPauseOnLogout) == "function" then
    megaCharmPauseOnLogout(cid)
  end
  return true
end
