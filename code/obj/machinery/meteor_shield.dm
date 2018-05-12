/obj/machinery/shield_generator/meteorshield
	name = "meteor shield generator"
	desc = "Generates a force field that stops meteors."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shieldgen"
	obj/item/cell/PCEL = null
	coveropen = 0
	active = 0
	range = 2
	min_range = 1
	max_range = 6
	battery_level = 0
	power_level = 1	//unused in meteor, used in energy shield
	image/display_active = null
	image/display_battery = null
	image/display_panel = null
	sound/sound_on = 'sound/effects/shielddown.ogg'
	sound/sound_off = 'sound/effects/shielddown2.ogg'
	sound/sound_battwarning = 'sound/machines/pod_alarm.ogg'
	sound/sound_shieldhit = 'sound/effects/shieldhit2.ogg'
	list/deployed_shields = list()


	shield_on()
		if (!PCEL)
			return
		if (PCEL.charge < 0)
			return

		for(var/turf/space/T in orange(src.range,src))
			if (get_dist(T,src) != src.range)
				continue
			var/obj/forcefield/meteorshield/S = new /obj/forcefield/meteorshield(T)
			S.deployer = src
			src.deployed_shields += S

		src.anchored = 1
		src.active = 1
		playsound(src.loc, src.sound_on, 50, 1)
		build_icon()

	build_icon()
		src.overlays = null

		if (src.coveropen)
			if (istype(src.PCEL,/obj/item/cell/))
				src.display_panel.icon_state = "panel-batt"
			else
				src.display_panel.icon_state = "panel-nobatt"
			src.overlays += src.display_panel

/obj/forcefield/meteorshield
	name = "Impact Forcefield"
	desc = "A force field deployed to stop meteors and other high velocity masses."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shield"
	var/sound/sound_shieldhit = 'sound/effects/shieldhit2.ogg'
	var/obj/machinery/deployer = null

	meteorhit(obj/O as obj)
		if (istype(deployer, /obj/machinery/shield_generator/meteorshield))
			var/obj/machinery/shield_generator/meteorshield/MS = deployer
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
