//STATISTIC GENERAL//

/datum/entity/statistic
	var/player_id
	var/name
	var/value
//STATISTIC GENERAL END//


////////////////////
//SECOND STATISTIC//
////////////////////
//HUMAN
/datum/entity/statistic/human
	var/type_s
	var/second_name


/datum/entity_meta/statistic_human
    entity_type = /datum/entity/statistic/human
    table_name = "log_player_statistic_human"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "type_s" = DB_FIELDTYPE_STRING_LARGE,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "second_name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

//TRACK
/proc/track_statistic_human_earned(type_s, name, second_name, value, player_id)
	if(!player_id || !type_s || !name)
		return

	DB_FILTER(/datum/entity/statistic/human, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("type_s", DB_EQUALS, type_s),
		DB_COMP("name", DB_EQUALS, name),
		DB_COMP("second_name", DB_EQUALS, second_name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_human_earned_callback, type_s, name, second_name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_human_earned_callback(type_s, name, second_name, value, player_id, var/list/datum/entity/statistic/human/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/human/S = DB_ENTITY(/datum/entity/statistic/human) // this creates a new record
		S.type_s = type_s
		S.name = name
		S.second_name = second_name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	if(result_length >= 2)
		while(result_length != 1)
			var/datum/entity/statistic/human/S = stats[2]
			S.delete()
			result_length--

	var/datum/entity/statistic/human/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it
//HUMAN END

//XENO
/datum/entity/statistic/xeno
	var/type_s
	var/second_name


/datum/entity_meta/statistic_xeno
    entity_type = /datum/entity/statistic/xeno
    table_name = "log_player_statistic_xeno"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "type_s" = DB_FIELDTYPE_STRING_LARGE,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "second_name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

//TRACK
/proc/track_statistic_xeno_earned(type_s, name, second_name, value, player_id)
	if(!player_id || !type_s || !name)
		return

	DB_FILTER(/datum/entity/statistic/xeno, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("type_s", DB_EQUALS, type_s),
		DB_COMP("name", DB_EQUALS, name),
		DB_COMP("second_name", DB_EQUALS, second_name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_xeno_earned_callback, type_s, name, second_name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_xeno_earned_callback(type_s, name, second_name, value, player_id, var/list/datum/entity/statistic/xeno/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/xeno/S = DB_ENTITY(/datum/entity/statistic/xeno) // this creates a new record
		S.type_s = type_s
		S.name = name
		S.second_name = second_name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	if(result_length >= 2)
		while(result_length != 1)
			var/datum/entity/statistic/xeno/S = stats[2]
			S.delete()
			result_length--

	var/datum/entity/statistic/xeno/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it
//XENO END
////////////////////////
//SECOND STATISTIC END//
////////////////////////

//PLAYER ENTITY//

/datum/entity/player_entity
	var/name
	var/ckey // "cakey"
	var/list/datum/entity/player_stats = list()
	var/datum/entity/player/player
	var/list/datum/entity/statistic/death/DS = list()
	var/list/datum/entity/statistic/medal/MS = list()
	var/list/datum/entity/statistic/xeno/XS = list()
	var/list/datum/entity/statistic/xeno/CS = list()
	var/list/datum/entity/statistic/xeno/CAS = list()
	var/list/datum/entity/statistic/human/HS = list()
	var/list/datum/entity/statistic/human/JS = list()
	var/list/datum/entity/statistic/human/WS = list()
	var/menu = 0
	var/subMenu = 0
	var/dataMenu = 0
	var/data[0]
	var/path

/datum/entity/player_entity/proc/setup_human_stats()
	if(player_stats["human"] && !isnull(player_stats["human"]))
		return player_stats["human"]
	var/datum/entity/player_stats/human/new_stat = new()
	new_stat.player = src
	player_stats["human"] = new_stat
	return new_stat

/datum/entity/player_entity/proc/setup_xeno_stats()
	if(player_stats["xeno"] && !isnull(player_stats["xeno"]))
		return player_stats["xeno"]
	var/datum/entity/player_stats/xeno/new_stat = new()
	new_stat.player = src
	player_stats["xeno"] = new_stat
	return new_stat
