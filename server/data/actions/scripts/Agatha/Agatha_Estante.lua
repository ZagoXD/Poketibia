function onUse(cid, item, fromPosition, itemEx, toPosition)

if getPlayerItemCount(cid, Agatha.colar) <= 0 then
   return true
elseif getPlayerStorageValue(cid, Agatha.stoIni) ~= 1 then
   return true
end

if itemEx.actionid ~= tonumber(getPlayerStorageValue(cid, Agatha.stoRes)) then
   sendMsgToPlayer(cid, 27, "You picked the wrong shelf, go back and start the quest again!")
   local monster = doCreateMonster("Shiny Abra", getClosestFreeTile(cid, toPosition), false)
   doSendMagicEffect(getThingPos(monster), 21)
   
   setPlayerStorageValue(cid, Agatha.stoRec, -1)
   setPlayerStorageValue(cid, Agatha.stoEni, -1)
   setPlayerStorageValue(cid, Agatha.stoRes, -1)
   for i = 1, #Agatha.stoPergs do
       setPlayerStorageValue(cid, Agatha.stoPergs[i], -1)
   end
else
   local h = doPlayerAddItem(cid, Agatha.hammer, 1)
   doSetItemAttribute(h, "aid", 6661)
   
   sendMsgToPlayer(cid, 27, "Congradulations, you picked the correct shelf!")
   doSendMagicEffect(getThingPos(cid), 21) --mudar eff
end
doRemoveItem(item.uid, 1)

return true
end  

--<action actionid="6660" event="script" value="Agatha_Estante.lua"/>  