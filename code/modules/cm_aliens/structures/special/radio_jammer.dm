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
	// the amount of plasma that is used per blocked radio signal (outbound only)
	var/plasma_usage = 5
	// this is to prevent multiple xenos from filling it up at the same time... or the same xeno
	in_use = FALSE

/obj/effect/alien/resin/special/jammer/Initialize(mapload, hive_ref)
	. = ..()
	// we need to register a signal to jam radios
	RegisterSignal(SSdcs, COMSIG_GLOB_SAY_RADIO, .proc/try_jamming)

/obj/effect/alien/resin/special/jammer/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoBuilder(M) && M.a_intent == INTENT_HELP && M.hivenumber == linked_hive.hivenumber)
		try_refill(M)
		return
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
	// so that multiple xenos cannot use it at the same time
	if(in_use)
		to_chat(M, SPAN_XENONOTICE("\The [src] is already in use, try again later."))
		return
	in_use = TRUE
	to_chat(M, SPAN_XENONOTICE("You begin to fill \the [src] with plasma."))
	// this will attempt to fill up all the way, but will stop at certain conditions
	for(var/iteration in 1 to 20)
		// if we are full, lets stop
		if(plasma_stored >= plasma_max)
			in_use = FALSE
			return
		// if the refilling xeno does not have enough plasma, lets stop
		if(M.plasma_stored < plasma_usage)
			in_use = FALSE
			return
		// if the refilling xeno cannot wait 2 seconds, lets stop
		if(!do_after(M, 2 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC))
			in_use = FALSE
			return
		visible_message(SPAN_XENONOTICE("\The [src] jiggles as it is filled with plasma..."))
		// now remove the plasma from the refilling xeno and add it to the structure
		M.plasma_stored -= plasma_usage
		plasma_stored += plasma_usage
		in_use = FALSE

// when we are attempting to jam a radio signal
/obj/effect/alien/resin/special/jammer/proc/try_jamming(datum/source, mob/M)
	// we need at least a certain amount of plasma to function
	if(plasma_stored < plasma_usage)
		return
	// need to be within 8 tiles distance to be blocked
	if(get_dist(M, src) >= 9)
		return
	// time to take the cost and block a signal
	plasma_stored -= plasma_usage
	return COMSIG_GLOB_SAY_RADIO_BLOCK
