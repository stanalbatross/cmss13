// === MOBILES

/// Generic Lifeboat definition
/obj/docking_port/mobile/escape_pod
	name = "escapepod"
	id = "escapepod"
	area_type = /area/shuttle/evacuation_pod
	ignitionTime = 8 SECONDS
	width = 5
	height = 4
	rechargeTime = 5 MINUTES

	var/can_launch = FALSE
	var/cap_weight = 3

	var/status = ESCAPE_STATE_IDLE
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program
	var/list/cryo_cells = list()
	var/list/obj/structure/machinery/door/airlock/evacuation/doors = list()
	var/static/survivors = 0

/obj/docking_port/mobile/escape_pod/proc/can_launch()
	if(..() && EvacuationAuthority.evac_status >= EVACUATION_STATUS_INITIATING)
		switch(status)
			if(ESCAPE_STATE_READY)
				return TRUE
			if(ESCAPE_STATE_DELAYED)
				for(var/obj/structure/machinery/cryopod/evacuation/C in cryo_cells)
					if(!C.occupant)
						return FALSE
				return TRUE

/obj/docking_port/mobile/escape_pod/proc/can_cancel()
	. = (EvacuationAuthority.evac_status > EVACUATION_STATUS_STANDING_BY && (status in ESCAPE_STATE_READY to ESCAPE_STATE_DELAYED))

/obj/docking_port/mobile/escape_pod/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/mobile/escape_pod/LateInitialize()
	. = ..()

/obj/docking_port/mobile/escape_pod/proc/check_for_survivors()
	for(var/mob/living/carbon/human/M as anything in GLOB.alive_human_list)
		var/area/A = get_area(M)
		if(!M)
			continue
		if(M.stat != DEAD && (A in shuttle_areas))
			var/turf/T = get_turf(M)
			if(!T || is_mainship_level(T.z))
				continue
			survivors++
			if(survivors > cap_weight)
				return FALSE
			to_chat(M, "<br><br>[SPAN_CENTERBOLD("<big>You have successfully left the [MAIN_SHIP_NAME]. You may now ghost and observe the rest of the round.</big>")]<br>")
	playsound(src,'sound/effects/escape_pod_warmup.ogg', 50, 1)
	return TRUE

#define MOVE_MOB_OUTSIDE \
for(var/obj/structure/machinery/cryopod/evacuation/C in cryo_cells) C.go_out()

/obj/docking_port/mobile/escape_pod/proc/toggle_ready()
	switch(status)
		if(ESCAPE_STATE_IDLE)
			status = ESCAPE_STATE_READY
			can_launch = TRUE
			spawn()
				setTimer(5 MINUTES)
				open_all_doors()

		if(ESCAPE_STATE_READY)
			status = ESCAPE_STATE_IDLE
			MOVE_MOB_OUTSIDE
			can_launch = FALSE
			spawn(250)
				setTimer(0)
				close_all_doors()


/obj/docking_port/mobile/escape_pod/proc/prepare_for_launch()
	if(!can_launch())
		return FALSE
	status = ESCAPE_STATE_LAUNCHING
	spawn()
		close_all_doors()
	sleep(31)
	if(!check_for_survivors())
		status = ESCAPE_STATE_BROKEN
		explosion(evacuation_program.master, -1, -1, 3, 4, , , , create_cause_data("escape pod malfunction"))
		sleep(25)

		MOVE_MOB_OUTSIDE
		spawn()
			open_all_doors()
		evacuation_program.master.state(SPAN_WARNING("WARNING: Maximum weight limit reached, pod unable to launch. Warning: Thruster failure detected."))
		return FALSE
	send_to_infinite_transit()
	return TRUE

#undef MOVE_MOB_OUTSIDE

/obj/docking_port/mobile/escape_pod/proc/open_all_doors()
	for(var/obj/structure/machinery/door/airlock/evacuation/D in doors)
		INVOKE_ASYNC(D, /obj/structure/machinery/door/airlock/evacuation/.proc/force_open)

/obj/docking_port/mobile/escape_pod/proc/close_all_doors()
	for(var/obj/structure/machinery/door/airlock/evacuation/D in doors)
		INVOKE_ASYNC(D, /obj/structure/machinery/door/airlock/evacuation/.proc/force_close)

/// Port
/obj/docking_port/mobile/escape_pod/port
	preferred_direction = WEST
	port_direction = WEST

/// Starboard
/obj/docking_port/mobile/escape_pod/starboard
	preferred_direction = EAST
	port_direction = EAST

/// Aft
/obj/docking_port/mobile/escape_pod/aft
	preferred_direction = SOUTH
	port_direction = SOUTH

/// Stern
/obj/docking_port/mobile/escape_pod/stern
	preferred_direction = NORTH
	port_direction = NORTH

/obj/docking_port/mobile/escape_pod/proc/send_to_infinite_transit()
	status = ESCAPE_STATE_LAUNCHED
	destination = null
	on_ignition()
	setTimer(ignitionTime)



// === STATIONARIES

/// Generic lifeboat dock
/obj/docking_port/stationary/escape_pod_dock
	name   = "Escape pod docking port"
	width = 5
	height = 4

/obj/docking_port/stationary/escape_pod_dock/almayer/port
	dir = NORTH
	roundstart_template = /datum/map_template/shuttle/escape_pod_port

/obj/docking_port/stationary/escape_pod_dock/almayer/starboard
	dir = NORTH
	roundstart_template = /datum/map_template/shuttle/escape_pod_starboard

/obj/docking_port/stationary/escape_pod_dock/almayer/aft
	dir = NORTH
	roundstart_template = /datum/map_template/shuttle/escape_pod_aft

/obj/docking_port/stationary/escape_pod_dock/almayer/stern
	dir = NORTH
	roundstart_template = /datum/map_template/shuttle/escape_pod_stern

/obj/docking_port/stationary/escape_pod_dock/almayer/Initialize(mapload)
	. = ..()
	GLOB.escape_almayer_docks += src

/obj/docking_port/stationary/escape_pod_dock/almayer/Destroy(force)
	if(force)
		GLOB.escape_almayer_docks -= src
	. = ..()

/// Admin lifeboat dock temporary dest because someone mapped them in for some reason (use transit instead)
/obj/docking_port/stationary/escape_pod_dock/admin
	dir = NORTH
	id = "admin-lifeboat" // change this

// === SHUTTLE TEMPLATES FOR SPAWNING THEM

/// Port
/datum/map_template/shuttle/escape_pod_port
	name = "Port door escape pod"
	shuttle_id = "escape_pod_port"

/// Starboard
/datum/map_template/shuttle/escape_pod_starboard
	name = "Starboard door escape pod"
	shuttle_id = "escape_pod_starboard"

/// Aft
/datum/map_template/shuttle/escape_pod_aft
	name = "Aft door escape pod"
	shuttle_id = "escape_pod_aft"

/// Stern
/datum/map_template/shuttle/escape_pod_stern
	name = "Stern door escape pod"
	shuttle_id = "escape_pod_stern"



//=========================================================================================
//==================================Console Object=========================================
//=========================================================================================
/*
These were written by a crazy person, so that datums are constantly inserted for child objects,
the same datums that serve a similar purpose all-around. Incredibly stupid, but there you go.
As such, a new tracker datum must be constructed to follow proper child inheritance.
*/

//This controller goes on the escape pod itself.
/obj/structure/machinery/embedded_controller/radio/simple_docking_controller/escape_pod
	name = "escape pod controller"
	unslashable = TRUE
	unacidable = TRUE
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program //Runs the doors and states.
	//door_tag is the tag for the pod door.
	//id_tag is the generic connection tag.
	//TODO make sure you can't C4 this.

	ex_act(severity)
		return FALSE

	ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
		var/launch_status[] = evacuation_program.check_launch_status()
		var/data[] = list(
			"docking_status"	= evacuation_program.dock_state,
			"door_state"		= evacuation_program.memory["door_status"]["state"],
			"door_lock"			= evacuation_program.memory["door_status"]["lock"],
			"can_lock"			= evacuation_program.dock_state == (ESCAPE_STATE_READY || ESCAPE_STATE_DELAYED) ? 1:0,
			"can_force"			= evacuation_program.dock_state == (ESCAPE_STATE_READY || ESCAPE_STATE_DELAYED) ? 1:0,
			"can_delay"			= launch_status[2]
		)

		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

		if (!ui)
			ui = new(user, src, ui_key, "escape_pod_console.tmpl", id_tag, 470, 290)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(0)

	Topic(href, href_list)
		if(..())
			return TRUE	//Has to return true to fail. For some reason.

		var/obj/docking_port/mobile/escape_pod/P = SSshuttle.getShuttle("[id_tag]")
		switch(href_list["command"])
			if("force_launch")
				P.prepare_for_launch()
			if("delay_launch")
				evacuation_program.dock_state = evacuation_program.dock_state == ESCAPE_STATE_DELAYED ? ESCAPE_STATE_READY : ESCAPE_STATE_DELAYED
			if("lock_door")
				var/obj/structure/machinery/door/airlock/evacuation/D = pick(P.doors)
				if(D.density) //Closed
					spawn()
						P.open_all_doors()
				else //Open
					spawn()
						P.close_all_doors()

//=========================================================================================
//================================Controller Program=======================================
//=========================================================================================

//A docking controller program for a simple door based docking port
/datum/computer/file/embedded_program/docking/simple/escape_pod
	dock_state = ESCAPE_STATE_IDLE

/datum/computer/file/embedded_program/docking/simple/escape_pod/proc/check_launch_status()
	var/obj/docking_port/mobile/escape_pod/P = SSshuttle.getShuttle("[id_tag]")
	. = list(P.can_launch(), P.can_cancel())

//=========================================================================================
//================================Evacuation Sleeper=======================================
//=========================================================================================

/obj/structure/machinery/cryopod/evacuation
	stat = MACHINE_DO_NOT_PROCESS
	unslashable = TRUE
	unacidable = TRUE
	time_till_despawn = 6000000 //near infinite so despawn never occurs.
	var/being_forced = 0 //Simple variable to prevent sound spam.
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program

	ex_act(severity)
		return FALSE

	attackby(obj/item/grab/G, mob/user)
		if(istype(G))
			if(being_forced)
				to_chat(user, SPAN_WARNING("There's something forcing it open!"))
				return FALSE

			if(occupant)
				to_chat(user, SPAN_WARNING("There is someone in there already!"))
				return FALSE

			if(evacuation_program.dock_state < ESCAPE_STATE_READY)
				to_chat(user, SPAN_WARNING("The cryo pod is not responding to commands!"))
				return FALSE

			var/mob/living/carbon/human/M = G.grabbed_thing
			if(!istype(M))
				return FALSE

			visible_message(SPAN_WARNING("[user] starts putting [M.name] into the cryo pod."), null, null, 3)

			if(do_after(user, 20, INTERRUPT_ALL, BUSY_ICON_GENERIC))
				if(!M || !G || !G.grabbed_thing || !G.grabbed_thing.loc || G.grabbed_thing != M)
					return FALSE
				move_mob_inside(M)

	eject()
		set name = "Eject Pod"
		set category = "Object"
		set src in oview(1)

		if(!occupant || !usr.stat || usr.is_mob_restrained())
			return FALSE

		if(occupant) //Once you're in, you cannot exit, and outside forces cannot eject you.
			//The occupant is actually automatically ejected once the evac is canceled.
			if(occupant != usr) to_chat(usr, SPAN_WARNING("You are unable to eject the occupant unless the evacuation is canceled."))

		add_fingerprint(usr)

	go_out() //When the system ejects the occupant.
		if(occupant)
			occupant.forceMove(get_turf(src))
			occupant.in_stasis = FALSE
			occupant = null
			icon_state = orient_right ? "body_scanner_0-r" : "body_scanner_0"

	move_inside()
		set name = "Enter Pod"
		set category = "Object"
		set src in oview(1)

		var/mob/living/carbon/human/user = usr

		if(!istype(user) || user.stat || user.is_mob_restrained())
			return FALSE

		if(being_forced)
			to_chat(user, SPAN_WARNING("You can't enter when it's being forced open!"))
			return FALSE

		if(occupant)
			to_chat(user, SPAN_WARNING("The cryogenic pod is already in use! You will need to find another."))
			return FALSE

		if(evacuation_program.dock_state < ESCAPE_STATE_READY)
			to_chat(user, SPAN_WARNING("The cryo pod is not responding to commands!"))
			return FALSE

		visible_message(SPAN_WARNING("[user] starts climbing into the cryo pod."), null, null, 3)

		if(do_after(user, 20, INTERRUPT_NO_NEEDHAND, BUSY_ICON_GENERIC))
			user.stop_pulling()
			move_mob_inside(user)

	attack_alien(mob/living/carbon/Xenomorph/user)
		if(being_forced)
			to_chat(user, SPAN_XENOWARNING("It's being forced open already!"))
			return XENO_NO_DELAY_ACTION

		if(!occupant)
			to_chat(user, SPAN_XENOWARNING("There is nothing of interest in there."))
			return XENO_NO_DELAY_ACTION

		being_forced = !being_forced
		xeno_attack_delay(user)
		visible_message(SPAN_WARNING("[user] begins to pry \the [src]'s cover!"), null, null, 3)
		playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
		if(do_after(user, 20, INTERRUPT_ALL, BUSY_ICON_HOSTILE)) go_out() //Force the occupant out.
		being_forced = !being_forced
		return XENO_NO_DELAY_ACTION

/obj/structure/machinery/cryopod/evacuation/proc/move_mob_inside(mob/M)
	if(occupant)
		to_chat(M, SPAN_WARNING("The cryogenic pod is already in use. You will need to find another."))
		return FALSE
	M.forceMove(src)
	to_chat(M, SPAN_NOTICE("You feel cool air surround you as your mind goes blank and the pod locks."))
	occupant = M
	occupant.in_stasis = STASIS_IN_CRYO_CELL
	add_fingerprint(M)
	icon_state = orient_right ? "body_scanner_1-r" : "body_scanner_1"


/obj/structure/machinery/door/airlock/evacuation
	name = "Evacuation Airlock"
	icon = 'icons/obj/structures/doors/pod_doors.dmi'
	heat_proof = 1
	unslashable = TRUE
	unacidable = TRUE

/obj/structure/machinery/door/airlock/evacuation/Initialize()
	. = ..()
	INVOKE_ASYNC(src, .proc/lock)
	generate_name()

/obj/structure/machinery/door/airlock/evacuation/proc/generate_name()
	name = "[name]_[pick(alphabet_uppercase)][pick(alphabet_uppercase)][rand(1,9)]"

/obj/structure/machinery/door/airlock/evacuation/proc/force_open()
	if(!density)
		return
	unlock()
	open()
	lock()

/obj/structure/machinery/door/airlock/evacuation/proc/force_close()
	if(density)
		return
	unlock()
	close()
	lock()

	//Can't interact with them, mostly to prevent grief and meta.
/obj/structure/machinery/door/airlock/evacuation/Collided()
	return FALSE

/obj/structure/machinery/door/airlock/evacuation/attackby()
	return FALSE

/obj/structure/machinery/door/airlock/evacuation/attack_hand()
	return FALSE

/obj/structure/machinery/door/airlock/evacuation/attack_alien()
	return FALSE //Probably a better idea that these cannot be forced open.

/obj/structure/machinery/door/airlock/evacuation/attack_remote()
	return FALSE

/*
//Leaving this commented out for the CL pod, which should have a way to open from the outside.

//This controller is for the escape pod berth (station side)
/obj/structure/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth
	name = "escape pod berth controller"

/obj/structure/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth/Initialize()
	. = ..()
	docking_program = new/datum/computer/file/embedded_program/docking/simple/escape_pod(src)
	program = docking_program

/obj/structure/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/armed = null
	if (istype(docking_program, /datum/computer/file/embedded_program/docking/simple/escape_pod))
		var/datum/computer/file/embedded_program/docking/simple/escape_pod/P = docking_program
		armed = P.armed

	var/data[] = list(
		"docking_status" = docking_program.get_docking_status(),
		"override_enabled" = docking_program.override_enabled,
		"armed" = armed,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "escape_pod_berth_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
*/