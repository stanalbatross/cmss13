/datum/entity/player_stats/human
	var/datum/entity/player_stats/weapon/top_weapon = null // reference to /datum/entity/player_stats/weapon_stats (like tac-shotty)
	var/list/weapon_stats_list = list() // list of types /datum/entity/player_stats/weapon_stats
	var/list/job_stats_list = list() // list of types /datum/entity/job_stats

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/human/proc/get_recalculate()
	for(var/datum/entity/statistic/human/N in player.JS)
		setup_job_stats(N.name)
	for(var/datum/entity/statistic/human/N in player.WS)
		setup_weapon_stats(N.name)

	recalculate_statistic()

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
		var/datum/entity/player_stats/weapon/S = weapon_stats_list["[weapon_key]"]
		if(!S.display_stat && noteworthy)
			S.display_stat = noteworthy
		return S
	var/datum/entity/player_stats/weapon/new_stat = new()
	new_stat.display_stat = noteworthy
	new_stat.player = player
	new_stat.name = weapon_key
	weapon_stats_list["[weapon_key]"] = new_stat
	new_stat.get_recalculate()
	return new_stat

/datum/entity/player_stats/human/proc/recalculate_statistic()
	for(var/iteration in job_stats_list)
		var/datum/entity/player_stats/human/S = job_stats_list[iteration]
		if(!S.display_stat)
			continue

		for(var/sub_iteration in S.statistic)
			var/datum/entity/statistic/human/D = S.statistic[sub_iteration]
			if(!statistic["[D.name]"])
				var/datum/entity/statistic/human/NN = new()
				NN.name = D.name
				statistic["[D.name]"] = NN
			var/datum/entity/statistic/human/NNN = statistic["[D.name]"]
			NNN.value += D.value

/mob/living/carbon/human/track_death_calculations()
	if(statistic_exempt || statistic_tracked || !mind || !mind.player_entity)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	if(isnull(human_stats))
		return
	var/job_actual = get_actual_job_name(src)
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

/datum/entity/player_stats/human/proc/recalculate_top_weapon()
	for(var/statistics in weapon_stats_list)
		var/datum/entity/player_stats/weapon/stat_entity = weapon_stats_list[statistics]
		stat_entity.get_recalculate()
		stat_entity.get_kills()
		if(!top_weapon)
			top_weapon = stat_entity
			continue
		if(stat_entity.total_kills > top_weapon.total_kills)
			top_weapon = stat_entity

/datum/entity/player_stats/human/proc/track_job_playing(var/job, var/client/client)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	if(!S)
		return
	if(!S.round_played)
		track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, job, STATISTICS_ROUNDS_PLAYED, 1, client.player_data.id)
		S.round_played = TRUE

//*****************
//Mob Procs - minor
//*****************

/mob/living/carbon/human/track_steps_walked(var/amount = 1, var/name = STATISTICS_STEPS_WALKED)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	var/job_actual = get_actual_job_name(src)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, job_actual, name, amount, client.player_data.id)

/mob/proc/track_hit(var/weapon, var/amount = 1, var/name = STATISTICS_HIT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, job, name, amount, client.player_data.id)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_WEAPON, weapon, name, amount, client.player_data.id)

/mob/proc/track_shot(var/weapon, var/amount = 1, var/name = STATISTICS_SHOT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, job, name, amount, client.player_data.id)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_WEAPON, weapon, name, amount, client.player_data.id)

/mob/proc/track_shot_hit(var/weapon, var/shot_mob, var/amount = 1, var/name = STATISTICS_SHOT_HIT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, job, name, amount, client.player_data.id)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_WEAPON, weapon, name, amount, client.player_data.id)
	if(round_statistics)
		round_statistics.total_projectiles_hit += amount
		if(shot_mob)
			if(ishuman(shot_mob))
				round_statistics.total_projectiles_hit_human += amount
			else if(isXeno(shot_mob))
				round_statistics.total_projectiles_hit_xeno += amount

/mob/proc/track_friendly_fire(var/weapon, var/amount = 1, var/name = STATISTICS_FF_SHOT_HIT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, job, name, amount, client.player_data.id)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_WEAPON, weapon, name, amount, client.player_data.id)
	if(round_statistics)
		round_statistics.total_friendly_fire_instances += amount

/mob/proc/track_revive(var/role, var/amount = 1, var/name = STATISTICS_REVIVED)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, role, name, amount, client.player_data.id)

/mob/proc/track_life_saved(var/role, var/amount = 1, var/name = STATISTICS_REVIVE)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, role, name, amount, client.player_data.id)

/mob/proc/track_scream(var/role, var/amount = 1, var/name = STATISTICS_SCREAM)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, role, name, amount, client.player_data.id)

/datum/entity/player_stats/human/count_statistic_stat(var/client/client, var/name, var/amount = 1, var/role, var/weapon)
	if(!name)
		return
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, role, name, amount, client.player_data.id)
	if(weapon)
		track_statistic_human_earned(STATISTIC_TYPE_HUMAN_WEAPON, weapon, name, amount, client.player_data.id)

//************************
//Stat Procs - kills/death
//************************

//KILLS

/datum/entity/player_stats/human/count_kill(var/role, var/weapon, var/id, var/kill_type, var/amount = 1)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, role, kill_type, amount, id)
	if(weapon)
		track_statistic_human_earned(STATISTIC_TYPE_HUMAN_WEAPON, weapon, kill_type, amount, id)
		recalculate_top_weapon()

//DEATHS
/datum/entity/player_stats/human/count_death(var/role, var/weapon, var/id, var/death_type, var/amount = 1)
	track_statistic_human_earned(STATISTIC_TYPE_HUMAN_JOB, role, death_type, amount, id)