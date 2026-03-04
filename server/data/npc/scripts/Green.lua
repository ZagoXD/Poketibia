local focus = 0
local max_distance = 8
local talk_start = 0
local conv = 0
local fighting = false
local challenger = 0
local afk_limit_time = 30
local afk_time = 0
local battle_turn = 1
local challenger_turn = 0

local pokemons = {
  {name = "Pidgeot",   optionalLevel = 300, sex = SEX_MALE, nick = "", ball = "normal"},
  {name = "Alakazam",  optionalLevel = 330, sex = SEX_MALE, nick = "", ball = "normal"},
  {name = "Rhydon",    optionalLevel = 330, sex = SEX_MALE, nick = "", ball = "normal"},
  {name = "Arcanine",  optionalLevel = 330, sex = SEX_MALE, nick = "", ball = "normal"},
  {name = "Exeggutor", optionalLevel = 330, sex = SEX_MALE, nick = "", ball = "normal"},
  {name = "Blastoise", optionalLevel = 340, sex = SEX_MALE, nick = "", ball = "normal"},
}

local function doSummonElitePokemon(npc)
  if gymSummonNext(npc, focus, pokemons, battle_turn, 15) then
    fighting = true
    battle_turn = battle_turn + 1
  end
end

local function doWinElite(cid, npc)
  if not isCreature(cid) then return true end

  local idx = eliteGetNpcIndex(npc)
  if idx then
    eliteRunSetDefeated(cid, idx)
  end

  setPlayerStorageValue(cid, ELITE_CHAMPION_DONE, 1)

  local accId = getPlayerAccountId(cid)
  if type(setAccountStorageValue) == "function" then
    setAccountStorageValue(accId, 9351, 1)
  end

  selfSay("...Entao e isso. Voce venceu.")
  eliteRunEnd(cid)

  if OTCSendSkillBar then
    OTCSendSkillBar(cid)
  end

  eliteSendCompletionMessage(cid)
end

function onCreatureSay(cid, type, msg)
  msg = string.lower(msg)
  if focus == cid then talk_start = os.clock() end

  if msgcontains(msg, 'hi') and focus == 0 and getDistanceToCreature(cid) <= 4 then
    focus = cid
    talk_start = os.clock()
    conv = 1
    selfSay("Finalmente... Eu sou Green, o Campeao. Se quiser meu titulo, tera que me derrotar.")
    return true
  end

  if isDuelMsg(msg) and conv == 1 and focus == cid then
    local ok, reason = eliteCanChallenge(cid, getThis())
    if not ok then
      selfSay(reason)
      return true
    end

    if not hasPokemon(cid) then
      selfSay("Voce precisa de pokemons para lutar.")
      return true
    end

    selfSay("Muito bem. Esta e a batalha final. Limite de "..#pokemons.." pokemons. Vamos comecar?")
    conv = 2
    return true
  end

  if isConfirmMsg(msg) and conv == 2 and focus == cid then
    challenger = focus
    setPlayerStorageValue(cid, 990, 1)
    selfSay("Mostre do que voce e capaz!")
    talk_start = os.clock()
    addEvent(doSummonElitePokemon, 850, getThis())
    conv = 3
    return true
  end

  if isNegMsg(msg) and conv == 2 and focus == cid then
    focus = 0
    selfSay("Volte quando estiver pronto.")
    return true
  end

  if msgcontains(msg, 'bye') and focus == cid then
    selfSay("Ate mais.")
    setPlayerStorageValue(focus, 990, -1)
    focus = 0
    return true
  end
end

local afk_warning = false

function onThink()
  if focus == 0 then
    selfTurn(2)
    fighting = false
    challenger = 0
    challenger_turn = 0
    battle_turn = 1
    afk_time = 0
    afk_warning = false

    if #getCreatureSummons(getThis()) >= 1 then
      setPlayerStorageValue(getCreatureSummons(getThis())[1], 1006, 0)
      doCreatureAddHealth(getCreatureSummons(getThis())[1], -getCreatureMaxHealth(getCreatureSummons(getThis())[1]))
    end
    return true
  end

  if not isCreature(focus) then
    gymClearFlags(getThis(), focus)
    focus = 0
    return true
  end

  if fighting then
    talk_start = os.clock()

    if gymRetargetTick(getThis(), focus) then
      afk_time = 0
    end

    local s = (#getCreatureSummons(getThis()) >= 1) and getCreatureSummons(getThis())[1] or nil
    if s and not isCreature(getCreatureTarget(s)) then
      gymStartAggro(s, focus)
      afk_time = 0
    end

    if afk_time > afk_limit_time then
      gymClearFlags(getThis(), focus)
      setPlayerStorageValue(focus, 990, -1)
      focus = 0
      selfSay("Voce demorou demais. Volte quando estiver pronto.")
      return true
    end

    if not afk_warning and afk_time > afk_limit_time / 2 then
      selfSay("Onde esta seu pokemon? Vamos lutar!")
      afk_warning = true
    end

    if #getCreatureSummons(getThis()) == 0 then
      if battle_turn > #pokemons then
        gymClearFlags(getThis(), focus)
        addEvent(doWinElite, 1000, focus, getThis())
        setPlayerStorageValue(focus, 990, -1)
        focus = 0
        return true
      end
      addEvent(doSummonElitePokemon, 1000, getThis())
    end

    if not hasPokemon(challenger) or challenger_turn >= 7 or challenger_turn > #pokemons then
      gymClearFlags(getThis(), focus)
      selfSay("Voce perdeu. Tente novamente mais tarde.")
      eliteRunFail(focus, getThis())
      setPlayerStorageValue(focus, 990, -1)
      focus = 0
      return true
    end
  end

  local npcpos = getThingPos(getThis())
  local focpos = getThingPos(focus)

  if npcpos.z ~= focpos.z then
    gymClearFlags(getThis(), focus)
    setPlayerStorageValue(focus, 990, -1)
    focus = 0
    selfSay("Ate mais.")
    return true
  end

  if (os.clock() - talk_start) > 30 then
    gymClearFlags(getThis(), focus)
    selfSay("Ate mais.")
    setPlayerStorageValue(focus, 990, -1)
    focus = 0
  end

  if getDistanceToCreature(focus) > max_distance then
    gymClearFlags(getThis(), focus)
    setPlayerStorageValue(focus, 990, -1)
    focus = 0
    return true
  end

  local dir = doRedirectDirection(getDirectionTo(npcpos, focpos))
  selfTurn(dir)
  return true
end
