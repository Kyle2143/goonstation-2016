/datum/projectile/phaser/type_1
	name = "phaser shot"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "phaser_light"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 15
//How much ammo this costs
	cost = 15
//How fast the power goes away
	dissipation_rate = 2
//How many tiles till it starts to lose power
	dissipation_delay = 2
//Kill/Stun ratio
	ks_ratio = 0.5
//name of the projectile setting, used when you change a guns setting
	sname = "stun"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/laser_a.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type?
//kinetic , piercing, slashing, energy, burning, radioactive, toxic
	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 0
	//Can we pass windows
	window_pass = 0
	brightness = 1
	color_red = 0.9
	color_green = 0.9
	color_blue = 0.1

	disruption = 8

	on_pointblank(var/obj/projectile/P, var/mob/living/M)
		stun_bullet_hit(P, M)


//Any special things when it hits shit?
	on_hit(atom/hit)
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			H.slowed = max(2, H.slowed)
			H.change_misstep_chance(5)
			H.emote("twitch_v")
		return

//"stun" really does stamina damage
/datum/projectile/phaser/type_1/stun
	sname = "stun"
	icon_state = "phaser_light"
	cost = 30
	power = 5
	// dissipation_rate = 2
	// dissipation_delay = 2

	on_hit(atom/hit)
		//meant to reduce stamina, deal very minimal damage to slow down carbons
		if (iscarbon(hit))
			var/mob/living/carbon/C = hit
			C.remove_stamina(50)
			// C.emote("twitch_v")
			C.slowed = max(0.5, C.slowed)

		//Should have some effect on robots one second stun...
		else if (istype(hit, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = hit
			R.stunned = max(R.stunned, 1)
		// else if (istype(hit, /mob/lving/critter))	//maybe add special interaction for mob critters


		return

/datum/projectile/phaser/type_1/damage
	sname = "damage"
	icon_state = "phaser_med"
	cost = 60
	power = 15
	
	window_pass = 1
	dissipation_rate = 5
	dissipation_delay = 3


/datum/projectile/phaser/type_1/power
	sname = "power"
	icon_state = "phaser_heavy"
	cost = 90
	power = 30

	window_pass = 1
	dissipation_rate = 5
	dissipation_delay = 4


/datum/projectile/phaser/type_1/utility
	sname = "utility"
	icon_state = "phaser_ultra"
	cost = 15
	power = 1	//almost no damage. Should do something, it's energy right?

	shot_number = 1
	window_pass = 1 //maybe I want this, not sure?
