local win
local state = {
    name = "?",
    max = 6,
    moves = {},
    selected = {},
    order = {},
    lastActiveOrdered = {}
}

local suppressNextUi = false

local function clearTable(t)
    for k in pairs(t) do t[k] = nil end
end

local function countSelected()
    local n = 0
    for _ in pairs(state.selected) do n = n + 1 end
    return n
end

local function listsEqual(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

local function setInfoText()
    if not win then return end
    local info = win:recursiveGetChildById('info')
    info:setText(string.format('Selected: %d/%d', countSelected(), state.max))
    local title = win:recursiveGetChildById('title')
    title:setText('Moves - ' .. (state.name or '?'))
end

local function lineText(idx, m, checked)
    local mark = checked and '[X]' or '[ ]'
    return string.format('%s  #%02d - %s (lvl %d, cd %ds)', mark, idx, m.name, m.level or 0, m.cd or 0)
end

local function getIconPath(moveName)
    local base = "/modules/movesui/moves_icon/"
    local nameVariants = { moveName, moveName:gsub("%s+", "_"), moveName:gsub("%s+", "") }

    for _, n in ipairs(nameVariants) do
        local tries = { base .. n .. "_on.png", base .. n .. "_on.PNG" }
        for _, p in ipairs(tries) do
            if g_resources.fileExists(p) then
                return p
            end
        end
    end

    if g_resources.fileExists(base .. "unknown.png") then
        return base .. "unknown.png"
    end
    return "/images/ui/unknown"
end

local function setRowChecked(row, checked, idx, m)
    if not row then return end
    row.isChecked = checked and true or false
    local textWidget = row:recursiveGetChildById('text')
    if textWidget then
        textWidget:setText(lineText(idx, m, row.isChecked))
    end
    row:setBackgroundColor('#00000055')
end

local function rebuildList()
    if not win then return end

    local content = win:recursiveGetChildById('content')
    for _, child in ipairs(content:getChildren()) do child:destroy() end

    table.sort(state.order, function(a, b) return a < b end)

    for _, idx in ipairs(state.order) do
        local m = state.moves[idx]
        if m then
            local btn = g_ui.createWidget('MoveButton', content)
            btn.idx = idx
            btn.isChecked = state.selected[idx] and true or false

            btn:setText(lineText(idx, m, btn.isChecked))
            if btn.setImageSource then
                btn:setImageSource(getIconPath(m.name))
            elseif btn.setIcon then
                btn:setIcon(getIconPath(m.name))
            end

            btn:setBackgroundColor('#00000055')

            btn.onMouseRelease = function(_, _, mouseButton)
                if mouseButton ~= MouseLeftButton then return end

                local selCount = countSelected()
                if btn.isChecked then
                    btn.isChecked = false
                    state.selected[btn.idx] = nil
                else
                    if selCount >= state.max then return end
                    btn.isChecked = true
                    state.selected[btn.idx] = true
                end

                btn:setText(lineText(btn.idx, state.moves[btn.idx], btn.isChecked))
                btn:setBackgroundColor('#00000055')
                setInfoText()
            end
        end
    end

    setInfoText()
end

local function hide()
    if win then
        win:destroy()
        win = nil
    end
end

local function show()
    if not win then
        win = g_ui.displayUI('movesui', modules.game_interface.getRootPanel())

        local refresh     = win:recursiveGetChildById('refresh')
        local apply       = win:recursiveGetChildById('apply')
        local close       = win:recursiveGetChildById('close')
        local resetButton = win:recursiveGetChildById('resetButton')

        if refresh then
            refresh.onClick = function()
                clearTable(state.selected)
                table.sort(state.order, function(a, b) return a < b end)
                local count = 0
                for _, idx in ipairs(state.order) do
                    if state.moves[idx] then
                        state.selected[idx] = true
                        count = count + 1
                        if count >= state.max then break end
                    end
                end
                rebuildList()
            end
        end

        if apply then
            apply.onClick = function()
                local chosen, seen = {}, {}

                for _, idx in ipairs(state.lastActiveOrdered or {}) do
                    if state.selected[idx] then
                        table.insert(chosen, idx)
                        seen[idx] = true
                    end
                end

                table.sort(state.order, function(a, b) return a < b end)
                for _, idx in ipairs(state.order) do
                    if state.selected[idx] and not seen[idx] then
                        table.insert(chosen, idx)
                        seen[idx] = true
                    end
                end

                if listsEqual(chosen, state.lastActiveOrdered or {}) then
                    hide()
                    return
                end

                suppressNextUi = true
                if #chosen > 0 then
                    g_game.talk('!moves set ' .. table.concat(chosen, ' '))
                else
                    g_game.talk('!moves reset')
                end
                hide()
            end
        end

        if resetButton then
            resetButton.onClick = function()
                clearTable(state.selected)
                rebuildList()
            end
        end

        if close then
            close.onClick = function() hide() end
        end
    end

    win:show()
    win:raise()
    win:focus()
end

local function parsePayload(text)
    if not text or not text:find('%[MOVESUI%]') then
        return false
    end

    if suppressNextUi then
        suppressNextUi = false
        return false
    end

    clearTable(state.moves)
    clearTable(state.selected)
    clearTable(state.order)
    clearTable(state.lastActiveOrdered)

    local body = text:match('%[MOVESUI%]%s*(.+)')
    if not body then return false end

    local fields = {}
    for k, v in body:gmatch('([A-Z]+)%s*=%s*([^;]+)') do
        fields[k] = v
    end

    state.name = fields.NAME or '?'
    state.max = tonumber(fields.MAX or '') or 6
    if state.max < 1 then state.max = 1 end
    if state.max > 10 then state.max = 10 end

    local activeSet = {}
    if fields.ACTIVE then
        for n in fields.ACTIVE:gmatch('%d+') do
            local idx = tonumber(n)
            if idx then
                table.insert(state.lastActiveOrdered, idx)
                activeSet[idx] = true
            end
        end
    end

    if fields.ALL then
        for part in fields.ALL:gmatch('[^|]+') do
            local idx, name, lvl, cd = part:match('^(%d+):([^:]+):(%d+):(%d+)$')
            if idx and name then
                local i = tonumber(idx)
                state.moves[i] = {
                    idx = i,
                    name = name,
                    level = tonumber(lvl or '0') or 0,
                    cd = tonumber(cd or '0') or 0
                }
                table.insert(state.order, i)
                if activeSet[i] then
                    state.selected[i] = true
                end
            end
        end
    end

    return true
end

local function onTextMessage(mode, text)
    if parsePayload(text) then
        show()
        rebuildList()
        return true
    end
    if mode == MessageModes.Failure then
        if (text:find('12//,') and text:find('hide')) or text:lower():find('voce precisa ter seu pokemon invocado') then
            hide()
            return true
        end
    end
end

function init()
    connect(g_game, {
        onGameStart   = function() end,
        onGameEnd     = function() hide() end,
        onTextMessage = onTextMessage
    })
end

function terminate()
    disconnect(g_game, {
        onGameStart   = true,
        onGameEnd     = true,
        onTextMessage = onTextMessage
    })
    hide()
end
