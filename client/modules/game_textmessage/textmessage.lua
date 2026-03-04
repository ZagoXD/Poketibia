MessageSettings = {
  none            = {},
  consoleRed      = { color = TextColors.red,    consoleTab='Default' },
  consoleOrange   = { color = TextColors.orange, consoleTab='Default' },
  consoleBlue     = { color = TextColors.blue,   consoleTab='Default' },
  centerRed       = { color = TextColors.red,    consoleTab='Server Log', screenTarget='lowCenterLabel' },
  centerGreen     = { color = TextColors.green,  consoleTab='Server Log', screenTarget='highCenterLabel',   consoleOption='showInfoMessagesInConsole' },
  centerWhite     = { color = TextColors.white,  consoleTab='Server Log', screenTarget='middleCenterLabel', consoleOption='showEventMessagesInConsole' },
  bottomWhite     = { color = TextColors.white,  consoleTab='Server Log', screenTarget='statusLabel',       consoleOption='showEventMessagesInConsole' },
  status          = { color = TextColors.white,  consoleTab='Server Log', screenTarget='statusLabel',       consoleOption='showStatusMessagesInConsole' },
  statusSmall     = { color = TextColors.white,                           screenTarget='statusLabel' },
  private         = { color = TextColors.lightblue,                       screenTarget='privateLabel' }
}

MessageTypes = {
  [MessageModes.MonsterSay] = MessageSettings.consoleOrange,
  [MessageModes.MonsterYell] = MessageSettings.consoleOrange,
  [MessageModes.BarkLow] = MessageSettings.consoleOrange,
  [MessageModes.BarkLoud] = MessageSettings.consoleOrange,
  [MessageModes.Failure] = MessageSettings.statusSmall,
  [MessageModes.Login] = MessageSettings.bottomWhite,
  [MessageModes.Game] = MessageSettings.centerWhite,
  [MessageModes.Status] = MessageSettings.status,
  [MessageModes.Warning] = MessageSettings.centerRed,
  [MessageModes.Look] = MessageSettings.centerGreen,
  [MessageModes.Loot] = MessageSettings.centerGreen,
  [MessageModes.Red] = MessageSettings.consoleRed,
  [MessageModes.Blue] = MessageSettings.consoleBlue,
  [MessageModes.PrivateFrom] = MessageSettings.consoleBlue,

  [MessageModes.DamageDealed] = MessageSettings.status,
  [MessageModes.DamageReceived] = MessageSettings.status,
  [MessageModes.Heal] = MessageSettings.status,
  [MessageModes.Exp] = MessageSettings.status,

  [MessageModes.DamageOthers] = MessageSettings.none,
  [MessageModes.HealOthers] = MessageSettings.none,
  [MessageModes.ExpOthers] = MessageSettings.none,

  [MessageModes.TradeNpc] = MessageSettings.centerWhite,
  [MessageModes.Guild] = MessageSettings.centerWhite,
  [MessageModes.PartyManagement] = MessageSettings.centerWhite,
  [MessageModes.TutorialHint] = MessageSettings.centerWhite,
  [MessageModes.Market] = MessageSettings.centerWhite,
  [MessageModes.BeyondLast] = MessageSettings.centerWhite,
  [MessageModes.Report] = MessageSettings.consoleRed,
  [MessageModes.HotkeyUse] = MessageSettings.centerGreen,

  [254] = MessageSettings.private
}

messagesPanel = nil

function init()
  connect(g_game, 'onTextMessage', displayMessage)
  connect(g_game, 'onGameEnd', clearMessages)
  messagesPanel = g_ui.loadUI('textmessage', modules.game_interface.getRootPanel())
end

function terminate()
  disconnect(g_game, 'onTextMessage', displayMessage)
  disconnect(g_game, 'onGameEnd',clearMessages)
  clearMessages()
  messagesPanel:destroy()
end

function calculateVisibleTime(text)
  return math.max(#text * 100, 4000)
end

function displayMessage(mode, text)
  if not g_game.isOnline() then return end

  if type(text) == 'string' and (text:find('^%[DMEM%]') or text:find('^%[DMEM_HIDE%]')) then
    return
  end

  if type(text) == 'string' then
    local p7 = text:sub(1,7)
    local p9 = text:sub(1,9)
    if p7 == 'Pokebar' or p9 == 'BarClosed' then
      return
    end
  end

  local msgtype = MessageTypes[mode]

  if not msgtype then
    perror('unhandled onTextMessage message mode ' .. mode .. ': ' .. text)
    return
  end

  if msgtype == MessageSettings.none then return end
  
  --[[if mode == MessageModes.Warning then
	local label = messagesPanel:recursiveGetChildById('customMessage')
	local color = msgtype.color
	
	if ( text:find('|') ) then
		color = text:explode('|')[1]
		text  = text:explode('|')[2]
	end

	label:setText(text)
	label:setColor(color)
	label:setBorderColor(color)
	label:setWidth(label:getTextSize().width+110)
	label:show()
	
	addEvent(function() g_effects.fadeIn(label, 250) end)
    removeEvent(label.hideEvent)
    label.hideEvent = scheduleEvent(function() 
	addEvent(function() g_effects.fadeOut(label, 250) end)
	scheduleEvent(function() label:hide() end, 250) 
	end, calculateVisibleTime(text))
	return 
  end]]--

  if msgtype.consoleTab ~= nil and (msgtype.consoleOption == nil or modules.client_options.getOption(msgtype.consoleOption)) then
    if modules and modules.game_console and modules.game_console.addText then
      modules.game_console.addText(text, msgtype, tr(msgtype.consoleTab))
    end
  end

  if msgtype.screenTarget then
    if string.find(text, '12//,') or string.find(text, '12|,') or string.find(text, 'p#,') or string.find(text, '12&,') or string.find(text, '#ph#,') then
    return
		 end
		     if string.find(text, '@pokedex') and not string.find(text, 'MySelf') then
       local t = string.explode(text, "/")
          modules.Base.init2(t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15], t[16], t[17], text)
          return
    elseif string.find(text, 'MySelf') and string.find(text, '@pokedex') then 
            modules.Base.init3(text)
         return
    elseif string.find(text, '@dex') then 
    local t = string.explode(text, "/")
            modules.Base.init4(t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15], t[16], t[17], text)
         return
	elseif string.find(text, "%#CatcherWindow@") then
		return
	elseif string.find(text, "%#Pokedex") then
		return 
		 end
    local label = messagesPanel:recursiveGetChildById(msgtype.screenTarget)
    label:setText(text)
    label:setColor(msgtype.color)
    label:setVisible(true)
    removeEvent(label.hideEvent)
    label.hideEvent = scheduleEvent(function() label:setVisible(false) end, calculateVisibleTime(text))
end
end

function displayPrivateMessage(text)
  displayMessage(254, text)
end

function displayStatusMessage(text)
  displayMessage(MessageModes.Status, text)
end

function displayFailureMessage(text)
  displayMessage(MessageModes.Failure, text)
end

function displayGameMessage(text)
  displayMessage(MessageModes.Game, text)
end

function displayBroadcastMessage(text)
  displayMessage(MessageModes.Warning, text)
end

function clearMessages()
  for _i,child in pairs(messagesPanel:recursiveGetChildren()) do
    if child:getId():match('Label') then
      child:hide()
      removeEvent(child.hideEvent)
    end
  end
end

function LocalPlayer:onAutoWalkFail(player)
  modules.game_textmessage.displayFailureMessage(tr('There is no way.'))
end

function doShowPokedex()
   modules.Base.init()
end