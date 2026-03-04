function onStepIn(cid, item, position, fromPosition)
  local NPSpeed = PlayerSpeed + (getPlayerLevel(cid) * 0.1)
  local PSLimit = 1000

  if isPlayer(cid) and NPSpeed >= PSLimit then
    NPSpeed = PSLimit
  end
end

if getPlayerStorageValue(cid, 17000) >= 1 then
  return true
end

if getPlayerStorageValue(cid, 63215) >= 1 then
  doRemoveCondition(cid, CONDITION_OUTFIT)
  setPlayerStorageValue(cid, 63215, 0)

  local item = getPlayerSlotItem(cid, 8)
  local pokemon = getItemAttribute(item.uid, "poke")

  if getItemAttribute(item.uid, "nick") then
    doCreatureSay(cid, getItemAttribute(item.uid, "nick")..", I'm tired of surfing!", 1)
  else
    doCreatureSay(cid, getItemAttribute(item.uid, "poke")..", I'm tired of surfing!", 1)
  end

  doSummonMonster(cid, pokemon)
  local pk = getCreatureSummons(cid)[1]

  local NPSpeed = PlayerSpeed + (getPlayerLevel(cid) * 0.1)
  if NPSpeed >= 1000 then NPSpeed = 1000 end
  doChangeSpeed(pk, getCreatureSpeed(cid))
  doChangeSpeed(cid, -getCreatureSpeed(cid))
  doChangeSpeed(cid, NPSpeed)

  local offsets = {
    {x = 1, y = 0}, {x = -1, y = 0}, {x = 0, y = 1}, {x = 0, y = -1},
    {x = 1, y = 1}, {x = 1, y = -1}, {x = -1, y = 1}, {x = -1, y = -1}
  }

  local targetPos
  for i = 1, #offsets do
    local pos = {x = getThingPos(cid).x + offsets[i].x, y = getThingPos(cid).y + offsets[i].y, z = getThingPos(cid).z}
    if isTileWalkable(pos) and not getTopCreature(pos).uid then
      targetPos = pos
      break
    end
  end

  if not targetPos then
    doPlayerSendCancel(cid, "You can't leave surf!")
  end

  doTeleportThing(pk, targetPos, false)
  doCreatureSetLookDir(pk, getCreatureLookDir(cid))

  adjustStatus(pk, item.uid, true, false, true)
  return true
end

