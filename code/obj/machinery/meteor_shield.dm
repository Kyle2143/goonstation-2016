/obj/machinery/shieldgenerator/meteorshield
	name = "meteor shield generator"
	desc = "Generates a force field that stops meteors."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shieldgen"

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


/obj/forcefield/meteorshield
	name = "Impact Forcefield"
	desc = "A force field deployed to stop meteors and other high velocity masses."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shield"
	var/sound/sound_shieldhit = 'sound/effects/shieldhit2.ogg'
	var/obj/machinery/shieldgenerator/meteorshield/deployer = null

	meteorhit(obj/O as obj)
		if (istype(deployer, /obj/machinery/shieldgenerator/meteorshield))
			var/obj/machinery/shieldgenerator/meteorshield/MS = deployer
			if (MS.PCEL)
				MS.PCEL.charge -= 10 * MS.range
				playsound(src.loc, src.sound_shieldhit, 50, 1)
			else
				deployer = null
				qdel(src)

		else if (istype(deployer, /obj/machinery/shieldgenerator))
			var/obj/machinery/shieldgenerator/SG = deployer
			if ((SG.stat & (NOPOWER|BROKEN)) || !SG.powered())
				deployer = null
				qdel(src)
			SG.use_power(10)
			playsound(src.loc, src.sound_shieldhit, 50, 1)

		else
			deployer = null
			qdel(src)
