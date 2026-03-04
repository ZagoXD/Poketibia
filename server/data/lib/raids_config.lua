RAID_EXIT_POS = {x=1055, y=1050, z=7}

RAID_STOR = {
  ACTIVE = 91000,
  STAGE = 91001,
  INST = 91002,
  CLAIMED = 91003,
  DIFF = 91004,
  REMOVING = 91005,
}

RAID_LOBBY_WINDOW_MS = 10 * 60 * 1000

-- Lotação/raio do lobby
RAID_LOBBY_RADIUS = 1
RAID_MAX_PLAYERS  = 4
RAID_LOBBY_HINT   = "Fique a ate %d SQM do portal para entrar."

-- Dificuldade (1=fácil, 2=média, 3=difícil)
RAID_DEFAULT_DIFFICULTY = 0

-- Tabela de dificuldades
RAID_DIFF = { EASY=1, MEDIUM=2, HARD=3 }
RAID_DIFF_CFG = {
  [RAID_DIFF.EASY ] = { name="Facil",   time_ms=15*60*1000, loot_mult=1.0, chest_aid=55331, chest_room={x=1008,y=1102,z=15} },
  [RAID_DIFF.MEDIUM] = { name="Media",   time_ms= 15*60*1000, loot_mult=2.0, chest_aid=55332, chest_room={x=1000,y=1102,z=15} },
  [RAID_DIFF.HARD ] = { name="Dificil", time_ms= 15*60*1000, loot_mult=3.0, chest_aid=55333, chest_room={x=1004,y=1110,z=15} },
}

-- Tipos de raid
RAID_TYPES = {
  fire =  { centerItemId=14101, enter={x=1086,y=1123,z=15},  bossPos={x=1095,y=1092,z=15} },
  water = { centerItemId=14103, enter={x=1144,y=1202,z=15}, bossPos={x=1151,y=1168,z=15} },
  plant = { centerItemId=14101, enter={x=1022,y=1195,z=15}, bossPos={x=1061,y=1185,z=15} },
}

-- Boss por tipo/dificuldade
RAID_BOSSES = {
  fire  = { [RAID_DIFF.EASY]="Raid Charmander", [RAID_DIFF.MEDIUM]="Raid Charmeleon", [RAID_DIFF.HARD]="Raid Charizard" },
  water = { [RAID_DIFF.EASY]="Raid Squirtle",   [RAID_DIFF.MEDIUM]="Raid Wartortle",  [RAID_DIFF.HARD]="Raid Blastoise" },
  plant = { [RAID_DIFF.EASY]="Raid Bulbasaur",  [RAID_DIFF.MEDIUM]="Raid Ivysaur",    [RAID_DIFF.HARD]="Raid Venusaur"  },
}

-- Locais onde o lobby pode aparecer
RAID_LOBBY_SPAWNS = {
  [1]  = { type = "fire",  center = {x=738,  y=1405, z=7} },
  [2]  = { type = "fire",  center = {x=855,  y=1413, z=7} },
  [3]  = { type = "fire",  center = {x=1125, y=769,  z=7} },
  [4]  = { type = "fire",  center = {x=1181, y=838,  z=7} },
  [5]  = { type = "fire",  center = {x=1215, y=1049, z=7} },

  [6]  = { type = "water", center = {x=1052, y=860,  z=7} },
  [7]  = { type = "water", center = {x=846,  y=1017, z=7} },
  [8]  = { type = "water", center = {x=557,  y=1281, z=7} },
  [9]  = { type = "water", center = {x=839,  y=1347, z=7} },
  [10] = { type = "water", center = {x=1369, y=1574, z=7} },

  [11] = { type = "plant", center = {x=1128, y=1043,  z=7} },
  [12] = { type = "plant", center = {x=917,  y=905,   z=7} },
  [13] = { type = "plant", center = {x=955,  y=1146,  z=7} },
  [14] = { type = "plant", center = {x=1312, y=1300, z=7} },
  [15] = { type = "plant", center = {x=1012, y=1147,  z=7} },
}


-- Loot do baú
RAID_LOOT_TABLE = {
  [RAID_DIFF.EASY] = {
    picks = {1, 3},
    pool = {
      { id = 2160,  count = {40, 100} },
      { id = 2392,  count = {40, 100} },
      { id = 12344, count = {10,  20} },

      { id = 11441, count = 1 }, { id = 11442, count = 1 }, { id = 11443, count = 1 },
      { id = 11444, count = 1 }, { id = 11445, count = 1 }, { id = 11446, count = 1 },
      { id = 11447, count = 1 }, { id = 11448, count = 1 }, { id = 11449, count = 1 },
      { id = 11450, count = 1 }, { id = 11451, count = 1 }, { id = 11452, count = 1 },
      { id = 11453, count = 1 }, { id = 11454, count = 1 },
      { id = 12232, count = 1 }, { id = 12242, count = 1 },
      { id = 12244, count = 1 }, { id = 12245, count = 1 },
    }
  },

  [RAID_DIFF.MEDIUM] = {
    picks = {2, 3},
    extra = {
      {id=12706,count=1},{id=12707,count=1},{id=12708,count=1},{id=12709,count=1},{id=12710,count=1},
      {id=12711,count=1},{id=12712,count=1},{id=12713,count=1},{id=12714,count=1},{id=12715,count=1},
      {id=12716,count=1},{id=12717,count=1},{id=12718,count=1},{id=12719,count=1},{id=12720,count=1},
      {id=12721,count=1},{id=12722,count=1},{id=12723,count=1},{id=12724,count=1},{id=12725,count=1},
      {id=12726,count=1},

      { id = 12703, count = 1 },
      { id = 12681, count = 1 },
    }
  },

  [RAID_DIFF.HARD] = {
    picks = {2, 5},
    extra = {
      { id = 12704, count = 1 },
      { id = 12999, count = 1 },
      {id=12682,count=1},{id=12683,count=1},{id=12684,count=1},{id=12685,count=1},{id=12686,count=1},
      {id=12687,count=1},{id=12688,count=1},{id=12689,count=1},{id=12690,count=1},{id=12691,count=1},
      {id=12692,count=1},{id=12693,count=1},{id=12694,count=1},{id=12695,count=1},{id=12696,count=1},
      {id=12697,count=1},{id=12698,count=1},{id=12699,count=1},{id=12700,count=1},{id=12701,count=1},
      {id=12702,count=1},{id=14104,count=1},{id=14105,count=1},{id=14107,count=1},
    }
  },
}
