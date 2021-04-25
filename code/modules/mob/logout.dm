/mob/Logout()
	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	if(interactee)
		unset_interaction()
	GLOB.player_list -= src
	log_access("Logout: [key_name(src)]")

	if(ckey != null)
		unansweredAhelps.Remove(src.computer_id)

	if(AHOLD_IS_MOD(admin_datums[src.ckey]) && SSticker.current_state == GAME_STATE_PLAYING)
		message_staff("Admin logout: [key_name(src)]")

	if(s_active)
		s_active.storage_close(src)
	..()

	var/datum/entity/player/P = get_player_from_key(logging_ckey)

	if(P)
		if(stat == DEAD)
			record_playtime(P, JOB_OBSERVER, type)
		else
			record_playtime(P, job, type)

	logging_ckey = null

	if(client)
		for(var/foo in client.player_details.post_logout_callbacks)
			var/datum/callback/CB = foo
			CB.Invoke()

	return TRUE
