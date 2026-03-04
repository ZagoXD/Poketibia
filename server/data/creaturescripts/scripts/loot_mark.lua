local AMULET_ORB_IDENT = 35
local CHANCE_MUL = 3.0
local COUNT_MUL  = 1.0

local DEBUG = false
local DEBUG_EFFECT = CONST_ME_MAGIC_GREEN

local function extractKiller(deathList)
  if type(deathList) ~= "table" then return nil end
  for i = 1, #deathList do
    local e = deathList[i]
    local cid = (type(e) == "table") and (e[1] or e.killer or e.cid) or e
    if cid and isCreature(cid) then
      if isPlayer(cid) then return cid end
      local m = getCreatureMaster(cid)
      if m and isPlayer(m) then return m end
    end
  end
  return nil
end

local function killerHasAmuletCoin(pid)
  local ball = getPlayerSlotItem(pid, 8)
  if not ball or ball.uid <= 0 then return false end
  local orb = tonumber(getItemAttribute(ball.uid, "orb") or 0) or 0
  return orb == AMULET_ORB_IDENT
end

function onDeath(creature, corpse, deathList)
  -- print("[LootMark] onDeath disparado para:", getCreatureName(creature) or tostring(creature))

  local pos = getCreaturePosition(creature) or getThingPos(creature)
  if pos then doSendMagicEffect(pos, DEBUG_EFFECT) end

  if not corpse then
    -- print("[LootMark] sem corpse (nil)")
    return true
  end

  -- Só pra log mesmo; NÃO vamos depender disso
  -- print("[LootMark] corpse uid:", corpse.uid or corpse, "isContainer:", tostring(isContainer(corpse)))

  local pid = extractKiller(deathList)
  -- print("[LootMark] killer resolvido:", pid, pid and getCreatureName(pid))

  if not pid then
    -- print("[LootMark] não achou killer player na deathList.")
    return true
  end

  local hasCoin = killerHasAmuletCoin(pid)
  -- print("[LootMark] killer tem Amulet Coin?", hasCoin)

  if hasCoin then
    doItemSetAttribute(corpse.uid, "lootChanceMul", CHANCE_MUL)
    doItemSetAttribute(corpse.uid, "lootCountMul",  COUNT_MUL)
    doItemSetAttribute(corpse.uid, "lootMark", "AmuletCoin")

    if DEBUG then
      local cMul = getItemAttribute(corpse.uid, "lootChanceMul")
      local qMul = getItemAttribute(corpse.uid, "lootCountMul")
      -- print(string.format("[LootMark] atributos gravados no corpse uid=%s chanceMul=%s countMul=%s",
      --   tostring(corpse.uid), tostring(cMul), tostring(qMul)))

      doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format("[Amulet Coin] Loot x%.1f (chance) e x%.1f (quantidade) aplicados.", CHANCE_MUL, COUNT_MUL))
      -- print(string.format("[LootMark] %s marcou o corpo de %s (x%.1f chance, x%.1f qtd).",
      --   getCreatureName(pid), getCreatureName(creature), CHANCE_MUL, COUNT_MUL))
    end
  end

  return true
end
