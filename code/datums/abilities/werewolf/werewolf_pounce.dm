/datum/targetable/werewolf/werewolf_pounce
	name = "Pounce"
	desc = "Pounce on a target location."
	icon_state = "pounce"
	targeted = 1
	target_nodamage_check = 1
	target_anything = 1	
	max_range = 10
	cooldown = 100
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	werewolf_only = 1
	restricted_area_check = 2

	cast(turf/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner

		if (M == target)
			boutput(M, __red("Why would you want to pounce on yourself?"))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1
		if (istype(M.loc,/mob/))
			boutput(usr, "<span style=\"color:red\">You can't jump right now!</span>")
			return 1

		var/jump_tiles = get_dist(M, target)
		var/pixel_move = round((8/7)*jump_tiles)
		var/sleep_time = 1

		if (istype(M.loc,/turf/))
			playsound(M.loc, "sound/weapons/thudswoosh.ogg", 50, 1)

			usr.visible_message("<span style=\"color:red\"><b>[M]</b> pounces at [target]!</span>")
			var/prevLayer = M.layer
			M.layer = EFFECTS_LAYER_BASE

			for(var/i=0, i < jump_tiles, i++)

				//get the mobs on the next step in the pounce, throw em to the side if they are standing. 
				var/dir = get_dir(M,target)
				var/turf/next_step = get_step(M, dir)
				for (var/mob/A in next_step)
					if (A.density)
						M.werewolf_attack(A, "pounce")
				step(M, dir)
				if(i < jump_tiles / 2)
					M.pixel_y += pixel_move
				else
					M.pixel_y -= pixel_move
				sleep(sleep_time)

			usr.pixel_y = 0

			if (M.bioHolder && M.bioHolder.HasEffect("fat") && prob(66))
				M.visible_message("<span style=\"color:red\"><b>[M]</b> crashes due to their heavy weight!</span>")
				playsound(usr.loc, "sound/effects/zhit.ogg", 50, 1)
				M.weakened += 10
				M.stunned += 5

			M.layer = prevLayer

		if (istype(M.loc,/obj/))
			var/obj/container = M.loc
			boutput(M, "<span style=\"color:red\">You leap and slam your head against the inside of [container]! Ouch!</span>")
			M.paralysis += 3
			M.weakened += 5
			container.visible_message("<span style=\"color:red\"><b>[M.loc]</b> emits a loud thump and rattles a bit.</span>")
			playsound(M.loc, "sound/effects/bang.ogg", 50, 1)
			var/wiggle = 6
			while(wiggle > 0)
				wiggle--
				container.pixel_x = rand(-3,3)
				container.pixel_y = rand(-3,3)
				sleep(1)
			container.pixel_x = 0
			container.pixel_y = 0

		return

