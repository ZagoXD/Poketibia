function onKill(cid, target, lastHit)
  if not isPlayer(cid) or not isMonster(target) then
    return true
  end

  local mname = getCreatureName(target)
  if type(dailyKillOnKill) == "function" then
    dailyKillOnKill(cid, mname)
  end
  return true
end
