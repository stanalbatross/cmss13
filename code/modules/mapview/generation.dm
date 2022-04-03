/////////////////////
//MINIMAP MAP DATUM//
/////////////////////
/datum/tacmap/map_datum
	var/name
	var/map_type
	var/icon/minimap
	var/list/sizes

/datum/tacmap/map_datum/proc/generate_tacmap()
	var/icon/new_minimap
	var/list/turf_to_gen
	new_minimap = icon('icons/minimap.dmi', SSmapping.configs[map_type].map_name)
	name = SSmapping.configs[map_type].map_name
	if(map_type == GROUND_MAP)
		turf_to_gen = z1turfs
	else
		turf_to_gen = z2turfs
	var/min_x = 1000
	var/max_x = 0
	var/min_y = 1000
	var/max_y = 0
	for(var/z in turf_to_gen)
		var/turf/T = z
		if(T.x < min_x && !istype(T,/turf/open/space))
			min_x = T.x
		if(T.x > max_x && !istype(T,/turf/open/space))
			max_x = T.x
		if(T.y < min_y && !istype(T,/turf/open/space))
			min_y = T.y
		if(T.y > max_y && !istype(T,/turf/open/space))
			max_y = T.y
		var/area/A = get_area(T)
		if(istype(T,/turf/open/space))
			new_minimap.DrawBox(rgb(0,0,0),T.x,T.y)
			continue
		if(map_type == GROUND_MAP)
			if(A.ceiling >= CEILING_PROTECTION_TIER_2 && A.ceiling != CEILING_REINFORCED_METAL)
				new_minimap.DrawBox(rgb(0,0,0),T.x,T.y)
				continue
			if(A.ceiling >= CEILING_PROTECTION_TIER_2)
				new_minimap.DrawBox(rgb(0,0,0),T.x,T.y)
				continue
		if(locate(/obj/structure/cargo_container) in T)
			new_minimap.DrawBox(rgb(120,120,120),T.x,T.y)
			continue
		if(istype(T,/turf/open/gm/river))
			new_minimap.DrawBox(rgb(150,150,240),T.x,T.y)
			continue
		if(istype(T,/turf/open/gm/dirt))
			new_minimap.DrawBox(rgb(140,140,140),T.x,T.y)
			continue
		if(locate(/obj/structure/fence) in T)
			new_minimap.DrawBox(rgb(55,55,55),T.x,T.y)
			continue
		if(locate(/obj/structure/machinery/door) in T)
			new_minimap.DrawBox(rgb(50,50,50),T.x,T.y)
			continue
		if(locate(/obj/structure/window_frame) in T || locate(/obj/structure/window/framed) in T)
			new_minimap.DrawBox(rgb(40,40,40),T.x,T.y)
			continue
		if(istype(T,/turf/closed/wall/almayer/outer))
			new_minimap.DrawBox(rgb(20,20,20),T.x,T.y)
			continue
		if(istype(T,/turf/closed/wall))
			new_minimap.DrawBox(rgb(30,30,30),T.x,T.y)
			continue
		if(A.ceiling == CEILING_GLASS)
			new_minimap.DrawBox(rgb(100,100,100),T.x,T.y)
			continue
		if(A.ceiling == CEILING_METAL)
			new_minimap.DrawBox(rgb(80,80,80),T.x,T.y)
			continue
		if(A.ceiling == CEILING_REINFORCED_METAL)
			new_minimap.DrawBox(rgb(60,60,60),T.x,T.y)
			continue
		if(istype(T,/turf/open/space) || istype(T,/turf/open/floor/almayer_hull))
			new_minimap.DrawBox(rgb(0,0,0),T.x,T.y)
			continue
	new_minimap.Crop(1,1,max_x,max_y)
	sizes = list(max_x, max_y, min_x, min_y)
	spawn(30 MINUTES)
		generate_tacmap()