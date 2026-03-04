function onKill(cid, target, lastHit)
  if not isPlayer(cid) or not isMonster(target) then
    return true
  end
  local mname = getCreatureName(target)
  if type(megaCharmOnKill) == "function" then
    megaCharmOnKill(cid, mname)
  end
  return true
end
