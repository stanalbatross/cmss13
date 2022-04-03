////////////////////////////////
//PROCESSING OVERLAYS FOR MAPS//
////////////////////////////////
/datum/tacmap/tacmap_overlay
	var/list/datum/tacmap/tacmap_overlay/obj/objects = list()
	var/list/datum/tacmap/tacmap_overlay/mob/mobs = list()

	var/icon/icon

/datum/tacmap/tacmap_overlay/proc/add_obj(var/obj/obj_ref)
	if(!objects[obj_ref])
		var/datum/tacmap/tacmap_overlay/obj/new_objsect = new(obj_ref)
		new_objsect.icon = new()
		new_objsect.icon.DrawBox("white",obj_ref.x,obj_ref.y)
		objects[obj_ref] += new_objsect

/datum/tacmap/tacmap_overlay/proc/remove_obj(var/obj/obj_ref)
	if(objects[obj_ref])
		objects[obj_ref].stop_processing()
		qdel(objects[obj_ref])

/datum/tacmap/tacmap_overlay/proc/add_mob(var/mob/living/carbon/mob_ref)
	if(!mobs[mob_ref])
		var/datum/tacmap/tacmap_overlay/mob/new_mob = new(mob_ref)
		new_mob.icon = new()
		new_mob.icon.DrawBox("white",mob_ref.x,mob_ref.y)
		mobs[mob_ref] += new_mob

/datum/tacmap/tacmap_overlay/proc/remove_mob(var/mob/living/carbon/mob_ref)
	if(mobs[mob_ref])
		mobs[mob_ref].stop_processing()
		qdel(mobs[mob_ref])

//OBJECTS
/datum/tacmap/tacmap_overlay/obj
	var/obj/obj_ref

/datum/tacmap/tacmap_overlay/obj/New(obj/obj_ref_new)
	..()
	obj_ref = obj_ref_new
	addToListNoDupe(SSmapview.overlays, src)
	start_processing()

/datum/tacmap/tacmap_overlay/obj/start_processing()
	if(!processing)
		processing = TRUE
		addToListNoDupe(SSmapview.to_run, src)

/datum/tacmap/tacmap_overlay/obj/stop_processing()
	if(processing)
		processing = FALSE
		SSmapview.to_run -= src

//MOBS
/datum/tacmap/tacmap_overlay/mob
	var/mob/living/carbon/mob_ref

/datum/tacmap/tacmap_overlay/mob/New(mob/living/carbon/mob)
	..()
	mob_ref = mob
	addToListNoDupe(SSmapview.overlays, src)
	start_processing()

/datum/tacmap/tacmap_overlay/mob/start_processing()
	if(!processing)
		processing = TRUE
		addToListNoDupe(SSmapview.to_run, src)

/datum/tacmap/tacmap_overlay/mob/stop_processing()
	if(processing)
		processing = FALSE
		SSmapview.to_run -= src

/datum/tacmap/tacmap_overlay/mob/process()//update locs of overlay instead of make new icon
	if(!mob_ref || mob_ref.stat == DEAD)
		stop_processing()
		qdel(src)
	var/y_new = mob_ref.y - icon.Height()
	var/x_new = mob_ref.x - icon.Width()
	if(y_new == 0 || x_new == 0)
		return
	icon.Shift(NORTH, y_new)
	icon.Shift(EAST, x_new)


//////////////////////////
//MAP SCA'M, FREE VISION//
//////////////////////////
/datum/tacmap/tacmap_scan_info
	var/datum/tacmap/tacmap_info/tacmap_info
	var/datum/tacmap/map_datum/map_datum
	var/list/locs = list(0, 0)
	var/cooldown = 4 SECONDS
	var/size = 8
	var/active_scan_cd = 5 SECONDS

/datum/tacmap/tacmap_scan_info/New()
	locs[1] = size

	addToListNoDupe(SSmapview.scans, src)

	load_tacmaps()


/datum/tacmap/tacmap_scan_info/proc/load_tacmaps()
	set waitfor=0
	WAIT_MAPVIEW_READY
	map_datum = SSmapview.maps_generated[GROUND_MAP]

/datum/tacmap/tacmap_scan_info/start_processing()
	if(!processing)
		processing = TRUE
		addToListNoDupe(SSmapview.to_run, src)

/datum/tacmap/tacmap_scan_info/stop_processing()
	if(processing)
		processing = FALSE
		SSmapview.to_run -= src

/datum/tacmap/tacmap_scan_info/process()
	set waitfor = 0
	var/loc_id = 1

	passive_scan()

	spawn(active_scan_cd)
		active_scan()
		for(var/loc in locs)
			if(locs[loc_id] > map_datum.sizes[loc_id])
				locs[loc_id] -= map_datum.sizes[loc_id]
			else
				locs[loc_id] += 1
			loc_id++

/datum/tacmap/tacmap_scan_info/proc/active_scan()
	set waitfor = 0
	var/minimap = map_datum.map_type
	for(var/mob/living/carbon/M as anything in tacmap_info.tacmap_overlays.mobs)
		if(!facton_check(M, tacmap_info.faction) && tacmap_zlevel(M.z, minimap))
			if(M.loc.x > locs[2] && M.loc.x < locs[1])//get he coordinates, we need in space of scan size x1, x2
				continue
			var/icon/get_icon = tacmap_info.tacmap_overlays.mobs[M].icon
			get_icon += tacmap_info.faction.faction_color
			tacmap_info.overlays_to_add[minimap] += list(tacmap_info.tacmap_overlays.mobs[M])

/datum/tacmap/tacmap_scan_info/proc/passive_scan()
	set waitfor = 0
	var/minimap = map_datum.map_type
	for(var/mob/living/carbon/M as anything in tacmap_info.tacmap_overlays.mobs)
		if(!facton_check(M, tacmap_info.faction) && tacmap_zlevel(M.z, minimap))
			var/area/e_area = get_area(M.loc)
			if(e_area.ceiling > CEILING_PROTECTION_TIER_1)//map only on open sky and under not reinforsed roof
				continue
			var/icon/get_icon = tacmap_info.tacmap_overlays.mobs[M].icon
			get_icon += tacmap_info.faction.faction_color
			tacmap_info.overlays_to_add[minimap] += list(tacmap_info.tacmap_overlays.mobs[M])