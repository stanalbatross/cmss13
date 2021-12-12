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
			var/obj/chinguos = new /obj/item/tool/shovel(TT)
			chinguos.name += "[fooooorrrrrtnite]"

		else if(istype(TT, /turf/open/gm/river/ichor/deep))
			ichors_deep |= TT
			var/obj/chinguos = new /obj/item/tool/wrench(TT)
			chinguos.name += "[fooooorrrrrtnite]"

		else if(istype(TT, /turf/open/gm/river/ichor/chasm))
			ichors_chasm |= TT
			var/obj/chinguos = new /obj/item/tool/warning_cone(TT)
			chinguos.name += "[fooooorrrrrtnite]"

//====================================================Landmark time :o)

/obj/effect/landmark/ichor_eruptor
	var/datum/area_ichor_list/associated_area_ichor_list = null
	invisibility = 0

/obj/effect/landmark/ichor_eruptor/Initialize(mapload, ...)
	. = ..()
	associated_area_ichor_list = new /datum/area_ichor_list
	associated_area_ichor_list.parent_eruptor = src

	if(!istype(get_area(src), /area/leucanth/exterior/ichor))
		qdel(src)
		return

	associated_area_ichor_list.populate_lists(get_turf(src))


