/datum/area_ichor_list
	var/list/ichors_eruptors = list()
	var/list/ichors_deep = list(null)
	var/list/ichors_shallow = list(null)
	var/obj/effect/landmark/ichor_eruptor/parent_eruptor = null

/datum/area_ichor_list/proc/populate_lists(var/turf/T)
	find_all_ichors_eruptors()
	find_all_ichors_deep()
	find_all_ichors_shallow()

/datum/area_ichor_list/proc/find_all_ichors_eruptors()
	for(var/i = 0, i < 40, i++) // 40 is the maxium check number, very arbitrary :o)
		if(check_ichors_eruptors_neighbors())
			break				//it always breaks before it gets to that number anyways

/datum/area_ichor_list/proc/check_ichors_eruptors_neighbors()
	var/completed_turf_check = 0
	var/parent_eruptor_turf = get_turf(parent_eruptor)
	var/parent_eruptor_area = get_area(parent_eruptor)
	for(var/turf/T in ichors_eruptors)
		for(var/i = 1, i <= 8, i++)
			var/checking_turf = get_step(T, alldirs[i])
			if(istype(checking_turf, parent_eruptor_turf) && istype(get_area(checking_turf), parent_eruptor_area))
				ichors_eruptors |= checking_turf
		completed_turf_check++
	if(completed_turf_check == length(ichors_eruptors))
		return TRUE
	return FALSE

/datum/area_ichor_list/proc/find_all_ichors_deep()
	for(var/i = 0, i < 40, i++)
		if(check_ichors_deep_neighbors())
			break

/datum/area_ichor_list/proc/check_ichors_deep_neighbors()
	var/completed_turf_check = 0
	var/parent_eruptor_turf = get_turf(parent_eruptor)
	var/deep_ichor_area = get_area(ichors_deep[1])
	var/searching_turf = ichors_deep[1]
	if(ichors_deep[1] == null)	//we have no starting turf, go east until you find one -- THIS MUST BE MAPPED IN LIKE THIS SO NOTHING WILL BREAK HAHHAHAHAHA
		searching_turf = parent_eruptor_turf
		for(var/i, i < 20, i++)
			searching_turf = get_step(searching_turf, EAST)
			if(get_area(searching_turf) == get_area(parent_eruptor_turf))
				continue
			else
				ichors_deep[1] = searching_turf
				deep_ichor_area = get_area(searching_turf)
				break
	for(var/turf/T in ichors_deep)
		for(var/i = 1, i <= 8, i++)
			var/checking_turf = get_step(T, alldirs[i])
			if(istype(checking_turf, searching_turf) && istype(get_area(checking_turf), deep_ichor_area))
				ichors_deep |= checking_turf
		completed_turf_check++
	if(completed_turf_check == length(ichors_deep))
		return TRUE
	return FALSE

/datum/area_ichor_list/proc/find_all_ichors_shallow()
	var/funnnycolor = pipe_colors[rand(1, length(pipe_colors))]
	for(var/i = 0, i < 40, i++)
		if(check_ichors_shallow_neighbors())
			break
	for(var/turf/T in ichors_shallow)
		var/obj/structure/bookcase/bigchungus = new /obj/structure/bookcase(T)
		bigchungus.color =  funnnycolor

/datum/area_ichor_list/proc/check_ichors_shallow_neighbors()
	var/initial_ichors_shallow_length = length(ichors_shallow)
	var/parent_eruptor_turf = get_turf(parent_eruptor)
	var/shallow_ichor_area = get_area(ichors_shallow[1])
	var/searching_turf = ichors_shallow[1]
	if(ichors_shallow[1] == null)	//we have no starting turf, go east until you find one -- THIS MUST BE MAPPED IN LIKE THIS SO NOTHING WILL BREAK HAHHAHAHAHA
		searching_turf = ichors_deep[1]
		for(var/i, i < 20, i++)
			searching_turf = get_step(searching_turf, EAST)
			if(get_area(searching_turf) == get_area(parent_eruptor_turf) || get_area(searching_turf) == get_area(ichors_deep[1]))
				continue
			else
				ichors_shallow[1] = searching_turf
				shallow_ichor_area = get_area(searching_turf)
				break
	for(var/turf/T in ichors_shallow)
		for(var/iii = 1, iii <= 8, iii++)
			var/checking_turf = get_step(T, alldirs[iii])
			if(istype(checking_turf, searching_turf) && get_area(checking_turf) == shallow_ichor_area)
				var/list/proximity_check_list = range(2, checking_turf)
				for(var/area/leucanth/exterior/ichor/AA in proximity_check_list)
					if(istype(AA, get_area(ichors_deep[1])))
						ichors_shallow |= checking_turf
						break
			else if(istype(checking_turf, searching_turf) && istype(get_area(checking_turf), /area/leucanth/exterior/ichor/ford))
				var/list/ford_turfs = list(checking_turf)
				for(var/ii = 1, ii <= 10, ii++)
					var/initial_ford_turf_length = length(ford_turfs)
					for(var/turf/TTT in ford_turfs)
						for(var/iiii = 1, iiii <= 8, iiii++)
							var/ford_checking_turf = get_step(TTT, alldirs[iiii])
							if(istype(get_area(ford_checking_turf), /area/leucanth/exterior/ichor/ford))
								ford_turfs |= ford_checking_turf
					if(length(ford_turfs) == initial_ford_turf_length)
						ii = 11
						break
				ichors_shallow |= ford_turfs
	if(initial_ichors_shallow_length == length(ichors_shallow))
		return TRUE
	return FALSE

	/*for(var/turf/T in ichors_deep)
		for(var/turf/TT in range(4, T))
			if(!istype(get_area(TT), /area/leucanth/exterior/ichor) || ichors_shallow.Find(TT))
				break
			var/area/leucanth/exterior/ichor/checking_area = get_area(TT)
			if(!get_area(TT) == checking_area.ford_area_type) //FOUND A FORD!!!! - theses will break if either eruption zone beside them erupts
				var/list/ford_turfs = list(TT)
				for(var/ii = 1, ii <= 10, ii++)
					var/initial_ford_turf_length = length(ford_turfs)
					for(var/turf/TTT in ford_turfs)
						for(var/i = 1, i <= 8, i++)
							var/checking_turf = get_step(TT, alldirs[i])
							if(get_area(checking_turf) == get_area(TT))
								ford_turfs |= checking_turf
					if(length(ford_turfs) == initial_ford_turf_length)
						ii == 11
				ichors_shallow |= ford_turfs
				for(var/turf/gogogo in ford_turfs)
					new /obj/structure/bed(gogogo)
			if(get_area(TT) == (get_area(parent_eruptor)).shallow_area_type)
				if(!ichors_eruptors.Find(TT) && !ichors_deep.Find(TT))
					ichors_shallow |= TT */





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


