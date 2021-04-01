
/obj/docking_port/mobile/lifeboat
	name = "lifeboat"
	id = "lifeboat"
	ignitionTime = 5 SECONDS
	width  = 5
	height = 12
	area_type = /area/almayer/evacuation

/obj/docking_port/mobile/lifeboat/Initialize(mapload)
	. = ..()
	SSshuttle.lifeboats += src
/obj/docking_port/mobile/lifeboat/Destroy()
	SSshuttle.lifeboats -= src
	return ..()

/obj/docking_port/stationary/lifeboat_dock
	width  = 5
	height = 12
	roundstart_template = /datum/map_template/shuttle/lifeboat

/obj/docking_port/stationary/lifeboat_dock/dock1
	name   = "Lifeboat Dock 1"
	id = "lifeboat_dock1"
/obj/docking_port/stationary/lifeboat_dock/dock2
	name   = "Lifeboat Dock 2"
	id = "lifeboat_dock2"
/obj/docking_port/stationary/lifeboat_dock/dock3
	name   = "Lifeboat Dock 3"
	id = "lifeboat_dock3"
