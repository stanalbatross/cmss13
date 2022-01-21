//STATISTIC GENERAL//

/datum/entity/statistic/xeno
	var/player_id

BSQL_PROTECT_DATUM(/datum/entity/statistic/xeno)
BSQL_PROTECT_DATUM(/datum/entity_meta/statistic_xeno)

/datum/entity_meta/statistic_xeno
    entity_type = /datum/entity/statistic/xeno
    table_name = "log_player_statistic_xeno"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/entity_link/player_to_xeno_stat
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic/xeno
    child_field = "player_id"

    parent_name = "player"
    child_name = "xeno"

/datum/view_record/xeno
	var/player_id
	var/name
	var/value

/datum/entity_view_meta/statistic_xeno_ordered
    root_record_type = /datum/entity/statistic/xeno
    destination_entity = /datum/view_record/xeno
    fields = list(
        "player_id",
        "name",
        "value"
    )
    order_by = list("value" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_xeno_earned(name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic/xeno, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_xeno_earned_callback, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_xeno_earned_callback(name, value, player_id, var/list/datum/entity/statistic/xeno/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/xeno/S = DB_ENTITY(/datum/entity/statistic/xeno) // this creates a new record
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	var/datum/entity/statistic/xeno/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//XENO ENTITY//

/datum/entity/player_stats/xeno
	var/datum/entity/player_stats/caste/top_caste = null // reference to /datum/entity/player_stats/caste (i.e. ravager)
	var/list/caste_stats_list = list() // list of types /datum/entity/player_stats/caste

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/xeno/proc/get_recalculate()
	for(var/datum/entity/statistic/xeno/N in player.XS)
		if(!statistic["[N.name]"])
			var/datum/entity/statistic/xeno/NN = new()
			NN.name = N.name
			statistic["[N.name]"] = NN
		var/datum/entity/statistic/xeno/NNN = statistic["[N.name]"]
		NNN.value = N.value
	for(var/datum/entity/statistic/caste/N in player.CS)
		setup_caste_stats(N.caste)

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
	for(var/datum/entity/statistic/death/stat_entity in player.DS)
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
		track_statistic_caste_earned(caste, STATISTICS_ROUNDS_PLAYED, 1, client.player_data.id)

/mob/living/carbon/Xenomorph/proc/track_ability_usage(var/ability, var/caste, var/amount = 1)
	if(statistic_exempt || !client || !mind)
		return
	if(caste)
		track_statistic_caste_ability_earned(caste, ability, amount, client.player_data.id)

/mob/living/carbon/Xenomorph/track_steps_walked(var/amount = 1, var/name = STATISTICS_STEPS_WALKED)
	if(statistic_exempt || !client || !mind)
		return
	track_statistic_xeno_earned(name, amount, client.player_data.id)
	if(caste_type)
		track_statistic_caste_earned(caste_type, name, amount, client.player_data.id)

/mob/living/carbon/Xenomorph/proc/track_slashes(var/caste, var/amount = 1, var/name = STATISTICS_SLASH)
	if(statistic_exempt || !client || !mind)
		return
	track_statistic_xeno_earned(name, amount, client.player_data.id)
	if(caste)
		track_statistic_caste_earned(caste, name, amount, client.player_data.id)

/datum/entity/player_stats/xeno/count_statistic_stat(var/client/client, var/name, var/amount = 1, var/caste)
	if(!name)
		return
	track_statistic_xeno_earned(name, amount, client.player_data.id)
	if(caste)
		track_statistic_caste_earned(caste, name, amount, client.player_data.id)

//************************
//Stat Procs - kills/death
//************************

//KILLS
/datum/entity/player_stats/xeno/count_kill(var/role, var/weapon, var/id, var/kill_type, var/amount = 1)
	track_statistic_xeno_earned(kill_type, amount, id)
	if(role)
		track_statistic_caste_earned(role, kill_type, amount, id)
		recalculate_top_caste()

//DEATHS
/datum/entity/player_stats/xeno/count_death(var/role, var/weapon, var/id, var/death_type, var/amount = 1)
	track_statistic_xeno_earned(death_type, amount, id)
	if(role)
		track_statistic_caste_earned(role, death_type, amount, id)
		recalculate_top_caste()