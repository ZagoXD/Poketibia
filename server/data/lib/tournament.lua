Tournament = Tournament or {}

Tournament.cfg = {
  coinId = 2149,
  entryCost = 2,
  maxPlayers = 16,

  prepSeconds = 5,
  breakSeconds = 20,

  duelStorage = 52481,
  gymBlockStorage = 990,

  registerStorage = 22560,
  stateStorage = 22561,
  pvpStorage = 22562,

  prizeId = 2149,
  relogOutStorage = 22563,
  outPos = {x = 1055, y = 1050, z = 7},
}

Tournament.arenas = {
  {a = {x=1131,y=576,z=0}, b = {x=1131,y=583,z=0}},
  {a = {x=1131,y=588,z=0}, b = {x=1131,y=595,z=0}},
  {a = {x=1146,y=576,z=0}, b = {x=1146,y=583,z=0}},
  {a = {x=1146,y=588,z=0}, b = {x=1146,y=595,z=0}},
  {a = {x=1157,y=576,z=0}, b = {x=1157,y=583,z=0}},
  {a = {x=1157,y=588,z=0}, b = {x=1157,y=595,z=0}},
  {a = {x=1172,y=576,z=0}, b = {x=1172,y=583,z=0}},
  {a = {x=1172,y=588,z=0}, b = {x=1172,y=595,z=0}},
}

Tournament.area = {
  fromPos = {x=1127,y=575,z=0}, 
  toPos   = {x=1175,y=597,z=0} 
}

Tournament._loaded = Tournament._loaded or false
Tournament.registered = Tournament.registered or {}
Tournament.order = Tournament.order or {}
Tournament.running = Tournament.running or false
Tournament.round = Tournament.round or 0
Tournament.initialCount = Tournament.initialCount or 0
Tournament.matches = Tournament.matches or {}
Tournament.playerMatch = Tournament.playerMatch or {}
Tournament._phase = Tournament._phase or "idle"
Tournament._phaseUntil = Tournament._phaseUntil or 0
Tournament._tickScheduled = Tournament._tickScheduled or false

local function now()
  return os.time()
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function splitCsv(str)
  local t = {}
  if not str or str == -1 or str == "" then return t end
  for part in string.gmatch(str, "([^,]+)") do
    part = trim(part)
    if part ~= "" then
      table.insert(t, part)
    end
  end
  return t
end

local function joinCsv(t)
  local s = ""
  for i=1,#t do
    s = s .. t[i] .. ","
  end
  return s
end

local function msgPlayerByName(name, text)
  local cid = getPlayerByName(name)
  if cid and cid > 0 and isPlayer(cid) then
    doPlayerSendTextMessage(cid, 20, text)
  end
end

local function sendStartMsg(cid, text)
  if cid and isPlayer(cid) then
    doPlayerSendTextMessage(cid, 20, text)
  else
    doBroadcastMessage(text)
  end
end

local function posInArea(pos, fromPos, toPos)
  return pos.z == fromPos.z
     and pos.x >= math.min(fromPos.x, toPos.x) and pos.x <= math.max(fromPos.x, toPos.x)
     and pos.y >= math.min(fromPos.y, toPos.y) and pos.y <= math.max(fromPos.y, toPos.y)
end

function Tournament.isPvpEnabled()
  return getGlobalStorageValue(Tournament.cfg.pvpStorage) == 1
end

function Tournament.isRunning()
  return getGlobalStorageValue(Tournament.cfg.stateStorage) == 1
end

function Tournament.isInTournamentArea(cid)
  if not isCreature(cid) then return false end
  return posInArea(getThingPos(cid), Tournament.area.fromPos, Tournament.area.toPos)
end

function Tournament._load()
  if Tournament._loaded then return end
  Tournament._loaded = true

  Tournament.registered = {}
  Tournament.order = {}

  local raw = getGlobalStorageValue(Tournament.cfg.registerStorage)
  local arr = splitCsv(raw)

  for i=1,#arr do
    local n = arr[i]
    Tournament.registered[n] = true
    table.insert(Tournament.order, n)
  end

  Tournament.running = Tournament.isRunning()
end

function Tournament._save()
  setGlobalStorageValue(Tournament.cfg.registerStorage, joinCsv(Tournament.order))
end

function Tournament._setPvp(on)
  setGlobalStorageValue(Tournament.cfg.pvpStorage, on and 1 or -1)
end

function Tournament._setRunning(on)
  setGlobalStorageValue(Tournament.cfg.stateStorage, on and 1 or -1)
end

function Tournament._setFightLocks(name, on)
  local cid = getPlayerByName(name)
  if not cid or cid <= 0 or not isPlayer(cid) then return end
  setPlayerStorageValue(cid, Tournament.cfg.duelStorage, on and 1 or -1)
  setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, on and 1 or -1)
end

function Tournament._clearPlayerFlags(name)
  local cid = getPlayerByName(name)
  if cid and cid > 0 and isPlayer(cid) then
    setPlayerStorageValue(cid, IS_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, PLAYER_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, Tournament.cfg.duelStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, -1)
  end
end

function Tournament._teleport(name, pos)
  local cid = getPlayerByName(name)
  if cid and cid > 0 and isPlayer(cid) then
    doTeleportThing(cid, pos)
    doSendMagicEffect(pos, CONST_ME_TELEPORT)
  end
end

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

local function isAllowedCount(n)
  return (n == 2 or n == 4 or n == 8 or n == 16)
end

local function nearestAllowedDown(n)
  if n >= 16 then return 16 end
  if n >= 8 then return 8 end
  if n >= 4 then return 4 end
  if n >= 2 then return 2 end
  return 0
end

local function playerHasPokemonByName(name)
  local cid = getPlayerByName(name)
  if not cid or cid <= 0 or not isPlayer(cid) then return false end
  if type(hasPokemon) ~= "function" then return true end
  return hasPokemon(cid)
end

function Tournament.register(cid)
  Tournament._load()

  if Tournament.isRunning() then
    return doPlayerSendTextMessage(cid, 20, "O torneio ja esta em andamento.")
  end

  local name = getCreatureName(cid)

  if Tournament.registered[name] then
    return doPlayerSendTextMessage(cid, 20, "Voce ja esta registrado no torneio.")
  end

  if #Tournament.order >= Tournament.cfg.maxPlayers then
    return doPlayerSendTextMessage(cid, 20, "Limite de jogadores atingido para o torneio.")
  end

  if getPlayerItemCount(cid, Tournament.cfg.coinId) < Tournament.cfg.entryCost then
    return doPlayerSendTextMessage(cid, 20, "Voce nao tem Meowth Coins suficientes para registrar.")
  end

  doPlayerRemoveItem(cid, Tournament.cfg.coinId, Tournament.cfg.entryCost)

  Tournament.registered[name] = true
  table.insert(Tournament.order, name)
  Tournament._save()

  return doPlayerSendTextMessage(cid, 20, "Registro confirmado. Aguarde o inicio do torneio.")
end

function Tournament.leave(cid)
  Tournament._load()

  if Tournament.isRunning() then
    return doPlayerSendTextMessage(cid, 20, "Voce nao pode sair. O torneio ja esta em andamento.")
  end

  local name = getCreatureName(cid)
  if not Tournament.registered[name] then
    return doPlayerSendTextMessage(cid, 20, "Voce nao esta registrado no torneio.")
  end

  local newOrder = {}
  for i=1,#Tournament.order do
    if Tournament.order[i] ~= name then
      table.insert(newOrder, Tournament.order[i])
    end
  end
  Tournament.order = newOrder
  Tournament.registered[name] = nil
  Tournament._save()

  doPlayerAddItem(cid, Tournament.cfg.coinId, Tournament.cfg.entryCost)
  return doPlayerSendTextMessage(cid, 20, "Voce saiu do torneio e foi reembolsado.")
end

function Tournament.status(cid)
  Tournament._load()

  local n = #Tournament.order
  local running = Tournament.isRunning() and "sim" or "nao"
  local pvp = Tournament.isPvpEnabled() and "sim" or "nao"

  doPlayerSendTextMessage(cid, 20, "Torneio rodando: " .. running .. " | PvP: " .. pvp .. " | Registrados: " .. n .. "/" .. Tournament.cfg.maxPlayers)
  if n > 0 then
    doPlayerSendTextMessage(cid, 20, "Use !tournament start para iniciar (se tiver 2/4/8/16).")
  end
end

function Tournament._refundLastUntilAllowed()
  Tournament._load()

  local n = #Tournament.order
  local allowed = nearestAllowedDown(n)
  if allowed < 2 then
    return 0, 0
  end

  local refunded = 0
  while #Tournament.order > allowed do
    local last = Tournament.order[#Tournament.order]
    Tournament.order[#Tournament.order] = nil
    Tournament.registered[last] = nil

    local cid = getPlayerByName(last)
    if cid and cid > 0 and isPlayer(cid) then
      doPlayerAddItem(cid, Tournament.cfg.coinId, Tournament.cfg.entryCost)
      doPlayerSendTextMessage(cid, 20, "Voce foi reembolsado porque a quantidade de jogadores nao fechou para iniciar.")
    end
    refunded = refunded + 1
  end

  Tournament._save()
  return allowed, refunded
end

function Tournament.start(cid)
  Tournament._load()

  if Tournament.isRunning() then
    sendStartMsg(cid, "O torneio ja esta em andamento.")
    return true
  end

  local n = #Tournament.order
  if n < 2 then
    sendStartMsg(cid, "Numero insuficiente de jogadores. Minimo: 2.")
    return true
  end

  if not isAllowedCount(n) then
    local allowed, refunded = Tournament._refundLastUntilAllowed()
    if allowed < 2 then
      sendStartMsg(cid, "Nao foi possivel ajustar a quantidade. Minimo: 2.")
      return true
    end
    sendStartMsg(cid, "Jogadores ajustados para " .. allowed .. ". Reembolsados: " .. refunded .. ".")
    n = allowed
  end

  local players = {}
  for i=1,#Tournament.order do
    local name = Tournament.order[i]
    local pid = getPlayerByName(name)
    if pid and pid > 0 and isPlayer(pid) then
      table.insert(players, name)
    else
      Tournament.registered[name] = nil
    end
  end

  if #players < 2 then
    Tournament.order = {}
    Tournament._save()
    sendStartMsg(cid, "Poucos jogadores online para iniciar. Limpei a lista de registro.")
    return true
  end

  Tournament._setRunning(true)
  Tournament._setPvp(false)

  Tournament.running = true
  Tournament.round = 0
  Tournament.initialCount = #players
  Tournament.matches = {}
  Tournament.playerMatch = {}
  Tournament._phase = "idle"
  Tournament._phaseUntil = 0
  Tournament._tickScheduled = false

  for i=1,#players do
    local pid = getPlayerByName(players[i])
    if pid and pid > 0 and isPlayer(pid) then
      setPlayerStorageValue(pid, IS_IN_TOURNAMENT, 1)
      setPlayerStorageValue(pid, PLAYER_IN_TOURNAMENT, 1)
      Tournament._setFightLocks(players[i], false)
    end
  end

  Tournament._beginRound(players)
  sendStartMsg(cid, "Torneio iniciado com " .. #players .. " jogadores.")
  return true
end

function Tournament._beginRound(players)
  Tournament.round = Tournament.round + 1
  shuffle(players)

  local matches = {}
  local matchId = 0

  local arenaIdx = {}
  for i=1,#Tournament.arenas do table.insert(arenaIdx, i) end
  shuffle(arenaIdx)

  for i=1,#players,2 do
    matchId = matchId + 1
    local aName = players[i]
    local bName = players[i+1]
    local aIdx = arenaIdx[matchId] or arenaIdx[((matchId - 1) % #arenaIdx) + 1]

    matches[matchId] = {a = aName, b = bName, done = false, winner = nil, arena = aIdx}
    Tournament.playerMatch[aName] = matchId
    Tournament.playerMatch[bName] = matchId
  end

  Tournament.matches = matches

  for id,m in pairs(Tournament.matches) do
    local ar = Tournament.arenas[m.arena]
    Tournament._teleport(m.a, ar.a)
    Tournament._teleport(m.b, ar.b)

    local ca = getPlayerByName(m.a)
    local cb = getPlayerByName(m.b)
    if ca and ca > 0 and isPlayer(ca) then setPlayerStorageValue(ca, PLAYER_IN_TOURNAMENT, id) end
    if cb and cb > 0 and isPlayer(cb) then setPlayerStorageValue(cb, PLAYER_IN_TOURNAMENT, id) end

    msgPlayerByName(m.a, "Rodada " .. Tournament.round .. " iniciando. Prepare-se.")
    msgPlayerByName(m.b, "Rodada " .. Tournament.round .. " iniciando. Prepare-se.")
  end

  Tournament._phase = "prep"
  Tournament._phaseUntil = now() + Tournament.cfg.prepSeconds
  Tournament._setPvp(false)

  if not Tournament._tickScheduled then
    Tournament._tickScheduled = true
    addEvent(Tournament._tick, 1000)
  end
end

function Tournament._tick()
  if not Tournament.isRunning() then
    Tournament._tickScheduled = false
    return true
  end

  local t = now()

  if Tournament._phase == "prep" and t >= Tournament._phaseUntil then
    Tournament._phase = "fight"
    Tournament._setPvp(true)

    for _,m in pairs(Tournament.matches) do
      if not m.done then
        Tournament._setFightLocks(m.a, true)
        Tournament._setFightLocks(m.b, true)
        msgPlayerByName(m.a, "Luta liberada!")
        msgPlayerByName(m.b, "Luta liberada!")
      end
    end
  end

  if Tournament._phase == "fight" then
    Tournament._checkMatches()

    if Tournament._allMatchesDone() then
      Tournament._phase = "break"
      Tournament._phaseUntil = t + Tournament.cfg.breakSeconds
      Tournament._setPvp(false)

      local winners = Tournament._collectWinners()
      if #winners <= 1 then
        Tournament._finish(winners[1])
        Tournament._tickScheduled = false
        return true
      end

      for i=1,#winners do
        Tournament._setFightLocks(winners[i], false)
        msgPlayerByName(winners[i], "Rodada finalizada. Voce tem " .. Tournament.cfg.breakSeconds .. " segundos para curar.")
      end
    end
  end

  if Tournament._phase == "break" and t >= Tournament._phaseUntil then
    local winners = Tournament._collectWinners()

    local alive = {}
    for i=1,#winners do
      local cid = getPlayerByName(winners[i])
      if cid and cid > 0 and isPlayer(cid) then
        table.insert(alive, winners[i])
      end
    end

    if #alive <= 1 then
      Tournament._finish(alive[1])
      Tournament._tickScheduled = false
      return true
    end

    Tournament._tickScheduled = false
    Tournament._beginRound(alive)
    return true
  end

  addEvent(Tournament._tick, 1000)
  return true
end

function Tournament._allMatchesDone()
  for _,m in pairs(Tournament.matches) do
    if not m.done then
      return false
    end
  end
  return true
end

function Tournament._collectWinners()
  local winners = {}
  for _,m in pairs(Tournament.matches) do
    if m.winner and m.winner ~= "" then
      table.insert(winners, m.winner)
    end
  end
  return winners
end

function Tournament._declareWinner(matchId, winnerName, loserName, reason)
  local m = Tournament.matches[matchId]
  if not m or m.done then return end

  m.done = true
  m.winner = winnerName

  if loserName and loserName ~= "" then
    msgPlayerByName(loserName, "Voce foi eliminado. Motivo: " .. reason)
    Tournament._setFightLocks(loserName, false)
    Tournament._clearPlayerFlags(loserName)
    Tournament._teleport(loserName, Tournament.cfg.outPos)
  end

  msgPlayerByName(winnerName, "Voce venceu sua luta. Aguarde o fim da rodada.")
end

function Tournament._checkMatches()
  for id,m in pairs(Tournament.matches) do
    if not m.done then
      local ca = getPlayerByName(m.a)
      local cb = getPlayerByName(m.b)
      local aOnline = (ca and ca > 0 and isPlayer(ca))
      local bOnline = (cb and cb > 0 and isPlayer(cb))

      if not aOnline and bOnline then
        Tournament._declareWinner(id, m.b, m.a, "adversario deslogou")

      elseif not bOnline and aOnline then
        Tournament._declareWinner(id, m.a, m.b, "adversario deslogou")

      elseif not aOnline and not bOnline then
        Tournament.matches[id].done = true
        Tournament.matches[id].winner = nil

      else
        local aHas = playerHasPokemonByName(m.a)
        local bHas = playerHasPokemonByName(m.b)

        if (not aHas) and bHas then
          Tournament._declareWinner(id, m.b, m.a, "todos os pokemons foram derrotados")
        elseif (not bHas) and aHas then
          Tournament._declareWinner(id, m.a, m.b, "todos os pokemons foram derrotados")
        elseif (not aHas) and (not bHas) then
          Tournament.matches[id].done = true
          Tournament.matches[id].winner = nil
          msgPlayerByName(m.a, "Voce foi eliminado. Motivo: sem pokemon.")
          msgPlayerByName(m.b, "Voce foi eliminado. Motivo: sem pokemon.")
          Tournament._clearPlayerFlags(m.a)
          Tournament._clearPlayerFlags(m.b)
          Tournament._teleport(m.a, Tournament.cfg.outPos)
          Tournament._teleport(m.b, Tournament.cfg.outPos)
        end
      end
    end
  end
end

function Tournament.onLogout(cid)
  if getPlayerStorageValue(cid, IS_IN_TOURNAMENT) ~= 1 then
    return true
  end

  if not Tournament.isRunning() then
    setPlayerStorageValue(cid, IS_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, PLAYER_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, Tournament.cfg.duelStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.relogOutStorage, 1)
    return true
  end

  local name = getCreatureName(cid)
  local matchId = Tournament.playerMatch[name]
  if not matchId then
    setPlayerStorageValue(cid, IS_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, PLAYER_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, Tournament.cfg.duelStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.relogOutStorage, 1)
    return true
  end

  local m = Tournament.matches[matchId]
  if not m or m.done then
    setPlayerStorageValue(cid, IS_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, PLAYER_IN_TOURNAMENT, -1)
    setPlayerStorageValue(cid, Tournament.cfg.duelStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, -1)
    setPlayerStorageValue(cid, Tournament.cfg.relogOutStorage, 1)
    return true
  end

  local other = (m.a == name) and m.b or m.a
  Tournament._declareWinner(matchId, other, name, "deslogou")

  setPlayerStorageValue(cid, IS_IN_TOURNAMENT, -1)
  setPlayerStorageValue(cid, PLAYER_IN_TOURNAMENT, -1)
  setPlayerStorageValue(cid, Tournament.cfg.duelStorage, -1)
  setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, -1)
  setPlayerStorageValue(cid, Tournament.cfg.relogOutStorage, 1)

  return true
end

function Tournament._finish(winnerName)
  Tournament._setPvp(false)
  Tournament._setRunning(false)

  Tournament.registered = {}
  Tournament.order = {}
  Tournament._save()

  Tournament.matches = {}
  Tournament.playerMatch = {}
  Tournament.running = false
  Tournament._phase = "idle"
  Tournament._phaseUntil = 0
  Tournament._tickScheduled = false

  if winnerName and winnerName ~= "" then
    local cid = getPlayerByName(winnerName)
    if cid and cid > 0 and isPlayer(cid) then
      local prizeCount = Tournament.initialCount * 2
      doPlayerAddItem(cid, Tournament.cfg.prizeId, prizeCount)
      doPlayerSendTextMessage(cid, 20, "Parabens! Voce venceu o torneio e recebeu o premio x" .. prizeCount .. ".")
      Tournament._setFightLocks(winnerName, false)
      Tournament._clearPlayerFlags(winnerName)
      Tournament._teleport(winnerName, Tournament.cfg.outPos)
    end
    doBroadcastMessage("O torneio terminou! Vencedor: " .. winnerName .. ".")
  else
    doBroadcastMessage("O torneio terminou sem vencedor.")
  end
end

function Tournament.closeAndPull()
  Tournament._load()

  if Tournament.isRunning() then return true end

  if #Tournament.order < 2 then
    doBroadcastMessage("O torneio nao sera iniciado: nenhum jogador suficiente registrado.")
    return true
  end

  if not isAllowedCount(#Tournament.order) then
    local allowed, refunded = Tournament._refundLastUntilAllowed()
    if allowed < 2 then
      doBroadcastMessage("O torneio nao sera iniciado: nao foi possivel ajustar para 2/4/8/16.")
      return true
    end
    doBroadcastMessage("Inscricoes fechadas! Ajustado para "..allowed.." jogadores. Reembolsados: "..refunded..".")
  else
    doBroadcastMessage("Inscricoes fechadas! Total: "..#Tournament.order.." jogadores.")
  end

  return true
end

function Tournament.startIfReady()
  Tournament._load()
  if Tournament.isRunning() then return true end
  if #Tournament.order < 2 then
    doBroadcastMessage("O torneio nao iniciou: jogadores insuficientes.")
    return true
  end
  return Tournament.start(nil)
end