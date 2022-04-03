#define WAIT_MAPVIEW_READY while(!SSmapview.ready) {stoplag();}

SUBSYSTEM_DEF(mapview)
	name          = "Mapview"
	wait          = 2 SECONDS
	flags         = SS_POST_FIRE_TIMING | SS_DISABLE_FOR_TESTING
	runlevels     = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority      = SS_PRIORITY_MAPVIEW
	init_order    = SS_INIT_MAPVIEW
	var/ready = FALSE
	var/updated = FALSE
	var/runing = FALSE
	var/datum/tacmap/tacmap_overlay/map_overlay = new()
	var/list/mobs_last_update
	var/list/datum/tacmap/map_datum/maps_generated = list()
	var/list/scans = list()
	var/list/overlays = list()
	var/list/mapviews = list()
	var/list/to_run = list()
	var/list/currentrun

/datum/controller/subsystem/mapview/Initialize(start_timeofday)
	RegisterSignal(SSdcs, COMSIG_GLOB_MODE_PRESETUP, .proc/pre_round_start)
	return ..()

/datum/controller/subsystem/mapview/stat_entry(msg)
	if(runing)
		msg = "M:[length(maps_generated)]|V:[length(mapviews)]|O:[length(overlays)]|S:[length(scans)]"
	else
		msg = "OFFLINE"
	return ..()

/datum/controller/subsystem/mapview/proc/pre_round_start()
	SIGNAL_HANDLER
	for(var/i in ALL_MAPTYPES)
		var/datum/tacmap/map_datum/map_datum = new()
		map_datum.map_type = i
		map_datum.name = SSmapping.configs[i].map_name
		map_datum.generate_tacmap()
		maps_generated[i] = map_datum
	var/list/factions = SET_FACTION_LIST_ALL
	for(var/faction_get in factions)
		var/datum/faction_status/faction = GLOB.faction_datum[faction_get]
		var/datum/tacmap/tacmap_info/tacmap_info = new(faction)
		tacmap_info.load_tacmaps()
	sleep(10)
	runing = TRUE
	ready = TRUE

/datum/controller/subsystem/mapview/fire(resumed = FALSE)
	if(!ready || !RoleAuthority || !runing)
		return
	if(!resumed)
		currentrun = list()
		currentrun += to_run
		updated = FALSE

	if(mobs_last_update != GLOB.living_mob_list)
		for(var/mob/living/mob in GLOB.living_mob_list - mobs_last_update)
			map_overlay.add_mob(mob)
		mobs_last_update = GLOB.living_mob_list

	while(length(currentrun))
		var/datum/tacmap/tc = currentrun[currentrun.len]
		currentrun.len--

		tc.process()

		if (MC_TICK_CHECK)
			return
