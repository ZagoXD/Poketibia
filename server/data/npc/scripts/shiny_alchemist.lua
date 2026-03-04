local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)    npcHandler:onCreatureAppear(cid)    end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, t, m) npcHandler:onCreatureSay(cid, t, m) end
function onThink()                npcHandler:onThink()                end

npcHandler:setMessage(MESSAGE_GREET,    "Ola treinador! Eu ensino como funciona a forja de stones. Diga {help}.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Boas forjas!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Volte quando quiser aprender mais.")

local function sayTo(cid, text)
  local tt = TALKTYPE_PRIVATE_NP or TALKTYPE_PRIVATE_NPC or TALKTYPE_PRIVATE or TALKTYPE_SAY
  doCreatureSay(getNpcId(), text, tt, false, cid)
end

local TXT_INTRO = table.concat({
  "Este e um sistema de craft alquimico. Procure uma bancada alquimica.",
  "Ao interagir com a bancada, um painel de transmutacao aparece com os tipos de stone.",
  "Escolha a stone desejada e confirme no modal para concluir o ritual.",
}, " ")

local TXT_COST = "Custo do ritual: 20x da stone normal + 5x Shiny Dust = 1x Shining Stone."

local TXT_LIST = table.concat({
  "Tipos trabalhados na forja:",
  "1 Fire, 2 Enigma, 3 Thunder, 4 Water, 5 Rock, 6 Crystal, 7 Leaf,",
  "8 Venom, 9 Coccon, 10 Earth, 11 Heart, 12 Ice, 13 Darkness, 14 Punch."
}, " ")

local TXT_TIPS = table.concat({
  "Dicas do alquimista:",
  "- Traga sempre Shiny Dust suficiente.",
  "- Se a mochila estiver cheia, o item pode ser enviado ao depot.",
  "- A bancada funciona apenas se voce estiver ao lado dela."
}, " ")

local function onHelp(cid)
  sayTo(cid, TXT_INTRO)
  sayTo(cid, TXT_COST)
  sayTo(cid, TXT_LIST)
  sayTo(cid, TXT_TIPS)
end

local function onHow(cid)
  sayTo(cid, "Encontre uma bancada alquimica, fique ao lado dela e interaja. O painel abrira. Selecione a stone e confirme no modal.")
end

local function onCost(cid)
  sayTo(cid, TXT_COST)
end

local function onList(cid)
  sayTo(cid, TXT_LIST)
end

local HELP_WORDS = { "help", "ajuda", "como", "how", "craft", "forja", "alquimia", "bancada", "painel", "sistema" }
for _, w in ipairs(HELP_WORDS) do
  keywordHandler:addKeyword({w}, function(_, cid) onHelp(cid) end)
end

keywordHandler:addKeyword({"cost", "custo", "preco"},  function(_, cid) onCost(cid) end)
keywordHandler:addKeyword({"stones", "lista", "list"}, function(_, cid) onList(cid) end)
keywordHandler:addKeyword({"como usar", "tutorial"},   function(_, cid) onHow(cid) end)

keywordHandler:addKeyword({"dust", "shiny dust"}, function(_, cid)
  sayTo(cid, "Shiny Dust e o catalisador do ritual. Separe ao menos 5x para cada troca.")
end)

npcHandler:addModule(FocusModule:new())
