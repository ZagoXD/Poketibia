local ELITE_RUN_BASE       = 9300
local ELITE_CHAMPION_DONE  = 9350
local ELITE_ACCOUNT_STORAGE= 9351
local ELITE_RUN_ACTIVE     = 9352

local RESET_POS = {x = 558, y = 1066, z = 6}

local MIN_GROUP = 3

local function resetElitePlayerStorages(cid)
  for i = 1, 5 do
    setPlayerStorageValue(cid, ELITE_RUN_BASE + i, -1)
  end

  setPlayerStorageValue(cid, ELITE_CHAMPION_DONE, -1)
  setPlayerStorageValue(cid, ELITE_RUN_ACTIVE, -1)
end

local function resetEliteAccountStorage(cid)
  if type(setAccountStorageValue) ~= "function" or type(getPlayerAccountId) ~= "function" then
    return false, "Account storage nao suportado neste servidor."
  end

  local accId = getPlayerAccountId(cid)
  setAccountStorageValue(accId, ELITE_ACCOUNT_STORAGE, -1)
  return true
end

function onSay(cid, words, param)
  if not isPlayer(cid) then return true end

  if getPlayerGroupId(cid) < MIN_GROUP then
    doPlayerSendCancel(cid, "Comando apenas para GM/Admin.")
    return true
  end

  param = (param or ""):lower()

  -- /elitereset
  -- /elitereset acc
  -- /elitereset tp
  -- /elitereset acc,tp
  local doAcc = (param:find("acc") ~= nil)
  local doTp  = (param:find("tp") ~= nil)

  resetElitePlayerStorages(cid)

  local msg = "Elite resetada (player storages)."

  if doAcc then
    local ok, err = resetEliteAccountStorage(cid)
    if ok then
      msg = msg .. " Account storage resetado."
    else
      msg = msg .. " (Falha ao resetar account storage: " .. (err or "erro") .. ")"
    end
  end

  if doTp then
    doTeleportThing(cid, RESET_POS)
    doSendMagicEffect(RESET_POS, CONST_ME_TELEPORT)
    msg = msg .. " Teleportado para a posicao de reset."
  end

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
  return true
end
