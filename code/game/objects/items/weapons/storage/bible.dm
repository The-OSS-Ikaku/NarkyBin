/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/obj/item/organ/limb/affecting in H.organs)
			if(affecting.status == ORGAN_ORGANIC) //No Bible can heal a robotic arm!
				if(affecting.heal_damage(heal_amt, heal_amt, 0))
					H.update_damage_overlays(0)
	return

/obj/item/weapon/storage/bible/attack(mob/living/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1

	add_logs(user, M, "attacked", object="[src.name]")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if(!chaplain)
		user << "\red The book sizzles in your hands."
		user.take_organ_damage(0,10)
		return

	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if(M.mind && (M.mind.assigned_role == "Chaplain"))
			user << "\red You can't heal yourself!"
			return
		/*if((M.mind in ticker.mode.cult) && (prob(20)))
			M << "\red The power of [src.deity_name] clears your mind of heresy!"
			user << "\red You see how [M]'s eyes become clear, the cult no longer holds control over him!"
			ticker.mode.remove_cultist(M.mind)*/
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/message_halt = 0
				for(var/obj/item/organ/limb/affecting in H.organs)
					if(affecting.status == ORGAN_ORGANIC)
						if(message_halt == 0)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] heals [] with the power of [src.deity_name]!</B>", user, M), 1)
							M << "\red May the power of [src.deity_name] compel you to be healed!"
							playsound(src.loc, "punch", 25, 1, -1)
							message_halt = 1
					else
						src << "<span class='warning'>[src.deity_name] refuses to heal this metalic taint!</span>"
						return




		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				M << "\red You feel dumber."
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] beats [] over the head with []!</B>", user, M, src), 1)
			playsound(src.loc, "punch", 25, 1, -1)

	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] smacks []'s lifeless corpse with [].</B>", user, M, src), 1)
		playsound(src.loc, "punch", 25, 1, -1)
	return

/obj/item/weapon/storage/bible/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(A, /turf/simulated/floor))
		user << "\blue You hit the floor with the bible."
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			user << "\blue You bless [A]."
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)
		if(A.reagents && A.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
			user << "\blue You purify [A]."
			var/unholy2clean = A.reagents.get_reagent_amount("unholywater")
			A.reagents.del_reagent("unholywater")
			A.reagents.add_reagent("cleaner",unholy2clean)		//it cleans their soul, get it? I'll get my coat...

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	..()
