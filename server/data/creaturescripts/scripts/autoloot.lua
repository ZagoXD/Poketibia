local LOOT_DELAY_MS = 50

local function tryAutoloot(cid, pos, corpseId)
  if not isPlayer(cid) then return true end
  local mode = autolootGetMode(cid)
  if mode == 0 then return true end

  local tileItem = getTileItemById(pos, corpseId)
  local corpse = tileItem and tileItem.uid or 0
  if corpse <= 0 or not isContainer(corpse) then return true end

  local owner = getItemAttribute(corpse, "corpseowner")
  if owner and owner > 0 and owner ~= cid then
    return true
  end

  local size = getContainerSize(corpse)
  if size <= 0 then return true end

  for slot = size-1, 0, -1 do
    local it = getContainerItem(corpse, slot)
    if it.uid > 0 and it.itemid > 0 then
      local take = false
      if mode == 1 then
        take = true
      elseif mode == 2 then
        take = autolootIsStone(it.itemid)
      end

      if take then
        local count = it.type > 0 and it.type or 1
        doPlayerAddItemStackingToBackpack(cid, it.itemid, count)
        doRemoveItem(it.uid)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
          string.format("AutoLoot: %dx %s.", count, getItemNameById(it.itemid)))
      end
    end
  end

  return true
end

function onKill(cid, target, lastHit)
  if not isPlayer(cid) then return true end
  if not isCreature(target) or isPlayer(target) then return true end

  local name = getCreatureName(target)
  local info = getMonsterInfo(name)
  if not info or not info.lookCorpse or info.lookCorpse == 0 then
    return true
  end

  local pos = getThingPos(target)
  addEvent(tryAutoloot, LOOT_DELAY_MS, cid, pos, info.lookCorpse)
  return true
end
