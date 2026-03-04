function onDeath(cid, corpse, killer)
  if Raid and Raid.bossArena and Raid.bossArena[cid] then
    local arenaId = Raid.bossArena[cid]
    Raid.bossArena[cid] = nil
    addEvent(function()
      if Raid and Raid.winFight then Raid.winFight(arenaId) end
    end, 1)
  end
  return true
end
