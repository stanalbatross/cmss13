/datum/area_ichor_list
	var/list/ichors_chasm = list()
	var/list/ichors_deep = list()
	var/list/ichors_shallow = list()
	var/obj/effect/landmark/ichor_eruptor/parent_eruptor = null

/datum/area_ichor_list/proc/populate_lists(turf/T)
	var/area/leucanth/exterior/ichor/zone_area = get_area(T)
	var/list/zone_ichor_turfs = list(T)
	for(var/i=0,i<40,i++)
		var/initial_zone_ichor_turfs_length = length(zone_ichor_turfs)
		for(var/turf/bangusBongus in zone_ichor_turfs)
			if(istype(get_area(bangusBongus), /area/leucanth/exterior/ichor/ford))
				continue
			for(var/ii=1,ii<=8,ii++)
				var/checking_turf = get_step(bangusBongus, alldirs[ii])
				var/checking_area = get_area(checking_turf)
				if(zone_ichor_turfs.Find(checking_turf))
					continue
				if(checking_area == zone_area)
					zone_ichor_turfs |= checking_turf
					continue
				else if(istype(checking_area, /area/leucanth/exterior/ichor/ford))
					var/list/ford_list = list(checking_turf)
					for(var/j=0,j<20,j++)
						var/initial_ford_list_length = length(ford_list)
						for(var/turf/tea in ford_list)
							for(var/jj=1,jj<=8,jj++)
								var/ford_checking_turf = get_step(tea, alldirs[jj])
								if(istype(get_area(ford_checking_turf), /area/leucanth/exterior/ichor/ford))
									ford_list |= ford_checking_turf
						if(initial_ford_list_length == length(ford_list))
							zone_ichor_turfs |= ford_list
							break
		if(initial_zone_ichor_turfs_length == length(zone_ichor_turfs))
			break
	var/fooooorrrrrtnite = rand(0,999)
	for(var/turf/TT in zone_ichor_turfs)
		if(istype(TT, /turf/open/gm/river/ichor/shallow))
			ichors_shallow |= TT

		else if(istype(TT, /turf/open/gm/river/ichor/deep))
			ichors_deep |= TT

		else if(istype(TT, /turf/open/gm/river/ichor/chasm))
			ichors_chasm |= TT

//====================================================Landmark time :o)

/obj/effect/landmark/ichor_eruptor
	var/datum/area_ichor_list/associated_area_ichor_list = null
	var/eruption_chance = 1  // 0 to 100 used in rumble() to see if it will make eruption :o)

/obj/effect/landmark/ichor_eruptor/Initialize(mapload, ...)
	. = ..()
	associated_area_ichor_list = new /datum/area_ichor_list
	associated_area_ichor_list.parent_eruptor = src

	if(!istype(get_area(src), /area/leucanth/exterior/ichor))
		qdel(src)
		return

	associated_area_ichor_list.populate_lists(get_turf(src))

	var/dead_time = ((rand(1,5) * 5) + rand(-1,1)) MINUTES
	addtimer(CALLBACK(src, .proc/rumble, 1), dead_time, TIMER_UNIQUE)

/obj/effect/landmark/ichor_eruptor/proc/get_solidified_ichor_count()
	var/solid_count = 0
	for(var/turf/open/gm/river/ichor/T in associated_area_ichor_list.ichors_shallow)
		if(T.covered)
			solid_count++
	return solid_count


/obj/effect/landmark/ichor_eruptor/proc/rumble(rumble_counter)
	//if eruption fails how soon until next rumble?
	var/rumble_timing = Clamp(rand(5, 25) - (rumble_counter * (1 + (10/eruption_chance))), 1, 15) MINUTES

	message_admins("RUMBBBBLEEEE - [rumble_timing/600]")
	rumble_counter++
	if(prob(eruption_chance))
		//ITS HAPPENING
		playsound(src, 'sound/effects/rumble.ogg', 20, 1, 30, falloff = 2) //quiet before the storm
		addtimer(CALLBACK(src, .proc/erupt, rumble_counter), 1 MINUTES, TIMER_UNIQUE)
		return
	//eruption failed we try again soon
	playsound(src, 'sound/effects/rumble.ogg', 80, 1, 30, falloff = 2)
	eruption_chance = Clamp(eruption_chance + rand(-5,20), 1, 100)
	addtimer(CALLBACK(src, .proc/rumble, rumble_counter), rumble_timing, TIMER_UNIQUE)

/obj/effect/landmark/ichor_eruptor/proc/erupt(rumble_counter) //take rumble counter as influence in how big eruption is
	var/eruption_power = (50 - (30 * (1/rumble_counter))) + (eruption_chance / 2) // 0 to 100 baby!

	message_admins(" !!!eruption!!! --> [eruption_power]")
	for(var/turf/open/gm/river/ichor/T in associated_area_ichor_list.ichors_shallow)
		T.covered = FALSE
		T.update_icon()

	var/dead_time = ((rand(1,5) * 5) + (20 * (100/eruption_power))) MINUTES
	addtimer(CALLBACK(src, .proc/rumble, 0), dead_time, TIMER_UNIQUE)
