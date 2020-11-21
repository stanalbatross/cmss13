/turf/open/blank
	name = "Blank"
	icon = 'icons/effects/effects.dmi'
	icon_state = "white"
	mouse_opacity = FALSE
	can_bloody = FALSE

/obj/effect/node
	name = "Tech Node"
	icon = 'icons/effects/alert.dmi'

	icon_state = "red"

	var/datum/tech/info

/obj/effect/node/clicked(mob/user, list/mods)
	. = ..()
	
	ui_interact(user)
	return TRUE

/obj/effect/node/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)
	if(!info)
		qdel(src)
		return

	var/list/data = info.show_info(user)

	if(!data)
		return

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "tree_node.tmpl", "Node Information", 400, 250)
		ui.set_initial_data(data)
		ui.allowed_user_stat = -1
		ui.set_auto_update(FALSE)
		ui.open()

/obj/effect/node/Topic(href, href_list)
	. = ..()
	if(!info)
		qdel(src)
		return

	if(isobserver(usr))
		return
		
	if(!info.holder)
		return

	if(href_list["purchase_node"])
		info.holder.purchase_node(usr, info)
	
	ui_interact(usr)
	return TRUE