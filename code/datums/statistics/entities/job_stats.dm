/datum/entity/player_stats/job
	var/name = null

/datum/entity/player_stats/job/proc/get_recalculate()
	for(var/datum/entity/statistic/human/N in player.JS)
		if(N.name == name)
			if(!statistic["[N.second_name]"])
				var/datum/entity/statistic/human/NN = new()
				NN.name = N.second_name
				statistic["[N.second_name]"] = NN
			var/datum/entity/statistic/human/NNN = statistic["[N.second_name]"]
			NNN.value = N.value

/datum/entity/player_stats/job/recalculate_nemesis()
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