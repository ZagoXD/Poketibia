local TM = _G.TM or dofile('data/lib/tm/tm_config.lua')

local M = {}
M.UI_SLOTS = 12

local function normalizeSpecies(name)
  if not name or name == "" then return name end
  local base = name
  if TM.aliasToBase and TM.aliasToBase[name] then
    base = TM.aliasToBase[name]
  else
    base = base:gsub("^Shiny%s+", ""):gsub("^Mega%s+", ""):gsub("^Shiny%s+Mega%s+", "")
    base = base:gsub("^Alolan%s+", ""):gsub("^Galarian%s+", "")
  end
  return base
end

local function shallowCopyMoves(base)
  local r = {}
  if base then
    for i = 1, M.UI_SLOTS do
      local k = "move" .. i
      if base[k] then r[k] = base[k] end
    end
  end
  return r
end

function M.isMoveAllowedForPokemon(pokeName, moveName)
  if not TM.rules.usePerPokemon then
    return M.isTypeAllowed(pokeName, moveName)
  end

  local base = normalizeSpecies(pokeName)
  if TM.learnsetByMove and TM.learnsetByMove[moveName] then
    for _, who in ipairs(TM.learnsetByMove[moveName]) do
      if normalizeSpecies(who) == base then
        return true
      end
    end
    if TM.rules.allowTypeFallback then
      return M.isTypeAllowed(pokeName, moveName)
    end
    return false
  end

  if TM.rules.allowTypeFallback then
    return M.isTypeAllowed(pokeName, moveName)
  end
  return false
end


function M.parseTmSlots(raw)
  local map = {}
  if not raw or raw == "" then return map end
  for token in tostring(raw):gmatch("[^|]+") do
    local idxStr, name = token:match("^(%d+)=([^|]+)$")
    local idx = tonumber(idxStr)
    if idx and idx >= 1 and idx <= M.UI_SLOTS and name and name ~= "" then
      map[idx] = name
    end
  end
  return map
end

function M.encodeTmSlots(map)
  local list = {}
  for i = 1, M.UI_SLOTS do
    local name = map[i]
    if name then table.insert(list, tostring(i) .. "=" .. name) end
  end
  return table.concat(list, "|")
end

function M.getPokemonTypes(pokeName)
  local a, b
  local P = pokes and pokes[pokeName]
  if P and P.type then
    if type(P.type) == "string" then
      local t1, t2 = P.type:match("^([^/]+)/?(.*)$")
      a = t1 and t1:lower() or nil
      b = (t2 ~= "" and t2:lower()) or nil
    elseif type(P.type) == "table" then
      a = P.type[1] and tostring(P.type[1]):lower() or nil
      b = P.type[2] and tostring(P.type[2]):lower() or nil
    end
  end
  return a, b
end

function M.getMoveType(moveName)
  if TM.moveType and TM.moveType[moveName] then
    return tostring(TM.moveType[moveName]):lower()
  end
  if movesinfo and movesinfo[moveName] and movesinfo[moveName].t then
    return tostring(movesinfo[moveName].t):lower()
  end
  return nil
end

function M.isTypeAllowed(pokeName, moveName)
  if not TM.rules.requireTypeMatch then
    return true
  end

  local mt = M.getMoveType(moveName)
  if not mt or mt == "" then
    return TM.rules.allowStatusAnyType or true
  end

  local t1, t2 = M.getPokemonTypes(pokeName)
  if not t1 and not t2 then
    return true
  end

  return (t1 == mt) or (t2 == mt)
end

function M.buildEffectiveMovesFor(name, ball)
  local base = movestable[name]
  local res  = shallowCopyMoves(base)

  local raw  = ball and ball.uid > 0 and getItemAttribute(ball.uid, "tm_slots") or nil
  local map  = M.parseTmSlots(raw)

  for idx, moveName in pairs(map) do
    local per  = (TM.rules.perMove and TM.rules.perMove[moveName]) or nil
    local meta = (movesinfo and movesinfo[moveName]) or nil

    local cd   = (per and per.cd) or (TM.rules.defaultCd or 20)
    local lvl  = (per and per.minLevel) or TM.rules.minLevelDefault

  local target
  if per and per.target ~= nil then
    target = per.target
  elseif meta and meta.target ~= nil then
    target = meta.target
  else
    target = 1
  end

    local dist = (per and per.dist) or (meta and meta.dist) or 1

    res["move" .. idx] = {
      name  = moveName,
      cd    = cd,
      level = lvl,
      target = target,
      dist   = dist,
      -- area  = area,
      -- t     = type_,
    }
  end

  return res
end


function M.pokemonKnowsMove(name, ball, moveName)
  local eff = M.buildEffectiveMovesFor(name, ball)
  for i = 1, M.UI_SLOTS do
    local m = eff["move" .. i]
    if m and m.name == moveName then return true, i end
  end
  return false, nil
end

function M.findFirstFreeSlot(name, ball)
  local used = {}
  local base = movestable[name]
  if base then
    for i = 1, M.UI_SLOTS do
      if base["move" .. i] then used[i] = true end
    end
  end
  local map = M.parseTmSlots(ball and getItemAttribute(ball.uid, "tm_slots") or nil)
  for i, _ in pairs(map) do used[i] = true end
  for i = 1, M.UI_SLOTS do
    if not used[i] then return i end
  end
  return nil
end

function M.addLearnedMove(ball, idx, moveName)
  if not ball or ball.uid <= 0 then return false, "invalid ball" end
  local map = M.parseTmSlots(getItemAttribute(ball.uid, "tm_slots"))
  map[idx] = moveName
  doItemSetAttribute(ball.uid, "tm_slots", M.encodeTmSlots(map))
  return true
end

return M
