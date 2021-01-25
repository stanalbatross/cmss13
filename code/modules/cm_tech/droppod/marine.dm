/obj/structure/droppod/tech
	name = "\improper USCM Droppod"

	var/datum/tech/droppod/attached_tech

/obj/structure/droppod/tech/Initialize(mapload, time_to_drop, var/datum/tech/droppod/attached_tech)
	if(!attached_tech)
		qdel(src)
		return

	. = ..()

	src.attached_tech = attached_tech
	attached_tech.on_pod_created(src)

/obj/structure/droppod/tech/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user) || !attached_tech || !(droppod_flags & DROPPOD_OPEN))
		return

	if(!attached_tech.can_access(user, src))
		return

	attached_tech.on_pod_access(user, src)
