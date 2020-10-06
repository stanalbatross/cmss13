//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33
#define FLAG_SHOW_CIC			1
#define FLAG_SHOW_AUXIL_SUPPORT	2
#define FLAG_SHOW_MISC			4
#define FLAG_SHOW_POLICE		8
#define FLAG_SHOW_ENGINEERING	16
#define FLAG_SHOW_REQUISITION	32
#define FLAG_SHOW_MEDICAL		64
#define FLAG_SHOW_MARINES		128
#define FLAG_SHOW_ALL			FLAG_SHOW_CIC|FLAG_SHOW_AUXIL_SUPPORT|FLAG_SHOW_MISC|FLAG_SHOW_POLICE|FLAG_SHOW_ENGINEERING|FLAG_SHOW_REQUISITION|FLAG_SHOW_MEDICAL|FLAG_SHOW_MARINES

/mob/new_player
	var/ready = FALSE
	var/spawning = FALSE//Referenced when you want to delete the new_player later on in the code.

	invisibility = 101

	density = FALSE
	canmove = FALSE
	anchored = TRUE
	universal_speak = TRUE
	stat = DEAD

/mob/new_player/Initialize()
	. = ..()
	if(client)
		client.view = lobby_view_size

/mob/new_player/Destroy()
	if(ready)
		readied_players--

	return ..()

/mob/new_player/verb/new_player_panel()
	set src = usr
	if(client && client.player_entity)
		client.player_entity.update_panel_data(null)
	new_player_panel_proc()


/mob/new_player/proc/new_player_panel_proc(var/refresh = FALSE)
	var/tempnumber = rand(1, 999)
	var/postfix_text = (client.prefs && client.prefs.xeno_postfix) ? ("-"+client.prefs.xeno_postfix) : ""
	var/prefix_text = (client.prefs && client.prefs.xeno_prefix) ? client.prefs.xeno_prefix : "XX"
	var/xeno_text = "[prefix_text]-[tempnumber][postfix_text]"
	var/round_start = !ticker || !ticker.mode || ticker.current_state <= GAME_STATE_PREGAME

	var/output = "<div align='center'>Welcome,"
	output +="<br><b>[(client.prefs && client.prefs.real_name) ? client.prefs.real_name : client.key]</b>"
	output +="<br><b>[xeno_text]</b>"
	output += "<p><a href='byond://?src=\ref[src];lobby_choice=show_preferences'>Setup Character</A></p>"

	output += "<p><a href='byond://?src=\ref[src];lobby_choice=show_playtimes'>View Playtimes</A></p>"

	if(round_start)
		output += "<p>\[ [ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [ready? "<a href='byond://?src=\ref[src];lobby_choice=unready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
		output += "<b>Be Xenomorph:</b> [(client.prefs && (client.prefs.be_special & BE_ALIEN)) ? "Yes" : "No"]"

	else
		output += "<a href='byond://?src=\ref[src];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join'>Join the USCM!</A></p>"
		output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join_xeno'>Join the Hive!</A></p>"
		if(ticker.mode.flags_round_type & MODE_PREDATOR)
			if(ticker.mode.check_predator_late_join(src,0)) output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join_pred'>Join the Hunt!</A></p>"

	output += "<p><a href='byond://?src=\ref[src];lobby_choice=observe'>Observe</A></p>"

	output += "</div>"
	if (refresh)
		close_browser(src, "playersetup")
	show_browser(src, output, null, "playersetup", "size=240x[round_start ? 330 : 380];can_close=0;can_minimize=0")
	return

/mob/new_player/Stat()
	if (!..())
		return 0

	stat("Time:","[worldtime2text()]")
	stat("Map:", "[map_tag]")
	if(!ticker)
		return

	if(ticker.hide_mode)
		stat("Game Mode:", "Colonial Marines")
	else if(ticker.hide_mode == 0)
		stat("Game Mode:", "[master_mode]") // Old setting for showing the game mode

	if(ticker.current_state == GAME_STATE_PREGAME)
		stat("Time To Start:", "[ticker.pregame_timeleft][going ? "" : " (DELAYED)"]")
		stat("Players: [length(player_list)]", "Players Ready: [readied_players]")
		for(var/mob/new_player/player in player_list)
			stat("[player.key]", player.ready ? "(Playing)" : "")

/mob/new_player/Topic(href, href_list[])
	if(!client)	
		return

	switch(href_list["lobby_choice"])
		if("show_preferences")
			client.prefs.ShowChoices(src)
			return 1

		if("show_playtimes")
			if(client.player_data)
				client.player_data.ui_interact(src)
			return 1

		if("ready")
			if( (!ticker || ticker.current_state <= GAME_STATE_PREGAME) && !ready) // Make sure we don't ready up after the round has started
				ready = TRUE
				readied_players++

			new_player_panel_proc()

		if("unready")
			if((!ticker || ticker.current_state <= GAME_STATE_PREGAME) && ready) // Make sure we don't ready up after the round has started
				ready = FALSE
				readied_players--
			
			new_player_panel_proc()

		if("refresh")
			new_player_panel_proc(TRUE)

		if("observe")
			if(alert(src,"Are you sure you wish to observe? When you observe, you will not be able to join as marine. It might also take some time to become a xeno or responder!","Player Setup","Yes","No") == "Yes")
				if(!client)	
					return TRUE
				var/mob/dead/observer/observer = new()
				spawning = TRUE
				observer.started_as_observer = TRUE

				close_spawn_windows()

				var/obj/O = locate("landmark*Observer-Start")
				if(istype(O))
					to_chat(src, SPAN_NOTICE("Now teleporting."))
					observer.loc = O.loc
				else
					to_chat(src, SPAN_DANGER("Could not locate an observer spawn point. Use the Teleport verb to jump to the station map."))
				observer.icon = 'icons/mob/humans/species/r_human.dmi'
				observer.icon_state = "anglo_example"
				observer.alpha = 127

				if(client.prefs.be_random_name)
					client.prefs.real_name = random_name(client.prefs.gender)
				observer.real_name = client.prefs.real_name
				observer.name = observer.real_name

				mind.transfer_to(observer, TRUE)

				if(observer.client)
					observer.client.change_view(world_view_size)
				
				observer.set_huds_from_prefs()

				qdel(src)
				return 1

		if("late_join")

			if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
				to_chat(src, SPAN_WARNING("The round is either not ready, or has already finished..."))
				return

			if(ticker.mode.flags_round_type	& MODE_NO_LATEJOIN)
				to_chat(src, SPAN_WARNING("Sorry, you cannot late join during [ticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible."))
				return

			if(client.prefs.species != "Human")
				if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
					to_chat(src, "You are currently not whitelisted to play [client.prefs.species].")
					return

				var/datum/species/S = all_species[client.prefs.species]
				if(!(S.flags & IS_WHITELISTED))
					to_chat(src, alert("Your current species,[client.prefs.species], is not available for play on the station."))
					return

			LateChoices()

		if("late_join_xeno")
			if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
				to_chat(src, SPAN_WARNING("The round is either not ready, or has already finished..."))
				return

			if(alert(src,"Are you sure you want to attempt joining as a xenomorph?","Confirmation","Yes","No") == "Yes" )
				if(ticker.mode.check_xeno_late_join(src))
					var/mob/new_xeno = ticker.mode.attempt_to_join_as_xeno(src, 0)
					if(new_xeno && !istype(new_xeno, /mob/living/carbon/Xenomorph/Larva))
						ticker.mode.transfer_xeno(src, new_xeno)
						close_spawn_windows()

		if("late_join_pred")
			if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
				to_chat(src, SPAN_WARNING("The round is either not ready, or has already finished..."))
				return

			if(alert(src,"Are you sure you want to attempt joining as a predator?","Confirmation","Yes","No") == "Yes" )
				if(ticker.mode.check_predator_late_join(src,0))
					close_spawn_windows()
					ticker.mode.attempt_to_join_as_predator(src)
				else
					to_chat(src, SPAN_WARNING("You are no longer able to join as predator."))
					new_player_panel()

		if("manifest")
			ViewManifest()

		if("SelectedJob")

			if(!enter_allowed)
				to_chat(usr, SPAN_WARNING("There is an administrative lock on entering the game! (The dropship likely crashed into the Almayer. This should take at most 20 minutes.)"))
				return

			if(client.prefs.species != "Human")
				if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
					to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
					return 0

				var/datum/species/S = all_species[client.prefs.species]
				if(!(S.flags & IS_WHITELISTED))
					to_chat(src, alert("Your current species,[client.prefs.species], is not available for play on the station."))
					return 0

			AttemptLateSpawn(href_list["job_selected"],client.prefs.spawnpoint)
			return

		else
			if(!ready && href_list["preference"])
				if(client) client.prefs.process_link(src, href_list)
			else new_player_panel()

/mob/new_player/proc/AttemptLateSpawn(rank, spawning_at)
	if (src != usr)
		return
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, SPAN_WARNING("The round is either not ready, or has already finished!"))
		return
	if(!enter_allowed)
		to_chat(usr, SPAN_WARNING("There is an administrative lock on entering the game! (The dropship likely crashed into the Almayer. This should take at most 20 minutes.)"))
		return
	if(!RoleAuthority.assign_role(src, RoleAuthority.roles_for_mode[rank], 1))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return

	spawning = TRUE
	close_spawn_windows()

	var/datum/spawnpoint/S //We need to find a spawn location for them.
	var/turf/T
	if(map_tag != MAP_WHISKEY_OUTPOST)
		if(spawning_at) S = spawntypes[spawning_at]
		if(istype(S)) 	T = pick(S.turfs)
		else 			T = pick(latejoin)
	else if (map_tag == MAP_WHISKEY_OUTPOST)
		T = pick(latewhiskey)

	var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
	RoleAuthority.equip_role(character, RoleAuthority.roles_for_mode[rank], T)
	EquipCustomItems(character)

	data_core.manifest_inject(character)
	if(map_tag == MAP_WHISKEY_OUTPOST)
		call(/datum/game_mode/whiskey_outpost/proc/spawn_player)(character)
	ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	ticker.mode.latejoin_tally++

	for(var/datum/squad/sq in RoleAuthority.squads)
		if(sq)
			sq.max_engineers = engi_slot_formula(clients.len)
			sq.max_medics = medic_slot_formula(clients.len)

	if(ticker.mode.latejoin_larva_drop && ticker.mode.latejoin_tally >= ticker.mode.latejoin_larva_drop)
		ticker.mode.latejoin_tally -= ticker.mode.latejoin_larva_drop
		for(var/datum/hive_status/hs in hive_datum)
			if (hs.living_xeno_queen)
				hs.stored_larva++
				hs.hive_ui.update_pooled_larva()

	if(character.mind && character.mind.player_entity)
		var/datum/entity/player_entity/player = character.mind.player_entity
		if(player.get_playtime(STATISTIC_HUMAN) == 0 && player.get_playtime(STATISTIC_XENO) == 0)
			msg_admin_niche("NEW PLAYER: <b>[key_name(character, 1, 1, 0)] (<A HREF='?_src_=admin_holder;ahelp=adminmoreinfo;extra=\ref[character]'>?</A>)</b>. IP: [character.lastKnownIP], CID: [character.computer_id]")

	qdel(src)


/mob/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = "<html><body onselectstart='return false;'><center>"
	dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

	if(EvacuationAuthority)
		switch(EvacuationAuthority.evac_status)
			if(EVACUATION_STATUS_INITIATING) dat += "<font color='red'><b>The [MAIN_SHIP_NAME] is being evacuated.</b></font><br>"
			if(EVACUATION_STATUS_COMPLETE) dat += "<font color='red'>The [MAIN_SHIP_NAME] has undergone evacuation.</font><br>"

	dat += "Choose from the following open positions:<br>"
	var/roles_show = FLAG_SHOW_ALL

	var/datum/job/J
	var/i
	for(i in RoleAuthority.roles_for_mode)
		J = RoleAuthority.roles_for_mode[i]
		if(!RoleAuthority.check_role_entry(src, J, 1)) continue
		var/active = 0
		// Only players with the job assigned and AFK for less than 10 minutes count as active
		for(var/mob/M in player_list)
			if(M.client && M.job == J.title && M.client.inactivity <= 10 * 60 * 10)
				active++
		if(roles_show & FLAG_SHOW_CIC && ROLES_CIC.Find(J.title))
			dat += "Command:<br>"
			roles_show ^= FLAG_SHOW_CIC

		else if(roles_show & FLAG_SHOW_AUXIL_SUPPORT && ROLES_AUXIL_SUPPORT.Find(J.title))
			dat += "<hr>Auxiliary Combat Support:<br>"
			roles_show ^= FLAG_SHOW_AUXIL_SUPPORT

		else if(roles_show & FLAG_SHOW_MISC && ROLES_MISC.Find(J.title))
			dat += "<hr>Other:<br>"
			roles_show ^= FLAG_SHOW_MISC

		else if(roles_show & FLAG_SHOW_POLICE && ROLES_POLICE.Find(J.title))
			dat += "<hr>Military Police:<br>"
			roles_show ^= FLAG_SHOW_POLICE

		else if(roles_show & FLAG_SHOW_ENGINEERING && ROLES_ENGINEERING.Find(J.title))
			dat += "<hr>Engineering:<br>"
			roles_show ^= FLAG_SHOW_ENGINEERING

		else if(roles_show & FLAG_SHOW_REQUISITION && ROLES_REQUISITION.Find(J.title))
			dat += "<hr>Requisitions:<br>"
			roles_show ^= FLAG_SHOW_REQUISITION

		else if(roles_show & FLAG_SHOW_MEDICAL && ROLES_MEDICAL.Find(J.title))
			dat += "<hr>Medbay:<br>"
			roles_show ^= FLAG_SHOW_MEDICAL

		else if(roles_show & FLAG_SHOW_MARINES && ROLES_MARINES.Find(J.title))
			dat += "<hr>Squad Marine:<br>"
			roles_show ^= FLAG_SHOW_MARINES

		dat += "<a href='byond://?src=\ref[src];lobby_choice=SelectedJob;job_selected=[J.title]'>[J.disp_title] ([J.current_positions]) (Active: [active])</a><br>"

	dat += "</center>"
	show_browser(src, dat, "Late Join", "latechoices", "size=420x700")


/mob/new_player/proc/create_character()
	spawning = TRUE
	close_spawn_windows()

	var/mob/living/carbon/human/new_character

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(chosen_species)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		if(is_species_whitelisted(chosen_species) || has_admin_rights())
			new_character = new(loc, client.prefs.species)

	if(!new_character)
		new_character = new(loc)

	new_character.lastarea = get_area(loc)

	if(ticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_name = random_name(new_character.gender)
		client.prefs.randomize_appearance(new_character)
	else
		client.prefs.copy_all_to(new_character)

	if (client.prefs.be_random_body)
		var/datum/preferences/TP = new()
		TP.randomize_appearance(new_character)

	if(mind)
		mind_initialize()
		mind.active = 0					//we wish to transfer the key manually
		mind.original = new_character
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active
		mind.setup_human_stats()

	new_character.job = job
	new_character.name = real_name
	new_character.voice = real_name

	if(client.prefs.disabilities)
		new_character.disabilities |= NEARSIGHTED

	// Update the character icons
	// This is done in set_species when the mob is created as well, but 
	INVOKE_ASYNC(new_character, /mob/living/carbon/human.proc/regenerate_icons)
	INVOKE_ASYNC(new_character, /mob/living/carbon/human.proc/update_body, 1, 0)
	INVOKE_ASYNC(new_character, /mob/living/carbon/human.proc/update_hair)

	new_character.key = key		//Manually transfer the key to log them in
	if(new_character.client) 
		new_character.client.change_view(world_view_size)

	return new_character

/mob/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4><center>Crew Manifest:</center></h4>"
	dat += data_core.get_manifest(FALSE, TRUE)

	show_browser(src, dat, "Crew Manifest", "manifest", "size=450x750")

/mob/new_player/Move()
	return 0

/mob/proc/close_spawn_windows() // Somehow spawn menu stays open for non-newplayers
	close_browser(src, "latechoices") //closes late choices window
	close_browser(src, "playersetup") //closes the player setup window
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // Stops lobby music.
	if(src.open_uis)
		for(var/datum/nanoui/ui in src.open_uis)
			if(ui.allowed_user_stat == -1)
				ui.close()
				continue

/mob/new_player/proc/has_admin_rights()
	return client.admin_holder.rights & R_ADMIN

/mob/new_player/proc/is_species_whitelisted(datum/species/S)
	if(!S) return 1
	return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !(S.flags & IS_WHITELISTED)

/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species)
		return "Human"

	if(is_species_whitelisted(chosen_species) || has_admin_rights())
		return chosen_species.name

	return "Human"

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

/mob/new_player/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "",var/italics = 0, var/mob/speaker = null)
	return

/mob/new_player/hear_radio(var/message, var/verb="says", var/datum/language/language=null, var/part_a, var/part_b, var/mob/speaker = null, var/hard_to_hear = 0)
	return

#undef FLAG_SHOW_CIC
#undef FLAG_SHOW_AUXIL_SUPPORT
#undef FLAG_SHOW_MISC
#undef FLAG_SHOW_POLICE
#undef FLAG_SHOW_ENGINEERING
#undef FLAG_SHOW_REQUISITION
#undef FLAG_SHOW_MEDICAL
#undef FLAG_SHOW_MARINES
#undef FLAG_SHOW_ALL