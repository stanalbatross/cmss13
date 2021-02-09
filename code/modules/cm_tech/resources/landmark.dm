/obj/effect/landmark/resource_node
	icon_state = "landmark_node"

	var/resource_multiplier = 1
	var/is_area_controller = TRUE

/obj/effect/landmark/resource_node/Initialize(mapload, ...)
	. = ..()

	var/obj/structure/resource_node/RN = new(loc, TRUE, is_area_controller)
	RN.resources_per_second *= resource_multiplier
	return INITIALIZE_HINT_QDEL
