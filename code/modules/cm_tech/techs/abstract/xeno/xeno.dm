/datum/tech/xeno
	name = "Xeno Tech"

	var/faction_to_get = SET_FACTION_HIVE_NORMAL
	var/datum/faction_status/faction

/datum/tech/xeno/on_tree_insertion(var/datum/techtree/xenomorph/tree)
	. = ..()
	faction_to_get = tree.faction_to_get
	faction = GLOB.faction_datum[faction_to_get]

/datum/tech/xeno/on_unlock()
	. = ..()
	xeno_message("The hive has unlocked the '[name]' evolution.", 3, hivenumber)
	for(var/m in hive.totalXenos)
		var/mob/M = m
		playsound_client(M.client, "queen")
