local posis = {   --[storage da city] = {pos da nurse na city},
  [897530] = {x = 1055, y = 1047, z = 7},   --saffron
  [897531] = {x = 1060, y = 903, z = 7},    --cerulean
  [897532] = {x = 1202, y = 1044, z = 7},   --lavender
  [897533] = {x = 1214, y = 1324, z = 7},   --fuchsia
  [897534] = {x = 862, y = 1094, z = 6},    --celadon
  [897535] = {x = 706, y = 1086, z = 7},    --viridian
  [897536] = {x = 1074, y = 1237, z = 7},   --vermilion
  [897537] = {x = 721, y = 848, z = 7},     --pewter
  [897538] = {x = 850, y = 1402, z = 7},    --cinnabar
  [897539] = {x = 1431, y = 1601, z = 6},   --snow
  [897540] = {x = 542, y = 675, z = 7},     --golden
  [897541] = {x = 3117, y = 1291, z = 6},     --out north
  [897542] = {x = 3129, y = 1673, z = 6},     --out south
  [897543] = {x = 3474, y = 1513, z = 6},     --out east
  [897544] = {x = 556, y = 1063, z = 6},     --liga
}

function onThingMove(creature, thing, oldpos, oldstackpos) end
function onCreatureAppear(creature) end

function onCreatureDisappear(cid, pos)
  if focus == cid then
    selfSay('Good bye sir!')
    focus = 0
    talk_start = 0
  end
end

function onCreatureTurn(creature) end

function msgcontains(txt, str)
  return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end

function onCreatureSay(cid, type, msg)
  local msg = string.lower(msg)
  local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

  for a, b in pairs(gobackmsgs) do
    local gm = string.gsub(b.go, "doka!", "")
    local bm = string.gsub(b.back, "doka!", "")
    if string.find(string.lower(msg), string.lower(gm)) or string.find(string.lower(msg), string.lower(bm)) then
      return true
    end
  end

  if ((msgcontains(msg, 'hi') or msgcontains(msg, 'heal') or msgcontains(msg, 'help')) and (getDistanceToCreature(cid) <= 3)) then

    if exhaustion.get(cid, 9211) then
      selfSay('Please wait a few moment before asking me to heal your pokemons again!')
      return true
    end

    if not getTileInfo(getThingPos(cid)).protection and nurseHealsOnlyInPZ then
      selfSay("Please, get inside the pok�mon center to heal your pokemons!")
      return true
    end

    if getPlayerStorageValue(cid, 52480) >= 1 then
      selfSay("You can't do that while in a Duel!")   --alterado v1.6.1
      return true
    end

    for e, f in pairs(posis) do
      local pos = getThingPos(getNpcCid())
      if isPosEqual(pos, f) then
        if getPlayerStorageValue(cid, e) <= -1 then           --alterado v1.7
          setPlayerStorageValue(cid, e, 1)
        end
      end
    end

    exhaustion.set(cid, 9211, 5)

    doCreatureAddHealth(cid, getCreatureMaxHealth(cid) - getCreatureHealth(cid))
    doCureStatus(cid, "all", true)
    doSendMagicEffect(getThingPos(cid), 132)

    local mypb = getPlayerSlotItem(cid, 8)

    if #getCreatureSummons(cid) >= 1 then
      if not nurseHealsPokemonOut then
        selfSay("Please, return your pokemon to his ball!")
        return true
      end

      local s = getCreatureSummons(cid)[1]
      doCreatureAddHealth(s, getCreatureMaxHealth(s))
      doSendMagicEffect(getThingPos(s), 13)
      doCureStatus(s, "all", false)
      if getPlayerStorageValue(s, 1008) < baseNurseryHappiness then
        setPlayerStorageValue(s, 1008, baseNurseryHappiness)
      end
      if getPlayerStorageValue(s, 1009) > baseNurseryHunger then
        setPlayerStorageValue(s, 1009, baseNurseryHunger)
      end

      onPokeHealthChange(cid)

    else
      if mypb.itemid ~= 0 and isPokeball(mypb.itemid) then
        doItemSetAttribute(mypb.uid, "hp", 1)
        if getItemAttribute(mypb.uid, "hunger") and getItemAttribute(mypb.uid, "hunger") > baseNurseryHunger then
          doItemSetAttribute(mypb.uid, "hunger", baseNurseryHunger)
        end
        for c = 1, 15 do
          local str = "move"..c
          setCD(mypb.uid, str, 0)
        end
        if getItemAttribute(mypb.uid, "happy") and getItemAttribute(mypb.uid, "happy") < baseNurseryHappiness then
          doItemSetAttribute(mypb.uid, "happy", baseNurseryHappiness)
        end
        if getPlayerStorageValue(cid, 17000) <= 0 and getPlayerStorageValue(cid, 17001) <= 0 and getPlayerStorageValue(cid, 63215) <= 0 then
          for a, b in pairs (pokeballs) do
            if isInArray(b.all, mypb.itemid) then
              doTransformItem(mypb.uid, b.on)
            end
          end
        end

        syncBallHpAndIcon(cid, mypb.uid, true)
      end
    end

    local bp = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
    local balls = getPokeballsInContainer(bp.uid)
    if #balls >= 1 then
      for _, uid in ipairs(balls) do
        doItemSetAttribute(uid, "hp", 1)
        for c = 1, 15 do
          local str = "move"..c
          setCD(uid, str, 0)
        end
        if getItemAttribute(uid, "hunger") and getItemAttribute(uid, "hunger") > baseNurseryHunger then
          doItemSetAttribute(uid, "hunger", baseNurseryHunger)
        end
        if getItemAttribute(uid, "happy") and getItemAttribute(uid, "happy") < baseNurseryHappiness then
          doItemSetAttribute(uid, "happy", baseNurseryHappiness)
        end
        local this = getThing(uid)
        for a, b in pairs (pokeballs) do
          if isInArray(b.all, this.itemid) then
            doTransformItem(uid, b.on)
          end
        end

        local feet = getPlayerSlotItem(cid, CONST_SLOT_FEET)
        local push = (feet.uid == uid and #getCreatureSummons(cid) == 0)
        syncBallHpAndIcon(cid, uid, push)
      end
    end

    selfSay('There you go! You and your pokemons are healthy again.')

    sendAllPokemonsBarPoke(cid)
    if useKpdoDlls then  --alterado v1.7
      doUpdateMoves(cid)
    end
  end
end
