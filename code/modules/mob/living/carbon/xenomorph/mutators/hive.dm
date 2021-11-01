/datum/xeno_mutator/instant_tackle
	name = "Instant Tackle"
	description = "Every caste now always tackles on the first attempt and for 5 seconds."
	flavor_description = null
	cost = 200
	required_level = 0
	unique = TRUE
	death_persistent = TRUE
	hive_only = TRUE
	individual_only = FALSE
	keystone = FALSE
	flaw = FALSE
	caste_whitelist = list()
	mutator_actions_to_remove
	mutator_actions_to_add

	behavior_delegate_type = null


/datum/xeno_mutator/instant_tackle/apply_mutator(datum/mutator_set/MS)
	if(!MS.can_purchase_mutator(name))
		return FALSE
	if(MS.remaining_points < cost)
		return FALSE
	MS.remaining_points -= cost
	MS.purchased_mutators += name

	if(istype(MS, /datum/mutator_set/individual_mutators))
		var/datum/mutator_set/individual_mutators/IS = MS
		if(IS.xeno)
			IS.xeno.hive.hive_ui.update_xeno_info()
	var/datum/mutator_set/hive_mutators/HS = MS
	HS.tackle_strength_bonus = 10
	for(var/mob/living/carbon/Xenomorph/X in GLOB.living_xeno_list)
		if(X.hivenumber == HS.hive.hivenumber)
			X.recalculate_everything()
			to_chat(X, SPAN_XENOANNOUNCE("Your tackle is now instant!"))
			playsound(X.loc, "alien_help", 25)
			X.xeno_jitter(15)
	return TRUE
