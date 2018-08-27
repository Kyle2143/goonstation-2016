/datum/targetable/werewolf/werewolf_pounce
	name = "Pounce"
	desc = "Pounce on a target location."
	targeted = 1
	target_nodamage_check = 1
	max_range = 10
	var/min_range = 3		//gotta jump kinda far at least
	cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	werewolf_only = 1
	restricted_area_check = 2

	cast(turf/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		if (get_dist(M, target) < src.min_range)
			boutput(M, __red("[target] is too close to leap, it would be more of a hop."))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

/////////////////////////////////////

		if (istype(M.loc,/mob/))
			boutput(usr, "<span style=\"color:red\">You can't jump right now!</span>")
			return 1

		var/jump_tiles = get_dist(M, target)
		var/pixel_move = round((8/7)*jump_tiles)
		var/sleep_time = 1

		if (istype(M.loc,/turf/))
			playsound(M.loc, "sound/weapons/thudswoosh.ogg", 50, 1)

			//Can pounce at any turf, but if there is a mob on it, you get text that has the target's name for flavour.
			//maybe there's a better way to do this, but changing the argument for cast to atom didn't seem to do it so I'm not going to fret over it - Kyle
			var/mob_found = 0
			for (/mob/T in target.contents)
				usr.visible_message("<span style=\"color:red\"><b>[M]</b> pounces at [M]!</span>")
				mob_found = 1
				break
			if (!mob_found)
				usr.visible_message("<span style=\"color:red\"><b>[M]</b> pounces at [target]!</span>")
			var/prevLayer = M.layer
			M.layer = EFFECTS_LAYER_BASE

			for(var/i=0, i < jump_tiles, i++)

				step(M, get_dir(M,target))
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

/datum/action/bar/private/icon/werewolf_pounce
	duration = 300
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "werewolf_pounce"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/turf/target
	var/datum/targetable/werewolf/werewolf_pounce/pounce
	var/last_complete = 0
	var/do_we_get_points = 0 // For the specialist objective. Did we feed on the target long enough?

	New(Target, Pounce)
		target = Target
		pounce = Pounce
		..()


	onEnd()
		..()

		var/datum/abilityHolder/A = spread.holder
		var/mob/living/M = owner
		var/mob/living/carbon/human/HH = target


		if (A && istype(A))
			A.locked = 0

	onInterrupt()
		..()
		var/datum/abilityHolder/A = spread.holder
