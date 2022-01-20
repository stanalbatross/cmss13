//STATISTIC GENERAL//

/datum/entity/statistic/job
	var/player_id
	var/job

BSQL_PROTECT_DATUM(/datum/entity/statistic/job)
BSQL_PROTECT_DATUM(/datum/entity_meta/statistic_job)

/datum/entity_meta/statistic_job
    entity_type = /datum/entity/statistic/job
    table_name = "log_player_statistic_job"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "job" = DB_FIELDTYPE_STRING_LARGE,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/entity_link/player_to_job_stat
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic/job
    child_field = "player_id"

    parent_name = "player"
    child_name = "job"

/datum/view_record/job
	var/player_id
	var/job
	var/name
	var/value

/datum/entity_view_meta/statistic_job_ordered
    root_record_type = /datum/entity/statistic/job
    destination_entity = /datum/view_record/job
    fields = list(
        "player_id",
        "job",
        "name",
        "value"
    )
    order_by = list("value" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_job_earned(job, name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic/job, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("job", DB_EQUALS, job),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_job_earned_callback, job, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_job_earned_callback(job, name, value, player_id, var/list/datum/entity/statistic/job/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/job/S = DB_ENTITY(/datum/entity/statistic/job) // this creates a new record
		S.job = job
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	var/datum/entity/statistic/job/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//JOB ENTITY//

/datum/entity/player_stats/job
	var/name = null

/datum/entity/player_stats/job/proc/get_recalculate()
	for(var/datum/entity/statistic/job/N in player.JS)
		if(N.job == name)
			if(!statistic["[N.name]"])
				var/datum/entity/statistic/job/NN = new()
				NN.name = N.name
				statistic["[N.name]"] = NN
			var/datum/entity/statistic/job/NNN = statistic["[N.name]"]
			NNN.value = N.value

/datum/entity/player_stats/job/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DS)
		if(!stat_entity.cause_name || stat_entity.role_name != name)
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

/datum/entity/player_stats/job/proc/get_kills()
	for(var/statistics in statistic)
		var/datum/entity/statistic/stat_entity = statistic[statistics]
		if(stat_entity.name != "total_kills")
			continue
		total_kills = stat_entity.value