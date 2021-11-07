/datum/area_glamour_list
	var/list/glamour_list = list()
	var/list/turf_list = list()

/obj/effect/glamour
	icon = 'icons/turf/walls/leucanth.dmi'
	icon_state = "stupid"
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
	var/area/A = get_area(src)
	if(!istype(A, /area/leucanth))
		qdel(src)
		message_admins("[name] deleted --> !!!NOT IN LEUCANTH AREA!!!")
		return
	var/area/leucanth/Gl_area = A
	var/datum/area_glamour_list/AGL = Gl_area.check_for_turf_in_greater_area_glamour_list(get_turf(src))
	if(AGL)
		glamour_parent = AGL
		AGL.glamour_list += src
	else
		message_admins("stupid stupid dumb idiot TURF NOT IN A GREATER LIST, SAD!")
		qdel(src)

/obj/effect/glamour/Crossed(O)
	. = ..()
	if(istype(O, /mob/living/carbon))
		return
	var/mob/living/carbon/M = O
	if(M.client)
		for(var/obj/effect/glamour/GGGG in glamour_parent.glamour_list)
			M.client.images -= GGGG.glamour_image
		addtimer(CALLBACK(src, .proc/readd_images, M, glamour_parent), 5 SECONDS, TIMER_UNIQUE)

/obj/effect/glamour/proc/readd_images(mob/living/carbon/M, datum/area_glamour_list/GL)
	for(var/obj/effect/glamour/GGGG in GL.glamour_list)
		M.client.images |= GGGG.glamour_image

/obj/effect/glamour/fake_rock
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "sand"
	glamour_icon = 'icons/turf/ground_map.dmi'
	glamour_icon_state = "sand"

