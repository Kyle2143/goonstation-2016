/obj/machinery/shieldgenerator
	name = "Shield generator parent"
	desc = "blah blah blah."
	density = 1
	opacity = 0
	anchored = 0
	mats = 9
	var/obj/item/cell/PCEL = null
	var/coveropen = 0
	var/active = 0
	var/range = 2
	var/min_range = 1
	var/max_range = 6
	var/battery_level = 0
	var/power_level = 1	//unused in meteor, used in energy shield
	var/image/display_active = null
	var/image/display_battery = null
	var/image/display_panel = null
	var/sound/sound_on = 'sound/effects/shielddown.ogg'
	var/sound/sound_off = 'sound/effects/shielddown2.ogg'
	var/sound/sound_battwarning = 'sound/machines/pod_alarm.ogg'
	var/sound/sound_shieldhit = 'sound/effects/shieldhit2.ogg'
	var/list/deployed_shields = list()
	
	New()
		PCEL = new /obj/item/cell/supercell(src)
		PCEL.charge = PCEL.maxcharge

		src.display_active = image('icons/obj/meteor_shield.dmi', "on")
		src.display_battery = image('icons/obj/meteor_shield.dmi', "")
		src.display_panel = image('icons/obj/meteor_shield.dmi', "")
		..()

	disposing()
		shield_off(1)
		if (PCEL)
			PCEL.dispose()
		PCEL = null
		display_active = null
		display_battery = null
		display_panel = null
		sound_on = null
		sound_off = null
		sound_battwarning = null
		sound_shieldhit = null
		deployed_shields = list()
		..()

	process()
		if (src.active)
			if(!PCEL)
				shield_off(1)
				return
			PCEL.charge -= 5 * src.range * (power_level * power_level)

			var/charge_percentage = 0
			var/current_battery_level = 0
			if (PCEL && PCEL.charge > 0 && PCEL.maxcharge > 0)
				charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
				switch(charge_percentage)
					if (75 to 100)
						current_battery_level = 3
					if (35 to 74)
						current_battery_level = 2
					else
						current_battery_level = 1

			if (current_battery_level != src.battery_level)
				src.battery_level = current_battery_level
				src.build_icon()
				if (src.battery_level == 1)
					playsound(src.loc, src.sound_battwarning, 50, 1)
					src.visible_message("<span style=\"color:red\"><b>[src] emits a low battery alarm!</b></span>")

			if (PCEL.charge < 0)
				src.visible_message("<b>[src]</b> runs out of power and shuts down.")
				src.shield_off()
				return

	attack_hand(mob/user as mob)
		if (src.coveropen && src.PCEL)
			src.PCEL.set_loc(src.loc)
			src.PCEL = null
			boutput(user, "You remove the power cell.")
		else
			if (src.active)
				src.shield_off()
				src.visible_message("<b>[user.name]</b> powers down the [src].")
			else
				if (PCEL)
					if (PCEL.charge > 0)
						src.shield_on()
						src.visible_message("<b>[user.name]</b> powers up the [src].")
					else
						boutput(user, "[src]'s battery light flickers briefly.")
				else
					boutput(user, "Nothing happens.")
		build_icon()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/screwdriver))
			src.coveropen = !src.coveropen
			src.visible_message("<b>[user.name]</b> [src.coveropen ? "opens" : "closes"] [src]'s cell cover.")

		if (istype(W,/obj/item/cell/) && src.coveropen && !src.PCEL)
			user.drop_item()
			W.set_loc(src)
			src.PCEL = W
			boutput(user, "You insert the power cell.")

		else
			..()

		build_icon()

	attack_ai(mob/user as mob)
		return attack_hand(user)

	verb/set_range()
		set src in view(1)
		set name = "Set Range"

		if (!istype(usr,/mob/living/))
			boutput(usr, "<span style=\"color:red\">Your ghostly arms phase right through [src] and you sadly contemplate the state of your life.</span>")
			boutput(usr, "<span style=\"color:red\">That's what happens when you try to be a smartass, you dead sack of crap.</span>")
			return

		if (get_dist(usr,src) > 1)
			boutput(usr, "<span style=\"color:red\">You need to be closer to do that.</span>")
			return

		var/the_range = input("Enter a range from [src.min_range]-[src.max_range]. Higher ranges use more power.","[src.name]",2) as null|num
		if (!the_range)
			return
		if (get_dist(usr,src) > 1)
			boutput(usr, "<span style=\"color:red\">You flail your arms at [src] from across the room like a complete muppet. Move closer, genius!</span>")
			return
		the_range = max(src.min_range,min(the_range,src.max_range))
		src.range = the_range
		var/outcome_text = "You set the range to [src.range]."
		if (src.active)
			outcome_text += " The generator shuts down for a brief moment to recalibrate."
			shield_off()
			sleep(5)
			shield_on()
		boutput(usr, "<span style=\"color:blue\">[outcome_text]</span>")

	proc/build_icon()
		//scr.overlays set to null in child proc for different panels
		// src.overlays = null

		if (src.active)
			//src.display_active.icon_state = "on"
			src.overlays += src.display_active
			if (istype(src.PCEL,/obj/item/cell))
				var/charge_percentage = null
				if (PCEL.charge > 0 && PCEL.maxcharge > 0)
					charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
					switch(charge_percentage)
						if (75 to 100)
							src.display_battery.icon_state = "batt-3"
						if (35 to 74)
							src.display_battery.icon_state = "batt-2"
						else
							src.display_battery.icon_state = "batt-1"
				else
					src.display_battery.icon_state = "batt-3"
				src.overlays += src.display_battery

	proc/shield_on()
		// if (!PCEL)
		// 	return
		// if (PCEL.charge < 0)
		// 	return

		// for(var/turf/space/T in orange(src.range,src))
		// 	if (get_dist(T,src) != src.range)
		// 		continue
		// 	var/obj/forcefield/meteorshield/S = new /obj/forcefield/meteorshield(T)
		// 	S.deployer = src
		// 	src.deployed_shields += S

		// src.anchored = 1
		// src.active = 1
		// playsound(src.loc, src.sound_on, 50, 1)
		// build_icon()

	proc/shield_off(var/failed = 0)
		//TODO: Change this if you get the chance
		for(var/obj/forcefield/meteorshield/S in src.deployed_shields)
			src.deployed_shields -= S
			S.deployer = null
			qdel(S)

		src.anchored = 0
		src.active = 0
		if (failed)
			src.visible_message("<b>[src]</b> fails, and shuts down!")
		playsound(src.loc, src.sound_off, 50, 1)
		build_icon()

	proc/update_nearby_tiles(need_rebuild)
		var/turf/simulated/source = loc
		if (istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1

/obj/forcefield/meteorshield
	name = "Impact Forcefield"
	desc = "A force field deployed to stop meteors and other high velocity masses."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shield"
	var/sound/sound_shieldhit = 'sound/effects/shieldhit2.ogg'
	var/obj/machinery/deployer = null

	meteorhit(obj/O as obj)
		if (istype(deployer, /obj/machinery/meteorshield))
			var/obj/machinery/meteorshield/MS = deployer
			if (MS.PCEL)
				MS.PCEL.charge -= 10 * MS.range
				playsound(src.loc, src.sound_shieldhit, 50, 1)
			else
				deployer = null
				qdel(src)

		else if (istype(deployer, /obj/machinery/shield_generator))
			var/obj/machinery/shield_generator/SG = deployer
			if ((SG.stat & (NOPOWER|BROKEN)) || !SG.powered())
				deployer = null
				qdel(src)
			SG.use_power(10)
			playsound(src.loc, src.sound_shieldhit, 50, 1)

		else
			deployer = null
			qdel(src)
