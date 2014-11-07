//REMEMBER TO REMOVE THE DNA LIST

datum
	race
		var/name="undefined"
		var/generic="something"
		var/adjective="unknown"
		var/restricted=0 //Set to 1 to not allow anyone to choose it, 2 to hide it from the DNA scanner, and text to restrict it to one person
		var/tail=0
		var/taur=0
		human
			name="human"
			generic="human"
			adjective="ordinary"
			taur="horse"
		fox
			name="fox"
			adjective="foxy"
			tail=1
			taur=1
		fennec
			name="fennec"
			generic="fox"
			adjective="foxy"
			tail=1
		lizard
			name="lizard"
			generic="reptile"
			adjective="scaled"
			tail=1
		tajaran
			name="tajaran"
			generic="feline"
			adjective="furry"
			tail=1
			taur=1
		panther
			name="panther"
			generic="feline"
			adjective="furry"
			tail=1
			taur=1
		husky
			name="husky"
			generic="canine"
			adjective="derpy"
			tail=1
		dalmatian
			name="dalmatian"
			generic="canine"
			adjective="spotty"
			tail=1
		lab
			name="lab"
			generic="canine"
			adjective="sleek"
			tail=1
		shepherd
			name="shepherd"
			generic="canine"
			adjective="happy"
			tail=1
		wolf
			name="wolf"
			generic="canine"
			adjective="shaggy"
			tail=1
		squirrel
			name="squirrel"
			generic="rodent"
			adjective="nutty"
			tail=1
		otter
			name="otter"
			generic="weasel"
			adjective="slim"
			tail=1
		murid
			name="murid"
			generic="rodent"
			adjective="squeaky"
			tail=1
		leporid
			name="leporid"
			generic="leporid"
			adjective="hoppy"
			tail=1
		ailurus
			name="ailurus"
			generic="ailurus"
			adjective="cuddly"
			tail=1
		pig
			name="pig"
			generic="pig"
			adjective="curly"
			tail=1
		hippo
			name="hippo"
			generic="hippo"
			adjective="buoyant"
			tail=1
		shark
			name="shark"
			generic="fish"
			adjective="fishy"
			tail=1
		hawk
			name="hawk"
			generic="bird"
			adjective="feathery"
			tail=1
		jelly
			name="jelly"
			generic="jelly"
			adjective="jelly"
		slime
			name="slime"
			generic="slime"
			adjective="slimy"
		plant
			name="plant"
			generic="plant"
			adjective="leafy"
		narky
			name="narky"
			generic="narwhal"
			adjective="fluffy"
			restricted="kingpygmy"
			tail=1
			taur=1
		jordy
			name="jordy"
			generic="canine"
			adjective="hyper"
			tail=1
			restricted=1
		runac
			name="runac"
			generic="fox"
			adjective="glowing"
			tail=1
			restricted=1
		fly
			name="fly"
			generic="insect"
			adjective="buzzy"
			restricted=1
		skeleton
			name="skeleton"
			generic="human"
			adjective="boney"
			restricted=2
		shadow
			name="shadow"
			generic="darkness"
			adjective="shady"
			restricted=2
		golem
			name="golem"
			generic="golem"
			adjective="rocky"
			restricted=2
		adamantine
			name="adamantine"
			generic="golem"
			adjective="rocky"
			restricted=2

var/list/kpcode_race_list

proc/kpcode_race_genlist()
	if(!kpcode_race_list)
		var/paths = typesof(/datum/race)
		kpcode_race_list = new/list()
		for(var/path in paths)
			var/datum/race/D = new path()
			if(D.name!="undefined")
				kpcode_race_list[D.name] = D

proc/kpcode_race_getlist(var/restrict=0)
	var/list/race_options = list()
	for(var/r_id in kpcode_race_list)
		var/datum/race/R = kpcode_race_list[r_id]
		if(!R.restricted||R.restricted==restrict)
			race_options[r_id]=R
	return race_options

proc/kpcode_race_get(var/name="human")
	if(!name||name=="") name="human"
	if(kpcode_race_list[name])
		return kpcode_race_list[name]
	else
		return 0

proc/kpcode_race_restricted(var/name="human")
	if(kpcode_race_get(name))
		var/datum/race/D=kpcode_race_get(name)
		return D.restricted
	return 2

proc/kpcode_race_tail(var/name="human")
	if(kpcode_race_get(name))
		var/datum/race/D=kpcode_race_get(name)
		return D.tail
	return 0

proc/kpcode_race_taur(var/name="human")
	if(kpcode_race_get(name))
		var/datum/race/D=kpcode_race_get(name)
		return D.taur
	return 0

proc/kpcode_race_generic(var/name="human")
	if(kpcode_race_get(name))
		var/datum/race/D=kpcode_race_get(name)
		return D.generic
	return 0

proc/kpcode_race_adjective(var/name="human")
	if(kpcode_race_get(name))
		var/datum/race/D=kpcode_race_get(name)
		return D.adjective
	return 0

proc/kpcode_get_generic(var/mob/living/M)
	if(istype(M,/mob/living/carbon/human))
		if(M:dna)
			return kpcode_race_generic(M:dna:mutantrace)
		else
			return kpcode_race_generic("human")
	if(istype(M,/mob/living/carbon/monkey))
		return "monkey"
	if(istype(M,/mob/living/carbon/alien))
		return "xeno"
	if(istype(M,/mob/living/simple_animal))
		return M.name
	return "something"

proc/kpcode_get_adjective(var/mob/living/M)
	if(istype(M,/mob/living/carbon/human))
		if(M:dna)
			return kpcode_race_adjective(M:dna:mutantrace)
		else
			return kpcode_race_adjective("human")
	if(istype(M,/mob/living/carbon/monkey))
		return "cranky"
	if(istype(M,/mob/living/carbon/alien))
		return "alien"
	if(istype(M,/mob/living/simple_animal))
		return "beastly"
	return "something"


/*var/list/mutant_races = list(
	"human",
	"fox",
	"fennec",
	"lizard",
	"tajaran",
	"panther",
	"husky",
	"squirrel",
	"otter",
	"murid",
	"leporid",
	"ailurus",
	"shark",
	"hawk",
	"jelly",
	"slime",
	"plant",
	)*/

var/list/mutant_tails = list(
	"none"=0,
	"neko"="tajaran",
	"dog"="lab",
	"wolf"="wolf",
	"fox"="fox",
	"mouse"="murid",
	"leporid"="leporid",
	"panda"="ailurus",
	"pig"="pig",
	)

var/list/cock_list = list(
	"human",
	"canine",
	"feline",
	"murid",
	"leporid",
	//"custom",
	)


proc/kpcode_hastail(var/S)
	//switch(S)
		//if("jordy","husky","squirrel","lizard","narky","tajaran","otter","murid","fox","fennec","wolf","leporid","shark","panther","ailurus","runac","hawk")
	if(kpcode_race_tail(S)==1)
		return S
	if(kpcode_race_tail(S))
		return kpcode_race_tail(S)
		/*if("neko")
			return "tajaran"
		if("mouse")
			return "murid"
		if("panda")
			return "ailurus"*/
	if(S in mutant_tails)
		return mutant_tails[S]
	return 0

proc/kpcode_tail_offset(var/S)
	S=kpcode_hastail(S)
	switch(S)
		if("leporid")
			return 8
		else
			return 0

proc/kpcode_cantaur(var/S)
	if(!S)return "horse"
	switch(S)
		if("narky","panther","tajaran","fox")
			return S
		if("human")
			return "horse"
		else
			return 0