#define WEED_BASE_GROW_SPEED (10 SECONDS)
#define WEED_BASE_DECAY_SPEED (20 SECONDS)

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird black weeds..."
	icon_state = "base"

	anchored = 1
	density = 0
	layer = WEED_LAYER
	unacidable = TRUE
	health = WEED_HEALTH_STANDARD
	var/weed_strength = WEED_LEVEL_STANDARD
	var/node_range = WEED_RANGE_STANDARD
	var/secreting = FALSE

	var/hibernate = FALSE

	var/datum/hive_status/linked_hive = null
	var/hivenumber = XENO_HIVE_NORMAL

	// Which node is responsible for keeping this weed patch alive?
	var/obj/effect/alien/weeds/node/parent = null

/obj/effect/alien/weeds/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	icon = get_icon_from_source(CONFIG_GET(string/alien_weeds))
	if(node)
		linked_hive = node.linked_hive
		weed_strength = node.weed_strength
		node_range = node.node_range
		if(weed_strength >= WEED_LEVEL_HIVE)
			name = "hive [name]"
			health = WEED_HEALTH_HIVE
		node.add_child(src)
		hivenumber = linked_hive.hivenumber
	else
		linked_hive = GLOB.hive_datum[hivenumber]

	set_hive_data(src, hivenumber)

	update_icon()
	update_neighbours()
	if(node && node.loc && (get_dist(node, src) < node.node_range) && !hibernate)
		addtimer(CALLBACK(src, .proc/weed_expand), WEED_BASE_GROW_SPEED / max(weed_strength, 1))

/obj/effect/alien/weeds/initialize_pass_flags(var/datum/pass_flags_container/PF)
	. = ..()
	if (PF)
		PF.flags_pass = PASS_FLAGS_WEEDS

/obj/effect/alien/weeds/proc/on_weed_expand(var/obj/effect/alien/weeds/spread_from, var/list/new_weeds)
	return

/obj/effect/alien/weeds/weak
	name = "weak weeds"
	alpha = 127

/obj/effect/alien/weeds/weak/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	name = initial(name)
	weed_strength = WEED_LEVEL_WEAK

	update_icon()

/obj/effect/alien/weeds/node/weak
	name = "weak purple sac"
	health = WEED_HEALTH_STANDARD
	alpha = 127

/obj/effect/alien/weeds/node/weak/Initialize(mapload, obj/effect/alien/weeds/node/node, var/mob/living/carbon/Xenomorph/X, var/datum/hive_status/hive)
	. = ..()
	name = initial(name)
	weed_strength = WEED_LEVEL_WEAK

	update_icon()

/obj/effect/alien/weeds/node/weak/on_weed_expand(var/obj/effect/alien/weeds/spread_from, var/list/new_weeds)
	var/atom/to_copy = /obj/effect/alien/weeds/weak
	for(var/i in new_weeds)
		var/obj/effect/alien/weeds/W = i
		W.name = initial(to_copy.name)
		W.alpha = initial(to_copy.alpha)


/obj/effect/alien/weeds/Destroy()
	if(parent)
		if(istype(parent, /obj/effect/alien/weeds/node/pylon))
			var/obj/effect/alien/weeds/node/pylon/P = parent
			P.parent_pylon.damaged = TRUE
		parent.remove_child(src)

	var/oldloc = loc
	parent = null
	. = ..()
	update_neighbours(oldloc)

/obj/effect/alien/weeds/examine(mob/user)
	..()
	var/turf/T = get_turf(src)
	if(istype(T, /turf/open))
		T.ceiling_desc(user)


/obj/effect/alien/weeds/Crossed(atom/movable/AM)
	if (ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(!slowdown_immune(H))
			H.next_move_slowdown = H.next_move_slowdown + weed_strength
	else if (isXeno(AM))
		var/mob/living/carbon/Xenomorph/X = AM
		if (!linked_hive.is_ally(X))
			X.next_move_slowdown = X.next_move_slowdown + (weed_strength*WEED_XENO_SPEED_MULT)

/obj/effect/alien/weeds/proc/slowdown_immune(var/mob/living/carbon/human/H)
	if(H.ally_of_hivenumber(linked_hive.hivenumber) || H.shoes.flags_inventory & NOWEEDSLOW) //if wearing shoes like pred shoes, immune to weed slowdown effect
		return TRUE
	else
		return FALSE

// Uh oh, we might be dying!
// I know this is bad proc naming but it was too good to pass on and it's only used in this file anyways
// If you're still confused, scroll aaaall the way down to the bottom of the file.
// that's /obj/effect/alien/weeds/node/Destroy().
/obj/effect/alien/weeds/proc/avoid_orphanage()
	for(var/obj/effect/alien/weeds/node/N in orange(node_range, get_turf(src)))
		// WE FOUND A NEW MOMMY
		N.add_child(src)
		break

	// NO MORE FOOD ON THE TABLE. WE DIE
	if(!parent || weed_strength > WEED_LEVEL_STANDARD)
		qdel(src)

/obj/effect/alien/weeds/proc/weed_expand()
	if(!parent)
		return

	var/obj/effect/alien/weeds/node/node = parent
	var/turf/U = get_turf(src)

	if(!istype(U))
		return

	var/list/weeds = list()
	for(var/dirn in cardinal)
		var/turf/T = get_step(src, dirn)
		if(!istype(T) || !T.is_weedable())
			continue

		var/obj/effect/alien/weeds/W = locate() in T
		if(W)
			if(W.weed_strength >= WEED_LEVEL_HIVE)
				continue
			else if (W.linked_hive == node.linked_hive && W.weed_strength >= node.weed_strength)
				continue
			qdel(W)

		if(istype(T, /turf/closed/wall/resin))
			continue

		if(istype(T, /turf/closed/wall) && T.density)
			weeds.Add(new /obj/effect/alien/weeds/weedwall(T, node))
			continue

		if(!weed_expand_objects(T, dirn))
			continue

		weeds.Add(new /obj/effect/alien/weeds(T, node))


	on_weed_expand(src, weeds)
	if(parent)
		parent.on_weed_expand(src, weeds)

	return weeds

/obj/effect/alien/weeds/proc/weed_expand_objects(var/turf/T, var/direction)
	for(var/obj/structure/platform/P in src.loc)
		if(P.dir == reverse_direction(direction))
			return FALSE

	for(var/obj/O in T)
		if(istype(O, /obj/structure/platform))
			if(O.dir == direction)
				return FALSE

		if(istype(O, /obj/structure/window/framed))
			new /obj/effect/alien/weeds/weedwall/window(T, parent)
			return FALSE
		else if(istype(O, /obj/structure/window_frame))
			new /obj/effect/alien/weeds/weedwall/frame(T, parent)
			return FALSE
		else if(istype(O, /obj/structure/machinery/door) && O.density && (!(O.flags_atom & ON_BORDER) || O.dir != direction))
			return FALSE

	return TRUE

/obj/effect/alien/weeds/proc/update_neighbours(turf/U)
	if(!U)
		U = loc
	if(istype(U))
		for(var/dirn in cardinal)
			var/turf/T = get_step(U, dirn)

			if(!istype(T))
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if(W)
				W.update_icon()

/obj/effect/alien/weeds/update_icon()
	overlays.Cut()

	var/my_dir = 0
	for(var/check_dir in cardinal)
		var/turf/check = get_step(src, check_dir)

		if(!istype(check))
			continue
		if(istype(check, /turf/closed/wall/resin))
			my_dir |= check_dir

		else if (locate(/obj/effect/alien/weeds) in check)
			my_dir |= check_dir

	// big brain the icon dir by letting -15 represent the base icon,
	// 0-15 be for omnidirectional and -1 to -14 be the rest

	var/icon_dir = -15
	if(my_dir == 15) //weeds in all four directions
		icon_dir = rand(0,15)
		icon_state = "weed[icon_dir]"
		if(weed_strength >= WEED_LEVEL_HIVE)
			icon_state = "hive_[icon_state]"
	else if(my_dir == 0) //no weeds in any direction
		icon_state = "base"
	else
		icon_dir = -my_dir
		icon_state = "weed_dir[my_dir]"

	if(secreting)
		var/image/secretion

		if(icon_dir >= 0)
			secretion = image(get_icon_from_source(CONFIG_GET(string/alien_effects)), "secrete[icon_dir]")
		else if(icon_dir == -15)
			secretion = image(get_icon_from_source(CONFIG_GET(string/alien_effects)), "secrete_base")
		else
			secretion = image(get_icon_from_source(CONFIG_GET(string/alien_effects)), "secrete_dir[-icon_dir]")

		overlays += secretion

/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(0 to EXPLOSION_THRESHOLD_LOW)
			if(prob(50))
				qdel(src)
		if(EXPLOSION_THRESHOLD_LOW to EXPLOSION_THRESHOLD_MEDIUM)
			if(prob(70))
				qdel(src)
		if(EXPLOSION_THRESHOLD_MEDIUM to INFINITY)
			qdel(src)

/obj/effect/alien/weeds/attack_alien(mob/living/carbon/Xenomorph/X)
	if(!HIVE_ALLIED_TO_HIVE(X.hivenumber, hivenumber))
		X.animation_attack_on(src)

		X.visible_message(SPAN_DANGER("\The [X] slashes [src]!"), \
		SPAN_DANGER("You slash [src]!"), null, 5)
		playsound(loc, "alien_resin_break", 25)
		health -= X.melee_damage_lower*WEED_XENO_DAMAGEMULT
		healthcheck()



/obj/effect/alien/weeds/attackby(obj/item/W, mob/living/user)
	if(QDELETED(W) || QDELETED(user) || (W.flags_item & NOBLUDGEON))
		return 0

	if(istype(src, /obj/effect/alien/weeds/node)) //The pain is real
		to_chat(user, SPAN_WARNING("You hit \the [src] with \the [W]."))
	else
		to_chat(user, SPAN_WARNING("You cut \the [src] away with \the [W]."))

	var/damage = W.force / 3
	playsound(loc, "alien_resin_break", 25)

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(2))
			damage = WEED_HEALTH_STANDARD
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)
	else
		playsound(loc, "alien_resin_break", 25)


	user.animation_attack_on(src)

	health -= damage
	healthcheck()
	return TRUE //don't call afterattack

/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/effect/alien/weeds/flamer_fire_act(dam)
	. = ..()
	if(!QDELETED(src))
		QDEL_IN(src, rand(SECONDS_1, SECONDS_2)) // 1-2 seconds

/obj/effect/alien/weeds/acid_spray_act()
	. = ..()
	health -= 20 * WEED_XENO_DAMAGEMULT
	healthcheck()

/obj/effect/alien/weeds/weedwall
	layer = RESIN_STRUCTURE_LAYER
	icon_state = "weedwall"
	var/list/wall_connections = list("0", "0", "0", "0")
	hibernate = TRUE

/obj/effect/alien/weeds/weedwall/update_icon()
	if(istype(loc, /turf/closed/wall))
		var/turf/closed/wall/W = loc
		wall_connections = W.wall_connections
		icon_state = ""
		var/image/I
		for(var/i = 1 to 4)
			I = image(icon, "weedwall[wall_connections[i]]", dir = 1<<(i-1))
			overlays += I

/obj/effect/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/window/update_icon()
	var/obj/structure/window/framed/F = locate() in loc
	if(F && F.junction)
		icon_state = "weedwall[F.junction]"

/obj/effect/alien/weeds/weedwall/frame
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/frame/update_icon()
	var/obj/structure/window_frame/WF = locate() in loc
	if(WF && WF.junction)
		icon_state = "weedframe[WF.junction]"


/obj/effect/alien/weeds/node
	name = "purple sac"
	desc = "A weird, pulsating node."
	icon_state = "weednode"
	health = NODE_HEALTH_STANDARD
	flags_atom = OPENCONTAINER

	// Which weeds are being kept alive by this node?
	var/list/obj/effect/alien/weeds/children = list()

/obj/effect/alien/weeds/node/proc/add_child(var/obj/effect/alien/weeds/weed)
	if(!weed || !istype(weed))
		return
	weed.parent = src
	children += weed

/obj/effect/alien/weeds/node/proc/remove_child(var/obj/effect/alien/weeds/weed)
	if(!weed || !istype(weed) || !(weed in children))
		return
	weed.parent = null
	children -= weed

/obj/effect/alien/weeds/node/proc/replace_child(var/turf/T, var/weed_type)
	if(!T || !istype(T) || QDELETED(src))
		return
	var/obj/effect/alien/weeds/replacement_child = new weed_type(T, src)
	add_child(replacement_child)

/obj/effect/alien/weeds/node/update_icon()
	..()
	overlays += "weednode"

/obj/effect/alien/weeds/node/Initialize(mapload, obj/effect/alien/weeds/node/node, mob/living/carbon/Xenomorph/X, datum/hive_status/hive)
	if (istype(hive))
		linked_hive = hive
	else if (istype(X) && X.hive)
		linked_hive = X.hive
	else
		linked_hive = GLOB.hive_datum[hivenumber]


	. = ..(mapload, src)

	overlays += "weednode"
	if(X)
		add_hiddenprint(X)
		weed_strength = X.weed_level
		if (weed_strength < WEED_LEVEL_STANDARD)
			weed_strength = WEED_LEVEL_STANDARD

		node_range = node_range + weed_strength - 1//stronger weeds expand further!
		if(weed_strength >= WEED_LEVEL_HIVE)
			name = "hive node sac"

	create_reagents(30)
	reagents.add_reagent(PLASMA_PURPLE,30)
	for(var/obj/effect/alien/weeds/W in loc)
		if(W != src)
			if(W.weed_strength > WEED_LEVEL_HIVE)
				qdel(src)
				return
			qdel(W) //replaces the previous weed
			break

/obj/effect/alien/weeds/node/Destroy()
	// When the node is removed, weeds should start dying out
	// Make all the children look for a new parent node
	for(var/X in children)
		var/obj/effect/alien/weeds/W = X
		remove_child(W)
		addtimer(CALLBACK(W, .proc/avoid_orphanage), WEED_BASE_DECAY_SPEED + rand(0, 10)) // Slight variation whilst decaying

	. = ..()

/obj/effect/alien/weeds/node/pylon
	health = WEED_HEALTH_HIVE
	weed_strength = WEED_LEVEL_HIVE
	node_range = WEED_RANGE_PYLON
	var/obj/effect/alien/resin/special/pylon/parent_pylon

/obj/effect/alien/weeds/node/pylon/core
	node_range = WEED_RANGE_CORE

/obj/effect/alien/weeds/node/pylon/Destroy()
	parent_pylon = null
	return ..()

/obj/effect/alien/weeds/node/pylon/ex_act(severity)
	return

/obj/effect/alien/weeds/node/pylon/attackby(obj/item/W, mob/living/user)
	return

/obj/effect/alien/weeds/node/pylon/attack_alien(mob/living/carbon/Xenomorph/X)
	return

/obj/effect/alien/weeds/node/pylon/flamer_fire_act(dam)
	return

/obj/effect/alien/weeds/node/pylon/acid_spray_act()
	return

#undef WEED_BASE_GROW_SPEED
