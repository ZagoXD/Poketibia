CreateCharacter = CreateCharacter or {}

local win
local loadBox
local submitting = false
local selectedGender = true

local function W(id)
  return win and win:recursiveGetChildById(id)
end

local function applyGenderUI()
  local male = W('genderMale')
  local female = W('genderFemale')
  if not male or not female then return end

  if selectedGender then
    male:setStyle('GenderCardSelected')
    female:setStyle('GenderCard')
  else
    male:setStyle('GenderCard')
    female:setStyle('GenderCardSelected')
  end
end

function CreateCharacter.selectGender(isMale)
  selectedGender = isMale and true or false
  applyGenderUI()
end

function CreateCharacter.init()
  win = g_ui.displayUI('createcharacter', g_ui.getRootWidget())
  win:hide()

  selectedGender = true
  applyGenderUI()

  local a = W('ccNameText')
  if a then a:setText('') end
end

function CreateCharacter.terminate()
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
  if win then
    win:destroy()
    win = nil
  end
end

function CreateCharacter.show()
  if not win then return end
  win:show()
  win:raise()
  win:focus()

  if win.centerInParent then
    win:centerInParent()
  else
    local root = g_ui.getRootWidget()
    local rootSize = root:getSize()
    local winSize = win:getSize()
    win:setPosition({
      x = math.floor((rootSize.width - winSize.width) / 2),
      y = math.floor((rootSize.height - winSize.height) / 2)
    })
  end

  local a = W('ccNameText')
  if a then a:focus() end
end

function CreateCharacter.hide()
  if win then win:hide() end
end

function CreateCharacter.back()
  CreateCharacter.hide()
  if CharacterList and CharacterList.isAvailable and CharacterList.isAvailable() then
    CharacterList.show()
  elseif EnterGame and EnterGame.show then
    EnterGame.show()
  end
end

function CreateCharacter.cancel()
  if submitting then return end
  CreateCharacter.back()
end

function CreateCharacter.submit()
  if submitting then return end

  if not HTTP or not HTTP.postJSON then
    displayErrorBox(tr('Erro'), tr('HTTP.postJSON não encontrado.'))
    return
  end
  if not json or not json.encode or not json.decode then
    displayErrorBox(tr('Erro'), tr('json.encode/json.decode não encontrado.'))
    return
  end

  local name = W('ccNameText') and W('ccNameText'):getText() or ''
  name = name:trim()
  if name == '' then
    displayErrorBox(tr('Erro'), tr('Digite um nome.'))
    return
  end

  local gender = selectedGender and 1 or 0

  local url = "http://api.pokenathso.com.br/api/createcharacter"

  local payload = {
    account = G.account,
    password = G.password,
    name = name,
    selected_gender = gender
  }

  submitting = true
  if loadBox then loadBox:destroy() end
  loadBox = displayCancelBox(tr('Aguarde'), tr('Criando personagem...'))

  connect(loadBox, {
    onCancel = function()
      if loadBox then
        loadBox:destroy()
        loadBox = nil
      end
      submitting = false
      CreateCharacter.show()
    end
  })

  HTTP.postJSON(url, payload, function(data, err, status)
    if loadBox then
      loadBox:destroy()
      loadBox = nil
    end
    submitting = false

    if err then
      local box = displayErrorBox(tr('Erro'), err)
      connect(box, { onOk = function() CreateCharacter.show() end })
      return
    end

    if data and data.ok then
      CreateCharacter.hide()
      local box = displayInfoBox(tr('Sucesso'), tr('Personagem criado!'))
      connect(box, {
        onOk = function()
          CreateCharacter.hide()
          if EnterGame and EnterGame.refreshCharacterList then
            EnterGame.refreshCharacterList()
            return
          end
          if CharacterList and CharacterList.showAgain then
            CharacterList.showAgain()
          elseif EnterGame and EnterGame.show then
            EnterGame.show()
          end
        end
      })
    else
      local msg = (data and data.error) or ("Falha ao criar personagem (HTTP " .. tostring(status) .. ")")
      local box = displayErrorBox(tr('Erro'), msg)
      connect(box, { onOk = function() CreateCharacter.show() end })
    end
  end)
end

function init() CreateCharacter.init() end
function terminate() CreateCharacter.terminate() end
