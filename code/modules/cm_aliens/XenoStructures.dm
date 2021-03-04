/*
 * effect/alien
 */
/obj/effect/alien
	name = "alien thing"
	desc = "theres something alien about this"
	unacidable = TRUE
	health = 1
	flags_obj = OBJ_ORGANIC

/obj/effect/alien/Initialize(mapload, ...)
	. = ..()
	icon = get_icon_from_source(CONFIG_GET(string/alien_effects))

/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"
	anchored = 1
	health = 200
	unacidable = TRUE

/obj/effect/alien/resin/proc/healthcheck()
	if(health <= 0)
		density = 0
		qdel(src)

/obj/effect/alien/resin/flamer_fire_act()
	health -= 50
	healthcheck()

/obj/effect/alien/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return 1

/obj/effect/alien/resin/ex_act(severity)
	health -= (severity * RESIN_EXPLOSIVE_MULTIPLIER)
	healthcheck()
	return

/obj/effect/alien/resin/hitby(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/Xenomorph))
		return
	visible_message(SPAN_DANGER("\The [src] was hit by \the [AM]."), \
	SPAN_DANGER("You hit \the [src]."))
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	if(istype(src, /obj/effect/alien/resin/sticky))
		playsound(loc, "alien_resin_move", 25)
	else
		playsound(loc, "alien_resin_break", 25)
	health = max(0, health - tforce)
	healthcheck()

/obj/effect/alien/resin/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) //Larvae can't do shit
		return 0
	if(M.a_intent == INTENT_HELP)
		M.visible_message(SPAN_WARNING("\The [M] creepily taps on [src] with its huge claw."), \
			SPAN_WARNING("You creepily tap on [src]."), null, 5)
	else
		M.visible_message(SPAN_XENONOTICE("\The [M] claws \the [src]!"), \
		SPAN_XENONOTICE("You claw \the [src]."))
		if(istype(src, /obj/effect/alien/resin/sticky))
			playsound(loc, "alien_resin_move", 25)
		else
			playsound(loc, "alien_resin_break", 25)

		health -= (M.melee_damage_upper + 50) //Beef up the damage a bit
		healthcheck()

/obj/effect/alien/resin/attack_animal(mob/living/M as mob)
	M.visible_message(SPAN_DANGER("[M] tears \the [src]!"), \
	SPAN_DANGER("You tear \the [name]."))
	if(istype(src, /obj/effect/alien/resin/sticky))
		playsound(loc, "alien_resin_move", 25)
	else
		playsound(loc, "alien_resin_break", 25)
	health -= 40
	healthcheck()

/obj/effect/alien/resin/attack_hand()
	to_chat(usr, SPAN_WARNING("You scrape ineffectively at \the [src]."))

/obj/effect/alien/resin/attackby(obj/item/W, mob/user)
	if(!(W.flags_item & NOBLUDGEON))
		var/damage = W.force * RESIN_MELEE_DAMAGE_MULTIPLIER
		health -= damage
		if(istype(src, /obj/effect/alien/resin/sticky))
			playsound(loc, "alien_resin_move", 25)
		else
			playsound(loc, "alien_resin_break", 25)
		healthcheck()
	return ..()

/obj/effect/alien/resin/sticky
	name = "sticky resin"
	desc = "A layer of disgusting sticky slime."
	icon_state = "sticky"
	density = 0
	opacity = 0
	health = HEALTH_RESIN_XENO_STICKY
	layer = RESIN_STRUCTURE_LAYER
	var/slow_amt = 8
	var/hivenumber = XENO_HIVE_NORMAL

/obj/effect/alien/resin/sticky/Initialize(mapload, hive)
	..()
	if (hive)
		hivenumber = hive
	set_hive_data(src, hivenumber)

/obj/effect/alien/resin/sticky/Crossed(atom/movable/AM)
	. = ..()
	var/mob/living/carbon/human/H = AM
	if(istype(H) && !H.lying && !H.ally_of_hivenumber(hivenumber))
		H.next_move_slowdown = H.next_move_slowdown + slow_amt
		return .
	var/mob/living/carbon/Xenomorph/X = AM
	if(istype(X) && !X.ally_of_hivenumber(hivenumber))
		X.next_move_slowdown = X.next_move_slowdown + (slow_amt * WEED_XENO_SPEED_MULT)
		return .

// Praetorian Sticky Resin spit uses this.
/obj/effect/alien/resin/sticky/thin
	name = "thin sticky resin"
	desc = "A thin layer of disgusting sticky slime."
	health = 7
	slow_amt = 4

// Gardener drone uses this.
/obj/effect/alien/resin/sticky/thin/weak
	name = "Weak sticky resin"
	desc = "A thin and weak layer of disgusting sticky slime. It looks like it's already melting..."
	var/duration = 20 SECONDS

/obj/effect/alien/resin/sticky/thin/weak/Initialize(...)
	. = ..()
	QDEL_IN(src, duration)

/obj/effect/alien/resin/sticky/fast
	name = "fast resin"
	desc = "A layer of disgusting sleek slime."
	icon_state = "fast"
	health = HEALTH_RESIN_XENO_FAST
	var/speed_amt = 0.7

	Crossed(atom/movable/AM)
		return


//Resin Doors
/obj/structure/mineral_door/resin
	name = "resin door"
	mineralType = "resin"
	hardness = 1.5
	health = HEALTH_DOOR_XENO
	var/close_delay = 100
	var/hivenumber = XENO_HIVE_NORMAL

	flags_obj = OBJ_ORGANIC

	tiles_with = list(/obj/structure/mineral_door/resin)

/obj/structure/mineral_door/resin/Initialize(mapload, hive)
	. = ..()
	icon = get_icon_from_source(CONFIG_GET(string/alien_effects))
	relativewall()
	relativewall_neighbours()
	for(var/turf/closed/wall/W in orange(1))
		W.update_connections()
		W.update_icon()

	if (hive)
		hivenumber = hive

	set_hive_data(src, hivenumber)

/obj/structure/mineral_door/resin/flamer_fire_act(var/dam = BURN_LEVEL_TIER_1)
	health -= dam
	healthcheck()

/obj/structure/mineral_door/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return 1

/obj/structure/mineral_door/resin/attackby(obj/item/W, mob/living/user)
	if(W.pry_capable == IS_PRY_CAPABLE_FORCE && user.a_intent != INTENT_HARM)
		return // defer to item afterattack
	if(!(W.flags_item & NOBLUDGEON) && W.force)
		user.animation_attack_on(src)
		health -= W.force*RESIN_MELEE_DAMAGE_MULTIPLIER
		to_chat(user, "You hit the [name] with your [W.name]!")
		playsound(loc, "alien_resin_move", 25)
		healthcheck()
	else
		return attack_hand(user)

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isXenoLarva(user))
		var/mob/living/carbon/Xenomorph/Larva/L = user
		if (L.hivenumber == hivenumber)
			L.scuttle(src)
		return
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if (C.ally_of_hivenumber(hivenumber))
			return ..()

/obj/structure/mineral_door/resin/Open()
	if(state || !loc) return //already open
	isSwitchingStates = 1
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]opening",src)
	sleep(3)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

	spawn(close_delay)
		if(!isSwitchingStates && state == 1)
			Close()

/obj/structure/mineral_door/resin/Close()
	if(!state || !loc) return //already closed
	//Can't close if someone is blocking it
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			spawn (close_delay)
				Close()
			return
	isSwitchingStates = 1
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]closing",src)
	sleep(3)
	density = 1
	opacity = 1
	state = 0
	update_icon()
	isSwitchingStates = 0
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			Open()
			return

/obj/structure/mineral_door/resin/Dismantle(devastated = 0)
	qdel(src)

/obj/structure/mineral_door/resin/CheckHardness()
	playsound(loc, "alien_resin_move", 25)
	..()

/obj/structure/mineral_door/resin/Destroy()
	relativewall_neighbours()
	var/turf/U = loc
	spawn(0)
		var/turf/T
		for(var/i in cardinal)
			T = get_step(U, i)
			if(!istype(T)) continue
			for(var/obj/structure/mineral_door/resin/R in T)
				R.check_resin_support()
	. = ..()

/obj/structure/mineral_door/resin/proc/healthcheck()
	if(src.health <= 0)
		src.Dismantle(1)

/obj/structure/mineral_door/resin/ex_act(severity)

	if(!density)
		severity *= EXPLOSION_DAMAGE_MODIFIER_DOOR_OPEN

	health -= (severity * RESIN_EXPLOSIVE_MULTIPLIER * EXPLOSION_DAMAGE_MULTIPLIER_DOOR)
	healthcheck()

	if(src)
		check_resin_support()
	return


/obj/structure/mineral_door/resin/get_explosion_resistance()
	if(density)
		return health //this should exactly match the amount of damage needed to destroy the door
	else
		return 0

//do we still have something next to us to support us?
/obj/structure/mineral_door/resin/proc/check_resin_support()
	var/turf/T
	for(var/i in cardinal)
		T = get_step(src, i)
		if(!T)
			continue
		if(T.density)
			. = 1
			break
		if(locate(/obj/structure/mineral_door/resin) in T)
			. = 1
			break
	if(!.)
		visible_message(SPAN_NOTICE("[src] collapses from the lack of support."))
		qdel(src)

/obj/structure/mineral_door/resin/thick
	name = "thick resin door"
	health = HEALTH_RESIN_PILLAR
	hardness = 2.0

/obj/structure/resin_pillar
	name = "resin pillar"
	desc = "This massive structure arose out of some weeds coating the ground, somehow... It seems to be doing nothing but blocking the way."
	health = HEALTH_RESIN_PILLAR
	density = TRUE
	icon = 'icons/mob/hostiles/structures64x64.dmi'
	icon_state = "resin_pillar"
	var/width = 2
	var/height = 2
	indestructible = TRUE //initially indestructible
	var/breaktime
	var/brittle
	var/time_to_brittle = 45 SECONDS
	var/time_to_collapse = 45 SECONDS

/obj/structure/resin_pillar/Initialize(mapload, ...)
	. = ..()
	//playsound(granite shuffling)
	bound_width = width * world.icon_size
	bound_height = height * world.icon_size
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, FALSE)
	if(mapload) //this should never be called in mapload, but in case it is
		name = "calcified resin pillar"
		desc = "This massive structure seems to be inert."

/obj/structure/resin_pillar/process()
	if(brittle && prob(25))
		playsound(loc, "alien_resin_break", 25, TRUE)

/obj/structure/resin_pillar/proc/start_decay(brittle_time_override, collapse_time_override)
	if(brittle_time_override && collapse_time_override)
		addtimer(CALLBACK(src, .proc/brittle, collapse_time_override), brittle_time_override SECONDS)
	else
		addtimer(CALLBACK(src, .proc/brittle, time_to_collapse), time_to_brittle SECONDS)


/obj/structure/resin_pillar/proc/brittle(collapse_time_override)
	//playsound(granite cracking)
	visible_message(SPAN_DANGER("You hear cracking sounds from the [src] as splinters start falling off from the structure! It seems brittle now."))
	indestructible = FALSE
	brittle = TRUE
	icon_state = "resin_pillar_decay"
	playsound(loc, "alien_resin_break", 25, TRUE)
	START_PROCESSING(SSobj, src)
	if(collapse_time_override)
		addtimer(CALLBACK(src, .proc/collapse, TRUE), collapse_time_override SECONDS)
	else
		addtimer(CALLBACK(src, .proc/collapse, TRUE), time_to_collapse SECONDS)

/obj/structure/resin_pillar/proc/collapse(var/decayed = FALSE)
	//playsound granite collapsing
	if(decayed)
		visible_message(SPAN_DANGER("[src]'s failing structure suddenly collapses!"))
	else
		visible_message(SPAN_DANGER("[src]'s structure collapses under the blow!"))

	playsound(loc, "alien_resin_break", 25, TRUE)
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/structure/resin_pillar/proc/pillar_health_check()
	if(health <= 0)
		collapse(FALSE)

//bullet_act() by default only pings, so it's not overridden here. it should not damage, only ping even post-brittle

/obj/structure/resin_pillar/hitby(atom/movable/AM)
	if(indestructible)
		visible_message(SPAN_DANGER("[AM] harmlessly bounces off the [src]!"))
	else ..()


/obj/structure/resin_pillar/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	if(indestructible)
		M.visible_message(SPAN_XENONOTICE("\The [M] claws \the [src], but the slash bounces off!"), \
		SPAN_XENONOTICE("You claw \the [src], but the slash bounces off!"))
	else
		M.visible_message(SPAN_XENONOTICE("\The [M] claws \the [src]!"), \
		SPAN_XENONOTICE("You claw \the [src]."))
		playsound(loc, "alien_resin_break", 25)
		health -= (M.melee_damage_upper + 50)
		pillar_health_check()

/obj/structure/resin_pillar/attackby(obj/item/W, mob/living/user)
	user.animation_attack_on(src)
	if(indestructible)
		user.visible_message(SPAN_DANGER("[user] hits \the [src], but \the [W] bounces off!"), \
	SPAN_DANGER("You hit \the [name], but \the [W] bounces off!"))
	else
		if(!(W.flags_item & NOBLUDGEON) && W.force)
			health -= W.force*RESIN_MELEE_DAMAGE_MULTIPLIER
			to_chat(user, "You hit the [name] with your [W.name]!")
			playsound(loc, "alien_resin_move", 25)
			
		else
			return attack_hand(user)
	pillar_health_check()