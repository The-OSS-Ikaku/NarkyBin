/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Screwdriver the door to complete
 */


obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'

	name = "Windoor Assembly"
	icon_state = "l_windoor_assembly01"
	anchored = 0
	density = 0
	dir = NORTH

	var/ini_dir
	var/obj/item/weapon/airlock_electronics/electronics = null

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = ""		//Whether or not this creates a secure windoor
	var/state = "01"	//How far the door assembly has progressed in terms of sprites

obj/structure/windoor_assembly/New(dir=NORTH)
	..()
	src.ini_dir = src.dir
	air_update_turf(1)

obj/structure/windoor_assembly/Destroy()
	density = 0
	air_update_turf(1)
	..()

/obj/structure/windoor_assembly/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/windoor_assembly/update_icon()
	icon_state = "[facing]_[secure]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CanAtmosPass(var/turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/windoor_assembly/attackby(obj/item/W as obj, mob/user as mob)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	add_fingerprint(user)
	switch(state)
		if("01")
			if(istype(W, /obj/item/weapon/weldingtool) && !anchored )
				var/obj/item/weapon/weldingtool/WT = W
				if (WT.remove_fuel(0,user))
					user.visible_message("<span class='warning'>[user] dissassembles the windoor assembly.</span>", "<span class='notice'>You start to dissassemble the windoor assembly.</span>")
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)

					if(do_after(user, 40))
						if(!src || !WT.isOn()) return
						user << "<span class='notice'>You dissasembled the windoor assembly!</span>"
						var/obj/item/stack/sheet/rglass/RG = new (get_turf(src), 5)
						RG.add_fingerprint(user)
						if(secure)
							var/obj/item/stack/rods/R = new (get_turf(src), 4)
							R.add_fingerprint(user)
						qdel(src)
				else
					user << "<span class='notice'>You need more welding fuel to dissassemble the windoor assembly.</span>"
					return

			//Wrenching an unsecure assembly anchors it in place. Step 4 complete
			if(istype(W, /obj/item/weapon/wrench) && !anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
				user.visible_message("[user] secures the windoor assembly to the floor.", "You start to secure the windoor assembly to the floor.")

				if(do_after(user, 40))
					if(!src) return
					user << "\blue You've secured the windoor assembly!"
					src.anchored = 1
					if(src.secure)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Anchored Windoor Assembly"

			//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
			else if(istype(W, /obj/item/weapon/wrench) && anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
				user.visible_message("[user] unsecures the windoor assembly to the floor.", "You start to unsecure the windoor assembly to the floor.")

				if(do_after(user, 40))
					if(!src) return
					user << "\blue You've unsecured the windoor assembly!"
					src.anchored = 0
					if(src.secure)
						src.name = "Secure Windoor Assembly"
					else
						src.name = "Windoor Assembly"

			//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			else if(istype(W, /obj/item/stack/sheet/plasteel) && !secure)
				var/obj/item/stack/sheet/plasteel/P = W
				if(P.amount < 2)
					user << "\red You need more plasteel to do this."
					return
				user << "\blue You start to reinforce the windoor with plasteel."

				if(do_after(user,40))
					if(!src) return

					P.use(2)
					user << "\blue You reinforce the windoor."
					src.secure = "secure_"
					if(src.anchored)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Secure Windoor Assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(istype(W, /obj/item/stack/cable_coil) && anchored)
				user.visible_message("[user] wires the windoor assembly.", "You start to wire the windoor assembly.")

				if(do_after(user, 40))
					if(!src) return
					var/obj/item/stack/cable_coil/CC = W
					CC.use(1)
					user << "\blue You wire the windoor!"
					src.state = "02"
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"
			else
				..()

		if("02")

			//Removing wire from the assembly. Step 5 undone.
			if(istype(W, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
				user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

				if(do_after(user, 40))
					if(!src) return

					user << "\blue You cut the windoor wires.!"
					new/obj/item/stack/cable_coil(get_turf(user), 1)
					src.state = "01"
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"

			//Adding airlock electronics for access. Step 6 complete.
			else if(istype(W, /obj/item/weapon/airlock_electronics))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
				user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")

				if(do_after(user, 40))
					if(!src) return

					user.drop_item()
					W.loc = src
					user << "\blue You've installed the airlock electronics!"
					src.name = "Near finished Windoor Assembly"
					src.electronics = W
				else
					W.loc = src.loc

			//Screwdriver to remove airlock electronics. Step 6 undone.
			else if(istype(W, /obj/item/weapon/screwdriver))
				if(!electronics)
					return

				playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
				user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to uninstall electronics from the airlock assembly.")

				if(do_after(user, 40))
					if(!src) return
					user << "\blue You've removed the airlock electronics!"
					src.name = "Wired Windoor Assembly"
					var/obj/item/weapon/airlock_electronics/ae
					if (!electronics) //This shouldnt happen, but if it does, lets not crash and runtime.
						ae = new/obj/item/weapon/airlock_electronics( src.loc )
					else
						ae = electronics
						electronics = null
						ae.loc = src.loc


			//Crowbar to complete the assembly, Step 7 complete.
			else if(istype(W, /obj/item/weapon/crowbar))
				if(!src.electronics)
					usr << "\red The assembly is missing electronics."
					return
				usr << browse(null, "window=windoor_access")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
				user.visible_message("[user] pries the windoor into the frame.", "You start prying the windoor into the frame.")

				if(do_after(user, 40))

					if(!src) return

					density = 1 //Shouldn't matter but just incase
					user << "\blue You finish the windoor!"

					if(secure)
						var/obj/machinery/door/window/brigdoor/windoor = new /obj/machinery/door/window/brigdoor(src.loc)
						if(src.facing == "l")
							windoor.icon_state = "leftsecureopen"
							windoor.base_state = "leftsecure"
						else
							windoor.icon_state = "rightsecureopen"
							windoor.base_state = "rightsecure"
						windoor.dir = src.dir
						windoor.density = 0

						if(src.electronics.use_one_access)
							windoor.req_one_access = src.electronics.conf_access
						else
							windoor.req_access = src.electronics.conf_access
						windoor.electronics = src.electronics
						src.electronics.loc = windoor
						windoor.close()
					else
						var/obj/machinery/door/window/windoor = new /obj/machinery/door/window(src.loc)
						if(src.facing == "l")
							windoor.icon_state = "leftopen"
							windoor.base_state = "left"
						else
							windoor.icon_state = "rightopen"
							windoor.base_state = "right"
						windoor.dir = src.dir
						windoor.density = 0

						windoor.req_access = src.electronics.conf_access
						windoor.electronics = src.electronics
						src.electronics.loc = windoor
						windoor.close()

					qdel(src)


			else
				..()

	//Update to reflect changes(if applicable)
	update_icon()


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	//if(src.state != "01")
		//update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.dir = turn(src.dir, 270)

	//if(src.state != "01")
		//update_nearby_tiles(need_rebuild=1)

	src.ini_dir = src.dir
	update_icon()
	return

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(src.facing == "l")
		usr << "The windoor will now slide to the right."
		src.facing = "r"
	else
		src.facing = "l"
		usr << "The windoor will now slide to the left."

	update_icon()
	return