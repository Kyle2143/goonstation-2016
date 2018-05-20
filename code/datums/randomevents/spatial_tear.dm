/datum/random_event/major/spatial_tear/spatial_tear
	name = "Spatial Tear"
	centcom_headline = "Spatial Anomaly"
	centcom_message = "A severe spatial anomaly has been detected near the station. Personnel are advised to avoid any unusual phenomenae."
	required_elapsed_round_time = 6000 // 10m
	var/list/spatial_tears = new()

	event_effect(var/source)
		..()
		var/datum/random_event/major/spatial_tear/induvidual_tear/tear = new(source)

		spatial_tears.Add(tear)


/datum/random_event/major/spatial_tear/induvidual_tear

	//turfs North/East and South/West of corresponding tears stored for player teleportation
	var/list/turfsSW = new()
	var/list/turfsNE = new()
	var/btype

	New(var/source)
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

		if (turfsSW && turfsNE)
			remove_bad_turfs(turfsSW)
			remove_bad_turfs(turfsNE)

	//loops through the list of all turfs and removes any that are dense or space
	/proc/remove_bad_turfs(var/list/turfs)
		for(var/turf/T in turfs)
			if(istype(T,/turf/space) || (T.density)) continue
				turfs.Remove(T)
		
		return turfs

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/forcefield/event
	name = "Spatial Tear"
	desc = "A breach in the spatial fabric. Extremely difficult to pass."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spat-h"
	anchored = 1.0
	opacity = 1
	density = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	var/datum/random_event/major/spatial_tear/induvidual_tear/tear

	New(loc,duration, datum/random_event/major/spatial_tear/induvidual_tear/spatialTear)
		..()
		tear = spatialTear
		spawn(duration)
			qdel(src)
			// if (src.tear.turfsSW != null && src.tear.turfsNE != null)
				//Remove corresponding teleport turfs
			if (src.tear != null)
				src.tear = null

	HasEntered(atom/A, turf/OldLoc)
		if (istype(A, /mob/living))
			var/mob/living/M = A

			//Critters can't pass through the tear, unfair I know.
			if (istype(A, /mob/living/critter))
				return

			if (istype(tear, /datum/random_event/major/spatial_tear/induvidual_tear))
				var/datum/random_event/major/spatial_tear/induvidual_tear/T = tear
				handle_teleport(T, M, OldLoc)
				handle_damage(M)
				//Considering making a human pick up a random item while passing through the tear. Like they got it in their travels inside.


	//Handle assigning damage to various mobs that can pass through, currently only humans and cyborgs can pass
	proc/handle_damage(mob/living/M)
		var/damage = rand(10, 30)
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			H.remove_stamina(50)
			var/damage_zone = pick(H.organs)
			var/brute = 0
			var/burn = 0
			var/tox = 0
			//brute damage most likely to be inflicted. 
			//these could change, but I wanted it to be like anything could happen while crossing the tear
			var/damage_type = pick(
				prob(100)
					brute = damage,
				prob(75)
					burn = damage,
				prob(75)
					tox = damage
				)
			H.TakeDamage(damage_zone, brute + damage_type, burn + damage_type, tox + damage_type, 0, 0)

		else if (istype(M, /mob/living/silicon))
			var/mob/living/silicon/robot/S = M
			//stolen from robot.dm
			for (var/obj/item/parts/robot_parts/RP in S.contents)
				if (RP.ropart_take_damage(damage,damage) == 1) S.compborg_lose_limb(RP)


	//Detemines which way to teleport the mob to
	proc/handle_teleport(datum/random_event/major/spatial_tear/induvidual_tear/T, var/mob/living/M, var/turf/OldLoc)
		if (T == null)
			//Something's broken. Are there asset statements or error logs to print this error to?
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
	proc/teleport(mob/living/M as mob, var/list/L)
		
		playsound(M.loc, "sound/effects/mag_teleport.ogg", 25, 1, -1)

		var/turf/picked = null
		if (L.len) 
			picked = pick(L)
		if(!isturf(picked))
			boutput(M, "<span style=\"color:red\">You can't pass through, there must be nowhere to go.</span>")
			return
		
		// animate_blink(M)
		M.set_loc(picked)
