//STATISTIC GENERAL//

/datum/entity/statistic
	var/name
	var/value

/*
/datum/entity_meta/statistic
    entity_type = /datum/entity/statistic/caste
    table_name = "log_player_statistic"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/entity_meta/statistic/on_insert(var/datum/entity/statistic/player)
    player.value = 0

/datum/entity_link/player_to_caste
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic
    child_field = "player_id"

    parent_name = "player"
    child_name = "statistic"

/datum/view_record/statistic
	var/player_id
	var/name
	var/value

/datum/entity_view_meta/statistic_ordered
    root_record_type = /datum/entity/statistic
    destination_entity = /datum/view_record/statistic
    fields = list(
        "player_id",
        "name",
        "value"
    )
    order_by = list("player_id" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_earned(name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_earned_callback, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_earned_callback(name, value, player_id, var/list/datum/entity/statistic/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/S = DB_ENTITY(/datum/entity/statistic) // this creates a new record
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	var/datum/entity/statistic/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//PLAYER ENTITY//
*/
/datum/entity/player_entity
	var/name
	var/ckey // "cakey"
	var/list/datum/entity/player_stats = list()
	var/datum/entity/player/player
	var/list/datum/entity/statistic/death/DS = list()
	var/list/datum/entity/statistic/medal/MS = list()
	var/list/datum/entity/statistic/human/HS = list()
	var/list/datum/entity/statistic/xeno/XS = list()
	var/list/datum/entity/statistic/caste/CS = list()
	var/list/datum/entity/statistic/abilities/CAS = list()
	var/list/datum/entity/statistic/job/JS = list()
	var/list/datum/entity/statistic/weapon/WS = list()
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
