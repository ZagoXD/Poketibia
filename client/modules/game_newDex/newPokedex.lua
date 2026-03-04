-- Public functions
function init()
newpokedex = "Bulbasaur;Ivysaur;Venusaur;Charmander;Charmeleon;Charizard;Squirtle;Wartortle;Blastoise;Caterpie;Metapod;Butterfree;Weedle;Kakuna;Beedrill;Pidgey;Pidgeotto;Pidgeot;Rattata;Raticate;Spearow;Fearow;Ekans;Arbok;Pikachu;Raichu;Sandshrew;Sandslash;Nidoran Female;Nidorina;Nidoqueen;Nidoran Male;Nidorino;Nidoking;Clefairy;Clefable;Vulpix;Ninetales;Jigglypuff;Wigglytuff;Zubat;Golbat;Oddish;Gloom;Vileplume;Paras;Parasect;Venonat;Venomoth;Diglett;Dugtrio;Meowth;Persian;Psyduck;Golduck;Mankey;Primeape;Growlithe;Arcanine;Poliwag;Poliwhirl;Poliwrath;Abra;Kadabra;Alakazam;Machop;Machoke;Machamp;Bellsprout;Weepinbell;Victreebel;Tentacool;Tentacruel;Geodude;Graveler;Golem;Ponyta;Rapidash;Slowpoke;Slowbro;Magnemite;Magneton;Farfetch'd;Doduo;Dodrio;Seel;Dewgong;Grimer;Muk;Shellder;Cloyster;Gastly;Haunter;Gengar;Onix;Drowzee;Hypno;Krabby;Kingler;Voltorb;Electrode;Exeggcute;Exeggutor;Cubone;Marowak;Hitmonlee;Hitmonchan;Lickitung;Koffing;Weezing;Rhyhorn;Rhydon;Chansey;Tangela;Kangaskhan;Horsea;Seadra;Goldeen;Seaking;Staryu;Starmie;Mr. Mime;Scyther;Jynx;Electabuzz;Magmar;Pinsir;Tauros;Magikarp;Gyarados;Lapras;Ditto;Eevee;Vaporeon;Jolteon;Flareon;Porygon;Omanyte;Omastar;Kabuto;Kabutops;Aerodactyl;Snorlax;Articuno;Zapdos;Moltres;Dratini;Dragonair;Dragonite;Mewtwo;Mew;Chikorita;Bayleef;Meganium;Cyndaquil;Quilava;Typhlosion;Totodile;Croconaw;Feraligatr;Sentret;Furret;Hoothoot;Noctowl;Ledyba;Ledian;Spinarak;Ariados;Crobat;Chinchou;Lanturn;Pichu;Cleffa;Igglybuff;Togepi;Togetic;Natu;Xatu;Mareep;Flaaffy;Ampharos;Bellossom;Marill;Azumarill;Sudowoodo;Politoed;Hoppip;Skiploom;Jumpluff;Aipom;Sunkern;Sunflora;Yanma;Wooper;Quagsire;Espeon;Umbreon;Murkrow;Slowking;Misdreavus;Unown;Wobbuffet;Girafarig;Pineco;Forretress;Dunsparce;Gligar;Steelix;Snubbull;Granbull;Qwilfish;Scizor;Shuckle;Heracross;Sneasel;Teddiursa;Ursaring;Slugma;Magcargo;Swinub;Piloswine;Corsola;Remoraid;Octillery;Delibird;Mantine;Skarmory;Houndour;Houndoom;Kingdra;Phanpy;Donphan;Porygon2;Stantler;Smeargle;Tyrogue;Hitmontop;Smoochum;Elekid;Magby;Miltank;Blissey;Raikou;Entei;Suicune;Larvitar;Pupitar;Tyranitar;Lugia;Ho-oh;Celebi;Treecko;Grovyle;Sceptile;Torchic;Combusken;Blaziken;Mudkip;Marshtomp;Swampert;Swampert;Mightyena;Zigzagoon;Linoone;Wurmple;Silcoon;Beautifly;Cascoon;Dustox;Lotad;Lombre;Ludicolo;Seedot;Nuzleaf;Shiftry;Taillow;Swellow;Wingull;Pelipper;Ralts;Kirlia;Gardevoir;Surskit;Masquerain;Shroomish;Breloom;Slakoth;Vigoroth;Slaking;Nincada;Ninjask;Shedinja;Whismur;Loudred;Exploud;Makuhita;Hariyama;Azurill;Nosepass;Skitty;Delcatty;Sableye;Mawile;Aron;Lairon;Aggron;Meditite;Medicham;Electrike;Manectric;Plusle;Minun;Volbeat;Illumise;Roselia;Gulpin;Swalot;Carvanha;Sharpedo;Wailmer;Wailord;Numel;Camerupt;Torkoal;Spoink;Grumpig;Spinda;Trapinch;Vibrava;Flygon;Cacnea;Cacturne;Swablu;Altaria;Zangoose;Seviper;Lunatone;Solrock;Barboach;Whiscash;Corphish;Crawdaunt;Baltoy;Claydol;Lileep;Cradily;Anorith;Armaldo;Feebas;Milotic;Castform;Kecleon;Shuppet;Banette;Duskull;Dusclops;Tropius;Chimecho;Absol;Wynaut;Snorunt;Glalie;Spheal;Sealeo;Walrein;Clamperl;Huntail;Gorebyss;Relicanth;Luvdisc;Bagon;Shelgon;Salamence;Beldum;Metang;Metagross;Regirock;Regice;Registeel;Latias;Latios;Kyogre;Groudon;Rayquaza"

poke = g_ui.displayUI('NewPokedex')
listDex = g_ui.displayUI('newPokedexList')
moveDex = g_ui.displayUI('newPokedexMoves')
poke:addChild(moveDex)
poke:setOn(false)
poke:setVisible(false)  
poke:setDraggable(true)

listDex:setOn(false)
listDex:setVisible(false)  
listDex:setDraggable(true)

moveDex:setOn(false)
moveDex:setVisible(false)  
moveDex:setDraggable(true)
	
connect(g_game, 'onTextMessage', getParams)
connect(g_game, { onGameEnd = hide } )

end

function getParams(mode, text)
	if not g_game.isOnline() then return end
	if mode == MessageModes.Failure then 
		if string.find(text, "ShowDex") then
			ShowPokedex(text)
		elseif string.find(text, "DexList") then
			showList(text)
		end
	end
end

function showList(text)
	listaPokedex = listDex:recursiveGetChildById("listaPokedex")
	listaPokedex:destroyChildren()
	local newpokedex = string.explode(newpokedex, ";")
	local dexOn = string.explode(text, "~")
	local dexOn = string.explode(dexOn[2], ",")
	
	for i = 1, #newpokedex do
		
		x = g_ui.createWidget('buttonList2', listaPokedex)
		fotoPoke = g_ui.createWidget('fotoPoke', x)		
		for b = 1,#dexOn do
			i = tonumber(i)
			dexOn[b] = tonumber(dexOn[b])
			if i == dexOn[b] then
				x:setText("# "..i.." - "..newpokedex[i])
				locaImg = "pokes/normal/"..i..".png"
				fotoPoke:setImageSource(locaImg)
				break
			else
				locaImg = "interface/who.png"
				x:setText("# "..i.." - ??????")
				fotoPoke:setImageSource(locaImg)
			end
		end
		x:setOn(true) 
		x.onClick = function() 
			listDex:setVisible(false) 
			g_game.talk("/dex "..newpokedex[i]) 
		end
	end
	listDex:show()
end
function checkDexOn(a, text)
	local dexOn = string.explode(text, "~")
	local dexOn = string.explode(dexOn[2], ",")
	for i=1, #dexOn do
	
	end
end
function showMoveList()
	moveDex:show()
	moveDex:focus()
end
function  ShowPokedex(text)
	local t = string.explode(text, "~")
	
	if string.find(t[2], "Shiny") then
		pasta = 'shiny'
	else
		pasta = 'normal'
	end
	
	pokemonImage = poke:recursiveGetChildById("pokeFoto")
	local image = "pokes/"..pasta.."/"..t[16]..".png"
	pokemonImage:setImageSource(image)
	
	pokemonName = poke:recursiveGetChildById("pokeName")
	pokeName = "# "..t[16].." - "..t[2]
	pokemonName:setText(pokeName)
	
	pokemonGen = poke:recursiveGetChildById("pokeGen")
	pokeGen = "interface/"..t[20]..".png"
	pokemonGen:setImageSource(pokeGen)
	
	pokemonTipo = poke:recursiveGetChildById("pokeTipo")
	pokeTipo = "interface/"..t[10]..".png"
	pokemonTipo:setImageSource(pokeTipo)
	
	pokemonTipo2 = poke:recursiveGetChildById("pokeTipo2")
	pokeTipo2 = "interface/"..t[11]..".png"
	pokemonTipo2:setImageSource(pokeTipo2)
	
	infoPokemon2 = poke:recursiveGetChildById("infoPoke2")
	infoPoke2 = t[4].."\n"..t[22].."\n"..t[19].."\n"..t[17].."\n"..t[18].."\n"..t[21]
	infoPokemon2:setText(infoPoke2)
	
	infoPokemon = poke:recursiveGetChildById("infoPoke")
	infoPoke = "Level\nEsp�cie\nCor\nAltura\nPeso\nHabitat"
	infoPokemon:setText(infoPoke)
	
	infoEvolucao = poke:recursiveGetChildById("infoEvu")
	if t[12] ~= '' then
		infoEvu = "Evolu��o: "..t[12].."\nLevel: "..t[13].."\n"..t[14]
	else
		infoEvu = "Este Pokemon n�o possui\n nenhuma evolu��o"
	end
	infoEvolucao:setText(infoEvu)
	
	infoHabilidade = poke:recursiveGetChildById("infoHabi")
	if t[15] ~= '' then
		infoHabi = t[15]
	else
		infoHabi = "Este Pokemon n�o possui\n nenhuma Habilidade"
	end
	infoHabilidade:setText(infoHabi)
	
	statusPoke = poke:recursiveGetChildById("statusPoke")
	statusPokemon = t[5].."\n"..t[6].."\n"..t[23].."\n"..t[7].."\n"..t[8].."\n"..t[9]
	statusPoke:setText(statusPokemon)
	
	local maximum = 200
	
	hpBar = poke:recursiveGetChildById("hpBar")
	atackBar = poke:recursiveGetChildById("atackBar")
	defenseBar = poke:recursiveGetChildById("defenseBar")
	spaBar = poke:recursiveGetChildById("spaBar")
	spdBar = poke:recursiveGetChildById("spdBar")
	speedBar = poke:recursiveGetChildById("speedBar")
	
	hpValue = t[5] 
	atackValue = t[6]
	defensepValue = t[23]
	spaValue = t[7] 
	spdValue = t[8]
	speedValue = t[9] 
	
	
	hpBar:setValue(hpValue, 0, maximum)
	atackBar:setValue(atackValue, 0, maximum)
	defenseBar:setValue(defensepValue, 0, maximum)
	spaBar:setValue(spaValue, 0, maximum)
	spdBar:setValue(spdValue, 0, maximum)
	speedBar:setValue(speedValue, 0, maximum)
	
	local pokemonList = moveDex:recursiveGetChildById("movesPokedex")
	pokemonList:destroyChildren()
	
	montaMoves(t[3])
	show()
end
function montaMoves(text)
	local pokemonList = moveDex:recursiveGetChildById("movesPokedex")
	local text = string.explode(text, "|")
	for k,v in pairs(text) do
		if (v == "") then
		
		else
			v = string.explode(v, "*")
			if (v[2] == "passive") then
				v[2] = "P"
			end
			local x = g_ui.createWidget('buttonList', pokemonList)
			local moveLevel = g_ui.createWidget('moveLevel',x)
			local typeMove = g_ui.createWidget('typeMove',x)
			local moveType = "interface/"..v[3]..".png"
			typeMove:setImageSource(moveType)
			moveLevel:setText(v[2])
			x:setText(v[1])
		end
	end
	
end
function showDexList()
	poke:setOn(false)
	poke:setVisible(false)
	listDex:show()
end

function pokeimg()
	if poke:isVisible() then
		hide()
	else
		show()
	end
end

function terminate()
   disconnect(g_game, 'onTextMessage', getParams)
end

function hide()
	poke:setOn(true)
	poke:setVisible(false)
	
	listDex:setOn(true)
	listDex:setVisible(false)
end
function hideMoves()
	poke:setOn(true)
	poke:setVisible(true)
	
	moveDex:setOn(false)
	moveDex:setVisible(false)
end
function show()
   poke:setVisible(true)
end

-- End public functions