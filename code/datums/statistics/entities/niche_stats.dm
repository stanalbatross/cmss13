/datum/entity/statistic/niche
	var/player_id
	var/niche_statistic_name_primary
	var/niche_statistic_name_first
	var/niche_statistic_name_second
	var/niche_statistic_name_last
	var/niche_value

BSQL_PROTECT_DATUM(/datum/entity/statistic/niche)

/datum/entity_meta/statistic_niche
    entity_type = /datum/entity/statistic/niche
    table_name = "log_player_statistic_niche"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "niche_statistic_name_primary" = DB_FIELDTYPE_STRING_LARGE,
        "niche_statistic_name_first" = DB_FIELDTYPE_STRING_LARGE,
        "niche_statistic_name_second" = DB_FIELDTYPE_STRING_LARGE,
        "niche_statistic_name_last" = DB_FIELDTYPE_STRING_LARGE,
        "niche_value" = DB_FIELDTYPE_INT
    )

/datum/entity_meta/statistic_niche/on_insert(var/datum/entity/statistic/niche/player)
    player.niche_value = 0

/datum/entity_link/player_to_niche
    parent_entity = /datum/entity/player
    child_entity = /datum/entity/statistic/niche
    child_field = "player_id"

    parent_name = "player"
    child_name = "niche"

/datum/view_record/statistic_niche
	var/player_id
	var/niche_statistic_name_primary
	var/niche_statistic_name_first
	var/niche_statistic_name_second
	var/niche_statistic_name_last
	var/niche_value

/datum/entity_view_meta/statistic_niche_ordered
    root_record_type = /datum/entity/statistic/niche
    destination_entity = /datum/view_record/statistic_niche
    fields = list(
        "player_id",
        "niche_statistic_name_primary",
        "niche_statistic_name_first",
        "niche_statistic_name_second",
        "niche_statistic_name_last",
        "niche_value"
    )
    order_by = list("player_id" = DB_ORDER_BY_DESC)

/proc/track_niche_earned(niche_statistic_name_primary, niche_statistic_name_first, niche_statistic_name_second, niche_statistic_name_last, niche_value, player_id)
	DB_FILTER(/datum/entity/statistic/niche, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("niche_statistic_name_primary", DB_EQUALS, niche_statistic_name_primary),
		DB_COMP("niche_statistic_name_first", DB_EQUALS, niche_statistic_name_first),
		DB_COMP("niche_statistic_name_second", DB_EQUALS, niche_statistic_name_second),
		DB_COMP("niche_statistic_name_last", DB_EQUALS, niche_statistic_name_last)),
		CALLBACK(GLOBAL_PROC, .proc/track_niche_earned_callback, niche_statistic_name_primary, niche_statistic_name_first, niche_statistic_name_second, niche_statistic_name_last, niche_value, player_id)) // call the thing when filter is done filtering

/proc/track_niche_earned_callback(niche_statistic_name_primary, niche_statistic_name_first, niche_statistic_name_second, niche_statistic_name_last, niche_value, player_id, var/list/datum/entity/statistic/niche/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/niche/N = DB_ENTITY(/datum/entity/statistic/niche) // this creates a new record
		N.niche_statistic_name_primary = niche_statistic_name_primary
		N.niche_statistic_name_first = niche_statistic_name_first
		N.niche_statistic_name_second = niche_statistic_name_second
		N.niche_statistic_name_last = niche_statistic_name_last
		N.niche_value = niche_value
		N.player_id = player_id
		N.save() // save it
		return // we are done here

	var/datum/entity/statistic/niche/N = stats[1] // we ensured this is the only item
	N.niche_value += niche_value // add the thing
	N.save() // say we wanna save it