function onSay(cid, words, param)

    local typess = {
        [1] = "normal",
        [2] = "great",
        [3] = "super",
        [4] = "ultra"
    }

    if param == "" then
        doPlayerSendCancel(cid,
            'Command needs parameters. Usage:\n' .. 'New: "/cb [Pokemon Name], [max|31], [Nature], [boost], [Gender]"\n' ..
                'Old: "/cb [Pokemon Name], [boost], [Gender]"')
        return 0
    end

    local VALID_NATURES = {
        hardy = "Hardy",
        docile = "Docile",
        serious = "Serious",
        bashful = "Bashful",
        quirky = "Quirky",
        adamant = "Adamant",
        brave = "Brave",
        lonely = "Lonely",
        naughty = "Naughty",
        modest = "Modest",
        quiet = "Quiet",
        mild = "Mild",
        rash = "Rash",
        bold = "Bold",
        relaxed = "Relaxed",
        impish = "Impish",
        lax = "Lax",
        calm = "Calm",
        sassy = "Sassy",
        careful = "Careful",
        gentle = "Gentle",
        timid = "Timid",
        jolly = "Jolly",
        hasty = "Hasty",
        naive = "Naive"
    }

    local function normalizeNature(s)
        if not s or s == "" then
            return nil
        end
        s = s:gsub("^%s+", ""):gsub("%s+$", "")
        local canon = VALID_NATURES[string.lower(s)]
        return canon
    end

    local t = string.explode(param, ",")

    local name = ""
    if t[1] then
        local n = string.explode(t[1], " ")
        local str = string.sub(n[1], 1, 1)
        local sta = string.sub(n[1], 2, string.len(n[1]))
        name = "" .. string.upper(str) .. "" .. string.lower(sta) .. ""
        if n[2] then
            str = string.sub(n[2], 1, 1)
            sta = string.sub(n[2], 2, string.len(n[2]))
            name = name .. " " .. string.upper(str) .. "" .. string.lower(sta) .. ""
        end
        if not pokes[name] then
            doPlayerSendCancel(cid, "Sorry, a pokemon with the name " .. name .. " doesn't exists.")
            return true
        end
        print("" .. name .. " ball has been created by " .. getPlayerName(cid) .. ".")
    end

    local function trim(s)
        return s and s:gsub("^%s+", ""):gsub("%s+$", "") or s
    end
    local p2 = trim(t[2] or "")
    local p2lower = string.lower(p2 or "")

    local forcePerfectIVs = false
    local boostIdx, genderIdx, natureIdx

    if p2lower == "max" or p2lower == "maxiv" or p2lower == "perfect" or p2lower == "31" or p2lower == "all31" then
        forcePerfectIVs = true
        natureIdx = 3 
        boostIdx = 4
        genderIdx = 5
    else
        boostIdx = 2
        genderIdx = 3
        natureIdx = nil
    end

    local genders = {
        ["male"] = 4,
        ["female"] = 3,
        ["1"] = 4,
        ["0"] = 3
    }

    local genderParam = trim(t[genderIdx] or "")
    local gender = 0
    do
        local rate = newpokedex[name].gender
        if genderParam ~= "" then
            if genders[genderParam] then
                gender = genders[genderParam]
            else
                if rate == 0 then
                    gender = 3
                elseif rate == 1000 then
                    gender = 4
                elseif rate == -1 then
                    gender = 0
                elseif math.random(1, 1000) <= rate then
                    gender = 4
                else
                    gender = 3
                end
            end
        else
            if rate == 0 then
                gender = 3
            elseif rate == 1000 then
                gender = 4
            elseif rate == -1 then
                gender = 0
            elseif math.random(1, 1000) <= rate then
                gender = 4
            else
                gender = 3
            end
        end
    end

    local boost = 0
    local boostParam = trim(t[boostIdx] or "")
    if boostParam ~= "" and tonumber(boostParam) then
        local b = tonumber(boostParam)
        if b > 0 and b <= 50 then
            boost = b
        end
    end

    local chosenNature = nil
    if natureIdx then
        local natParam = trim(t[natureIdx] or "")
        if natParam ~= "" then
            local canon = normalizeNature(natParam)
            if not canon then
                doPlayerSendCancel(cid, 'Invalid Nature "' .. natParam ..
                    '". Valid: Hardy, Docile, Serious, Bashful, Quirky, Adamant, Brave, Lonely, Naughty, ' ..
                    'Modest, Quiet, Mild, Rash, Bold, Relaxed, Impish, Lax, Calm, Sassy, Careful, Gentle, ' ..
                    'Timid, Jolly, Hasty, Naive.')
                return true
            end
            chosenNature = canon
        end
    end

    local btype = typess[math.random(1, 4)]
    local mypoke = pokes[name]
    local happy = 255

    local item = doCreateItemEx(2219)
    doItemSetAttribute(item, "poke", name)
    doItemSetAttribute(item, "hp", 1)
    if boost > 0 then
        doItemSetAttribute(item, "boost", boost)
    end
    doItemSetAttribute(item, "happy", happy)
    doItemSetAttribute(item, "gender", gender)
    if name == "Shiny Hitmonchan" or name == "Hitmonchan" then
        doItemSetAttribute(item, "hands", 0)
    end
    doItemSetAttribute(item, "description", "Contains a " .. name .. ".")
    doItemSetAttribute(item, "fakedesc", "Contains a " .. name .. ".")

    if forcePerfectIVs then
        doItemSetAttribute(item, "iv_off", 31)
        doItemSetAttribute(item, "iv_spa", 31)
        doItemSetAttribute(item, "iv_def", 31)
        doItemSetAttribute(item, "iv_vit", 31)
        doItemSetAttribute(item, "iv_hp", 31)
        doItemSetAttribute(item, "iv_cdr", 31)
        doItemSetAttribute(item, "iv_set", 1)
    end

    if chosenNature then
        doItemSetAttribute(item, "nature", chosenNature)
    end

    doPlayerAddItemEx(cid, item, true)
    doTransformItem(item, pokeballs[btype].on)
    return 1
end
