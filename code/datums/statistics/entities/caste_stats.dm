/datum/entity/player_stats/caste
	var/name = null
	var/list/abilities_used = list() // types of /datum/entity/statistic, "tail sweep" = 10, "screech" = 2

/datum/entity/player_stats/caste/proc/get_recalculate()
	for(var/datum/entity/statistic/niche/N in player.NICHE)
		if(N.niche_statistic_name_first == name)
			if(N.niche_statistic_name_second == STATISTICS_NICHE_KILL)
				total_kills = N.niche_value
			else if(N.niche_statistic_name_second == STATISTICS_NICHE_ABILITES)
				if(!niche_stats["[N.niche_statistic_name_second]"])
					var/datum/entity/statistic/NS = new()
					NS.name = N.niche_statistic_name_second
					niche_stats["[N.niche_statistic_name_second]"] = NS
				var/datum/entity/statistic/S = niche_stats["[N.niche_statistic_name_second]"]
				S.value = N.niche_value
			else if(N.niche_statistic_name_last == STATISTICS_NICHE_NICHES)
				if(!niche_stats["[N.niche_statistic_name_second]"])
					var/datum/entity/statistic/NS = new()
					NS.name = N.niche_statistic_name_second
					niche_stats["[N.niche_statistic_name_second]"] = NS
				var/datum/entity/statistic/S = niche_stats["[N.niche_statistic_name_second]"]
				S.value = N.niche_value

/datum/entity/player_stats/caste/recalculate_nemesis()
	var/list/causes = list()
	for(var/datum/entity/statistic/death/stat_entity in player.DEATHS)
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