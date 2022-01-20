//STATISTIC GENERAL//
//Caste
/datum/entity/statistic/caste
	var/player_id
	var/caste

BSQL_PROTECT_DATUM(/datum/entity/statistic/caste)
BSQL_PROTECT_DATUM(/datum/entity_meta/statistic_caste)

/datum/entity_meta/statistic_caste
    entity_type = /datum/entity/statistic/caste
    table_name = "log_player_statistic_caste"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "caste" = DB_FIELDTYPE_STRING_LARGE,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/entity_link/player_to_caste_stat
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic/caste
    child_field = "player_id"

    parent_name = "player"
    child_name = "caste"

/datum/view_record/caste
	var/player_id
	var/caste
	var/name
	var/value

/datum/entity_view_meta/statistic_caste_ordered
    root_record_type = /datum/entity/statistic/caste
    destination_entity = /datum/view_record/caste
    fields = list(
        "player_id",
        "caste",
        "name",
        "value"
    )
    order_by = list("value" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_caste_earned(caste, name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic/caste, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("caste", DB_EQUALS, caste),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_caste_earned_callback, caste, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_caste_earned_callback(caste, name, value, player_id, var/list/datum/entity/statistic/caste/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/caste/S = DB_ENTITY(/datum/entity/statistic/caste) // this creates a new record
		S.caste = caste
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	var/datum/entity/statistic/caste/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//Abilities

/datum/entity/statistic/abilities
	var/player_id
	var/caste

BSQL_PROTECT_DATUM(/datum/entity/statistic/abilities)
BSQL_PROTECT_DATUM(/datum/entity_meta/statistic_caste_abilities)

/datum/entity_meta/statistic_caste_abilities
    entity_type = /datum/entity/statistic/abilities
    table_name = "log_player_statistic_caste_abilities"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "caste" = DB_FIELDTYPE_STRING_LARGE,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/entity_link/player_to_caste_ability_stat
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic/abilities
    child_field = "player_id"

    parent_name = "player"
    child_name = "abilities"

/datum/view_record/abilities
	var/player_id
	var/caste
	var/name
	var/value

/datum/entity_view_meta/statistic_caste_abilities_ordered
    root_record_type = /datum/entity/statistic/abilities
    destination_entity = /datum/view_record/abilities
    fields = list(
        "player_id",
        "caste",
        "name",
        "value"
    )
    order_by = list("value" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_caste_ability_earned(caste, name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic/abilities, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("caste", DB_EQUALS, caste),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_caste_ability_earned_callback, caste, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_caste_ability_earned_callback(caste, name, value, player_id, var/list/datum/entity/statistic/abilities/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/abilities/S = DB_ENTITY(/datum/entity/statistic/abilities) // this creates a new record
		S.caste = caste
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	var/datum/entity/statistic/abilities/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//CASTLE ENTITY//


/datum/entity/player_stats/caste
	var/name = null
	var/list/abilities_used = list() // types of /datum/entity/statistic, "tail sweep" = 10, "screech" = 2

/datum/entity/player_stats/caste/proc/get_recalculate()
	for(var/datum/entity/statistic/caste/N in player.CS)
		if(N.caste == name)
			if(!statistic["[N.name]"])
				var/datum/entity/statistic/caste/NN = new()
				NN.name = N.name
				statistic["[N.name]"] = NN
			var/datum/entity/statistic/caste/NNN = statistic["[N.name]"]
			NNN.value = N.value

	for(var/datum/entity/statistic/abilities/N in player.CAS)
		if(N.caste == name)
			if(!abilities_used["[N.name]"])
				var/datum/entity/statistic/abilities/NN = new()
				NN.name = N.name
				abilities_used["[N.name]"] = NN
			var/datum/entity/statistic/abilities/NNN = abilities_used["[N.name]"]
			NNN.value = N.value

/datum/entity/player_stats/caste/recalculate_nemesis()
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

/datum/entity/player_stats/caste/proc/get_kills()
	for(var/statistics in statistic)
		var/datum/entity/statistic/stat_entity = statistic[statistics]
		if(stat_entity.name != "total_kills")
			continue
		total_kills = stat_entity.value