//STATISTIC GENERAL//

/datum/entity/statistic/weapon
	var/player_id
	var/weapon

BSQL_PROTECT_DATUM(/datum/entity/statistic/weapon)
BSQL_PROTECT_DATUM(/datum/entity_meta/statistic_weapon)

/datum/entity_meta/statistic_weapon
    entity_type = /datum/entity/statistic/weapon
    table_name = "log_player_statistic_weapon"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "weapon" = DB_FIELDTYPE_STRING_LARGE,
        "name" = DB_FIELDTYPE_STRING_LARGE,
        "value" = DB_FIELDTYPE_INT
    )

/datum/view_record/weapon
	var/player_id
	var/weapon
	var/name
	var/value

/datum/entity_view_meta/statistic_weapon_ordered
    root_record_type = /datum/entity/statistic/weapon
    destination_entity = /datum/view_record/weapon
    fields = list(
        "player_id",
        "weapon",
        "name",
        "value"
    )
    order_by = list("value" = DB_ORDER_BY_DESC)


//TRACK

/proc/track_statistic_weapon_earned(weapon, name, value, player_id)
	if(!player_id || !name)
		return
	DB_FILTER(/datum/entity/statistic/weapon, DB_AND( // find all records (hopefully just one)
		DB_COMP("player_id", DB_EQUALS, player_id),
		DB_COMP("weapon", DB_EQUALS, weapon),
		DB_COMP("name", DB_EQUALS, name)),
		CALLBACK(GLOBAL_PROC, .proc/track_statistic_weapon_earned_callback, weapon, name, value, player_id)) // call the thing when filter is done filtering

/proc/track_statistic_weapon_earned_callback(weapon, name, value, player_id, var/list/datum/entity/statistic/weapon/stats)
	var/result_length = length(stats)
	if(result_length == 0) // haven't found an item
		var/datum/entity/statistic/weapon/S = DB_ENTITY(/datum/entity/statistic/weapon) // this creates a new record
		S.weapon = weapon
		S.name = name
		S.value = value
		S.player_id = player_id
		S.save() // save it
		return // we are done here

	if(result_length >= 2)
		while(result_length == 1)
			var/datum/entity/statistic/weapon/S = stats[2]
			S.delete()
			result_length--

	var/datum/entity/statistic/weapon/S = stats[1] // we ensured this is the only item
	S.value += value // add the thing
	S.save() // say we wanna save it


//WEAPON ENTITY//

/datum/entity/player_stats/weapon
	var/name = null

/datum/entity/player_stats/weapon/proc/get_recalculate()
	for(var/datum/entity/statistic/weapon/N in player.WS)
		if(N.weapon == name)
			if(!statistic["[N.name]"])
				var/datum/entity/statistic/weapon/NN = new()
				NN.name = N.name
				statistic["[N.name]"] = NN
			var/datum/entity/statistic/weapon/NNN = statistic["[N.name]"]
			NNN.value = N.value

/datum/entity/player_stats/weapon/proc/get_kills()
	for(var/statistics in statistic)
		var/datum/entity/statistic/stat_entity = statistic[statistics]
		if(stat_entity.name != "total_kills")
			continue
		total_kills = stat_entity.value
