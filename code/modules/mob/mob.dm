/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	mob_list -= src
	dead_mob_list -= src
	living_mob_list -= src
	if(client)
		for(var/atom/movable/AM in client.screen)
			qdel(AM)
		client.screen = list()
	qdel(hud_used)
	if(mind && mind.current == src)
		spellremove(src)
	for(var/infection in viruses)
		qdel(infection)
	ghostize()
	..()

/mob/proc/sac_act(var/obj/effect/rune/R, var/mob/victim as mob)
	return


var/next_mob_id = 0
/mob/New()
	tag = "mob_[next_mob_id++]"
	mob_list += src
	if(stat == DEAD)
		dead_mob_list += src
	else
		living_mob_list += src
	..()

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "\blue Coordinates: [x],[y] \n"
	t+= "\red Temperature: [environment.temperature] \n"
	t+= "\blue Nitrogen: [environment.nitrogen] \n"
	t+= "\blue Oxygen: [environment.oxygen] \n"
	t+= "\blue Plasma : [environment.toxins] \n"
	t+= "\blue Carbon Dioxide: [environment.carbon_dioxide] \n"
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "\blue [trace_gas.type]: [trace_gas.moles] \n"

	usr.show_message(t, 1)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)	return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (type)
		if(type & 1 && (sdisabilities & BLIND || blinded || paralysis) )//Vision related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if (type & 2 && (sdisabilities & DEAF || ear_deaf))//Hearing related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && sdisabilities & BLIND))
					return
	// Added voice muffling for Issue 41.
	if(stat == UNCONSCIOUS || sleeping > 0)
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/*/mob/visible_message(var/message, var/self_message, var/blind_message)
	var/mob/origin=src
	if(istype(src.loc,/mob/living))
		origin=src.loc
	for(var/mob/M in viewers(origin))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)*/

/mob/visible_message(var/message, var/self_message, var/blind_message)
	var/mob/origin=src.get_top_level_mob()
	for(var/mob/M in viewers(origin))
		M.visible_message_inside(message, self_message, blind_message, src)


/mob/proc/visible_message_inside(var/message, var/self_message, var/blind_message, var/message_source)
	var/msg = message
	if(self_message && src==message_source)
		msg = self_message
	src.show_message( msg, 1, blind_message, 2)
	for(var/mob/M in src)
		if(M==src)
			continue
		M.visible_message_inside(message,self_message,blind_message, message_source)

/mob/proc/get_top_level_mob()
	if(istype(src.loc,/mob)&&src.loc!=src)
		var/mob/M=src.loc
		return M.get_top_level_mob()
	return src

proc/get_top_level_mob(var/mob/S)
	if(istype(S.loc,/mob)&&S.loc!=S)
		var/mob/M=S.loc
		return M.get_top_level_mob()
	return S

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		//M.show_message( message, 1, blind_message, 2)
		M.visible_message_inside( message, blind_message, src)


/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	return

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/effect/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				qdel(L)
				return temp
			else
				return L.container
	return

/mob/proc/restrained()
	return

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_hand()

	if(istype(W))
		if(equip_to_slot_if_possible(W, slot,0,0,0))
			return 1

	if(!W)
		// Activate the item
		var/obj/item/I = get_item_by_slot(slot)
		if(istype(I))
			I.attack_hand(src)

	return 0

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, qdel_on_fail = 0, disable_warning = 1, redraw_mob = 1)
	if(equip_to_slot_if_possible(W, slot_l_hand, qdel_on_fail, disable_warning, redraw_mob))
		return 1
	else if(equip_to_slot_if_possible(W, slot_r_hand, qdel_on_fail, disable_warning, redraw_mob))
		return 1
	return 0

//This is a SAFE proc. Use this instead of equip_to_splot()!
//set qdel_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W as obj, slot, qdel_on_fail = 0, disable_warning = 0, redraw_mob = 1)
	if(!istype(W)) return 0
	if(!W.mob_can_equip(src, slot, disable_warning))
		if(qdel_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				src << "\red You are unable to equip that." //Only print if qdel_on_fail is false
		return 0
	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
	return 1

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W as obj, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W as obj, slot)
	equip_to_slot_if_possible(W, slot, 1, 1, 0)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list( \
		slot_back,\
		slot_wear_id,\
		slot_w_uniform,\
		slot_wear_suit,\
		slot_wear_mask,\
		slot_head,\
		slot_shoes,\
		slot_gloves,\
		slot_ears,\
		slot_glasses,\
		slot_belt,\
		slot_s_store,\
		slot_l_store,\
		slot_r_store\
	)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W)) return 0

	for(var/slot in slot_equipment_priority)
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1)) //qdel_on_fail = 0; disable_warning = 0; redraw_mob = 1
			return 1

	return 0

/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return


/mob/proc/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[slot_l_hand]'>		[(l_hand&&!(l_hand.flags&ABSTRACT)) 	? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[slot_r_hand]'>		[(r_hand&&!(r_hand.flags&ABSTRACT))		? r_hand	: "Nothing"]</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	user << browse(dat, "window=mob\ref[src];size=325x500")
	onclose(user, "mob\ref[src]")


/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc,/obj/mecha)) return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand(0)
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand(0)
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/*
/mob/verb/help()
	set name = "Help"
	src << browse('html/help.html', "window=help")
	return
*/

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (!( abandon_allowed ) && !is_whitelisted(ckey))
		return
	if ((stat != 2 || !( ticker )))
		usr << "\blue <B>You must be dead to use this!</B>"
		return

	var/was_observing = 0
	if(istype(src,/mob/dead/observer))
		var/mob/dead/observer/spook=src
		was_observing=spook.started_as_observer
	log_game("[usr.name]/[usr.key] used respawn.[was_observing ? "(Was Not Playing)" : "(Was Playing)"]")
	message_admins("[usr.name]/[usr.key] is respawning. [was_observing ? "(Was Not Playing)" : "(Was Playing)"]")

	usr << "\blue <B>Please roleplay correctly!</B>"

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.Cut()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		qdel(M)
		return

	M.key = key
//	M.Login()	//wat
	return

/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	getFiles(
		'html/postcardsmall.jpg',
		'html/somerights20.png',
		'html/88x31.png',
		'html/bug-minus.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/wrench-screwdriver.png',
		'html/spell-check.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/changelog.css',
		'html/changelog.js',
		'html/changelog.html'
		)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		prefs.save_preferences()
		winset(src, "rpane.changelog", "background-color=none;font-style=;")

/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = 0

	if(check_rights_for(client,R_ADMIN))
		is_admin = 1
	else if(stat != DEAD || istype(src, /mob/new_player))
		usr << "\blue You must be observing to use this!"
		return

	if(is_admin && stat == DEAD)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for(var/obj/O in world)				//EWWWWWWWWWWWWWWWWWWWWWWWW ~needs to be optimised
		if(!O.loc)
			continue
		if(istype(O, /obj/item/weapon/disk/nuclear))
			var/name = "Nuclear Disk"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/machinery/singularity))
			var/name = "Singularity"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/machinery/bot))
			var/name = "BOT: [O.name]"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O


	for(var/mob/M in sortAtom(mob_list))
		var/name = M.name
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M


	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	kp_log_observe("[key_name(usr)] observed [eye_name].")

	if(client && mob_eye)
		client.eye = mob_eye
		if (is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0
			if(client.adminobs&&!check_rights_for(client,R_SPECIAL))
				log_admin("[key_name(usr)] admin-observed [eye_name].")

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	unset_machine()
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["refresh"])
		if(machine && in_range(src, usr))
			show_inv(machine)

	if(!usr.stat && usr.canmove && !usr.restrained() && Adjacent(usr))
		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			var/obj/item/what = get_item_by_slot(slot)

			if(what)
				if(what.flags & NODROP)
					usr << "<span class='notice'>You can't remove \the [what.name], it appears to be stuck!</span>"
					return
				visible_message("<span class='danger'>[usr] tries to remove [src]'s [what.name].</span>", \
								"<span class='userdanger'>[usr] tries to remove [src]'s [what.name].</span>")
				what.add_fingerprint(usr)
				if(do_mob(usr, src, STRIP_DELAY))
					if(what && Adjacent(usr))
						unEquip(what)
			else
				what = usr.get_active_hand()
				if(what && (what.flags & NODROP))
					usr << "<span class='notice'>You can't put \the [what.name] on [src], it's stuck to your hand!</span>"
					return
				if(what && what.mob_can_equip(src, slot, 1))
					visible_message("<span class='notice'>[usr] tries to put [what] on [src].</span>")
					if(do_mob(usr, src, STRIP_DELAY * 0.5))
						if(what && Adjacent(usr))
							usr.unEquip(what)
							equip_to_slot_if_possible(what, slot, 0, 1)

	if(usr.machine == src)
		if(Adjacent(usr))
			show_inv(usr)
		else
			usr << browse(null,"window=mob\ref[src]")


/mob/MouseDrop(mob/M)
	..()
	if(M != usr)	return
	if(usr == src)	return
	if(!Adjacent(usr))	return
	if(istype(M, /mob/living/silicon/ai))	return
	show_inv(usr)


/mob/verb/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null

/mob/proc/start_pulling(var/atom/movable/AM)
	if ( !AM || !usr || src==AM || !isturf(src.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return
	if (!( AM.anchored ))
		AM.add_fingerprint(src)

		// If we're pulling something then drop what we're currently pulling and pull this instead.
		if(pulling)
			// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
			if(AM == pulling)
				return
			stop_pulling()

		src.pulling = AM
		AM.pulledby = src
		if(ismob(AM))
			var/mob/M = AM
			if(!iscarbon(src))
				M.LAssailant = null
			else
				M.LAssailant = usr


/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/Stat()
	..()

	if(client && client.holder)

		if(statpanel("Status"))	//not looking at that panel
			stat(null,"Location:\t([x], [y], [z])")
			stat(null,"CPU:\t[world.cpu]")
			stat(null,"Instances:\t[world.contents.len]")

			if(master_controller)
				stat(null,"MasterController-[last_tick_duration] ([master_controller.processing?"On":"Off"]-[controller_iteration])")
				stat(null,"Air-[master_controller.air_cost]\t#[global_activeturfs]")
				stat(null,"Turfs-[master_controller.air_turfs]\tGroups-[master_controller.air_groups]")
				stat(null,"SC-[master_controller.air_superconductivity]\tHP-[master_controller.air_highpressure]\tH-[master_controller.air_hotspots]")
				stat(null,"Sun-[master_controller.sun_cost]")
				stat(null,"Mob-[master_controller.mobs_cost]\t#[mob_list.len]")
				stat(null,"Dis-[master_controller.diseases_cost]\t#[active_diseases.len]")
				stat(null,"Mch-[master_controller.machines_cost]\t#[machines.len]")
				stat(null,"Obj-[master_controller.objects_cost]\t#[processing_objects.len]")
				stat(null,"Net-[master_controller.networks_cost]\tPnet-[master_controller.powernets_cost]")
				stat(null,"NanoUI-[master_controller.nano_cost]\t#[nanomanager.processing_uis.len]")
				stat(null,"GC-[master_controller.gc_cost]\t#[garbage.destroyed.len]-#dels[garbage.dels]")
				stat(null,"Tick-[master_controller.ticker_cost]\tALL-[master_controller.total_cost]")
			else
				stat(null,"MasterController-ERROR")

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			for(var/atom/A in listed_turf)
				if(A.invisibility > see_invisible)
					continue
				statpanel(listed_turf.name, null, A)


	if(mind)
		add_spells_to_statpanel(mind.spell_list)
		if(mind.changeling)
			add_stings_to_statpanel(mind.changeling.purchasedpowers)
	add_spells_to_statpanel(mob_spell_list)

/mob/proc/add_spells_to_statpanel(var/list/spells)
	for(var/obj/effect/proc_holder/spell/S in spells)
		if(S.can_be_cast_by(src))
			switch(S.charge_type)
				if("recharge")
					statpanel("[S.panel]","[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel("[S.panel]","[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel("[S.panel]","[S.holder_var_type] [S.holder_var_amount]",S)

/mob/proc/add_stings_to_statpanel(var/list/stings)
	for(var/obj/effect/proc_holder/changeling/S in stings)
		if(S.chemical_cost >=0 && S.can_be_used_by(src))
			statpanel("[S.panel]",((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""),S)

// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(world.time < client.move_delay)	return 0
	if(stat==2)							return 0
	if(anchored)						return 0
	if(notransform)						return 0
	if(restrained())					return 0
	return 1

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
//Robots and brains have their own version so don't worry about them
/mob/proc/update_canmove()
        var/ko = weakened || paralysis || stat || (status_flags & FAKEDEATH)
        var/bed = !(buckled && istype(buckled, /obj/structure/stool/bed/chair))
        if(ko || resting || stunned)
                drop_r_hand()
                drop_l_hand()
        else
                lying = 0
                canmove = 1
        if(buckled)
                lying = 90 * bed
                anchored = buckled
        else
                if((ko || resting) && !lying)
                        fall(ko)
        canmove = !(ko || resting || stunned || buckled)
        density = !lying
        update_transform()
        lying_prev = lying
        if(update_icon) //forces a full overlay update
                update_icon = 0
                regenerate_icons()
        return canmove

/mob/proc/fall(var/forced)
	drop_l_hand()
	drop_r_hand()

/mob/verb/eastface()
	set hidden = 1
	if(!canface())	return 0
	dir = EAST
	client.move_delay += movement_delay()
	return 1


/mob/verb/westface()
	set hidden = 1
	if(!canface())	return 0
	dir = WEST
	client.move_delay += movement_delay()
	return 1


/mob/verb/northface()
	set hidden = 1
	if(!canface())	return 0
	dir = NORTH
	client.move_delay += movement_delay()
	return 1


/mob/verb/southface()
	set hidden = 1
	if(!canface())	return 0
	dir = SOUTH
	client.move_delay += movement_delay()
	return 1


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0

/mob/proc/Jitter(amount)
	jitteriness = max(jitteriness,amount,0)

/mob/proc/Dizzy(amount)
	dizziness = max(dizziness,amount,0)

/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		update_canmove()
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
		update_canmove()
	return

/mob/proc/Weaken(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(max(weakened,amount),0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/SetWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(weakened + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(max(paralysis,amount),0)
		update_canmove()
	return

/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount,0)
		update_canmove()
	return

/mob/proc/Sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
	update_canmove()
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	update_canmove()
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	update_canmove()
	return

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
	update_canmove()
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	update_canmove()
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	update_canmove()
	return

