/datum/area_glamour_list
	var/area/leucanth/glamour_area
	var/list/glamour_list = list()

/datum/area_glamour_list/New()
	. = ..()
	GLOB.greater_area_glamour_list += src

/datum/area_glamour_list/Destroy(force, ...)
	. = ..()
	GLOB.greater_area_glamour_list -= src
/*
/datum/area_glamour_list/proc/check_for_turf_in_greater_area_glamour_list(turf/T)
	for(var/datum/area_glamour_list/AGL in greater_area_glamour_list)
		var/found_turf = locate(T) in AGL.turf_list
		if(T == found_turf)
			return AGL
		else
			return null
*/
/mob/proc/add_all_glamours()
	if(!client)
		return
	for(var/datum/area_glamour_list/AGL in GLOB.greater_area_glamour_list)
		for(var/obj/effect/glamour/G in AGL.glamour_list)
			client.images += G.glamour_image

/obj/effect/glamour
	icon = 'icons/turf/walls/leucanth.dmi'
	icon_state = "stupid"
	anchored = TRUE
	opacity = FALSE
	var/datum/area_glamour_list/glamour_parent = null
	var/image/glamour_image
	var/glamour_icon = null
	var/glamour_icon_state = null
	var/glamour_dir = SOUTH
	var/glamour_pixel_x = 0
	var/glamour_pixel_y = 0

/obj/effect/glamour/Initialize(mapload, ...)
	. = ..()
	icon = null
	icon_state = null
	glamour_image = image(glamour_icon, src.loc, glamour_icon_state, ABOVE_XENO_LAYER, glamour_dir, glamour_pixel_x, glamour_pixel_y)

	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	var/list/adjacent_turfs
	for(var/turf/AT in range(1,T))
		var/doodle = locate(get_dir(T, AT)) in diagonals
		if(get_area(AT) != src || AT == T || doodle)
			continue
		adjacent_turfs += AT
	if(!istype(A, /area/leucanth))
		message_admins("[name] deleted in [A.name] ||| IT WASNT IN A LEUCANTH AREA!?")
		qdel(src)
		return
	check_and_update_glamours_on_turfs(src, adjacent_turfs)

/obj/effect/glamour/proc/check_and_update_glamours_on_turfs(obj/effect/glamour/G, list/glamour_turf_list)
	if(G.glamour_parent)
		for(var/turf/T in glamour_turf_list)
			for(var/obj/effect/glamour/AdjG in T.contents)
				if(AdjG.glamour_parent && AdjG.glamour_parent != G.glamour_parent)
					G.glamour_parent.glamour_list |= AdjG.glamour_parent.glamour_list
	else
		var/list/target_glamours_without_parents = list()
		for(var/turf/T in glamour_turf_list)
			for(var/obj/effect/glamour/AdjG in T.contents)
				if(AdjG.glamour_parent && !G.glamour_parent)
					G.glamour_parent = AdjG.glamour_parent
					G.glamour_parent.glamour_list += G
				else
					target_glamours_without_parents += AdjG
			if(G.glamour_parent)
				for(var/obj/effect/glamour/AdjG in target_glamours_without_parents)
					G.glamour_parent.glamour_list |= AdjG.glamour_parent.glamour_list
					if(AdjG.glamour_parent)
						qdel(AdjG.glamour_parent)
		if(!G.glamour_parent)
			var/datum/area_glamour_list/newAGL = new /datum/area_glamour_list
			newAGL.glamour_list += G
			newAGL.glamour_list |= target_glamours_without_parents
			G.glamour_parent = newAGL
			for(var/obj/effect/glamour/AdjG in target_glamours_without_parents)
				AdjG.glamour_parent = newAGL

/obj/effect/glamour/Crossed(O)
	. = ..()
	message_admins("IT WORKED")
	if(!istype(O, /mob/living/carbon))
		message_admins("failure")
		return
	var/mob/living/carbon/M = O
	if(M.client)
		message_admins("bingus")
		for(var/obj/effect/glamour/GGGG in glamour_parent.glamour_list)
			M.client.images -= GGGG.glamour_image
			message_admins("[GGGG.name] removed from [M.name]")
		addtimer(CALLBACK(src, .proc/readd_images, M, glamour_parent), 5 SECONDS, TIMER_UNIQUE)
	message_admins("NOTHING HAPPENED")

/obj/effect/glamour/proc/readd_images(mob/living/carbon/M, datum/area_glamour_list/GL)
	for(var/obj/effect/glamour/GGGG in GL.glamour_list)
		if(M in (get_turf(GGGG)).contents)
			addtimer(CALLBACK(src, .proc/readd_images, M, glamour_parent), 5 SECONDS, TIMER_UNIQUE)
			return
	for(var/obj/effect/glamour/GGGG in GL.glamour_list)
		M.client.images += GGGG.glamour_image
		message_admins("[GGGG.name] added to [M.name]")

/obj/effect/glamour/fake_rock
	icon = 'icons/turf/walls/walls.dmi'
	icon_state = "rock"
	glamour_icon = 'icons/turf/walls/walls.dmi'
	glamour_icon_state = "rock"

