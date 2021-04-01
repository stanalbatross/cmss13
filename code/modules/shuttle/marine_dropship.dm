/// Generic game marine dropship
/obj/docking_port/mobile/marine_dropship
	name = "marine dropship"
	//callTime = DROPSHIP_TRANSIT_DURATION
	callTime = 100 SECONDS
	ignitionTime = 10 SECONDS
	prearrivalTime = 10 SECONDS
	rechargeTime = 2 MINUTES
	preferred_direction = SOUTH
	var/crash_landing = 0
	var/turf/crashloc

/obj/docking_port/mobile/marine_dropship/on_prearrival()
	. = ..()
	if(!crashing || !crashloc.z) return
	marine_announcement("DROPSHIP ON COLLISION COURSE. CRASH IMMINENT." , "EMERGENCY", 'sound/AI/dropship_emergency.ogg')
	sleep(1 SECONDS)
	if(security_level < SEC_LEVEL_RED) //automatically set security level to red.
		set_security_level(SEC_LEVEL_RED, TRUE)
	for(var/obj/structure/machinery/power/apc/A in machines) //break APCs
		if(A.z != crashloc.z) continue
		if(prob(A.crash_break_probability))
			A.overload_lighting()
			A.set_broken()
	var/turf/sploded
	for(var/j=0; j<20; j++)
		sploded = locate(crashloc.x + rand(-10, 10), crashloc.y + rand(-12, 12), crashloc.z)
		//Fucking. Kaboom.
		cell_explosion(sploded, 200, 20, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, "dropship crash") //Clears out walls
		sleep(3)
	// Break the ultra-reinforced windows.
	// Break the briefing windows.
	for(var/i in GLOB.hijack_bustable_windows)
		var/obj/structure/window/H = i
		H.shatter_window(1)
	// Delete the briefing door(s).
	for(var/D in GLOB.hijack_deletable_windows)
		qdel(D)

/obj/docking_port/mobile/marine_dropship/on_crash()
	for(var/i in GLOB.alive_human_list) //knock down mobs
		var/mob/living/carbon/human/M = i
		if(M.z != crashloc.z) continue
		if(M.buckled)
			to_chat(M, SPAN_WARNING("You are jolted against [M.buckled]!"))
			shake_camera(M, 3, 1)
		else
			to_chat(M, SPAN_WARNING("The floor jolts under your feet!"))
			shake_camera(M, 10, 1)
			M.KnockDown(3)
	// Also passengers OK
	for(var/area/Ar in shuttle_areas)
		for(var/mob/M in Ar)
			to_chat(M, SPAN_HIGHDANGER("You feel an impact as the dropship hits something!"))
			shake_camera(M, 15, 2)
			M.KnockDown(4)
	enter_allowed = 0 //No joining after dropship crash
	for (var/obj/structure/machinery/door_display/research_cell/d in machines)
		if(is_mainship_level(d.z) || is_loworbit_level(d.z))
			d.ion_act() //Breaking xenos out of containment
	//Stolen from events.dm. WARNING: This code is old as hell
	for (var/obj/structure/machinery/power/apc/APC in machines)
		if(is_mainship_level(APC.z) || is_loworbit_level(APC.z))
			APC.ion_act()
	for (var/obj/structure/machinery/power/smes/SMES in machines)
		if(is_mainship_level(SMES.z) || is_loworbit_level(SMES.z))
			SMES.ion_act()
	if(SSticker.mode)
		SSticker.mode.is_in_endgame = TRUE
		SSticker.mode.force_end_at = world.time + 15000 // 25 mins
	// OPEN DOORS
	for(var/area/Ar in shuttle_areas)
		for(var/obj/structure/machinery/door/airlock/AL in Ar)
			uscm_open_up(AL, TRUE)

/obj/docking_port/mobile/marine_dropship/on_ignition()

	return ..()

/obj/docking_port/mobile/marine_dropship/proc/uscm_open_up(obj/structure/machinery/door/airlock/AL, stay_open = FALSE)
	set waitfor = FALSE
	AL.unlock()
	if(stay_open)
		AL.open()
		AL.lock()

/obj/docking_port/mobile/marine_dropship/proc/uscm_close_up(obj/structure/machinery/door/airlock/AL)
	set waitfor = FALSE
	AL.unlock()
	AL.close()

/obj/docking_port/mobile/marine_dropship/proc/uscm_shutters_up(obj/structure/machinery/door/poddoor/shutters/transit/AS, crashlanding = FALSE)
	set waitfor = FALSE
	if(AS.operating == 2)
		AS.operating = 0
	AS.open()
	if(crashlanding)
		AS.operating = 1 // No move anymore

/obj/docking_port/mobile/marine_dropship/proc/uscm_shutters_takeoff(obj/structure/machinery/door/poddoor/shutters/transit/AS)
	set waitfor = FALSE
	AS.close()
	if(AS.operating == 0)
		AS.operating = 2 // STAY SEATED AND DO NOT TOUCH FUCKING SHUTTERS

/obj/docking_port/mobile/marine_dropship/canMove()
	. = ..()
	if(!. || crash_landing == 2)
		return FALSE

/obj/docking_port/mobile/marine_dropship/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force)
	. = ..()
	if(. == DOCKING_SUCCESS)
		if(!istype(get_docked(), /obj/docking_port/stationary/transit))
			if(crash_landing)
				crash_landing = 2 // Not usable anymore. TOASTED
			for(var/area/Ar in shuttle_areas)
				Ar.ambience_exterior = null
				for(var/obj/structure/machinery/door/poddoor/shutters/transit/AS in Ar)
					uscm_shutters_up(AS, crash_landing)
				for(var/obj/structure/machinery/door/airlock/AL in Ar)
					uscm_open_up(AL)
				for(var/mob/M in Ar)
					M?.client?.soundOutput?.update_ambience(Ar, TRUE)
		else
			for(var/area/Ar in shuttle_areas)
				Ar.ambience_exterior = 'sound/ambience/dropship_ambience_loop.ogg'
				for(var/obj/structure/machinery/door/airlock/AL in Ar)
					uscm_close_up(AL)
				for(var/obj/structure/machinery/door/poddoor/shutters/transit/AS in Ar)
					uscm_shutters_takeoff(AS)
				for(var/mob/M in Ar)
					M?.client?.soundOutput?.update_ambience(Ar, TRUE)


/obj/docking_port/mobile/marine_dropship/proc/crashShuttle(sectionName)
	if(crashing) return FALSE
	// Start by setting up an imaginary dock port at the crash loc
	if(!sectionName || !GLOB.shuttle_crash_sections[sectionName])
		sectionName = pick(GLOB.shuttle_crash_sections)
	if(almayer_aa_cannon?.protecting_section == sectionName) // Redirect if AA
		sectionName = pick(GLOB.shuttle_crash_sections - sectionName)
	var/obj/effect/landmark/shuttle_loc/marine_crs/LL = pick(GLOB.shuttle_crash_sections[sectionName])
	var/turf/crash_turf = get_turf(LL)
	if(!crash_turf?.z) return FALSE
	var/crash_id = "[id]-[sectionName]-[world.time]"
	new /obj/docking_port/stationary/crash_landing(crash_turf, crash_id)
	// Prepare global hijack stuff
	if(bomb_set)
		for(var/obj/structure/machinery/nuclearbomb/bomb in world)
			bomb.end_round = FALSE
	if(almayer_orbital_cannon)
		almayer_orbital_cannon.is_disabled = TRUE
		addtimer(CALLBACK(almayer_orbital_cannon, /obj/structure/orbital_cannon.proc/enable), 10 MINUTES, TIMER_UNIQUE)
	if(almayer_aa_cannon)
		almayer_aa_cannon.is_disabled = TRUE
	// Send shuttle to its doom
	crashloc = crash_turf
	crashing = TRUE
	crash_landing = 1
	SSshuttle.moveShuttle(id, "crash_[crash_id]", TRUE)
	return TRUE

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
	name    = "Crash location"
	width   = 11
	height  = 21
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
	landing_sound = null

