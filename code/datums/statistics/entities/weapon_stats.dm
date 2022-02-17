/datum/entity/player_stats/weapon
	var/name = null

/datum/entity/player_stats/weapon/proc/get_recalculate()
	for(var/datum/entity/statistic/human/N in player.WS)
		if(N.name == name)
			if(!statistic["[N.second_name]"])
				var/datum/entity/statistic/NN = new()
				NN.name = N.second_name
				statistic["[N.second_name]"] = NN
			var/datum/entity/statistic/NNN = statistic["[N.second_name]"]
			NNN.value = N.value

/datum/entity/player_stats/weapon/proc/get_kills()
	for(var/statistics in statistic)
		var/datum/entity/statistic/human/stat_entity = statistic["total_kills"]
		total_kills = stat_entity.value
