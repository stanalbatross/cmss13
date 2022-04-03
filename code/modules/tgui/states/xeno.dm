/**
 * tgui state: hive_state
 *
 * Checks that the user is part of a hive.
 *
 */

GLOBAL_LIST_INIT(hive_state, setup_hive_states())

/proc/setup_hive_states()
	. = list()
	for(var/faction in SET_FACTION_LIST_XENOS)
		var/datum/faction_status/xeno/hive = GLOB.faction_datum[faction]
		.[hive] = new/datum/ui_state/hive_state(hive)

/datum/ui_state/hive_state
	var/hivenumber
	var/datum/faction_status/xeno/hive

/datum/ui_state/hive_state/New(var/datum/faction_status/xeno/Hive)
	. = ..()
	hive = Hive
	hivenumber = hive.faction_number

/datum/ui_state/hive_state/can_use_topic(src_object, mob/user)
	if(hive.is_ally(user))
		return UI_INTERACTIVE
	return UI_CLOSE

/**
 * tgui state: hive_state_queen
 *
 * Checks that the user is part of a hive and is the leading queen of that hive.
 *
 */

GLOBAL_LIST_INIT(hive_state_queen, setup_hive_queen_states())

/proc/setup_hive_queen_states()
	. = list()
	for(var/faction in SET_FACTION_LIST_XENOS)
		var/datum/faction_status/xeno/hive = GLOB.faction_datum[faction]
		.[hive] = new/datum/ui_state/hive_state/queen(hive)

/datum/ui_state/hive_state/queen/can_use_topic(src_object, mob/user)
	. = ..()
	if(. == UI_CLOSE)
		return

	if(hive.living_xeno_queen == user)
		return UI_INTERACTIVE
	return UI_UPDATE
