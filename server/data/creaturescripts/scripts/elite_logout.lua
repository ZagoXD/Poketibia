function onLogout(cid)
  if type(eliteRunIsActive) == "function" and eliteRunIsActive(cid) then
    if type(eliteRunAbort) == "function" then
      eliteRunAbort(cid)
    end
  end
  return true
end