/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0

	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1

	//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/pathweight = 1

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

// Adds the adjacent turfs to the current atmos processing
/turf/Del()
	if(air_master)
		for(var/direction in cardinal)
			if(atmos_adjacent_turfs & direction)
				var/turf/simulated/T = get_step(src, direction)
				if(istype(T))
					air_master.add_to_active(T)
	..()

/turf/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

/turf/ex_act(severity)
	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return
	if (!mover)
		return 1
	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Bump(obstacle, 1)
				return 0

	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags&ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
			mover.Bump(obstacle, 1)
			return 0
	return 1 //Nothing found to block so return success!

/turf/Entered(atom/atom as mob|obj)
	if(movement_disabled)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return
	..()
//vvvvv Infared beam stuff vvvvv

	if ((atom && atom.density && !( istype(atom, /obj/effect/beam) )))
		for(var/obj/effect/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				break

//^^^^^ Infared beam stuff ^^^^^

	if(!istype(atom, /atom/movable))
		return

	var/atom/movable/M = atom

	var/loopsanity = 100
	if(ismob(M))
		if(!M:lastarea)
			M:lastarea = get_area(M.loc)
		if(!has_gravity(M))
			inertial_drift(M)

	/*
		if(M.flags & NOGRAV)
			inertial_drift(M)
	*/



		else if(!istype(src, /turf/space))
			M:inertia_dir = 0
	..()
	var/objects = 0
	for(var/atom/A as mob|obj|turf|area in range(1))
		if(objects > loopsanity)	break
		objects++
		spawn( 0 )
			if ((A && M))
				A.HasProximity(M, 1)
			return
	return

/turf/proc/is_plating()
	return 0
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	if(!(A.last_move))	return
	if((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1)))
		var/mob/M = A
		if(M.Process_Spacemove(1))
			M.inertia_dir  = 0
			return
		spawn(5)
			if((M && !(M.anchored) && (M.loc == src)))
				if(M.inertia_dir)
					step(M, M.inertia_dir)
					return
				M.inertia_dir = M.last_move
				step(M, M.inertia_dir)
	return

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(var/path)
	if(!path)			return
	if(path == type)	return src
	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/old_opacity = opacity
	if(air_master)
		air_master.remove_from_active(src)

	var/turf/W = new path(src)

	if(istype(W, /turf/simulated))
		W:Assimilate_Air()
		W.RemoveLattice()

	W.lighting_lumcount += old_lumcount
	if(old_lumcount != W.lighting_lumcount)	//light levels of the turf have changed. We need to shift it to another lighting-subarea
		W.lighting_changed = 1
		lighting_controller.changed_turfs += W

	if(old_opacity != W.opacity)			//opacity has changed. Need to update surrounding lights
		if(W.lighting_lumcount)				//unless we're being illuminated, don't bother (may be buggy, hard to test)
			W.UpdateAffectingLights()

	W.levelupdate()
	W.CalculateAdjacentTurfs()
	return W

//////Assimilate Air//////
/turf/simulated/proc/Assimilate_Air()
	if(air)
		var/aoxy = 0//Holders to assimilate air from nearby turfs
		var/anitro = 0
		var/aco = 0
		var/atox = 0
		var/atemp = 0
		var/turf_count = 0

		for(var/direction in cardinal)//Only use cardinals to cut down on lag
			var/turf/T = get_step(src,direction)
			if(istype(T,/turf/space))//Counted as no air
				turf_count++//Considered a valid turf for air calcs
				continue
			else if(istype(T,/turf/simulated/floor))
				var/turf/simulated/S = T
				if(S.air)//Add the air's contents to the holders
					aoxy += S.air.oxygen
					anitro += S.air.nitrogen
					aco += S.air.carbon_dioxide
					atox += S.air.toxins
					atemp += S.air.temperature
				turf_count ++
		air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
		air.nitrogen = (anitro/max(turf_count,1))
		air.carbon_dioxide = (aco/max(turf_count,1))
		air.toxins = (atox/max(turf_count,1))
		air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant
		if(air_master)
			air_master.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(/turf/space)
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)	continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")

/turf/proc/Bless()
	if(flags & NOJAUNT)
		return
	flags |= NOJAUNT

/turf/proc/AdjacentTurfs()
	var/L[] = new()
	for(var/turf/simulated/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L
/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		cost *= (pathweight+t.pathweight)/2
		return cost
	else
		return get_dist(src,t)

// This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/t)
	if(!src || !t) return 0
	return abs(src.x - t.x) + abs(src.y - t.y)

/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/handle_fall(mob/faller, forced)
	faller.lying = pick(90, 270)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, 1)

/turf/handle_slip(mob/slipper, s_amount, w_amount, obj/O, lube)
	if(has_gravity(src))
		var/mob/living/carbon/M = slipper
		if (M.m_intent=="walk" && (lube&NO_SLIP_WHEN_WALKING))
			return 0
		if(!M.lying)
			M.stop_pulling()
			if(lube&STEP)
				step(M, M.dir)
			if(lube&SLIDE)
				for(var/i=1, i<5, i++)
					spawn (i)
						step(M, M.dir)
				if(M.lying) //did I fall over?
					M.adjustBruteLoss(2)
			if(O)
				M << "<span class='notice'>You slipped on the [O.name]!</span>"
			else
				M << "<span class='notice'>You slipped!</span>"
			playsound(M.loc, 'sound/misc/slip.ogg', 50, 1, -3)
			M.Stun(s_amount)
			M.Weaken(w_amount)
			return 1
	return 0 // no success. Used in clown pda and wet floors
