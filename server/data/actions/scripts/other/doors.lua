local ELITE_GATE_AID = 45000
local ELITE_DOOR_DEST = {
  [45000] = {x = 559, y = 1063, z = 5},
  [45001] = {x = 567, y = 1068, z = 4},
  [45002] = {x = 563, y = 1073, z = 3},
  [45003] = {x = 557, y = 1062, z = 2},
  [45004] = {x = 550, y = 1068, z = 1},
  [45005] = {x = 570, y = 1068, z = 0},
}

local MIN_LEVEL = 200

local ELITE_ACCOUNT_STORAGE = 9351

local ELITE_PROGRESS_DOORS = {
  [45001] = 1, -- venceu Lorelei
  [45002] = 2, -- venceu Bruno
  [45003] = 3, -- venceu Agatha
  [45004] = 4, -- venceu Lance
  [45005] = 5, -- venceu Green
}

local function eliteDoorEnter(cid, item, aid)
  local dest = ELITE_DOOR_DEST[aid]
  if not dest then return false end
  doTeleportThing(cid, dest)
  doSendMagicEffect(dest, CONST_ME_TELEPORT)
  return true
end

local function checkStackpos(item, position)
  position.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE
  local thing = getThingFromPos(position)

  position.stackpos = STACKPOS_TOP_FIELD
  local field = getThingFromPos(position)

  return (item.uid == thing.uid or thing.itemid < 100 or field.itemid == 0)
end

local function doorEnter(cid, item, toPosition)
  doTransformItem(item.uid, item.itemid + 1)
  doTeleportThing(cid, toPosition)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  if item.actionid == ELITE_GATE_AID or item.uid == ELITE_GATE_AID then
    if getPlayerLevel(cid) < MIN_LEVEL then
      doPlayerSendCancel(cid, "Voce precisa ser level " .. MIN_LEVEL .. " para entrar na Elite dos 4.")
      return true
    end

    if not isPremium(cid) then
      doPlayerSendCancel(cid, "Apenas VIP pode entrar na Elite dos 4.")
      return true
    end

    if type(gymHasAllBadges) ~= "function" or not gymHasAllBadges(cid) then
      doPlayerSendCancel(cid, "Voce precisa das 8 Insignias para entrar na Elite dos 4.")
      return true
    end

    local accId = getPlayerAccountId(cid)
    if type(getAccountStorageValue) == "function" then
      if getAccountStorageValue(accId, ELITE_ACCOUNT_STORAGE) > 0 then
        doPlayerSendCancel(cid, "Sua conta ja venceu o Campeao. Nao pode entrar novamente.")
        return true
      end
    end

    if type(eliteChampionLocked) == "function" and eliteChampionLocked(cid) then
      doPlayerSendCancel(cid, "Voce ja venceu o Campeao. Nao pode entrar novamente.")
      return true
    end

    if type(eliteRunStart) == "function" then
      local ok, reason = eliteRunStart(cid, true)
      if not ok then
        doPlayerSendCancel(cid, reason or "A Elite ja esta sendo desafiada.")
        return true
      end
    end

    eliteDoorEnter(cid, item, 45000)
    return true
  end

  local eliteKey = ELITE_PROGRESS_DOORS[item.actionid] and item.actionid
                or ELITE_PROGRESS_DOORS[item.uid] and item.uid
                or nil
  local reqIdx = eliteKey and ELITE_PROGRESS_DOORS[eliteKey] or nil

	if reqIdx then
	if reqIdx == 5 then
		local ok = false

		if type(eliteRunHasDefeated) == "function" and eliteRunHasDefeated(cid, 5) then
		ok = true
		end

		if not ok and type(eliteChampionLocked) == "function" and eliteChampionLocked(cid) then
		ok = true
		end

		if not ok and type(getAccountStorageValue) == "function" then
		local accId = getPlayerAccountId(cid)
		if getAccountStorageValue(accId, ELITE_ACCOUNT_STORAGE) > 0 then
			ok = true
		end
		end

		if not ok then
		doPlayerSendCancel(cid, "Voce precisa derrotar o Green antes de passar.")
		return true
		end

		eliteDoorEnter(cid, item, eliteKey)
		return true
	end

	if type(eliteRunIsActive) ~= "function" or not eliteRunIsActive(cid) then
		doPlayerSendCancel(cid, "Voce nao esta em uma run da Elite.")
		return true
	end

	if type(eliteRunHasDefeated) ~= "function" or not eliteRunHasDefeated(cid, reqIdx) then
		local names = {"Lorelei", "Bruno", "Agatha", "Lance", "Green"}
		doPlayerSendCancel(cid, "Voce precisa derrotar " .. (names[reqIdx] or "o desafio anterior") .. " antes de passar.")
		return true
	end

	eliteDoorEnter(cid, item, eliteKey)
	return true
	end


  if(fromPosition.x ~= CONTAINER_POSITION and isPlayerPzLocked(cid) and getTileInfo(fromPosition).protection) then
    doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
    return true
  end

  if(getItemLevelDoor(item.itemid) > 0) then
    if(item.actionid == 189) then
      if(not isPremium(cid)) then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
        return true
      end

      doorEnter(cid, item, toPosition)
      return true
    end

    local gender = item.actionid - 186
    if(isInArray({PLAYERSEX_FEMALE,  PLAYERSEX_MALE, PLAYERSEX_GAMEMASTER}, gender)) then
      if(gender ~= getPlayerSex(cid)) then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
        return true
      end

      doorEnter(cid, item, toPosition)
      return true
    end

    local skull = item.actionid - 180
    if(skull >= SKULL_NONE and skull <= SKULL_BLACK) then
      if(skull ~= getCreatureSkullType(cid)) then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
        return true
      end

      doorEnter(cid, item, toPosition)
      return true
    end

    local group = item.actionid - 150
    if(group >= 0 and group < 30) then
      if(group > getPlayerGroupId(cid)) then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
        return true
      end

      doorEnter(cid, item, toPosition)
      return true
    end

    local vocation = item.actionid - 100
    if(vocation >= 0 and vocation < 50) then
      local playerVocationInfo = getVocationInfo(getPlayerVocation(cid))
      if(playerVocationInfo.id ~= vocation and playerVocationInfo.fromVocation ~= vocation) then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
        return true
      end

      doorEnter(cid, item, toPosition)
      return true
    end

    if(item.actionid == 190 or (item.actionid ~= 0 and getPlayerLevel(cid) >= (item.actionid - getItemLevelDoor(item.itemid)))) then
      doorEnter(cid, item, toPosition)
    else
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
    end

    return true
  end

  if(isInArray(specialDoors, item.itemid)) then
    if(item.actionid == 100 or (item.actionid ~= 0 and getPlayerStorageValue(cid, item.actionid) > 0)) then
      doorEnter(cid, item, toPosition)
    else
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The door seems to be sealed against unwanted intruders.")
    end

    return true
  end

  if(isInArray(keys, item.itemid)) then
    if(itemEx.actionid > 0) then
      if(item.actionid == itemEx.actionid and doors[itemEx.itemid] ~= nil) then
        doTransformItem(itemEx.uid, doors[itemEx.itemid])
        return true
      end

      doPlayerSendCancel(cid, "The key does not match.")
      return true
    end

    return false
  end

  if(isInArray(horizontalOpenDoors, item.itemid) and checkStackpos(item, fromPosition)) then
    local newPosition = toPosition
    newPosition.y = newPosition.y + 1
    local doorPosition = fromPosition
    doorPosition.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE
    local doorCreature = getThingfromPos(doorPosition)
    if(doorCreature.itemid ~= 0) then
      local pzDoorPosition = getTileInfo(doorPosition).protection
      local pzNewPosition = getTileInfo(newPosition).protection
      if((pzDoorPosition and not pzNewPosition and doorCreature.uid ~= cid) or
        (not pzDoorPosition and pzNewPosition and doorCreature.uid == cid and isPlayerPzLocked(cid))) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
      else
        doTeleportThing(doorCreature.uid, newPosition)
        if(not isInArray(closingDoors, item.itemid)) then
          doTransformItem(item.uid, item.itemid - 1)
        end
      end

      return true
    end

    doTransformItem(item.uid, item.itemid - 1)
    return true
  end

  if(isInArray(verticalOpenDoors, item.itemid) and checkStackpos(item, fromPosition)) then
    local newPosition = toPosition
    newPosition.x = newPosition.x + 1
    local doorPosition = fromPosition
    doorPosition.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE
    local doorCreature = getThingfromPos(doorPosition)
    if(doorCreature.itemid ~= 0) then
      if(getTileInfo(doorPosition).protection and not getTileInfo(newPosition).protection and doorCreature.uid ~= cid) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
      else
        doTeleportThing(doorCreature.uid, newPosition)
        if(not isInArray(closingDoors, item.itemid)) then
          doTransformItem(item.uid, item.itemid - 1)
        end
      end

      return true
    end

    doTransformItem(item.uid, item.itemid - 1)
    return true
  end

  if(doors[item.itemid] ~= nil and checkStackpos(item, fromPosition)) then
    if(item.actionid == 0) then
      doTransformItem(item.uid, doors[item.itemid])
    else
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "It is locked.")
    end

    return true
  end

  local houseDoors = {
    [11790] = 11792,
    [11791] = 11792,
    [11792] = 11790,
    [11793] = 11795,
    [11794] = 11795,
    [11795] = 11793,
    [11796] = 11797,
    [11797] = 11796,
    [11798] = 11799,
    [11799] = 11798,
    [11800] = 11801,
    [11801] = 11800,
    [11802] = 11803,
    [11803] = 11802,
  }

  if houseDoors[item.itemid] then
    doTransformItem(item.uid, houseDoors[item.itemid])
    return true
  end

  return false
end
