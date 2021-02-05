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

	tgui_interact(user)
	return TRUE

/obj/effect/node/tgui_interact(mob/user, datum/tgui/ui)
	if(!info)
		qdel(src)
		return

	info.tgui_interact(user, ui)
