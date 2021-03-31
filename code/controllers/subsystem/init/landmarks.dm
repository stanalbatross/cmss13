var/list/shuttle_landmarks = list()
var/list/item_pool_landmarks = list()

SUBSYSTEM_DEF(landmark_init)
	name       = "Landmark Init"
	init_order = SS_INIT_LANDMARK
	flags      = SS_NO_FIRE

/datum/controller/subsystem/landmark_init/Initialize()
	RegisterSignal(SSdcs, COMSIG_GLOB_POST_SETUP, .proc/setup_crash_sections)

	for(var/obj/effect/landmark/shuttle_loc/L in shuttle_landmarks)
		L.initialize_marker()
		L.link_loc()
		shuttle_landmarks -= L

	// List of all the datums we need to loop through
	var/list/datum/item_pool_holder/pools = list()

	for (var/obj/effect/landmark/item_pool_spawner/L in item_pool_landmarks)

		var/curr_pool_name = L.pool_name

		if (!curr_pool_name)
			log_debug("Item pool spawner [L] has a no pool name populated. Code: ITEM_POOL_1")
			message_admins("Item pool spawner [L] has a no pool name populated. Tell the devs. Code: ITEM_POOL_1")
			continue

		if (!pools[curr_pool_name])
			pools[curr_pool_name] = new /datum/item_pool_holder(L.pool_name)

		var/datum/item_pool_holder/item_pool_holder = pools[L.pool_name]

		item_pool_holder.turfs += get_turf(L)

		if (L.type_to_spawn)
			item_pool_holder.type_to_spawn = L.type_to_spawn

		if (L.quota)
			item_pool_holder.quota = L.quota

		qdel(L)

	for (var/pool_key in pools)

		var/datum/item_pool_holder/pool = pools[pool_key]

		if (!istype(pool))
			log_debug("Item pool incorrectly initialized by pool spawner landmarks. Code: ITEM_POOL_2")
			message_admins("Item pool incorrectly initialized by pool spawner landmarks. Tell the devs. Code: ITEM_POOL_2")
			continue

		if (!pool.quota || !pool.type_to_spawn)
			log_debug("Item pool [pool.pool_name] has no master landmark, aborting item spawns. Code: ITEM_POOL_3")
			message_admins("Item pool [pool.pool_name] has no master landmark, aborting item spawns. Tell the devs. Code: ITEM_POOL_3")
			continue

		if (pool.quota > pool.turfs.len)
			log_debug("Item pool [pool.pool_name] wants to spawn more items than it has landmarks for. Spawning [turfs.len] instances of [pool.type_to_spawn] instead. Code: ITEM_POOL_4")
			message_admins("Item pool [pool.pool_name] wants to spawn more items than it has landmarks for. Spawning [turfs.len] instances of [pool.type_to_spawn] instead. Tell the devs. Code: ITEM_POOL_4")
			pool.quota = pool.turfs.len

		// Quota times, pick a random turf, spawn an item there, then remove that turf from the list.
		for (var/i in 1 to pool.quota)
			var/turf/T = pool.turfs[rand(1, pool.turfs.len)]
			var/atom/movable/newly_spawned = new pool.type_to_spawn()

			newly_spawned.forceMove(T)
			pool.turfs -= T

	return ..()

/// Categorizes crash landmarks for later usage by hijack related systems
/datum/controller/subsystem/landmark_init/proc/setup_crash_sections()
	PRIVATE_PROC(TRUE)
	GLOB.shuttle_crash_sections = list()

	// First ghetto insertion-sort the landmarks by Fake-Z-Level then X
	var/list/z_landmarks = list()
	for(var/obj/effect/landmark/shuttle_loc/marine_crs/dropship/DCL)
		var/turf/T = get_turf(DCL)
		var/area/A = get_area(T)
		if(!A || !T)
			continue
		if(!is_mainship_level(T.z))
			continue
		if(!isnum(A.fake_zlevel) || A.fake_zlevel < 1)
			continue
		if(A.fake_zlevel > z_landmarks.len)
			z_landmarks.len = A.fake_zlevel
		if(!length(z_landmarks[A.fake_zlevel]))
			z_landmarks[A.fake_zlevel] = list()
		var/list/obj/effect/landmark/shuttle_loc/marine_crs/dropship/AL = z_landmarks[A.fake_zlevel]
		if(!length(AL))
			AL[DCL] = T.x
		var/ipos
		for(ipos in AL.len to 1)
			if(T.x >= AL[AL[ipos]])
				ipos++
				break
		AL.Insert(ipos, DCL)
		AL[DCL] = T.x

	// Now go over each Fake-Z to sort the landmarks into sections
	for(var/zlevel in 1 to z_landmarks.len)
		var/list/obj/effect/landmark/shuttle_loc/marine_crs/dropship/AL = z_landmarks[zlevel]
		if(!length(AL))
			continue
		var/x_min = AL[AL[1]]
		var/x_max = AL[AL[AL.len]]
		var/x_off = (x_max - x_min) * 0.25

		var/section_name
		switch(zlevel)
			if(1) section_name = UPPER_DECK
			if(2) section_name = LOWER_DECK
			else  section_name = num2text(zlevel)

		// Split 25/50/25 into 3 sections, uneven cause edge landmarks aren't actually at edge to leave space for crash
		for(var/obj/effect/landmark/shuttle_loc/marine_crs/dropship/DCL in AL)
			var/turf/TL = get_turf(DCL)
			if(!TL?.z) continue
			var/eff_section
			if(TL.x < (x_min + x_off))
				eff_section = "[section_name] [FORESHIP]"
			else if(TL.x > (x_max - x_off))
				eff_section = "[section_name] [AFTSHIP]"
			else
				eff_section = "[section_name] [MIDSHIP]"
			LAZYINITLIST(GLOB.shuttle_crash_sections[eff_section])
			GLOB.shuttle_crash_sections[eff_section][TL] = DCL.rotation

// Java bean thingy to hold what I need to populate these
/datum/item_pool_holder
	// Exact copies of landmark vars
	var/pool_name
	var/quota
	var/type_to_spawn

	// List of turfs to consider as candidates
	var/list/turfs

/datum/item_pool_holder/New(var/pool_name)
	src.pool_name = pool_name
	turfs = list()

/datum/item_pool_holder/Destroy()
	turfs = null
	. = ..()
