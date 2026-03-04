function onLogin(cid)
  local ammo = getPlayerSlotItem(cid, CONST_SLOT_AMMO)
  if ammo and ammo.uid and ammo.uid > 0 and ammo.itemid == 2547 then
    doRemoveItem(ammo.uid)
  end
  return true
end