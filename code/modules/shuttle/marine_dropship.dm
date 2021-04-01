/// Generic game marine dropship
/obj/docking_port/mobile/marine_dropship
	name = "marine dropship"
	callTime = DROPSHIP_TRANSIT_DURATION
	ignitionTime = 10 SECONDS

/// Generic game marine dropship port
/obj/docking_port/mobile/marine_dropship
	name = "Generic Marine Dropship Dock"
	id = "generic marine dropship"

/// Ship-side Hangar landing zones
/obj/docking_port/stationary/marine_dropship
	name   = "Dropship Docking Port"
	width  = 11
	height = 21

/obj/docking_port/stationary/marine_dropship/rasputin
	name   = "Rasputin Docking Port"
	id     = "rasputin_dock"
	width  =  9
	height = 18
	roundstart_template = /datum/map_template/shuttle/rasputin

/obj/docking_port/stationary/marine_dropship/drop_pod
	name   = "Drop Pod Dock"
	id     = "drop_pod_dock"
	width  =  7
	height =  7
	roundstart_template = /datum/map_template/shuttle/drop_pod

/// Generic game landing zones
/obj/docking_port/stationary/landing_zone
	name = "Marine Dropship Landing Zone"
	id   = "landing zone"
	width   = 11
	height  = 21

/obj/docking_port/stationary/landing_zone/lz1
	name = "Landing Zone 1"
	id   = "lz1"

/obj/docking_port/stationary/landing_zone/lz2
	name = "Landing Zone 2"
	id   = "lz2"

/// Virtual landing point created on-the-fly for Hijack
/obj/docking_port/stationary/crash_landing
	name = "Crash location"
/obj/docking_port/stationary/crash_landing/Initialize(mapload, crash_identifier)
	id = "crash_[crash_identifier]"
	return ..()

/// Rasputin Dropship from the USS Sulaco
/obj/docking_port/mobile/marine_dropship/rasputin
	name    = "Rasputin Drop Ship"
	id      = "rasputin"
	width   = 9
	height  = 18

/// AUD-25 Alamo Dropship from the USS Almayer
/obj/docking_port/mobile/marine_dropship/alamo
	width   = 11
	height  = 21

/// AUD-25 Normandy Dropship from the USS Almayer
/obj/docking_port/mobile/marine_dropship/normandy
	width   = 11
	height  = 21

/// Drop pod used aboard the sulaco
/obj/docking_port/mobile/marine_dropship/sulaco_pod
	name    = "Sulaco Drop Pod"
	id      = "drop_pod"
	width   = 7
	height  = 7
