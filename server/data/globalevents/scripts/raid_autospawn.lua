local function pickRandomFreeLobby()
  local ids = {}
  for id, def in pairs(RAID_LOBBY_SPAWNS) do
    if def and def.center and not Raid.lobbies[id] then
      table.insert(ids, id)
    end
  end
  if #ids == 0 then return nil end
  return ids[math.random(1, #ids)]
end

function onStartup()
  addEvent(function()
    local id = pickRandomFreeLobby()
    if id then
      Raid.spawnLobby(id)
    else
      print("[RAID] AutoSpawn startup: nenhum lobby livre.")
    end
  end, 10000)
  return true
end

function onThink(interval, lastExecution)
  local id = pickRandomFreeLobby()
  if id then
    Raid.spawnLobby(id)
  else
    print("[RAID] AutoSpawn: nenhum lobby livre (todos ativos?).")
  end
  return true
end
