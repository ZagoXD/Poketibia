function onLogout(cid)
  if Tournament and type(Tournament.onLogout) == "function" then
    return Tournament.onLogout(cid)
  end
  return true
end
