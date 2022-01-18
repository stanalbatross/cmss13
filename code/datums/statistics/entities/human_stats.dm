/datum/entity/player_stats/human
	var/datum/entity/player_stats/weapon_stats/top_weapon = null // reference to /datum/entity/player_stats/weapon_stats (like tac-shotty)
	var/list/weapon_stats_list = list() // list of types /datum/entity/player_stats/weapon_stats
	var/list/job_stats_list = list() // list of types /datum/entity/job_stats

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/human/proc/get_recalculate()
	for(var/datum/entity/statistic/niche/N in player.NICHE)
		if(N.niche_statistic_name_primary == STATISTICS_NICHE_TYPE_BASE_HUMAN)
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
		if(N.niche_statistic_name_primary == STATISTICS_NICHE_JOB_SUBTYPE)
			setup_job_stats(N.niche_statistic_name_first)
	for(var/datum/entity/statistic/niche/N in player.NICHE)
		if(N.niche_statistic_name_primary == STATISTICS_NICHE_WEAPON_SUBTYPE)
			setup_weapon_stats(N.niche_statistic_name_first)

/datum/entity/player_stats/human/proc/setup_job_stats(var/job, var/noteworthy = TRUE)
	if(!job)
		return
	var/job_key = strip_improper(job)
	if(job_stats_list["[job_key]"])
		var/datum/entity/player_stats/job/S = job_stats_list["[job_key]"]
		if(!S.display_stat && noteworthy)
			S.display_stat = noteworthy
		return S
	var/datum/entity/player_stats/job/new_stat = new()
	new_stat.display_stat = noteworthy
	new_stat.player = player
	new_stat.name = job_key
	job_stats_list["[job_key]"] = new_stat
	new_stat.get_recalculate()
	return new_stat

/datum/entity/player_stats/human/proc/setup_weapon_stats(var/weapon, var/noteworthy = TRUE)
	if(!weapon)
		return
	var/weapon_key = strip_improper(weapon)
	if(weapon_stats_list["[weapon_key]"])
		var/datum/entity/player_stats/weapon_stats/S = weapon_stats_list["[weapon_key]"]
		if(!S.display_stat && noteworthy)
			S.display_stat = noteworthy
		return S
	var/datum/entity/player_stats/weapon_stats/new_stat = new()
	new_stat.display_stat = noteworthy
	new_stat.player = src
	new_stat.name = weapon_key
	weapon_stats_list["[weapon_key]"] = new_stat
	new_stat.get_recalculate()
	return new_stat

/mob/living/carbon/human/track_death_calculations()
	if(statistic_exempt || statistic_tracked || !mind || !mind.player_entity)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	if(isnull(human_stats))
		return
	var/job_actual = get_actual_job_name(src)
	if(!human_stats.round_played)
		track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_ROUNDS_PLAYED, STATISTICS_NICHE_NICHES, 1, client.player_data.id)
		human_stats.round_played = TRUE
	human_stats.track_job_playing(job_actual, client)
	human_stats.recalculate_top_weapon()
	human_stats.recalculate_nemesis()
	human_stats.get_recalculate()
	..()

/datum/entity/player_stats/human/recalculate_nemesis()
	for(var/job_statistic in job_stats_list)
		var/datum/entity/player_stats/job/job_entity = job_stats_list[job_statistic]
		job_entity.get_recalculate()
		job_entity.recalculate_nemesis()
	..()

/datum/entity/player_stats/human/proc/recalculate_top_weapon()
	for(var/statistics in weapon_stats_list)
		var/datum/entity/player_stats/weapon_stats/stat_entity = weapon_stats_list[statistics]
		stat_entity.get_recalculate()
		if(!top_weapon)
			top_weapon = stat_entity
			continue
		if(stat_entity.total_kills > top_weapon.total_kills)
			top_weapon = stat_entity

/datum/entity/player_stats/human/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DEATHS)
		if(!stat_entity.cause_name || stat_entity.faction_name == "Normal Hive")
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

/datum/entity/player_stats/human/proc/track_job_playing(var/job, var/client/client)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	if(!S)
		return
	if(!S.round_played)
		track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_ROUNDS_PLAYED, STATISTICS_NICHE_NICHES, 1, client.player_data.id)
		S.round_played = TRUE

//*****************
//Mob Procs - minor
//*****************

/mob/living/carbon/human/track_steps_walked(var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_STEPS_WALKED, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	var/job_actual = get_actual_job_name(src)
	if(job_actual)
		track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job_actual, STATISTICS_NICHE_STEPS_WALKED, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/proc/track_hit(var/weapon, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_WEAPON_SUBTYPE, weapon, STATISTICS_NICHE_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/proc/track_shot(var/weapon, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_SHOT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_WEAPON_SUBTYPE, weapon, STATISTICS_NICHE_SHOT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_SHOT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/proc/track_shot_hit(var/weapon, var/shot_mob, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_SHOT_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_WEAPON_SUBTYPE, weapon, STATISTICS_NICHE_SHOT_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_SHOT_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	if(round_statistics)
		round_statistics.total_projectiles_hit += amount
		if(shot_mob)
			if(ishuman(shot_mob))
				round_statistics.total_projectiles_hit_human += amount
			else if(isXeno(shot_mob))
				round_statistics.total_projectiles_hit_xeno += amount

/mob/proc/track_friendly_fire(var/weapon, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_FF_SHOT_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_WEAPON_SUBTYPE, weapon, STATISTICS_NICHE_FF_SHOT_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_FF_SHOT_HIT, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/proc/track_revive(var/job, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_REVIVED, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_REVIVED, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/proc/track_life_saved(var/job, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_REVIVE, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_REVIVE, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/mob/proc/track_scream(var/job, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, STATISTICS_NICHE_SCREAM, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, job, STATISTICS_NICHE_SCREAM, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

/datum/entity/player_stats/human/count_niche_stat(var/client/client, var/niche_name, var/amount = 1, var/role, var/weapon)
	if(!niche_name)
		return
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, niche_name, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	if(role)
		track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, role, niche_name, STATISTICS_NICHE_NICHES, amount, client.player_data.id)
	if(weapon)
		track_niche_earned(STATISTICS_NICHE_WEAPON_SUBTYPE, weapon, niche_name, STATISTICS_NICHE_NICHES, amount, client.player_data.id)

//************************
//Stat Procs - kills/death
//************************

//KILLS

/datum/entity/player_stats/human/count_kill(var/role, var/weapon, var/id, var/kill_type, var/amount = 1)
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, kill_type, STATISTICS_NICHE_NOT_NICHES, amount, id)
	if(role)
		track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, role, kill_type, STATISTICS_NICHE_NOT_NICHES, amount, id)
	if(weapon)
		track_niche_earned(STATISTICS_NICHE_WEAPON_SUBTYPE, weapon, kill_type, STATISTICS_NICHE_NOT_NICHES, amount, id)
		recalculate_top_weapon()

//DEATHS
/datum/entity/player_stats/human/count_death(var/role, var/weapon, var/id, var/death_type, var/amount = 1)
	track_niche_earned(STATISTICS_NICHE_TYPE_BASE_HUMAN, STATISTICS_NICHE_HELP_SUBTYPE, death_type, STATISTICS_NICHE_NICHES, amount, id)
	if(role)
		track_niche_earned(STATISTICS_NICHE_JOB_SUBTYPE, role, death_type, STATISTICS_NICHE_NICHES, amount, id)