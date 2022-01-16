/datum/entity/player_stats/job
	var/name = null

/datum/entity/player_stats/job/proc/get_recalculate()
	for(var/datum/entity/statistic/niche/N in player.NICHE)
		if(N.niche_statistic_name_first == name)
			if(N.niche_statistic_name_second == STATISTICS_NICHE_KILL)
				total_kills = N.niche_value
			else if(N.niche_statistic_name_last == STATISTICS_NICHE_NICHES)
				if(!niche_stats["[N.niche_statistic_name_second]"])
					var/datum/entity/statistic/NS = new()
					NS.name = N.niche_statistic_name_second
					niche_stats["[N.niche_statistic_name_second]"] = NS
				var/datum/entity/statistic/S = niche_stats["[N.niche_statistic_name_second]"]
				S.value = N.niche_value