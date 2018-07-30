/datum/ailment/disease/nokidneys
	name = "Kidney Abscondment"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "Both of the patient's kidneys are missing."
	cure = "Kidney Transplant"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/nokidneys/stage_act(var/mob/living/carbon/human/H,var/datum/ailment/D)
	if (..())
		return
	if (!H.organHolder)
		H.cure_disease(D)
		return
	if (!H.organHolder.left_kidney && !H.organHolder.right_kidney)
		H.cure_disease(D)
		return
	else
		H.take_toxin_damage(4)

		H.weakened = max(H.weakened, 5)
		H.updatehealth()