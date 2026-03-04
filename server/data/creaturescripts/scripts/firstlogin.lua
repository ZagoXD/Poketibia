function onLogin(cid)
  local STORAGE = 90001

  if getPlayerStorageValue(cid, STORAGE) ~= 1 then
    doTeleportThing(cid, {x=49, y=73, z=7})

    local target = 25

    local function expForLevel(lvl)
      if type(getExperienceForLevel) == 'function' then
        return getExperienceForLevel(lvl)
      end
      local l = lvl - 1
      return math.floor((50 * l * l * l - 150 * l * l + 400 * l) / 3)
    end

    local curLevel = getPlayerLevel(cid)
    if curLevel < target then
      local need = expForLevel(target) - getPlayerExperience(cid)
      if need > 0 then
        doPlayerAddExperience(cid, need)
      end
    end

    setPlayerStorageValue(cid, STORAGE, 1)
  end
  return true
end
