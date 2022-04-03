///////////////////////
//TACMAP INITIAL INFO//
///////////////////////
/datum/tacmap
	var/processing = FALSE

/datum/tacmap/New()
	..()
	start_processing()

/datum/tacmap/proc/start_processing()
	return

/datum/tacmap/proc/stop_processing()
	return

/datum/tacmap/process()//If you dont use process why are you here
	return

/datum/tacmap/proc/tacmap_zlevel(var/zlevel, var/map_type)
	if(is_ground_level(zlevel) && map_type == GROUND_MAP)
		return TRUE
	else if(is_mainship_level(zlevel) && map_type == SHIP_MAP)
		return TRUE
	return FALSE

/datum/tacmap/proc/facton_check(var/mob/living/carbon/M, var/datum/faction_status/faction)
	if(M.faction == faction || M.faction in faction.allies)
		return TRUE
	return FALSE


///////////////////////////
//TACMAP PROCESSING DATUM//
///////////////////////////
/datum/tacmap/tacmap_info
	var/list/datum/tacmap/map_datum/tacmap = list()
	var/datum/faction_status/faction
	var/list/datum/tacmap/tacmap_scan_info/tacmap_scan_info = list()
	var/datum/tacmap/tacmap_overlay/tacmap_overlays

	var/list/overlays_to_add = list()
	var/list/atom/processing_mapview_machines

	var/icon/minimap_overlay //to safety Ho, ho, ho. No.

/datum/tacmap/tacmap_info/New(datum/faction_status/faction_get)
	faction = faction_get

	SSmapview.mapviews["[faction.internal_faction]"] = src

	if(length(processing_mapview_machines))
		start_processing()

/datum/tacmap/tacmap_info/proc/load_tacmaps()
	set waitfor=0
	WAIT_MAPVIEW_READY

	tacmap_overlays = SSmapview.map_overlay

	for(var/i in ALL_MAPTYPES)
		overlays_to_add += i
		var/datum/tacmap/map_datum/map = SSmapview.maps_generated[i]
		tacmap[i] = map
		var/datum/tacmap/tacmap_scan_info/generate_scan = new
		generate_scan.tacmap_info = src
		generate_scan.map_datum = map
		tacmap_scan_info += generate_scan

/datum/tacmap/tacmap_info/process()
	overlays_to_add = list()
	for(var/i in ALL_MAPTYPES)
		overlays_to_add += i
	for(var/list/i in tacmap)
		var/datum/tacmap/map_datum/map_datum = i[2]
		map_allies(map_datum.map_type)
		additional_draw(map_datum.map_type)
		enemy_draw(map_datum.map_type)

	for(var/list/i in tacmap)
		var/map_name = i[1]
		var/icon/map = tacmap[map_name].minimap
		for(var/datum/tacmap/tacmap_overlay/mob/mob_datum in overlays_to_add[map_name])
			var/icon/overlay = mob_datum
			map.Blend(overlay,ICON_OVERLAY)
		minimap_overlay[map_name] = map

	SEND_SIGNAL(processing_mapview_machines, COMSIG_MAPVIEW_UPDATE, overlay_tacmap())

/datum/tacmap/tacmap_info/proc/connect_to_machine(var/machine)
	addToListNoDupe(processing_mapview_machines, machine)
	start_processing()
	RegisterSignal(machine, COMSIG_MAPVIEW_MACHINE_HANDLE, .proc/disconnect_from_machine, machine)

/datum/tacmap/tacmap_info/proc/disconnect_from_machine(var/machine)
	SIGNAL_HANDLER
	processing_mapview_machines -= machine
	if(!length(processing_mapview_machines))
		stop_processing()

/datum/tacmap/tacmap_info/start_processing()
	if(!processing)
		processing = TRUE
		addToListNoDupe(SSmapview.to_run, src)
		for(var/datum/tacmap/tacmap_scan_info/scans in tacmap_scan_info)
			addToListNoDupe(SSmapview.to_run, scans)

/datum/tacmap/tacmap_info/stop_processing()
	if(processing)
		processing = FALSE
		SSmapview.to_run -= src
		for(var/datum/tacmap/tacmap_scan_info/scans in tacmap_scan_info)
			SSmapview.to_run -= scans

/datum/tacmap/tacmap_info/proc/map_allies(var/minimap)
	set waitfor = 0
	for(var/mob/living/carbon/M as anything in tacmap_overlays.mobs)
		if(facton_check(M, faction) && tacmap_zlevel(M.z, minimap))
			var/icon/get_icon = tacmap_overlays.mobs[M].icon
			get_icon += M.faction.faction_color
			overlays_to_add[minimap] += list(tacmap_overlays.mobs[M])

/datum/tacmap/tacmap_info/proc/enemy_draw(var/minimap)
	set waitfor = 0
	for(var/mob/living/carbon/M as anything in tacmap_overlays.mobs)
		if(!facton_check(M, faction) && tacmap_zlevel(M.z, minimap))
			continue
		if(LAZYISIN(overlays_to_add[minimap].icon[M], tacmap_overlays.mobs[M].icon))
			continue

		var/turf/T = get_turf(M)
		for(var/mob/living/carbon/F in range(F.sensor_radius, T))
			if(!facton_check(F))
				continue
			var/icon/get_icon = tacmap_overlays.mobs[M].icon
			get_icon += M.faction.faction_color

			overlays_to_add[minimap] += list(tacmap_overlays.mobs[M])

/datum/tacmap/tacmap_info/proc/additional_draw(var/minimap)
	set waitfor = 0
	return

/datum/tacmap/tacmap_info/proc/overlay_tacmap(var/tacmap_to_overlay)
	return minimap_overlay[tacmap_to_overlay]

/datum/tacmap/tacmap_info/proc/change_mapview(var/mob/usr)
	var/list/map_to_take
	for(var/list/i in tacmap)
		var/datum/tacmap/map_datum/tacmap = i[2]
		map_to_take += list("[tacmap.name]" = tacmap.map_type)
	var/tacmap_type = tgui_input_list(usr, "TACMAP", "Select Location", map_to_take)
	if(tacmap_type)
		return tacmap_type

/proc/update_mapview(var/datum/tacmap/tacmap_info/tacmap_info, var/mob/mapviewer, var/minimap_name, var/map_type, var/icon/O)
	if(O)
		mapviewer << browse_rsc(O, "minimap.png")
		show_browser(mapviewer, "<img src=minimap.png>", minimap_name, "minimap", "size=[(tacmap_info.tacmap[map_type].sizes[1].x*2)+50]x[(tacmap_info.tacmap[map_type].sizes[2].y*2)+50]", closeref = src)