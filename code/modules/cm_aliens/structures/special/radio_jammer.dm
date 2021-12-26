#define DEFAULT_JAMMER_PROCESS 3 SECONDS

/obj/effect/alien/resin/special/jammer
	name = XENO_STRUCTURE_JAMMER
	desc = "An ominous pile of resin that eminates faint purple light."
	icon_state = "jammer"
	health = 400
	luminosity = 2

	// the amount of plasma that is stored within the jammer
	var/plasma_stored = 0
	// the maximum amount of plasma that is able to be stored within the jammer
	var/plasma_max = 100
	// the amount of plasma that is used per six seconds
	var/plasma_usage = 1
	// this is to prevent multiple xenos from filling it up at the same time... or the same xeno
	in_use = FALSE
	// this is what tells how many seconds between each process
	var/processing_cooldown = DEFAULT_JAMMER_PROCESS
	// this is the time to check between each processing_cooldown
	var/processing_timer = 0

/obj/effect/alien/resin/special/jammer/Initialize(mapload, hive_ref)
	. = ..()
	// we need to register a signal to jam radios
	RegisterSignal(SSdcs, COMSIG_GLOB_SAY_RADIO, .proc/try_jamming)
	START_PROCESSING(SSobj, src)

/obj/effect/alien/resin/special/jammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_SAY_RADIO)
	return ..()

/obj/effect/alien/resin/special/jammer/examine(mob/user)
	. = ..()
	if(isXeno(user))
		. += "[plasma_stored]/100 plasma stored."

/obj/effect/alien/resin/special/jammer/process()
	// check to make sure its every six seconds, then run
	if(world.time <= processing_timer)
		return
	processing_timer = world.time + processing_cooldown
	// make sure we can take out the plasma
	if(plasma_stored <= 0)
		return
	// if we are refilling, don't use it
	if(in_use)
		return
	// take out the plasma
	plasma_stored -= plasma_usage

/obj/effect/alien/resin/special/jammer/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoBuilder(M) && M.a_intent == INTENT_HELP && M.hivenumber == linked_hive.hivenumber)
		try_refill(M)
		return XENO_NO_DELAY_ACTION
	else
		return ..()

// when we are attempting to refill the jammer
/obj/effect/alien/resin/special/jammer/proc/try_refill(mob/living/carbon/Xenomorph/M)
	// have to make sure it is a xeno using this
	if(!istype(M))
		return
	// we do not want to go above the max amount of plasma
	if(plasma_stored >= plasma_max)
		to_chat(M, SPAN_XENONOTICE("\The [src] is already full of plasma, and does not require any more."))
		return
	if(plasma_stored + (plasma_usage * 2) > plasma_max)
		to_chat(M, SPAN_XENONOTICE("\The [src] would be too full of plasma, try again later."))
		return
	// so that multiple xenos cannot use it at the same time
	if(in_use)
		to_chat(M, SPAN_XENONOTICE("\The [src] is already in use, try again later."))
		return
	in_use = TRUE
	to_chat(M, SPAN_XENONOTICE("You begin to fill \the [src] with plasma."))
	// this will attempt to fill up all the way, but will stop at certain conditions
	for(var/iteration in 1 to 10)
		// if we are full, lets stop
		if(plasma_stored >= plasma_max)
			in_use = FALSE
			return
		// if we become fuller than max, lets stop
		if(plasma_stored + (plasma_usage * 10) > plasma_max)
			in_use = FALSE
			return
		// if the refilling xeno does not have enough plasma, lets stop
		if(M.plasma_stored < (plasma_usage * 10))
			in_use = FALSE
			return
		// if the refilling xeno cannot wait 2 seconds, lets stop
		if(!do_after(M, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC))
			in_use = FALSE
			return
		visible_message(SPAN_XENONOTICE("\The [src] shivers as it is filled with plasma..."))
		// now remove the plasma from the refilling xeno and add it to the structure
		M.plasma_stored -= (plasma_usage * 10)
		plasma_stored += (plasma_usage * 10)
	in_use = FALSE

// when we are attempting to jam a radio signal
/obj/effect/alien/resin/special/jammer/proc/try_jamming(datum/source, mob/M)
	// we need at least a certain amount of plasma to function
	if(plasma_stored < plasma_usage)
		return
	// need to be within 8 tiles distance to be blocked
	if(get_dist(M, src) >= 9)
		return
	// time to block the signal
	return COMSIG_GLOB_SAY_RADIO_BLOCK
