var/bomb_set

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1

	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/weapon/disk/nuclear/auth = null
	use_power = 0
	var/previous_level = ""

/obj/machinery/nuclearbomb/New()
	..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.

/obj/machinery/nuclearbomb/process()
	if (src.timing)
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		src.timeleft--
		if (src.timeleft <= 0)
			explode()
		else
			var/volume = (timeleft <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/timer.ogg', volume, 0)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/weapon/I as obj, mob/user as mob)
	if (istype(I, /obj/item/weapon/disk/nuclear))
		usr.drop_item()
		I.loc = src
		src.auth = I
		src.add_fingerprint(user)
		return
	else if(istype(I, /obj/item/weapon/disk))
		usr << "Wrong disk."
	..()

/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = text("<TT>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (src.auth ? "++++++++++" : "----------"))
	if (src.auth)
		if (src.yes_code)
			dat += text("\n<B>Status</B>: []-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] <A href='?src=\ref[];timer=1'>Toggle</A><BR>\nTime: <A href='?src=\ref[];time=-10'>-</A> <A href='?src=\ref[];time=-1'>-</A> [] <A href='?src=\ref[];time=1'>+</A> <A href='?src=\ref[];time=10'>+</A><BR>\n<BR>\nSafety: [] <A href='?src=\ref[];safety=1'>Toggle</A><BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (src.timing ? "Func/Set" : "Functional"), (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src, src, src, src.timeleft, src, src, (src.safety ? "On" : "Off"), src, (src.anchored ? "Engaged" : "Off"), src)
		else
			dat += text("\n<B>Status</B>: Auth. S2-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
	else
		if (src.timing)
			dat += text("\n<B>Status</B>: Set-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		else
			dat += text("\n<B>Status</B>: Auth. S1-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
	var/message = "AUTH"
	if (src.auth)
		message = text("[]", src.code)
		if (src.yes_code)
			message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A><A href='?src=\ref[];type=2'>2</A><A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A><A href='?src=\ref[];type=5'>5</A><A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A><A href='?src=\ref[];type=8'>8</A><A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A><A href='?src=\ref[];type=0'>0</A><A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
	var/datum/browser/popup = new(user, "nuclearbomb", name, 300, 400)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/nuclearbomb/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if (href_list["auth"])
		if (src.auth)
			src.auth.loc = src.loc
			src.yes_code = 0
			src.auth = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/disk/nuclear))
				usr.drop_item()
				I.loc = src
				src.auth = I
			else if(istype(I, /obj/item/weapon/disk))
				usr << "Wrong disk."
			else
				usr << "This isn't a disk."
	if (src.auth)
		if (href_list["type"])
			if (href_list["type"] == "E")
				if (src.code == src.r_code)
					src.yes_code = 1
					src.code = null
				else
					src.code = "ERROR"
			else
				if (href_list["type"] == "R")
					src.yes_code = 0
					src.code = null
				else
					src.code += text("[]", href_list["type"])
					if (length(src.code) > 5)
						src.code = "ERROR"
		if (src.yes_code)
			if (href_list["time"])
				var/time = text2num(href_list["time"])
				src.timeleft += time
				src.timeleft = min(max(round(src.timeleft), 60), 600)
			if (href_list["timer"])
				if (src.timing == -1.0)
					return
				if (src.safety)
					usr << "\red The safety is still on."
					return
				src.timing = !( src.timing )
				if (src.timing)
					src.icon_state = "nuclearbomb2"
					if(!src.safety)
						bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
						src.previous_level = "[get_security_level()]"
						set_security_level("delta")
					else
						bomb_set = 0
						set_security_level("[previous_level]")
				else
					src.icon_state = "nuclearbomb1"
					bomb_set = 0
					set_security_level("[previous_level]")
			if (href_list["safety"])
				src.safety = !( src.safety )
				src.icon_state = "nuclearbomb1"
				if(safety)
					src.timing = 0
					bomb_set = 0
			if (href_list["anchor"])
				if(!isinspace())
					src.anchored = !( src.anchored )
				else
					usr << "<span class='warning'>There is nothing to anchor to!</span>"
	src.add_fingerprint(usr)
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)

/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/blob_act()
	if (src.timing == -1.0)
		return
	else
		return ..()
	return


#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if (src.safety)
		src.timing = 0
		return
	src.timing = -1.0
	src.yes_code = 0
	src.safety = 1
	src.icon_state = "nuclearbomb3"
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1
	sleep(100)

	enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if( bomb_location && (bomb_location.z == 1) )
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
			off_station = 1
	else
		off_station = 2

	if(ticker)
		if(ticker.mode && ticker.mode.name == "nuclear emergency")
			var/obj/machinery/computer/syndicate_station/syndie_location = locate(/obj/machinery/computer/syndicate_station)
			if(syndie_location)
				ticker.mode:syndies_didnt_escape = (syndie_location.z > 1 ? 0 : 1)	//muskets will make me change this, but it will do for now
			ticker.mode:nuke_off_station = off_station
		ticker.station_explosion_cinematic(off_station,null)
		if(ticker.mode)
			ticker.mode.explosion_in_progress = 0
			if(ticker.mode.name == "nuclear emergency")
				ticker.mode:nukes_left --
			else
				world << "<B>The station was destoyed by the nuclear blast!</B>"

			ticker.mode.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
															//kinda shit but I couldn't  get permission to do what I wanted to do.

			if(!ticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
				world << "<B>Resetting in 30 seconds!</B>"

				feedback_set_details("end_error","nuke - unhandled ending")

				if(blackbox)
					blackbox.save_all_data_to_sql()
				sleep(300)
				log_game("Rebooting due to nuclear detonation")
				kick_clients_in_lobby("\red The round came to an end with you in the lobby.", 1) //second parameter ensures only afk clients are kicked
				world.Reboot()
				return
	return

/obj/item/weapon/disk/nuclear/Destroy()
	if(blobstart.len > 0)
		loc = pick(blobstart)
		message_admins("[src] has been destroyed.  Moving it to ([x], [y], [z]).")
		log_game("[src] has been destroyed.  Moving it to ([x], [y], [z]).")
	return 1 // Cancel destruction.
