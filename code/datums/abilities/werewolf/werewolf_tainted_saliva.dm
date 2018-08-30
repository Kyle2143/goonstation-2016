/datum/targetable/werewolf/werewolf_tainted_saliva
	name = "Tainted Saliva"
	desc = "Use your werewolf powers to add reagents from your body to your next attacks!."
	icon_state = "tainted-bite"  // No custom sprites yet.
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 300//2000
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	werewolf_only = 0


	cast(mob/target)
		if (!holder)
			return 1
		var/datum/abilityHolder/werewolf/W = holder
		if (!istype(W))
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1

		M.visible_message("<span style=\"color:red\"><B>[M] starts salivating a disgusting amount!</B></span>")
		
		W.tainted_saliva_active = 1


		spawn(300)
			W.tainted_saliva_active = 0
			boutput(M, __blue("<B>You no longer will spread saliva when you attack!</B>"))
			M.visible_message("<span style=\"color:blue\"><B>[M] stops dripping its disgusing saliva!</B></span>")

		return 0

