local CDR_IV_PCT_PER_POINT = 0.0065

local function getIVsFromBall(ballUid)
    if not ballUid or ballUid <= 0 then return nil end
    local off = getItemAttribute(ballUid, "iv_off")
    local def = getItemAttribute(ballUid, "iv_def")
    local spa = getItemAttribute(ballUid, "iv_spa")
    local vit = getItemAttribute(ballUid, "iv_vit")
    local hp  = getItemAttribute(ballUid, "iv_hp")
    local cdr = getItemAttribute(ballUid, "iv_cdr")
    if off==nil and def==nil and spa==nil and vit==nil and hp==nil and cdr==nil then
        return nil
    end
    return {
        off = tonumber(off or 0),
        def = tonumber(def or 0),
        spa = tonumber(spa or 0),
        vit = tonumber(vit or 0),
        hp  = tonumber(hp  or 0),
        cdr = tonumber(cdr or 0),
    }
end

local function getHeldCdrBonus(tier)
    local t = {
        [113] = (type(XCooldownBonus1) == "number" and XCooldownBonus1) or 0,
        [79]  = (type(XCooldownBonus2) == "number" and XCooldownBonus2) or 0,
        [80]  = (type(XCooldownBonus3) == "number" and XCooldownBonus3) or 0,
        [81]  = (type(XCooldownBonus4) == "number" and XCooldownBonus4) or 0,
        [82]  = (type(XCooldownBonus5) == "number" and XCooldownBonus5) or 0,
        [83]  = (type(XCooldownBonus6) == "number" and XCooldownBonus6) or 0,
        [84]  = (type(XCooldownBonus7) == "number" and XCooldownBonus7) or 0,
    }
    return t[tier] or 0
end

local function formatPct(x) return string.format("%.1f%%", x * 100) end

local function getBallFromTarget(cid, target)
    if target and target.uid and target.uid > 0 and target.itemid and isPokeball(target.itemid) then
        if getItemAttribute(target.uid, "poke") then
            return target.uid, nil
        end
    end

    if target and target.uid and isCreature(target.uid) then
        if isSummon(target.uid) then
            local owner = getCreatureMaster(target.uid)
            if owner then
                local ball = getPlayerSlotItem(owner, 8)
                if ball and ball.uid > 0 and getItemAttribute(ball.uid, "poke") then
                    return ball.uid, owner
                end
            end
        elseif isPlayer(target.uid) then
            local ball = getPlayerSlotItem(target.uid, 8)
            if ball and ball.uid > 0 and getItemAttribute(ball.uid, "poke") then
                return ball.uid, target.uid
            end
        end
    end

    local myball = getPlayerSlotItem(cid, 8)
    if myball and myball.uid > 0 and getItemAttribute(myball.uid, "poke") then
        return myball.uid, cid
    end

    return nil, nil
end

function onUse(cid, item, fromPos, target, toPos)
    local ball, ownerCid = getBallFromTarget(cid, target)
    if not ball then
        doPlayerSendCancel(cid, "Use a IV Lens numa pokébola, num Pokémon invocado, ou segure sua pokébola no slot 8.")
        doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
        return true
    end

    local name = getItemAttribute(ball, "poke") or "Pokemon"
    local ivs  = getIVsFromBall(ball)

    if not ivs then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
            "IV Lens - "..name.."\nIVs ainda não foram definidos. Invoque este Pokémon pelo menos uma vez.")
        doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_GREEN)
        return true
    end

    local ivFrac   = (ivs.cdr or 0) * CDR_IV_PCT_PER_POINT
    local heldTier = tonumber(getItemAttribute(ball, "heldx") or 0)
    local heldFrac = getHeldCdrBonus(heldTier)

    local totalMult = tonumber(getItemAttribute(ball, "cdr_mult") or 0)
    local totalFrac
    if totalMult and totalMult > 0 then
        totalFrac = 1 - totalMult
    else
        totalFrac = 1 - ((1 - ivFrac) * (1 - heldFrac))
    end

    local ownerNote = ""
    if ownerCid and ownerCid ~= cid then
        ownerNote = " (de " .. getCreatureName(ownerCid) .. ")"
    end

    local lines = {
        "IV Lens - "..name..ownerNote,
        string.format("IVs: Off %d | Def %d | SpA %d | Vit %d | HP %d | CDR %d",
            ivs.off, ivs.def, ivs.spa, ivs.vit, ivs.hp, ivs.cdr),
        string.format("CDR por IV: %s",  formatPct(ivFrac)),
        string.format("CDR por HeldX: %s", formatPct(heldFrac)),
        string.format("CDR total (aprox.): %s", formatPct(totalFrac)),
    }

    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(lines, "\n"))
    doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_GREEN)
    return true
end
