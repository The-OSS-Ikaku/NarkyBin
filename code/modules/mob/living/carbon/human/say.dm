/mob/living/carbon/human/say(var/message)

	if(silent)
		return

	// Needed so when they die they can talk in dead chat normally without needing to ghost.
	if(stat != DEAD)

		//Mimes dont speak! Changeling hivemind and emotes are allowed.
		if(!IsVocal())
			if(length(message) >= 2)
				if(mind && mind.changeling)
					if(copytext(message, 1, 2) != "*" && copytext(message, 1, 3) != ":g" && copytext(message, 1, 3) != ":G" && copytext(message, 1, 3) != ":�")
						return
					else
						return ..(message)
				if(stat == DEAD)
					return ..(message)

			if(length(message) >= 1) //In case people forget the '*help' command, this will slow them the message and prevent people from saying one letter at a time
				if (copytext(message, 1, 2) != "*")
					return

		if(dna)
			//if(dna.mutantrace == "lizard")
			//	if(copytext(message, 1, 2) != "*")
			//		message = replacetext(message, "s", stutter("ss"))

			if(dna.mutantrace == "fly")
				if(copytext(message, 1, 2) != "*")
					message = replacetext(message, "z", stutter("zz"))

			/*if(dna.mutantrace == "slime" && prob(5))
				if(copytext(message, 1, 2) != "*")
					if(copytext(message, 1, 2) == ";")
						message = ";"
					else
						message = ""
					message += "SKR"
					var/imax = rand(5,20)
					for(var/i = 0,i<imax,i++)
						message += "E"*/
		if(viruses.len)
			for(var/datum/disease/pierrot_throat/D in viruses)
				var/list/temp_message = text2list(message, " ") //List each word in the message
				var/list/pick_list = list()
				for(var/i = 1, i <= temp_message.len, i++) //Create a second list for excluding words down the line
					pick_list += i
				for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++) //Loop for each stage of the disease or until we run out of words
					if(prob(3 * D.stage)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
						var/H = pick(pick_list)
						if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
						temp_message[H] = "HONK"
						pick_list -= H //Make sure that you dont HONK the same word twice
					message = list2text(temp_message, " ")

		if(wear_mask)
			message = wear_mask.speechModification(message)

		if ((HULK in mutations) && health >= 25 && length(message))
			if(copytext(message, 1, 2) != "*")
				message = "[uppertext(replacetext(message, ".", "!"))]!!" //because I don't know how to code properly in getting vars from other files -Bro

	..(message)


/mob/living/carbon/human/proc/forcesay(list/append)
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtextEx(temp, "Say \"", 1, 7) && length(temp) > 5)	//case sensitive means

				temp = replacetext(temp, ";", "")	//general radio

				if(findtext(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext(trim_left(temp), 3)

				if(findtext(temp, "*", 1, 2))	//emotes
					return

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")


/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/decoy))
		return 1
	if (istype(other, /mob/living/silicon/pai))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	if (istype(other, /mob/living/carbon/slime))
		return 1
	return ..()


/mob/living/carbon/human/GetVoice()
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = src.wear_mask
		if(V.vchange)
			return V.voice
		else
			return name
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/IsVocal()
	if(mind)
		return !mind.miming
	return 1

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return


/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return


/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice