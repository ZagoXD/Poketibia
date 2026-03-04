AUTOLOOT_STORAGE_MODE = 91000
AUTOLOOT_BACKPACK_SLOT = 3

AUTOLOOT_STONES = {
  [11441]=true,[11442]=true,[11443]=true,[11444]=true,[11445]=true,[11446]=true,
  [11447]=true,[11448]=true,[11449]=true,[11450]=true,[11451]=true,[11452]=true,
  [11453]=true,[11454]=true,[12232]=true,[12242]=true,[12244]=true,[12245]=true,
  [12417]=true,[12418]=true,[12419]=true,
  [12401]=true,[12402]=true,[12403]=true,[12404]=true,[12405]=true,[12406]=true,
  [12407]=true,[12408]=true,[12409]=true,[12410]=true,[12411]=true,[12412]=true,
  [12413]=true,
  [14108]=true,[14109]=true,[14110]=true,[14111]=true,[14112]=true,[14117]=true,
  [14118]=true,[14119]=true,[14120]=true,[14121]=true,[14122]=true
}

function autolootGetMode(cid)
  local v = getPlayerStorageValue(cid, AUTOLOOT_STORAGE_MODE)
  if v == -1 then return 0 end
  return v
end

function autolootSetMode(cid, mode)
  setPlayerStorageValue(cid, AUTOLOOT_STORAGE_MODE, mode)
end

function autolootIsStone(itemid)
  return AUTOLOOT_STONES[itemid] == true
end

function doPlayerAddItemStackingToBackpack(cid, itemid, count)
  local bp = getPlayerSlotItem(cid, AUTOLOOT_BACKPACK_SLOT)
  if bp and bp.uid > 0 and isContainer(bp.uid) then
    local size = getContainerSize(bp.uid)
    for i=0, size-1 do
      local it = getContainerItem(bp.uid, i)
      if it.uid > 0 and it.itemid == itemid and it.type and it.type > 0 and it.type < 100 then
        local new = it.type + count
        if new <= 100 then
          doTransformItem(it.uid, itemid, new)
          return true
        else
          doTransformItem(it.uid, itemid, 100)
          count = new - 100
        end
      end
    end
    if count > 0 then
      doAddContainerItem(bp.uid, itemid, count)
      return true
    end
    return true
  end
  doPlayerAddItem(cid, itemid, count)
  return true
end
