//STATISTIC GENERAL//

/datum/entity/statistic/human
	var/player_id

BSQL_PROTECT_DATUM(/datum/entity/statistic/human)
BSQL_PROTECT_DATUM(/datum/entity_meta/statistic_human)

/datum/entity_meta/statistic_human
    entity_type = /datum/entity/statistic/human
    table_name = "log_player_statistic_human"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/entity_link/player_to_human_stat
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic/human
    child_field = "player_id"

    parent_name = "player"
    child_name = "human"

/datum/view_record/human
	var/player_id
	var/name
	var/value

/datum/entity_view_meta/statistic_human_ordered
    root_record_type = /datum/entity/statistic/human
    destination_entity = /datum/view_record/human
    fields = list(
        "player_id",
        "name",
        "value"
    )
    order_by = list("value" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_human_earned(name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic/human, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_human_earned_callback, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_human_earned_callback(name, value, player_id, var/list/datum/entity/statistic/human/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/human/S = DB_ENTITY(/datum/entity/statistic/human) // this creates a new record
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	var/datum/entity/statistic/human/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//HUMAN ENTITY//

/datum/entity/player_stats/human
	var/datum/entity/player_stats/weapon/top_weapon = null // reference to /datum/entity/player_stats/weapon_stats (like tac-shotty)
	var/list/weapon_stats_list = list() // list of types /datum/entity/player_stats/weapon_stats
	var/list/job_stats_list = list() // list of types /datum/entity/job_stats

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/human/proc/get_recalculate()
	for(var/datum/entity/statistic/human/N in player.HS)
		if(!statistic["[N.name]"])
			var/datum/entity/statistic/human/NN = new()
			NN.name = N.name
			statistic["[N.name]"] = NN
		var/datum/entity/statistic/human/NNN = statistic["[N.name]"]
		NNN.value = N.value
	for(var/datum/entity/statistic/job/N in player.JS)
		setup_job_stats(N.job)
	for(var/datum/entity/statistic/weapon/N in player.WS)
		setup_weapon_stats(N.weapon)

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

/mob/living/carbon/human/track_death_calculations()
	if(statistic_exempt || statistic_tracked || !mind || !mind.player_entity)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	if(isnull(human_stats))
		return
	var/job_actual = get_actual_job_name(src)
	if(!human_stats.round_played)
		track_statistic_human_earned(STATISTICS_ROUNDS_PLAYED, 1, client.player_data.id)
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
		var/datum/entity/player_stats/weapon/stat_entity = weapon_stats_list[statistics]
		stat_entity.get_recalculate()
		if(!top_weapon)
			top_weapon = stat_entity
			continue
		if(stat_entity.total_kills > top_weapon.total_kills)
			top_weapon = stat_entity

/datum/entity/player_stats/human/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DS)
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
		track_statistic_job_earned(job, STATISTICS_ROUNDS_PLAYED, 1, client.player_data.id)
		S.round_played = TRUE

//*****************
//Mob Procs - minor
//*****************

/mob/living/carbon/human/track_steps_walked(var/amount = 1, var/name = STATISTICS_STEPS_WALKED)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	var/job_actual = get_actual_job_name(src)
	if(job_actual)
		track_statistic_job_earned(job, name, amount, client.player_data.id)

/mob/proc/track_hit(var/weapon, var/amount = 1, var/name = STATISTICS_HIT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_weapon_earned(weapon, name, amount, client.player_data.id)

/mob/proc/track_shot(var/weapon, var/amount = 1, var/name = STATISTICS_SHOT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	track_statistic_job_earned(job, name, amount, client.player_data.id)
	track_statistic_weapon_earned(weapon, name, amount, client.player_data.id)

/mob/proc/track_shot_hit(var/weapon, var/shot_mob, var/amount = 1, var/name = STATISTICS_SHOT_HIT)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	track_statistic_job_earned(job, name, amount, client.player_data.id)
	track_statistic_weapon_earned(weapon, name, amount, client.player_data.id)
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
	track_statistic_human_earned(name, amount, client.player_data.id)
	track_statistic_job_earned(job, name, amount, client.player_data.id)
	track_statistic_weapon_earned(weapon, name, amount, client.player_data.id)

/mob/proc/track_revive(var/role, var/amount = 1, var/name = STATISTICS_REVIVED)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	if(role)
		track_statistic_job_earned(role, name, amount, client.player_data.id)

/mob/proc/track_life_saved(var/role, var/amount = 1, var/name = STATISTICS_REVIVE)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	if(role)
		track_statistic_job_earned(role, name, amount, client.player_data.id)

/mob/proc/track_scream(var/role, var/amount = 1, var/name = STATISTICS_SCREAM)
	if(statistic_exempt || !client || !ishuman(src) || !mind)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	if(role)
		track_statistic_job_earned(role, name, amount, client.player_data.id)

/datum/entity/player_stats/human/count_statistic_stat(var/client/client, var/name, var/amount = 1, var/role, var/weapon)
	if(!name)
		return
	track_statistic_human_earned(name, amount, client.player_data.id)
	if(role)
		track_statistic_job_earned(role, name, amount, client.player_data.id)
	if(weapon)
		track_statistic_weapon_earned(weapon, name, amount, client.player_data.id)

//************************
//Stat Procs - kills/death
//************************

//KILLS

/datum/entity/player_stats/human/count_kill(var/role, var/weapon, var/id, var/kill_type, var/amount = 1)
	track_statistic_human_earned(kill_type, amount, id)
	if(role)
		track_statistic_job_earned(role, kill_type, amount, id)
	if(weapon)
		track_statistic_weapon_earned(weapon, kill_type, amount, id)
		recalculate_top_weapon()

//DEATHS
/datum/entity/player_stats/human/count_death(var/role, var/weapon, var/id, var/death_type, var/amount = 1)
	track_statistic_human_earned(death_type, amount, id)
	if(role)
		track_statistic_job_earned(role, death_type, amount, id)