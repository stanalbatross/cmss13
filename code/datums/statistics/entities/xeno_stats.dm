/datum/entity/player_stats/xeno
	var/datum/entity/player_stats/caste/top_caste = null // reference to /datum/entity/player_stats/caste (i.e. ravager)
	var/list/caste_stats_list = list() // list of types /datum/entity/player_stats/caste

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/xeno/proc/get_recalculate()
	for(var/datum/entity/statistic/niche/N in player.NICHE)
		if(N.niche_statistic_name_primary == STATISTICS_NICHE_TYPE_BASE_XENO)
			if(N.niche_statistic_name_second == STATISTICS_NICHE_KILL)
				total_kills = N.niche_value
			else if(N.niche_statistic_name_last == STATISTICS_NICHE_NICHES)
				if(!niche_stats["[N.niche_statistic_name_second]"])
					var/datum/entity/statistic/NS = new()
					NS.name = N.niche_statistic_name_second
					niche_stats["[N.niche_statistic_name_second]"] = NS
				var/datum/entity/statistic/S = niche_stats["[N.niche_statistic_name_second]"]
				S.value = N.niche_value
	for(var/datum/entity/statistic/niche/N in player.NICHE)
		if(N.niche_statistic_name_primary == STATISTICS_NICHE_CASTLE_SUBTYPE)
			setup_caste_stats(N.niche_statistic_name_first)

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
		track_niche_earned(STATISTICS_NICHE_TYPE_BASE_XENO, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_ROUNDS_PLAYED, STATISTICS_NICHE_NICHES, 1, client.player_data.id)
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
	..()

/datum/entity/player_stats/xeno/proc/recalculate_top_caste()
	for(var/statistics in caste_stats_list)
		var/datum/entity/player_stats/caste/stat_entity = caste_stats_list[statistics]
		stat_entity.get_recalculate()
		if(!top_caste)
			top_caste = stat_entity
			continue
		if(stat_entity.total_kills > top_caste.total_kills)
			top_caste = stat_entity

/datum/entity/player_stats/xeno/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DEATHS)
		if(!stat_entity.cause_name || stat_entity.faction_name != "Normal Hive")
			continue
		causes["[stat_entity.cause_name]"] += 1
		if(!nemesis)
			nemesis = new()
			nemesis.name = stat_entity.cause_name
			nemesis.value = 1
			continue
		if(causes["[stat_entity.cause_name]"] > nemesis.value)
			nemesis.name = stat_entity.cause_name
			nemesis.value = causes["[stat_entity.cause_name]"]

/datum/entity/player_stats/xeno/proc/track_caste_playing(var/caste, var/client/client)
	var/datum/entity/player_stats/caste/S = setup_caste_stats(caste)
	if(!S.round_played)
		S.round_played = TRUE
		track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, caste, STATISTICS_NICHE_ROUNDS_PLAYED, STATISTICS_NICHE_NICHES, 1, client.player_data.id)

/mob/living/carbon/Xenomorph/proc/track_ability_usage(var/ability, var/caste, var/amount = 1)
	if(statistic_exempt || !client || !mind)
		return
	if(caste_type)
		track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, caste_type, ability, amount, client.player_data.id)

/mob/living/carbon/Xenomorph/track_steps_walked(var/amount = 1)
	if(statistic_exempt || !client || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_XENO, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_STEPS_WALKED, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	if(caste_type)
		track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, caste_type, STATISTICS_NICHE_STEPS_WALKED, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/living/carbon/Xenomorph/proc/track_slashes(var/caste, var/amount = 1)
	if(statistic_exempt || !client || !mind)
		return

	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_XENO, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_SLASH, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	if(caste_type)
		track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, caste_type, STATISTICS_NICHE_SLASH, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/datum/entity/player_stats/xeno/count_niche_stat(var/client/client, var/niche_name, var/amount = 1, var/role)
	if(!niche_name)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_XENO, STATISTICS_NICHE_HELP_SUBTYPE, niche_name, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	if(role)
		track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, role, niche_name, STATISTICS_NICHE_NICHES, amount, client.player_data.id)


//************************
//Stat Procs - kills/death
//************************

//KILLS
/datum/entity/player_stats/xeno/count_personal_kill(var/role, var/cause_name, var/datum/entity/player/player_data, var/kill_type)
	track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, role, kill_type, STATISTICS_NICHE_NOT_NICHES, 1, player_data.id)
	recalculate_top_caste()

/datum/entity/player_stats/xeno/count_kill(var/role, var/cause_name, var/datum/entity/player/player_data, var/kill_type)
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_XENO, STATISTICS_NICHE_HELP_SUBTYPE, kill_type, STATISTICS_NICHE_NICHES, 1, player_data.id)
	if(role)
		count_personal_kill(cause_name, role, player_data, kill_type)

//DEATHS
/datum/entity/player_stats/xeno/count_personal_death(var/role, var/cause_name, var/datum/entity/player/player_data, var/death_type)
	track_niche_earned(STATISTICS_NICHE_CASTLE_SUBTYPE, role, death_type, STATISTICS_NICHE_NICHES, 1, player_data.id)
	recalculate_top_caste()

/datum/entity/player_stats/xeno/count_death(var/role, var/cause_name, var/datum/entity/player/player_data, var/death_type)
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_XENO, STATISTICS_NICHE_HELP_SUBTYPE, death_type, STATISTICS_NICHE_NICHES, 1, player_data.id)
	if(role)
		count_personal_death(cause_name, role, player_data, death_type)