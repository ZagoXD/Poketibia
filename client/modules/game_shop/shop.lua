local CLIENT_CLAN_COST = 50
function refreshEmeralds()
  if playerEmeralds and g_game.isOnline() then
    playerEmeralds:setText(tostring(g_game.getLocalPlayer():getItemsCount(3032)))
  end
end
local BUY_POINTS_URL = "pokenathso.com.br/buypoints"
local function openBuyPage()
  if g_platform and g_platform.openUrl then
    g_platform.openUrl(BUY_POINTS_URL)
  else
    displayInfoBox('Diamond Shop', "Abra no navegador:\n" .. BUY_POINTS_URL)
  end
end
marketOffers = { -- Name/Description/Image/Cost/Promotion
[1] = {'Vip', '30 Days', 'vip', 10, false, 'Vip30'},
[2] = {'Vip', '60 Days', 'vip', 18, false, 'Vip60'},
[3] = {'Vip', '90 Days', 'vip', 25, false, 'Vip90'},
[4] = {'Gender', 'Change Sex', 'changegender', 5, false, 'Sexy'},
[5] = {'Pokemon', 'Ditto', 'ditto', 15, false, 'Ditto'},
[6] = {'Shiny Charm', 'Shiny Charm (3d)', 'shinycharm', 17, false, 'Charm3'},
[7] = { 'Blank TM', 'Convert into any TM', 'blanktm', 20, false, 'BlankTM' },
[8] = { 'Bottle Cap', 'One IV to 31', 'bottlecap', 30, false, 'BottleCap' },   
[9] = { 'Golden Bottle Cap', 'All IVs to 31', 'goldenbottlecap', 75, false, 'GoldCap' },
[10] = { 'Bike', 'Move speed boost', 'bike', 5, false, 'Bike' },
[11] = { 'Yellow Robot', 'Move speed and HP boost', 'yrobot', 10, false, 'YellowRobot' },
[12] = { 'Move Increaser', 'Increase moves amount', 'moveincreaser', 15, false, 'MoveInc' }, 
[13] = { 'Prize Box', 'Generic Held Prize Box', 'genericheld', 28, false, 'BoxHeld' }, 
[14] = { 'Prize Box', 'Type Held Prize Box', 'typeheld', 28, false, 'BoxType' }, 
[15] = { 'Prize Box', 'Mega Stone Prize Box', 'megabox', 60, false, 'BoxMega' }, 
[16] = { 'Prize Box', 'Shiny Pokemon Box', 'shbox', 50, false, 'ShBox' }, 
[17] = { 'Shiny Dust', 'Evolve Your Shiny', 'dust', 3, false, 'sdust' }, 
[18] = { 'Boost Stone', 'Boost your pokemon', 'Boost Stone', 1, false, 'boost' }, 
[19] = { 'Exp Boost', 'Boost your Exp Gain', 'xpboost', 5, false, 'xpboost' }, 
[20] = {'Mega Charm', 'Mega Charm (3d)', 'megacharm', 30, false, 'Mega3'},
}

outfitsOffers = { -- Name/Description/Type/Head/Body/Legs/Feet/Cost/Promotion
--[[[1] = {'Slash', 'Male', 1441, 0, 114, 94, 114, 10, false, 'outfitslash'},
[2] = {'PlayBoy', 'Female', 1442, 0, 0, 114, 94, 10, false, 'outfitplayboy'},
[3] = {'Vinganca', 'Male', 1443, 0, 0, 114, 94, 10, false, 'outfitvinganca'},
[4] = {'House', 'Male', 1444, 0, 0, 114, 94, 10, false, 'outfithouse'},
[5] = {'Veteran Trainer', 'Male', 1465, 0, 0, 114, 94, 15, false, 'outfitveteran'},
[6] = {'Veteran Trainer', 'Female', 1466, 0, 0, 114, 94, 15, false, 'outfitveteran'},
[7] = {'Assassin', 'Female', 1469, 0, 0, 114, 94, 15, false, 'outfitassasin'},
[8] = {'Assassin', 'Male', 1470, 0, 0, 114, 94, 15, false, 'outfitassasin'},
[9] = {'Duelist', 'Male', 1671, 0, 0, 114, 94, 10, false, 'outfitduelist'},
[10] = {'Duelist', 'Female', 1672, 0, 0, 114, 94, 10, false, 'outfitduelist'},
[11] = {'Rabbitt', 'Female', 1679, 0, 0, 114, 94, 10, false, 'outfitrabbitt'},
[12] = {'Rabbitt', 'Male', 1680, 0, 0, 114, 94, 10, false, 'outfitrabbitt'},
[13] = {'Iron Man', 'Male', 1675, 0, 0, 114, 94, 20, false, 'outfitiron'},
[14] = {'Fantasia', 'Female', 2711, 0, 0, 114, 94, 20, false, 'outfitfantasia'},
[15] = {'Fantasia', 'Male', 2710, 0, 0, 114, 94, 20, false, 'outfitfantasia'},
[16] = {'Jack', 'Male', 2727, 0, 0, 114, 94, 20, false, 'outfithallowen'},
[17] = {'Noiva Cadaver', 'Female', 2728, 0, 0, 114, 94, 20, false, 'outfithallowen'},
[18] = {'Duende', 'Male', 2742, 0, 0, 114, 94, 20, false, 'outfitnatal'},
[19] = {'Duende', 'Female', 2743, 0, 0, 114, 94, 20, false, 'outfitnatal'},]]--
}

-- addonsOffers = {
-- }

clansOffers = {
[1] = {'Clan', 'Gardestrike', 'gardestrike', false},
-- [2] = {'Clan', 'Ironhard', 'ironhard', false},
[2] = {'Clan', 'Malefic', 'malefic', false},
[3] = {'Clan', 'Naturia', 'naturia', false},
[4] = {'Clan', 'Orebound', 'orebound', false},
[5] = {'Clan', 'Psycraft', 'psycraft', false},
[6] = {'Clan', 'Raibolt', 'raibolt', false},
[7] = {'Clan', 'Seavell', 'seavell', false},
[8] = {'Clan', 'Volcanic', 'volcanic', false},
[9] = {'Clan', 'Wingeon', 'wingeon', false},
}

showEvent = nil
hideEvent = nil
clanWindow = nil

function init()
  connect(g_game, { onGameEnd = hide })
  connect(g_game, 'onTextMessage', onConfirmBought)

  shopWindow = g_ui.displayUI('shop', modules.game_interface.getRootPanel())
  shopButton = modules.client_topmenu.addRightGameButton('shopButton', tr('Diamond Shop'), '/images/topbuttons/emerald_shop', toggle)
  shopButton:setWidth(36)
  offerSearch = shopWindow:recursiveGetChildById('searchText')
  shopWindow:hide()

  playerEmeralds = shopWindow:recursiveGetChildById('emeralds')
  connect(g_game, { onGameStart = function()
    if shopWindow:isVisible() then refreshEmeralds() end
  end })

  shopTabBar = shopWindow:recursiveGetChildById('shopTabBar')
  shopTabBar:setContentWidget(shopWindow:recursiveGetChildById('shopTabContent'))
  shopTabBar.onTabChange = onTabChange

  marketPanel = g_ui.loadUI('market')
  shopTabBar:addTab('', marketPanel, '/images/game/shop/market')

  outfitsPanel = g_ui.loadUI('outfits')
  shopTabBar:addTab('', outfitsPanel, '/images/game/shop/outfits')

  -- addonsPanel = g_ui.loadUI('addons')
  -- shopTabBar:addTab('', addonsPanel, '/images/game/shop/addons')

  clansPanel = g_ui.loadUI('clans')
  shopTabBar:addTab('', clansPanel, '/images/game/shop/clans')

  shopTabBar:addButton('', openBuyPage, '/images/game/shop/buy_diamonds')
end

function terminate()
  disconnect(g_game, { onGameEnd = hide })
  disconnect(g_game, 'onTextMessage', onConfirmBought)

  shopWindow:destroy()
end

function show()
  g_effects.cancelFade(shopWindow)
  removeEvent(hideEvent)
  if not showEvent then
    showEvent = addEvent(function() g_effects.fadeIn(shopWindow, 250) end)
  end
  shopButton:setOn(true)
  shopWindow:raise()
  shopWindow:focus()
  shopWindow:show()
  refreshEmeralds() 
  setOffers(marketPanel)
  setOffers(outfitsPanel)
  -- setOffers(addonsPanel)
  setOffers(clansPanel)
end

function hide()
  shopButton:setOn(false)
  hideEvent = scheduleEvent(function() shopWindow:hide() end, 250)
  addEvent(function() g_effects.fadeOut(shopWindow, 250) end)
  showEvent = nil
end

function toggle()
  if shopButton:isOn() then
    shopButton:setOn(false)
    hide()
  else
    shopButton:setOn(true)
    show()
  end
end

function getCodeBuffer(mode, code, text)
  if mode == MessageModes.Failure then 
    if string.find(text, '&sco&,' .. tostring(code)) then
      return text:explode(',')[3]
    else
      return false
    end
  end
end

function sendInfoToServer(code, info)
  g_game.talk('#%sco%# '..code..','..info)
end

function onConfirmBought(mode, text)
  if not getCodeBuffer(mode, 163, text) then return end
  local buffer = getCodeBuffer(mode, 163, text)
  if string.find(buffer, 'manyPoints') then
    return displayInfoBox('Emerald Shop', tr('You already have many points.'))
  elseif string.find(buffer, 'clanName') then
    local clan = string.explode(buffer, '|')[2]
    return displayInfoBox('Emerald Shop', tr('You already belong to the clan %s.', doCorrectString(clan)))
  elseif string.find(buffer, 'clanRank') then
    local rank = string.explode(buffer, '|')[2]
    return displayInfoBox('Emerald Shop', tr('You must be at least rank %s.', rank))
  elseif string.find(buffer, 'clanLevel') then
    local level = string.explode(buffer, '|')[2]
    local clan = string.explode(buffer, '|')[3]
    local rank = string.explode(buffer, '|')[4]
    return displayInfoBox('Emerald Shop', tr('You need to be level %s to switch to %s rank %s.', level, doCorrectString(clan), rank))
  end
  local name = string.explode(buffer, '|')[1]
  local description = string.explode(buffer, '|')[2]
  refreshEmeralds()
  displayInfoBox('Emerald Shop', tr('You bought %s (%s)!', name, description))
end

function onBuyMarket(buyId)
  if g_game.getLocalPlayer():getItemsCount(3032) >= marketOffers[buyId][4] then
    if not confirmWindow then
      local yesCallback = function()		
		g_game.talk('/shop '..marketOffers[buyId][6])
        if confirmWindow then
          confirmWindow:destroy()
          confirmWindow = nil
        end
      end

      local noCallback = function()
        confirmWindow:destroy()
        confirmWindow = nil
      end
      confirmWindow = displayGeneralBox('Emerald Shop', tr('Are you sure you want to buy %s (%s)?', marketOffers[buyId][1], marketOffers[buyId][2]), {
        { text=tr('Yes'), callback=yesCallback },
        { text=tr('No'), callback=noCallback },
      anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
    else
      confirmWindow:destroy()
      confirmWindow = nil
      onBuyMarket(buyId)
    end
  else
    displayInfoBox('Emerald Shop', tr('You don\'t have enough emeralds.'))
  end
end

function onBuyOutfit(buyId)
  if g_game.getLocalPlayer():getItemsCount(3032) >= outfitsOffers[buyId][8] then
    if not confirmWindow then
      local yesCallback = function()		
		g_game.talk('/shop '..outfitsOffers[buyId][10])
        if confirmWindow then
          confirmWindow:destroy()
          confirmWindow = nil
        end
      end

      local noCallback = function()
        confirmWindow:destroy()
        confirmWindow = nil
      end
      confirmWindow = displayGeneralBox('Emerald Shop', tr('Are you sure you want to buy %s (%s)?', outfitsOffers[buyId][1], outfitsOffers[buyId][2]), {
        { text=tr('Yes'), callback=yesCallback },
        { text=tr('No'), callback=noCallback },
      anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
    else
      confirmWindow:destroy()
      confirmWindow = nil
      onBuyOutfit(buyId)
    end
  else
    displayInfoBox('Emerald Shop', tr('You don\'t have enough emeralds.'))
  end
end

-- function onBuyAddons(buyId)
--   if g_game.getLocalPlayer():getItemsCount(3032) >= addonsOffers[buyId][8] then
--     if not confirmWindow then
--       local yesCallback = function()		
-- 		g_game.talk('/shop '..addonsOffers[buyId][10])
--         if confirmWindow then
--           confirmWindow:destroy()
--           confirmWindow = nil
--         end
--       end

--       local noCallback = function()
--         confirmWindow:destroy()
--         confirmWindow = nil
--       end
--       confirmWindow = displayGeneralBox('Emerald Shop', tr('Are you sure you want to buy %s (%s)?', addonsOffers[buyId][1], addonsOffers[buyId][2]), {
--         { text=tr('Yes'), callback=yesCallback },
--         { text=tr('No'), callback=noCallback },
--       anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
--     else
--       confirmWindow:destroy()
--       confirmWindow = nil
--       onBuyOutfit(buyId)
--     end
--   else
--     displayInfoBox('Emerald Shop', tr('You don\'t have enough emeralds.'))
--   end
-- end

function onBuyClan(clanId)
  destroyClanWindow()
  clanWindow = g_ui.createWidget('ClanWindow', rootWidget)

  clanWindow:setText(clansOffers[clanId][2])
  clanWindow:getChildById('prize'):setText(CLIENT_CLAN_COST .. ' Emeralds')

  local sb = clanWindow:getChildById('spinBox')
  if sb then sb:hide() end

  local callback = function()
    if g_game.getLocalPlayer():getItemsCount(3032) >= CLIENT_CLAN_COST then
      g_game.talk('/clan ' .. clansOffers[clanId][2])
      destroyClanWindow()
    else
      displayInfoBox('Emerald Shop', tr('You don\'t have enough emeralds.'))
    end
  end

  clanWindow:getChildById('okButton').onClick = callback
  clanWindow.onEnter = callback
end


function destroyClanWindow()
  if clanWindow then
    clanWindow:destroy()
    clanWindow = nil
  end
end

function onTabChange(tabBar, tab)
  offerSearch:clearText()
end

function searchOffer()
  local panel = shopTabBar:getCurrentTabPanel():getChildByIndex(1)
  local searchFilter = offerSearch:getText():lower()
  for i = 1, panel:getChildCount() do
    local button = panel:getChildByIndex(i)
    local searchCondition = (searchFilter == '') or (searchFilter ~= '' and (string.find(button.name:lower(), searchFilter) ~= nil or string.find(button.description:lower(), searchFilter) ~= nil))
    button:setVisible(searchCondition)
  end
end

function setOffers(panel)
  local offersPanel = panel:getChildByIndex(1)
  if offersPanel:getId() == 'shopMarket' then
    for i = 1, #marketOffers do
      local widget = offersPanel:getChildByIndex(i)
      widget:setId(i)
      widget:getChildByIndex(1):setText(marketOffers[i][1])
      widget:getChildByIndex(2):setText(marketOffers[i][2])
      widget:getChildByIndex(3):setImageSource('/images/game/shop/market/'..marketOffers[i][3])
      widget:getChildByIndex(4):setText(marketOffers[i][4]..' Emeralds')
      widget.name = marketOffers[i][1]
      widget.description = marketOffers[i][2]
      widget.sale = marketOffers[i][5]
      if widget.sale then
        widget:getChildByIndex(1):setColor('#FF2000')
        widget:getChildByIndex(2):setColor('#FF2000')
        widget:getChildByIndex(3):setIconColor('white')
        widget:getChildByIndex(4):setColor('#CC2000')
      else
        widget:getChildByIndex(1):setColor('white')
        widget:getChildByIndex(2):setColor('white')
        widget:getChildByIndex(3):setIconColor('alpha')
        widget:getChildByIndex(4):setColor('white')
      end
    end
  elseif offersPanel:getId() == 'shopOutfits' then
    for i = 1, #outfitsOffers do
      local widget = offersPanel:getChildByIndex(i)
      local player = g_game.getLocalPlayer()
      local outfit = player:getOutfit()
      outfit.type = outfitsOffers[i][3]
      outfit.head = outfitsOffers[i][4]
      outfit.body = outfitsOffers[i][5]
      outfit.legs = outfitsOffers[i][6]
      outfit.feet = outfitsOffers[i][7]
      widget:setId(i)
      widget:getChildByIndex(1):setText(outfitsOffers[i][1])
      widget:getChildByIndex(2):setText(outfitsOffers[i][2])
      widget:getChildByIndex(3):setCreature()
      widget:getChildByIndex(3):setOutfit(outfit)
      widget:getChildByIndex(4):setText(outfitsOffers[i][8]..' Emeralds')
      widget.name = outfitsOffers[i][1]
      widget.description = outfitsOffers[i][2]
      widget.sale = outfitsOffers[i][9]
      if widget.sale then
        widget:getChildByIndex(1):setColor('#FF2000')
        widget:getChildByIndex(2):setColor('#FF2000')
        widget:getChildByIndex(3):getChildByIndex(1):setIconColor('white')
        widget:getChildByIndex(4):setColor('#CC2000')
      else
        widget:getChildByIndex(1):setColor('white')
        widget:getChildByIndex(2):setColor('white')
        widget:getChildByIndex(3):getChildByIndex(1):setIconColor('alpha')
        widget:getChildByIndex(4):setColor('white')
      end
    end
  -- elseif offersPanel:getId() == 'shopAddons' then
  --   for i = 1, #addonsOffers do
  --     local widget = offersPanel:getChildByIndex(i)
  --     local player = g_game.getLocalPlayer()
  --     local outfit = player:getOutfit()
  --     outfit.type = addonsOffers[i][3]
  --     outfit.head = addonsOffers[i][4]
  --     outfit.body = addonsOffers[i][5]
  --     outfit.legs = addonsOffers[i][6]
  --     outfit.feet = addonsOffers[i][7]
  --     widget:setId(i)
  --     widget:getChildByIndex(1):setText(addonsOffers[i][1])
  --     widget:getChildByIndex(2):setText(addonsOffers[i][2])
  --     widget:getChildByIndex(3):setCreature()
  --     widget:getChildByIndex(3):setOutfit(outfit)
  --     widget:getChildByIndex(4):setText(addonsOffers[i][8]..' Emeralds')
  --     widget.name = addonsOffers[i][1]
  --     widget.description = addonsOffers[i][2]
  --     widget.sale = addonsOffers[i][9]
  --     if widget.sale then
  --       widget:getChildByIndex(1):setColor('#FF2000')
  --       widget:getChildByIndex(2):setColor('#FF2000')
  --       widget:getChildByIndex(3):getChildByIndex(1):setIconColor('white')
  --       widget:getChildByIndex(4):setColor('#CC2000')
  --     else
  --       widget:getChildByIndex(1):setColor('white')
  --       widget:getChildByIndex(2):setColor('white')
  --       widget:getChildByIndex(3):getChildByIndex(1):setIconColor('alpha')
  --       widget:getChildByIndex(4):setColor('white')
  --     end
  --   end
  elseif offersPanel:getId() == 'shopClans' then
    for i = 1, #clansOffers do
      local widget = offersPanel:getChildByIndex(i)
      widget:setId(i)
      widget:setImageSource('/images/game/shop/clans/'..clansOffers[i][3])
      widget.name = clansOffers[i][1]
      widget.description = clansOffers[i][2]
      widget.sale = clansOffers[i][4]
    end
  end
end
