
//Areas for the Kutjevo Refinery

/area/leucanth
	name = "Leucanth Labs"
	icon = 'icons/turf/area_leucanth.dmi'
	//ambience = list('figuresomethingout.ogg')
	icon_state = "sus"
	can_build_special = TRUE //T-Comms structure
	temperature = 308.7 //kelvin, 35c, 95f
	lighting_use_dynamic = 1
	var/list/greater_area_glamour_list = list()

/area/leucanth/proc/check_for_turf_in_greater_area_glamour_list(turf/T)
	for(var/datum/area_glamour_list/AGL in greater_area_glamour_list)
		var/found_turf = locate(T) in AGL.turf_list
		if(T == found_turf)
			return AGL
		else
			return null

/area/leucanth/Initialize(mapload, ...)
	. = ..()
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		add_thunder()
	else
		LAZYADD(GLOB.thunder_setup_areas, src)

	var/list/big_chungus_list = get_area_turfs(src)
	for(var/turf/T in big_chungus_list)
		var/datum/area_glamour_list/AGL = check_for_turf_in_greater_area_glamour_list(T)
		var/list/adjacent_turfs = range(1,T)
		for(var/turf/AT in adjacent_turfs)
			var/doodle = locate(get_dir(T, AT)) in diagonals
			if(get_area(AT) != src || AT == T || doodle)
				adjacent_turfs -= AT
		if(AGL)
			//its alrady in the great list, now lets check its adjacents and add them in if they arent already!
			for(var/turf/AT in adjacent_turfs)
				var/datum/area_glamour_list/ATAGL = check_for_turf_in_greater_area_glamour_list(AT)
				if(ATAGL)
					if(ATAGL != AGL)
						message_admins("something terrible has happened, WHY ARE THERE TWO AGL RIGHT NEXT TO EACHOTHER!?!?")
						AGL.turf_list |= ATAGL.turf_list
						for(var/obj/effect/glamour/GGG in ATAGL.glamour_list)
							GGG.glamour_parent = AGL
						AGL.glamour_list |= ATAGL.glamour_list
						qdel(ATAGL)
					// else if(ATAGL == AGL) message_admins("Good job, they match")
				else
					AGL.turf_list += AT
		else
			//its not in the great list, lets check if any of its adjacents are and add it to their great list if they are in one.
			for(var/turf/AT in adjacent_turfs)
				var/datum/area_glamour_list/ATAGL = check_for_turf_in_greater_area_glamour_list(AT)
				if(ATAGL)
					ATAGL.turf_list += T
				else
					var/datum/area_glamour_list/nAGL = new /datum/area_glamour_list
					greater_area_glamour_list += nAGL
					nAGL.turf_list += T
					nAGL.turf_list |= adjacent_turfs
		for(var/datum/area_glamour_list/ATAGL in greater_area_glamour_list)
			for(var/obj/effect/glamour/G in ATAGL)
				message_admins("NAME:[G.name] ==> [G.loc] ==> [G.glamour_parent]")

/area/shuttle/drop1/leucanth
	name = "Leucanth Labs - Dropship Alamo Landing Zone"
	icon_state = "shuttle"
	icon = 'icons/turf/area_leucanth.dmi'
	lighting_use_dynamic = 1

/area/leucanth/exterior
	name = "Leucanth Labs - Exterior"
	ceiling = CEILING_NONE
	icon_state = "ext"

/area/leucanth/interior
	name = "Leucanth Labs - Interior"
	ceiling = CEILING_UNDERGROUND_ALLOW_CAS
	icon_state = "int"
	requires_power = 1

/area/leucanth/exterior/lz_pad
	name = "Leucanth Labs Landing Zone"
	icon_state = "lz1_pad"
	weather_enabled = FALSE
	unlimited_power = 1//ds computer
	is_resin_allowed = FALSE

/area/leucanth/exterior/ichor
	name = "Leucanth Labs - Ichor River"
	icon_state = "ext"

/area/leucanth/exterior/ichor/pistil
	name = "Leucanth Labs - The Pistil Ichor River"
	icon_state = "ichor_pistil"

/area/leucanth/exterior/ichor/stamen
	name = "Leucanth Labs - The Stamen Ichor River"
	icon_state = "ichor_stamen"

/area/leucanth/exterior/ichor/stigma
	name = "Leucanth Labs - The Stigma Ichor River"
	icon_state = "ichor_stigma"

/area/leucanth/exterior/ichor/anther
	name = "Leucanth Labs - The Anther Ichor River"
	icon_state = "ichor_anther"

/area/leucanth/exterior/se_barrens
	name = "Leucanth Labs - South East Barrens"
	icon_state = "se_barrens"

/area/leucanth/exterior/sw_barrens
	name = "Leucanth Labs - South West Barrens"
	icon_state = "sw_barrens"

/area/leucanth/exterior/ne_barrens
	name = "Leucanth Labs - North East Barrens"
	icon_state = "ne_barrens"

/area/leucanth/exterior/nw_barrens
	name = "Leucanth Labs - North West Barrens"
	icon_state = "nw_barrens"

/area/leucanth/exterior/e_caves
	name = "Leucanth Labs - East Caves"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "e_caves"

/area/leucanth/exterior/n_caves
	name = "Leucanth Labs - North Caves"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "n_caves"

/area/leucanth/exterior/w_caves
	name = "Leucanth Labs - West Caves"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "w_caves"

/area/leucanth/exterior/jungle
	name = "Big Chungus"
	icon_state = "ext"

/area/leucanth/exterior/jungle/fungal_flats
	name = "Leucanth Labs - Fungal Flats Land"
	icon_state = "fungal_flats"

/area/leucanth/exterior/jungle/arid_cractus
	name = "Leucanth Labs - Arid Cractus Land"
	icon_state = "arid_cractus"

/area/leucanth/exterior/jungle/great_ferns
	name = "Leucanth Labs - Great Fern Land"
	icon_state = "great_fern"

/area/leucanth/exterior/jungle/bulb_land
	name = "Leucanth Labs - Bulb Land"
	icon_state = "bulb_land"

/area/kutjleucanthevo/exterior/jungle/grassy_matts
	name = "Leucanth Labs - Grassy Matts Land"
	icon_state = "grassy_matts"

/area/leucanth/exterior/jungle/ichor_hotsprings
	name = "Leucanth Labs - Ichor Hot Springs"
	icon_state = "ichor_hotsprings"

/area/leucanth/exterior/cove
	name = "Biggle Chunkleton"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "ext"

/area/leucanth/exterior/cove/fungal_flats
	name = "Leucanth Labs - Fungal Flats Cove"
	icon_state = "fungal_flats_cove"

/area/leucanth/exterior/cove/arid_cractus
	name = "Leucanth Labs - Arid Cractus Cove"
	icon_state = "arid_cractus_cove"

/area/leucanth/exterior/cove/great_ferns
	name = "Leucanth Labs - Great Fern Cove"
	icon_state = "great_fern_cove"

/area/leucanth/exterior/cove/bulb_land
	name = "Leucanth Labs - Bulb Cove"
	icon_state = "bulb_land_cove"

/area/kutjleucanthevo/exterior/cove/grassy_matts
	name = "Leucanth Labs - Grassy Matts Cove"
	icon_state = "grassy_matts_cove"

/area/leucanth/exterior/cove/ichor_hotsprings
	name = "Leucanth Labs - Ichor Hot Cove"
	icon_state = "ichor_hotsprings_cove"
