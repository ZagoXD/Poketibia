local MIN_GROUP = 5

local function toggleCatchFlag(playerCid)
    local cur = getPlayerStorageValue(playerCid, CATCH100_STOR)
    local on = (cur ~= 1)
    setPlayerStorageValue(playerCid, CATCH100_STOR, on and 1 or -1)
    return on
end

function onSay(cid, words, param, channel)
    if getPlayerGroupId(cid) < MIN_GROUP then
        doPlayerSendCancel(cid, "Voce nao tem permissao para usar esse comando.")
        return true
    end

    param = tostring(param or ""):gsub("^%s+",""):gsub("%s+$","")

    if param == "" then
        local on = toggleCatchFlag(cid)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
            on and "[CATCH] 100% de catch ATIVADO para voce." or "[CATCH] 100% de catch DESATIVADO para voce.")
        return true
    end

    local target = getPlayerByNameWildcard(param)
    if not target or not isPlayer(target) then
        doPlayerSendCancel(cid, "Jogador nao encontrado ou offline.")
        return true
    end

    if getPlayerGroupId(target) > getPlayerGroupId(cid) then
        doPlayerSendCancel(cid, "Voce nao pode alterar o status de um grupo superior.")
        return true
    end

    local on = toggleCatchFlag(target)
    local who = getCreatureName(target)

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        (on and "[CATCH] ATIVADO" or "[CATCH] DESATIVADO") .. " 100% de catch para " .. who .. ".")

    doPlayerSendTextMessage(target, MESSAGE_STATUS_CONSOLE_BLUE,
        (on and "[CATCH] ATIVADO" or "[CATCH] DESATIVADO") .. " 100% de catch no seu personagem (por " .. getCreatureName(cid) .. ").")

    return true
end
