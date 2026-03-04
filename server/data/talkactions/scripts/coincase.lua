local coinsStorage = 23254

function onSay(cid, words, param)
  local coins = getPlayerStorageValue(cid, coinsStorage)
  if coins == -1 then coins = 0 end

  if coins >= 1 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "You have " .. coins .. " cassino coins left."
    )
  else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "You don't have any cassino coins. To buy coins, order at celadon's cassino."
    )
  end
  return true
end