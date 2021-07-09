/datum/character_trait/physical_trait
	applyable = FALSE
	trait_group = /datum/character_trait_group/physical_trait

/datum/character_trait/physical_trait/lisp
	trait_name = "Lisping"
	trait_desc = "You have difficulty with pronouncing 'S' sounds (and similar). Expect to be mocked mercilessly."
	applyable = TRUE
	inapplicable_roles = list(JOB_SEA, JOB_COMMAND_ROLES_LIST, JOB_SYNTH, JOB_SYNTH_SURVIVOR, JOB_ADMIRAL)
	inapplicable_species = list(SPECIES_SYNTHETIC)

/datum/character_trait/physical_trait/lisp/apply_trait(mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(target, TRAIT_LISPING, TRAIT_SOURCE_QUIRK)
	target.speech_problem_flag = TRUE

/datum/character_trait/physical_trait/lisp/unapply_trait(mob/living/carbon/human/target)
	..()
	REMOVE_TRAIT(target, TRAIT_LISPING, TRAIT_SOURCE_QUIRK)

/datum/character_trait_group/physical_trait
	trait_group_name = "Physical Traits"
