dofile('data/lib/pb_sync.lua')
local config = {
    loginMessage = getConfigValue('loginMessage'),
    useFragHandler = getBooleanFromString(getConfigValue('useFragHandler'))
}

function onLogin(cid)

    if getPlayerLevel(cid) >= 1 and getPlayerLevel(cid) <= 10 then -- alterado v1.8
        doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, 0)
    else
        doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE,
            (getPlayerLevel(cid) >= 200 and 100 or math.floor(getPlayerLevel(cid) / 2)))
    end
    doCreatureSetDropLoot(cid, false)

    local accountManager = getPlayerAccountManager(cid)

    if (accountManager == MANAGER_NONE) then
        local lastLogin, str = getPlayerLastLoginSaved(cid), config.loginMessage
        if (lastLogin > 0) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_DEFAULT, str)
            str = "Your last visit was on " .. os.date("%a %b %d %X %Y", lastLogin) .. "."
        else
            str = str
        end

        doPlayerSendTextMessage(cid, MESSAGE_STATUS_DEFAULT, str)

    elseif (accountManager == MANAGER_NAMELOCK) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
            "Hello, it appears that your character has been namelocked, what would you like as your new name?")
    elseif (accountManager == MANAGER_ACCOUNT) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
            "Hello, type 'account' to manage your account and if you want to start over then type 'cancel'.")
    else
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
            "Hello, type 'account' to create an account or type 'recover' to recover an account.")
    end

    if getCreatureName(cid) == "Account Manager" then
        local outfit = {}
        if accountManagerRandomPokemonOutfit then
            outfit = {
                lookType = getPokemonXMLOutfit(oldpokedex[math.random(151)][1])
            }
        else
            outfit = accountManagerOutfit
        end

        doSetCreatureOutfit(cid, outfit, -1)
        return true
    end

    if (not isPlayerGhost(cid)) then
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
    end

    local outfit = {}

    if getPlayerVocation(cid) == 0 then
        doPlayerSetMaxCapacity(cid, 0)
        doPlayerSetVocation(cid, 1)
        setCreatureMaxMana(cid, 6)
        doPlayerAddSoul(cid, -getPlayerSoul(cid))
        setPlayerStorageValue(cid, 19898, 0)
        if getCreatureOutfit(cid).lookType == 128 then
            outfit = {
                lookType = 510,
                lookHead = math.random(0, 132),
                lookBody = math.random(0, 132),
                lookLegs = math.random(0, 132),
                lookFeet = math.random(0, 132)
            }
        elseif getCreatureOutfit(cid).lookType == 136 then
            outfit = {
                lookType = 511,
                lookHead = math.random(0, 132),
                lookBody = math.random(0, 132),
                lookLegs = math.random(0, 132),
                lookFeet = math.random(0, 132)
            }
        end
        doCreatureChangeOutfit(cid, outfit)
    end

    registerCreatureEvent(cid, "dropStone")
    registerCreatureEvent(cid, "ShowPokedex")
    registerCreatureEvent(cid, "ClosePokedex")
    registerCreatureEvent(cid, "WalkTv")
    registerCreatureEvent(cid, "RecordTv")
    registerCreatureEvent(cid, "PlayerLogout")
    registerCreatureEvent(cid, "WildAttack")
    registerCreatureEvent(cid, "Idle")
    registerCreatureEvent(cid, "EffectOnAdvance")
    registerCreatureEvent(cid, "GeneralConfiguration")
    registerCreatureEvent(cid, "SaveReportBug")
    registerCreatureEvent(cid, "LookSystem")
    registerCreatureEvent(cid, "T1")
    registerCreatureEvent(cid, "T2")
    registerCreatureEvent(cid, "task_count")
    registerCreatureEvent(cid, "RaidLogin")
    registerCreatureEvent(cid, "RaidKill")
    registerCreatureEvent(cid, "RaidDeath")
    registerCreatureEvent(cid, "RemoveCoinCase")
    registerCreatureEvent(cid, "AutoLootKill")
    registerCreatureEvent(cid, "Duel_ExtOP")
    registerCreatureEvent(cid, "TournamentLogout")
    if Tournament and Tournament.cfg then
    if getPlayerStorageValue(cid, Tournament.cfg.relogOutStorage) == 1 then
        setPlayerStorageValue(cid, Tournament.cfg.relogOutStorage, -1)
        doTeleportThing(cid, Tournament.cfg.outPos)
        doSendMagicEffect(Tournament.cfg.outPos, CONST_ME_TELEPORT)
    end
    if type(Tournament.isInTournamentArea) == "function" and Tournament.isInTournamentArea(cid) then
        if getPlayerStorageValue(cid, IS_IN_TOURNAMENT) ~= 1 or not Tournament.isRunning() then
        setPlayerStorageValue(cid, IS_IN_TOURNAMENT, -1)
        setPlayerStorageValue(cid, PLAYER_IN_TOURNAMENT, -1)
        setPlayerStorageValue(cid, Tournament.cfg.duelStorage, -1)
        setPlayerStorageValue(cid, Tournament.cfg.gymBlockStorage, -1)
        doTeleportThing(cid, Tournament.cfg.outPos)
        doSendMagicEffect(Tournament.cfg.outPos, CONST_ME_TELEPORT)
        end
    end
    end
    registerCreatureEvent(cid, "AntiDropPortraits")
    registerCreatureEvent(cid, "DailyKillHook")
    registerCreatureEvent(cid, "Opcode")
    if getPlayerStorageValue(cid, 990) > 0 then
        setPlayerStorageValue(cid, 990, -1)
    end
    registerCreatureEvent(cid, "EliteLogout")
    addEvent(function()
        if isPlayer(cid) and OTCSendSkillBar then
            OTCSendSkillBar(cid)
        end
    end, 1000)

    sendPokeHPMsg(cid)
    addEvent(sendPokeHPMsg, 200, cid)

    if getPlayerStorageValue(cid, 99284) == 1 then
        setPlayerStorageValue(cid, 99284, -1)
    end

    if getPlayerStorageValue(cid, 6598754) >= 1 or getPlayerStorageValue(cid, 6598755) >= 1 then
        setPlayerStorageValue(cid, 6598754, -1)
        setPlayerStorageValue(cid, 6598755, -1)
        doRemoveCondition(cid, CONDITION_OUTFIT) -- alterado v1.9 \/
        doTeleportThing(cid, posBackPVP, false)
        doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
    end

    doChangeSpeed(cid, -(getCreatureSpeed(cid)))

    -- ///////////////////////////////////////////////////////////////////////////--
    local storages = {17000, 63215, 17001, 13008, 5700}
    for s = 1, #storages do
        if not tonumber(getPlayerStorageValue(cid, storages[s])) then
            if s == 3 then
                setPlayerStorageValue(cid, storages[s], 1)
            elseif s == 4 then
                setPlayerStorageValue(cid, storages[s], -1)
            else
                if isBeingUsed(getPlayerSlotItem(cid, 8).itemid) then
                    setPlayerStorageValue(cid, storages[s], 1)
                else
                    setPlayerStorageValue(cid, storages[s], -1)
                end
            end
            doPlayerSendTextMessage(cid, 27, "Sorry, but a problem occurred on the server, but now it's alright")
        end
    end
    -- /////////////////////////////////////////////////////////////////////////--
    if getPlayerStorageValue(cid, 17000) >= 1 then -- fly

        local item = getPlayerSlotItem(cid, 8)
        local poke = getItemAttribute(item.uid, "poke")
        doChangeSpeed(cid, getPlayerStorageValue(cid, 54844))
        doRemoveCondition(cid, CONDITION_OUTFIT)
        doSetCreatureOutfit(cid, {
            lookType = flys[poke][1] + 351
        }, -1)

        local apos = getFlyingMarkedPos(cid)
        apos.stackpos = 0

        if getTileThingByPos(apos).itemid <= 2 then
            doCombatAreaHealth(cid, FIREDAMAGE, getFlyingMarkedPos(cid), 0, 0, 0, CONST_ME_NONE)
            doCreateItem(460, 1, getFlyingMarkedPos(cid))
        end

        doTeleportThing(cid, apos, false)
        if getItemAttribute(item.uid, "boost") and getItemAttribute(item.uid, "boost") >= 50 and
            getPlayerStorageValue(cid, 42368) >= 1 then
            sendAuraEffect(cid, auraSyst[getItemAttribute(item.uid, "aura")]) -- alterado v1.8
        end

        local posicao = getTownTemplePosition(getPlayerTown(cid))
        markFlyingPos(cid, posicao)

    elseif getPlayerStorageValue(cid, 63215) >= 1 then -- surf

        local item = getPlayerSlotItem(cid, 8)
        local poke = getItemAttribute(item.uid, "poke")
        doSetCreatureOutfit(cid, {
            lookType = surfs[poke].lookType + 351
        }, -1) -- alterado v1.6
        doChangeSpeed(cid, getPlayerStorageValue(cid, 54844))
        if getItemAttribute(item.uid, "boost") and getItemAttribute(item.uid, "boost") >= 50 and
            getPlayerStorageValue(cid, 42368) >= 1 then
            sendAuraEffect(cid, auraSyst[getItemAttribute(item.uid, "aura")]) -- alterado v1.8
        end

    elseif getPlayerStorageValue(cid, 17001) >= 1 then -- ride

        local item = getPlayerSlotItem(cid, 8)
        local poke = getItemAttribute(item.uid, "poke")

        if rides[poke] then
            doChangeSpeed(cid, getPlayerStorageValue(cid, 54844))
            doRemoveCondition(cid, CONDITION_OUTFIT)
            doSetCreatureOutfit(cid, {
                lookType = rides[poke][1] + 351
            }, -1)
            if getItemAttribute(item.uid, "boost") and getItemAttribute(item.uid, "boost") >= 50 and
                getPlayerStorageValue(cid, 42368) >= 1 then
                sendAuraEffect(cid, auraSyst[getItemAttribute(item.uid, "aura")]) -- alterado v1.8
            end
        else
            setPlayerStorageValue(cid, 17001, -1)
            doRegainSpeed(cid)
        end

        local posicao2 = getTownTemplePosition(getPlayerTown(cid))
        markFlyingPos(cid, posicao2)

    elseif getPlayerStorageValue(cid, 13008) >= 1 then -- dive
        if not isInArray({5405, 5406, 5407, 5408, 5409, 5410}, getTileInfo(getThingPos(cid)).itemid) then
            setPlayerStorageValue(cid, 13008, 0)
            doRegainSpeed(cid)
            doRemoveCondition(cid, CONDITION_OUTFIT)
            return true
        end

        if getPlayerSex(cid) == 1 then
            doSetCreatureOutfit(cid, {
                lookType = 1034,
                lookHead = getCreatureOutfit(cid).lookHead,
                lookBody = getCreatureOutfit(cid).lookBody,
                lookLegs = getCreatureOutfit(cid).lookLegs,
                lookFeet = getCreatureOutfit(cid).lookFeet
            }, -1)
        else
            doSetCreatureOutfit(cid, {
                lookType = 1035,
                lookHead = getCreatureOutfit(cid).lookHead,
                lookBody = getCreatureOutfit(cid).lookBody,
                lookLegs = getCreatureOutfit(cid).lookLegs,
                lookFeet = getCreatureOutfit(cid).lookFeet
            }, -1)
        end
        doChangeSpeed(cid, 800)

elseif getPlayerStorageValue(cid, 5700) > 0 then -- bike
    doChangeSpeed(cid, -getCreatureSpeed(cid))
    doChangeSpeed(cid, getPlayerStorageValue(cid, 5700))

    local savedLook = tonumber(getPlayerStorageValue(cid, 5701) or -1)
    local lookType = (savedLook and savedLook > 0)
        and savedLook
        or ((getPlayerSex(cid) == 1) and 1394 or 1393)

    doSetCreatureOutfit(cid, { lookType = lookType }, -1)

    if getPlayerStorageValue(cid, 5712) == 1 then
        local baseMax = tonumber(getPlayerStorageValue(cid, 5710) or 0)
        if baseMax and baseMax > 0 then
            local pct = getCreatureHealth(cid) / math.max(1, getCreatureMaxHealth(cid))
            setCreatureMaxHealth(cid, baseMax * 2)
            local targetHp = math.floor((baseMax * 2) * pct + 0.5)
            doCreatureAddHealth(cid, targetHp - getCreatureHealth(cid))
        end
    end


    elseif getPlayerStorageValue(cid, 75846) >= 1 then -- alterado v1.9 \/
        doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
        setPlayerStorageValue(cid, 75846, -1)
        sendMsgToPlayer(cid, 20, "You have been moved to your town!")
    else
        doRegainSpeed(cid)
    end

local GOLDEN_KICK_LOGIN = 22552

if getPlayerStorageValue(cid, GOLDEN_KICK_LOGIN) == 1 then
    setPlayerStorageValue(cid, GOLDEN_KICK_LOGIN, -1)
    setPlayerStorageValue(cid, 22545, -1)

    doTeleportThing(cid, getClosestFreeTile(cid, posBackGolden), false)
    setPlayerRecordWaves(cid)
end



    if useKpdoDlls then
        doUpdateMoves(cid)
        doUpdatePokemonsBar(cid)
    end

    addEvent(function()
        if isPlayer(cid) then
            sendPokeballOnClientIds(cid)
        end
    end, 200)
    if getPlayerStorageValue(cid, 52480) >= 1 and getPlayerStorageValue(cid, 52484) ~= 10 then
        doEndDuel(cid, true)
    end
    return true
end
