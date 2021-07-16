//LV522 AREAS--------------------------------------//

/area/lv522
	icon_state = "lv-626"
	can_build_special = TRUE
	powernet_name = "ground"

/area/LV522/Initialize()
	. = ..()
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		add_thunder()
	else
		LAZYADD(GLOB.thunder_setup_areas, src)

//Landing Zones

/area/shuttle/drop1/lv522
	name = "Chances Claim - Dropship Alamo Landing Zone"
	icon_state = "shuttle"
	icon = 'icons/turf/area_shiva.dmi'
	lighting_use_dynamic = TRUE

/area/shuttle/drop2/lv522
	name = "Chances Claim - Dropship Normandy Landing Zone"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_shiva.dmi'
	lighting_use_dynamic = TRUE

/area/lv522/exterior/lz1_console
	name = "Chances Claim - Dropship Alamo Console"
	requires_power = FALSE

/area/lv522/exterior/lz1_console/two
	name = "Chances Claim - Dropship Normandy Console"

//Colony
/area/lv522/colony_streets
	name = "Colony Streets"
	icon_state = "green"
	always_unpowered = 1 //Will this mess things up? God only knows
