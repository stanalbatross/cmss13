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

/area/lv522/colony_streets
	name = "Colony Streets"
	icon_state = "green"
	always_unpowered = 1 //Will this mess things up? God only knows
