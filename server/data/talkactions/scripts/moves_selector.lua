local DEFAULT_MAX = 6
local HARD_CAP = 10
local UI_SLOTS = 12

local CHANGE_COOLDOWN = 5 * 60
local ATTR_NEXT_CHANGE = "moves_next_change"

local TMC = dofile('data/lib/tm/tm_core.lua')

local function now()
    return os.time()
end

local function remainingStr(seconds)
    if seconds < 0 then
        seconds = 0
    end
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%dmin %ds", m, s)
end

local function canChangeMoves(ball)
    if not ball or ball.uid <= 0 then
        return false, CHANGE_COOLDOWN
    end
    local nxt = tonumber(getItemAttribute(ball.uid, ATTR_NEXT_CHANGE) or 0) or 0
    local t = now()
    if t >= nxt then
        return true, 0
    else
        return false, (nxt - t)
    end
end

local function armChangeCooldown(ball)
    if ball and ball.uid > 0 then
        doItemSetAttribute(ball.uid, ATTR_NEXT_CHANGE, now() + CHANGE_COOLDOWN)
    end
end

local function msg(cid, text)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function parseActiveMovesAttr(raw)
    local seen, out = {}, {}
    if not raw or raw == "" then
        return out
    end
    for n in tostring(raw):gmatch("%d+") do
        local i = tonumber(n)
        if i and i >= 1 and i <= 12 and not seen[i] then
            seen[i] = true
            table.insert(out, i)
        end
    end
    return out
end

local function listToCsv(t)
    local out = {}
    for i, v in ipairs(t) do
        out[i] = tostring(v)
    end
    return table.concat(out, ",")
end

local function getMovesTableForSummon(summon, ball)
    if not summon then
        return nil
    end
    local name
    if isTransformed and isTransformed(summon) then
        name = getPlayerStorageValue(summon, 1010)
    else
        name = getCreatureName(summon)
    end
    return TMC.buildEffectiveMovesFor(name, ball)
end

local function getMaxActiveForBall(ball)
    local m = ball and ball.uid > 0 and tonumber(getItemAttribute(ball.uid, "max_active_moves")) or nil
    if not m or m < 1 then
        m = DEFAULT_MAX
    end
    if m > HARD_CAP then
        m = HARD_CAP
    end
    return m
end

local function normalizeActiveListForMoves(moves, list, maxActive)
    local ok, seen, out = {}, {}, {}
    if not moves then
        return out
    end
    for i = 1, 12 do
        if getNewMoveTable(moves, i) then
            ok[i] = true
        end
    end
    for _, idx in ipairs(list) do
        if ok[idx] and not seen[idx] then
            seen[idx] = true
            table.insert(out, idx)
            if #out >= maxActive then
                break
            end
        end
    end
    return out
end

local function autoPickFirstMoves(moves, maxActive)
    local picked = {}
    if not moves then
        return picked
    end
    for i = 1, 12 do
        if getNewMoveTable(moves, i) then
            table.insert(picked, i)
            if #picked >= maxActive then
                break
            end
        end
    end
    return picked
end

local function hasValue(t, x)
    for i = 1, #t do
        if t[i] == x then
            return true
        end
    end
    return false
end

local function removeValue(t, x)
    for i = #t, 1, -1 do
        if t[i] == x then
            table.remove(t, i)
        end
    end
end

local function writeActiveAndRefresh(cid, ballUid, active)
    doItemSetAttribute(ballUid, "active_moves", listToCsv(active))
    for i = 1, 12 do
        doItemEraseAttribute(ballUid, "move" .. i)
        doItemEraseAttribute(ballUid, "cm_move" .. i)
    end
    if doUpdateMoves then
        doUpdateMoves(cid)
    end
    if doUpdateCooldowns then
        doUpdateCooldowns(cid)
    end
end

local function renderListText(moves, active, maxActive)
    local lines = {}
    table.insert(lines, string.format("Active (%d/%d):", #active, maxActive))
    if #active == 0 then
        table.insert(lines, "  - none -")
    else
        for slot = 1, #active do
            local idx = active[slot]
            local m = getNewMoveTable(moves, idx)
            if m then
                table.insert(lines, string.format("  [%d] #%02d - %s (lvl %d, cd %ds)", slot, idx, m.name, m.level or 0,
                    m.cd or 0))
            end
        end
    end
    table.insert(lines, "")
    table.insert(lines, "All moves available:")
    for i = 1, 12 do
        local m = getNewMoveTable(moves, i)
        if m then
            local mark = hasValue(active, i) and "[X]" or "[ ]"
            table.insert(lines,
                string.format("  %s #%02d - %s (lvl %d, cd %ds)", mark, i, m.name, m.level or 0, m.cd or 0))
        end
    end
    table.insert(lines, "")
    table.insert(lines, "Commands:")
    table.insert(lines, "  !moves list")
    table.insert(lines, "  !moves add <idx>          (ex: !moves add 3)")
    table.insert(lines, "  !moves rem <idx>          (ex: !moves rem 3)  aliases: remove/del")
    table.insert(lines, "  !moves set <i1> <i2> ...  (ex: !moves set 1 3 5 7 9 11)")
    table.insert(lines, "  !moves reset              (alias: clear)")
    table.insert(lines, "")
    table.insert(lines, "Obs.: indices sao de 1..12 conforme o config desse pokemon/forma.")
    return table.concat(lines, "\n")
end

local function sanitizeName(s)
    return tostring(s or ""):gsub("[|:;]", " ")
end

local function sendMovesUiPayload(cid, summon, moves, active, maxActive)
    local name = getCreatureName(summon)
    local activeCsv = listToCsv(active)

    local parts = {}
    for i = 1, 12 do
        local mt = getNewMoveTable(moves, i)
        if mt then
            local nm = sanitizeName(mt.name)
            local lv = tonumber(mt.level or 0) or 0
            local cd = tonumber(mt.cd or 0) or 0
            table.insert(parts, string.format("%d:%s:%d:%d", i, nm, lv, cd))
        end
    end
    local all = table.concat(parts, "|")

    local payload = "[DMEM_HIDE]" ..
        string.format("[MOVESUI] NAME=%s;MAX=%d;ACTIVE=%s;ALL=%s",
                      sanitizeName(name), maxActive, activeCsv, all)

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, payload)
end


function onSay(cid, words, param)
    if not isCreature(cid) then
        return true
    end

    local summon = getCreatureSummons(cid)[1]
    if not summon then
        msg(cid, "Voce precisa ter seu Pokemon invocado.")
        return true
    end

    local ball = getPlayerSlotItem(cid, 8)
    local moves = getMovesTableForSummon(summon, ball)
    if not moves then
        msg(cid, "Nao foi possivel carregar a lista de moves.")
        return true
    end

    if not ball or ball.uid <= 0 then
        msg(cid, "Coloque a pokebola no slot 8 (ball slot).")
        return true
    end

    local maxActive = getMaxActiveForBall(ball)
    local raw = getItemAttribute(ball.uid, "active_moves")
    local parsed = parseActiveMovesAttr(raw)
    local active = normalizeActiveListForMoves(moves, parsed, maxActive)
    if #active < maxActive then
        local fillers = autoPickFirstMoves(moves, maxActive)
        local seen = {}
        for _, v in ipairs(active) do
            seen[v] = true
        end
        for _, v in ipairs(fillers) do
            if not seen[v] then
                table.insert(active, v)
                seen[v] = true
                if #active >= maxActive then
                    break
                end
            end
        end
    end

    doItemSetAttribute(ball.uid, "active_moves", listToCsv(active))

    param = (param or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    if param == "ui" or param == "window" or param == "janela" then
        local ok, left = canChangeMoves(ball)
        if not ok then
            msg(cid, "Voce so podera alterar os moves desse pokemon em " .. remainingStr(left) .. ".")
            return true
        end
        sendMovesUiPayload(cid, summon, moves, active, maxActive)
        return true
    end

    if param == "" or param == "list" then
        msg(cid, renderListText(moves, active, maxActive))
        return true
    end

    if param == "help" then
        msg(cid, "Use: !moves list | add <idx> | rem <idx> | set <i1> <i2> ... | reset | ui")
        return true
    end

    local args = {}
    for tok in param:gmatch("%S+") do
        table.insert(args, tok)
    end
    local cmd = args[1]

    if cmd == "reset" or cmd == "clear" then
        if #active == 0 then
            msg(cid, "Selecao ja esta vazia.")
            sendMovesUiPayload(cid, summon, moves, active, maxActive)
            return true
        end

        local ok, left = canChangeMoves(ball)
        if not ok then
            msg(cid, "Voce so podera alterar os moves em " .. remainingStr(left) .. ".")
            return true
        end

        active = {}
        writeActiveAndRefresh(cid, ball.uid, active)
        armChangeCooldown(ball)

        msg(cid, "Selecao limpa.")
        msg(cid, renderListText(moves, active, maxActive))
        sendMovesUiPayload(cid, summon, moves, active, maxActive)
        return true
    end

    if cmd == "add" and tonumber(args[2]) then
        local idx = tonumber(args[2])
        local m = getNewMoveTable(moves, idx)
        if not m then
            msg(cid, "Indice invalido para este pokemon/forma.")
            return true
        end
        if hasValue(active, idx) then
            msg(cid, "Esse move (#" .. idx .. ") ja esta selecionado.")
            return true
        end
        if #active >= maxActive then
            msg(cid, "Voce ja possui " .. maxActive .. " moves ativos. Use !moves rem <idx> ou !moves set ...")
            return true
        end

        local ok, left = canChangeMoves(ball)
        if not ok then
            msg(cid, "Voce so podera alterar os moves em " .. remainingStr(left) .. ".")
            return true
        end

        table.insert(active, idx)
        writeActiveAndRefresh(cid, ball.uid, active)
        armChangeCooldown(ball)

        msg(cid, "Adicionado: #" .. string.format("%02d", idx) .. " (" .. m.name .. ").")
        msg(cid, renderListText(moves, active, maxActive))
        sendMovesUiPayload(cid, summon, moves, active, maxActive)
        return true
    end

    if (cmd == "rem" or cmd == "remove" or cmd == "del") and tonumber(args[2]) then
        local idx = tonumber(args[2])
        if not hasValue(active, idx) then
            msg(cid, "Esse move (#" .. idx .. ") nao esta na selecao.")
            return true
        end

        local ok, left = canChangeMoves(ball)
        if not ok then
            msg(cid, "Voce so podera alterar os moves em " .. remainingStr(left) .. ".")
            return true
        end

        removeValue(active, idx)
        writeActiveAndRefresh(cid, ball.uid, active)
        armChangeCooldown(ball)

        msg(cid, "Removido: #" .. string.format("%02d", idx) .. ".")
        msg(cid, renderListText(moves, active, maxActive))
        sendMovesUiPayload(cid, summon, moves, active, maxActive)
        return true
    end

    if cmd == "set" and #args >= 2 then
        local wanted, seen = {}, {}
        for i = 2, #args do
            local idx = tonumber(args[i])
            if idx and idx >= 1 and idx <= 12 and not seen[idx] then
                local m = getNewMoveTable(moves, idx)
                if m then
                    table.insert(wanted, idx)
                    seen[idx] = true
                    if #wanted >= maxActive then
                        break
                    end
                end
            end
        end
        if #wanted == 0 then
            msg(cid, "Nenhum indice valido informado. Ex.: !moves set 1 3 5 7")
            return true
        end

        local same = (#wanted == #active)
        if same then
            for i = 1, #wanted do
                if wanted[i] ~= active[i] then
                    same = false
                    break
                end
            end
        end

        if not same then
            local ok, left = canChangeMoves(ball)
            if not ok then
                msg(cid, "Voce so podera alterar os moves em " .. remainingStr(left) .. ".")
                return true
            end
            writeActiveAndRefresh(cid, ball.uid, wanted)
            armChangeCooldown(ball)
            sendMovesUiPayload(cid, summon, moves, wanted, maxActive)
        else
            msg(cid, "Nenhuma alteracao nos moves.")
            sendMovesUiPayload(cid, summon, moves, active, maxActive)
        end
        return true
    end

    msg(cid, "Comando invalido. Use !moves help")
    return true
end
