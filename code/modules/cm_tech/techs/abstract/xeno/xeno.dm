/datum/tech/xeno
	name = "Xeno Tech"

	var/hivenumber = XENO_HIVE_NORMAL
	var/datum/hive_status/hive

/datum/tech/xeno/on_tree_insertion(var/datum/techtree/xenomorph/tree)
	. = ..()
	hivenumber = tree.hivenumber
	hive = GLOB.hive_datum[hivenumber]

/datum/tech/xeno/on_unlock(datum/techtree/tree)
	. = ..()
	xeno_message("The hive has unlocked the '[name]' evolution.", 3, hivenumber)
	for(var/m in hive.totalXenos)
		playsound(m, "queen")
