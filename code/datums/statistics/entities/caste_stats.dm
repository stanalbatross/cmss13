/datum/entity/player_stats/caste
	var/name = null
	var/list/abilities_used = list() // types of /datum/entity/statistic, "tail sweep" = 10, "screech" = 2

/datum/entity/player_stats/caste/proc/get_recalculate()
	for(var/datum/entity/statistic/xeno/N in player.CS)
		if(N.name == name)
			if(!statistic["[N.second_name]"])
				var/datum/entity/statistic/xeno/NN = new()
				NN.name = N.second_name
				statistic["[N.second_name]"] = NN
			var/datum/entity/statistic/xeno/NNN = statistic["[N.second_name]"]
			NNN.value = N.value

	for(var/datum/entity/statistic/xeno/N in player.CAS)
		if(N.name == name)
			if(!abilities_used["[N.second_name]"])
				var/datum/entity/statistic/xeno/NN = new()
				NN.name = N.second_name
				abilities_used["[N.second_name]"] = NN
			var/datum/entity/statistic/xeno/NNN = abilities_used["[N.second_name]"]
			NNN.value = N.value

/datum/entity/player_stats/caste/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DS)
		if(!stat_entity.cause_name || stat_entity.role_name != name)
			continue
		causes["[stat_entity.cause_name]"] += 1
		if(!nemesis)
			nemesis = new()
			nemesis.name = stat_entity.cause_name
			nemesis.value = 1
			continue
		if(causes["[stat_entity.cause_name]"] > nemesis.value)
			nemesis.name = stat_entity.cause_name
			nemesis.value = causes["[stat_entity.cause_name]"]

/datum/entity/player_stats/caste/proc/get_kills()
	var/datum/entity/statistic/xeno/stat_entity = statistic["Kill"]
	if(stat_entity)
		total_kills = stat_entity.value