datum
	reagents
		proc
			get_reagent_data(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						return R.data

				return 0














datum
	reagent
		semen
			data = list("adjective"=null, "type"=null, "digested"=null, "digested_DNA"=null, "digested_type"=null, "donor_DNA"=null)
			name = "Semen"
			id = "semen"
			description = "A clear-ish white-ish liquid produced by the... sexual parts of mammals."
			reagent_state = LIQUID
			color = "#DFDFDF" // rgb: 223, 223, 223

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
				if(holder.has_reagent("capsaicin"))
					holder.remove_reagent("capsaicin", 2)
				M.nutrition++
				..()
				return

			reaction_turf(var/turf/simulated/T, var/volume)
				if(!istype(T)) return
				//var/datum/reagent/semen/self = src
				src = null
				if(!(volume >= 3)) return
				var/obj/effect/decal/cleanable/sex/sex_prop = locate() in T
				if(!sex_prop)
					sex_prop = new/obj/effect/decal/cleanable/sex/semen(T)

			on_merge(var/list/new_data)
				if(data&&new_data)
					for(var/I in new_data)
						if(data[I]==null)
							data[I]=new_data[I]

		femjuice
			data = list("adjective"=null, "type"=null, "digested"=null, "digested_DNA"=null, "digested_type"=null, "donor_DNA"=null)
			name = "Female Ejaculate"
			id = "femjuice"
			description = "It's really just urine."
			reagent_state = LIQUID
			color = "#AFAFAF"

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
				if(holder.has_reagent("capsaicin"))
					holder.remove_reagent("capsaicin", 2)
				M.nutrition++
				..()
				return

			reaction_turf(var/turf/simulated/T, var/volume)
				if(!istype(T)) return
				//var/datum/reagent/femjuice/self = src
				src = null
				if(!(volume >= 3)) return
				var/obj/effect/decal/cleanable/sex/sex_prop = locate() in T
				if(!sex_prop)
					sex_prop = new/obj/effect/decal/cleanable/sex/femjuice(T)

			on_merge(var/list/new_data)
				if(data&&new_data)
					for(var/I in new_data)
						if(data[I]==null)
							data[I]=new_data[I]

		milk
			data = list("adjective"=null, "type"=null, "digested"=null, "digested_DNA"=null, "digested_type"=null, "donor_DNA"=null)
			reaction_turf(var/turf/simulated/T, var/volume)
				if(!istype(T)) return
				//var/datum/reagent/milk/self = src
				src = null
				if(!(volume >= 3)) return
				var/obj/effect/decal/cleanable/sex/sex_prop = locate() in T
				if(!sex_prop)
					sex_prop = new/obj/effect/decal/cleanable/sex/milk(T)

			on_merge(var/list/new_data)
				if(data&&new_data)
					for(var/I in new_data)
						if(data[I]==null)
							data[I]=new_data[I]

		shrinkchem
			name = "Shrink Chemical"
			id = "shrinkchem"
			description = "Shrinks people. Eaten by larger chemicals."
			reagent_state = LIQUID
			color = "#C8A5FF" // rgb: 200, 165, 220

			var/cnt_digested=0
			var/original_size=-1

			on_mob_life(var/mob/living/M as mob)
				if(original_size==-1)
					original_size=M.sizeplay_size
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				//if(volume%10==5)
				//	if(!holder.has_reagent("growchem"))
				//		M.sizeplay_shrink()
				//		M<<"You shrink."
				if(volume>=1)
					cnt_digested++
				if(cnt_digested==5&&volume>1)
					if(!holder.has_reagent("growchem"))
						M.sizeplay_shrink()
						M<<"You shrink."
				if(cnt_digested==20)
					cnt_digested=0
					original_size=M.sizeplay_size
				if(volume<=1&&volume>0&&original_size>M.sizeplay_size)
					M<<"You grow back a little."
					M.sizeplay_grow()
				holder.remove_reagent(src.id, 1)
				return

		growchem
			name = "Grow Chemical"
			id = "growchem"
			description = "Enlarges people. Eats smaller chemicals."
			reagent_state = LIQUID
			color = "#FFA5DC" // rgb: 200, 165, 220

			var/cnt_digested=0
			var/original_size=-1

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(holder.has_reagent("shrinkchem"))
					holder.remove_reagent("shrinkchem",holder.get_reagent_amount("shrinkchem")-0.1)
				//if(volume%10==5)
				//	M.sizeplay_grow()
				//	M<<"You grow."
				if(volume>=1)
					cnt_digested++
				if(cnt_digested==5&&volume>1)
					M.sizeplay_grow()
					M<<"You grow."
				if(cnt_digested==20)
					cnt_digested=0
					original_size=M.sizeplay_size
				if(volume<=1&&volume>0&&original_size<M.sizeplay_size)
					M<<"You shrink back a little."
					M.sizeplay_shrink()
				holder.remove_reagent(src.id, 1)
				return

		cockchem
			name = "Wundbonite+"
			id = "cockchem"
			description = "Type C growth chemical."
			reagent_state = LIQUID
			color = "#FFDFDF"

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(holder.has_reagent("decockchem"))
					holder.remove_reagent("decockchem",holder.get_reagent_amount("decockchem"))
				if(volume>=1)
					cnt_digested++
				if(istype(M,/mob/living/carbon)&&check_dna_integrity(M))
					var/mob/living/carbon/humz=M
					var/bonersize=humz.dna.cock["has"]
					if(cnt_digested==20&&bonersize==humz.dna.COCK_NONE)
						cnt_digested=0
						humz.dna.cock["has"]=humz.dna.COCK_NORMAL
						M<<"You grow a cock."
						updateappearance(humz)
					if(cnt_digested==10&&bonersize==humz.dna.COCK_NORMAL)
						cnt_digested=0
						humz.dna.cock["has"]=humz.dna.COCK_HYPER
						M<<"Your cock is now huge."
						updateappearance(humz)
					if(bonersize!=humz.dna.COCK_NORMAL&&bonersize!=humz.dna.COCK_NONE)
						cnt_digested=min(1,cnt_digested)
				else
					cnt_digested=min(1,cnt_digested)
				holder.remove_reagent(src.id, 1)
				return

		decockchem
			name = "Wundbonite-"
			id = "decockchem"
			description = "Type C shrink chemical."
			reagent_state = LIQUID
			color = "#DFDFFF"

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(volume>=1)
					cnt_digested++
				if(istype(M,/mob/living/carbon)&&check_dna_integrity(M)&&!holder.has_reagent("cockchem"))
					var/mob/living/carbon/humz=M
					var/bonersize=humz.dna.cock["has"]
					if(cnt_digested==20&&bonersize==humz.dna.COCK_NORMAL)
						cnt_digested=0
						humz.dna.cock["has"]=humz.dna.COCK_NONE
						M<<"You no longer have a cock."
						M.set_cock_block()
						updateappearance(humz)
					if(cnt_digested==10&&bonersize==humz.dna.COCK_HYPER)
						cnt_digested=0
						humz.dna.cock["has"]=humz.dna.COCK_NORMAL
						M<<"Your cock shrinks."
						M.set_cock_block()
						updateappearance(humz)
					if(cnt_digested==10&&bonersize==humz.dna.COCK_DOUBLE)
						cnt_digested=0
						humz.dna.cock["has"]=humz.dna.COCK_NORMAL
						M<<"You no longer have two cocks."
						M.set_cock_block()
						updateappearance(humz)
					if(bonersize!=humz.dna.COCK_NORMAL&&bonersize!=humz.dna.COCK_HYPER&&bonersize!=humz.dna.COCK_DOUBLE)
						cnt_digested=min(1,cnt_digested)
				else
					cnt_digested=min(1,cnt_digested)
				holder.remove_reagent(src.id, 1)
				return

		vagchem
			name = "Fisbonite+"
			id = "vagchem"
			description = "Type V growth chemical."
			reagent_state = LIQUID
			color = "#FFDFDF"

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(holder.has_reagent("devagchem"))
					holder.remove_reagent("devagchem",holder.get_reagent_amount("devagchem"))
				if(volume>=1)
					cnt_digested++
				if(istype(M,/mob/living/carbon)&&check_dna_integrity(M))
					var/mob/living/carbon/humz=M
					var/vaghas=humz.dna.vagina
					if(vaghas)
						cnt_digested=min(1,cnt_digested)
					else
						if(cnt_digested==20)
							cnt_digested=0
							humz.dna.vagina=1
							M<<"A slit forms between your legs. You have a vaigna, now."
							M.set_cock_block()
				else
					cnt_digested=min(1,cnt_digested)
				holder.remove_reagent(src.id, 1)
				return

		devagchem
			name = "Fisbonite-"
			id = "devagchem"
			description = "Type V shrink chemical."
			reagent_state = LIQUID
			color = "#DFDFFF"

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(volume>=1)
					cnt_digested++
				if(istype(M,/mob/living/carbon)&&check_dna_integrity(M)&&!holder.has_reagent("vagchem"))
					var/mob/living/carbon/humz=M
					var/vaghas=humz.dna.vagina
					if(!vaghas)
						cnt_digested=min(1,cnt_digested)
					else
						if(cnt_digested==20)
							cnt_digested=0
							humz.dna.vagina=0
							M<<"You no longer have a vagina."
							M.set_cock_block()
				else
					cnt_digested=min(1,cnt_digested)
				holder.remove_reagent(src.id, 1)
				return

		boobchem
			name = "Lactoverbrinitemosidine+"
			id = "boobchem"
			description = "Type B growth chemical."
			reagent_state = LIQUID
			color = "#FFEEEE"

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(holder.has_reagent("deboobchem"))
					holder.remove_reagent("deboobchem",holder.get_reagent_amount("deboobchem"))
				if(volume>=1)
					cnt_digested++
				if(istype(M,/mob/living/carbon)&&check_dna_integrity(M))
					//var/mob/living/carbon/humz=M
					var/boobhas=M.gender==FEMALE
					if(boobhas)
						cnt_digested=min(1,cnt_digested)
					else
						if(cnt_digested==20)
							cnt_digested=0
							M.gender=FEMALE
							if(check_dna_integrity(M))
								var/datum/dna/Mdna=check_dna_integrity(M)
								Mdna.uni_identity = setblock(Mdna.uni_identity, DNA_GENDER_BLOCK, construct_block((M.gender!=MALE)+1, 2))
							M<<"You now have boobs."
							updateappearance(M)
				else
					cnt_digested=min(1,cnt_digested)
				holder.remove_reagent(src.id, 1)
				return

		deboobchem
			name = "Lactoverbrinitemosidine-"
			id = "deboobchem"
			description = "Type V shrink chemical."
			reagent_state = LIQUID
			color = "#EEEEFF"

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(volume>=1)
					cnt_digested++
				if(istype(M,/mob/living/carbon)&&check_dna_integrity(M)&&!holder.has_reagent("boobchem"))
					//var/mob/living/carbon/humz=M
					var/boobhas=M.gender==FEMALE
					if(!boobhas)
						cnt_digested=min(1,cnt_digested)
					else
						if(cnt_digested==20)
							cnt_digested=0
							M.gender=MALE
							if(check_dna_integrity(M))
								var/datum/dna/Mdna=check_dna_integrity(M)
								Mdna.uni_identity = setblock(Mdna.uni_identity, DNA_GENDER_BLOCK, construct_block((M.gender!=MALE)+1, 2))
							M<<"You no longer have boobs."
							updateappearance(M)
				else
					cnt_digested=min(1,cnt_digested)
				holder.remove_reagent(src.id, 1)
				return

		stomexchem
			name = "Bio-Expansion Chemical"
			id = "stomexchem"
			description = "Enlarges belly by reacting directly with the digestive acids. May react oddly to other bodily fluids."
			reagent_state = LIQUID
			color = "#C8FFDC" // rgb: 200, 255, 220

			var/cnt_digested=0

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(volume>=1)
					cnt_digested++
				//if(volume%10==5)
				if(cnt_digested==10)
					cnt_digested=0
					if(M.vore_ability[num2text(VORE_METHOD_ORAL)]<VORE_SIZEDIFF_ANY)
						M.vore_ability[num2text(VORE_METHOD_ORAL)]+=1
						M<<"Your stomach feels funny."
				holder.remove_reagent(src.id, 1)
				return

		vorechem
			name = "Vorarium"
			id = "vorechem"
			description = "Can be used to do an assortment of things."
			color = "#FF55A0" //I dunno =D

		narkychem
			name = "Narkanian Honey"
			id = "narkychem"
			description = "This lets you see lots of colours."
			color = "#CCAAFF"
			data = list("active"=0,"count"=1,"adjective"=null,"type"=null,"digested"=null, "digested_DNA"=null, "digested_type"=null, "donor_DNA"=null)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(data)
					M.druggy = max(M.druggy, 30)
					switch(data["count"])
						if(1 to 5)
							if(prob(5)) M.emote("giggle")
							else if(prob(10))
								if(prob(50))M.emote("dance")
								for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
									M.dir = i
									sleep(1)
						if(5 to 10)
							M.druggy = max(M.druggy, 35)
							if(prob(5)) M.emote("giggle")
							else if(prob(20))
								if(prob(30))M.emote("dance")
								for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
									M.dir = i
									sleep(1)
						if (10 to INFINITY)
							M.druggy = max(M.druggy, 40)
							if(prob(5)) M.emote("giggle")
							else if(prob(30))
								if(prob(20))M.emote("dance")
								for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
									M.dir = i
									sleep(1)
					data["count"]++
				holder.remove_reagent(src.id, 0.5)
				//..()
				return
			on_merge(var/list/new_data)
				if(data&&new_data)
					for(var/I in new_data)
						if(data[I]==null)
							data[I]=new_data[I]

		hornychem
			name = "Aphrodisiac"
			id = "hornychem"
			description = "You so horny."
			color = "#FF9999"
			data = list("count"=1)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(data)
					switch(data["count"])
						if(1 to 50)
							if(prob(9)) M.emote("blush")
						if (50 to INFINITY)
							if(prob(3)) M.emote("blush")
							if(prob(5)) M.emote("moan")
							if(prob(3))
								if(M.vore_cock_datum.check_exist()&&M.vore_womb_datum.check_exist())
									if(prob(50)) M.vore_cock_datum.release(M.vore_cock_datum.FLAVOUR_HURL)
									else M.vore_womb_datum.release(M.vore_womb_datum.FLAVOUR_HURL)
								else if(M.vore_cock_datum.check_exist())
									M.vore_cock_datum.release(M.vore_cock_datum.FLAVOUR_HURL)
								else if(M.vore_womb_datum.check_exist())
									M.vore_womb_datum.release(M.vore_womb_datum.FLAVOUR_HURL)
					data["count"]++
				holder.remove_reagent(src.id, 0.5)
				//..()
				return


/datum/chemical_reaction/growchem
	name = "Growchem"
	id = "growchem"
	result = "growchem"
	required_reagents = list("hydrogen" = 1, "vorechem" = 1)
	result_amount = 1
/datum/chemical_reaction/shrinkchem
	name = "Shrinkchem"
	id = "shrinkchem"
	result = "shrinkchem"
	required_reagents = list("sodium" = 1, "vorechem" = 1)
	result_amount = 1

/datum/chemical_reaction/stomexchem
	name = "Stomexchem"
	id = "stomexchem"
	result = "stomexchem"
	required_reagents = list("radium" = 1, "vorechem" = 1)
	result_amount = 1

/datum/chemical_reaction/cockchem
	name = "Cockchem"
	id = "cockchem"
	result = "cockchem"
	required_reagents = list("growchem" = 2, "semen" = 3, "vorechem" = 1)
	result_amount = 2
/datum/chemical_reaction/decockchem
	name = "Decockchem"
	id = "decockchem"
	result = "decockchem"
	required_reagents = list("shrinkchem" = 2, "semen" = 3, "vorechem" = 1)
	result_amount = 2

/datum/chemical_reaction/vagchem
	name = "Vagchem"
	id = "vagchem"
	result = "vagchem"
	required_reagents = list("growchem" = 2, "femjuice" = 3, "vorechem" = 1)
	result_amount = 2
/datum/chemical_reaction/devagchem
	name = "Devagchem"
	id = "devagchem"
	result = "devagchem"
	required_reagents = list("shrinkchem" = 2, "femjuice" = 3, "vorechem" = 1)
	result_amount = 2

/datum/chemical_reaction/boobchem
	name = "Boobchem"
	id = "boobchem"
	result = "boobchem"
	required_reagents = list("growchem" = 2, "milk" = 3, "vorechem" = 1)
	result_amount = 2
/datum/chemical_reaction/deboobchem
	name = "Deboobchem"
	id = "deboobchem"
	result = "deboobchem"
	required_reagents = list("shrinkchem" = 2, "milk" = 3, "vorechem" = 1)
	result_amount = 2

/obj/item/weapon/reagent_containers/pill/shrink
	name = "shrink pill"
	desc = "Used to shrink people."
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("shrinkchem", 10)

/obj/item/weapon/reagent_containers/pill/grow
	name = "grow pill"
	desc = "Used to make people larger."
	icon_state = "pill19"
	New()
		..()
		reagents.add_reagent("growchem", 10)

/obj/item/weapon/reagent_containers/pill/stomex
	name = "stomEx pill"
	desc = "Used to make the subject more able in the field of vore."
	icon_state = "pill9"
	New()
		..()
		reagents.add_reagent("stomexchem", 10)

/datum/chemical_reaction/narkychem
	name = "Narkychem"
	id = "narkychem"
	result = "narkychem"
	required_reagents = list("vorechem" = 1, "spacemountainwind" = 1, "femjuice" = 2)
	//required_catalysts = list("femjuice" = 2)
	result_amount=2

/datum/chemical_reaction/narkychem/on_reaction(var/datum/reagents/holder, var/created_volume, var/data_send)

	//var/datum/reagent/femjuice/F = locate(/datum/reagent/femjuice) in holder.reagent_list
	var/list/F=null
	if(data_send)
		F=data_send["femjuice"]
	var/datum/reagent/narkychem/A = locate(/datum/reagent/narkychem) in holder.reagent_list
	if(F)
		A.on_merge(F)
		/*if(F["digested"]!=null)
			if(F["digested"]=="Narky Sawtooth")
				if(A&&A.data)
					A.data["active"]|=2
		if(F["donor_DNA"]!=null)
			var/datum/dna/check_DNA=F["donor_DNA"]
			if(check_DNA.mutantrace&&check_DNA.mutantrace=="narky")
				if(A&&A.data)
					A.data["active"]|=1*/
	//holder.remove_reagent("femjuice",created_volume)

/obj/item/weapon/storage/box/pillbottles/vore
	name = "box of vore pill bottles"
	desc = "It has pictures of pill bottles on its front."
	icon_state = "pillbox"
	New()
		..()
		for(var/obj/item/weapon/storage/pill_bottle/PB in src)
			qdel(PB)
		new /obj/item/weapon/storage/pill_bottle/shrinkpills( src )
		new /obj/item/weapon/storage/pill_bottle/shrinkpills( src )
		new /obj/item/weapon/storage/pill_bottle/shrinkpills( src )
		new /obj/item/weapon/storage/pill_bottle/growpills( src )
		new /obj/item/weapon/storage/pill_bottle/growpills( src )
		new /obj/item/weapon/storage/pill_bottle/growpills( src )
		new /obj/item/weapon/storage/pill_bottle/stomexpills( src )

/obj/item/weapon/storage/pill_bottle/shrinkpills
	name = "bottle of shrink pills"
	desc = "Contains pills used to shirnk people."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/shrink( src )
		new /obj/item/weapon/reagent_containers/pill/shrink( src )
		new /obj/item/weapon/reagent_containers/pill/shrink( src )
		new /obj/item/weapon/reagent_containers/pill/shrink( src )
		new /obj/item/weapon/reagent_containers/pill/shrink( src )
		new /obj/item/weapon/reagent_containers/pill/shrink( src )
		new /obj/item/weapon/reagent_containers/pill/shrink( src )

/obj/item/weapon/storage/pill_bottle/growpills
	name = "bottle of grow pills"
	desc = "Contains pills used to enlarge people."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/grow( src )
		new /obj/item/weapon/reagent_containers/pill/grow( src )
		new /obj/item/weapon/reagent_containers/pill/grow( src )
		new /obj/item/weapon/reagent_containers/pill/grow( src )
		new /obj/item/weapon/reagent_containers/pill/grow( src )
		new /obj/item/weapon/reagent_containers/pill/grow( src )
		new /obj/item/weapon/reagent_containers/pill/grow( src )

/obj/item/weapon/storage/pill_bottle/stomexpills
	name = "bottle of stomEx pills"
	desc = "Contains pills used to increase vore ability."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/stomex( src )
		new /obj/item/weapon/reagent_containers/pill/stomex( src )
		new /obj/item/weapon/reagent_containers/pill/stomex( src )
		new /obj/item/weapon/reagent_containers/pill/stomex( src )








/obj/item/weapon/reagent_containers/food/snacks/narkypudding
	name = "Narky Pudding"
	desc = "So prettiful."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 12)
		reagents.add_reagent("narkychem", 12)
		bitesize = 3

/datum/recipe/narkypudding
	reagents = list("vorechem" = 5, "semen" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/narkypudding
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/narkypudding/being_cooked = ..(container)
		var/datum/reagent/R=container.reagents.has_reagent("semen")
		var/datum/reagent/A=being_cooked.reagents.has_reagent("narkychem")
		if(!R&&A)A.data["active"]|=1 //TEMP FIX
		if(R&&R.data&&R.data["digested"]!=null)
			if(R.data["digested"]=="Narky Sawtooth")
				if(A&&A.data)
					A.data["active"]|=2
				being_cooked.name=being_cooked.name+" (With Real Narky)"
				//being_cooked.reagents.add_reagent("narkychem",12)
		if(R&&R.data&&R.data["donor_DNA"]!=null)
			var/datum/dna/check_DNA=R.data["donor_DNA"]
			if(check_DNA.mutantrace&&check_DNA.mutantrace=="narky")
				if(A&&A.data)
					A.data["active"]|=1
				being_cooked.name="Special "+being_cooked.name
				//being_cooked.reagents.add_reagent("narkychem",12)
		return being_cooked