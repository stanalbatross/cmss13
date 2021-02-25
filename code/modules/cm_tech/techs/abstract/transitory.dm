/datum/tech/transitory
	name = "Transitory tech"
	desc = "Transitions the tree to another tier."
	icon_state = "upgrade"

	var/datum/tier/before
	var/datum/tier/next

/datum/tech/transitory/check_tier_level(var/mob/M)
	if(before && before != holder.tier.type)
		to_chat(M, SPAN_WARNING("You can't unlock this node!"))
		return

	return TRUE

/datum/tech/transitory/on_unlock()
	. = ..()
	if(!next)
		return
	var/datum/tier/next_tier = holder.tree_tiers[next]
	if(next_tier)
		holder.tier = next_tier
		for(var/a in next_tier.tier_turfs)
			var/turf/T = a
			T.color = next_tier.color

/datum/tech/transitory/get_tier_overlay()
	if(!next)
		return

	var/datum/tier/next_tier = holder.tree_tiers[next]
	var/image/I = ..()
	I.color = next_tier.color

	return I

/datum/tech/transitory/tier1
	name = "Unlock tier 1"
	tier = /datum/tier/free

	flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

	next = /datum/tier/one

/datum/tech/transitory/tier2
	name = "Unlock tier 2"
	tier = /datum/tier/one_transition_two

	flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

	before = /datum/tier/one
	next = /datum/tier/two
	var/techs_to_unlock = 2

	required_points = 0

/datum/tech/transitory/tier2/check_tier_level(var/mob/M)
	. = ..()

	if(!.)
		return .

	var/amount_of_unlocked_techs = LAZYLEN(holder.unlocked_techs[before])

	if(amount_of_unlocked_techs < techs_to_unlock)
		to_chat(M, SPAN_WARNING("You must unlock [techs_to_unlock] techs from [initial(before.name)] before you can unlock this tech!"))
		return FALSE

/datum/tech/transitory/tier3
	name = "Unlock tier 3"
	tier = /datum/tier/two_transition_three

	flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

	required_points = 0

	before = /datum/tier/two
	next = /datum/tier/three

/datum/tech/transitory/tier4
	name = "Unlock tier 4"
	tier = /datum/tier/three_transition_four

	flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

	required_points = 0

	before = /datum/tier/three
	next = /datum/tier/four

	// This is sadly disabled for now
	var/control_points_needed = 0.5

/datum/tech/transitory/tier4/check_tier_level(var/mob/M) // Can unlock this at any tier after 2
	if(holder.tier.tier < initial(before.tier))
		to_chat(M, SPAN_WARNING("You can't unlock this node!"))
		return

	/*
	var/list/resources = SStechtree.resources

	var/total = 0
	var/controlled = 0
	for(var/a in resources)
		var/obj/structure/resource_node/R = a

		if(!(R.z in GAME_PLAY_Z_LEVELS))
			continue

		if(R.tree == tree)
			controlled++

		total++

	*/

	return TRUE
