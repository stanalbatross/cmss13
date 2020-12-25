/datum/xeno_mutator/steel_crest 
	name = "STRAIN: Defender - Steel Crest"
	description = "You trade your tail swipe for slightly increased headbutt damage, and the ability to slowly move and headbutt while fortified."
	cost = MUTATOR_COST_EXPENSIVE
	individual_only = TRUE
	caste_whitelist = list("Defender") 
	keystone = TRUE

/datum/xeno_mutator/steel_crest/apply_mutator(datum/mutator_set/individual_mutators/MS)
	. = ..()
	if (. == 0)
		return

	var/mob/living/carbon/Xenomorph/Defender/D = MS.xeno
	D.mutation_type = DEFENDER_STEELCREST
	D.remove_action("Tail Sweep")
	D.steelcrest = TRUE
	if(D.fortify)
		D.ability_speed_modifier += 2.5
	MS.recalculate_actions(description, flavor_description)
	D.recalculate_stats()
