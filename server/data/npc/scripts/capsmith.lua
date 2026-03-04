local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)
    npcHandler:onCreatureAppear(cid)
end
function onCreatureDisappear(cid)
    npcHandler:onCreatureDisappear(cid)
end
function onCreatureSay(cid, type, msg)
    npcHandler:onCreatureSay(cid, type, msg)
end
function onThink()
    npcHandler:onThink()
end

npcHandler:setMessage(MESSAGE_GREET,
    "Hey, trainer! I can upgrade IVs using {bottle cap} or {golden bottle cap}. Ask me about them.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good luck out there!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Come back if you need more upgrades.")

local function npcsay(cid, text)
    local t = TALKTYPE_PRIVATE_NP or TALKTYPE_PRIVATE_NPC or TALKTYPE_PRIVATE or TALKTYPE_SAY
    doCreatureSay(getNpcId(), text, t, false, cid)
end

local BOTTLE_CAP_ID = 12703
local GOLDEN_BOTTLE_CAP_ID = 12704

local STAT_ALIASES = {
    offense = "iv_off",
    off = "iv_off",
    atk = "iv_off",
    attack = "iv_off",
    specialattack = "iv_spa",
    spattack = "iv_spa",
    spa = "iv_spa",
    sp_atk = "iv_spa",
    defense = "iv_def",
    def = "iv_def",
    vitality = "iv_vit",
    vit = "iv_vit",
    hp = "iv_hp",
    cdr = "iv_cdr",
    cooldown = "iv_cdr",
    haste = "iv_cdr",
    speed = "iv_cdr"
}

local PRETTY = {
    iv_off = "Offense",
    iv_spa = "Special Attack",
    iv_def = "Defense",
    iv_vit = "Vitality",
    iv_hp = "HP",
    iv_cdr = "Cooldown Reduction"
}

local HELP_STAT = "Which stat do you want to maximize? {offense}/{specialattack}/{defense}/{vitality}/{hp}/{cdr}"
local REMIND_SLOT = "Make sure the Pokemon ball you want to upgrade is equipped in slot 8."

local function playerHasItem(cid, itemId, count)
    return getPlayerItemCount(cid, itemId) >= (count or 1)
end

local function removePlayerItem(cid, itemId, count)
    return doPlayerRemoveItem(cid, itemId, count or 1)
end

local function getBallOnSlot8(cid)
    local it = getPlayerSlotItem(cid, 8)
    if it and it.uid and it.uid > 0 then
        return it
    end
    return nil
end

local function setIv31(ballUid, key)
    doItemSetAttribute(ballUid, key, 31)
    doItemSetAttribute(ballUid, "iv_set", 1)
end

local function setAllIv31(ballUid)
    doItemSetAttribute(ballUid, "iv_off", 31)
    doItemSetAttribute(ballUid, "iv_spa", 31)
    doItemSetAttribute(ballUid, "iv_def", 31)
    doItemSetAttribute(ballUid, "iv_vit", 31)
    doItemSetAttribute(ballUid, "iv_hp", 31)
    doItemSetAttribute(ballUid, "iv_cdr", 31)
    doItemSetAttribute(ballUid, "iv_set", 1)
end

local states = {}

local function resetState(cid)
    states[cid] = nil
end

local function talk_about_bottlecap(cid)
    states[cid] = {
        mode = "single",
        step = "confirm"
    }
    npcsay(cid, "To maximize ONE IV to 31, you'll spend a Bottle Cap. " .. REMIND_SLOT ..
        " Do you want to continue? {yes}/{no}")
end

local function talk_about_goldencap(cid)
    states[cid] = {
        mode = "golden",
        step = "confirm"
    }
    npcsay(cid, "Golden Bottle Cap maximizes ALL IVs to 31. " .. REMIND_SLOT .. " Do you want to proceed? {yes}/{no}")
end

local function proceed_single_after_confirm(cid)
    local st = states[cid]
    if not st or st.mode ~= "single" then
        return
    end
    st.step = "choose"
    npcsay(cid, HELP_STAT)
end

local function finalize_single_confirm(cid, say)
    local st = states[cid]
    if not st or st.mode ~= "single" or st.step ~= "confirm_final" then
        return
    end

    if say == "yes" then
        if not playerHasItem(cid, BOTTLE_CAP_ID, 1) then
            npcsay(cid, "You don't have a Bottle Cap.")
            return resetState(cid)
        end
        local ball = getBallOnSlot8(cid)
        if not ball then
            npcsay(cid, "I can't find a Pokemon ball in slot 8.")
            return resetState(cid)
        end

        if removePlayerItem(cid, BOTTLE_CAP_ID, 1) then
            setIv31(ball.uid, st.chosenKey)
            npcsay(cid, "Done! " .. PRETTY[st.chosenKey] .. " is now 31.")
        else
            npcsay(cid, "Hmm, I couldn't take your Bottle Cap.")
        end
        return resetState(cid)
    else
        npcsay(cid, "No problem. Come back anytime.")
        return resetState(cid)
    end
end

local function finalize_golden_confirm(cid, say)
    local st = states[cid]
    if not st or st.mode ~= "golden" or st.step ~= "confirm" then
        return
    end

    if say == "yes" then
        if not playerHasItem(cid, GOLDEN_BOTTLE_CAP_ID, 1) then
            npcsay(cid, "You don't have a Golden Bottle Cap.")
            return resetState(cid)
        end
        local ball = getBallOnSlot8(cid)
        if not ball then
            npcsay(cid, "I can't find a Pokemon ball in slot 8.")
            return resetState(cid)
        end

        if removePlayerItem(cid, GOLDEN_BOTTLE_CAP_ID, 1) then
            setAllIv31(ball.uid)
            npcsay(cid, "Perfect! All IVs are now 31.")
        else
            npcsay(cid, "Hmm, I couldn't take your Golden Bottle Cap.")
        end
        return resetState(cid)
    else
        npcsay(cid, "Alright, maybe next time.")
        return resetState(cid)
    end
end

local function creatureSayCallback(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end
    local say = msg:lower()

    if say == "bottle cap" or say == "bottlecap" then
        talk_about_bottlecap(cid)
        return true
    end
    if say == "golden bottle cap" or say == "golden bottlecap" or say == "golden" then
        talk_about_goldencap(cid)
        return true
    end
    if say == "help" or say == "stat" or say == "stats" then
        npcsay(cid, "I can use {bottle cap} to max ONE IV, or {golden bottle cap} to max ALL IVs.")
        return true
    end

    local st = states[cid]

    if not st then
        return false
    end

    if say == "yes" or say == "no" then
        if st.mode == "single" then
            if st.step == "confirm" then
                if say == "yes" then
                    proceed_single_after_confirm(cid)
                else
                    npcsay(cid, "Okay, cancelled.")
                    resetState(cid)
                end
            elseif st.step == "confirm_final" then
                finalize_single_confirm(cid, say)
            end
            return true
        elseif st.mode == "golden" then
            if st.step == "confirm" then
                finalize_golden_confirm(cid, say)
            end
            return true
        end
    end

    if st.mode == "single" and st.step == "choose" then
        local key = STAT_ALIASES[say]
        if not key then
            npcsay(cid, "I didn't get it. " .. HELP_STAT)
            return true
        end
        st.chosenKey = key
        st.step = "confirm_final"
        npcsay(cid, "You chose " .. PRETTY[key] .. ". Spend 1 Bottle Cap to set it to 31? {yes}/{no}")
        return true
    end

    return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new())
