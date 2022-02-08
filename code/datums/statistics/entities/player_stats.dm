/datum/entity/player_stats
	var/datum/entity/player_entity/player = null // "mattatlas"
	var/total_kills = 0
	var/round_played = FALSE
	var/datum/entity/statistic/nemesis = null // "runner" = 3
	var/list/statistic = list() // list of type /datum/entity/statistic, "Total Executions" = number
	var/display_stat = TRUE

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/proc/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DS)
		if(!stat_entity.cause_name)
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

/mob/proc/track_death_calculations()
	if(statistic_exempt || statistic_tracked)
		return
	if(mind && mind.player_entity)
		mind.player_entity.setup_entity(round_statistics)
	statistic_tracked = TRUE

//*****************
//Mob Procs - minor
//*****************

/mob/proc/count_statistic_stat(var/name, var/amount = 1)
	return

/mob/living/carbon/human/count_statistic_stat(var/name, var/amount = 1, var/weapon)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	var/job_actual = get_actual_job_name(src)
	human_stats.count_statistic_stat(client, name, amount, job_actual, weapon)

/mob/living/carbon/Xenomorph/count_statistic_stat(var/name, var/amount = 1)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
	xeno_stats.count_statistic_stat(client, name, amount, caste_type)

/datum/entity/player_stats/proc/count_statistic_stat(var/client/client, var/name, var/amount = 1, var/job)
	return

/datum/entity/player_stats/proc/count_personal_steps_walked(var/client/client, var/job)
	return

/mob/proc/track_steps_walked()
	return


//************************
//Stat Procs - kills/death
//************************

//KILLS
/datum/entity/player_stats/proc/count_kill(var/role, var/weapon, var/id, var/kill_type, var/amount = 1)
	return

//DEATHS
/datum/entity/player_stats/proc/count_death(var/role, var/weapon, var/id, var/death_type, var/amount = 1)
	return