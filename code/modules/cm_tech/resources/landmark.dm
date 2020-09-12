/obj/effect/landmark/resource_node
    icon_state = "landmark_node"

    var/points_per_cycle = RESOURCE_PER_CYCLE
    var/is_area_controller = TRUE

/obj/effect/landmark/resource_node/Initialize(mapload, ...)
    . = ..()

    var/obj/structure/resource_node/RN = new(loc, TRUE, is_area_controller)
    RN.resource_to_give = points_per_cycle
    qdel(src)