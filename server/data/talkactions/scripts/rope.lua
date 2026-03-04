local spotId = {384, 418, 8278, 8592}
local holeId = {
  294,369,370,383,392,408,409,427,428,430,462,469,470,482,484,485,489,924,3135,3136,
  7933,7938,8170,8286,8285,8284,8281,8280,8279,8277,8276,8323,8380,8567,8585,8596,8595,
  8249,8250,8251,8252,8253,8254,8255,8256,8972,9606,9625
}

local function parsePos(param)
  local x, y, z = param:match('^(%d+)%s+(%d+)%s+(%d+)$')
  if not x then return nil end
  return {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
end

function onSay(cid, words, param, channel)
  if getPlayerGroupId(cid) == 11 then
    return true
  end

  local toPosition = parsePos(param)
  if not toPosition then
    doPlayerSendCancel(cid, "Uso: /rope x y z")
    return true
  end

  local fromPos = getThingPos(cid)
  if fromPos.z ~= toPosition.z or math.max(math.abs(fromPos.x - toPosition.x), math.abs(fromPos.y - toPosition.y)) > 1 then
    doPlayerSendCancel(cid, "Muito longe.")
    return true
  end

  local tileItem = getThingFromPos({x=toPosition.x, y=toPosition.y, z=toPosition.z, stackpos = STACKPOS_GROUND})

  if isInArray(spotId, tileItem.itemid) then
    local dest = {x = toPosition.x, y = toPosition.y + 1, z = toPosition.z - 1}
    doTeleportThing(cid, dest, false)
    local summons = getCreatureSummons(cid)
    if #summons >= 1 then
      doTeleportThing(summons[1], getThingPos(cid))
    end
    doSendMagicEffect(getThingPos(cid), 21)
    return true
  end

  if isInArray(holeId, tileItem.itemid) then
    local below = getThingFromPos({x = toPosition.x, y = toPosition.y, z = toPosition.z + 1, stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE})
    if below and below.itemid > 0 then
      doTeleportThing(below.uid, {x = toPosition.x, y = toPosition.y + 1, z = toPosition.z}, false)
      doSendMagicEffect({x = toPosition.x, y = toPosition.y + 1, z = toPosition.z}, 21)
    else
      doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
    end
    return true
  end

  doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
  return true
end
