/mob/living/carbon/slime/verb/Feed()
	set category = "Slime"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."
	if(Victim)
		Feedstop()
		return

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return

	var/list/choices = list()
	for(var/mob/living/C in view(1,src))
		if(C!=src && !istype(C,/mob/living/carbon/slime) && Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to feed on?") in null|choices
	if(!M) return
	if(Adjacent(M))

		if(!istype(src, /mob/living/carbon/brain))
			if(!istype(M, /mob/living/carbon/slime))
				if(stat != 2)
					if(health > -70)

						for(var/mob/living/carbon/slime/met in view())
							if(met.Victim == M && met != src)
								src << "<i>The [met.name] is already feeding on this subject...</i>"
								return
						src << "\blue <i>I have latched onto the subject and begun feeding...</i>"
						M << "\red <b>The [src.name] has latched onto your head!</b>"
						Feedon(M)

					else
						src << "<i>This subject does not have a strong enough life energy...</i>"
				else
					src << "<i>This subject does not have an edible life energy...</i>"
			else
				src << "<i>I must not feed on my brothers...</i>"
		else
			src << "<i>This subject does not have an edible life energy...</i>"



/mob/living/carbon/slime/proc/Feedon(var/mob/living/carbon/M)
	Victim = M
	src.loc = M.loc
	canmove = 0
	anchored = 1
	var/lastnut = nutrition
	//if(M.client) M << "\red You legs become paralyzed!"
	if(is_adult)
		icon_state = "[colour] adult slime eat"
	else
		icon_state = "[colour] baby slime eat"

	while(Victim && M.health > -70 && stat != 2)
		// M.canmove = 0
		canmove = 0

		if(Adjacent(M))
			loc = M.loc

			if(prob(15) && M.client && istype(M, /mob/living/carbon))
				M << "\red [pick("You can feel your body becoming weak!", \
				"You feel like you're about to die!", \
				"You feel every part of your body screaming in agony!", \
				"A low, rolling pain passes through your body!", \
				"Your body feels as if it's falling apart!", \
				"You feel extremely weak!", \
				"A sharp, deep pain bathes every inch of your body!")]"

			if(istype(M, /mob/living/carbon))
				Victim.adjustCloneLoss(rand(1,10))
				Victim.adjustToxLoss(rand(1,2))
				if(Victim.health <= 0)
					Victim.adjustToxLoss(rand(2,4))

				// Heal yourself
				adjustToxLoss(-10)
				adjustOxyLoss(-10)
				adjustBruteLoss(-10)
				adjustFireLoss(-10)
				adjustCloneLoss(-10)

				if(Victim)
					for(var/mob/living/carbon/slime/slime in view(1,M))
						if(slime.Victim == M && slime != src)
							slime.Feedstop()

				nutrition += rand(10,25)
				if(nutrition >= lastnut + 50)
					if(prob(80))
						lastnut = nutrition
						powerlevel++
						if(powerlevel > 10)
							powerlevel = 10

				if(is_adult)
					if(nutrition > 1200)
						nutrition = 1200
				else
					if(nutrition > 1000)
						nutrition = 1000

				Victim.updatehealth()
				updatehealth()

			else
				if(prob(25))
					src << "\red <i>[pick("This subject is incompatable", \
					"This subject does not have a life energy", "This subject is empty", \
					"I am not satisified", "I can not feed from this subject", \
					"I do not feel nourished", "This subject is not food")]...</i>"

			sleep(rand(15,45))

		else
			break

	if(stat == 2)
		if(!is_adult)
			icon_state = "[colour] baby slime dead"

	else
		if(is_adult)
			icon_state = "[colour] adult slime"
		else
			icon_state = "[colour] baby slime"

	canmove = 1
	anchored = 0

	if(M)
		if(M.health <= -70)
			M.canmove = 0
			if(!client)
				if(Victim && !rabid && !attacked)
					if(Victim.LAssailant && Victim.LAssailant != Victim)
						if(prob(50))
							if(!(Victim.LAssailant in Friends))
								Friends.Add(Victim.LAssailant) // no idea why i was using the |= operator

			if(M.client && istype(src, /mob/living/carbon/human))
				if(prob(85))
					rabid = 1 // UUUNNBGHHHH GONNA EAT JUUUUUU

			if(client) src << "<i>This subject does not have a strong enough life energy anymore...</i>"
		else
			M.canmove = 1

			if(client) src << "<i>I have stopped feeding...</i>"
	else
		if(client) src << "<i>I have stopped feeding...</i>"

	Victim = null

/mob/living/carbon/slime/proc/Feedstop()
	if(Victim)
		if(Victim.client) Victim << "[src] has let go of your head!"
		Victim = null

/mob/living/carbon/slime/proc/UpdateFeed(var/mob/M)
	if(Victim)
		if(Victim == M)
			loc = M.loc // simple "attach to head" effect!


/mob/living/carbon/slime/verb/Evolve()
	set category = "Slime"
	set desc = "This will let you evolve from baby to adult slime."

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return
	if(!is_adult)
		if(amount_grown >= 10)
			is_adult = 1
			maxHealth = 200
			amount_grown = 0
			regenerate_icons()
			name = text("[colour] [is_adult ? "adult" : "baby"] slime ([rand(1, 1000)])")
		else
			src << "<i>I am not ready to evolve yet...</i>"
	else
		src << "<i>I have already evolved...</i>"

/mob/living/carbon/slime/verb/Reproduce()
	set category = "Slime"
	set desc = "This will make you split into four Slimes."

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return

	if(is_adult)
		if(amount_grown >= 10)
			if(stat)
				src << "<i>I must be conscious to do this...</i>"
				return

			var/list/babies = list()
			var/new_nutrition = round(nutrition * 0.9)
			var/new_powerlevel = round(powerlevel / 4)
			for(var/i=1,i<=4,i++)
				var/mob/living/carbon/slime/M = new /mob/living/carbon/slime/(loc)
				if(prob(70))
					M.colour = colour
				else
					M.colour = slime_mutation[rand(1,4)]
				if(ckey)	M.nutrition = new_nutrition //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
				M.powerlevel = new_powerlevel
				if(i != 1) step_away(M,src)
				babies += M
				feedback_add_details("slime_babies_born","slimebirth_[replacetext(M.colour," ","_")]")

			var/mob/living/carbon/slime/new_slime = pick(babies)
			new_slime.a_intent = "harm"
			new_slime.universal_speak = universal_speak
			if(src.mind)
				src.mind.transfer_to(new_slime)
			else
				new_slime.key = src.key
			qdel(src)
		else
			src << "<i>I am not ready to reproduce yet...</i>"
	else
		src << "<i>I am not old enough to reproduce yet...</i>"
