/datum/tech
	var/name = "tech"
	var/desc = "placeholder description"

	var/icon_state = "red"

	var/flags = NO_FLAGS

	var/required_points = 0
	var/datum/tier/tier = /datum/tier/one

	var/unlocked = FALSE

	var/datum/techtree/holder

/datum/tech/proc/fire()
	return

/datum/tech/proc/can_unlock(var/mob/M, var/datum/techtree/tree)
	if(!tree.has_access(M, TREE_ACCESS_MODIFY))
		to_chat(M, SPAN_WARNING("You lack the necessary permission required to use this tree"))
		return

	if(!check_tier_level(M, tree))
		return

	if(!(type in tree.all_techs[tier.type]))
		to_chat(M, SPAN_WARNING("You cannot purchase this node!"))
		return

	if(!tree.check_and_use_points(src))
		to_chat(M, SPAN_WARNING("Not enough points to purchase this node."))
		return

	return TRUE

/datum/tech/proc/check_tier_level(var/mob/M, var/datum/techtree/tree)
	if(tree.tier.tier < tier.tier)
		to_chat(M, SPAN_WARNING("This tier level has not been unlocked yet!"))
		return

	var/datum/tier/t_target = tree.tree_tiers[tier.type]
	if(LAZYLEN(tree.unlocked_techs[tier.type]) >= t_target.max_techs)
		to_chat(M, SPAN_WARNING("You can't purchase any more techs of this tier!"))
		return

	return TRUE

/datum/tech/proc/on_unlock(var/datum/techtree/tree)
	return

/datum/tech/proc/show_info(var/mob/M)
	var/total_points = 0
	if(holder)
		total_points = holder.points

	var/list/data = list(
		"xeno" = TREE_FLAG_XENO & holder.flags,
		"name" = name,
		"desc" = desc,
		"cost" = required_points,
		"total_points" = total_points,
		"unlocked" = unlocked
	)

	return data
