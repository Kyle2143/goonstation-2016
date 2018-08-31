/datum/targetable/werewolf/werewolf_defense
	name = "Defensive Howl"
	desc = "Start howling and switch to a defensive stance for 15 seconds."
	icon_state = "howl"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 500
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	werewolf_only = 1

	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1

		var/mob/living/carbon/human/H = M
		if (!istype(H))
			return 1
			
		if (!iswerewolf(M))
			return 1

		H.visible_message("<span style=\"color:red\"><B>[H] shifts to a defensive stance and starts to howl!</B></span>")

		//Do some howling
		H.emote("howl")

		if (H.burning)
			H.burning = 0
			H.visible_message("<span style=\"color:red\"><B>[H] deafening howl completely extinguishes the fire on it!</B></span>")

		spawn(rand(30,50))
			H.emote("howl")
		spawn(rand(80,120))
			H.emote("howl")

		H.stance = "defensive"
		spawn(150)
			H.stance = "normal"
			H.visible_message("<span style=\"color:red\"><B>[H] shifts back to a normal werewolf stance! You can totally tell the difference!</B></span>")

		return 0

