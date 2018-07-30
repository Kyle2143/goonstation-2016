/datum/ailment/disease/noliver
	name = "Liver Abscondment"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "The patient's Liver is missing."
	cure = "Liver Transplant"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/noliver/stage_act(var/mob/living/carbon/human/H,var/datum/ailment/D)
	if (..())
		return
	if (!H.organHolder)
		H.cure_disease(D)
		return
	if (!H.organHolder.liver)
		H.cure_disease(D)
		return
	else
		H.take_toxin_damage(4)

		H.weakened = max(H.weakened, 5)
		H.updatehealth()