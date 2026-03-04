local win
local btn
local ROW_HEIGHT = 92
local ROW_SPACING = 10
local state = {
    mode = 'all',
    offers = {},
    lastPayloadMode = nil
}
local ITEMS_PER_PAGE = 10

state.page = 1
state.totalPages = 1

local function clearChildren(w)
    if not w then
        return
    end
    for _, c in ipairs(w:getChildren()) do
        c:destroy()
    end
end

local function split(str, sep)
    sep = sep or "|"
    local t = {}
    str = tostring(str or "")
    if str == "" then
        return t
    end
    for part in str:gmatch("([^" .. sep .. "]+)") do
        table.insert(t, part)
    end
    return t
end

local function trim(s)
    return (tostring(s or "")):match("^%s*(.-)%s*$")
end

local function getCodeBuffer(text, code)
    local prefix = "&sco&," .. tostring(code) .. ","
    local pos = text:find(prefix, 1, true)
    if not pos then
        return nil
    end
    return text:sub(pos + #prefix)
end

local function resolveClientIdByName(name)
    if not name or name == "" then
        return nil
    end
    if getItemIdByName then
        local id = getItemIdByName(name, false)
        if id and id > 0 then
            return id
        end
    end
    if ItemType then
        local it = ItemType(name)
        if it and it.getId and it:getId() > 0 then
            return it:getId()
        end
    end
    return nil
end

local function setIcon(widget, clientId, name, count)
    if not widget or not widget.setItemId then
        return
    end
    local cid = tonumber(clientId) or resolveClientIdByName(name)
    if cid and cid > 0 then
        widget:setItemId(cid)
        if widget.setItemCount and count then
            widget:setItemCount(count)
        end
        widget:setVisible(true)
    else
        widget:setVisible(false)
    end
end

local function matchAllTermsInName(itemName, filter)
    itemName = (itemName or ""):lower()
    filter = (filter or ""):lower()
    if filter == "" then
        return true
    end
    for term in filter:gmatch("%S+") do
        if not itemName:find(term, 1, true) then
            return false
        end
    end
    return true
end

local function wireHoverRecursive(widget, frame)
    if not widget or not frame then
        return
    end
    widget.onHoverChange = function(_, hovered)
        frame:setImageSource(hovered and 'images/market_frame_hover.png' or 'images/market_frame.png')
    end
    for _, child in ipairs(widget:getChildren()) do
        wireHoverRecursive(child, frame)
    end
end

local function wireRowHover(w)
    local frame = w:recursiveGetChildById('rowFrame')
    if not frame then
        return
    end
    frame:setImageSource('images/market_frame.png')

    w.onHoverChange = function(_, h)
        frame:setImageSource(h and 'images/market_frame_hover.png' or 'images/market_frame.png')
    end
end

local function getFilteredOffers()
    local searchEdit = win and win:recursiveGetChildById('searchEdit')
    local filter = (searchEdit and searchEdit:getText() or "")
    if filter == "" then
        return state.offers
    end
    local out = {}
    for _, row in ipairs(state.offers) do
        if matchAllTermsInName(row.name, filter) then
            table.insert(out, row)
        end
    end
    return out
end

local function clampPage()
    if state.totalPages < 1 then
        state.totalPages = 1
    end
    if state.page < 1 then
        state.page = 1
    end
    if state.page > state.totalPages then
        state.page = state.totalPages
    end
end

local function updatePaginationUI()
    if not win then
        return
    end
    local prevBtn = win:recursiveGetChildById('pagePrev')
    local nextBtn = win:recursiveGetChildById('pageNext')
    local pageLbl = win:recursiveGetChildById('pageLabel')

    if pageLbl then
        pageLbl:setText(string.format("Page %d / %d", state.page, state.totalPages))
    end

    local hasPrev = state.page > 1
    local hasNext = state.page < state.totalPages

    if prevBtn then
        prevBtn:setOpacity(hasPrev and 1 or 0.35)
    end
    if nextBtn then
        nextBtn:setOpacity(hasNext and 1 or 0.35)
    end

end

local function rebuildList()
    if not win then
        return
    end
    local content = win:recursiveGetChildById('listContent')
    local scroll = win:recursiveGetChildById('listScroll')
    if not content then
        return
    end

    clearChildren(content)

    -- filtra e calcula páginas
    local filtered = getFilteredOffers()
    local total = #filtered
    state.totalPages = math.ceil(math.max(total, 1) / ITEMS_PER_PAGE)
    clampPage()

    local startIndex = (state.page - 1) * ITEMS_PER_PAGE + 1
    local endIndex = math.min(startIndex + ITEMS_PER_PAGE - 1, total)

    local created = 0
    for i = startIndex, endIndex do
        local row = filtered[i]
        if row then
            local w = g_ui.createWidget('OfferRow', content)
            w:setWidth(content:getWidth())
            wireRowHover(w)

            local frame = w:recursiveGetChildById('rowFrame')
            if frame then
                frame:setImageSource('images/market_frame.png')
                wireHoverRecursive(w, frame)
            end

            local sellerLbl = w:recursiveGetChildById('rowSeller')
            local sellIcon = w:recursiveGetChildById('sellIcon')
            local wantIcon = w:recursiveGetChildById('wantIcon')
            local rowText = w:recursiveGetChildById('rowText')
            local btn = w:recursiveGetChildById('actionBtn')
            local statusLbl = w:recursiveGetChildById('statusLbl')

            if sellerLbl then
                sellerLbl:setText(tostring(row.seller or "Unknown"))
            end
            if statusLbl then
                statusLbl:setVisible(false)
            end

            if rowText then
                local leftBit = string.format("%s x%d", row.name or "?", row.amount or 0)
                local rightBit = string.format("%dx %s", row.wantAmount or 0, row.wantName or "?")
                rowText:setText(leftBit .. " -- wants " .. rightBit)
            end

            setIcon(sellIcon, row.sellClientId, row.name, row.amount)
            setIcon(wantIcon, row.wantClientId, row.wantName, row.wantAmount)

            if state.mode == 'all' then
                if statusLbl then
                    statusLbl:setVisible(false)
                end
                if btn then
                    btn:setText("Buy")
                    btn:setEnabled(true)
                    btn.onClick = function()
                        if row.id then
                            g_game.talk("/market buy " .. row.id)
                            addEvent(function()
                                if state.mode == 'all' then
                                    g_game.talk("/market list")
                                end
                            end)
                        end
                    end
                end
            else
                if statusLbl then
                    statusLbl:setText(string.format("[%s]", row.status or "?"))
                    statusLbl:setVisible(true)
                end
                if btn then
                    if row.status == 'active' then
                        btn:setText("Cancel");
                        btn:setEnabled(true)
                        btn.onClick = function()
                            if row.id then
                                g_game.talk("/market cancel " .. row.id)
                                addEvent(function()
                                    if state.mode == 'my' then
                                        g_game.talk("/market my")
                                    end
                                end)
                            end
                        end
                    elseif row.status == 'sold' then
                        btn:setText("Sold");
                        btn:setEnabled(false)
                    else
                        btn:setText("-");
                        btn:setEnabled(false)
                    end
                end
            end

            created = created + 1
        end
    end

    if created == 0 then
        local empty = g_ui.createWidget('UILabel', content)
        empty:setText(tr('No offers to show'))
        empty:setColor('white')
        empty:setWidth(content:getWidth())
        empty:setHeight(54)
        if empty.setTextAlign then
            empty:setTextAlign(AlignCenter)
        end
    end

    -- altura do conteúdo só do que está na página
    local contentHeight
    if created == 0 then
        contentHeight = ROW_HEIGHT
    else
        contentHeight = created * (ROW_HEIGHT + ROW_SPACING) - ROW_SPACING
    end
    content:setHeight(contentHeight)

    if scroll then
        local vbar = scroll:getChildById('listVScroll')
        if vbar and vbar.setValue then
            vbar:setValue(0)
        end
    end

    updatePaginationUI()
end

local function updateTabButtons()
    if not win then
        return
    end
    local tabAll = win:recursiveGetChildById('tabAll')
    local tabMy = win:recursiveGetChildById('tabMy')
    local claim = win:recursiveGetChildById('claimAllBtn')

    if state.mode == 'all' then
        if tabAll then
            tabAll:setEnabled(false)
        end
        if tabMy then
            tabMy:setEnabled(true)
        end
        if claim then
            claim:setVisible(false)
        end
    else
        if tabAll then
            tabAll:setEnabled(true)
        end
        if tabMy then
            tabMy:setEnabled(false)
        end
        if claim then
            claim:setVisible(true)
        end
    end
end

local function requestList()
    if state.mode == 'all' then
        g_game.talk("/market list")
    else
        g_game.talk("/market my")
    end
end

local function onSearchChange()
    state.page = 1
    rebuildList()
end

local function parseMarketPayload(payload)
    local rows = split(payload, "|")
    local parsed = {}

    for _, r in ipairs(rows) do
        if r ~= "" then
            local cols = split(r, ";")
            local c = #cols

            if c >= 9 then
                local id = tonumber(cols[1] or "")
                local name = cols[2]
                local amount = tonumber(cols[3] or "")
                if state.lastPayloadMode == 'my' then
                    local status = cols[4]
                    local wantAmt = tonumber(cols[5] or "")
                    local wantName = cols[6]
                    local seller = cols[7]
                    local sellCid = tonumber(cols[8] or "0")
                    local wantCid = tonumber(cols[9] or "0")
                    if id and name and amount then
                        table.insert(parsed, {
                            id = id,
                            name = name,
                            amount = amount,
                            status = status,
                            wantAmount = wantAmt,
                            wantName = wantName,
                            seller = seller,
                            sellClientId = sellCid,
                            wantClientId = wantCid
                        })
                    end
                else
                    local wantAmt = tonumber(cols[4] or "")
                    local wantName = cols[5]
                    local seller = cols[6]
                    local sellCid = tonumber(cols[7] or "0")
                    local wantCid = tonumber(cols[8] or "0")
                    if id and name and amount then
                        table.insert(parsed, {
                            id = id,
                            name = name,
                            amount = amount,
                            wantAmount = wantAmt,
                            wantName = wantName,
                            seller = seller,
                            sellClientId = sellCid,
                            wantClientId = wantCid
                        })
                    end
                end

            elseif c == 8 then
                local id = tonumber(cols[1] or "")
                local name = cols[2]
                local amount = tonumber(cols[3] or "")
                local wantAmt = tonumber(cols[4] or "")
                local wantName = cols[5]
                local seller = cols[6]
                local sellCid = tonumber(cols[7] or "0")
                local wantCid = tonumber(cols[8] or "0")
                if id and name and amount then
                    table.insert(parsed, {
                        id = id,
                        name = name,
                        amount = amount,
                        wantAmount = wantAmt,
                        wantName = wantName,
                        seller = seller,
                        sellClientId = sellCid,
                        wantClientId = wantCid
                    })
                end

            elseif c == 7 and state.lastPayloadMode == 'my' then
                local id = tonumber(cols[1] or "")
                local name = cols[2]
                local amount = tonumber(cols[3] or "")
                local status = cols[4]
                local wantAmt = tonumber(cols[5] or "")
                local wantName = cols[6]
                local seller = cols[7]
                if id and name and amount then
                    table.insert(parsed, {
                        id = id,
                        name = name,
                        amount = amount,
                        status = status,
                        wantAmount = wantAmt,
                        wantName = wantName,
                        seller = seller
                    })
                end

            elseif c == 6 and state.lastPayloadMode == 'all' then
                local id = tonumber(cols[1] or "")
                local name = cols[2]
                local amount = tonumber(cols[3] or "")
                local wantAmt = tonumber(cols[4] or "")
                local wantName = cols[5]
                local seller = cols[6]
                if id and name and amount then
                    table.insert(parsed, {
                        id = id,
                        name = name,
                        amount = amount,
                        wantAmount = wantAmt,
                        wantName = wantName,
                        seller = seller
                    })
                end

            elseif c == 5 then
                local id = tonumber(cols[1] or "")
                local name = cols[2]
                local amount = tonumber(cols[3] or "")
                local wantAmt = tonumber(cols[4] or "")
                local wantName = cols[5]
                if id and name and amount then
                    table.insert(parsed, {
                        id = id,
                        name = name,
                        amount = amount,
                        wantAmount = wantAmt,
                        wantName = wantName,
                        seller = "Unknown"
                    })
                end
            end
        end
    end

    state.offers = parsed
    state.page = 1
    rebuildList()
end

local function show()
    if not win then
        win = g_ui.displayUI('marketui', modules.game_interface.getRootPanel())
        local scroll = win:recursiveGetChildById('listScroll')
        local vbar = win:recursiveGetChildById('listVScroll')
        if scroll and vbar and scroll.setVerticalScrollBar then
            scroll:setVerticalScrollBar(vbar)
        end
        local createBtn = win:recursiveGetChildById('createBtn')
        local closeBtn = win:recursiveGetChildById('closeBtn')
        local sellName = win:recursiveGetChildById('sellName')
        local sellAmt = win:recursiveGetChildById('sellAmt')
        local wantName = win:recursiveGetChildById('wantName')
        local wantAmt = win:recursiveGetChildById('wantAmt')

        if createBtn then
            createBtn.onClick = function()
                local sName = trim(sellName:getText())
                local sAmt = trim(sellAmt:getText())
                local wName = trim(wantName:getText())
                local wAmt = trim(wantAmt:getText())

                if sName == "" or sAmt == "" or wName == "" or wAmt == "" then
                    displayInfoBox('Market', tr('Preencha todos os campos.'))
                    return
                end
                g_game.talk(string.format("/market create %s|%s|%s|%s", sName, sAmt, wName, wAmt))
                addEvent(function()
                    if state.mode == 'my' then
                        g_game.talk("/market my")
                    else
                        g_game.talk("/market list")
                    end
                end)
            end
        end

        if closeBtn then
            closeBtn.onClick = function()
                win:destroy()
                win = nil
            end
        end

        local tabAll = win:recursiveGetChildById('tabAll')
        local tabMy = win:recursiveGetChildById('tabMy')
        local refreshBtn = win:recursiveGetChildById('refreshBtn')
        local claimAll = win:recursiveGetChildById('claimAllBtn')
        local searchEdit = win:recursiveGetChildById('searchEdit')
        local prevBtn = win:recursiveGetChildById('pagePrev')
        local nextBtn = win:recursiveGetChildById('pageNext')

        if prevBtn then
            prevBtn.onMouseRelease = function(widget, mousePos, button)
                if button == MouseLeftButton and state.page > 1 then
                    state.page = state.page - 1
                    rebuildList()
                    return true
                end
            end
        end

        if nextBtn then
            nextBtn.onMouseRelease = function(widget, mousePos, button)
                if button == MouseLeftButton and state.page < state.totalPages then
                    state.page = state.page + 1
                    rebuildList()
                    return true
                end
            end
        end

        if tabAll then
            tabAll.onClick = function()
                state.mode = 'all'
                state.lastPayloadMode = 'all'
                updateTabButtons()
                requestList()
            end
        end
        if tabMy then
            tabMy.onClick = function()
                state.mode = 'my'
                state.lastPayloadMode = 'my'
                updateTabButtons()
                requestList()
            end
        end
        if refreshBtn then
            refreshBtn.onClick = function()
                requestList()
            end
        end
        if claimAll then
            claimAll.onClick = function()
                g_game.talk("/market claim")
                addEvent(function()
                    if state.mode == 'my' then
                        g_game.talk("/market my")
                    end
                end)
            end
        end
        if searchEdit then
            searchEdit.onTextChange = onSearchChange
        end
    end

    updateTabButtons()
    win:show()
    win:raise()
    win:focus()
    requestList()
end

local function hide()
    if win then
        win:destroy()
        win = nil
    end
end

local function toggle()
    if win and win:isVisible() then
        hide()
    else
        show()
    end
end

local function onTextMessage(mode, text)
    if type(text) ~= 'string' then
        return
    end
    local payload = getCodeBuffer(text, 164)
    if not payload then
        return
    end
    if not win then
        show()
    end

    if payload == "" then
        state.offers = {}
        rebuildList()
        return true
    end

    if not state.lastPayloadMode or state.lastPayloadMode == 'unknown' then
        local firstRow = payload:match("([^|]+)")
        if firstRow then
            local c = 0;
            for _ in firstRow:gmatch("[^;]+") do
                c = c + 1
            end
            if c >= 9 then
                state.lastPayloadMode = 'my'
            elseif c >= 8 then
                state.lastPayloadMode = 'all'
            else
                state.lastPayloadMode = (c >= 7) and 'my' or 'all'
            end
        end
    end

    parseMarketPayload(payload)
    return true
end

function init()
    connect(g_game, {
        onGameEnd = hide,
        onTextMessage = onTextMessage
    }, true)
end

function terminate()
    disconnect(g_game, {
        onGameEnd = hide,
        onTextMessage = onTextMessage
    })
    hide()
end
