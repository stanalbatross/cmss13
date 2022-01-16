/datum/entity/player_entity/proc/setup_entity(var/datum/entity/statistic/round/round_statistics)
	set waitfor=0
	WAIT_DB_READY
	var/datum/entity/player_stats/human/human_stats = setup_human_stats()
	var/datum/entity/player_stats/xeno/xeno_stats = setup_xeno_stats()
	xeno_stats.get_recalculate()
	human_stats.get_recalculate()
	human_stats.recalculate_nemesis()
	xeno_stats.recalculate_nemesis()
	xeno_stats.recalculate_top_caste()
	human_stats.recalculate_top_weapon()
	update_panel_data(round_statistics)