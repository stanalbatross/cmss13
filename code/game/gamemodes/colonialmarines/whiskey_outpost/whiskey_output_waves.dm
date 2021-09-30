#define WO_SPAWN_MULTIPLIER 0.9
#define WO_SCALED_WAVE 1
#define WO_STATIC_WAVE 2

//SPAWN XENOS
/datum/game_mode/whiskey_outpost/proc/spawn_whiskey_outpost_xenos(var/datum/whiskey_outpost_wave/wave_data)
	if(!istype(wave_data))
		return

	var/datum/hive_status/hive = GLOB.hive_datum[XENO_HIVE_NORMAL]
	if(hive.slashing_allowed != XENO_SLASH_ALLOWED)
		hive.slashing_allowed = XENO_SLASH_ALLOWED //Allows harm intent for aliens
	var/xenos_to_spawn
	if(wave_data.wave_type == WO_SCALED_WAVE)
		xenos_to_spawn = max(count_marines(SSmapping.levels_by_trait(ZTRAIT_GROUND)),5) * wave_data.scaling_factor * WO_SPAWN_MULTIPLIER
	else
		xenos_to_spawn = wave_data.number_of_xenos

	if(wave_data.wave_number == 1)
		call(/datum/game_mode/whiskey_outpost/proc/disablejoining)()

	while(xenos_to_spawn-- > 0)
		xeno_pool += pick(wave_data.wave_castes) // Adds the wave's xenos to the current pool



/datum/game_mode/whiskey_outpost/attempt_to_join_as_xeno(mob/xeno_candidate, instant_join = 0)
	var/list/available_xenos = list()
	var/list/unique_xenos = list()

	for(var/mob/living/carbon/Xenomorph/X in GLOB.living_xeno_list)
		var/area/A = get_area(X)
		if(is_admin_level(X.z) && (!A || !(A.flags_area & AREA_ALLOW_XENO_JOIN))) continue //xenos on admin z level don't count
		if(istype(X) && !X.client)
			if(X.away_timer >= XENO_LEAVE_TIMER || (isXenoLarva(X) && X.away_timer >= XENO_LEAVE_TIMER_LARVA))
				available_xenos += X

	for(var/name in xeno_pool)
		if(!(name in unique_xenos))
			unique_xenos += name

	available_xenos += unique_xenos

	if(!available_xenos.len)
		to_chat(xeno_candidate, SPAN_WARNING("There aren't any available xenomorphs."))
		return FALSE

	var/userInput = tgui_input_list(usr, "Available Xenomorphs", "Join as Xeno", available_xenos)

	if(!xeno_candidate)
		return FALSE

	if(RoleAuthority.castes_by_name[userInput])
		if(!(userInput in xeno_pool))
			to_chat(xeno_candidate, SPAN_WARNING("The caste type you chose was occupied by someone else."))
			return FALSE
		var/spawn_loc = pick(xeno_spawns)
		var/xeno_type = RoleAuthority.get_caste_by_text(userInput)
		var/mob/living/carbon/Xenomorph/new_xeno = new xeno_type(spawn_loc)
		new_xeno.nocrit(xeno_wave)
		xeno_pool -= userInput
		if(isnewplayer(xeno_candidate))
			var/mob/new_player/N = xeno_candidate
			N.close_spawn_windows()
		if(transfer_xeno(xeno_candidate, new_xeno))
			return TRUE
	else
		if(!isXeno(userInput))
			return FALSE

		var/mob/living/carbon/Xenomorph/new_xeno = userInput
		if(!(new_xeno in GLOB.living_xeno_list) || new_xeno.stat == DEAD)
			to_chat(xeno_candidate, SPAN_WARNING("You cannot join if the xenomorph is dead."))
			return FALSE

		if(new_xeno.client)
			to_chat(xeno_candidate, SPAN_WARNING("That xenomorph has been occupied."))
			return FALSE

		if(!xeno_bypass_timer)
			if((!isXenoLarva(new_xeno) && new_xeno.away_timer < XENO_LEAVE_TIMER) || (isXenoLarva(new_xeno) && new_xeno.away_timer < XENO_LEAVE_TIMER_LARVA))
				var/to_wait = XENO_LEAVE_TIMER - new_xeno.away_timer
				if(isXenoLarva(new_xeno))
					to_wait = XENO_LEAVE_TIMER_LARVA - new_xeno.away_timer
				to_chat(xeno_candidate, SPAN_WARNING("That player hasn't been away long enough. Please wait [to_wait] second\s longer."))
				return FALSE

		if(alert(xeno_candidate, "Everything checks out. Are you sure you want to transfer yourself into [new_xeno]?", "Confirm Transfer", "Yes", "No") == "Yes")
			if(new_xeno.client || !(new_xeno in GLOB.living_xeno_list) || new_xeno.stat == DEAD || !xeno_candidate) // Do it again, just in case
				to_chat(xeno_candidate, SPAN_WARNING("That xenomorph can no longer be controlled. Please try another."))
				return FALSE
		else return FALSE

		if(istype(new_xeno) && xeno_candidate && xeno_candidate.client)
			if(isnewplayer(xeno_candidate))
				var/mob/new_player/N = xeno_candidate
				N.close_spawn_windows()
			if(transfer_xeno(xeno_candidate, new_xeno))
				return TRUE
	to_chat(xeno_candidate, "JAS01: Something went wrong, tell a coder.")




/datum/whiskey_outpost_wave
	var/wave_number = 1
	var/list/wave_castes = list()
	var/wave_type = WO_SCALED_WAVE
	var/scaling_factor = 1.0
	var/number_of_xenos = 0 // not used for scaled waves
	var/wave_delay = 200 SECONDS
	var/list/sound_effect = list('sound/voice/alien_distantroar_3.ogg','sound/voice/xenos_roaring.ogg', 'sound/voice/4_xeno_roars.ogg')
	var/list/command_announcement = list()

/datum/whiskey_outpost_wave/wave1
	wave_number = 1
	wave_castes = list(XENO_CASTE_RUNNER)
	sound_effect = list('sound/effects/siren.ogg')
	command_announcement = list("We're tracking the creatures that wiped out our patrols heading straight towards your outpost as we speak. Stand-by as we're still attempting to establish a signal with the USS Alistoun to alert them of these creatures. Don't let them past you.", "Captain Naich, 3rd Battalion Command, LV-624 Garrison")
	scaling_factor = 0.3
	wave_delay = 90 SECONDS //Early, quick waves

/datum/whiskey_outpost_wave/wave2
	wave_number = 2
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_SENTINEL)
	scaling_factor = 0.4
	wave_delay = 90 SECONDS //Early, quick waves

/datum/whiskey_outpost_wave/wave3 //Tier II versions added, but rare
	wave_number = 3
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER)
	scaling_factor = 0.6
	command_announcement = list("Several of our outposts are suffering hostile contact but the situation is under control at present. We need you all to keep holding out. The majority of enemy activity appears to be concentrated in southern areas so far.", "Captain Naich, 3rd Battalion Command, LV-624 Garrison")
	wave_delay = 120 SECONDS //Early, quick waves

/datum/whiskey_outpost_wave/wave4 //Tier II more common
	wave_number = 4
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE)
	scaling_factor = 0.7

/datum/whiskey_outpost_wave/wave5 //Reset the spawns	so we don't drown in xenos again.
	wave_number = 5
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE)
	scaling_factor = 0.8
	command_announcement = list("The vanguard of enemy forces are hitting out outposts now, and Whiskey Outpost is clearly going to take the brunt of it. We're going to need you to hold while we get this all done. We're prepparing additional mortar support, hold the line or we're all going to die.", "Captain Naich, 3rd Battalion Command, LV-624 Garrison")

/datum/whiskey_outpost_wave/wave6 //Tier II more common
	wave_number = 6
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_SENTINEL,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR)
	scaling_factor = 0.9

/datum/whiskey_outpost_wave/wave7
	wave_number = 7
	wave_type = WO_STATIC_WAVE
	number_of_xenos = 0
	command_announcement = list("Major Ike Saker speaking, The Captain is still trying to try and get off world contact. An engineer platoon managed to destroy the main entrance into this valley this should give you a short break while the aliens find another way in. I have also recieved word that the 7th 'Falling Falcons' Battalion. Should be near. I used to be stationed with them they are top notch! Standby for reinforcements!", "Major Ike Saker, 3rd Battalion Command, LV-624 Garrison")

/datum/whiskey_outpost_wave/wave8
	wave_number = 8
	wave_castes = list(XENO_CASTE_SENTINEL,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR)
	sound_effect = list()
	command_announcement = list("Captain Naiche speaking, we've been unsuccessful in establishing offworld communication for the moment. We're prepping our M402 mortar to destroy the inbound xeno force on the main road. Standby for fire support.", "Captain Naich, 3rd Battalion Command, LV-624 Garrison")

/datum/whiskey_outpost_wave/wave9 //Ravager and Praetorian Added, Tier II more common, Tier I less common
	wave_number = 9
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR)
	sound_effect = list('sound/voice/alien_queen_command.ogg')
	command_announcement = list("Our garrison forces are reaching seventy percent casualties, we are losing our grip on LV-624. It appears that vanguard of the hostile force is still approaching, and most of the other Dust Raider platoons have been shattered. We're counting on you to keep holding. Don't let us down.", "Captain Naich, 3rd Battalion Command, LV-624 Garrison")

/datum/whiskey_outpost_wave/wave10
	wave_number = 10
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR)

/datum/whiskey_outpost_wave/wave11
	wave_number = 11
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_WARRIOR)

/datum/whiskey_outpost_wave/wave12
	wave_number = 12
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_RAVAGER,
					XENO_CASTE_RAVAGER,
					XENO_CASTE_PRAETORIAN,
					XENO_CASTE_PRAETORIAN)
	scaling_factor = 2
	command_announcement = list("This is Captain Naiche, we are picking up large signatures inbound, we'll see what we can do to delay them. We're still working on establishing contact. Reports are promising, but we need more time !", "Captain Naich, 3rd Battalion Command, LV-624")

/datum/whiskey_outpost_wave/wave13
	wave_number = 13
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_RAVAGER,
					XENO_CASTE_RAVAGER,
					XENO_CASTE_PRAETORIAN,
					XENO_CASTE_PRAETORIAN,
					XENO_CASTE_BOILER,
					XENO_CASTE_CRUSHER,
					XENO_CASTE_CRUSHER,
					XENO_CASTE_HIVELORD)
	scaling_factor = 2
	command_announcement = list("This is Captain Naiche, we've had unexpected delay but the distress beacon is almost operational! Our forces are crumbling under the attack but we're still holding them off and need just need a bit more time to transmit the call! Do not let them past to us!", "Captain Naich, 3rd Battalion Command, LV-624")

/datum/whiskey_outpost_wave/wave14
	wave_number = 14
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_LURKER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_SPITTER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DEFENDER,
					XENO_CASTE_DRONE,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_WARRIOR,
					XENO_CASTE_RAVAGER,
					XENO_CASTE_RAVAGER,
					XENO_CASTE_PRAETORIAN,
					XENO_CASTE_PRAETORIAN,
					XENO_CASTE_CRUSHER,
					XENO_CASTE_CRUSHER,
					XENO_CASTE_HIVELORD)
	wave_type = WO_STATIC_WAVE
	number_of_xenos = 50
	command_announcement = list("This is Captain Naiche, we've established our distress beacon for the USS Alistoun and the remaining Dust Raiders. Hold on for a bit longer while we trasmit our coordinates! We should get help any moment now!", "Captain Naich, 3rd Battalion Command, LV-624 Garrison")

/datum/whiskey_outpost_wave/random
	wave_type = WO_STATIC_WAVE
	wave_number = 15
	number_of_xenos = 50

/datum/whiskey_outpost_wave/random/wave1 //Runner madness
	wave_castes = list(XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RUNNER,
					XENO_CASTE_RAVAGER)

/datum/whiskey_outpost_wave/random/wave2 //Spitter madness
	wave_castes = list(XENO_CASTE_SENTINEL,
						XENO_CASTE_SENTINEL,
						XENO_CASTE_SENTINEL,
						XENO_CASTE_SENTINEL,
						XENO_CASTE_SENTINEL,
						XENO_CASTE_SENTINEL,
						XENO_CASTE_SPITTER,
						XENO_CASTE_SPITTER,
						XENO_CASTE_SPITTER,
						XENO_CASTE_SPITTER,
						XENO_CASTE_PRAETORIAN)
	number_of_xenos = 45

/datum/whiskey_outpost_wave/random/wave3 //Siege madness
	wave_castes = list(XENO_CASTE_BOILER,
					XENO_CASTE_CRUSHER)
	number_of_xenos = 15
