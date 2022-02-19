/datum/entity/vending_stat
	var/item
	var/source
	var/count

/datum/entity_meta/vending_stat
	entity_type = /datum/entity/vending_stat
	table_name = "vending_stat"
	hints = DB_TABLEHINT_LOCAL
	field_types = list(
		"item" = DB_FIELDTYPE_STRING_LARGE,
		"source" = DB_FIELDTYPE_STRING_LARGE,
		"count" = DB_FIELDTYPE_BIGINT)

/proc/vending_stat_bump(item_name, source_name, bump_by = 1)
	DB_FILTER(/datum/entity/vending_stat, DB_AND( // find all records (hopefully just one)
		DB_COMP("item", DB_EQUALS, item_name), // about this item
		DB_COMP("source", DB_EQUALS, source_name)), // from this source
		CALLBACK(GLOBAL_PROC, .proc/vending_stat_callback, item_name, source_name, bump_by)) // call the thing when filter is done filtering

/proc/vending_stat_callback(item_name, source_name, bump_by, var/list/datum/entity/vending_stat/stats)
	var/result_length = length(stats)
	if(result_length  == 0) // haven't found an item
		var/datum/entity/vending_stat/WS = DB_ENTITY(/datum/entity/vending_stat) // this creates a new record
		WS.item = item_name
		WS.source = source_name
		WS.count = bump_by
		WS.save() // save it
		return // we are done here

	if(result_length >= 2)
		while(result_length != 1)
			var/datum/entity/vending_stat/WS = stats[2]
			WS.delete()
			result_length--

	var/datum/entity/vending_stat/WS = stats[1] // we ensured this is the only item
	WS.count += bump_by // add the thing
	WS.save() // say we wanna save it