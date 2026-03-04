local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid)         npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg) end
function onThink()                        npcHandler:onThink() end

local function sayTo(cid, text)
  local t = TALKTYPE_PRIVATE_NP or TALKTYPE_PRIVATE_NPC or TALKTYPE_PRIVATE or TALKTYPE_SAY
  doCreatureSay(getNpcId(), text, t, false, cid)
end

npcHandler:setMessage(MESSAGE_GREET,
  "Ola, treinador! Quer um {daily kill}? Escolha {facil}, {medio} ou {dificil}. Diga {reportar} quando terminar.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Ate a proxima!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Boa sorte por ai.")

local PT_TO_DIFF = {
  ["facil"] = "easy",   ["fácil"] = "easy",   ["easy"]   = "easy",
  ["medio"] = "medium", ["médio"] = "medium", ["medium"] = "medium",
  ["dificil"] = "hard", ["difícil"] = "hard", ["hard"]   = "hard",
}

local function fmtTimePT(sec)
  local function p(n, s, pl) return n == 1 and s or pl end
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

local function describeStatus(cid)
  local st = dailyKillStatus(cid)
  if st.active then
    local alvo = (st.target ~= "" and st.target or "—")
    sayTo(cid, "Missao atual: ["..st.diff.."] alvo {"..alvo.."} ("..st.count.."/"..st.goal..").")
  else
    if st.cooldown then
      local nice = fmtTimePT(st.remaining)
      sayTo(cid, "Voce ja fez um Daily Kill. Voce podera tentar de novo em "..nice..".")
    else
      sayTo(cid, "Diga {facil}, {medio} ou {dificil} para iniciar.")
    end
  end
end

local function creatureSayCallback(cid, _type, msg)
  if not npcHandler:isFocused(cid) then return false end
  local say = msg:lower()

  if say == "daily" or say == "daily kill" or say == "missao" or say == "missao kill" or say == "task" then
    describeStatus(cid)
    return true
  end

  if PT_TO_DIFF[say] then
    local diff = PT_TO_DIFF[say]
    local ok, res = dailyKillPropose(cid, diff)
    sayTo(cid, ok and res or ("Nao foi possivel iniciar: "..res))
    return true
  end

  if say == "sim" or say == "yes" or say == "confirmar" then
    local ok, res = dailyKillConfirm(cid, true)
    sayTo(cid, res)
    return true
  end
  if say == "nao" or say == "não" or say == "no" or say == "cancelar" then
    local ok, res = dailyKillConfirm(cid, false)
    sayTo(cid, res)
    return true
  end

  if say == "report" or say == "reportar" or say == "recompensa" or say == "reward" then
    local ok, res = dailyKillGiveReward(cid)
    sayTo(cid, res)
    return true
  end

  if say == "status" then
    describeStatus(cid)
    return true
  end

  return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
