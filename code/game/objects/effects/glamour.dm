/datum/area_glamour_list
	var/area/leucanth/glamour_area
	var/list/glamour_list = list()
	var/list/glamour_targets = list()

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
	var/glamour_pixel_x = 0
	var/glamour_pixel_y = 0
	var/list/stupiddebuglist = list()

/obj/effect/glamour/Initialize(mapload, ...)
	. = ..()
	icon = null
	icon_state = null
	glamour_image = image(glamour_icon, src.loc, glamour_icon_state, ABOVE_XENO_LAYER, dir, glamour_pixel_x, glamour_pixel_y)

	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	var/list/adjacent_turfs = list()
	for(var/turf/AT in range(1,T))
		for(var/i in diagonals)
			if(get_dir(T, AT) == i)
				continue
		if(get_area(AT) != get_area(src) || AT == T)
			continue
		adjacent_turfs += AT
	if(!istype(A, /area/leucanth))
		message_admins("[name] deleted in [A.name] ||| IT WASNT IN A LEUCANTH AREA!?")
		qdel(src)
		return
	stupiddebuglist |= adjacent_turfs
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
					G.glamour_parent.glamour_list |= G
				else
					target_glamours_without_parents += AdjG
			if(G.glamour_parent)
				for(var/obj/effect/glamour/AdjG in target_glamours_without_parents)
					AdjG.glamour_parent = G.glamour_parent
					G.glamour_parent.glamour_list |= AdjG
		if(!G.glamour_parent)
			var/datum/area_glamour_list/newAGL = new /datum/area_glamour_list
			newAGL.glamour_list += G
			newAGL.glamour_list |= target_glamours_without_parents
			G.glamour_parent = newAGL
			for(var/obj/effect/glamour/AdjG in target_glamours_without_parents)
				AdjG.glamour_parent = newAGL

/obj/effect/glamour/Crossed(O)
	. = ..()
	if(!istype(O, /mob/living/carbon) || locate(O) in glamour_parent.glamour_targets)
		return
	var/mob/living/carbon/M = O
	if(M.client)
		glamour_parent.glamour_targets |= M
		for(var/obj/effect/glamour/GGGG in glamour_parent.glamour_list)
			M.client.images -= GGGG.glamour_image
			GGGG.opacity = FALSE
		addtimer(CALLBACK(src, .proc/readd_images, M, glamour_parent), 5 SECONDS, TIMER_UNIQUE)

/obj/effect/glamour/proc/readd_images(mob/living/carbon/M, datum/area_glamour_list/GL)
	if(!M.client)
		return FALSE
	for(var/obj/effect/glamour/GGGG in GL.glamour_list)
		if(M in (get_turf(GGGG)).contents)
			addtimer(CALLBACK(src, .proc/readd_images, M, glamour_parent), 5 SECONDS, TIMER_UNIQUE)
			return
	for(var/obj/effect/glamour/GGGG in GL.glamour_list)
		M.client.images |= GGGG.glamour_image
		GGGG.glamour_parent.glamour_targets -= M
		GGGG.opacity = initial(GGGG.opacity)

/obj/effect/glamour/fake_rock
	icon = 'icons/turf/walls/walls.dmi'
	icon_state = "rock"
	glamour_icon = 'icons/turf/walls/walls.dmi'
	glamour_icon_state = "rock"

/obj/effect/glamour/overhanging_rockledge
		icon = 'icons/turf/leucanth.dmi'
		glamour_icon = 'icons/turf/leucanth.dmi'

/obj/effect/glamour/overhanging_rockledge/cobaltite_cove_1st
	icon_state = "cobaltite_cove_1st"
	glamour_icon_state = "cobaltite_cove_1st"

/obj/effect/glamour/overhanging_rockledge/cobaltite_cove_2nd
	icon_state = "cobaltite_cove_2nd"
	glamour_icon_state = "cobaltite_cove_2nd"

/obj/effect/glamour/overhanging_rockledge/cobaltite_wall_2nd
	icon_state = "cobaltite_wall_2nd"
	glamour_icon_state = "cobaltite_wall_2nd"

/obj/effect/glamour/overhanging_rockledge/cobaltite_wall_3rd
	icon_state = "cobaltite_wall_3rd"
	glamour_icon_state = "cobaltite_wall_3rd"
	opacity = TRUE

/obj/effect/glamour/overhanging_rockledge/cobaltite_wall_3rd_2
	icon_state = "cobaltite_wall_3rd_2"
	glamour_icon_state = "cobaltite_wall_3rd_2"
	opacity = TRUE

/obj/effect/glamour/overhanging_rockledge/cobaltite_cove_3rd
	icon_state = "cobaltite_cove_3rd"
	glamour_icon_state = "cobaltite_cove_3rd"
	opacity = TRUE

/obj/effect/glamour/overhanging_rockledge/cobaltite_cove_3rd_2
	icon_state = "cobaltite_cove_3rd_2"
	glamour_icon_state = "cobaltite_cove_3rd_2"
	opacity = TRUE


/obj/effect/glamour/overhanging_rockledge/cobaltite_wall_surface
	icon_state = "cobaltite_wall_surface"
	glamour_icon_state = "cobaltite_wall_surface"
	opacity = TRUE

/obj/effect/glamour/overhanging_rockledge/cobaltite_cavewall_top
	icon_state = "cobaltite_cave_2nd"
	glamour_icon_state = "cobaltite_cave_2nd"

/obj/effect/glamour/overhanging_rockledge/cobaltite_cavewall_top_2
	icon_state = "cobaltite_cave_2nd_2"
	glamour_icon_state = "cobaltite_cave_2nd_2"
/obj/structure/prop/leucanth/shadow
	icon = 'icons/turf/leucanth.dmi'
	icon_state = "shade"
	layer = ABOVE_WEED_LAYER

/obj/structure/prop/leucanth/shadow_2
	icon = 'icons/turf/leucanth.dmi'
	icon_state = "shade_2"
	layer = ABOVE_WEED_LAYER

/obj/structure/prop/leucanth/shadow_f
	icon = 'icons/turf/leucanth.dmi'
	icon_state = "shade_f"
	layer = ABOVE_WEED_LAYER
