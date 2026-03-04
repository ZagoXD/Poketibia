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