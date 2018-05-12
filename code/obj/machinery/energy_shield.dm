/obj/machinery/meteorshield/energy_shield
	name = "Energy-Shield Generator"
	desc = "Organic matter can pass through the shields generated by this generator. Can be secured to the ground using a wrench."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "energyShield"
	density = 0
	var/orientation = 1  //shield extend direction 0 = north/south, 1 = east/west
	power_level = 1 //1 for atmos shield, 2 for liquid, 3 for solid material
	var/const/MAX_POWER_LEVEL = 3
	var/const/MIN_POWER_LEVEL = 1
	min_range = 0
	max_range = 5

	New()
		display_battery = image('icons/obj/meteor_shield.dmi', "")
		..()
	// 	/obj/machinery/meteorshield/New()
	// 	display_panel.dir = EAST
		// src.display_active = image('icons/obj/meteor_shield.dmi', "")
		// src.display_battery = image('icons/obj/meteor_shield.dmi', "")
		// src.display_panel = image('icons/obj/meteor_shield.dmi', "")


	examine()
		..()
		if(usr.client)
			var/charge_percentage = 0
			if (PCEL && PCEL.charge > 0 && PCEL.maxcharge > 0)
				charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
				boutput(usr, "It has [PCEL.charge]/[PCEL.maxcharge] ([charge_percentage]%) battery power left.")
				boutput(usr, "The range setting is set to [src.range].")
				boutput(usr, "The power setting is set to [src.power_level].")
				boutput(usr, "The unit will consume [5 * src.range * (src.power_level * src.power_level)] power a second.")
			else
				boutput(usr, "It seems to be missing a usable battery.")

	meteorshield_on()
		if (!PCEL)
			return
		if (PCEL.charge < 0)
			return

		change_orientation()

		var/xa= -range-1
		var/ya= -range-1
		var/atom/A
		if (range == 0)
			var/obj/forcefield/energyshield/S = new /obj/forcefield/energyshield ( locate((src.x),(src.y),src.z) )
			S.icon_state = "enshieldw"
			//tiles += S
			S.deployer = src
			src.deployed_shields += S
		else
			for (var/i = 0-range, i <= range, i++)
				if (orientation)
					A = locate((src.x+i),(src.y),src.z)
					xa++
					ya = 0
				else
					A = locate((src.x),(src.y+i), src.z)
					ya++
					xa = 0

				if (!A.density)
					var/obj/forcefield/energyshield/S = new /obj/forcefield/energyshield ( locate((src.x + xa),(src.y + ya),src.z) )
					if (xa == -range)
						S.dir = SOUTHWEST
					else if (xa == range)
						S.dir = SOUTHEAST
					else if (ya == -range)
						S.dir = NORTHWEST
					else if (ya == range)
						S.dir = NORTHEAST
					else if (orientation)
						S.dir = NORTH
					else if (!orientation)
						S.dir = EAST

					S.deployer = src
					src.deployed_shields += S
					if (src.power_level == 1)
						S.name = "Atmospheric Forcefield"
						S.desc = "A force field that prevents gas from passing through it."
						S.icon_state = "shieldw" //change colour or something for different power levels
						S.color = "#3333FF"
					else if (src.power_level == 2)
						S.name = "Atmospheric/Liquid Forcefield"
						S.desc = "A force field that prevents gas and liquids from passing through it."
						S.icon_state = "shieldw" //change colour or something for different power levels
						S.color = "#33FF33"
					else
						S.name = "Energy Forcefield"
						S.desc = "A force field that prevents matter from passing through it."
						S.icon_state = "shieldw" //change colour or something for different power levels
						S.color = "#FF3333"


		src.anchored = 1
		src.active = 1

		update_nearby_tiles()
		playsound(src.loc, src.sound_on, 50, 1)
		build_icon()
		display_active.icon_state = "energyShieldOn"
		if (src.power_level == 1)
			display_active.color = "#0000FA"
		else if (src.power_level == 2)
			display_active.color = "#00FF00"
		else
			display_active.color = "#FA0000"


	meteorshield_off(var/failed = 0)
		for(var/obj/forcefield/energyshield/S in src.deployed_shields)
			src.deployed_shields -= S
			S.deployer = null
			qdel(S)

		src.anchored = 0
		src.active = 0
		if (failed)
			src.visible_message("<b>[src]</b> fails, and shuts down!")
		playsound(src.loc, src.sound_off, 50, 1)
		build_icon()

	//Changes shield orientation based on direction the generator is facing
	proc/change_orientation()
		if (src.dir == NORTH || src.dir == SOUTH)
			orientation = 0
		else 
			orientation = 1


	verb/toggle()
		set src in view(1)
		if (src.active)
			meteorshield_off()
		else
			meteorshield_on()

	verb/rotate()
		set src in view(1)
		if (src.active)
			boutput(usr, "<span style=\"color:red\">You can't rotate an active shield generator!</span>")
			return
		src.dir = turn(src.dir, -90)
		change_orientation()
		boutput(usr, "<span style=\"color:blue\">Orientation set to : [orientation ? "Horizontal" : "Vertical"]</span>")

	verb/set_power_level()
		set src in view(1)
		set name = "Set Power Level"

		if (active)
			boutput(usr, "<span style=\"color:red\">You can't change the power level while the generator is active.</span>")
			return

		if (get_dist(usr,src) > 1)
			boutput(usr, "<span style=\"color:red\">You need to be closer to do that.</span>")
			return
		var/the_level = input("Enter a power level from [src.MIN_POWER_LEVEL]-[src.MAX_POWER_LEVEL]. Higher ranges use more power.","[src.name]",2) as null|num
		if (!the_level)
			return
		if (get_dist(usr,src) > 1)
			boutput(usr, "<span style=\"color:red\">You flail your arms at [src] from across the room like a complete muppet. Move closer, genius!</span>")
			return
		the_level = max(MIN_POWER_LEVEL,min(the_level,MAX_POWER_LEVEL))
		src.power_level = the_level
		var/outcome_text = "You set the power level to [src.power_level]."
		if (src.active)
			outcome_text += " The generator shuts down for a brief moment to recalibrate."
			meteorshield_off()
			sleep(10)
			meteorshield_on()
		boutput(usr, "<span style=\"color:blue\">[outcome_text]</span>")

/obj/forcefield/energyshield
	name = "Impact Forcefield"
	desc = "A force field."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shieldw"

	var/sound/sound_shieldhit = 'sound/effects/shieldhit2.ogg'
	var/obj/machinery/meteorshield/energy_shield/deployer = null

	CanPass(atom/A, turf/T)
		if (deployer == null) return 0
		if (deployer.power_level == 1 || deployer.power_level == 2)
			if (ismob(A)) return 1
			if (isobj(A)) return 1
		else return 0

	meteorhit(obj/O as obj)
		if (istype(deployer, /obj/machinery/meteorshield/energy_shield))
			var/obj/machinery/meteorshield/energy_shield/ES = deployer
			//unless the power level is 3, which blocks solid objects, meteors should pass through unmolested
			if (ES.power_level == 3)
				if (ES.PCEL)
					ES.PCEL.charge -= 10 * ES.range * (ES.power_level * ES.power_level)
					playsound(src.loc, src.sound_shieldhit, 50, 1)
				else
					deployer = null
					qdel(src)

		else
			deployer = null
			qdel(src)
