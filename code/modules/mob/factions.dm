//FACTION ALLIANCES
/mob/living/carbon/verb/faction_alliance_status()
	set name = "Faction Alliance Status"
	set desc = "Check the status of your alliances."
	set category = "IC"

	if(!faction || !faction.faction_ui)
		return

	faction.faction_ui.tgui_interact(src)

GLOBAL_LIST_INIT(alliable_factions, generate_alliable_factions())

/proc/generate_alliable_factions()
	. = list()

	.["Xenomorph"] = GLOB.faction_datum[SET_FACTION_LIST_XENOS]

	.["Human"] = GLOB.faction_datum[SET_FACTION_LIST_HUMANS]

	.["Raw"] = .["Human"] + .["Xenomorph"]

/datum/alliance_faction_ui
	var/name = "Factions"

	var/datum/faction_status/assoc_faction = null

/datum/alliance_faction_ui/New(var/datum/faction_status/hive_to_assign)
	. = ..()
	assoc_faction = hive_to_assign

/datum/alliance_faction_ui/ui_state(mob/user)
	return GLOB.hive_state_queen[assoc_faction]

/datum/alliance_faction_ui/tgui_interact(mob/user, datum/tgui/ui)
	if(!assoc_faction)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HiveFaction", "[assoc_faction.name] Faction Panel")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/alliance_faction_ui/ui_data(mob/user)
	. = list()
	.["current_allies"] = assoc_faction.allies

/datum/alliance_faction_ui/ui_static_data(mob/user)
	. = list()
	.["glob_factions"] = GLOB.alliable_factions

/datum/alliance_faction_ui/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_ally")
			if(isnull(params["should_ally"]) || isnull(params["target_faction"]))
				return

			if(!(params["target_faction"] in GLOB.alliable_factions["Raw"]))
				return

			var/should_ally = text2num(params["should_ally"])
			assoc_faction.allies[params["target_faction"]] = should_ally
			. = TRUE

/datum/faction_status_ui
	var/name = "Faction Status"

	var/data_initialized = FALSE

	var/datum/faction_status/assoc_faction = null


/datum/faction_status_ui/New(var/datum/faction_status/faction)
	assoc_faction = faction

//xeno procs
/datum/faction_status_ui/proc/update_xeno_counts(send_update = TRUE)

/datum/faction_status_ui/proc/update_hive_location(send_update = TRUE)

/datum/faction_status_ui/proc/update_xeno_keys(send_update = TRUE)

/datum/faction_status_ui/proc/xeno_removed(var/mob/living/carbon/Xenomorph/X)

/datum/faction_status_ui/proc/update_xeno_info(send_update = TRUE)

/datum/faction_status_ui/proc/update_xeno_vitals()

/datum/faction_status_ui/proc/update_pooled_larva(send_update = TRUE)

/datum/faction_status_ui/proc/update_all_xeno_data(send_update = TRUE)

/datum/faction_status_ui/proc/update_all_data()

/datum/faction_status_ui/proc/open_hive_status(var/mob/user)


/datum/faction_status_ui/hive
	name = "Hive Status"
	var/total_xenos
	var/list/xeno_counts
	var/list/tier_slots
	var/list/xeno_vitals
	var/list/xeno_keys
	var/list/xeno_info
	var/hive_location
	var/pooled_larva
	var/evilution_level

/datum/faction_status_ui/hive/New(var/datum/faction_status/faction)
	assoc_faction = faction
	update_all_data()
	START_PROCESSING(SShive_status, src)

/datum/faction_status_ui/hive/process()
	update_xeno_vitals()
	update_xeno_info(FALSE)
	SStgui.update_uis(src)

// Updates the list tracking how many xenos there are in each tier, and how many there are in total
/datum/faction_status_ui/hive/update_xeno_counts(send_update = TRUE)
	xeno_counts = assoc_faction.get_xeno_counts()

	total_xenos = 0
	for(var/counts in xeno_counts)
		for(var/caste in counts)
			total_xenos += counts[caste]

	if(send_update)
		SStgui.update_uis(src)

	xeno_counts[1] -= "Queen" // don't show queen in the amount of xenos

	// Also update the amount of T2/T3 slots
	tier_slots = assoc_faction.get_tier_slots()

// Updates the hive location using the area name of the defined hive location turf
/datum/faction_status_ui/hive/update_hive_location(send_update = TRUE)
	if(!assoc_faction.hive_location)
		return

	hive_location = strip_improper(get_area_name(assoc_faction.hive_location))

	if(send_update)
		SStgui.update_uis(src)

// Updates the sorted list of all xenos that we use as a key for all other information
/datum/faction_status_ui/hive/update_xeno_keys(send_update = TRUE)
	xeno_keys = assoc_faction.get_xeno_keys()

	if(send_update)
		SStgui.update_uis(src)

// Mildly related to the above, but only for when xenos are removed from the hive
// If a xeno dies, we don't have to regenerate all xeno info and sort it again, just remove them from the data list
/datum/faction_status_ui/hive/xeno_removed(var/mob/living/carbon/Xenomorph/X)
	if(!xeno_keys)
		return

	for(var/index in 1 to length(xeno_keys))
		var/list/info = xeno_keys[index]
		if(info["nicknumber"] == X.nicknumber)

			// tried Remove(), didn't work. *shrug*
			xeno_keys[index] = null
			xeno_keys -= null
			return

	SStgui.update_uis(src)

// Updates the list of xeno names, strains and references
/datum/faction_status_ui/hive/update_xeno_info(send_update = TRUE)
	xeno_info = assoc_faction.get_xeno_info()

	if(send_update)
		SStgui.update_uis(src)

// Updates vital information about xenos such as health and location. Only info that should be updated regularly
/datum/faction_status_ui/hive/update_xeno_vitals()
	xeno_vitals = assoc_faction.get_xeno_vitals()

// Updates how many buried larva there are
/datum/faction_status_ui/hive/update_pooled_larva(send_update = TRUE)
	pooled_larva = assoc_faction.stored_larva
	if(SSxevolution)
		evilution_level = SSxevolution.get_evolution_boost_power(assoc_faction)
	else
		evilution_level = 1

	if(send_update)
		SStgui.update_uis(src)

// Updates all data except pooled larva
/datum/faction_status_ui/hive/update_all_xeno_data(send_update = TRUE)
	update_xeno_counts(FALSE)
	update_xeno_vitals()
	update_xeno_keys(FALSE)
	update_xeno_info(FALSE)

	if(send_update)
		SStgui.update_uis(src)

// Updates all data, including pooled larva
/datum/faction_status_ui/hive/update_all_data()
	data_initialized = TRUE
	update_all_xeno_data(FALSE)
	update_pooled_larva(FALSE)
	SStgui.update_uis(src)

/datum/faction_status_ui/hive/ui_state(mob/user)
	return GLOB.hive_state[assoc_faction]

/datum/faction_status_ui/hive/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(isobserver(user))
		return UI_INTERACTIVE

/datum/faction_status_ui/hive/ui_data(mob/user)
	. = list()
	.["total_xenos"] = total_xenos
	.["xeno_counts"] = xeno_counts
	.["tier_slots"] = tier_slots
	.["xeno_keys"] = xeno_keys
	.["xeno_info"] = xeno_info
	.["xeno_vitals"] = xeno_vitals
	.["queen_location"] = get_area_name(assoc_faction.living_xeno_queen)
	.["hive_location"] = hive_location
	.["pooled_larva"] = pooled_larva
	.["evilution_level"] = evilution_level

	var/mob/living/carbon/Xenomorph/Queen/Q = user
	.["is_in_ovi"] = istype(Q) && Q.ovipositor

/datum/faction_status_ui/hive/ui_static_data(mob/user)
	. = list()
	.["user_ref"] = REF(user)
	.["hive_color"] = assoc_faction.ui_color
	.["hive_name"] = assoc_faction.name

/datum/faction_status_ui/hive/open_hive_status(var/mob/user)
	if(!user)
		return

	// Update absolutely all data
	if(!data_initialized)
		update_all_data()

	tgui_interact(user)

/datum/faction_status_ui/hive/tgui_interact(mob/user, datum/tgui/ui)
	if(!assoc_faction)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HiveStatus", "[assoc_faction.name] Status")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/faction_status_ui/hive/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("give_plasma")
			var/mob/living/carbon/Xenomorph/xenoTarget = locate(params["target_ref"]) in GLOB.living_xeno_list
			var/mob/living/carbon/Xenomorph/xenoSrc = ui.user

			if(QDELETED(xenoTarget) || xenoTarget.stat == DEAD || is_admin_level(xenoTarget.z))
				return

			if(xenoSrc.stat == DEAD)
				return

			var/datum/action/xeno_action/A = get_xeno_action_by_type(xenoSrc, /datum/action/xeno_action/activable/queen_give_plasma)
			A?.use_ability_wrapper(xenoTarget)

		if("heal")
			var/mob/living/carbon/Xenomorph/xenoTarget = locate(params["target_ref"]) in GLOB.living_xeno_list
			var/mob/living/carbon/Xenomorph/xenoSrc = ui.user

			if(QDELETED(xenoTarget) || xenoTarget.stat == DEAD || is_admin_level(xenoTarget.z))
				return

			if(xenoSrc.stat == DEAD)
				return

			var/datum/action/xeno_action/A = get_xeno_action_by_type(xenoSrc, /datum/action/xeno_action/activable/queen_heal)
			A?.use_ability_wrapper(xenoTarget, TRUE)

		if("overwatch")
			var/mob/living/carbon/Xenomorph/xenoTarget = locate(params["target_ref"]) in GLOB.living_xeno_list
			var/mob/living/carbon/Xenomorph/xenoSrc = ui.user

			if(QDELETED(xenoTarget) || xenoTarget.stat == DEAD || is_admin_level(xenoTarget.z))
				return

			if(xenoSrc.stat == DEAD)
				if(isobserver(xenoSrc))
					var/mob/dead/observer/O = xenoSrc
					O.ManualFollow(xenoTarget)
				return

			if(!xenoSrc.check_state(TRUE))
				return

			var/isQueen = (xenoSrc.caste_type == XENO_CASTE_QUEEN)
			if (isQueen)
				xenoSrc.overwatch(xenoTarget, movement_event_handler = /datum/event_handler/xeno_overwatch_onmovement/queen)
			else
				xenoSrc.overwatch(xenoTarget)




//FACTIONS
/datum/faction_status
	var/name
	var/internal_faction
	var/faction_number

	var/orders = ""
	var/color = null
	var/ui_color = null
	var/prefix = ""

	var/faction_color = TACMAP_BASE_ALLIES_COLOR
	var/enemy_color = TACMAP_BASE_ENEMY_COLOR
	var/list/mob/living/carbon/not_allies_faction_mobs
	var/list/totalMobs = list()

	//REFS TO FACTIONS
	var/list/datum/faction_status/allies = list()
	var/list/datum/faction_status/neutrals = list()
	var/list/datum/faction_status/enemies = list()
	var/list/datum/faction_status/no_data_factions = list()
	//INITIAL
	var/list/allies_initial
	var/list/neutrals_initial
	var/list/enemies_initial

	var/mob/living/carbon/leader

	//XENO
	var/xeno = FALSE
	var/mob/living/carbon/Xenomorph/Queen/living_xeno_queen
	var/egg_planting_range = 15
	var/slashing_allowed = XENO_SLASH_ALLOWED //This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
	var/construction_allowed = NORMAL_XENO //Who can place construction nodes for special structures
	var/destruction_allowed = XENO_LEADER //Who can destroy special structures
	var/unnesting_allowed = TRUE
	var/queen_leader_limit = 2
	var/list/open_xeno_leader_positions = list(1, 2) // Ordered list of xeno leader positions (indexes in xeno_leader_list) that are not occupied
	var/list/xeno_leader_list[2] // Ordered list (i.e. index n holds the nth xeno leader)
	var/stored_larva = 0
	/// Assoc list of free slots available to specific castes
	var/list/free_slots = list(
		/datum/caste_datum/burrower = 1,
		/datum/caste_datum/hivelord = 1,
		/datum/caste_datum/carrier = 1
	)
	/// Assoc list of free slots currently used by specific castes
	var/list/used_free_slots
	var/list/tier_2_xenos = list()//list of living tier2 xenos
	var/list/tier_3_xenos = list()//list of living tier3 xenos
	var/xeno_queen_timer
	var/isSlotOpen = TRUE //Set true for starting alerts only after the hive has reached its full potential
	var/allowed_nest_distance = 15 //How far away do we allow nests from an ovied Queen. Default 15 tiles.
	var/obj/effect/alien/resin/special/pylon/core/hive_location = null //Set to ref every time a core is built, for defining the hive location.
	var/obj/effect/alien/resin/special/pool/spawn_pool = null // Ref to the spawn pool if there is one
	var/obj/effect/alien/resin/special/silo/silo = null // Ref to the spawn pool if there is one
	var/crystal_stored = 0 //How much stockpiled material is stored for the hive to use.
	var/xenocon_points = 0 //Xeno version of DEFCON

	var/datum/mutator_set/hive_mutators/mutators = new
	var/tier_slot_multiplier = 1.0
	var/larva_gestation_multiplier = 1.0
	var/bonus_larva_spawn_chance = 1.0
	var/hijack_pooled_surge = FALSE //at hijack, start spawning lots of pooled

	var/ignore_slots = FALSE
	var/dynamic_evolution = TRUE
	var/evolution_rate = 3 // Only has use if dynamic_evolution is false
	var/evolution_bonus = 0

	var/allow_no_queen_actions = FALSE
	var/evolution_without_ovipositor = TRUE //Temporary for the roundstart.
	var/allow_queen_evolve = TRUE // Set to true if you want to prevent evolutions into Queens
	var/hardcore = FALSE // Set to true if you want to prevent bursts and spawns of new xenos. Will also prevent healing if the queen no longer exists

	var/list/hive_inherant_traits

	// Cultist Info
	var/mob/living/carbon/leading_cult_sl

	//List of how many maximum of each special structure you can have
	var/list/hive_structures_limit = list(
		XENO_STRUCTURE_CORE = 1,
		XENO_STRUCTURE_CLUSTER = 8,
		XENO_STRUCTURE_PYLON = 3,
		XENO_STRUCTURE_POOL = 1,
		XENO_STRUCTURE_EGGMORPH = 6,
		XENO_STRUCTURE_EVOPOD = 2,
		XENO_STRUCTURE_RECOVERY = 6,
	)

	var/global/list/hive_structure_types = list(
		XENO_STRUCTURE_CORE = /datum/construction_template/xenomorph/core,
		XENO_STRUCTURE_CLUSTER = /datum/construction_template/xenomorph/cluster,
		XENO_STRUCTURE_POOL = /datum/construction_template/xenomorph/pool,
		XENO_STRUCTURE_EGGMORPH = /datum/construction_template/xenomorph/eggmorph,
		XENO_STRUCTURE_EVOPOD = /datum/construction_template/xenomorph/evopod,
		XENO_STRUCTURE_RECOVERY = /datum/construction_template/xenomorph/recovery,
	)

	var/list/list/hive_structures = list() //Stringref list of structures that have been built
	var/list/list/hive_constructions = list() //Stringref list of structures that are being built

	var/datum/faction_status_ui/faction_ui

	var/list/tunnels = list()

/datum/faction_status/New()
	faction_ui = new(src)
	initialize_faction_statuses()

/datum/faction_status/proc/initialize_faction_statuses()
	var/list/ally = allies_initial
	var/list/enemy = enemies_initial
	var/list/netral = neutrals_initial
	for(var/list/i in ally)
		allies += GLOB.faction_datum[i[1]]
	for(var/list/i in netral)
		neutrals += GLOB.faction_datum[i[1]]
	for(var/list/i in enemy)
		enemies += GLOB.faction_datum[i[1]]
	var/list/allfactions = GLOB.faction_datum - allies - neutrals - enemies - src
	for(var/i in allfactions)
		no_data_factions += GLOB.faction_datum[i]

/datum/faction_status/proc/add_mob(var/mob/living/carbon/C)
	if(!C || !istype(C))
		return

	if(C.faction && C.faction != src)
		C.faction.remove_mob(C, TRUE)

	if(C in totalMobs)
		return

	C.set_faction(src)

	if(C.hud_list)
		C.hud_update()

	if(!is_admin_level(C.z))
		totalMobs += C

/datum/faction_status/proc/remove_mob(var/mob/living/carbon/C, var/hard=FALSE)
	if(!C || !istype(C))
		return

	if(!(C in totalMobs))
		return

	if(hard)
		C.faction = null

	totalMobs -= C

/mob/living/carbon/proc/set_faction(var/datum/faction_status/new_faction)
	faction = new_faction

/mob/living/carbon/proc/ally(var/datum/faction_status/ally_faction)
	if(!ally_faction)
		return FALSE

	if(ally_faction == faction)
		return ally_faction

	return ally_faction.is_ally(src)

/datum/faction_status/proc/is_ally(var/mob/living/carbon/C)
	if(!C.faction)
		return FALSE

	return faction_is_ally(C.faction)

/datum/faction_status/proc/faction_is_ally(var/datum/faction_status/faction)
	return allies[faction]

/datum/faction_status/neutral
	name = "United States Colonial Marine Corps"
	internal_faction = FACTION_NEUTRAL
	faction_number = SET_FACTION_NEUTRAL
	color = "#22888a"
	ui_color = "#22888a"

	allies_initial = list(SET_FACTION_WY, SET_FACTION_RESS, SET_FACTION_COLONIST, SET_FACTION_FREELANCER, SET_FACTION_UPP, SET_FACTION_CLF)
	neutrals_initial = list(SET_FACTION_THREEWE, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_PIRATE)

/datum/faction_status/neutral/dutch
	name = "Dutch's Dozen"
	internal_faction = FACTION_DUTCH
	faction_number = SET_FACTION_DUTCH

/datum/faction_status/neutral/dutch/mercenary
	name = "Dutch's Dozen Mercenary"
	internal_faction = FACTION_MERCENARY
	faction_number = SET_FACTION_MERCENARY

/datum/faction_status/neutral/pirate
	name = "Pirates"
	internal_faction = FACTION_PIRATE
	faction_number = SET_FACTION_PIRATE

/datum/faction_status/neutral/colonist
	name = "Colony"
	internal_faction = FACTION_COLONIST
	faction_number = SET_FACTION_COLONIST

/datum/faction_status/neutral/hefa
	name = "HEFA Knights"
	internal_faction = FACTION_HEFA
	faction_number = SET_FACTION_HEFA

/datum/faction_status/neutral/mutineer
	name = "Mutineer Cult"
	internal_faction = FACTION_MUTINEER
	faction_number = SET_FACTION_MUTINEER

/datum/faction_status/neutral/pizza
	name = "Pizza Galaxy"
	internal_faction = FACTION_PIZZA
	faction_number = SET_FACTION_PIZZA

/datum/faction_status/neutral/pizza/souto
	name = "Souto Galaxy"
	internal_faction = FACTION_SOUTO
	faction_number = SET_FACTION_SOUTO

/datum/faction_status/neutral/freelancer
	name = "Freelancers"
	internal_faction = FACTION_FREELANCER
	faction_number = SET_FACTION_FREELANCER

/datum/faction_status/uscm
	name = "United States Colonial Marine Corps"
	internal_faction = FACTION_MARINE
	faction_number = SET_FACTION_USCM
	color = "#1b337a"
	ui_color = "#1b337a"

	allies_initial = list(SET_FACTION_WY, SET_FACTION_RESS, SET_FACTION_COLONIST, SET_FACTION_FREELANCER)
	neutrals_initial = list(SET_FACTION_THREEWE, SET_FACTION_NEUTRAL, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_UPP, SET_FACTION_CLF, SET_FACTION_PIRATE)

/datum/faction_status/ress
	name = "Royal Empire of the Shining Sun"
	internal_faction = FACTION_RESS
	faction_number = SET_FACTION_RESS
	color = "#a1805d"
	ui_color = "#a1805d"

	allies_initial = list(SET_FACTION_USCM, SET_FACTION_COLONIST, SET_FACTION_FREELANCER)
	neutrals_initial = list(SET_FACTION_THREEWE, SET_FACTION_NEUTRAL, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_UPP, SET_FACTION_CLF, SET_FACTION_PIRATE)

/datum/faction_status/upp
	name = "Union of Progressive Peoples"
	internal_faction = FACTION_UPP
	faction_number = SET_FACTION_UPP
	color = "#02b513"
	ui_color = "#02b513"

	allies_initial = list(SET_FACTION_WY, SET_FACTION_COLONIST, SET_FACTION_FREELANCER)
	neutrals_initial = list(SET_FACTION_NEUTRAL, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_THREEWE, SET_FACTION_CLF, SET_FACTION_PIRATE, SET_FACTION_USCM)

/datum/faction_status/wy
	name = "Weyland-Yutani"
	internal_faction = FACTION_WY
	faction_number = SET_FACTION_WY
	color = "#4cb4c2"
	ui_color = "#4cb4c2"

	allies_initial = list(SET_FACTION_USCM, SET_FACTION_UPP, SET_FACTION_THREEWE, SET_FACTION_COLONIST, SET_FACTION_FREELANCER)
	neutrals_initial = list(SET_FACTION_NEUTRAL, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_CLF, SET_FACTION_PIRATE)

/datum/faction_status/clf
	name = "Colonial Liberation Front"
	internal_faction = FACTION_CLF
	faction_number = SET_FACTION_CLF
	color = "#82ad5e"
	ui_color = "#82ad5e"

	allies_initial = list(SET_FACTION_USCM, SET_FACTION_COLONIST, SET_FACTION_FREELANCER)
	neutrals_initial = list(SET_FACTION_THREEWE, SET_FACTION_NEUTRAL, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_UPP, SET_FACTION_CLF, SET_FACTION_PIRATE)

/datum/faction_status/threewe
	name = "Three World Empire"
	internal_faction = FACTION_THREEWE
	faction_number = SET_FACTION_THREEWE
	color = "#c77db2"
	ui_color = "#c77db2"

	allies_initial = list(SET_FACTION_WY)
	neutrals_initial = list(SET_FACTION_USCM, SET_FACTION_RESS, SET_FACTION_CLF, SET_FACTION_NEUTRAL, SET_FACTION_HEFA, SET_FACTION_MUTINEER, SET_FACTION_PIZZA)
	enemies_initial = list(SET_FACTION_UPP, SET_FACTION_PIRATE)

/datum/faction_status/yautja
	name = "Yautja Hanters"
	internal_faction = FACTION_YAUTJA
	faction_number = SET_FACTION_YAUTJA_NORMAL
	color = "#5ca162"
	ui_color = "#5ca162"

	enemies_initial = SET_FACTION_LIST_ALL

/datum/faction_status/xeno
	name = "Normal Hive"
	internal_faction = FACTION_XENOMORPH
	faction_number = SET_FACTION_HIVE_NORMAL

	evolution_without_ovipositor = FALSE

	enemies_initial = SET_FACTION_LIST_ALL

	xeno = TRUE

/datum/faction_status/xeno/New()
	mutators.faction = src
	faction_ui = new /datum/faction_status_ui/hive(src)
	initialize_faction_statuses()

// Adds a xeno to this hive
/datum/faction_status/xeno/add_mob(var/mob/living/carbon/Xenomorph/X)
	if(!X || !istype(X))
		return

	// If the xeno is part of another hive, they should be removed from that one first
	if(X.faction && X.faction != src)
		X.faction.remove_mob(X, TRUE)

	// Already in the hive
	if(X in totalMobs)
		return

	// Can only have one queen.
	if(isXenoQueen(X))
		if(!living_xeno_queen && !is_admin_level(X.z)) // Don't consider xenos in admin level
			set_living_xeno_queen(X)

	X.set_faction(src)

	if(X.hud_list)
		X.hud_update()

	var/area/A = get_area(X)
	if(!is_admin_level(X.z) || (A.flags_atom & AREA_ALLOW_XENO_JOIN))
		totalMobs += X
		if(X.tier == 2)
			tier_2_xenos += X
		else if(X.tier == 3)
			tier_3_xenos += X

	// Xenos are a fuckfest of cross-dependencies of different datums that are initialized at different times
	// So don't even bother trying updating UI here without large refactors

// Removes the xeno from the hive
/datum/faction_status/xeno/remove_mob(var/mob/living/carbon/Xenomorph/X, var/hard=FALSE, light_mode = FALSE)
	if(!X || !istype(X))
		return

	// Make sure the xeno was in the hive in the first place
	if(!(X in totalMobs))
		return

	if(isXenoQueen(X))
		if(living_xeno_queen == X)
			var/mob/living/carbon/Xenomorph/Queen/next_queen
			for(var/mob/living/carbon/Xenomorph/Queen/Q in totalMobs)
				if(!is_admin_level(Q.z))
					next_queen = Q
					break

			set_living_xeno_queen(next_queen) // either null or a queen

	// We allow "soft" removals from the hive (the xeno still retains information about the hive)
	// This is so that xenos can add themselves back to the hive if they should die or otherwise go "on leave" from the hive
	if(hard)
		X.faction = null

	totalMobs -= X
	if(X.tier == 2)
		tier_2_xenos -= X
	else if(X.tier == 3)
		tier_3_xenos -= X

	if(!light_mode)
		faction_ui.update_xeno_counts()
		faction_ui.xeno_removed(X)

/datum/faction_status/proc/set_living_xeno_queen(var/mob/living/carbon/Xenomorph/Queen/M)
	if(M == null)
		mutators.reset_mutators()
		SStracking.delete_leader("hive_[internal_faction]")
		SStracking.stop_tracking("hive_[internal_faction]", living_xeno_queen)
		SShive_status.wait = 10 SECONDS
	else
		SStracking.set_leader("hive_[internal_faction]", M)
		SShive_status.wait = 2 SECONDS

	living_xeno_queen = M

	recalculate_hive()

/datum/faction_status/proc/recalculate_hive()
	if(!living_xeno_queen)
		queen_leader_limit = 0 //No leaders for a Hive without a Queen!
	else
		queen_leader_limit = 4 + mutators.leader_count_boost

	if(xeno_leader_list.len > queen_leader_limit)
		var/diff = 0
		for(var/i in queen_leader_limit + 1 to xeno_leader_list.len)
			if(!open_xeno_leader_positions.Remove(i))
				remove_hive_leader(xeno_leader_list[i])
			diff++
		xeno_leader_list.len -= diff // Changing the size of xeno_leader_list needs to go at the end or else it won't iterate through the list properly
	else if (xeno_leader_list.len < queen_leader_limit)
		for (var/i in xeno_leader_list.len + 1 to queen_leader_limit)
			open_xeno_leader_positions += i
			xeno_leader_list.len++


	tier_slot_multiplier = mutators.tier_slot_multiplier
	larva_gestation_multiplier = mutators.larva_gestation_multiplier
	bonus_larva_spawn_chance = mutators.bonus_larva_spawn_chance

	faction_ui.update_all_data()

/datum/faction_status/proc/add_hive_leader(var/mob/living/carbon/Xenomorph/xeno)
	if(!xeno)
		return FALSE //How did this even happen?
	if(!open_xeno_leader_positions.len)
		return FALSE //Too many leaders already (no available xeno leader positions)
	if(xeno.hive_pos != NORMAL_XENO)
		return FALSE //Already on the list
	var/leader_num = open_xeno_leader_positions[1]
	xeno_leader_list[leader_num] = xeno
	xeno.hive_pos = XENO_LEADER_HIVE_POS(leader_num)
	xeno.handle_xeno_leader_pheromones()
	xeno.hud_update() // To add leader star
	open_xeno_leader_positions -= leader_num

	faction_ui.update_xeno_keys()
	return TRUE

/datum/faction_status/proc/remove_hive_leader(var/mob/living/carbon/Xenomorph/xeno, light_mode = FALSE)
	if(!istype(xeno) || !IS_XENO_LEADER(xeno))
		return FALSE

	var/leader_num = GET_XENO_LEADER_NUM(xeno)

	xeno_leader_list[leader_num] = null

	if(!light_mode) // Don't run side effects during deletions. Better yet, replace all this by signals someday
		xeno.hive_pos = NORMAL_XENO
		xeno.handle_xeno_leader_pheromones()
		xeno.hud_update() // To remove leader star

	// Need to maintain ascending order of open_xeno_leader_positions
	for (var/i in 1 to queen_leader_limit)
		if (i > open_xeno_leader_positions.len || open_xeno_leader_positions[i] > leader_num)
			open_xeno_leader_positions.Insert(i, leader_num)
			break

	if(!light_mode)
		faction_ui.update_xeno_keys()

	return TRUE

/datum/faction_status/proc/replace_hive_leader(var/mob/living/carbon/Xenomorph/original, var/mob/living/carbon/Xenomorph/replacement)
	if(!replacement || replacement.hive_pos != NORMAL_XENO)
		return remove_hive_leader(original)

	var/leader_num = GET_XENO_LEADER_NUM(original)

	xeno_leader_list[leader_num] = replacement

	original.hive_pos = NORMAL_XENO
	original.handle_xeno_leader_pheromones()
	original.hud_update() // To remove leader star

	replacement.hive_pos = XENO_LEADER_HIVE_POS(leader_num)
	replacement.handle_xeno_leader_pheromones()
	replacement.hud_update() // To add leader star

	faction_ui.update_xeno_keys()

/datum/faction_status/proc/handle_xeno_leader_pheromones()
	for(var/mob/living/carbon/Xenomorph/L in xeno_leader_list)
		L.handle_xeno_leader_pheromones()

/*
 *    Helper procs for the Hive Status UI
 *    These are all called by the hive status UI manager to update its data
 */

// Returns a list of how many of each caste of xeno there are, sorted by tier
/datum/faction_status/proc/get_xeno_counts()
	// Every caste is manually defined here so you get
	var/list/xeno_counts = list(
		// Yes, Queen is technically considered to be tier 0
		list(XENO_CASTE_LARVA = 0, "Queen" = 0),
		list(XENO_CASTE_DRONE = 0, XENO_CASTE_RUNNER = 0, XENO_CASTE_SENTINEL = 0, XENO_CASTE_DEFENDER = 0),
		list(XENO_CASTE_HIVELORD = 0, XENO_CASTE_BURROWER = 0, XENO_CASTE_CARRIER = 0, XENO_CASTE_LURKER = 0, XENO_CASTE_SPITTER = 0, XENO_CASTE_WARRIOR = 0),
		list(XENO_CASTE_BOILER = 0, XENO_CASTE_CRUSHER = 0, XENO_CASTE_PRAETORIAN = 0, XENO_CASTE_RAVAGER = 0)
	)

	for(var/mob/living/carbon/Xenomorph/X in totalMobs)
		//don't show xenos in the thunderdome when admins test stuff.
		if(is_admin_level(X.z))
			var/area/A = get_area(X)
			if(!(A.flags_atom & AREA_ALLOW_XENO_JOIN))
				continue

		if(X.caste)
			xeno_counts[X.caste.tier+1][X.caste.caste_type]++

	return xeno_counts

// Returns a sorted list of some basic info (stuff that's needed for sorting) about all the xenos in the hive
// The idea is that we sort this list, and use it as a "key" for all the other information (especially the nicknumber)
// in the hive status UI. That way we can minimize the amount of sorts performed by only calling this when xenos are created/disposed
/datum/faction_status/proc/get_xeno_keys()
	var/list/xenos[totalMobs.len]

	var/index = 1
	var/useless_slots = 0
	for(var/mob/living/carbon/Xenomorph/X in totalMobs)
		if(is_admin_level(X.z))
			var/area/A = get_area(X)
			if(!(A.flags_atom & AREA_ALLOW_XENO_JOIN))
				useless_slots++
				continue

		// Insert without doing list merging
		xenos[index++] = list(
			"nicknumber" = X.nicknumber,
			"tier" = X.tier, // This one is only important for sorting
			"is_leader" = (IS_XENO_LEADER(X)),
			"is_queen" = istype(X.caste, /datum/caste_datum/queen),
			"caste_type" = X.caste_type
		)

	// Clear nulls from the xenos list
	xenos.len -= useless_slots

	// Make it all nice and fancy by sorting the list before returning it
	var/list/sorted_keys = sort_xeno_keys(xenos)
	if(length(sorted_keys))
		return sorted_keys
	return xenos

// This sorts the xeno info list by multiple criteria. Prioritized in order:
// 1. Queen
// 2. Leaders
// 3. Tier
// It uses a slightly modified insertion sort to accomplish this
/datum/faction_status/proc/sort_xeno_keys(var/list/xenos)
	if(!length(xenos))
		return

	var/list/sorted_list = xenos.Copy()

	if(!length(sorted_list))
		return

	for(var/index in 2 to length(sorted_list))
		var/j = index

		while(j > 1)
			var/current = sorted_list[j]
			var/prev = sorted_list[j-1]

			// Queen comes first, always
			if(current["is_queen"])
				sorted_list.Swap(j-1, j)
				j--
				continue

			// don't muck up queen's slot
			if(prev["is_queen"])
				j--
				continue

			// Leaders before normal xenos
			if(!prev["is_leader"] && current["is_leader"])
				sorted_list.Swap(j-1, j)
				j--
				continue

			// Make sure we're only comparing leaders to leaders and non-leaders to non-leaders when sorting
			// This means we get leaders sorted first, then non-leaders sorted
			// Sort by tier first, higher tiers over lower tiers, and then by name alphabetically

			// Could not think of an elegant way to write this
			if(!(current["is_leader"]^prev["is_leader"])\
				&& (prev["tier"] < current["tier"]\
				|| prev["tier"] == current["tier"] && prev["caste_type"] > current["caste_type"]\
			))
				sorted_list.Swap(j-1, j)

			j--

	return sorted_list

// Returns a list with some more info about all xenos in the hive
/datum/faction_status/proc/get_xeno_info()
	var/list/xenos = list()

	for(var/mob/living/carbon/Xenomorph/X in totalMobs)
		if(is_admin_level(X.z))
			var/area/A = get_area(X)
			if(!(A.flags_atom & AREA_ALLOW_XENO_JOIN))
				continue

		var/xeno_name = X.name
		// goddamn fucking larvas with their weird ass maturing system
		// its name updates with its icon, unlike other castes which only update the mature/elder, etc. prefix on evolve
		if(istype(X, /mob/living/carbon/Xenomorph/Larva))
			xeno_name = "Larva ([X.nicknumber])"
		xenos["[X.nicknumber]"] = list(
			"name" = xeno_name,
			"strain" = X.strain_type,
			"ref" = "\ref[X]"
		)

	return xenos

/datum/faction_status/proc/set_hive_location(var/obj/effect/alien/resin/special/pylon/core/C)
	if(!C || C == hive_location)
		return
	var/area/A = get_area(C)
	xeno_message(SPAN_XENOANNOUNCE("The Queen has set the hive location as \the [A]."), 3, internal_faction)
	hive_location = C
	faction_ui.update_hive_location()

// Returns a list of xeno healths and locations
/datum/faction_status/proc/get_xeno_vitals()
	var/list/xenos = list()

	for(var/mob/living/carbon/Xenomorph/X in totalMobs)
		if(is_admin_level(X.z))
			var/area/A = get_area(X)
			if(!(A.flags_atom & AREA_ALLOW_XENO_JOIN))
				continue

		if(!(X in GLOB.living_xeno_list))
			continue

		var/area/A = get_area(X)
		var/area_name = "Unknown"
		if(A)
			area_name = A.name

		xenos["[X.nicknumber]"] = list(
			"health" = round((X.health / X.maxHealth) * 100, 1),
			"area" = area_name,
			"is_ssd" = (!X.client)
		)

	return xenos

#define TIER_3 "3"
#define TIER_2 "2"
#define OPEN_SLOTS "open_slots"
#define GUARANTEED_SLOTS "guaranteed_slots"

// Returns an assoc list of open slots and guaranteed slots left
/datum/faction_status/proc/get_tier_slots()
	var/list/slots = list(
		TIER_3 = list(
			OPEN_SLOTS = 0,
			GUARANTEED_SLOTS = list(),
		),
		TIER_2 = list(
			OPEN_SLOTS = 0,
			GUARANTEED_SLOTS = list(),
		),
	)

	var/pooled_factor = min(stored_larva, sqrt(4*stored_larva))
	pooled_factor = round(pooled_factor)

	var/used_tier_2_slots = length(tier_2_xenos)
	var/used_tier_3_slots = length(tier_3_xenos)
	for(var/caste_path in used_free_slots)
		var/used_count = used_free_slots[caste_path]
		if(!used_count)
			continue
		var/datum/caste_datum/C = caste_path
		switch(initial(C.tier))
			if(2) used_tier_2_slots -= used_count
			if(3) used_tier_3_slots -= used_count

	for(var/caste_path in free_slots)
		var/slot_count = free_slots[caste_path]
		if(!slot_count)
			continue
		var/datum/caste_datum/C = caste_path
		switch(initial(C.tier))
			if(2) slots[TIER_2][GUARANTEED_SLOTS][initial(C.caste_type)] = slot_count
			if(3) slots[TIER_3][GUARANTEED_SLOTS][initial(C.caste_type)] = slot_count

	var/effective_total = length(totalMobs) + pooled_factor

	// Tier 3 slots are always 20% of the total xenos in the hive
	slots[TIER_3][OPEN_SLOTS] = max(0, Ceiling(0.20*length(totalMobs)/tier_slot_multiplier) - used_tier_3_slots)
	// Tier 2 slots are between 30% and 50% of the hive, depending
	// on how many T3s there are.
	slots[TIER_2][OPEN_SLOTS] = max(0, Ceiling(0.5*effective_total/tier_slot_multiplier) - used_tier_2_slots - used_tier_3_slots)

	return slots

#undef TIER_3
#undef TIER_2
#undef OPEN_SLOTS
#undef GUARANTEED_SLOTS

// returns if that location can be used to plant eggs
/datum/faction_status/proc/in_egg_plant_range(var/turf/T)
	if(!istype(living_xeno_queen))
		return TRUE // xenos already dicked without queen. Let them plant whereever

	if(!living_xeno_queen.ovipositor)
		return FALSE // ovid queen only

	return get_dist(living_xeno_queen, T) <= egg_planting_range

/datum/faction_status/proc/can_build_structure(var/structure_name)
	if(!structure_name || !hive_structures_limit[structure_name])
		return FALSE
	var/total_count = 0
	if(hive_structures[structure_name])
		total_count += hive_structures[structure_name].len
	if(hive_constructions[structure_name])
		total_count += hive_constructions[structure_name].len
	if(total_count >= hive_structures_limit[structure_name])
		return FALSE
	return TRUE

/datum/faction_status/proc/has_structure(var/structure_name)
	if(!structure_name)
		return FALSE
	if(hive_structures[structure_name] && hive_structures[structure_name].len)
		return TRUE
	return FALSE

/datum/faction_status/proc/add_construction(var/obj/effect/alien/resin/construction/S)
	if(!S || !S.template)
		return FALSE
	var/name_ref = initial(S.template.name)
	if(!hive_constructions[name_ref])
		hive_constructions[name_ref] = list()
	if(hive_constructions[name_ref].len >= hive_structures_limit[name_ref])
		return FALSE
	hive_constructions[name_ref] += src
	return TRUE

/datum/faction_status/proc/remove_construction(var/obj/effect/alien/resin/construction/S)
	if(!S || !S.template)
		return FALSE
	var/name_ref = initial(S.template.name)
	hive_constructions[name_ref] -= src
	return TRUE

/datum/faction_status/proc/add_special_structure(var/obj/effect/alien/resin/special/S)
	if(!S)
		return FALSE
	var/name_ref = initial(S.name)
	if(!hive_structures[name_ref])
		hive_structures[name_ref] = list()
	if(hive_structures[name_ref].len >= hive_structures_limit[name_ref])
		return FALSE
	hive_structures[name_ref] += S
	return TRUE

/datum/faction_status/proc/remove_special_structure(var/obj/effect/alien/resin/special/S)
	if(!S)
		return FALSE
	var/name_ref = initial(S.name)
	hive_structures[name_ref] -= S
	return TRUE

/datum/faction_status/proc/has_special_structure(var/name_ref)
	if(!name_ref || !hive_structures[name_ref] || !hive_structures[name_ref].len)
		return 0
	return hive_structures[name_ref].len

/datum/faction_status/proc/abandon_on_hijack()
	var/area/hijacked_dropship = get_area(living_xeno_queen)
	for(var/name_ref in hive_structures)
		for(var/obj/effect/alien/resin/special/S in hive_structures[name_ref])
			if(get_area(S) == hijacked_dropship)
				continue
			hive_structures[name_ref] -= S
			qdel(S)
	for(var/i in totalMobs)
		var/mob/living/carbon/Xenomorph/xeno = i
		if(get_area(xeno) != hijacked_dropship && xeno.loc && is_ground_level(xeno.loc.z))
			to_chat(xeno, SPAN_XENOANNOUNCE("The Queen has left without you, you quickly find a hiding place to enter hibernation as you lose touch with the hive mind."))
			qdel(xeno)
	for(var/i in GLOB.alive_mob_list)
		var/mob/living/potential_host = i
		if(!(potential_host.status_flags & XENO_HOST))
			continue
		if(!is_ground_level(potential_host.z) || get_area(potential_host) == hijacked_dropship)
			continue
		var/obj/item/alien_embryo/A = locate() in potential_host
		if(A && A.faction != src)
			continue
		for(var/obj/item/alien_embryo/embryo in potential_host)
			qdel(embryo)
		potential_host.death(create_cause_data("самоубийство лярвы"))

/datum/faction_status/proc/free_respawn(var/client/C)
	stored_larva++
	if(!spawn_pool || !spawn_pool.spawn_pooled_larva(C.mob))
		stored_larva--
	else
		faction_ui.update_pooled_larva()

/datum/faction_status/xeno/is_ally(var/mob/living/carbon/C)
	if(isXeno(C) && C.faction == src)
		var/mob/living/carbon/Xenomorph/X = C
		return !X.banished
	. = ..()

/datum/faction_status/xeno/faction_is_ally(var/datum/faction_status/faction)
	if(!living_xeno_queen)
		return FALSE
	. = ..()

/datum/faction_status/xeno/corrupted
	name = "Corrupted Hive"
	internal_faction = FACTION_XENOMORPH_CORRPUTED
	faction_number = SET_FACTION_HIVE_CORRUPTED

	prefix = "Corrupted "
	color = "#80ff80"
	ui_color ="#4d994d"

/datum/faction_status/xeno/corrupted/add_mob(mob/living/carbon/Xenomorph/X)
	. = ..()
	X.add_language(LANGUAGE_ENGLISH)

/datum/faction_status/xeno/corrupted/remove_mob(mob/living/carbon/Xenomorph/X, hard)
	. = ..()
	X.remove_language(LANGUAGE_ENGLISH)

/datum/faction_status/xeno/alpha
	name = "Alpha Hive"
	internal_faction = FACTION_XENOMORPH_ALPHA
	faction_number = SET_FACTION_HIVE_ALPHA

	prefix = "Alpha "
	color = "#ff4040"
	ui_color = "#992626"

	dynamic_evolution = FALSE

/datum/faction_status/xeno/bravo
	name = "Bravo Hive"
	internal_faction = FACTION_XENOMORPH_BRAVO
	faction_number = SET_FACTION_HIVE_BRAVO

	prefix = "Bravo "
	color = "#ffff80"
	ui_color = "#99994d"

	dynamic_evolution = FALSE

/datum/faction_status/xeno/charlie
	name = "Charlie Hive"
	internal_faction = FACTION_XENOMORPH_CHARLIE
	faction_number = SET_FACTION_HIVE_CHARLIE

	prefix = "Charlie "
	color = "#bb40ff"
	ui_color = "#702699"

	dynamic_evolution = FALSE

/datum/faction_status/xeno/delta
	name = "Delta Hive"
	internal_faction = FACTION_XENOMORPH_DELTA
	faction_number = SET_FACTION_HIVE_DELTA

	prefix = "Delta "
	color = "#8080ff"
	ui_color = "#4d4d99"

	dynamic_evolution = FALSE

/datum/faction_status/xeno/feral
	name = "Feral Hive"
	internal_faction = FACTION_XENOMORPH_FERAL
	faction_number = SET_FACTION_HIVE_FERAL

	prefix = "Feral "
	color = "#828296"
	ui_color = "#828296"

	construction_allowed = XENO_QUEEN
	dynamic_evolution = FALSE
	allow_no_queen_actions = TRUE
	allow_queen_evolve = FALSE
	ignore_slots = TRUE

/datum/faction_status/xeno/mutated
	name = "Mutated Hive"
	internal_faction = FACTION_XENOMORPH_MUTATED
	faction_number = SET_FACTION_HIVE_MUTATED

	prefix = "Mutated "
	color = "#6abd99"
	ui_color = "#6abd99"

	hive_inherant_traits = list(TRAIT_XENONID)

/datum/faction_status/xeno/corrupted/tamed
	name = "Tamed Hive"
	internal_faction = FACTION_XENOMORPH_TAMED
	faction_number = SET_FACTION_HIVE_TAMED

	prefix = "Tamed "
	color = "#80ff80"

	dynamic_evolution = FALSE
	allow_no_queen_actions = TRUE
	allow_queen_evolve = FALSE
	ignore_slots = TRUE

/datum/faction_status/xeno/corrupted/tamed/New()
	. = ..()
	hive_structures_limit[XENO_STRUCTURE_EGGMORPH] = 0
	hive_structures_limit[XENO_STRUCTURE_EVOPOD] = 0

/datum/faction_status/proc/make_leader(var/mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.stat == DEAD)
		return

	if(leader)
		UnregisterSignal(leader, COMSIG_PARENT_QDELETING)

	leader = H
	RegisterSignal(leader, COMSIG_PARENT_QDELETING, .proc/handle_qdelete)

/datum/faction_status/proc/handle_qdelete(var/mob/living/carbon/human/H)
	SIGNAL_HANDLER

	if(H == leader)
		leader = null

/datum/faction_status/xeno/corrupted/tamed/add_mob(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(leader)
		X.faction = leader.faction

/datum/faction_status/xeno/corrupted/tamed/is_ally(mob/living/carbon/C)
	if(C.faction in allies)
		return TRUE

	if(C.faction == src)
		return TRUE

	return ..()
