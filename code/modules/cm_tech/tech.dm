/datum/tech
	var/name = "tech"
	var/desc = "placeholder description"

	var/icon = 'icons/effects/techtree/tech.dmi'
	var/icon_state

	var/flags = NO_FLAGS
	var/tech_flags = NO_FLAGS

	var/required_points = 0
	var/datum/tier/tier = /datum/tier/one

	var/unlocked = FALSE

	var/datum/techtree/holder

	// Variables for the physical node in the tree
	var/obj/effect/node

	var/locked_color = "#ff0000"
	var/background_icon = "background"

/datum/tech/proc/can_unlock(var/mob/M)
	SHOULD_CALL_PARENT(TRUE)

	if(!holder.has_access(M, TREE_ACCESS_MODIFY))
		to_chat(M, SPAN_WARNING("You lack the necessary permission required to use this tree"))
		return

	if(!check_tier_level(M))
		return

	if(!(type in holder.all_techs[tier.type]))
		to_chat(M, SPAN_WARNING("You cannot purchase this node!"))
		return

	if(!holder.can_use_points(required_points))
		to_chat(M, SPAN_WARNING("Not enough points to purchase this node."))
		return

	return TRUE

/datum/tech/proc/check_tier_level(var/mob/M)
	if(holder.tier.tier < tier.tier)
		to_chat(M, SPAN_WARNING("This tier level has not been unlocked yet!"))
		return

	var/datum/tier/t_target = holder.tree_tiers[tier.type]
	if(LAZYLEN(holder.unlocked_techs[tier.type]) >= t_target.max_techs)
		to_chat(M, SPAN_WARNING("You can't purchase any more techs of this tier!"))
		return

	return TRUE

/** Called when a tech is unlocked. Usually, benefits can be applied here
  * however, the purchase can still be cancelled by returning FALSE
  *
  * If you sleep in this proc, you must call can_unlock after the sleep ends to make sure you can still purchase the tech in question
**/
/datum/tech/proc/on_unlock(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	unlocked = TRUE
	to_chat(user, SPAN_HELPFUL("You have purchased the '[name]' tech node."))
	holder.add_points(-required_points)
	update_icon(node)
	return TRUE

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
	holder = tree
	background_icon = tree.background_icon

/datum/tech/proc/update_icon(var/obj/effect/node)
	if(!icon_state)
		node.icon = 'icons/effects/techtree/tech.dmi'
		node.icon_state = null
		return

	node.icon = 'icons/effects/techtree/tech.dmi'
	if(unlocked)
		node.icon_state = "[background_icon]"
	else
		node.icon_state = "[background_icon]_locked"

	node.overlays += get_tier_overlay()

	var/image/tech_icon = image(icon, node, icon_state)
	if(!unlocked)
		tech_icon.color = locked_color
	node.overlays += tech_icon

/datum/tech/proc/get_tier_overlay()
	var/image/I = image(node.icon, node, unlocked? "+lines" : "+lines_locked")
	I.color = tier.color

	return I
