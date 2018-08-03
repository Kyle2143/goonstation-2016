/datum/random_event/minor/appendicitis
	name = "Appendicitis Contraction"
	centcom_headline = "Appendicitis Contraction"
	centcom_message = "Some crew members have contracted Appendicitis, they should report to medbay before their condition worsens."

	event_effect(var/source)
		..()
		var/list/potential_victims = list()
		for (var/mob/living/carbon/human/H in mobs)
			if (H.stat == 2)
				continue
			potential_victims += H
		if (potential_victims.len)
			var/num = rand(1, 3)
			for (var/i = 0, i < num, i++)
				var/mob/living/carbon/human/patient_zero = pick(potential_victims)
				patient_zero.contract_disease(/datum/ailment/disease/appendicitis,null,null,1)