/datum/random_event/major/spatial_tear
	name = "Spatial Tear"
	centcom_headline = "Spatial Anomaly"
	centcom_message = "A severe spatial anomaly has been detected near the station. Personnel are advised to avoid any unusual phenomenae."
	required_elapsed_round_time = 6000 // 10m

	//turfs North/East and South/West of corresponding tears stored for player teleportation
	var/list/turfsSW = new()
	var/list/turfsNE = new()
	var/btype

	event_effect(var/source)
		..()
		var/barrier_duration = rand(600, 3000)
		var/pickx = rand(40,175)
		var/picky = rand(75,140)
		btype = rand(1,2)
		var/count = btype == 1 ? world.maxy : world.maxx // could just set it to our current mapsize (300) but this should help in case that changes again in the future or we go with non-square maps for some reason??  :v
		if (btype == 1)
			// Vertical
			while (count > 0)
				var/obj/forcefield/event/B = new /obj/forcefield/event(locate(pickx,count,1),barrier_duration, src)
				B.icon_state = "spat-v"
				count -= 1
				
				turfsSW.Add(locate(B.x-1, B.y, 1))
				turfsNE.Add(locate(B.x+1, B.y, 1))

		else
			// Horizontal
			while (count > 0)
				var/obj/forcefield/event/B = new /obj/forcefield/event(locate(count,picky,1),barrier_duration, src)
				B.icon_state = "spat-h"
				count -= 1

				turfsSW.Add(locate(B.x, B.y-1, 1))
				turfsNE.Add(locate(B.x, B.y+1, 1))


	
// /datum/random_event/major/spatial_tear/induvidual_tear
// 	var/list/spatial_tears = new()


/obj/forcefield/event
	name = "Spatial Tear"
	desc = "A breach in the spatial fabric. Extremely difficult to pass."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spat-h"
	anchored = 1.0
	opacity = 1
	density = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	var/datum/random_event/major/spatial_tear/tear

	New(loc,duration, datum/random_event/major/spatial_tear/spatialTear)
		..()
		tear = spatialTear
		spawn(duration)
			qdel(src)
			if (src.tear.turfsSW != null && src.tear.turfsNE != null)
				//Remove corresponding teleport turfs
				// src.tear.turfsSW.Remove(src)
				// src.tear.turfsNE.Remove(src)


	// CanPass(atom/A, turf/T)
	// 	if (A.x)
	// 	if (deployer == null) return 0
	// 	if (deployer.power_level == 1 || deployer.power_level == 2)
	// 		if (ismob(A)) return 1
	// 		if (isobj(A)) return 1
	// 	else return 0

	HasEntered(atom/A, turf/OldLoc)

		if (istype(A, /mob/living/carbon/human)/* && !locate(/obj/atmos_field, OldLoc)*/) // NOPE!! stepping around in the field while you're already inside it is fine
			var/mob/living/carbon/human/M = A
			// var/list/L = getTurfList(OldLoc)
			if (istype(tear, /datum/random_event/major/spatial_tear))
				var/datum/random_event/major/spatial_tear/T = tear

				if (T == null)
					//Something's broken
					return

				if (T.btype == 1)
					//user entered from the West
					if (OldLoc.x < src.x)
						teleport(M, T.turfsNE)
					//user entered from the East
					else
						teleport(M, T.turfsSW)
				else
					//user entered from the South
					if (OldLoc.y < src.y)
						teleport(M, T.turfsNE)
					//user entered from the North
					else
						teleport(M, T.turfsSW)

	//Selects a random turf from the list and teleports the Human to that turf.
	proc/teleport(mob/living/carbon/human/H as mob, var/list/L)
		
		playsound(H.loc, "sound/effects/mag_teleport.ogg", 25, 1, -1)

		var/turf/picked = null
		if (L.len) 
			picked = pick(L)
		if(!isturf(picked))
			boutput(H, "<span style=\"color:red\">You can't pass through, there must be nowhere to go.</span>")
			return
		
		// animate_blink(H)
		H.set_loc(picked)


	//returns a list of turfs that can be teleported to
	//turfs, not in space, on the tile across the spatial tear
	// proc/getTurfList(var/turf/OldLoc as turf)
	// 	//get a list of all atoms in on axis on the other side of the spatial tear
	// 	var/list/L = null
	// 	// Vertical
	// 	if (tear.btype == 1)
	// 		//user entered from the West                       world.icon_size
	// 		if (OldLoc.x < src.x)
 //            	var/turf/Turf = locate(src.x+1, src.y, 1) //From_zone Turf

	// 			L = bounds(src, 1, 4, 0, world.maxy-4)
	// 		//user entered from the East
	// 		else
	// 			L = bounds(src, -1, 4, 0, world.maxy-4)
	// 	else
	// 		//user entered from the South
	// 		if (OldLoc.y < src.y)
	// 			L = bounds(src, 4, 1, world.maxx-4, 0)
	// 		//user entered from the North
	// 		else
	// 			L = bounds(src, 4, -1, world.maxx-4, 0 )

	// 	//search through list of atoms, and return list of Turfs not in space
	// 	var/list/turfs = new/list()
	// 	for(var/turf/T in L)
	// 		if(istype(T,/turf/space)) continue
	// 		if(T.density) continue
	// 		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
	// 		if(T.y>world.maxy-4 || T.y<4)	continue
	// 		turfs.Add(T)

	// 	return turfs

