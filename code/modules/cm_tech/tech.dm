/datum/tech
	var/name = "tech"
	var/desc = "placeholder description"

	var/icon_state = "red"

	var/flags = NO_FLAGS
	var/tech_flags = NO_FLAGS

	var/required_points = 0
	var/datum/tier/tier = /datum/tier/one

	var/unlocked = FALSE

	var/datum/techtree/holder

/datum/tech/proc/fire()
	return

/**
 * Any additional arguments you want to pass to the `can_unlock` and `on_unlock` procs
 * They will be placed at the end of the argument lists in the order returned by this proc
 *
 * Note that if you want to pass multiple arguments, you will need to return a list
 * Additionally, list arguments need to be nested in lists, otherwise each of their
 * elements will be processed as an individual argument
 */
/datum/tech/proc/get_additional_args(var/mob/M)
	return

/datum/tech/proc/can_unlock(var/mob/M, var/datum/techtree/tree)
	SHOULD_CALL_PARENT(TRUE)
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

/datum/tech/ui_status(mob/user, datum/ui_state/state)
	return holder.ui_status(user, state)

/datum/tech/ui_data(mob/user)
	var/total_points = 0
	if(holder)
		total_points = holder.points

	. = list(
		"total_points" = total_points,
		"unlocked" = unlocked
	)

/datum/tech/ui_static_data(mob/user)
	. = list(
		"theme" = holder.ui_theme,
		"cost" = required_points,
		"name" = name,
		"desc" = desc,
	)

/datum/tech/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TechNode", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/tech/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase")
			holder.purchase_node(usr, src)
			. = TRUE

/datum/tech/proc/on_tree_insertion(var/datum/techtree/tree)
	return
