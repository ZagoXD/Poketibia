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
  {name = "Gyarados",  optionalLevel = 110, sex = SEX_MALE,   nick = "", ball = "normal"},
  {name = "Tentacruel",optionalLevel =  90, sex = SEX_MALE,   nick = "", ball = "normal"},
  {name = "Vaporeon",  optionalLevel =  85, sex = SEX_FEMALE, nick = "", ball = "normal"},
  {name = "Golduck",   optionalLevel =  70, sex = SEX_MALE,   nick = "", ball = "normal"},
  {name = "Blastoise", optionalLevel = 110, sex = SEX_MALE,   nick = "", ball = "normal"},
  {name = "Starmie",   optionalLevel =  70, sex = SEX_FEMALE, nick = "", ball = "normal"},
}

local function doSummonGymPokemon(npc)
  if gymSummonNext(npc, focus, pokemons, battle_turn, 15) then
    fighting = true
    battle_turn = battle_turn + 1
  end
end

local function doWinDuel(cid, npc)
  if not isCreature(cid) then return true end
  local a = gymbadges[getCreatureName(npc)] + 8
  doCreatureSay(npc, "Voce venceu o duelo! Parabens, pegue este(a) "..getItemNameById(a - 8).." como premio.", 1)

  local idx = gymGetLeaderBadgeIndex(npc)
  if idx then
    gymSetBadge(cid, idx)
  end

  if OTCSendSkillBar then
    OTCSendSkillBar(cid)
  end

  if gymHasAllBadges(cid) then
    gymSendAllBadgesMessage(cid)
  end

  local b = getPlayerItemById(cid, true, a)
  if b.uid > 0 then doTransformItem(b.uid, b.itemid - 8) end
end

function onCreatureSay(cid, type, msg)
  msg = string.lower(msg)
  if focus == cid then talk_start = os.clock() end

  if msgcontains(msg, 'hi') and focus == 0 and getDistanceToCreature(cid) <= 4 then
    focus = cid
    talk_start = os.clock()
    conv = 1
    selfSay("Ola "..getCreatureName(cid)..", eu sou a Misty, Lider do Ginasio de Cerulean. Como posso ajudar?")
    return true
  end

  if isDuelMsg(msg) and conv == 1 and focus == cid then
    local idx = gymGetLeaderBadgeIndex(getThis())
    if idx and gymHasBadge(cid, idx) then
      selfSay("Voce ja conquistou minha Insignia. Um lider nao da a mesma insignia duas vezes!")
      return true
    end
    if not hasPokemon(cid) then
      selfSay("Para batalhar contra um lider de ginasio, voce precisa de pokemons.")
      return true
    end
    selfSay("Voce esta me desafiando para uma batalha. Sera uma batalha com limite de "..#pokemons.." pokemons. Vamos comecar?")
    conv = 2
    return true
  end

  if isConfirmMsg(msg) and conv == 2 and focus == cid then
    challenger = focus
    setPlayerStorageValue(cid, 990, 1)
    selfSay("Sim, vamos lutar!")
    talk_start = os.clock()
    addEvent(doSummonGymPokemon, 850, getThis())
    conv = 3
    return true
  end

  if isNegMsg(msg) and conv == 2 and focus == cid then
    focus = 0
    selfSay("Tudo bem, volte quando estiver pronta(o)!")
    return true
  end

  if msgcontains(msg, 'bye') and focus == cid then
    selfSay('Tchau e de o seu melhor, treinador(a)!')
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
      selfSay("Esperei demais, volte quando estiver pronta(o)!")
      return true
    end

    if not afk_warning and afk_time > afk_limit_time / 2 then
      selfSay("Onde esta seu pokemon? Vamos lutar!")
      afk_warning = true
    end

    if #getCreatureSummons(getThis()) == 0 then
      if battle_turn > #pokemons then
        gymClearFlags(getThis(), focus)
        addEvent(doWinDuel, 1000, focus, getThis())
        setPlayerStorageValue(focus, 990, -1)
        focus = 0
        return true
      end
      addEvent(doSummonGymPokemon, 1000, getThis())
    end

    if not hasPokemon(challenger) or challenger_turn >= 7 or challenger_turn > #pokemons then
      gymClearFlags(getThis(), focus)
      selfSay("Voce perdeu nosso duelo! Talvez em outra hora voce me derrote.")
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
    selfSay("Tchau entao.")
    return true
  end

  if (os.clock() - talk_start) > 30 then
    gymClearFlags(getThis(), focus)
    selfSay("Tchau e continue treinando!")
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
