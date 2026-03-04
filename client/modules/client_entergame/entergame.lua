EnterGame = {}

-- private variables
local loadBox
local enterGame
local motdWindow
local motdButton
local enterGameButton
local clientBox
local protocolLogin
local motdEnabled = false
local serverIP = '177.54.150.41' -- 177.54.150.41

local function W(id)
    if not enterGame then
        return nil
    end
    return enterGame:recursiveGetChildById(id)
end


function getServerIP()
    return serverIP
end
-- private functions
local function onError(protocol, message, errorCode)
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end

  local msg = tostring(message or "")
  local msgLower = msg:lower()

  local noChars =
    msgLower:find("does not contain any character") or
    msgLower:find("does not contain any character yet") or
    msgLower:find("no character yet") or
    msgLower:find("create a new character") or
    msgLower:find("não possui nenhum personagem") or
    msgLower:find("nao possui nenhum personagem") or
    msgLower:find("nenhum personagem")

  if noChars then
    if g_modules and g_modules.ensureModuleLoaded then
      g_modules.ensureModuleLoaded('client_createcharacter')
    end

    if EnterGame and EnterGame.hide then
      EnterGame.hide()
    end

    if CreateCharacter and CreateCharacter.show then
      CreateCharacter.show()
    else
      local box = displayErrorBox(tr('Error'), tr('CreateCharacter module not loaded.'))
      connect(box, { onOk = function() if EnterGame and EnterGame.show then EnterGame.show() end end })
    end
    return
  end

  if not errorCode then
    EnterGame.clearAccountFields()
  end

  local errorBox = displayErrorBox(tr('Login Error'), message)
  connect(errorBox, { onOk = EnterGame.show })
end


local function onMotd(protocol, motd)
    G.motdNumber = tonumber(motd:sub(0, motd:find("\n")))
    G.motdMessage = motd:sub(motd:find("\n") + 1, #motd)
    if motdEnabled then
        motdButton:show()
    end
end

local function onCharacterList(protocol, characters, account, otui)
  ServerList.add(G.host, G.port, g_game.getProtocolVersion())

  local rb = W('rememberPasswordBox')
  local ab = W('autoLoginBox')

  if rb and rb:isChecked() then
    local encAccount  = g_crypt.encrypt(G.account or '')
    local encPassword = g_crypt.encrypt(G.password or '')

    g_settings.set('account', encAccount)
    g_settings.set('password', encPassword)

    ServerList.setServerAccount(G.host, encAccount)
    ServerList.setServerPassword(G.host, encPassword)

    g_settings.set('autologin', ab and ab:isChecked() or false)
  else
    ServerList.setServerAccount(G.host, '')
    ServerList.setServerPassword(G.host, '')
    g_settings.set('autologin', false)
    EnterGame.clearAccountFields()
  end

  loadBox:destroy()
  loadBox = nil

    if not characters or #characters == 0 then
    if g_modules and g_modules.ensureModuleLoaded then
      g_modules.ensureModuleLoaded('client_createcharacter')
    end

    if CreateCharacter and CreateCharacter.show then
      CreateCharacter.show()
    else
      displayErrorBox(tr('Error'), tr('No characters. CreateCharacter module not loaded.'))
      EnterGame.show()
    end
    return
  end

  CharacterList.create(characters, account, otui)
  CharacterList.show()

  if motdEnabled then
    local lastMotdNumber = g_settings.getNumber("motd")
    if G.motdNumber and G.motdNumber ~= lastMotdNumber then
      g_settings.set("motd", motdNumber)
      motdWindow = displayInfoBox(tr('Message of the day'), G.motdMessage)
      connect(motdWindow, { onOk = function() CharacterList.show() motdWindow = nil end })
      CharacterList.hide()
    end
  end
end

local function onUpdateNeeded(protocol, signature)
    loadBox:destroy()
    loadBox = nil

    if EnterGame.updateFunc then
        local continueFunc = EnterGame.show
        local cancelFunc = EnterGame.show
        EnterGame.updateFunc(signature, continueFunc, cancelFunc)
    else
        local errorBox = displayErrorBox(tr('Update needed'), tr('Your client needs update, try redownloading it.'))
        connect(errorBox, {
            onOk = EnterGame.show
        })
    end
end

-- public functions
function EnterGame.init()
  enterGame = g_ui.displayUI('entergame')
  enterGameButton = modules.client_topmenu.addLeftButton('enterGameButton', tr('Login') .. ' (Ctrl + G)', '/images/topbuttons/login', EnterGame.openWindow)
  enterGameButton:setWidth(23)
  motdButton = modules.client_topmenu.addLeftButton('motdButton', tr('Message of the day'), '/images/topbuttons/motd', EnterGame.displayMotd)
  motdButton:setWidth(31)
  motdButton:hide()
  g_keyboard.bindKeyDown('Ctrl+G', function() EnterGame.openWindow() end)

  if motdEnabled and G.motdNumber then
    motdButton:show()
  end

  local account      = g_settings.get('account')
  local password     = g_settings.get('password')
  local autologin    = g_settings.getBoolean('autologin')
  local clientVersion = g_settings.getInteger('client-version'); if clientVersion == 0 then clientVersion = 860 end

  EnterGame.setPassword(password)
  EnterGame.setAccountName(account)

  local rb, ab = W('rememberPasswordBox'), W('autoLoginBox')
  if ab then ab:setChecked(autologin) end
  if rb and ab then
    ab:setEnabled(rb:isChecked())
    if not rb:isChecked() then ab:setChecked(false) end
  end

  clientBox = W('clientComboBox')
  if clientBox then
    for _, proto in pairs(g_game.getSupportedClients()) do
      clientBox:addOption(proto)
    end
    clientBox:setCurrentOption(clientVersion)
  end

  enterGame:hide()
  if g_app.isRunning() and not g_game.isOnline() then enterGame:show() end
  EnterGame.setUniqueServer(serverIP, 7171, 854, 740, 740)
end

function EnterGame.firstShow()
    EnterGame.show()

    local account = g_crypt.decrypt(g_settings.get('account'))
    local password = g_crypt.decrypt(g_settings.get('password'))
    local host = g_settings.get('host')
    local autologin = g_settings.getBoolean('autologin')
    if #host > 0 and #password > 0 and #account > 0 and autologin then
        addEvent(function()
            if not g_settings.getBoolean('autologin') then
                return
            end
            EnterGame.doLogin()
        end)
    end
end

function EnterGame.terminate()
    g_keyboard.unbindKeyDown('Ctrl+G')
    enterGame:destroy()
    enterGame = nil
    enterGameButton:destroy()
    enterGameButton = nil
    clientBox = nil
    if motdWindow then
        motdWindow:destroy()
        motdWindow = nil
    end
    if motdButton then
        motdButton:destroy()
        motdButton = nil
    end
    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end
    if protocolLogin then
        protocolLogin:cancelLogin()
        protocolLogin = nil
    end
    EnterGame = nil
end

function EnterGame.show()
  if loadBox then return end
  enterGame:show()
  enterGame:raise()
  enterGame:focus()

  local a = W('accountNameTextEdit')
  if a then
    a:focus()
    a:setCursorPos(-1)
  end
end

function EnterGame.hide()
    enterGame:hide()
end

function EnterGame.openWindow()
    if g_game.isOnline() then
        CharacterList.show()
    elseif not g_game.isLogging() and not CharacterList.isVisible() then
        EnterGame.show()
    end
end

function EnterGame.setAccountName(account)
    local account = g_crypt.decrypt(account)
    local w = W('accountNameTextEdit')
    if w then
        w:setText(account)
        w:setCursorPos(-1)
    end
    local rb = W('rememberPasswordBox')
    if rb then
        rb:setChecked(#account > 0)
    end
end

function EnterGame.setPassword(password)
    local password = g_crypt.decrypt(password)
    local w = W('accountPasswordTextEdit')
    if w then
        w:setText(password)
    end
end

function EnterGame.clearAccountFields()
    local a = W('accountNameTextEdit')
    local p = W('accountPasswordTextEdit')
    if a then
        a:clearText()
    end
    if p then
        p:clearText()
    end
    if a then
        a:focus()
    end
    g_settings.remove('account')
    g_settings.remove('password')
end

function EnterGame.doLogin()
    local accEdit = W('accountNameTextEdit')
    local passEdit = W('accountPasswordTextEdit')

    G.account = accEdit and accEdit:getText() or ''
    G.password = passEdit and passEdit:getText() or ''

    G.host = serverIP
    G.port = 7171

    local clientVersion = tonumber(clientBox and clientBox:getText() or 854) or 854
    EnterGame.hide()

    if g_game.isOnline() then
        local errorBox = displayErrorBox(tr('Login Error'), tr('Cannot login while already in game.'))
        connect(errorBox, {
            onOk = EnterGame.show
        })
        return
    end

    g_settings.set('host', G.host)
    g_settings.set('port', G.port)
    g_settings.set('client-version', clientVersion)

    protocolLogin = ProtocolLogin.create()
    protocolLogin.onLoginError = onError
    protocolLogin.onMotd = onMotd
    protocolLogin.onCharacterList = onCharacterList
    protocolLogin.onUpdateNeeded = onUpdateNeeded

    loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...'))
    connect(loadBox, {
        onCancel = function(msgbox)
            loadBox = nil
            protocolLogin:cancelLogin()
            EnterGame.show()
        end
    })

    g_game.chooseRsa(G.host)
    g_game.setClientVersion(clientVersion)
    g_game.setProtocolVersion(g_game.getProtocolVersionForClient(clientVersion))

    if modules.game_things.isLoaded() then
        protocolLogin:login(G.host, G.port, G.account, G.password)
    else
        loadBox:destroy()
        loadBox = nil
        EnterGame.show()
    end
end

function EnterGame.refreshCharacterList()
  if not G.account or #tostring(G.account) == 0 or not G.password then
    EnterGame.show()
    return
  end

  if g_game.isOnline() or g_game.isLogging() then
    return
  end

  G.host = serverIP
  G.port = 7171

  local clientVersion = g_settings.getInteger('client-version')
  if not clientVersion or clientVersion == 0 then clientVersion = 854 end

  if EnterGame and EnterGame.hide then EnterGame.hide() end
  if CharacterList and CharacterList.hide then CharacterList.hide(false) end

  if protocolLogin then
    protocolLogin:cancelLogin()
    protocolLogin = nil
  end
  protocolLogin = ProtocolLogin.create()
  protocolLogin.onLoginError = onError
  protocolLogin.onMotd = onMotd
  protocolLogin.onCharacterList = onCharacterList
  protocolLogin.onUpdateNeeded = onUpdateNeeded

  loadBox = displayCancelBox(tr('Please wait'), tr('Updating character list...'))
  connect(loadBox, {
    onCancel = function()
      loadBox = nil
      if protocolLogin then
        protocolLogin:cancelLogin()
        protocolLogin = nil
      end
      if CharacterList and CharacterList.showAgain then
        CharacterList.showAgain()
      else
        EnterGame.show()
      end
    end
  })

  g_game.chooseRsa(G.host)
  g_game.setClientVersion(clientVersion)
  g_game.setProtocolVersion(g_game.getProtocolVersionForClient(clientVersion))

  if modules.game_things.isLoaded() then
    protocolLogin:login(G.host, G.port, G.account, G.password)
  else
    loadBox:destroy()
    loadBox = nil
    EnterGame.show()
  end
end

function EnterGame.displayMotd()
    if not motdWindow then
        motdWindow = displayInfoBox(tr('Message of the day'), G.motdMessage)
        motdWindow.onOk = function()
            motdWindow = nil
        end
    end
end

function EnterGame.setDefaultServer(host, port, protocol)
    local hostTextEdit = enterGame:getChildById('serverHostTextEdit')
    local portTextEdit = enterGame:getChildById('serverPortTextEdit')
    local clientLabel = enterGame:getChildById('clientLabel')
    local accountTextEdit = enterGame:getChildById('accountNameTextEdit')
    local passwordTextEdit = enterGame:getChildById('accountPasswordTextEdit')

    if hostTextEdit:getText() ~= host then
        hostTextEdit:setText(host)
        portTextEdit:setText(port)
        clientBox:setCurrentOption(protocol)
        accountTextEdit:setText('')
        passwordTextEdit:setText('')
    end
end

function EnterGame.setUniqueServer(host, port, protocol, windowWidth, windowHeight)
    serverIP = host or serverIP

    local hostTextEdit = W('serverHostTextEdit')
    if hostTextEdit then
        hostTextEdit:setText(host)
        hostTextEdit:setVisible(false)
        hostTextEdit:setHeight(0)
    end

    local portTextEdit = W('serverPortTextEdit')
    if portTextEdit then
        portTextEdit:setText(port)
        portTextEdit:setVisible(false)
        portTextEdit:setHeight(0)
    end

    if clientBox then
        clientBox:setCurrentOption(protocol)
        clientBox:setVisible(false)
        clientBox:setHeight(0)
    end

    local serverLabel = W('serverLabel');
    if serverLabel then
        serverLabel:setVisible(false);
        serverLabel:setHeight(0)
    end
    local portLabel = W('portLabel');
    if portLabel then
        portLabel:setVisible(false);
        portLabel:setHeight(0)
    end
    local clientLabel = W('clientLabel');
    if clientLabel then
        clientLabel:setVisible(false);
        clientLabel:setHeight(0)
    end
    local serverListButton = W('serverListButton');
    if serverListButton then
        serverListButton:setVisible(false);
        serverListButton:setHeight(0);
        serverListButton:setWidth(0)
    end

    local rememberPasswordBox = W('rememberPasswordBox')

    enterGame:setWidth(windowWidth or 740)
    enterGame:setHeight(windowHeight or 740)
end

function EnterGame.setServerInfo(message)
    local label = enterGame:getChildById('serverInfoLabel')
    label:setText(message)
end

function EnterGame.disableMotd()
    motdEnabled = false
    motdButton:hide()
end

function EnterGame.openCreateAccount()
  if g_modules and g_modules.ensureModuleLoaded then
    g_modules.ensureModuleLoaded('client_createaccount')
  end

  if not CreateAccount or not CreateAccount.show then
    displayErrorBox(tr('Erro'), tr('CreateAccount não carregou.'))
    return
  end

  EnterGame.hide()
  CreateAccount.show()
end
