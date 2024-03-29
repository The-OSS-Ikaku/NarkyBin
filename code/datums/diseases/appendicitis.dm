/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 3
	spread = "Acute"
	cure = "Surgery"
	agent = "Shitty Appendix"
	affected_species = list("Human")
	permeability_mod = 1
	contagious_period = 9001 //slightly hacky, but hey! whatever works, right?
	desc = "If left untreated the subject will become very weak, and may vomit often."
	severity = "Medium"
	longevity = 1000
	hidden = list(0, 1)
	requires = 1
	required_limb = list(/obj/item/organ/limb/chest)

/datum/disease/appendicitis/stage_act()
	..()

	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/appendix/A = affected_mob.getorgan(/obj/item/organ/appendix)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				affected_mob << "<span class='warning'>You feel a stabbing pain in your abdomen!</span>"
				affected_mob.Stun(rand(2,3))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				if (affected_mob.nutrition > 100)
					affected_mob.Stun(rand(4,6))
					//affected_mob.visible_message("<span class='warning'>[affected_mob] throws up!</span>")
					affected_mob.visible_message(text("<b>\red [] throws up!</b>",affected_mob),text("<b>\red You throw up!</b>"),text("<b>\red You hear a disgusting noise!</b>"))
					affected_mob.vore_stomach_datum.release()
					playsound(affected_mob.loc, 'sound/effects/splat.ogg', 50, 1)
					var/turf/location = affected_mob.loc
					if(istype(location, /turf/simulated))
						location.add_vomit_floor(affected_mob)
					affected_mob.nutrition -= 95
					affected_mob.adjustToxLoss(-1)
				else
					affected_mob << "<span class='warning'>You gag as you want to throw up, but there's nothing in your stomach!</span>"
					affected_mob.Weaken(10)
					affected_mob.adjustToxLoss(3)

