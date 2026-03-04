local function _setGymFlags(leaderSummon, player, playerSummon, val)
  if type(doSetGym) ~= 'function' then return end
  if isCreature(leaderSummon) then doSetGym(leaderSummon, val) end
  if isCreature(player)       then doSetGym(player,       val) end
  if isCreature(playerSummon) then doSetGym(playerSummon, val) end
end

function gymSetFlags(leaderSummon, player, playerSummon, val)
  return _setGymFlags(leaderSummon, player, playerSummon, val)
end

function gymClearFlags(npc, player)
  if type(doSetGym) ~= 'function' then return end
  local leaderSummon = (#getCreatureSummons(npc) >= 1) and getCreatureSummons(npc)[1] or nil
  local enemy        = (isCreature(player) and #getCreatureSummons(player) >= 1) and getCreatureSummons(player)[1] or nil
  _setGymFlags(leaderSummon, player, enemy, 0)
end

local GYM_INFIGHT_TICKS  = 12 * 1000
local GYM_INFIGHT_RECHECK = 1000

local gymFightCond = createConditionObject(CONDITION_INFIGHT)
setConditionParam(gymFightCond, CONDITION_PARAM_TICKS, GYM_INFIGHT_TICKS)

local GYM_INFIGHT_LOOP_STO = 908877

local function gymInfightTick(leaderSummon, player, enemySummon)
  if not isCreature(leaderSummon) then return true end
  if not isCreature(player) then
    setPlayerStorageValue(leaderSummon, GYM_INFIGHT_LOOP_STO, -1)
    return true
  end

  if not isCreature(enemySummon) then
    local ps = getCreatureSummons(player)
    enemySummon = (ps and ps[1]) or nil
    if not isCreature(enemySummon) then
      setPlayerStorageValue(leaderSummon, GYM_INFIGHT_LOOP_STO, -1)
      return true
    end
  end

  local t = getCreatureTarget(leaderSummon)
  local stillEngaged = (t == enemySummon) or (t == player)

  if not stillEngaged then
    setPlayerStorageValue(leaderSummon, GYM_INFIGHT_LOOP_STO, -1)
    return true
  end

  doAddCondition(player, gymFightCond)
  doAddCondition(enemySummon, gymFightCond)

  addEvent(gymInfightTick, GYM_INFIGHT_RECHECK, leaderSummon, player, enemySummon)
  return true
end

function gymStartAggro(leaderSummon, player)
  if not isCreature(leaderSummon) or not isCreature(player) then return end

  local enemy = (#getCreatureSummons(player) >= 1) and getCreatureSummons(player)[1] or nil
  if not isCreature(enemy) then
    return
  end

  _setGymFlags(leaderSummon, player, enemy, 1)

  if type(doSetGym) == 'function' then
    doSetGym(leaderSummon, 1)
    doSetGym(enemy, 1)
    doSetGym(player, 1)
  end

  if type(doSetAttackGym) == 'function' then
    doSetAttackGym(leaderSummon, enemy)
  elseif type(doChallengeCreature) == 'function' then
    doChallengeCreature(enemy, leaderSummon)
  end

  if getPlayerStorageValue(leaderSummon, GYM_INFIGHT_LOOP_STO) ~= 1 then
    setPlayerStorageValue(leaderSummon, GYM_INFIGHT_LOOP_STO, 1)
    addEvent(gymInfightTick, 10, leaderSummon, player, enemy)
  end
end

function gymRetargetTick(npc, player)
  if not isCreature(npc) or not isCreature(player) then return false end
  local leaderSummon = (#getCreatureSummons(npc) >= 1) and getCreatureSummons(npc)[1] or nil
  if not leaderSummon then return false end

  local enemySummon = (#getCreatureSummons(player) >= 1) and getCreatureSummons(player)[1] or nil
  local curTarget   = getCreatureTarget(leaderSummon)

  if not isCreature(curTarget) then
    gymStartAggro(leaderSummon, player)
    return true
  end

  if curTarget == player and isCreature(enemySummon) then
    gymStartAggro(leaderSummon, player)
    return true
  end

  if isCreature(enemySummon) and curTarget ~= enemySummon then
    gymStartAggro(leaderSummon, player)
    return true
  end

  return false
end

function gymSummonNext(npc, focus, pokemons, battle_turn, adjustDelayMs)
  if #getCreatureSummons(npc) >= 1 or focus == 0 then return false end

  local it = pokemons[battle_turn]
  if not it then return false end

  doSummonMonster(npc, it.name)
  local summon = getCreatureSummons(npc)[1]
  if not isCreature(summon) then return false end

  local balleffect = pokeballs["normal"].effect
  if it.ball and pokeballs[it.ball] then
    balleffect = pokeballs[it.ball].effect
  end
  doSendMagicEffect(getThingPos(summon), balleffect)

  setPlayerStorageValue(summon, 10000, balleffect)
  setPlayerStorageValue(summon, 10001, gobackmsgs[math.random(#gobackmsgs)].back:gsub("doka", it.nick ~= "" and it.nick or it.name))
  setPlayerStorageValue(summon, 1007, it.nick ~= "" and it.nick or it.name)

  if type(doSetGym) == 'function' then
  doSetGym(summon, 1)
end
  addEvent(adjustWildPoke, adjustDelayMs or 15, summon, it.optionalLevel)

  doCreatureSay(npc, gobackmsgs[math.random(#gobackmsgs)].go:gsub("doka", getPlayerStorageValue(summon, 1007)), 1)

  gymStartAggro(summon, focus)
  return true
end

GYM_BADGE_STORAGE_BASE = 9100
GYM_LEADER_BADGE_INDEX = {
  ["Brock"] = 1,
  ["Misty"] = 2,
  ["Surge"] = 3,
  ["Erika"] = 4,
  ["Sabrina"] = 5,
  ["Koga"] = 6,
  ["Blaine"] = 7,
  ["Kira"] = 8,
}

function gymGetLeaderBadgeIndex(npc)
  if not isCreature(npc) then return nil end
  return GYM_LEADER_BADGE_INDEX[getCreatureName(npc)]
end

function gymHasBadge(cid, badgeIndex)
  if not isPlayer(cid) or not badgeIndex then return false end
  return getPlayerStorageValue(cid, GYM_BADGE_STORAGE_BASE + badgeIndex) > 0
end

function gymSetBadge(cid, badgeIndex)
  if not isPlayer(cid) or not badgeIndex then return false end
  setPlayerStorageValue(cid, GYM_BADGE_STORAGE_BASE + badgeIndex, 1)
  return true
end

function gymHasAllBadges(cid)
  if not isPlayer(cid) then return false end
  for i = 1, 8 do
    if getPlayerStorageValue(cid, GYM_BADGE_STORAGE_BASE + i) <= 0 then
      return false
    end
  end
  return true
end

function gymSendAllBadgesMessage(cid)

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
    "Parabens, treinador! Voce conquistou as 8 Insignias oficiais de Kanto.\n" ..
    "Agora voce esta apto a desafiar a Elite dos 4 e provar que merece o titulo de Campeao!"
  )
end