function onSay(cid, words, param, channel)
    local p = (param or ""):lower()
    if p == "register" then

        if getGlobalStorageValue(22549) ~= -1 then
            local s = string.explode(getGlobalStorageValue(22549), ",")

            for i = 1, #s do
                if s[i] ~= "" and getCreatureName(cid) == s[i] then
                    doPlayerSendTextMessage(cid, 20, "Voce ja esta registrado na Golden Arena!")
                    return true
                end
            end
            if #s > 15 then
                doPlayerSendTextMessage(cid, 20, "Desculpe, atingimos o limite de jogadores para a Golden Arena!")
                return true
            end
        end

        doPlayerSendTextMessage(cid, 20, "Voce foi registrado na Golden Arena!")
        if getGlobalStorageValue(22549) == -1 then
            setGlobalStorageValue(22549, getCreatureName(cid) .. ",")
        else
            setGlobalStorageValue(22549, getGlobalStorageValue(22549) .. getCreatureName(cid) .. ",")
        end

        return true
    end
    if p == "horarios" then
        local hours = ""
        local c = 0

        for i = 1, #horas do
            hours = hours .. ((i == #horas and c ~= 0) and " e " or (i ~= 1 and ", " or "")) .. horas[i]
            c = c + 1
        end

        hours = hours .. " horas."
        doPlayerSendTextMessage(cid, 20, "A Golden Arena acontece as " .. hours)

        local timeDiff = showTimeDiff(nextHorario(cid))
        doPlayerSendTextMessage(cid, 20, "Proximo evento em " .. timeDiff .. ".")
        return true
    end
    if p == "rank" or p == "ranking" then
        doPlayerPopupFYI(cid, getRankGolden())
        return true
    end
    doPlayerSendTextMessage(cid, 20, "Comandos: " .. words .. " register | horarios | rank")
    return true
end
