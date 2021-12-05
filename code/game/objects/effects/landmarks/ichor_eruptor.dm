/datum/area_ichor_list
	var/list/ichors_eruptors = list()
	var/list/ichors_deep = list()
	var/list/ichors_shallow = list()
	var/obj/effect/landmark/ichor_eruptor/parent_eruptor = null

/datum/area_ichor_list/proc/populate_lists(var/turf/T)
	find_all_ichors_eruptors()
	find_all_ichors_deep()

/datum/area_ichor_list/proc/find_all_ichors_eruptors()
	for(var/i = 0, i < 40, i++)
		if(check_ichors_eruptors_neighbors())
			break

/datum/area_ichor_list/proc/check_ichors_eruptors_neighbors()
	var/completed_turf_check = 0
	var/parent_eruptor_turf = get_turf(parent_eruptor)
	var/parent_eruptor_area = get_area(parent_eruptor)
	for(var/turf/T in ichors_eruptors)
		for(var/i = 1, i <= 4, i++)
			var/checking_turf = get_step(T, cardinal[i])
			if(istype(checking_turf, parent_eruptor_turf) && istype(get_area(checking_turf), parent_eruptor_area))
				ichors_eruptors |= checking_turf
		completed_turf_check++
	if(completed_turf_check == length(ichors_eruptors))
		return TRUE
	return FALSE

/datum/area_ichor_list/proc/find_all_ichors_deep()
	for(var/i = 0, i < 40, i++)
		if(check_ichors_deep_neighbors())
			funny_proc()
			break

/datum/area_ichor_list/proc/funny_proc()
	for(var/turf/T in ichors_deep)
		new /obj/item/device/flashlight/flare/on(T)

/datum/area_ichor_list/proc/check_ichors_deep_neighbors() //NONE OF THIS WOOOORKSSSSS >:C
	var/bingusBongus = length(ichors_deep)
	var/completed_turf_check = 0
	var/parent_eruptor_turf = get_turf(parent_eruptor)
	var/deep_ichor_area = null
	var/searching_turf = parent_eruptor_turf
	if(length(ichors_deep) < 1)	//we have no starting turf, go east until you find one -- THIS MUST BE MAPPED IN LIKE THIS SO NOTHING WILL BREAK HAHHAHAHAHA
		for(var/i, i < 20, i++)
			searching_turf = get_step(searching_turf, EAST)
			if(get_area(searching_turf) == get_area(parent_eruptor_turf))
				continue
			else
				ichors_deep += searching_turf
				deep_ichor_area = get_area(searching_turf)
				new /obj/structure/machinery/bodyscanner(parent_eruptor_turf)
				new /obj/structure/machinery/autolathe(searching_turf)
				message_admins("bingus")
				break
	for(var/turf/T in ichors_deep)
		message_admins("bongus - [length(ichors_deep)]")
		for(var/i = 1, i <= 8, i++)
			var/checking_turf = get_step(T, alldirs[i])
			if(istype(checking_turf, searching_turf) && istype(get_area(checking_turf), deep_ichor_area))
				message_admins("[checking_turf], [searching_turf] && [get_area(checking_turf)], [deep_ichor_area]")
				new /obj/structure/girder(checking_turf)
				ichors_deep |= checking_turf
		completed_turf_check++
	message_admins("[bingusBongus] --> [length(ichors_deep)]")
	if(completed_turf_check == length(ichors_deep))
		return TRUE
	return FALSE

//====================================================Landmark time :o)

/obj/effect/landmark/ichor_eruptor
	var/datum/area_ichor_list/associated_area_ichor_list = null

/obj/effect/landmark/ichor_eruptor/Initialize(mapload, ...)
	. = ..()
	associated_area_ichor_list = new /datum/area_ichor_list
	associated_area_ichor_list.parent_eruptor = src

	if(!istype(get_area(src), /area/leucanth/exterior/ichor))
		qdel(src)
		return

	associated_area_ichor_list.ichors_eruptors += get_turf(src)
	associated_area_ichor_list.populate_lists(get_turf(src))


