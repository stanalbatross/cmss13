/datum/entity/player_stats/xeno
	var/datum/entity/player_stats/caste/top_caste = null // reference to /datum/entity/player_stats/caste (i.e. ravager)
	var/list/caste_stats_list = list() // list of types /datum/entity/player_stats/caste

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/xeno/proc/get_recalculate()
	for(var/datum/entity/statistic/xeno/N in player.CS)
		setup_caste_stats(N.name)

	recalculate_statistic()

/datum/entity/player_stats/xeno/proc/setup_caste_stats(var/caste, var/noteworthy = TRUE)
	if(!caste)
		return
	var/caste_key = strip_improper(caste)
	if(caste_stats_list["[caste_key]"])
		var/datum/entity/player_stats/caste/S = caste_stats_list["[caste_key]"]
		if(!S.display_stat && noteworthy)
			S.display_stat = noteworthy
		return S
	var/datum/entity/player_stats/caste/new_stat = new()
	new_stat.display_stat = noteworthy
	new_stat.player = player
	new_stat.name = caste_key
	caste_stats_list["[caste_key]"] = new_stat
	new_stat.get_recalculate()
	return new_stat

/datum/entity/player_stats/xeno/proc/recalculate_statistic()
	for(var/iteration in caste_stats_list)
		var/datum/entity/player_stats/xeno/S = caste_stats_list[iteration]
		if(!S.display_stat)
			continue

		for(var/sub_iteration in S.statistic)
			var/datum/entity/statistic/xeno/D = S.statistic[sub_iteration]
			if(!statistic["[D.name]"])
				var/datum/entity/statistic/xeno/NN = new()
				NN.name = D.name
				statistic["[D.name]"] = NN
			var/datum/entity/statistic/xeno/NNN = statistic["[D.name]"]
			NNN.value += D.value

//*****************
//Mob Procs - minor
//*****************

/mob/living/carbon/Xenomorph/track_death_calculations()
	if(statistic_exempt || statistic_tracked || !mind || !mind.player_entity)
		return
	var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
	if(isnull(xeno_stats))
		return
	if(!xeno_stats.round_played)
		track_statistic_xeno_earned(STATISTICS_ROUNDS_PLAYED, 1, client.player_data.id)
		xeno_stats.round_played = TRUE
	xeno_stats.track_caste_playing(caste_type, client)
	xeno_stats.recalculate_top_caste()
	xeno_stats.recalculate_nemesis()
	xeno_stats.get_recalculate()
	..()

/datum/entity/player_stats/xeno/recalculate_nemesis()
	for(var/caste_statistic in caste_stats_list)
		var/datum/entity/player_stats/caste/caste_entity = caste_stats_list[caste_statistic]
		caste_entity.get_recalculate()
		caste_entity.recalculate_nemesis()

/datum/entity/player_stats/xeno/proc/recalculate_top_caste()
	for(var/statistics in caste_stats_list)
		var/datum/entity/player_stats/caste/stat_entity = caste_stats_list[statistics]
		stat_entity.get_recalculate()
		stat_entity.get_kills()
		if(!top_caste)
			top_caste = stat_entity
			continue
		if(stat_entity.total_kills > top_caste.total_kills)
			top_caste = stat_entity

/datum/entity/player_stats/xeno/proc/track_caste_playing(var/caste, var/client/client)
	var/datum/entity/player_stats/caste/S = setup_caste_stats(caste)
	if(!S.round_played)
		S.round_played = TRUE
		track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE, caste, STATISTICS_ROUNDS_PLAYED, 1, client.player_data.id)

/mob/living/carbon/Xenomorph/proc/track_ability_usage(var/ability, var/caste, var/amount = 1)
	if(statistic_exempt || !client || !mind)
		return
	track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE_ABILITIES, caste, ability, amount, client.player_data.id)

/mob/living/carbon/Xenomorph/track_steps_walked(var/amount = 1, var/name = STATISTICS_STEPS_WALKED)
	if(statistic_exempt || !client || !mind)
		return
	track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE, caste_type, name, amount, client.player_data.id)

/mob/living/carbon/Xenomorph/proc/track_slashes(var/caste, var/amount = 1, var/name = STATISTICS_SLASH)
	if(statistic_exempt || !client || !mind)
		return
	track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE, caste, name, amount, client.player_data.id)
	if(round_statistics)
		round_statistics.total_slashes += amount

/datum/entity/player_stats/xeno/count_statistic_stat(var/client/client, var/name, var/amount = 1, var/caste)
	if(!name)
		return
	track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE, caste, name, amount, client.player_data.id)

//************************
//Stat Procs - kills/death
//************************

//KILLS
/datum/entity/player_stats/xeno/count_kill(var/role, var/weapon, var/id, var/kill_type, var/amount = 1)
	track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE, role, kill_type, amount, id)
	recalculate_top_caste()

//DEATHS
/datum/entity/player_stats/xeno/count_death(var/role, var/weapon, var/id, var/death_type, var/amount = 1)
	track_statistic_xeno_earned(STATISTIC_TYPE_XENO_CASTE, role, death_type, amount, id)
	recalculate_top_caste()