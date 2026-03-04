DAILY_KILL = DAILY_KILL or {}

DAILY_KILL.REWARD_ITEM = 2160
DAILY_KILL.REWARD = {
  easy   = 10,
  medium = 20,
  hard   = 50,
}

DAILY_KILL.KILLS = {
  easy   = 20,
  medium = 30,
  hard   = 90,
}

DAILY_KILL.COOLDOWN = 24 * 60 * 60

DAILY_KILL.STOR = {
  ACTIVE     = 90310,
  DIFF       = 90311,
  TARGET     = 90312,
  GOAL       = 90313,
  COUNT      = 90314,
  ASSIGNEDAT = 90315,
  LAST_DONE  = 90316,

  PENDING_DIFF   = 90317,
  PENDING_TARGET = 90318,
  PENDING_GOAL   = 90319,
  PENDING_AT     = 90320,
}

local function _S(v) return v == nil and "" or tostring(v) end
local function _now() return os.time() end
local function p(n, s, pl) return n == 1 and s or pl end

local function normName(name)
  if not name then return "" end
  name = tostring(name)
  name = name:gsub("^%s*Shiny[%s%-_]+", "")
  return string.upper(string.sub(name,1,1)) .. string.lower(string.sub(name,2))
end

local function fmtTimePT(sec)
  if sec <= 0 then return "alguns instantes" end
  local hours = math.floor(sec / 3600)
  local rem   = sec % 3600
  local mins  = math.ceil(rem / 60)
  if mins == 60 then hours = hours + 1; mins = 0 end
  if hours > 0 and mins > 0 then
    return string.format("%d %s e %d %s", hours, p(hours,"hora","horas"), mins, p(mins,"minuto","minutos"))
  elseif hours > 0 then
    return string.format("%d %s", hours, p(hours,"hora","horas"))
  else
    return string.format("%d %s", mins, p(mins,"minuto","minutos"))
  end
end

local function hasCooldown(cid)
  local last = getPlayerStorageValue(cid, DAILY_KILL.STOR.LAST_DONE)
  if type(last) ~= "number" then last = tonumber(last) or -1 end
  if last <= 0 then return false, 0 end
  local rem = (last + DAILY_KILL.COOLDOWN) - _now()
  return rem > 0, math.max(rem, 0)
end

local function diffKeyOk(k)
  return k == "easy" or k == "medium" or k == "hard"
end

local function pickTarget(diff)
  if type(DAILY_CATCH) == "table" and DAILY_CATCH.POKES and DAILY_CATCH.POKES[diff] then
    local list = DAILY_CATCH.POKES[diff]
    if #list > 0 then return list[math.random(1,#list)] end
  end
  return nil
end

function dailyKillStatus(cid)
  local active = getPlayerStorageValue(cid, DAILY_KILL.STOR.ACTIVE) == 1
  local diff   = _S(getPlayerStorageValue(cid, DAILY_KILL.STOR.DIFF))
  local target = _S(getPlayerStorageValue(cid, DAILY_KILL.STOR.TARGET))
  local goal   = tonumber(getPlayerStorageValue(cid, DAILY_KILL.STOR.GOAL)) or 0
  local count  = tonumber(getPlayerStorageValue(cid, DAILY_KILL.STOR.COUNT)) or 0
  local at     = tonumber(getPlayerStorageValue(cid, DAILY_KILL.STOR.ASSIGNEDAT)) or 0
  local onCd, rem = hasCooldown(cid)
  return {
    active=active, diff=diff, target=target, goal=goal, count=count,
    assigned=at, cooldown=onCd, remaining=rem
  }
end

local function dailyKillPendingStatus(cid)
  return {
    pdiff   = _S(getPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_DIFF)),
    ptarget = _S(getPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_TARGET)),
    pgoal   = tonumber(getPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_GOAL)) or 0,
    pat     = tonumber(getPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_AT)) or 0
  }
end

local function dailyKillPendingClear(cid)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_DIFF, "")
  setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_TARGET, "")
  setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_GOAL, 0)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_AT, 0)
end

function dailyKillCanStart(cid)
  local st = dailyKillStatus(cid)
  if st.active then
    return false, "Voce ja tem um Daily Kill ativo ("..st.diff.." -> "..st.target..")."
  end
  if st.cooldown then
    local nice = fmtTimePT(st.remaining)
    return false, "Voce ja concluiu um Daily Kill recentemente. Voce podera tentar de novo em "..nice.."."
  end
  return true
end

function dailyKillPropose(cid, diff)
  if not diffKeyOk(diff) then
    return false, "Dificuldade invalida."
  end
  local ok, msg = dailyKillCanStart(cid)
  if not ok then return false, msg end

  local pend = dailyKillPendingStatus(cid)
  local target, pdiff, pgoal = pend.ptarget, pend.pdiff, pend.pgoal

  if target == "" or pdiff ~= diff then
    local t = pickTarget(diff)
    if not t then return false, "Nao ha alvos configurados para "..diff.."." end
    target = t
    pgoal  = DAILY_KILL.KILLS[diff] or 0
    setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_DIFF, diff)
    setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_TARGET, target)
    setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_GOAL, pgoal)
    setPlayerStorageValue(cid, DAILY_KILL.STOR.PENDING_AT, _now())
  end

  return true, ("Na missao nivel %s, o pokemon a ser derrotado sera %s (meta %d kills). Deseja continuar? {sim}/{nao}")
              :format(diff, target, pgoal)
end

function dailyKillConfirm(cid, answerYes)
  local st = dailyKillStatus(cid)
  if st.active then
    dailyKillPendingClear(cid)
    return false, "Voce ja tem um Daily Kill ativo."
  end
  local ok, msg = dailyKillCanStart(cid)
  if not ok then
    dailyKillPendingClear(cid)
    return false, msg
  end

  local pend = dailyKillPendingStatus(cid)
  if pend.pdiff == "" or pend.ptarget == "" or pend.pgoal <= 0 then
    return false, "Nao ha uma missao pendente para confirmar."
  end

  if not answerYes then
    dailyKillPendingClear(cid)
    return true, "Missao cancelada."
  end

  setPlayerStorageValue(cid, DAILY_KILL.STOR.ACTIVE, 1)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.DIFF, pend.pdiff)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.TARGET, pend.ptarget)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.GOAL, pend.pgoal)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.COUNT, 0)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.ASSIGNEDAT, _now())
  dailyKillPendingClear(cid)

  return true, "Daily Kill iniciado! Dificuldade: "..pend.pdiff.."."
end

function dailyKillStart(cid, diff)
  local ok, msg = dailyKillPropose(cid, diff)
  if not ok then return false, msg end
  return dailyKillConfirm(cid, true)
end

function dailyKillOnKill(cid, monsterName)
  local st = dailyKillStatus(cid)
  if not st.active then return false end
  local target = normName(st.target)
  local killed = normName(monsterName)
  if target == "" or killed == "" then return false end

  if killed ~= target then return false end

  local goal  = st.goal
  local count = st.count + 1
  if count > goal then count = goal end

  setPlayerStorageValue(cid, DAILY_KILL.STOR.COUNT, count)

  local remaining = goal - count
  if remaining > 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      string.format("[Daily Kill] Faltam %d %s para completar a missao.", remaining, target))
  else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "[Daily Kill] Objetivo concluido! Volte ao NPC e diga {reportar}.")
  end
  return true
end

function dailyKillGiveReward(cid)
  local st = dailyKillStatus(cid)
  if not st.active then
    return false, "Voce nao tem um Daily Kill ativo."
  end
  if st.count < st.goal then
    return false, "Voce ainda nao completou a meta ("..st.count.."/"..st.goal..")."
  end

  local amount = DAILY_KILL.REWARD[st.diff] or 0
  if amount <= 0 then
    return false, "Configuracao de recompensa invalida."
  end

  doPlayerAddItem(cid, DAILY_KILL.REWARD_ITEM, amount)

  setPlayerStorageValue(cid, DAILY_KILL.STOR.ACTIVE, 0)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.DIFF, "")
  setPlayerStorageValue(cid, DAILY_KILL.STOR.TARGET, "")
  setPlayerStorageValue(cid, DAILY_KILL.STOR.GOAL, 0)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.COUNT, 0)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.ASSIGNEDAT, 0)
  setPlayerStorageValue(cid, DAILY_KILL.STOR.LAST_DONE, _now())

  return true, "Excelente trabalho! Pegue aqui seu recompensa. Volte em 24 horas."
end
