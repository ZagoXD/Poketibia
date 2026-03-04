local TM = {}

TM.rules = {
  consumeOnLearn       = true,

  usePerPokemon        = true,

  allowTypeFallback    = false,

  requireTypeMatch     = true,
  allowStatusAnyType   = false,

  maxMoveSlots         = 12,
  denyDuplicates       = true,
  minLevelDefault      = 1,
  defaultCd            = 20,
  perMove              = {},
}

TM.BLANK_ID = 12999

TM.byItem = {
  -- Water
  [12728] = "Bubbles",
  [12729] = "Water Gun",
  [12730] = "Waterball",
  [12731] = "Aqua Tail",
  [12732] = "Hydro Cannon",
  [12733] = "Bubble Blast",
  [12734] = "Hydropump",
  [12735] = "Water Pulse",
  [12736] = "Bubblebeam",
  [12737] = "Splash",
  [12738] = "Muddy Water",
  [12739] = "Clamp",
  [12740] = "Surf",
  [12741] = "Octazooka",

  -- Poison
  [12742] = "Poison Sting",
  [12743] = "Poison Fang",
  [12744] = "Sting Gun",
  [12745] = "Acid",
  [12746] = "Toxic Spikes",
  [12747] = "Toxic",
  [12748] = "Poison Bomb",
  [12749] = "Poison Gas",
  [12750] = "Sludge",
  [12751] = "Sludge Rain",
  [12752] = "Mortal Gas",
  [12753] = "Venom Motion",
  [12754] = "Venom Gale",
  [12755] = "Acid Armor",

  -- Dragon
  [12756] = "Rage",
  [12757] = "Dragon Claw",
  [12758] = "Dragon Breath",
  [12759] = "Twister",
  [12760] = "Draco Meteor",
  [12761] = "Dragon Pulse",

  -- Electric
  [12762] = "Thunder Shock",
  [12763] = "Thunder Bolt",
  [12764] = "Thunder Wave",
  [12765] = "Thunder",
  [12766] = "Thunder Punch",
  [12767] = "Electric Storm",
  [12768] = "Thunder Fang",
  [12769] = "Zap Cannon",
  [12770] = "Elecball",
  [12771] = "Electro Field",
  [12772] = "Charge",
  [12773] = "Spark",
  [12774] = "Charge Beam",

  -- Ghost / Dark utilitários
  [12775] = "Fear",
  [12776] = "Shadow Ball",
  [12777] = "Shadow Punch",
  [12778] = "Shadow Storm",
  [12779] = "Invisible",
  [12780] = "Nightmare",
  [12781] = "Night Shade",
  [12782] = "Dark Eye",
  [12783] = "Confuse Ray",
  [12784] = "Scary Face",

  -- Fighting
  [12785] = "Mega Kick",
  [12786] = "Triple Kick",
  [12787] = "Triple Kick Lee",
  [12788] = "Karate Chop",
  [12789] = "Ground Chop",
  [12790] = "Cross Chop",
  [12791] = "Mega Punch",
  [12792] = "Dizzy Punch",
  [12793] = "Ice Punch",
  [12794] = "Triple Punch",
  [12795] = "Fist Machine",
  [12796] = "Destroyer Hand",
  [12797] = "Multi-Kick",
  [12798] = "Multi-Punch",
  [12799] = "Furious Legs",
  [12800] = "Ultimate Champion",
  [12801] = "Rolling Kick",
  [12802] = "Fighter Spirit",
  [12803] = "Low Kick",

  -- Flying
  [12804] = "Wing Attack",
  [12805] = "Agility",          -- (Psychic)
  [12806] = "Gust",
  [12807] = "Whirlwind",
  [12808] = "Drill Peck",
  [12809] = "Tornado",
  [12810] = "Stickmerang",
  [12811] = "Stickslash",
  [12812] = "Stick Throw",
  [12813] = "Pluck",
  [12814] = "Air Cutter",
  [12815] = "Roost",
  [12816] = "Peck",
  [12817] = "Steel Wing",       -- (Steel)
  [12818] = "Air Slash",
  [12819] = "Feather Dance",
  [12820] = "Tailwind",
  [12821] = "Aerial Ace",
  [12822] = "Hurricane",

  -- Bug
  [12823] = "String Shot",
  [12824] = "Bug Bite",
  [12825] = "Fury Cutter",
  [12826] = "Pin Missile",
  [12827] = "X-Scissor",
  [12828] = "Team Slice",
  [12829] = "Red Fury",
  [12830] = "Team Claw",
  [12831] = "Megahorn",
  [12832] = "Bug Fighter",
  [12833] = "U-Turn",
  [12834] = "Struggle Bug",
  [12835] = "Shell Attack",

  -- Ground
  [12836] = "Sand Attack",
  [12837] = "Mud Shot",
  [12838] = "Mud Slap",
  [12839] = "Shockwave",
  [12840] = "Earthshock",
  [12841] = "Earthquake",
  [12842] = "Stomp",
  [12843] = "Crusher Stomp",
  [12844] = "Mud Bomb",
  [12845] = "Epicenter",
  [12846] = "Bonemerang",
  [12847] = "Bone Club",
  [12848] = "Bone Slash",
  [12849] = "Ground Crusher",
  [12850] = "Two Face Shock",
  [12851] = "Fissure",

  -- Grass
  [12852] = "Razor Leaf",
  [13002] = "Vine Whip",
  [13003] = "Leech Seed",
  [13004] = "Solar Beam",
  [13005] = "Bullet Seed",
  [13006] = "Leaf Storm",
  [13007] = "Absorb",
  [13008] = "Petal Dance",
  [13009] = "Super Vines",
  [12861] = "Magical Leaf",
  [12862] = "Leaf Blade",
  [12863] = "Aromateraphy",
  [12864] = "Synthesis",
  [12865] = "Cotton Spore",
  [12866] = "Giga Drain",
  [12867] = "Petal Tornado",
  [12868] = "Seed Bomb",

  -- Fire
  [12869] = "Ember",
  [12870] = "Flamethrower",
  [12871] = "Fireball",
  [12872] = "Fire Fang",
  [12873] = "Fire Blast",
  [12874] = "Raging Blast",
  [12875] = "Magma Storm",
  [12876] = "Flame Wheel",
  [12877] = "Tri Flames",
  [12878] = "Fire Punch",
  [12879] = "Sacred Fire",
  [12880] = "Blaze Kick",
  [12881] = "Overheat",
  [12882] = "Eruption",
  [12883] = "Sunny Day",
  [12884] = "Inferno",

  -- Ice
  [12885] = "Ice Punch",
  [12886] = "Ice Beam",
  [12887] = "Ice Shards",
  [12888] = "Icy Wind",
  [12889] = "Aurora Beam",
  [12890] = "Blizzard",
  [12891] = "Ice Fang",

  -- Psychic
  [12892] = "Calm Mind",
  [12893] = "Psybeam",
  [12894] = "Confusion",
  [12895] = "Psychic",
  [12896] = "Psywave",
  [12897] = "Hypnosis",
  [12898] = "Psy Pulse",
  [12899] = "Reflect",
  [12900] = "Psyusion",
  [12901] = "Dream Eater",
  [12902] = "Divine Punishment",
  [12903] = "Psy Ball",
  [12904] = "Psyshock",
  [12905] = "Miracle Eye",
  [12906] = "Mimic Wall",
  [12907] = "Magic Coat",
  [12908] = "Power Wave",
  [12909] = "Psy Impact",
  [12910] = "Future Sight",

  -- Rock
  [12911] = "Rollout",
  [12912] = "Rock Throw",
  [12913] = "Rock Slide",
  [12914] = "Falling Rocks",
  [12915] = "Rock Drill",
  [12916] = "Ancient Power",
  [12917] = "Rock Blast",
  [12918] = "Power Gem",
  [12919] = "Stone Edge",

  -- Steel
  [12920] = "Iron Tail",
  [12921] = "Iron Defense",
  [12922] = "Steel Wing",
  [12923] = "Metal Claw",

  -- Normal (e afins)
  [12924] = "Quick Attack",
  [12925] = "Headbutt",
  [12926] = "Sleep Powder",     -- (Grass)
  [12927] = "Stun Spore",       -- (Grass)
  [12928] = "Poison Powder",    -- (Poison)
  [12929] = "Body Slam",
  [12930] = "Scratch",
  [12931] = "Harden",
  [12932] = "Skull Bash",
  [12933] = "Super Sonic",
  [12934] = "Horn Attack",
  [12935] = "Strafe",
  [12936] = "Roar",
  [12937] = "Horn Drill",
  [12938] = "Doubleslap",
  [12939] = "Lovely Kiss",
  [12940] = "Sing",
  [12941] = "Selfheal",
  [12942] = "Restore",
  [12943] = "Multislap",
  [12944] = "Metronome",
  [12945] = "Focus",
  [12946] = "Hyper Voice",
  [12947] = "Healarea",
  [12948] = "Slash",
  [12949] = "Pay Day",
  [12950] = "War Dog",
  [12951] = "Selfdestruct",
  [12952] = "Sonicboom",
  [12953] = "Tri-Attack",
  [12954] = "Fury Attack",
  [12955] = "Rest",             -- (Psychic)
  [12956] = "Egg Bomb",
  [12957] = "Swift",
  [12958] = "Shredder Team",
  [12959] = "Great Love",
  [12960] = "Guillotine",
  [12961] = "Hyper Beam",
  [12962] = "Thrash",
  [12963] = "Crabhammer",       -- (Water)
  [12964] = "Ancient Fury",
  [12965] = "Camouflage",
  [12966] = "SmokeScreen",
  [12967] = "Meteor Smash",
  [12968] = "ExtremeSpeed",
  [12969] = "Egg Rain",
  [12970] = "Emergency Call",
  [12971] = "Safeguard",
  [12972] = "Swords Dance",
  [12973] = "Defense Curl",
  [12974] = "Double Team",
  [12975] = "Charm",
  [12976] = "Tackle",
  [12977] = "Take Down",
  [12978] = "Minimize",
  [12979] = "Yawn",
  [12980] = "Tongue Grap",
  [12981] = "Tongue Hook",
  [12982] = "Present",
  [12983] = "Wrap",
  [12984] = "Rock n'Roll",
  [12985] = "Last Resort",
  [12986] = "Echoed Voice",
  [12987] = "Squisky Licking",
  [12988] = "Lick",
  [12989] = "Bite",

  -- Dark
  [12990] = "Shadowave",
  [12991] = "Faint Attack",
  [12992] = "Assurance",
  [12993] = "Pursuit",
  [12994] = "Crunch",
  [12995] = "Night Daze",
  [12996] = "Dark Pulse",
  [12997] = "Sucker Punch",
  [12998] = "Elemental Hands",
}

TM.moveType = {}

local EX = {
  ["Agility"]        = "Psychic",
  ["Roost"]          = "Flying",
  ["Tailwind"]       = "Flying",
  ["Calm Mind"]      = "Psychic",
  ["Reflect"]        = "Psychic",
  ["Magic Coat"]     = "Psychic",
  ["Hypnosis"]       = "Psychic",
  ["Rest"]           = "Psychic",
  ["Sleep Powder"]   = "Grass",
  ["Stun Spore"]     = "Grass",
  ["Poison Powder"]  = "Poison",
  ["Sunny Day"]      = "Fire",
  ["Aromateraphy"]   = "Grass",
  ["Synthesis"]      = "Grass",
  ["Safeguard"]      = "Normal",
  ["Swords Dance"]   = "Normal",
  ["Defense Curl"]   = "Normal",
  ["Double Team"]    = "Normal",
  ["Camouflage"]     = "Normal",
  ["SmokeScreen"]    = "Normal",

  ["Steel Wing"]     = "Steel",
  ["Ice Punch"]      = "Ice",

  ["Confuse Ray"]    = "Ghost",
  ["Scary Face"]     = "Normal",
  ["Dark Eye"]       = "Dark",

  ["Crabhammer"]     = "Water",
  ["Lick"]           = "Ghost",
  ["Bite"]           = "Dark",

  ["Stomp"]          = "Normal",
  ["Shockwave"]      = "Electric",
}

for m,t in pairs(EX) do TM.moveType[m] = t end

local function addBucket(ttype, names)
  for _,n in ipairs(names) do
    if not TM.moveType[n] then TM.moveType[n] = ttype end
  end
end

addBucket("Water", {
  "Bubbles","Water Gun","Waterball","Aqua Tail","Hydro Cannon","Bubble Blast","Hydropump",
  "Water Pulse","Bubblebeam","Splash","Muddy Water","Clamp","Surf","Octazooka"
})

addBucket("Poison", {
  "Poison Sting","Poison Fang","Sting Gun","Acid","Toxic Spikes","Toxic","Poison Bomb","Poison Gas",
  "Sludge","Sludge Rain","Mortal Gas","Venom Motion","Venom Gale","Acid Armor"
})

addBucket("Dragon", {"Rage","Dragon Claw","Dragon Breath","Twister","Draco Meteor","Dragon Pulse"})

addBucket("Electric", {
  "Thunder Shock","Thunder Bolt","Thunder Wave","Thunder","Thunder Punch","Electric Storm","Thunder Fang",
  "Zap Cannon","Elecball","Electro Field","Charge","Spark","Charge Beam"
})

addBucket("Ghost", {
  "Fear","Shadow Ball","Shadow Punch","Shadow Storm","Invisible","Nightmare","Night Shade"
})

addBucket("Fighting", {
  "Mega Kick","Triple Kick","Triple Kick Lee","Karate Chop","Ground Chop","Cross Chop","Mega Punch",
  "Dizzy Punch","Triple Punch","Fist Machine","Destroyer Hand","Multi-Kick","Multi-Punch","Furious Legs",
  "Ultimate Champion","Rolling Kick","Fighter Spirit","Low Kick"
})

addBucket("Flying", {
  "Wing Attack","Gust","Whirlwind","Drill Peck","Tornado","Stickmerang","Stickslash","Stick Throw",
  "Pluck","Air Cutter","Peck","Air Slash","Feather Dance","Aerial Ace","Hurricane"
})

addBucket("Bug", {
  "String Shot","Bug Bite","Fury Cutter","Pin Missile","X-Scissor","Team Slice","Red Fury","Team Claw",
  "Megahorn","Bug Fighter","U-Turn","Struggle Bug","Shell Attack"
})

addBucket("Ground", {
  "Sand Attack","Mud Shot","Mud Slap","Earthshock","Earthquake","Crusher Stomp","Mud Bomb",
  "Epicenter","Bonemerang","Bone Club","Bone Slash","Ground Crusher","Two Face Shock","Fissure"
})

addBucket("Grass", {
  "Razor Leaf","Vine Whip","Leech Seed","Solar Beam","Bullet Seed","Leaf Storm","Absorb","Petal Dance",
  "Super Vines","Magical Leaf","Leaf Blade","Cotton Spore","Giga Drain","Petal Tornado","Seed Bomb"
})

addBucket("Fire", {
  "Ember","Flamethrower","Fireball","Fire Fang","Fire Blast","Raging Blast","Magma Storm","Flame Wheel",
  "Tri Flames","Fire Punch","Sacred Fire","Blaze Kick","Overheat","Eruption","Inferno"
})

addBucket("Ice", {"Ice Beam","Ice Shards","Icy Wind","Aurora Beam","Blizzard","Ice Fang"})

addBucket("Psychic", {
  "Psybeam","Confusion","Psychic","Psywave","Psy Pulse","Psyusion","Dream Eater","Divine Punishment",
  "Psy Ball","Psyshock","Miracle Eye","Mimic Wall","Power Wave","Psy Impact","Future Sight"
})

addBucket("Rock", {
  "Rollout","Rock Throw","Rock Slide","Falling Rocks","Rock Drill","Ancient Power","Rock Blast",
  "Power Gem","Stone Edge"
})

addBucket("Steel", {"Iron Tail","Iron Defense","Metal Claw"})

addBucket("Normal", {
  "Quick Attack","Headbutt","Body Slam","Scratch","Harden","Skull Bash","Super Sonic","Horn Attack",
  "Strafe","Roar","Horn Drill","Doubleslap","Lovely Kiss","Sing","Selfheal","Restore","Multislap",
  "Metronome","Focus","Hyper Voice","Healarea","Slash","Pay Day","War Dog","Selfdestruct","Sonicboom",
  "Tri-Attack","Fury Attack","Egg Bomb","Swift","Shredder Team","Great Love","Guillotine","Hyper Beam",
  "Thrash","Ancient Fury","Meteor Smash","ExtremeSpeed","Egg Rain","Emergency Call","Charm","Tackle",
  "Take Down","Minimize","Yawn","Tongue Grap","Tongue Hook","Present","Wrap","Rock n'Roll",
  "Last Resort","Echoed Voice","Squisky Licking"
})

addBucket("Dark", {
  "Shadowave","Faint Attack","Assurance","Pursuit","Crunch","Night Daze","Dark Pulse","Sucker Punch",
  "Elemental Hands"
})

TM.aliasToBase = {
  -- ["Shiny Bulbasaur"]       = "Bulbasaur",
}

TM.learnsetByMove = {
  -- Water
  ["Bubbles"] = {"Poliwrath", "Gyarados", "Lapras", "Vaporeon"},
  ["Water Gun"] = {"Poliwrath", "Gyarados", "Lapras", "Vaporeon", "Blastoise"},
  ["Waterball"] = {"Gyarados", "Lapras", "Vaporeon", "Kingler", "Poliwrath"},
  ["Aqua Tail"] = {"Gyarados", "Lapras", "Dragonite", "Feraligatr"},
  ["Hydro Cannon"] = {"Gyarados", "Lapras", "Vaporeon", "Feraligatr", "Blastoise"},
  ["Bubble Blast"] = {"Gyarados", "Lapras", "Vaporeon", "Poliwrath"},
  ["Hydropump"] = {"Gyarados", "Lapras", "Vaporeon", "Blastoise", "Feraligatr"},
  ["Water Pulse"] = {"Gyarados", "Lapras", "Blastoise", "Feraligatr"},
  ["Bubblebeam"] = {"Gyarados", "Lapras", "Vaporeon", "Blastoise"},
  ["Splash"] = {}, -- Apenas Magikarp
  ["Muddy Water"] = {"Gyarados", "Lapras", "Blastoise", "Feraligatr"},
  ["Clamp"] = {"Kingler", "Kabutops"},
  ["Surf"] = {"Gyarados", "Lapras", "Blastoise", "Feraligatr", "Vaporeon"},
  ["Octazooka"] = {"Blastoise", "Tentacruel", "Kingler"},

  -- Poison
  ["Poison Sting"] = {"Arbok", "Nidoking", "Venomoth"},
  ["Poison Fang"] = {"Arbok", "Nidoking", "Crobat"},
  ["Sting Gun"] = {"Beedrill", "Venomoth", "Ariados"},
  ["Acid"] = {"Arbok", "Tentacruel", "Muk"},
  ["Toxic Spikes"] = {"Arbok", "Venomoth", "Crobat"},
  ["Toxic"] = {"Arbok", "Muk", "Weezing", "Crobat"},
  ["Poison Bomb"] = {"Arbok", "Muk", "Weezing", "Crobat"},
  ["Poison Gas"] = {"Arbok", "Muk", "Weezing"},
  ["Sludge"] = {"Arbok", "Weezing", "Crobat"},
  ["Sludge Rain"] = {"Arbok", "Weezing", "Muk"},
  ["Mortal Gas"] = {"Arbok", "Muk", "Crobat"},
  ["Venom Motion"] = {"Arbok", "Crobat", "Tentacruel"},
  ["Venom Gale"] = {"Arbok", "Crobat", "Tentacruel"},
  ["Acid Armor"] = {"Tentacruel", "Weezing"},

  -- Dragon
  ["Rage"] = {"Blastoise", "Gyarados", "Dragonite", "Charizard", "Aerodactyl"},
  ["Dragon Claw"] = {"Gyarados", "Aerodactyl", "Charizard"},
  ["Dragon Breath"] = {"Charizard", "Aerodactyl", "Gyarados"},
  ["Twister"] = {"Charizard", "Gyarados", "Aerodactyl"},
  ["Draco Meteor"] = {"Dragonite", "Charizard", "Gyarados"},
  ["Dragon Pulse"] = {"Dragonite", "Charizard", "Gyarados"},

  -- Electric
  ["Thunder Shock"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Thunder Bolt"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Thunder Wave"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Thunder"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Thunder Punch"] = {"Pikachu", "Raichu", "Electabuzz", "Machamp"},
  ["Electric Storm"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Thunder Fang"] = {"Arcanine", "Nidoking", "Dragonite"},
  ["Zap Cannon"] = {"Magneton", "Electabuzz", "Porygon2"},
  ["Elecball"] = {"Pikachu", "Raichu", "Magneton"},
  ["Electro Field"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Charge"] = {"Pikachu", "Raichu", "Magneton", "Electabuzz"},
  ["Spark"] = {"Pikachu", "Raichu", "Electabuzz"},
  ["Charge Beam"] = {"Magneton", "Electabuzz", "Porygon2"},
  ["Shockwave"] = {"Magneton", "Electabuzz", "Raichu"},

  -- Ghost / Dark 
  ["Fear"] = {"Gyarados", "Dragonite", "Tyranitar", "Charizard"},
  ["Shadow Ball"] = {"Alakazam", "Gengar", "Misdreavus"},
  ["Shadow Punch"] = {"Machamp", "Hitmonchan", "Gengar"},
  ["Shadow Storm"] = {"Gengar", "Misdreavus", "Alakazam"},
  ["Invisible"] = {"Alakazam", "Gengar", "Misdreavus"},
  ["Nightmare"] = {"Alakazam", "Gengar", "Misdreavus"},
  ["Night Shade"] = {"Alakazam", "Gengar", "Misdreavus"},
  ["Dark Eye"] = {"Alakazam", "Gengar", "Misdreavus"},
  ["Confuse Ray"] = {"Alakazam", "Gengar", "Misdreavus"},
  ["Scary Face"] = {"Gyarados", "Dragonite", "Tyranitar", "Charizard"},

  -- Fighting
  ["Mega Kick"] = {"Blastoise", "Kangaskhan", "Snorlax", "Tyranitar"},
  ["Triple Kick"] = {"Hitmonlee", "Hitmontop", "Machamp"},
  ["Triple Kick Lee"] = {"Hitmonlee", "Machamp"},
  ["Karate Chop"] = {"Machamp", "Hitmonchan", "Primeape"},
  ["Ground Chop"] = {"Machamp", "Hitmonlee", "Poliwrath"},
  ["Cross Chop"] = {"Machamp", "Hitmonchan", "Poliwrath"},
  ["Mega Punch"] = {"Machamp", "Hitmonchan", "Kangaskhan"},
  ["Dizzy Punch"] = {"Hitmonchan", "Kangaskhan", "Snorlax"},
  ["Ice Punch"] = {"Hitmonchan", "Machamp", "Poliwrath"},
  ["Triple Punch"] = {"Hitmonchan", "Machamp"},
  ["Fist Machine"] = {"Machamp", "Hitmonchan"},
  ["Destroyer Hand"] = {"Machamp", "Hitmonchan"},
  ["Multi-Kick"] = {"Hitmonlee", "Machamp"},
  ["Multi-Punch"] = {"Hitmonchan", "Machamp"},
  ["Furious Legs"] = {"Hitmonlee", "Machamp"},
  ["Ultimate Champion"] = {"Hitmonchan", "Machamp"},
  ["Rolling Kick"] = {"Hitmontop", "Hitmonlee"},
  ["Fighter Spirit"] = {"Hitmontop", "Machamp"},
  ["Low Kick"] = {"Hitmonlee", "Machamp", "Primeape"},

  -- Flying
  ["Wing Attack"] = {"Charizard", "Dragonite", "Gyarados", "Aerodactyl"},
  ["Agility"] = {"Dragonite", "Aerodactyl", "Charizard"},
  ["Gust"] = {"Butterfree", "Charizard", "Dragonite"},
  ["Whirlwind"] = {"Charizard", "Dragonite", "Gyarados"},
  ["Drill Peck"] = {"Fearow", "Dodrio", "Pidgeot"},
  ["Tornado"] = {"Charizard", "Dragonite", "Gyarados"},
  ["Stickmerang"] = {"Farfetch'd"}, -- Exclusivo
  ["Stickslash"] = {"Farfetch'd"}, -- Exclusivo
  ["Stick Throw"] = {"Farfetch'd"}, -- Exclusivo
  ["Pluck"] = {"Fearow", "Dodrio", "Pidgeot"},
  ["Air Cutter"] = {"Charizard", "Dragonite", "Crobat"},
  ["Roost"] = {"Charizard", "Dragonite", "Aerodactyl"},
  ["Peck"] = {"Fearow", "Dodrio", "Pidgeot"},
  ["Steel Wing"] = {"Skarmory", "Dragonite", "Charizard"},
  ["Air Slash"] = {"Charizard", "Dragonite", "Crobat"},
  ["Feather Dance"] = {"Pidgeot", "Fearow", "Dodrio"},
  ["Tailwind"] = {"Charizard", "Dragonite", "Pidgeot"},
  ["Aerial Ace"] = {"Charizard", "Dragonite", "Pidgeot"},
  ["Hurricane"] = {"Charizard", "Dragonite", "Gyarados"},

  -- Bug
  ["String Shot"] = {"Butterfree", "Beedrill", "Venomoth"},
  ["Bug Bite"] = {"Butterfree", "Beedrill", "Venomoth"},
  ["Fury Cutter"] = {"Scyther", "Pinsir", "Scizor"},
  ["Pin Missile"] = {"Beedrill", "Jolteon", "Ariados"},
  ["X-Scissor"] = {"Scyther", "Pinsir", "Scizor"},
  ["Team Slice"] = {"Scyther", "Scizor"},
  ["Red Fury"] = {"Scyther", "Scizor"},
  ["Team Claw"] = {"Scyther", "Scizor"},
  ["Megahorn"] = {"Heracross", "Nidoking", "Rhydon"},
  ["Bug Fighter"] = {"Heracross", "Pinsir"},
  ["U-Turn"] = {"Scyther", "Scizor", "Pinsir"},
  ["Struggle Bug"] = {"Butterfree", "Beedrill", "Venomoth"},
  ["Shell Attack"] = {"Shellder", "Cloyster", "Kabutops"},

  -- Ground
  ["Sand Attack"] = {"Dugtrio", "Sandslash", "Golem"},
  ["Mud Shot"] = {"Dugtrio", "Sandslash", "Golem"},
  ["Mud Slap"] = {"Dugtrio", "Sandslash", "Golem"},
  ["Earthshock"] = {"Dugtrio", "Sandslash", "Golem", "Rhydon"},
  ["Earthquake"] = {"Dugtrio", "Sandslash", "Golem", "Rhydon", "Tyranitar"},
  ["Stomp"] = {"Rhydon", "Nidoking", "Kangaskhan"},
  ["Crusher Stomp"] = {"Rhydon", "Nidoking", "Tyranitar"},
  ["Mud Bomb"] = {"Dugtrio", "Sandslash", "Golem"},
  ["Epicenter"] = {"Dugtrio", "Golem", "Rhydon", "Tyranitar"},
  ["Bonemerang"] = {"Marowak"}, -- Exclusivo
  ["Bone Club"] = {"Marowak"}, -- Exclusivo
  ["Bone Slash"] = {"Marowak"}, -- Exclusivo
  ["Ground Crusher"] = {"Rhydon", "Golem", "Tyranitar"},
  ["Two Face Shock"] = {"Piloswine", "Quagsire"},
  ["Fissure"] = {"Dugtrio", "Golem", "Rhydon"},

  -- Grass (+ EX)
  ["Razor Leaf"] = {"Venusaur", "Victreebel", "Exeggutor"},
  ["Vine Whip"] = {"Venusaur", "Victreebel", "Tangela"},
  ["Leech Seed"] = {"Venusaur", "Victreebel", "Exeggutor"},
  ["Solar Beam"] = {"Venusaur", "Exeggutor", "Victreebel"},
  ["Bullet Seed"] = {"Venusaur", "Exeggutor", "Victreebel"},
  ["Leaf Storm"] = {"Venusaur", "Exeggutor", "Victreebel"},
  ["Absorb"] = {"Venusaur", "Vileplume", "Victreebel"},
  ["Petal Dance"] = {"Venusaur", "Vileplume", "Bellossom"},
  ["Super Vines"] = {"Venusaur", "Tangela", "Victreebel"},
  ["Magical Leaf"] = {"Venusaur", "Exeggutor", "Alakazam"},
  ["Leaf Blade"] = {"Scyther", "Scizor", "Kabutops"},
  ["Aromateraphy"] = {"Venusaur", "Vileplume", "Bellossom"},
  ["Synthesis"] = {"Venusaur", "Exeggutor", "Victreebel"},
  ["Cotton Spore"] = {"Venusaur", "Jumpluff", "Ampharos"},
  ["Giga Drain"] = {"Venusaur", "Exeggutor", "Victreebel"},
  ["Petal Tornado"] = {"Venusaur", "Vileplume", "Bellossom"},
  ["Seed Bomb"] = {"Venusaur", "Exeggutor", "Victreebel"},

  -- Fire
  ["Ember"] = {"Charizard", "Arcanine", "Rapidash", "Magmar"},
  ["Flamethrower"] = {"Charizard", "Arcanine", "Rapidash", "Magmar"},
  ["Fireball"] = {"Charizard", "Arcanine", "Rapidash", "Magmar"},
  ["Fire Fang"] = {"Charizard", "Arcanine", "Dragonite"},
  ["Fire Blast"] = {"Charizard", "Arcanine", "Rapidash", "Magmar", "Typhlosion"},
  ["Raging Blast"] = {"Charizard", "Arcanine", "Magmar", "Typhlosion"},
  ["Magma Storm"] = {"Charizard", "Arcanine", "Magmar", "Typhlosion"},
  ["Flame Wheel"] = {"Arcanine", "Rapidash", "Typhlosion"},
  ["Tri Flames"] = {"Charizard", "Arcanine", "Typhlosion"},
  ["Fire Punch"] = {"Machamp", "Hitmonchan", "Charizard"},
  ["Sacred Fire"] = {"Rapidash", "Ponyta", "Arcanine", "Charizard"},
  ["Blaze Kick"] = {"Hitmonlee", "Charizard", "Arcanine"},
  ["Overheat"] = {"Charizard", "Arcanine", "Typhlosion"},
  ["Eruption"] = {"Charizard", "Typhlosion", "Golem"},
  ["Sunny Day"] = {"Charizard", "Venusaur", "Exeggutor"},
  ["Inferno"] = {"Charizard", "Typhlosion", "Magmar"},

  -- Ice
  ["Ice Beam"] = {"Lapras", "Dewgong", "Cloyster", "Articuno"},
  ["Ice Shards"] = {"Lapras", "Dewgong", "Cloyster"},
  ["Icy Wind"] = {"Lapras", "Dewgong", "Articuno"},
  ["Aurora Beam"] = {"Lapras", "Dewgong", "Cloyster"},
  ["Blizzard"] = {"Lapras", "Articuno", "Dewgong"},
  ["Ice Fang"] = {"Lapras", "Dragonite", "Gyarados"},

  -- Psychic (+ EX)
  ["Calm Mind"] = {"Alakazam", "Mewtwo", "Espeon", "Slowking"},
  ["Psybeam"] = {"Alakazam", "Mewtwo", "Espeon", "Starmie"},
  ["Confusion"] = {"Alakazam", "Mewtwo", "Espeon", "Slowking"},
  ["Psychic"] = {"Alakazam", "Mewtwo", "Espeon", "Slowking"},
  ["Psywave"] = {"Alakazam", "Mewtwo", "Espeon", "Slowking"},
  ["Hypnosis"] = {"Alakazam", "Mewtwo", "Gengar", "Slowking"},
  ["Psy Pulse"] = {"Alakazam", "Mewtwo", "Espeon", "Slowking"},
  ["Reflect"] = {"Alakazam", "Mewtwo", "Espeon", "Slowking"},
  ["Psyusion"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Dream Eater"] = {"Alakazam", "Gengar", "Mewtwo"},
  ["Divine Punishment"] = {"Mewtwo"}, -- Exclusivo
  ["Psy Ball"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Psyshock"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Miracle Eye"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Mimic Wall"] = {"Mr. Mime"}, -- Exclusivo
  ["Magic Coat"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Power Wave"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Psy Impact"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Future Sight"] = {"Alakazam", "Mewtwo", "Espeon"},

  -- Rock
  ["Rollout"] = {"Golem", "Rhydon", "Tyranitar"},
  ["Rock Throw"] = {"Golem", "Rhydon", "Tyranitar", "Aerodactyl"},
  ["Rock Slide"] = {"Golem", "Rhydon", "Tyranitar", "Aerodactyl"},
  ["Falling Rocks"] = {"Golem", "Rhydon", "Tyranitar", "Aerodactyl"},
  ["Rock Drill"] = {"Rhydon", "Aerodactyl", "Tyranitar"},
  ["Ancient Power"] = {"Golem", "Rhydon", "Tyranitar", "Aerodactyl"},
  ["Rock Blast"] = {"Golem", "Rhydon", "Tyranitar"},
  ["Power Gem"] = {"Golem", "Rhydon", "Tyranitar"},
  ["Stone Edge"] = {"Golem", "Rhydon", "Tyranitar", "Aerodactyl"},

  -- Steel
  ["Iron Tail"] = {"Dragonite", "Tyranitar", "Steelix", "Scizor"},
  ["Iron Defense"] = {"Steelix", "Scizor", "Forretress"},
  ["Metal Claw"] = {"Dragonite", "Tyranitar", "Scizor"},

  -- Normal
  ["Quick Attack"] = {"Dragonite", "Aerodactyl", "Tyranitar", "Charizard"},
  ["Headbutt"] = {"Dragonite", "Tyranitar", "Snorlax"},
  ["Sleep Powder"] = {"Venusaur", "Vileplume", "Victreebel"},
  ["Stun Spore"] = {"Venusaur", "Vileplume", "Victreebel"},
  ["Poison Powder"] = {"Venusaur", "Vileplume", "Victreebel"},
  ["Body Slam"] = {"Dragonite", "Tyranitar", "Snorlax"},
  ["Scratch"] = {"Dragonite", "Tyranitar", "Aerodactyl"},
  ["Harden"] = {"Dragonite", "Tyranitar", "Steelix"},
  ["Skull Bash"] = {"Blastoise", "Rhydon", "Tyranitar"},
  ["Super Sonic"] = {"Butterfree", "Crobat", "Noctowl"},
  ["Horn Attack"] = {"Rhydon", "Nidoking", "Heracross"},
  ["Strafe"] = {"Dragonite", "Aerodactyl", "Tyranitar"},
  ["Roar"] = {"Dragonite", "Tyranitar", "Charizard"},
  ["Horn Drill"] = {"Rhydon", "Nidoking", "Heracross"},
  ["Doubleslap"] = {"Hitmonchan", "Machamp", "Kangaskhan"},
  ["Lovely Kiss"] = {"Jynx", "Clefable", "Wigglytuff"},
  ["Sing"] = {"Jynx", "Clefable", "Wigglytuff"},
  ["Selfheal"] = {"Blissey", "Chansey", "Snorlax"},
  ["Restore"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Multislap"] = {"Hitmonchan", "Machamp", "Kangaskhan"},
  ["Metronome"] = {"Clefable", "Wigglytuff", "Togetic"},
  ["Focus"] = {"Alakazam", "Mewtwo", "Espeon"},
  ["Hyper Voice"] = {"Dragonite", "Tyranitar", "Snorlax"},
  ["Healarea"] = {"Blissey", "Chansey", "Clefable"},
  ["Slash"] = {"Dragonite", "Tyranitar", "Aerodactyl"},
  ["Pay Day"] = {"Meowth", "Persian"}, -- Exclusivo
  ["War Dog"] = {"Arcanine", "Houndoom", "Granbull"},
  ["Selfdestruct"] = {"Golem", "Weezing", "Forretress"},
  ["Sonicboom"] = {"Magneton", "Electrode", "Porygon2"},
  ["Tri-Attack"] = {"Porygon2", "Dodrio", "Magneton"},
  ["Fury Attack"] = {"Nidoking", "Rhydon", "Heracross"},
  ["Rest"] = {"Snorlax", "Blissey", "Chansey"},
  ["Egg Bomb"] = {"Blissey", "Chansey", "Exeggutor"},
  ["Swift"] = {"Dragonite", "Tyranitar", "Aerodactyl"},
  ["Shredder Team"] = {"Scyther", "Scizor", "Pinsir"},
  ["Great Love"] = {"Blissey", "Chansey", "Clefable"},
  ["Guillotine"] = {"Kingler", "Pinsir", "Scizor"},
  ["Hyper Beam"] = {"Dragonite", "Tyranitar", "Snorlax", "Gyarados"},
  ["Thrash"] = {"Dragonite", "Tyranitar", "Ursaring"},
  ["Crabhammer"] = {"Kingler"}, -- Exclusivo
  ["Ancient Fury"] = {"Charizard", "Blastoise", "Venusaur"},
  ["Camouflage"] = {"Ditto", "Kecleon"}, -- Exclusivo
  ["SmokeScreen"] = {"Charizard", "Gyarados", "Dragonite"},
  ["Meteor Smash"] = {"Clefable", "Jigglypuff"},
  ["ExtremeSpeed"] = {"Dragonite", "Aerodactyl", "Tyranitar"},
  ["Egg Rain"] = {"Blissey", "Chansey", "Exeggutor"},
  ["Emergency Call"] = {"Blissey", "Chansey", "Kangaskhan"},
  ["Safeguard"] = {"Blissey", "Chansey", "Clefable"},
  ["Swords Dance"] = {"Scyther", "Scizor", "Pinsir"},
  ["Defense Curl"] = {"Dragonite", "Tyranitar", "Steelix"},
  ["Double Team"] = {"Alakazam", "Mewtwo", "Gengar"},
  ["Charm"] = {"Clefable", "Wigglytuff", "Togetic"},
  ["Tackle"] = {"Dragonite", "Tyranitar", "Snorlax"},
  ["Take Down"] = {"Dragonite", "Tyranitar", "Ursaring"},
  ["Minimize"] = {"Clefable", "Wigglytuff", "Chansey"},
  ["Yawn"] = {"Snorlax", "Slowking", "Blissey"},
  ["Tongue Grap"] = {"Lickitung", "Politoed"},
  ["Tongue Hook"] = {"Lickitung", "Politoed"},
  ["Present"] = {"Delibird"}, -- Exclusivo
  ["Wrap"] = {"Dragonite", "Gyarados", "Arbok"},
  ["Rock n'Roll"] = {"Wigglytuff", "Jigglypuff", "Clefable"},
  ["Last Resort"] = {"Eevee", "Umbreon", "Espeon"},
  ["Echoed Voice"] = {"Noctowl", "Wigglytuff", "Exploud"},
  ["Squisky Licking"] = {"Lickitung"}, -- Exclusivo
  ["Lick"] = {"Lickitung", "Gengar", "Haunter"},
  ["Bite"] = {"Dragonite", "Tyranitar", "Aerodactyl"},

  -- Dark
  ["Shadowave"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Faint Attack"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Assurance"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Pursuit"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Crunch"] = {"Tyranitar", "Houndoom", "Dragonite"},
  ["Night Daze"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Dark Pulse"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Sucker Punch"] = {"Tyranitar", "Houndoom", "Umbreon"},
  ["Elemental Hands"] = {"Hitmonchan"}, -- Exclusivo
}

TM.byMove = {}
for itemId, moveName in pairs(TM.byItem) do
  if not TM.byMove[moveName] then
    TM.byMove[moveName] = itemId
  end
end

_G.TM = TM
return TM
