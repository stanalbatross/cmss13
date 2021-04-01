
/obj/docking_port/mobile/lifeboat
	name = "lifeboat"
	ignitionTime = 5 SECONDS
/obj/docking_port/mobile/lifeboat/Initialize(mapload)
	. = ..()
	SSshuttle.lifeboats += src
/obj/docking_port/mobile/lifeboat/Destroy()
	SSshuttle.lifeboats -= src
	return ..()

/obj/docking_port/stationary/lifeboat_dock
	name   = "Lifeboat Dock"
	width  = 5
	height = 13
	//roundstart_template = /datum/map_template/shuttle/lifeboat
