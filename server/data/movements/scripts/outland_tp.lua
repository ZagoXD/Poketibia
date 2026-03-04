local MIN_LEVEL = 120

local DESTS = {
  [55340] = {x = 3116, y = 1294, z = 6},
  [55341] = {x = 3473, y = 1516, z = 6},
  [55342] = {x = 3128, y = 1676, z = 6},
}

local function isMountedOrSurf(cid)
  return getPlayerStorageValue(cid, 17000) >= 1
      or getPlayerStorageValue(cid, 17001) >= 1
      or getPlayerStorageValue(cid, 63215) >= 1
end

local function pullBack(cid, fromPos)
  local back = getClosestFreeTile(cid, fromPos, true, false)
  doTeleportThing(cid, back or fromPos, true)
  doSendMagicEffect(back or fromPos, CONST_ME_TELEPORT)
end

function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then return true end

  if getPlayerLevel(cid) < MIN_LEVEL then
    doPlayerSendCancel(cid, "Only level " .. MIN_LEVEL .. "+ may enter.")
    pullBack(cid, fromPosition)
    return true
  end

  if isMountedOrSurf(cid) then
    doPlayerSendCancel(cid, "You can't enter while flying, riding or surfing.")
    pullBack(cid, fromPosition)
    return true
  end

  local dest = DESTS[item.actionid]
  if dest then
    doSendMagicEffect(position, CONST_ME_TELEPORT)
    doTeleportThing(cid, dest, true)
    doSendMagicEffect(dest, CONST_ME_TELEPORT)
  end
  return true
end
