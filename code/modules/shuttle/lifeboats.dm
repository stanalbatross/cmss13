// === MOBILES

/// Generic Lifeboat definition
/obj/docking_port/mobile/lifeboat
	name = "lifeboat"
	area_type = /area/shuttle/lifeboat
	ignitionTime = 8 SECONDS
	width = 27
	height = 7
	rechargeTime = 20 MINUTES

	var/available = TRUE // can be used for evac? false if queenlocked or if in transit already
	var/status = LIFEBOAT_INACTIVE // -1 queen locked, 0 locked til evac, 1 working
	var/list/doors = list()
	var/list/status_displays = list()
	var/status_arrow = 0
	var/static/survivors = 0
	var/obj/structure/machinery/bolt_control/target/terminal

/obj/docking_port/mobile/lifeboat/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/mobile/lifeboat/LateInitialize()
	. = ..()
	for(var/obj/structure/machinery/status_display/lifeboat/SD as anything in GLOB.lifeboat_displays)
		if(SD.id == id)
			status_displays += SD
	for(var/obj/structure/machinery/bolt_control/target/T in machines)
		if(T.id == id)
			terminal = T
			return

/obj/docking_port/mobile/lifeboat/process()
	var/time
	time = getTimerStr()
	for(var/obj/structure/machinery/status_display/lifeboat/SD as anything in status_displays)
		if(status_arrow < 2 || timeLeft() <= 10 || EvacuationAuthority.evac_status < EVACUATION_STATUS_IN_PROGRESS)
			SD.set_and_update_lifeboat(time, "Lifeboat is refueling. Please wait.")
		else
			SD.set_lifeboat_overlay_arrow()
	status_arrow++
	if(status_arrow > 3)
		status_arrow = 0

/obj/docking_port/mobile/lifeboat/set_mode(new_mode)
	. = ..()
	INVOKE_ASYNC(src, .proc/manage_displays, mode)
	if(terminal && mode == SHUTTLE_IDLE && status == LIFEBOAT_ACTIVE)
		terminal.unlock()
	else if(mode == SHUTTLE_CALL)
		addtimer(CALLBACK(src, .proc/check_for_survivors, 3 SECONDS))

/obj/docking_port/mobile/lifeboat/proc/manage_displays(mode)
	SHOULD_NOT_SLEEP(TRUE)

	if(mode == SHUTTLE_RECHARGING)
		START_PROCESSING(SSobj, src)
	else if(mode == SHUTTLE_IDLE)
		STOP_PROCESSING(SSobj, src)
		if(status == LIFEBOAT_ACTIVE)
			for(var/obj/structure/machinery/status_display/lifeboat/SD as anything in status_displays)
				SD.set_lifeboat_overlay("lifeboat_overlay_ready")
		else if(status == LIFEBOAT_LOCKED)
			for(var/obj/structure/machinery/status_display/lifeboat/SD as anything in status_displays)
				SD.set_lifeboat_overlay("lifeboat_overlay_error")
	else if(mode == SHUTTLE_IGNITING)
		for(var/obj/structure/machinery/status_display/lifeboat/SD as anything in status_displays)
			SD.set_lifeboat_overlay("lifeboat_overlay_departing")
	else if(mode == SHUTTLE_CALL)
		for(var/obj/structure/machinery/status_display/lifeboat/SD as anything in status_displays)
			SD.set_lifeboat_overlay("lifeboat_overlay_departed")

/obj/docking_port/mobile/lifeboat/proc/check_for_survivors()
	for(var/mob/living/carbon/human/M as anything in GLOB.alive_human_list) //check for lifeboats survivors
		var/area/A = get_area(M)
		if(!M)
			continue
		if(M.stat != DEAD && (A in shuttle_areas))
			var/turf/T = get_turf(M)
			if(!T || is_mainship_level(T.z))
				continue
			survivors++
			to_chat(M, "<br><br>[SPAN_CENTERBOLD("<big>You have successfully left the [MAIN_SHIP_NAME]. You may now ghost and observe the rest of the round.</big>")]<br>")
	available = FALSE

/// Port Aft Lifeboat (bottom-right, doors on its left side)
/obj/docking_port/mobile/lifeboat/port
	name = "port-aft lifeboat"
	id = "lifeboat1"
	preferred_direction = WEST
	port_direction = WEST

/// Starboard Aft Lifeboat (top-right, doors its right side)
/obj/docking_port/mobile/lifeboat/starboard
	name = "starboard-aft lifeboat"
	id = "lifeboat2"
	preferred_direction = EAST
	port_direction = EAST

/obj/docking_port/mobile/lifeboat/proc/send_to_infinite_transit()
	destination = null
	set_mode(SHUTTLE_IGNITING)
	on_ignition()
	setTimer(ignitionTime)



// === STATIONARIES

/// Generic lifeboat dock
/obj/docking_port/stationary/lifeboat_dock
	name   = "Lifeboat docking port"
	width  = 27
	height = 7

/obj/docking_port/stationary/lifeboat_dock/on_dock_ignition(departing_shuttle)
	var/wait = 0
	for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat/blastdoor/D as anything in GLOB.lifeboat_doors)
		if(D.linked_dock == id)
			addtimer(CALLBACK(D,/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat.proc/close_and_lock), wait)
			addtimer(CALLBACK(D,/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat/blastdoor.proc/bolt_explosion), 75)
			wait += 10

	var/obj/docking_port/mobile/lifeboat/docked_shuttle = departing_shuttle
	if(istype(docked_shuttle))
		for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat/D in docked_shuttle.doors)
			addtimer(CALLBACK(D,/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat.proc/close_and_lock), wait)
			wait += 10

/obj/docking_port/stationary/lifeboat_dock/on_departure(obj/docking_port/mobile/departing_shuttle)
	. = ..()
	for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat/blastdoor/adoor as anything in GLOB.lifeboat_doors)
		if(adoor.linked_dock == id)
			adoor.vacate_premises()

/obj/docking_port/stationary/lifeboat_dock/proc/open_dock()
	var/wait = 0
	for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat/blastdoor/D as anything in GLOB.lifeboat_doors)
		if(D.linked_dock == id)
			addtimer(CALLBACK(D,/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat.proc/unlock_and_open), wait)
			wait += 10

	var/obj/docking_port/mobile/lifeboat/docked_shuttle = get_docked()
	if(docked_shuttle)
		for(var/obj/structure/machinery/door/airlock/multi_tile/D in docked_shuttle.doors)
			addtimer(CALLBACK(D,/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/lifeboat.proc/unlock_and_open), wait)
			wait += 10

/// Port Aft Lifeboat default dock
/obj/docking_port/stationary/lifeboat_dock/almayer/port
	name = "Almayer Port Lifeboat Docking Port"
	dir = NORTH
	id = "almayer-lifeboat1"
	roundstart_template = /datum/map_template/shuttle/lifeboat_port

/// Port Aft Lifeboat default dock
/obj/docking_port/stationary/lifeboat_dock/almayer/starboard
	name = "Almayer Starboard Lifeboat Docking Port"
	dir = NORTH
	id = "almayer-lifeboat2"
	roundstart_template = /datum/map_template/shuttle/lifeboat_starboard

/obj/docking_port/stationary/lifeboat_dock/almayer/Initialize(mapload)
	. = ..()
	GLOB.lifeboat_almayer_docks += src

/obj/docking_port/stationary/lifeboat_dock/almayer/Destroy(force)
	if(force)
		GLOB.lifeboat_almayer_docks -= src
	. = ..()

/// Admin lifeboat dock temporary dest because someone mapped them in for some reason (use transit instead)
/obj/docking_port/stationary/lifeboat_dock/admin
	dir = NORTH
	id = "admin-lifeboat" // change this

// === SHUTTLE TEMPLATES FOR SPAWNING THEM

/// Port-door lifeboat, bow east
/datum/map_template/shuttle/lifeboat_port
	name = "Port door lifeboat"
	shuttle_id = "lifeboat-port"

/// Starboard-door lifeboat, bow east
/datum/map_template/shuttle/lifeboat_starboard
	name = "Starboard door lifeboat"
	shuttle_id = "lifeboat-starboard"


