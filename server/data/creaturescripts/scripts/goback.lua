-- function onLogout(cid)
--     if getPlayerStorageValue(cid, 154585) >= 1 then
--         doPlayerSendTextMessage(cid, 20, "Voce Nao pode deslogar Enquanto pesca!")
--         return false
--     end
--     if not isCreature(cid) then
--         return true
--     end
--     local thisitem = getPlayerSlotItem(cid, 8)

--     if thisitem.uid <= 0 then
--         return true
--     end
--     doItemSetAttribute(thisitem.uid, "mega_active", 0)
--     local ballName = getItemAttribute(thisitem.uid, "poke")
--     local btype = getPokeballType(thisitem.itemid)

--     ---------------------------------------------------------------
--     if #getCreatureSummons(cid) > 1 and getPlayerStorageValue(cid, 212124) <= 0 then -- alterado v1.6
--         if getPlayerStorageValue(cid, 637501) == -2 or getPlayerStorageValue(cid, 637501) >= 1 then
--             BackTeam(cid)
--         end
--     end
--     -- ////////////////////////////////////////////////////////////////////////////////////////--
--     if getPlayerStorageValue(cid, 52480) >= 1 then
--         doEndDuel(cid, true)
--     end
--     -- ////////////////////////////////////////////////////////////////////////////////////////--
--     if #getCreatureSummons(cid) == 2 and getPlayerStorageValue(cid, 212124) >= 1 then
--         local cmed2 = getCreatureSummons(cid)[1]
--         local poscmed = getThingPos(cmed2)
--         local cmeddir = getCreatureLookDir(cmed2)
--         local namecmed = getCreatureName(cmed2)
--         local hp, maxHp = getCreatureHealth(getCreatureSummons(cid)[1]),
--             getCreatureMaxHealth(getCreatureSummons(cid)[1])
--         local gender = getPokemonGender(cmed2)
--         doRemoveCreature(getCreatureSummons(cid)[1])
--         local back = doCreateMonster(namecmed, poscmed)
--         addEvent(doCreatureSetSkullType, 150, back, gender)
--         doCreatureSetLookDir(back, cmeddir)
--         addEvent(doCreatureAddHealth, 100, back, hp - maxHp)

--         -- pokemon controlador	
--         local ball2 = getPlayerSlotItem(cid, 8)
--         local mynewpos = getThingPos(getCreatureSummons(cid)[1])
--         doRemoveCreature(getCreatureSummons(cid)[1])
--         local pk2 = doSummonCreature(getItemAttribute(ball2.uid, "poke"), mynewpos)
--         doConvinceCreature(cid, pk2)
--         addEvent(doAdjustWithDelay, 100, cid, pk2, true, true, false)
--         setPlayerStorageValue(cid, 888, -1)
--         cleanCMcds(ball2.uid)
--         doCreatureSetLookDir(getCreatureSummons(cid)[1], 2)
--         registerCreatureEvent(pk2, "SummonDeath")
--     end

--     ----------------------------------------------------------------------
--     local summon = getCreatureSummons(cid)[1]

--     if #getCreatureSummons(cid) >= 1 and thisitem.uid > 1 then
--         if getPlayerStorageValue(cid, 212124) <= 0 then
--             doItemSetAttribute(thisitem.uid, "hp", (getCreatureHealth(summon) / getCreatureMaxHealth(summon)))
--         end
--         setPlayerStorageValue(cid, 212124, 0)
--         local baseName = getItemAttribute(thisitem.uid, "poke")
--         if baseName then
--             local hpfrac = tonumber(getItemAttribute(thisitem.uid, "hp") or 0) or 0
--             local want = (hpfrac <= 0) and (baseName .. "_off") or baseName
--             doItemSetAttribute(thisitem.uid, "10002", want)
--         end
--         doTransformItem(thisitem.uid, pokeballs[btype].on)
--         doSendMagicEffect(getThingPos(summon), pokeballs[btype].effect)
--         doRemoveCreature(summon)
--         syncBallHpAndIcon(cid, thisitem.uid, true)
--     end

--     if getCreatureOutfit(cid).lookType == 814 then
--         doPlayerStopWatching(cid)
--     end

--     if tonumber(getPlayerStorageValue(cid, 17000)) and getPlayerStorageValue(cid, 17000) >= 1 then
--         markFlyingPos(cid, getThingPos(cid))
--     end

-- local GOLDEN_KICK_LOGIN = 22552

-- if getPlayerStorageValue(cid, 22545) == 1 then
--     -- marca pra expulsar quando logar (porque teleport no logout não garante)
--     setPlayerStorageValue(cid, GOLDEN_KICK_LOGIN, 1)

--     -- remove ele da contagem da golden AGORA
--     setPlayerStorageValue(cid, 22545, -1)

--     local started = (getGlobalStorageValue(22547) > 0)

--     -- recalcula vivos online (os que ainda tem 22545 == 1)
--     local aliveNow = 0
--     local last = nil
--     for _, pid in ipairs(getPlayersOnline()) do
--         if isPlayer(pid) and getPlayerStorageValue(pid, 22545) == 1 then
--             aliveNow = aliveNow + 1
--             last = pid
--         end
--     end
--     setGlobalStorageValue(22550, aliveNow)

--     if aliveNow <= 0 then
--         endGoldenArena()
--         return true
--     end

--     if aliveNow == 1 and last then
--         if started then
--             doPlayerSendTextMessage(last, 20, "Você foi o ultimo sobrevivente, pegue o seu premio!")
--             doPlayerAddItem(last, 2152, math.max(0, getPlayerStorageValue(last, 22551)) * 2)
--         else
--             doPlayerSendTextMessage(last, 20, "Golden Arena cancelada (sem participantes o suficiente).")
--         end

--         setPlayerStorageValue(last, 22545, -1)
--         doTeleportThing(last, getClosestFreeTile(last, posBackGolden), false)
--         doCreatureAddHealth(last, getCreatureMaxHealth(last) - getCreatureHealth(last))
--         setPlayerRecordWaves(last)

--         endGoldenArena()
--         return true
--     end
-- end


--     sendPokeHPMsg(cid)
--     return true
-- end

-- local deathtexts = {"Oh no! POKENAME, come back!", "Come back, POKENAME!", "That's enough, POKENAME!",
--                     "You did well, POKENAME!", "You need to rest, POKENAME!", "Nice job, POKENAME!",
--                     "POKENAME, you are too hurt!"}

-- function onDeath(cid, deathList)

--     local owner = getCreatureMaster(cid)

--     if getPlayerStorageValue(cid, 637500) >= 1 then
--         doSendMagicEffect(getThingPos(cid), 211)
--         doRemoveCreature(cid)
--         return true
--     end

--     if getPlayerStorageValue(cid, 212123) >= 1 then
--         return true
--     end

--     -- ////////////////////////////////////////////////////////////////////////////////////////--
--     checkDuel(owner)
--     -- ////////////////////////////////////////////////////////////////////////////////////////--

--     local thisball = getPlayerSlotItem(owner, 8)
--     if thisball and thisball.uid > 0 then
--         doItemSetAttribute(thisball.uid, "mega_active", 0)
--     end
--     local ballName = getItemAttribute(thisball.uid, "poke")

--     btype = getPokeballType(thisball.itemid)

--     if #getCreatureSummons(owner) > 1 then
--         BackTeam(owner, getCreatureSummons(owner))
--     end

--     doSendMagicEffect(getThingPos(cid), pokeballs[btype].effect)
--     local baseName = getItemAttribute(thisball.uid, "poke")
--     if baseName then
--         doItemSetAttribute(thisball.uid, "10002", baseName .. "_off")
--     end
--     doTransformItem(thisball.uid, pokeballs[btype].off)
--     sendPokeHPMsg(owner)
--     doPlayerSendTextMessage(owner, 22, "Your pokemon fainted.")

--     local say = deathtexts[math.random(#deathtexts)]
--     say = string.gsub(say, "POKENAME", getCreatureName(cid))

--     if getPlayerStorageValue(cid, 33) <= 0 then
--         doCreatureSay(owner, say, TALKTYPE_SAY)
--     end

--     doItemSetAttribute(thisball.uid, "hp", 0)
--     if ehMonstro(deathList[1]) then
--         doItemSetAttribute(thisball.uid, "happy", getPlayerStorageValue(cid, 1008) - happyLostOnDeath)
--     end
--     doItemSetAttribute(thisball.uid, "hunger", getPlayerStorageValue(cid, 1009))

--     if useOTClient then
--         doPlayerSendCancel(owner, '12//,hide') -- alterado v1.7
--     end

--     doRemoveCreature(cid)

--     return false
-- end


function onLogout(cid)
    if getPlayerStorageValue(cid, 154585) >= 1 then
        doPlayerSendTextMessage(cid, 20, "Voce Nao pode deslogar Enquanto pesca!")
        return false
    end
    if not isCreature(cid) then
        return true
    end
    local thisitem = getPlayerSlotItem(cid, 8)

    if thisitem.uid <= 0 then
        return true
    end
    doItemSetAttribute(thisitem.uid, "mega_active", 0)
    local ballName = getItemAttribute(thisitem.uid, "poke")
    local btype = getPokeballType(thisitem.itemid)

    ---------------------------------------------------------------
    if #getCreatureSummons(cid) > 1 and getPlayerStorageValue(cid, 212124) <= 0 then -- alterado v1.6
        if getPlayerStorageValue(cid, 637501) == -2 or getPlayerStorageValue(cid, 637501) >= 1 then
            BackTeam(cid)
        end
    end
    -- ////////////////////////////////////////////////////////////////////////////////////////--
    if getPlayerStorageValue(cid, 52480) >= 1 then
        doEndDuel(cid, true)
    end
    -- ////////////////////////////////////////////////////////////////////////////////////////--
    if #getCreatureSummons(cid) == 2 and getPlayerStorageValue(cid, 212124) >= 1 then
        local cmed2 = getCreatureSummons(cid)[1]
        local poscmed = getThingPos(cmed2)
        local cmeddir = getCreatureLookDir(cmed2)
        local namecmed = getCreatureName(cmed2)
        local hp, maxHp = getCreatureHealth(getCreatureSummons(cid)[1]),
            getCreatureMaxHealth(getCreatureSummons(cid)[1])
        local gender = getPokemonGender(cmed2)
        doRemoveCreature(getCreatureSummons(cid)[1])
        local back = doCreateMonster(namecmed, poscmed)
        addEvent(doCreatureSetSkullType, 150, back, gender)
        doCreatureSetLookDir(back, cmeddir)
        addEvent(doCreatureAddHealth, 100, back, hp - maxHp)

        -- pokemon controlador	
        local ball2 = getPlayerSlotItem(cid, 8)
        local mynewpos = getThingPos(getCreatureSummons(cid)[1])
        doRemoveCreature(getCreatureSummons(cid)[1])
        local pk2 = doSummonCreature(getItemAttribute(ball2.uid, "poke"), mynewpos)
        doConvinceCreature(cid, pk2)
        addEvent(doAdjustWithDelay, 100, cid, pk2, true, true, false)
        setPlayerStorageValue(cid, 888, -1)
        cleanCMcds(ball2.uid)
        doCreatureSetLookDir(getCreatureSummons(cid)[1], 2)
        registerCreatureEvent(pk2, "SummonDeath")
    end

    ----------------------------------------------------------------------
    local summon = getCreatureSummons(cid)[1]

    if #getCreatureSummons(cid) >= 1 and thisitem.uid > 1 then
        if getPlayerStorageValue(cid, 212124) <= 0 then
            doItemSetAttribute(thisitem.uid, "hp", (getCreatureHealth(summon) / getCreatureMaxHealth(summon)))
        end
        setPlayerStorageValue(cid, 212124, 0)
        local baseName = getItemAttribute(thisitem.uid, "poke")
        if baseName then
            local hpfrac = tonumber(getItemAttribute(thisitem.uid, "hp") or 0) or 0
            local want = (hpfrac <= 0) and (baseName .. "_off") or baseName
            doItemSetAttribute(thisitem.uid, "10002", want)
        end
        doTransformItem(thisitem.uid, pokeballs[btype].on)
        doSendMagicEffect(getThingPos(summon), pokeballs[btype].effect)
        doRemoveCreature(summon)
        syncBallHpAndIcon(cid, thisitem.uid, true)
    end

    if getCreatureOutfit(cid).lookType == 814 then
        doPlayerStopWatching(cid)
    end

    if tonumber(getPlayerStorageValue(cid, 17000)) and getPlayerStorageValue(cid, 17000) >= 1 then
        markFlyingPos(cid, getThingPos(cid))
    end

local GOLDEN_KICK_LOGIN = 22552

if getPlayerStorageValue(cid, 22545) == 1 then
    -- marca pra expulsar quando logar (porque teleport no logout não garante)
    setPlayerStorageValue(cid, GOLDEN_KICK_LOGIN, 1)

    -- remove ele da contagem da golden AGORA
    setPlayerStorageValue(cid, 22545, -1)

    local started = (getGlobalStorageValue(22547) > 0)

    -- recalcula vivos online (os que ainda tem 22545 == 1)
    local aliveNow = 0
    local last = nil
    for _, pid in ipairs(getPlayersOnline()) do
        if isPlayer(pid) and getPlayerStorageValue(pid, 22545) == 1 then
            aliveNow = aliveNow + 1
            last = pid
        end
    end
    setGlobalStorageValue(22550, aliveNow)

    if aliveNow <= 0 then
        endGoldenArena()
        return true
    end

    if aliveNow == 1 and last then
        if started then
            doPlayerSendTextMessage(last, 20, "Você foi o ultimo sobrevivente, pegue o seu premio!")
            doPlayerAddItem(last, 2152, math.max(0, getPlayerStorageValue(last, 22551)) * 2)
        else
            doPlayerSendTextMessage(last, 20, "Golden Arena cancelada (sem participantes o suficiente).")
        end

        setPlayerStorageValue(last, 22545, -1)
        doTeleportThing(last, getClosestFreeTile(last, posBackGolden), false)
        doCreatureAddHealth(last, getCreatureMaxHealth(last) - getCreatureHealth(last))
        setPlayerRecordWaves(last)

        endGoldenArena()
        return true
    end
end


    sendPokeHPMsg(cid)
    return true
end

local deathtexts = {"Oh no! POKENAME, come back!", "Come back, POKENAME!", "That's enough, POKENAME!",
                    "You did well, POKENAME!", "You need to rest, POKENAME!", "Nice job, POKENAME!",
                    "POKENAME, you are too hurt!"}

function onDeath(cid, deathList)

    local owner = getCreatureMaster(cid)

    if getPlayerStorageValue(cid, 637500) >= 1 then
        doSendMagicEffect(getThingPos(cid), 211)
        doRemoveCreature(cid)
        return true
    end

    if getPlayerStorageValue(cid, 212123) >= 1 then
        return true
    end

    -- ////////////////////////////////////////////////////////////////////////////////////////--
    checkDuel(owner)
    -- ////////////////////////////////////////////////////////////////////////////////////////--

    local thisball = getPlayerSlotItem(owner, 8)
    if thisball and thisball.uid > 0 then
        doItemSetAttribute(thisball.uid, "mega_active", 0)
    end
    local ballName = getItemAttribute(thisball.uid, "poke")

    btype = getPokeballType(thisball.itemid)

    if #getCreatureSummons(owner) > 1 then
        BackTeam(owner, getCreatureSummons(owner))
    end

    doSendMagicEffect(getThingPos(cid), pokeballs[btype].effect)
    local baseName = getItemAttribute(thisball.uid, "poke")
    if baseName then
        doItemSetAttribute(thisball.uid, "10002", baseName .. "_off")
    end
    doTransformItem(thisball.uid, pokeballs[btype].off)
    sendPokeHPMsg(owner)
    doPlayerSendTextMessage(owner, 22, "Your pokemon fainted.")

    local say = deathtexts[math.random(#deathtexts)]
    say = string.gsub(say, "POKENAME", getCreatureName(cid))

    if getPlayerStorageValue(cid, 33) <= 0 then
        doCreatureSay(owner, say, TALKTYPE_SAY)
    end

    doItemSetAttribute(thisball.uid, "hp", 0)
    if ehMonstro(deathList[1]) then
        doItemSetAttribute(thisball.uid, "happy", getPlayerStorageValue(cid, 1008) - happyLostOnDeath)
    end
    doItemSetAttribute(thisball.uid, "hunger", getPlayerStorageValue(cid, 1009))

    if isPlayer(owner) and useOTClient then
        doPlayerSendCancel(owner, '12//,hide')
    end
    doRemoveCreature(cid)

    addEvent(function()
        if not isPlayer(owner) then return end

        if type(doUpdateMoves) == "function" then
            doUpdateMoves(owner)
        end

        if type(doUpdateCooldowns) == "function" then
            addEvent(doUpdateCooldowns, 50, owner)
        end

        if useOTClient then
            doPlayerSendCancel(owner, '12//,hide')
        end
    end, 80)

    return false

end
