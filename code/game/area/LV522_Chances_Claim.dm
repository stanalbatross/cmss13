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

//parent types

/area/lv522/indoors
	name = "Chance's Claim - Outdoors"
	icon_state = "cliff_blocked" //because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_METAL
	soundscape_playlist = SCAPE_PL_LV522_OUTDOORS

/area/lv522/outdoors
	name = "Chance's Claim - Outdoors"
	icon_state = "cliff_blocked" //because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	soundscape_playlist = SCAPE_PL_LV522_INDOORS


//Landing Zone 1

/area/lv522/landing_zone_1
	name = "Chance's Claim - Landing Zone One"
	icon_state = "explored"
	is_resin_allowed =  "FALSE"

/area/shuttle/drop1/lv522
	name = "Chance's Claim - Dropship Alamo Landing Zone"
	icon_state = "shuttle"
	icon = 'icons/turf/area_shiva.dmi'
	lighting_use_dynamic = TRUE

/area/lv522/landing_zone_1/lz1_console
	name = "Chance's Claim - Dropship Alamo Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE

//Landing Zone 2

/area/lv522/landing_zone_2
	name = "Chance's Claim - Landing Zone Two"
	icon_state = "explored"
/area/shuttle/drop2/lv522
	name = "Chance's Claim - Dropship Normandy Landing Zone"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_shiva.dmi'
	lighting_use_dynamic = TRUE

/area/lv522/landing_zone_2/lz2_console
	name = "Chance's Claim - Dropship Normandy Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE

/area/lv522/landing_zone_2/UD6_Typhoon
	name = "Chance's Claim - UD6 Typhoon"
	icon_state = "shuttle"
	ceiling =  CEILING_METAL
	requires_power = FALSE

//Outdoors areas
/area/lv522/outdoors/colony_streets //WHY IS THIS A SUBTYPE OF BUILDINGS AAAARGGHGHHHH YOU DIDN'T EVEN USE OBJECT INHERITANCE FOR THE CIELINGS I HATE YOU BOBBY
	name = "Colony Streets"
	icon_state = "green"
	ceiling = CEILING_NONE

//misc indoors areas
/area/lv522/indoors/engineering
	name = "Emergency Engineering"
	icon_state = "engine_smes"

/area/lv522/indoors/West_LZ_Storage
	name = "West LZ1 Storage"
	icon_state = ""

/area/lv522/indoors/West_LZ_House
	name = "West LZ1 House"
	icon_state = ""

/area/lv522/indoors/South_Cargo_Buildings
	name = "South Cargo Buildings"
	icon_state = ""

//A Block
/area/lv522/indoors/A_block
	name = "A-Block"
	icon_state = "blue"

/area/lv522/indoors/A_block/Admin
	name = "A-Block Admin"
	icon_state = "mechbay"
	ceiling = CEILING_GLASS

/area/lv522/indoors/A_block/Dorms
	name = "A-Block Dorms"
	icon_state = "fitness"

/area/lv522/indoors/A_block/Medical
	name = "A-Block Medical"
	icon_state = "medbay"
	ceiling =  CEILING_GLASS

/area/lv522/indoors/A_block/Security
	name = "A-Block Security"
	icon_state = "security"

//B Block

/area/lv522/indoors/B_Block
	name = "B-Block"
	icon_state = "red"

/area/lv522/indoors/B_Block/Science_Lab
	name = "Science Lab"
	icon_state = "purple"

//C Block

/area/lv522/indoors/C_Block
	name = "C-Block"
	icon_state = ""

/area/lv522/indoors/C_Block/Cargo
	name = "C-Block Cargo"
	icon_state = "primarystorage"

/area/lv522/indoors/C_Block/Mining
	name = "C-Block Mining"
	icon_state = "orange"

/area/lv522/indoors/C_Block/Garage
	name = "C-Block Garage"
	icon_state = "storage"
