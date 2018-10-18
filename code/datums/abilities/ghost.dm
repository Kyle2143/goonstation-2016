// Converted everything related to ghostes from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

//////////////////////////////////////////// Setup //////////////////////////////////////////////////

/mob/proc/make_spooky()
	if (isobserver(src))
		var/datum/abilityHolder/ghost/A = src.get_ability_holder(/datum/abilityHolder/ghost)
		if (A && istype(A))
			return

		var/datum/abilityHolder/ghost/G = src.add_ability_holder(/datum/abilityHolder/ghost)
		G.addAbility(/datum/targetable/ghost/levitate)


//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/obj/screen/ability/ghost
	clicked(params)
		var/datum/targetable/ghost/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span style=\"color:red\">You can't use this ability here.</span>")
			return
		if (spell.targeted && usr:targeting_spell == owner)
			usr:targeting_spell = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_spell = owner
			owner.holder.owner.update_cursor()
		else
			spawn
				spell.handleCast()
		return

/datum/abilityHolder/ghost
	usesPoints = 0
	regenRate = 0
	tabName = "ghost"
	notEnoughPointsMessage = "<span style=\"color:red\">You aren't strong enough to use this ability.</span>"
	usesPoints = 1
	pointName = "Spook Points"
	points = 10
	regenRate = 5
/////////////////////////////////////////////// ghost spell parent ////////////////////////////

/datum/targetable/ghost
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "template"  // No custom sprites yet.
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/ghost
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/obj/screen/ability/ghost/B = new /obj/screen/ability/ghost(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/ghost()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	castcheck()
		if (!holder)
			return 0


		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/ghost/levitate
	name = "Levitate"
	desc = "Drop christmas cheer via graffiti and acts of destruction."
	targeted = 1
	target_anything = 1
	max_range = 10
	cooldown = 2
	start_on_cooldown = 0
	pointCost = 20
	when_stunned = 0
	not_when_handcuffed = 1

	cast(obj/item/target)
		if (!holder)
			return 1

		spawn(rand(30,60))
		animate_levitate(target, 1, 10)

/datum/targetable/ghost/levitate_chair
	name = "Levitate"
	desc = "Drop christmas cheer via graffiti and acts of destruction."
	targeted = 1
	target_anything = 1
	max_range = 10
	cooldown = 2
	start_on_cooldown = 0
	pointCost = 20
	when_stunned = 0
	not_when_handcuffed = 1

	// cast(obj/item/chair/target)
	// 	if (!holder)
	// 		return 1

	// 	animate_levitate(target, 1, 10)

