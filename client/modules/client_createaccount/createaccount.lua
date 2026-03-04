CreateAccount = CreateAccount or {}

local win
local loadBox
local submitting = false

local function W(id)
    return win and win:recursiveGetChildById(id)
end

function CreateAccount.init()
    win = g_ui.displayUI('createaccount', g_ui.getRootWidget())
    win:hide()
end

function CreateAccount.terminate()
    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end
    if win then
        win:destroy()
        win = nil
    end
end

function CreateAccount.show()
    win:show()
    win:raise()
    win:focus()

    local a = W('caAccountText')
    if a then
        a:focus()
    end
end

function CreateAccount.hide()
    if win then
        win:hide()
    end
end

function CreateAccount.submit()
    if submitting then
        return
    end

    if not HTTP or not HTTP.postJSON then
        displayErrorBox(tr('Erro'),
            tr('HTTP.postJSON nao encontrado. Verifique se corelib/http.lua esta sendo carregado.'))
        return
    end

    if not json or not json.encode or not json.decode then
        displayErrorBox(tr('Erro'), tr(
            'json.encode/json.decode nao encontrado. Verifique se corelib/json.lua e dkjson.lua estao carregados.'))
        return
    end

    local username = W('caAccountText'):getText()
    local email = W('caEmailText'):getText()
    local pass1 = W('caPassText'):getText()
    local pass2 = W('caPass2Text'):getText()

    if pass1 ~= pass2 then
        displayErrorBox(tr('Erro'), tr('As senhas nao conferem.'))
        return
    end

    local url = "http://api.pokenathso.com.br/api/createaccount"

    local payload = {
        username = username,
        email = email,
        password = pass1,
        password_again = pass2,
        flag = "br",
        selected = 1
    }

    submitting = true

    if loadBox then
        loadBox:destroy()
    end
    loadBox = displayCancelBox(tr('Aguarde'), tr('Criando conta...'))

    connect(loadBox, {
        onCancel = function()
            if loadBox then
                loadBox:destroy();
                loadBox = nil
            end
            submitting = false
            CreateAccount.show()
        end
    })

    HTTP.postJSON(url, payload, function(data, err, status)
        if loadBox then
            loadBox:destroy();
            loadBox = nil
        end
        submitting = false

        if err then
            local box = displayErrorBox(tr('Erro'), err)
            connect(box, {
                onOk = function()
                    CreateAccount.show()
                end
            })
            return
        end

        if data and data.ok then
            local box = displayInfoBox(tr('Sucesso'), tr('Conta criada! Agora faca login.'))
            connect(box, {
                onOk = function()
                    CreateAccount.backToEnterGame()
                end
            })
        else
            local msg = (data and data.error) or ("Falha ao criar conta (HTTP " .. tostring(status) .. ")")
            local box = displayErrorBox(tr('Erro'), msg)
            connect(box, {
                onOk = function()
                    CreateAccount.show()
                end
            })
        end
    end)

end

function init()
    CreateAccount.init()
end

function terminate()
    CreateAccount.terminate()
end

function CreateAccount.backToEnterGame()
    CreateAccount.hide()
    if EnterGame and EnterGame.show then
        EnterGame.show()
    end
end

function CreateAccount.cancel()
    if submitting then
        return
    end
    CreateAccount.backToEnterGame()
end
