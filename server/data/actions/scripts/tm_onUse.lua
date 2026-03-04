local TM  = _G.TM or dofile('data/lib/tm/tm_config.lua')
local TMC = dofile('data/lib/tm/tm_core.lua')

local DEFAULT_MAX, HARD_CAP = 6, 10

local function getMaxActiveForBall(ball)
  local m = ball and ball.uid > 0 and tonumber(getItemAttribute(ball.uid, "max_active_moves")) or nil
  if not m or m < 1 then m = DEFAULT_MAX end
  if m > HARD_CAP then m = HARD_CAP end
  return m
end

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

local function addToActiveIfSpace(cid, ball, idx)
  local maxA = getMaxActiveForBall(ball)
  local raw  = getItemAttribute(ball.uid, "active_moves")
  local lst  = parseActiveMovesAttr(raw)

  for _, v in ipairs(lst) do
    if v == idx then return end
  end

  if #lst < maxA then
    table.insert(lst, idx)
    doItemSetAttribute(ball.uid, "active_moves", listToCsv(lst))
    for i = 1, 12 do
      doItemEraseAttribute(ball.uid, "move" .. i)
      doItemEraseAttribute(ball.uid, "cm_move" .. i)
    end
    if doUpdateMoves then doUpdateMoves(cid) end
    if doUpdateCooldowns then doUpdateCooldowns(cid) end
  end
end

local function resolveBallFromTarget(cid, target)
  if not target then return nil end

  if isPokeball and isPokeball(target.itemid) then
    return target
  end

  if isCreature(target.uid) then
    local master = getCreatureMaster and getCreatureMaster(target.uid) or cid
    if master == cid then
      local b = getPlayerSlotItem(cid, 8)
      if b and b.uid > 0 then return b end
    end
  end
  return nil
end

local function teachMove(cid, ball, moveName)
  local pokeName = getItemAttribute(ball.uid, "poke")
  if not pokeName or pokeName == "" then
    doPlayerSendCancel(cid, "Esta pokebola nao tem um Pokemon valido.")
    return false
  end

  local knows, idxKnown = TMC.pokemonKnowsMove(pokeName, ball, moveName)
  if knows and TM.rules.denyDuplicates then
    doPlayerSendCancel(cid, "Este Pokemon ja conhece " .. moveName .. " (slot #" .. idxKnown .. ").")
    return false
  end

  if not TMC.isMoveAllowedForPokemon(pokeName, moveName) then
    doPlayerSendCancel(cid, "Este Pokemon nao pode aprender este TM.")
    return false
  end

  local freeIdx = TMC.findFirstFreeSlot(pokeName, ball)
  if not freeIdx then
    doPlayerSendCancel(cid, "Nao ha slots livres (1..12) para aprender um novo golpe.")
    return false
  end

  local ok, err = TMC.addLearnedMove(ball, freeIdx, moveName)
  if not ok then
    doPlayerSendCancel(cid, "Falha ao aprender o golpe: " .. tostring(err))
    return false
  end

  addToActiveIfSpace(cid, ball, freeIdx)

  doSendMagicEffect(getThingPos(cid), 12)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    getPokeballName(ball.uid) .. " aprendeu " .. moveName .. " (slot #" .. string.format("%02d", freeIdx) .. ").")
  return true
end

local function convertBlankToLastMove(cid, item, ball)
  local last = getItemAttribute(ball.uid, "tm_last_move_used")
  if not last or last == "" then
    doPlayerSendCancel(cid, "Nao achei o ultimo golpe usado por este Pokemon.")
    return true
  end
  local tmId = TM.byMove and TM.byMove[last]
  if not tmId then
    doPlayerSendCancel(cid, "Nao existe TM configurado para o golpe: " .. last)
    return true
  end
  doTransformItem(item.uid, tmId)
  doSendMagicEffect(getThingPos(cid), 12)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Blank TM convertido para TM de " .. last .. ".")
  return true
end

function onUse(cid, item, fromPos, target, toPos, isHotkey)
  local ball = resolveBallFromTarget(cid, target)
  if not ball then
    doPlayerSendCancel(cid, "Use o TM na pokebola do Pokemon (ou clique no proprio Pokemon invocado).")
    return true
  end

  if TM.BLANK_ID and item.itemid == TM.BLANK_ID then
    return convertBlankToLastMove(cid, item, ball)
  end

  local moveName = TM.byItem and TM.byItem[item.itemid]
  if not moveName then
    doPlayerSendCancel(cid, "Este item nao e um TM valido.")
    return true
  end

  local ok = teachMove(cid, ball, moveName)
  if ok and TM.rules.consumeOnLearn then
    doRemoveItem(item.uid, 1)
  end
  return true
end
