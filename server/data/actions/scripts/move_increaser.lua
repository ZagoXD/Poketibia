local DEFAULT_MAX = 6
local HARD_CAP    = 10

local function parseActiveMovesAttr(raw)
  local seen, out = {}, {}
  if not raw or raw == "" then return out end
  for n in tostring(raw):gmatch("%d+") do
    local i = tonumber(n)
    if i and i >= 1 and i <= 12 and not seen[i] then
      seen[i] = true
      table.insert(out, i)
    end
  end
  return out
end

local function listToCsv(t)
  local out = {}
  for i, v in ipairs(t) do out[i] = tostring(v) end
  return table.concat(out, ",")
end

local function getMovesTableForName(name)
  if not name then return nil end
  return movestable[name]
end

local function getNextFreeIndexes(moves, already, wantMore)
  local picked, mark = {}, {}
  for _,i in ipairs(already) do mark[i] = true end
  for i = 1, 12 do
    local mt = moves and moves["move"..i] or nil
    if mt and not mark[i] then
      table.insert(picked, i)
      if #picked >= wantMore then break end
    end
  end
  return picked
end

local function isMySummon(cid, uid)
  return isCreature(uid) and isSummon(uid) and getCreatureMaster(uid) == cid
end

local function tryGetTargetBall(cid, item2)
  if isCreature(item2.uid) then
    if not isMySummon(cid, item2.uid) then
      doPlayerSendCancel(cid, "Use no seu proprio Pokemon ou na Pokebola.")
      return nil
    end
    local ball = getPlayerSlotItem(cid, 8)
    if not ball or ball.uid <= 0 then
      doPlayerSendCancel(cid, "Coloque a Pokebola no slot 8.")
      return nil
    end
    return ball
  end

  if isPokeball(item2.itemid) and getItemAttribute(item2.uid, "poke") then
    return item2
  end

  doPlayerSendCancel(cid, "Alvo invalido. Clique no seu Pokemon invocado ou na Pokebola.")
  return nil
end

function onUse(cid, item, fromPos, item2, toPos)
  local ball = tryGetTargetBall(cid, item2)
  if not ball then return true end

  local cur = tonumber(getItemAttribute(ball.uid, "max_active_moves")) or DEFAULT_MAX
  if cur < 1 then cur = DEFAULT_MAX end
  if cur >= HARD_CAP then
    doPlayerSendCancel(cid, "Esse Pokemon ja atingiu o limite de " .. HARD_CAP .. " moves ativos.")
    return true
  end

  local newMax = cur + 1
  if newMax > HARD_CAP then newMax = HARD_CAP end
  doItemSetAttribute(ball.uid, "max_active_moves", newMax)

  local name = getItemAttribute(ball.uid, "poke")
  local moves = getMovesTableForName(name)
  if moves then
    local active = parseActiveMovesAttr(getItemAttribute(ball.uid, "active_moves"))
    if #active < newMax then
      local extra = getNextFreeIndexes(moves, active, newMax - #active)
      for _, idx in ipairs(extra) do table.insert(active, idx) end
      doItemSetAttribute(ball.uid, "active_moves", listToCsv(active))
    end
  end

  doRemoveItem(item.uid, 1)
  doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_BLUE)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    "Capacidade de moves ativos aumentada para " .. newMax .. ".")

  if doUpdateMoves then addEvent(doUpdateMoves, 100, cid) end
  if doUpdateCooldowns then addEvent(doUpdateCooldowns, 200, cid) end

  return true
end
