DAILY_CATCH = DAILY_CATCH or {}

DAILY_CATCH.REWARD_ITEM = 2160
DAILY_CATCH.REWARD = {
  easy   = 10,
  medium = 20,
  hard   = 50,
}

DAILY_CATCH.POKES = {
  easy = {
    "Caterpie","Metapod","Weedle","Kakuna",
    "Pidgey","Rattata","Spearow","Zubat",
    "Oddish","Paras","Venonat","Diglett",
    "Meowth","Psyduck","Poliwag","Tentacool",
    "Geodude","Slowpoke","Magnemite","Doduo",
    "Seel","Shellder","Krabby","Voltorb",
    "Exeggcute","Horsea","Goldeen","Staryu",
    "Ekans","Sandshrew",
    "Vulpix","Bellsprout","Machop","Drowzee",
    "Koffing","Grimer","Gastly"
  },

  medium = {
    "Butterfree","Beedrill",
    "Pidgeotto","Raticate","Fearow","Golbat",
    "Pikachu","Clefairy","Jigglypuff",
    "Gloom","Parasect","Venomoth","Dugtrio",
    "Persian","Poliwhirl","Graveler","Ponyta","Rapidash",
    "Magneton","Dodrio","Dewgong","Cloyster",
    "Kingler","Electrode","Seadra","Seaking","Starmie",
    "Weepinbell","Machoke","Kadabra","Haunter",
    "Marowak","Weezing","Muk","Onix","Hypno",
    "Lickitung","Tangela",
    "Seel","Shellder"
  },

  hard = {
    "Chansey","Lapras","Porygon","Ditto","Kangaskhan","Tauros",
    "Scyther","Pinsir","Snorlax","Eevee",
    "Dratini","Dragonair","Aerodactyl",
    "Omanyte","Kabuto","Omastar","Kabutops",
    "Rhyhorn","Rhydon",
    "Jynx","Magmar","Electabuzz",
    "Hitmonlee","Hitmonchan"
  }
}

DAILY_CATCH.COOLDOWN = 24 * 60 * 60

DAILY_CATCH.STOR = {
  ACTIVE     = 90210,
  DIFF       = 90211,
  TARGET     = 90212,
  ASSIGNEDAT = 90213,
  DONE       = 90214,
  LAST_DONE  = 90215,

  PENDING_DIFF   = 90216,
  PENDING_TARGET = 90217,
  PENDING_AT     = 90218,
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
  local last = getPlayerStorageValue(cid, DAILY_CATCH.STOR.LAST_DONE)
  if type(last) ~= "number" then last = tonumber(last) or -1 end
  if last <= 0 then return false, 0 end
  local rem = (last + DAILY_CATCH.COOLDOWN) - _now()
  return rem > 0, math.max(rem, 0)
end

local function diffKeyOk(k)
  return k == "easy" or k == "medium" or k == "hard"
end

local function pickTarget(diff)
  local list = DAILY_CATCH.POKES[diff] or {}
  if #list == 0 then return nil end
  return list[math.random(1, #list)]
end

function dailyCatchStatus(cid)
  local active = getPlayerStorageValue(cid, DAILY_CATCH.STOR.ACTIVE) == 1
  local diff   = _S(getPlayerStorageValue(cid, DAILY_CATCH.STOR.DIFF))
  local target = _S(getPlayerStorageValue(cid, DAILY_CATCH.STOR.TARGET))
  local done   = getPlayerStorageValue(cid, DAILY_CATCH.STOR.DONE) == 1
  local at     = tonumber(getPlayerStorageValue(cid, DAILY_CATCH.STOR.ASSIGNEDAT)) or 0
  local onCd, rem = hasCooldown(cid)
  return {
    active=active, diff=diff, target=target, done=done,
    assigned=at, cooldown=onCd, remaining=rem
  }
end

local function dailyCatchPendingStatus(cid)
  return {
    pdiff   = _S(getPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_DIFF)),
    ptarget = _S(getPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_TARGET)),
    pat     = tonumber(getPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_AT)) or 0
  }
end

local function dailyCatchPendingClear(cid)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_DIFF, "")
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_TARGET, "")
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_AT, 0)
end

function dailyCatchCanStart(cid)
  local st = dailyCatchStatus(cid)
  if st.active then
    return false, "Voce ja tem um Daily Catch ativo ("..st.diff.." -> "..st.target..")."
  end
  if st.cooldown then
    local nice = fmtTimePT(st.remaining)
    return false, "Voce ja concluiu um Daily Catch recentemente. Voce podera tentar de novo em "..nice.."."
  end
  return true
end

function dailyCatchPropose(cid, diff)
  if not diffKeyOk(diff) then
    return false, "Dificuldade invalida."
  end
  local ok, msg = dailyCatchCanStart(cid)
  if not ok then return false, msg end

  local pend = dailyCatchPendingStatus(cid)

  local target = pend.ptarget
  local pdiff  = pend.pdiff

  if target == "" or pdiff ~= diff then
    local t = pickTarget(diff)
    if not t then
      return false, "Nao ha alvos configurados para "..diff.."."
    end
    target = t
    setPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_DIFF, diff)
    setPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_TARGET, target)
    setPlayerStorageValue(cid, DAILY_CATCH.STOR.PENDING_AT, _now())
  end

  return true, ("Na missao nivel %s, o pokemon a ser capturado sera %s. Deseja continuar? {sim}/{nao}")
              :format(diff, target)
end

function dailyCatchConfirm(cid, answerYes)
  local st = dailyCatchStatus(cid)
  if st.active then
    dailyCatchPendingClear(cid)
    return false, "Voce ja tem um Daily Catch ativo."
  end
  local ok, msg = dailyCatchCanStart(cid)
  if not ok then
    dailyCatchPendingClear(cid)
    return false, msg
  end

  local pend = dailyCatchPendingStatus(cid)
  if pend.pdiff == "" or pend.ptarget == "" then
    return false, "Nao ha uma missao pendente para confirmar."
  end

  if not answerYes then
    dailyCatchPendingClear(cid)
    return true, "Missao cancelada."
  end

  setPlayerStorageValue(cid, DAILY_CATCH.STOR.ACTIVE, 1)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.DIFF, pend.pdiff)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.TARGET, pend.ptarget)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.DONE, 0)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.ASSIGNEDAT, _now())
  dailyCatchPendingClear(cid)

  return true, "Daily Catch iniciado! Dificuldade: "..st.diff.."."
end

function dailyCatchStart(cid, diff)
  local ok, msg = dailyCatchPropose(cid, diff)
  if not ok then return false, msg end
  return dailyCatchConfirm(cid, true)
end

function dailyCatchOnCapture(cid, pokeName)
  local st = dailyCatchStatus(cid)
  if not st.active or st.done then return false end
  local target = normName(st.target)
  local caught = normName(pokeName)
  if target == "" or caught == "" then return false end
  if st.assigned > 0 and _now() < st.assigned then return false end

  if target == caught then
    setPlayerStorageValue(cid, DAILY_CATCH.STOR.DONE, 1)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "[Daily Catch] Alvo '"..target.."' capturado! Volte ao NPC e diga {reportar}.")
    return true
  end
  return false
end

function dailyCatchGiveReward(cid)
  local st = dailyCatchStatus(cid)
  if not st.active then
    return false, "Voce nao tem um Daily Catch ativo."
  end
  if not st.done then
    local tgt = normName(st.target); if tgt == "" then tgt = "desconhecido" end
    return false, "Voce ainda nao capturou o alvo: " .. tgt .. "."
  end

  local diff   = st.diff
  local amount = DAILY_CATCH.REWARD[diff] or 0
  if amount <= 0 then
    return false, "Configuracao de recompensa invalida para '"..diff.."'."
  end

  doPlayerAddItem(cid, DAILY_CATCH.REWARD_ITEM, amount)

  setPlayerStorageValue(cid, DAILY_CATCH.STOR.ACTIVE, 0)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.DIFF, "")
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.TARGET, "")
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.DONE, 0)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.ASSIGNEDAT, 0)
  setPlayerStorageValue(cid, DAILY_CATCH.STOR.LAST_DONE, _now())

  return true, "Excelente trabalho! Pegue aqui seu recompensa. Volte em 24 horas."
end
