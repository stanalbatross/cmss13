var/global/datum/controller/subsystem/evacuation/EvacuationAuthority //This is initited elsewhere so that the world has a chance to load in.

SUBSYSTEM_DEF(evacuation)
	name = "Evacuation"
	flags = SS_NO_INIT|SS_TICKER

	var/passengers
	var/list/pod_list = list()
	var/list/pod_list_second = list()
	var/obj/docking_port/mobile/escape_pod/P
	var/evac_time	//Time the evacuation was initiated.
	var/evac_status = EVACUATION_STATUS_STANDING_BY //What it's doing now? It can be standing by, getting ready to launch, or finished.

	var/obj/structure/machinery/self_destruct/console/dest_master //The main console that does the brunt of the work.
	var/dest_rods[] //Slave devices to make the explosion work.
	var/dest_cooldown //How long it takes between rods, determined by the amount of total rods present.
	var/dest_index = 1	//What rod the thing is currently on.
	var/dest_status = NUKE_EXPLOSION_INACTIVE
	var/dest_started_at = 0

	var/flags_scuttle = NO_FLAGS

	var/defcon_console_loc = 0

/datum/controller/subsystem/evacuation/proc/prepare()
	dest_master = locate()
	if(!dest_master)
		log_debug("ERROR CODE SD1: could not find master self-destruct console")
		to_world(SPAN_DEBUG("ERROR CODE SD1: could not find master self-destruct console"))
		return FALSE
	dest_rods = new
	for(var/obj/structure/machinery/self_destruct/rod/I in dest_master.loc.loc) dest_rods += I
	if(!dest_rods.len)
		log_debug("ERROR CODE SD2: could not find any self destruct rods")
		to_world(SPAN_DEBUG("ERROR CODE SD2: could not find any self destruct rods"))
		qdel(dest_master)
		dest_master = null
		return FALSE
	dest_cooldown = SELF_DESTRUCT_ROD_STARTUP_TIME / dest_rods.len
	dest_master.desc = "Главная панель управления системой самоуничтожения. Она требует очень малого участия пользователя, но окончательный механизм безопасности разблокируется вручную.\nПосле начальной последовательности запуска, [dest_rods.len] управляющие стержни должны быть поставлены в режим готовности, после чего вручную переключается выключатель детонации."

/datum/controller/subsystem/evacuation/fire()
	switch(evac_status)
		if(EVACUATION_STATUS_IN_PROGRESS)
			for(var/i in pod_list)
				var/obj/docking_port/mobile/escape_pod/P = i
				P.launch()
			if(!pod_list)
				announce_evac_completion()

	switch(dest_status)
		if(NUKE_EXPLOSION_ACTIVE)
			initiate_self_destruct()

/datum/controller/subsystem/evacuation/proc/get_affected_zlevels() //This proc returns the ship's z level list (or whatever specified), when an evac/self destruct happens.
	if(dest_status < NUKE_EXPLOSION_IN_PROGRESS && evac_status == EVACUATION_STATUS_COMPLETE) //Nuke is not in progress and evacuation finished, end the round on ship and low orbit (dropships in transit) only.
		. = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_LOWORBIT))
	else
		if(SSticker.mode && SSticker.mode.is_in_endgame)
			. = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_LOWORBIT))

/datum/controller/subsystem/evacuation/proc/initiate_evacuation(var/force=0) //Begins the evacuation procedure.
	if(force || (evac_status == EVACUATION_STATUS_STANDING_BY && !(flags_scuttle & FLAGS_EVACUATION_DENY)))
		enter_allowed = 0 //No joining during evac.
		evac_time = world.time
		evac_status = EVACUATION_STATUS_INITIATING
		ai_announcement("Внимание. Чрезвычайная ситуация. Всему персоналу немедленно покинуть корабль. Вы имеете [round(EVACUATION_ESTIMATE_DEPARTURE/60,1)] минут до отлета капсул, после чего все вторичные системы выключатся.", 'sound/AI/evacuate.ogg')
		xeno_message("Волна адреналина прокатилась по улью. Существа из плоти пытаются сбежать!")
		for(var/obj/structure/machinery/status_display/SD in machines)
			if(is_mainship_level(SD.z))
				SD.set_picture("evac")
		pod_list = SSshuttle.escape_pods.Copy()
		for(var/i in pod_list)
			var/obj/docking_port/mobile/escape_pod/P = i
			P.prep_for_launch()
		process_evacuation()
		return TRUE

/datum/controller/subsystem/evacuation/proc/cancel_evacuation() //Cancels the evac procedure. Useful if admins do not want the marines leaving.
	if(evac_status == EVACUATION_STATUS_INITIATING)
		enter_allowed = 1
		evac_time = null
		evac_status = EVACUATION_STATUS_STANDING_BY
		ai_announcement("Эвакуация отменена.", 'sound/AI/evacuate_cancelled.ogg')
		if(get_security_level() == "red")
			for(var/obj/structure/machinery/status_display/SD in machines)
				if(is_mainship_level(SD.z))
					SD.set_picture("redalert")
		for(var/i in pod_list)
			var/obj/docking_port/mobile/escape_pod/P = i
			P.unprep_for_launch()
		return TRUE

/datum/controller/subsystem/evacuation/proc/begin_launch() //Launches the pods.
	if(evac_status == EVACUATION_STATUS_INITIATING)
		evac_status = EVACUATION_STATUS_IN_PROGRESS //Cannot cancel at this point. All shuttles are off.
		spawn()
			ai_announcement("ВНИМАНИЕ: Приказ о эвакуации приведен в действие. Запуск спасательных капсул.", 'sound/AI/evacuation_confirmed.ogg')
			fire()
			sleep(300)
			pod_list_second = SSshuttle.escape_pods.Copy()
			for(var/i in pod_list_second)
				var/obj/docking_port/mobile/escape_pod/escape_lifeboat/LB = i
				LB.open()
			ai_announcement("ВНИМАНИЕ: До отбытия шлюпок мение 10 минут, всему оставшемуся экипажу занять спасательные шлюпки, процедура подготовки почти закончена!")
			sleep(6000)
			for(var/i in pod_list_second)
				var/obj/docking_port/mobile/escape_pod/escape_lifeboat/LB = i
				LB.ready_up()
			sleep(1000)
			power_failure()
			evac_status = EVACUATION_STATUS_COMPLETE
		return TRUE

/datum/controller/subsystem/evacuation/proc/announce_evac_completion()
	var/obj/docking_port/mobile/escape_pod/P
	ai_announcement("ВНИМАНИЕ: Эвакуация спасательных капсул закончена. Исходящие сигналы жизни: [P.passengers ? P.passengers  : "отсутсвуют"].", 'sound/AI/evacuation_complete.ogg')
	evac_status = EVACUATION_STATUS_COMPLETE

datum/controller/subsystem/evacuation/proc/process_evacuation() //Process the timer.
	set background = 1

	spawn while(evac_status == EVACUATION_STATUS_INITIATING) //If it's not departing, no need to process.
		if(world.time >= evac_time + EVACUATION_AUTOMATIC_DEPARTURE) begin_launch()
		sleep(10) //One second.

/datum/controller/subsystem/evacuation/proc/get_status_panel_eta()
	switch(evac_status)
		if(EVACUATION_STATUS_STANDING_BY) . = "Ожидание"
		if(EVACUATION_STATUS_INITIATING)
			var/eta = EVACUATION_ESTIMATE_DEPARTURE
			. = "[(eta / 60) % 60]:[add_zero(num2text(eta % 60), 2)]"
		if(EVACUATION_STATUS_IN_PROGRESS) . = "СЕЙЧАС"
		if(EVACUATION_STATUS_COMPLETE) . = "Корабль Покинут"

//=========================================================================================
//===================================SELF DESTRUCT=========================================
//=========================================================================================

/datum/controller/subsystem/evacuation/proc/enable_self_destruct(var/force=0)
	if(force || (dest_status == NUKE_EXPLOSION_INACTIVE && !(flags_scuttle & FLAGS_SELF_DESTRUCT_DENY)))
		dest_status = NUKE_EXPLOSION_ACTIVE
		dest_master.lock_or_unlock(0)
		dest_started_at = world.time
		set_security_level(SEC_LEVEL_DELTA)
		spawn(0)
			for(var/obj/structure/machinery/door/poddoor/railing/R in machines)
				if(R.id == "sd1")
					INVOKE_ASYNC(R, /obj/structure/machinery/door/poddoor/railing/.proc/open)
			for(var/obj/structure/machinery/door/poddoor/almayer/S in machines)
				if(S.id == "sd_lockdown")
					INVOKE_ASYNC(S, /obj/structure/machinery/door/poddoor/almayer/.proc/open)
		return TRUE

//Override is for admins bypassing normal player restrictions.
/datum/controller/subsystem/evacuation/proc/cancel_self_destruct(override)
	if(dest_status == NUKE_EXPLOSION_ACTIVE)
		var/obj/structure/machinery/self_destruct/rod/I
		var/i
		for(i in EvacuationAuthority.dest_rods)
			I = i
			if(I.active_state == SELF_DESTRUCT_MACHINE_ARMED && !override)
				dest_master.state(SPAN_WARNING("ПРЕДУПРЕЖДЕНИЕ: Невозможно отменить детонацию. Пожалуйста деактивируйте все управляющие стержни."))
				return FALSE

		dest_status = NUKE_EXPLOSION_INACTIVE
		dest_master.in_progress = 1
		dest_started_at = 0
		for(i in dest_rods)
			I = i
			if(I.active_state == SELF_DESTRUCT_MACHINE_ACTIVE || (I.active_state == SELF_DESTRUCT_MACHINE_ARMED && override)) I.lock_or_unlock(1)
		dest_master.lock_or_unlock(1)
		dest_index = 1
		ai_announcement("Система аварийного самоуничтожения была деактивирована.", 'sound/AI/selfdestruct_deactivated.ogg')
		if(evac_status == EVACUATION_STATUS_STANDING_BY) //the evac has also been cancelled or was never started.
			set_security_level(SEC_LEVEL_RED, TRUE) //both SD and evac are inactive, lowering the security level.
		return TRUE

/datum/controller/subsystem/evacuation/proc/initiate_self_destruct(override)
	if(dest_status < NUKE_EXPLOSION_IN_PROGRESS)
		var/obj/structure/machinery/self_destruct/rod/I
		var/i
		for(i in dest_rods)
			I = i
			if(I.active_state != SELF_DESTRUCT_MACHINE_ARMED && !override)
				dest_master.state(SPAN_WARNING("ПРЕДУПРЕЖДЕНИЕ: Невозможно запустить детонацию. Пожалуйста, активируйте все управляющие стержни."))
				return FALSE
		dest_master.in_progress = !dest_master.in_progress
		for(i in EvacuationAuthority.dest_rods)
			I = i
			I.in_progress = 1
		ai_announcement("ОПАСНОСТЬ. ОПАСНОСТЬ. Система самоуничтожения активирована. ОПАСНОСТЬ. ОПАСНОСТЬ. Самоуничтожение выполняется. ОПАСНОСТЬ. ОПАСНОСТЬ.")
		trigger_self_destruct(,,override)
		return TRUE

/datum/controller/subsystem/evacuation/proc/trigger_self_destruct(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP), origin = dest_master, override = FALSE, end_type = NUKE_EXPLOSION_FINISHED, play_anim = TRUE, end_round = TRUE)
	set waitfor = 0
	if(dest_status < NUKE_EXPLOSION_IN_PROGRESS) //One more check for good measure, in case it's triggered through a bomb instead of the destruct mechanism/admin panel.
		enter_allowed = 0 //Do not want baldies spawning in as everything is exploding.
		dest_status = NUKE_EXPLOSION_IN_PROGRESS
		playsound(origin, 'sound/machines/Alarm.ogg', 75, 0, 30)
		world << pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg')

		var/ship_status = 1
		for(var/i in z_levels)
			if(is_mainship_level(i))
				ship_status = 0 //Destroyed.
			break

		var/L1[] = new //Everyone who will be destroyed on the zlevel(s).
		var/L2[] = new //Everyone who only needs to see the cinematic.
		var/mob/M
		var/turf/T
		for(M in GLOB.player_list) //This only does something cool for the people about to die, but should prove pretty interesting.
			if(!M || !M.loc) continue //In case something changes when we sleep().
			if(M.stat == DEAD)
				L2 |= M
			else if(M.z in z_levels)
				L1 |= M
				shake_camera(M, 110, 4)


		sleep(100)
		/*Hardcoded for now, since this was never really used for anything else.
		Would ideally use a better system for showing cutscenes.*/
		var/obj/screen/cinematic/explosion/C = new

		if(play_anim)
			for(M in L1 + L2)
				if(M && M.loc && M.client)
					M.client.screen |= C //They may have disconnected in the mean time.

			sleep(15) //Extra 1.5 seconds to look at the ship.
			flick(override ? "intro_override" : "intro_nuke", C)
		sleep(35)
		for(M in L1)
			if(M && M.loc) //Who knows, maybe they escaped, or don't exist anymore.
				T = get_turf(M)
				if(T.z in z_levels)
					if(istype(M.loc, /obj/structure/closet/secure_closet/freezer/fridge))
						continue
					M.death(create_cause_data("самоуничтожения корабля"))
				else
					if(play_anim)
						M.client.screen -= C //those who managed to escape the z level at last second shouldn't have their view obstructed.
		if(play_anim)
			flick(ship_status ? "ship_spared" : "ship_destroyed", C)
			C.icon_state = ship_status ? "summary_spared" : "summary_destroyed"
		world << sound('sound/effects/explosionfar.ogg')

		if(end_round)
			dest_status = end_type

			sleep(5)
			if(SSticker.mode)
				SSticker.mode.check_win()

			if(!SSticker.mode) //Just a safety, just in case a mode isn't running, somehow.
				to_world(SPAN_ROUNDBODY("Рестарт через 30 секунд!"))
				sleep(300)
				log_game("Рестарт из-за самоуничтожения корабля.")
				world.Reboot()
			return TRUE

/datum/controller/subsystem/evacuation/proc/process_self_destruct()
	set background = 1

	spawn while(dest_master && dest_master.loc && dest_master.active_state == SELF_DESTRUCT_MACHINE_ARMED && dest_status == NUKE_EXPLOSION_ACTIVE && dest_index <= dest_rods.len)
		var/obj/structure/machinery/self_destruct/rod/I = dest_rods[dest_index]
		if(world.time >= dest_cooldown + I.activate_time)
			I.lock_or_unlock(0) //Unlock it.
			if(++dest_index <= dest_rods.len)
				I = dest_rods[dest_index]//Start the next sequence.
				I.activate_time = world.time
		sleep(10) //Checks every second. Could integrate into another controller for better tracking.