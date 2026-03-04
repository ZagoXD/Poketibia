function onKill(cid, target, lastHit)
  if not isMonster(target) then return true end
  local arenaId = Raid.bossArena and Raid.bossArena[target] or nil
  if arenaId then
    addEvent(function()
      if Raid and Raid.winFight then Raid.winFight(arenaId) end
    end, 1)
  end
  return true
end

function onLogin(cid)
  if getPlayerStorageValue(cid, RAID_STOR.ACTIVE) == 1 and getPlayerStorageValue(cid, RAID_STOR.STAGE) >= 2 then
    doTeleportThing(cid, RAID_EXIT_POS, true)
    Raid.clearPlayer(cid)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Seu andamento na raid foi encerrado.")
  end
  return true
end

function onLogout(cid)
  if Raid.isActive(cid) and getPlayerStorageValue(cid, RAID_STOR.STAGE) >= 2 then
    return true
  end
  return true
end

function onPrepareDeath(cid, killer)
  if not isPlayer(cid) then return true end
  if Raid.isActive(cid) then
    Raid.clearPlayer(cid)
    setPlayerStorageValue(cid, RAID_STOR.REMOVING, 0)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, "Voce foi retirado da raid.")
    return true
  end
  return true
end


