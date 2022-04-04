/datum/tech/xeno
	name = "Xeno Tech"

/datum/tech/xeno/on_unlock()
	. = ..()
	xeno_message("The hive has unlocked the '[name]' evolution.", 3, faction)
	for(var/m in faction.totalMobs)
		var/mob/M = m
		playsound_client(M.client, "queen")
