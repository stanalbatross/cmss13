/obj/item/satchel_charge_detonator
	name = "M17 Satchel Charge Detonator"
	desc = "The Detonator for M420 Satchel Charges, it detonates all linked satchel charges when triggered. Quite a good design too."
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "detonator"

	var/list/linked_charges = list()

/obj/item/satchel_charge_detonator/attack_self(mob/user, parameters)
	. = ..()
	flick("detonator_pressed", src)
	var/detonation_count = 0
	for(var/obj/item/explosive/satchel_charge/SC in linked_charges)
		if(SC.z != src.loc.z)
			message_admins("")
		SC.detonate(src)
		detonation_count++
	to_chat(user, SPAN_NOTICE("[detonation_count] charges detonated."))

/obj/item/satchel_charge_detonator/clicked(mob/user, list/mods)
	if (isobserver(user) || isXeno(user)) return

	if (mods["alt"])
		to_chat(SPAN_NOTICE("You ping the detonator's [length(linked_charges)] linked charges."))
		for(var/obj/item/explosive/satchel_charge/SC in linked_charges)
			flick("satchel_primed", SC)
			SC.beep(TRUE)
		return 1

/obj/item/explosive/satchel_charge
	name = "M17 Satchel Charge"
	desc = "boomer"
	//desc = "After linked to a detonator, and thrown, will become primed and able to be detonated."
	gender = PLURAL
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "satchel"
	flags_item = NOBLUDGEON
	w_class = SIZE_SMALL
	max_container_volume = 180
	reaction_limits = list(	"max_ex_power" = 260,	"base_ex_falloff" = 90,	"max_ex_shards" = 64,
							"max_fire_rad" = 6,		"max_fire_int" = 26,	"max_fire_dur" = 30,
							"min_fire_rad" = 2,		"min_fire_int" = 4,		"min_fire_dur" = 5
	)

	var/prime_time_usa = 3 SECONDS
	var/prime_timer_usa = null
	var/linked_detonator = null
	var/activated = FALSE
	var/armed = FALSE

/obj/item/explosive/satchel_charge/attack_self(mob/user)
	. = ..()
	if(!linked_detonator)
		to_chat(user, SPAN_NOTICE("This Charge is not linked to any detonator"))
		return
	icon_state = "satchel_triggered"
	playsound(src.loc, 'sound/machines/click.ogg', 25, 1)
	var/mob/living/carbon/C = user
	if(istype(C) && !C.throw_mode)
		C.toggle_throw_mode(THROW_MODE_NORMAL)
	to_chat(user, SPAN_NOTICE("You activate the M17 Satchel Charge, it will now arm itself after a short time once thrown."))
	activated = TRUE
	addtimer(CALLBACK(src, .proc/un_activate), 10 SECONDS, TIMER_UNIQUE)

/obj/item/explosive/satchel_charge/attackby(obj/item/W, mob/user)
	. = ..()
	beep(TRUE)
	if(armed)
		to_chat(user, SPAN_WARNING("This charge is armed, its linking cannot be altered unless disarmed."))
		return
	if(!istype(W, /obj/item/satchel_charge_detonator))
		return
	var/obj/item/satchel_charge_detonator/D = W
	if(linked_detonator == D)
		D.linked_charges -= src
		linked_detonator == null
		to_chat(user, SPAN_NOTICE("You unlink the charge from the detonator."))
		icon_state = "satchel"
	else
		D.linked_charges |= src
		linked_detonator = D
		to_chat(user, SPAN_NOTICE("The detonator indicates a new charge has been linked."))
		icon_state = "satchel_linked"

/obj/item/explosive/satchel_charge/proc/un_activate()
	if(activated)
		activated = FALSE
		if(linked_detonator)
			icon_state = "satchel_linked"
		else
			icon_state = "satchel"

/obj/item/explosive/satchel_charge/throw_atom(atom/target, range, speed, atom/thrower, spin, launch_type, pass_flags)
	. = ..()
	dir = get_dir(src, thrower)
	if(activated && linked_detonator)
		icon_state = "satchel_primed"
		prime_timer_usa = addtimer(CALLBACK(src, .proc/arm), prime_time_usa, TIMER_UNIQUE)
		beep()

/obj/item/explosive/satchel_charge/proc/beep(var/beep_once)
	playsound(src.loc, 'sound/effects/beepo.ogg', 10, 1)
	if(!armed && beep_once != TRUE)
		addtimer(CALLBACK(src, .proc/beep), 1 SECONDS, TIMER_UNIQUE)


/obj/item/explosive/satchel_charge/proc/arm()
	activated = FALSE
	if(!linked_detonator || armed)
		return
	icon_state = "satchel_armed"
	armed = TRUE

/obj/item/explosive/satchel_charge/pickup(mob/user)
	if(armed || prime_timer_usa)
		if(prime_timer_usa)
			//stop the timer somehow -_-
		do_after(user, prime_time_usa, INTERRUPT_MOVED, TRUE)
		if(linked_detonator)
			icon_state = "satchel_linked"
		else
			icon_state = "satchel"
		armed = FALSE
		. = ..()
	else
		. = ..()

/obj/item/explosive/satchel_charge/proc/detonate(triggerer)
	if(!armed || linked_detonator != triggerer)
		return
	linked_detonator.linked_charges -= src
	message_admins("BOOM!")
	qdel(src)




