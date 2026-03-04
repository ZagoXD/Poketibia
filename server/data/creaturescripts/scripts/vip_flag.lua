local OPCODE_VIP = 101

local function sendVipFlagTo(receiverCid, creature)
  if not isPlayer(receiverCid) or not isCreature(creature) or not isPlayer(creature) then return end
  local name = getCreatureName(creature)
  local flag = isPremium(creature) and 1 or 0
  doSendPlayerExtendedOpcode(receiverCid, OPCODE_VIP, name .. "|" .. flag)
end

local function broadcastVipToSpectators(creature)
  if not isPlayer(creature) then return end
  local pos = getThingPos(creature)
  for _, sid in ipairs(getSpectators(pos, 9, 7, false)) do
    if isPlayer(sid) then
      sendVipFlagTo(sid, creature)
    end
  end
end

function onLogin(cid)
  registerCreatureEvent(cid, "VipFlagSpawn")
  registerCreatureEvent(cid, "VipFlagWalk")

  sendVipFlagTo(cid, cid)
  broadcastVipToSpectators(cid)
  return true
end

function onSpawn(cid)
  if isPlayer(cid) then
    broadcastVipToSpectators(cid)
  end
  return true
end

function onWalk(cid, fromPos, toPos)
  if isPlayer(cid) then
    broadcastVipToSpectators(cid)
  end
  return true
end
