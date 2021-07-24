//lv522 AREAS--------------------------------------//

/area/lv522
	icon_state = "lv-626"
	can_build_special = TRUE
	powernet_name = "ground"

/area/lv522/Initialize()
	. = ..()
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		add_thunder()
	else
		LAZYADD(GLOB.thunder_setup_areas, src)

//Landing Zone 1

/area/lv522/landing_zone_1
	name = "Chances Claim - Landing Zone One"
	icon_state = "explored"

/area/lv522/landing_zone_1/drop1
	name = "Chances Claim - Dropship Alamo Landing Zone"
	icon_state = "shuttle"
	icon = 'icons/turf/area_shiva.dmi'
	lighting_use_dynamic = TRUE

/area/lv522/landing_zone_1/lz1_console
	name = "Chances Claim - Dropship Alamo Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE

//Landing Zone 2

/area/lv522/landing_zone_2
	name = "Chances Claim - Landing Zone Two"
	icon_state = "explored"
/area/lv522/landing_zone_2/drop2
	name = "Chances Claim - Dropship Normandy Landing Zone"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_shiva.dmi'
	lighting_use_dynamic = TRUE

/area/lv522/landing_zone_2/lz2_console
	name = "Chances Claim - Dropship Normandy Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE

//Colony Streets
/area/lv522/colony_streets
	name = "Colony Streets"
	icon_state = "green"
	always_unpowered = 1
	ceiling = CEILING_NONE

/area/lv522/buildings/colony_streets/engineering
	name = "Emergancy Engineering"
	icon_state = "engine_smes"
	ceiling = CEILING_METAL

//A Block
/area/lv522/buildings/A_block
	name = "A-Block"
	icon_state = "blue"
	ceiling = CEILING_METAL

/area/lv522/buildings/A_block/Admin
	name = "A-Block Admin"
	icon_state = "mechbay"
	ceiling = CEILING_GLASS

/area/lv522/buildings/A_block/Dorms
	name = "A-Block Dorms"
	icon_state = "fitness"
	ceiling = CEILING_METAL

/area/lv522/buildings/A_block/Medical
	name = "A-Block Medical"
	icon_state = "medbay"
	ceiling =  CEILING_GLASS

/area/lv522/buildings/A_block/Security
	name = "A-Block Security"
	icon_state = "security"
	ceiling =  CEILING_METAL

//B Block

/area/lv522/buildings/B_Block
	name = "B-Block"
	icon_state = "red"
	ceiling = CEILING_METAL

//C Block

/area/lv522/buildings/C_Block
	name = "C-Block"
	icon_state = ""
	ceiling = CEILING_METAL

/area/lv522/buildings/C_Block/Cargo
	name = "C-Block Cargo"
	icon_state = "primarystorage"
	ceiling = CEILING_METAL

/area/lv522/buildings/C_Block/Mining
	name = "C-Block Mining"
	icon_state = "orange"
	ceiling = CEILING_METAL

/area/lv522/buildings/C_Block/Garage
	name = "C-Block Garage"
	icon_state = "storage"
	ceiling = CEILING_METAL