/obj/structure/machinery/computer/shuttle
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_state = "syndishuttle"
	req_access = list( )
//	interaction_flags = INTERACT_MACHINE_TGUI
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled

/obj/structure/machinery/computer/shuttle/update_icon()
	icon_state = initial(icon_state)

// Placeholder FIXME
/obj/structure/machinery/computer/shuttle/attack_hand(mob/user)
	if(user?.stat)
		return
	tgui_interact(user)

/obj/structure/machinery/computer/shuttle/attack_alien(mob/user)
	if(!isXenoQueen(user))
		return
	return attack_hand(user)

/obj/structure/machinery/computer/shuttle/tgui_interact(mob/user)
	. = ..()
	var/dat
	if(!ishuman(user))
		dat = xeno_menus(user)
		show_browser(user, dat, "Strange Console", "Strange Console", "size=300x200")
		return

	var/list/options = valid_destinations()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			destination_found = TRUE
			dat += "<A href='?src=[REF(src)];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"
			if(admin_controlled)
				dat += "Authorized personnel only<br>"
				dat += "<A href='?src=[REF(src)];request=1]'>Request Authorization</A><br>"
	show_browser(user, dat, M.name, M.name, "size=300x200")

/obj/structure/machinery/computer/shuttle/proc/valid_destinations()
	return params2list(possible_destinations)

/obj/structure/machinery/computer/shuttle/proc/xeno_menus(mob/user)
	return

/obj/structure/machinery/computer/shuttle/inoperable()
	return FALSE

/obj/structure/machinery/computer/shuttle/Topic(href, href_list)
	..() // Dumb machinery

	if(!isXenoQueen(usr) && !allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return TRUE
	else if(isXenoQueen(usr))
		return

	if(href_list["move"])
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
//		if(!(M.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
//			to_chat(usr, "<span class='warning'>The engines are still refueling.</span>")
//			return TRUE
		if(!M.can_move_topic(usr))
			return TRUE
		if(!(href_list["move"] in valid_destinations()))
			log_admin("[key_name(usr)] may be attempting a href dock exploit on [src] with target location \"[href_list["move"]]\"")
//			message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href dock exploit on [src] with target location \"[href_list["move"]]\"")
			return TRUE
		var/previous_status = M.mode
		log_game("[key_name(usr)] has sent the shuttle [M] to [href_list["move"]]")
		switch(SSshuttle.moveShuttle(shuttleId, href_list["move"], 1))
			if(0)
				if(previous_status != SHUTTLE_IDLE)
					visible_message("<span class='notice'>Destination updated, recalculating route.</span>")
				else
					visible_message("<span class='notice'>Shuttle departing. Please stand away from the doors.</span>")
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
				return TRUE
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
				return TRUE

/obj/structure/machinery/computer/shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id

/obj/structure/machinery/computer/shuttle/dropship
	density = TRUE
	icon_state = "shuttle"
	unacidable = TRUE
	indestructible = TRUE

/obj/structure/machinery/computer/shuttle/dropship/valid_destinations()
	. = ..()
	.[shuttleId + "_dock"] = TRUE
	// i fooked up
	var/obj/structure/machinery/computer/shuttle/dropship/ground/GC
	GC = SSticker.mode?.active_lz
	if(!GC) return
	var/secondary
	switch(GC.lz_id)
		if("lz2") secondary = "lz1"
		if("lz1") secondary = "lz2"
	if(shuttleId == "rasputin")
		.[GC.lz_id] = TRUE
	else
		.[secondary] = TRUE

/obj/structure/machinery/computer/shuttle/dropship/Topic(href, href_list)
	. = ..()
	if(.) return
	if(href_list["IAMTHEQUEEN"])
		if(isXenoQueen(usr))
			queen_special(usr)

/obj/structure/machinery/computer/shuttle/dropship/xeno_menus(mob/user)
	if(SSticker.mode?.active_lz == src && isXenoQueen(user))
		return "<A href='?src=[REF(src)];IAMTHEQUEEN=1]'>What does this button do?</A><br>"

/obj/structure/machinery/computer/shuttle/dropship/proc/queen_special(mob/user)
	return

/obj/structure/machinery/computer/shuttle/dropship/ground
	name = "Dropship Remote Control"
	var/lz_id
	var/lz_name

/obj/structure/machinery/computer/shuttle/dropship/ground/queen_special(mob/user)
	if(!SSticker.mode?.active_lz == src)
		to_chat(usr, SPAN_BOLDANNOUNCE("Wrong nest! You can't use this metal bird!"))
		return
	if(!SSshuttle.moveShuttle(shuttleId, lz_id, TRUE))
		GLOB.shuttle_lockdown[shuttleId] = world.time + 5 MINUTES
		to_chat(usr, SPAN_BOLDANNOUNCE("The metal bird is on its way!"))
	else to_chat(usr, SPAN_XENOHIGHDANGER("The metal bird is not responding!"))

/obj/structure/machinery/computer/shuttle/dropship/ground/attack_hand(mob/user)
	autolink_dropship()
	return ..()
/obj/structure/machinery/computer/shuttle/dropship/ground/tgui_interact(mob/user)
	autolink_dropship()
	return ..()
/obj/structure/machinery/computer/shuttle/dropship/ground/Topic(href, href_list)
	autolink_dropship()
	return ..()

/obj/structure/machinery/computer/shuttle/dropship/ground/proc/autolink_dropship(mob/user)
	if(shuttleId) return
	if(isnull(SSticker.mode?.active_lz))
		return
	if(SSticker.mode.active_lz == src)
		shuttleId = "rasputin"
	else shuttleId = "drop_pod"

/obj/structure/machinery/computer/shuttle/dropship/ground/lz1
	lz_id = "lz1"
	lz_name = "Landing Zone 1"

/obj/structure/machinery/computer/shuttle/dropship/ground/lz2
	lz_id = "lz2"
	lz_name = "Landing Zone 2"

/obj/structure/machinery/computer/shuttle/dropship/onboard
	icon_state = "syndishuttle"

/obj/structure/machinery/computer/shuttle/dropship/onboard/valid_destinations()
	if(!isXenoQueen(usr) && GLOB.shuttle_lockdown[shuttleId] && GLOB.shuttle_lockdown[shuttleId] > world.time)
		return list()
	return ..()

/obj/structure/machinery/computer/shuttle/dropship/onboard/xeno_menus(mob/user)
	if(SSticker.mode?.active_lz?.shuttleId == src.shuttleId && isXenoQueen(user))
		return "<A href='?src=[REF(src)];IAMTHEQUEEN=1]'>What if I press this?</A><br>"

/obj/structure/machinery/computer/shuttle/dropship/onboard/queen_special(mob/user)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle) return
	if(shuttle.crashing || shuttle.crash_landing == 1)
		to_chat(user, SPAN_XENOHIGHDANGER("Shuttle is already on a crash course!"))
		return
	if(shuttle.crash_landing == 2)
		to_chat(user, SPAN_XENOHIGHDANGER("This thing is completely busted!"))
		return

	GLOB.shuttle_lockdown[shuttleId] = world.time + 15 MINUTES
	var/mob/living/carbon/Xenomorph/Queen/Q = user

	// Check for onboard xenos, so the Queen doesn't leave most of her hive behind.
	var/count = Q.count_hivemember_same_area()

	// Check if at least half of the hive is onboard. If not, we don't launch.
	if(count < length(Q.hive.totalXenos) * 0.5)
		to_chat(Q, SPAN_WARNING("More than half of your hive is not on board. Don't leave without them!"))
		return

	// Allow the queen to choose the ship section to crash into
	var/crash_target = tgui_input_list(usr, "Choose a ship section to target","Hijack", GLOB.shuttle_crash_sections + list("Cancel"))
	if(crash_target == "Cancel")
		return

	var/i = alert("Warning: Once you launch the shuttle you will not be able to bring it back. Confirm anyways?", "WARNING", "Yes", "No")
	if(i == "No")
		return

	if(!shuttle.crashShuttle(crash_target))
		to_chat(user, SPAN_XENOHIGHDANGER("Internal error. Maybe try another section?"))
	else
		addtimer(CALLBACK(src, .proc/handle_hive_crash, Q), 15 SECONDS)

// Yes, this is very yolo
/obj/structure/machinery/computer/shuttle/dropship/onboard/proc/handle_hive_crash(mob/living/carbon/Xenomorph/Queen/Q)
	Q.count_niche_stat(STATISTICS_NICHE_FLIGHT)
	if(Q.hive)
		Q.hive.abandon_on_hijack()
		Q.hive.hijack_pooled_surge = TRUE
