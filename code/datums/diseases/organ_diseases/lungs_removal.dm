/datum/ailment/disease/nolungs
	name = "Lungs Abscondment"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "Both of the patient's lungs are missing."
	cure = "Lung Transplant"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/nolungs/stage_act(var/mob/living/carbon/human/H,var/datum/ailment/D)
	if (..())
		return
	if (!H.organHolder)
		H.cure_disease(D)
		return
	if (!H.organHolder.left_lung && !H.organHolder.right_lung)
		H.cure_disease(D)
		return
	else
		H.take_toxin_damage(4)

		H.weakened = max(H.weakened, 5)
		H.updatehealth()
		H.add_stam_mod_regen("lung_removal", 9)
		H.add_stam_mod_max("lung_removal", 150)


	on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
		..()
		H.remove_stam_mod_regen("lung_removal")
		H.remove_stam_mod_max("lung_removal")

		return

//missing one lung
/datum/ailment/disease/single_lung
	name = "Missing Lung"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "One of the patient's lungs are missing."
	cure = "Lung Transplant"
	affected_species = list("Human","Monkey")

	on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
		..()
		H.remove_stam_mod_regen("lung_removal")
		H.remove_stam_mod_max("lung_removal")

		return
/datum/ailment/disease/single_lung/stage_act(var/mob/living/carbon/human/H,var/datum/ailment/D)
	if (..())
		return
	if (!H.organHolder)
		H.cure_disease(D)
		return
	if ((H.organHolder.left_lung && !H.organHolder.right_lung) || (!H.organHolder.left_lung && H.organHolder.right_lung) )
		H.cure_disease(D)
		return
	else
		H.take_toxin_damage(4)

		H.add_stam_mod_regen("lung_removal", 5)
		H.add_stam_mod_max("lung_removal", 80)

		H.weakened = max(H.weakened, 5)
		H.updatehealth()


