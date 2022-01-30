/datum/entity/player_entity/proc/show_statistics(mob/user, var/datum/entity/statistic/round/viewing_round = round_statistics, var/update_data = FALSE)
	if(update_data)
		update_panel_data(round_statistics)
	ui_interact(user)

/datum/entity/player_entity/proc/ui_interact(mob/user, ui_key = "statistics", var/datum/nanoui/ui = null, var/force_open = 1)
	data["menu"] = menu
	data["subMenu"] = subMenu
	data["dataMenu"] = dataMenu

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "cm_stat_panel.tmpl", "Statistics", 450, 700, null, -1)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)

/datum/entity/player_entity/Topic(href, href_list)
	var/mob/user = usr
	user.set_interaction(src)

	if(href_list["menu"])
		menu = href_list["menu"]
	if(href_list["subMenu"])
		subMenu = href_list["subMenu"]
	if(href_list["dataMenu"])
		dataMenu = href_list["dataMenu"]

	nanomanager.update_uis(src)

/datum/entity/player_entity/proc/check_eye()
	return

/datum/entity/statistic/round/proc/show_kill_feed(mob/user)
	ui_interact(user)

/datum/entity/statistic/round/proc/ui_interact(mob/user, ui_key = "kills", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, death_data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "cm_kill_panel.tmpl", "Kill Feed", 800, 900, null, -1)
		ui.set_initial_data(death_data)
		ui.open()
		ui.set_auto_update(1)

/datum/entity/statistic/round/proc/check_eye()
	return

//*******************************************************
//*******************PLAYER DATA*************************
//*******************************************************

/datum/entity/player_entity/proc/update_panel_data(var/datum/entity/statistic/round/viewing_round = round_statistics)
	data["current_time"] = "[time2text(world.timeofday, "hh:mm.ss")]"

	if(viewing_round)
		viewing_round.update_panel_data()
		data["round"] = viewing_round.round_data["round"]

	if(player_stats["human"])
		var/datum/entity/player_stats/human/H = player_stats["human"]
		var/list/death_list = list()
		var/list/medal_list = list()
		var/list/weapon_stats_list = list()
		var/list/job_stats_list = list()
		var/list/statistic_list = list()
		var/list/top_weapon = null
		var/list/human_nemesis = null

		if(H.nemesis)
			human_nemesis = list("name" = H.nemesis.name, "value" = H.nemesis.value)


		if(H.top_weapon)
			var/list/top_weapon_statistic_list = list()
			for(var/iteration in H.top_weapon.statistic)
				var/datum/entity/statistic/weapon/S = H.top_weapon.statistic[iteration]
				top_weapon_statistic_list += list(list("name" = S.name, "value" = S.value))
			top_weapon = list(
				"name" = sanitize(H.top_weapon.name),
				"statistic" = top_weapon_statistic_list
			)

		for(var/iteration in H.statistic)
			var/datum/entity/statistic/S = H.statistic[iteration]
			statistic_list += list(list("name" = S.name, "value" = S.value))

		for(var/datum/entity/statistic/medal/M in MS)
			medal_list += list(list(
				"medal_type" = sanitize(M.medal_type),
				"recipient" = sanitize(M.recipient_name),
				"recipient_job" = sanitize(M.recipient_role),
				"citation" = sanitize(M.citation),
				"giver" = sanitize(M.giver_name)
			))

		for(var/datum/entity/statistic/death/SD in DS)
			if(SD.faction_name != "Normal Hive")
				var/list/damage_list = list()
				if(SD.total_brute)
					damage_list += list(list("name" = "brute", "value" = SD.total_brute))
				if(SD.total_burn)
					damage_list += list(list("name" = "burn", "value" = SD.total_burn))
				if(SD.total_oxy)
					damage_list += list(list("name" = "oxy", "value" = SD.total_oxy))
				if(SD.total_tox)
					damage_list += list(list("name" = "tox", "value" = SD.total_tox))
				death_list += list(list(
					"mob_name" = sanitize(SD.mob_name),
					"job_name" = SD.role_name,
					"area_name" = sanitize(SD.area_name),
					"cause_name" = sanitize(SD.cause_name),
					"total_kills" = SD.total_kills,
					"total_damage" = damage_list,
					"time_of_death" = SD.time_of_death,
					"total_time_alive" = SD.total_time_alive,
					"total_damage_taken" = SD.total_damage_taken,
					"x" = SD.x,
					"y" = SD.y,
					"z" = SD.z
				))

		for(var/iteration in H.weapon_stats_list)
			var/datum/entity/player_stats/weapon/S = H.weapon_stats_list[iteration]
			if(!S.display_stat)
				continue
			var/list/weapon_statistic_list = list()

			for(var/sub_iteration in S.statistic)
				var/datum/entity/statistic/weapon/D = S.statistic[sub_iteration]
				weapon_statistic_list += list(list("name" = D.name, "value" = D.value))

			weapon_stats_list += list(list(
				"name" = sanitize(S.name),
				"statistic" = weapon_statistic_list
			))

		for(var/iteration in H.job_stats_list)
			var/datum/entity/player_stats/job/S = H.job_stats_list[iteration]
			if(!S.display_stat)
				continue
			var/list/job_death_list = list()
			var/list/job_statistic_list = list()
			var/list/job_nemesis = null

			if(S.nemesis)
				job_nemesis = list("name" = S.nemesis.name, "value" = S.nemesis.value)

			for(var/sub_iteration in S.statistic)
				var/datum/entity/statistic/job/D = S.statistic[sub_iteration]
				job_statistic_list += list(list("name" = D.name, "value" = D.value))

			for(var/datum/entity/statistic/death/SD in DS)
				if(SD.role_name == S.name)
					if(job_death_list.len >= STATISTICS_DEATH_LIST_LEN)
						break
					var/list/damage_list = list()
					if(SD.total_brute)
						damage_list += list(list("name" = "brute", "value" = SD.total_brute))
					if(SD.total_burn)
						damage_list += list(list("name" = "burn", "value" = SD.total_burn))
					if(SD.total_oxy)
						damage_list += list(list("name" = "oxy", "value" = SD.total_oxy))
					if(SD.total_tox)
						damage_list += list(list("name" = "tox", "value" = SD.total_tox))
					var/list/job_new_death = list(list(
						"mob_name" = sanitize(SD.mob_name),
						"job_name" = SD.role_name,
						"area_name" = sanitize(SD.area_name),
						"cause_name" = sanitize(SD.cause_name),
						"total_kills" = SD.total_kills,
						"total_damage" = damage_list,
						"time_of_death" = SD.time_of_death,
						"total_time_alive" = SD.total_time_alive,
						"total_damage_taken" = SD.total_damage_taken,
						"x" = SD.x,
						"y" = SD.y,
						"z" = SD.z
					))
					if(job_death_list.len < STATISTICS_DEATH_LIST_LEN)
						job_death_list += job_new_death

			job_stats_list += list(list(
				"name" = S.name,
				"nemesis" = job_nemesis,
				"death_list" = job_death_list,
				"statistic" = job_statistic_list
			))

		data["human"] = list(
			"nemesis" = human_nemesis,
			"medal_list" = medal_list,
			"death_list" = death_list,
			"weapon_stats_list" = weapon_stats_list,
			"job_stats_list" = job_stats_list,
			"statistic" = statistic_list,
			"top_weapon" = top_weapon
		)

	if(player_stats["xeno"])
		var/datum/entity/player_stats/xeno/H = player_stats["xeno"]
		var/list/death_list = list()
		var/list/caste_stats_list = list()
		var/list/statistic_list = list()
		var/list/top_caste = null
		var/list/xeno_nemesis = null

		if(H.nemesis)
			xeno_nemesis = list("name" = H.nemesis.name, "value" = H.nemesis.value)

		if(H.top_caste)
			var/list/top_caste_statistic_list = list()
			for(var/iteration in H.top_caste.statistic)
				var/datum/entity/statistic/caste/S = H.top_caste.statistic[iteration]
				top_caste_statistic_list += list(list("name" = S.name, "value" = S.value))
			top_caste = list(
				"name" = H.top_caste.name,
				"statistic" = top_caste_statistic_list
			)

		for(var/iteration in H.statistic)
			var/datum/entity/statistic/S = H.statistic[iteration]
			statistic_list += list(list("name" = S.name, "value" = S.value))

		for(var/datum/entity/statistic/death/SD in DS)
			if(SD.faction_name == "Normal Hive")
				var/list/damage_list = list()
				if(SD.total_brute)
					damage_list += list(list("name" = "brute", "value" = SD.total_brute))
				if(SD.total_burn)
					damage_list += list(list("name" = "burn", "value" = SD.total_burn))
				if(SD.total_oxy)
					damage_list += list(list("name" = "oxy", "value" = SD.total_oxy))
				if(SD.total_tox)
					damage_list += list(list("name" = "tox", "value" = SD.total_tox))
				death_list += list(list(
					"mob_name" = sanitize(SD.mob_name),
					"job_name" = SD.role_name,
					"area_name" = sanitize(SD.area_name),
					"cause_name" = sanitize(SD.cause_name),
					"total_kills" = SD.total_kills,
					"total_damage" = damage_list,
					"time_of_death" = SD.time_of_death,
					"total_time_alive" = SD.total_time_alive,
					"total_damage_taken" = SD.total_damage_taken,
					"x" = SD.x,
					"y" = SD.y,
					"z" = SD.z
				))

		for(var/iteration in H.caste_stats_list)
			var/datum/entity/player_stats/caste/S = H.caste_stats_list[iteration]
			if(!S.display_stat)
				continue
			var/list/caste_abilities_used = list()
			var/list/caste_death_list = list()
			var/list/caste_statistic_list = list()
			var/list/caste_nemesis = null

			if(S.nemesis)
				caste_nemesis = list("name" = S.nemesis.name, "value" = S.nemesis.value)

			for(var/sub_iteration in S.abilities_used)
				var/datum/entity/statistic/abilities/D = S.abilities_used[sub_iteration]
				caste_abilities_used += list(list("name" = D.name, "value" = D.value))

			for(var/sub_iteration in S.statistic)
				var/datum/entity/statistic/caste/D = S.statistic[sub_iteration]
				caste_statistic_list += list(list("name" = D.name, "value" = D.value))

			for(var/datum/entity/statistic/death/SD in DS)
				if(SD.faction_name == "Normal Hive")
					var/list/damage_list = list()
					if(SD.total_brute)
						damage_list += list(list("name" = "brute", "value" = SD.total_brute))
					if(SD.total_burn)
						damage_list += list(list("name" = "burn", "value" = SD.total_burn))
					if(SD.total_oxy)
						damage_list += list(list("name" = "oxy", "value" = SD.total_oxy))
					if(SD.total_tox)
						damage_list += list(list("name" = "tox", "value" = SD.total_tox))
					caste_death_list += list(list(
						"mob_name" = sanitize(SD.mob_name),
						"job_name" = SD.role_name,
						"area_name" = sanitize(SD.area_name),
						"cause_name" = sanitize(SD.cause_name),
						"total_kills" = SD.total_kills,
						"total_damage" = damage_list,
						"time_of_death" = SD.time_of_death,
						"total_time_alive" = SD.total_time_alive,
						"x" = SD.x,
						"y" = SD.y,
						"z" = SD.z
					))

			caste_stats_list += list(list(
				"name" = S.name,
				"nemesis" = caste_nemesis,
				"death_list" = caste_death_list,
				"abilities_used" = caste_abilities_used,
				"statistic" = caste_statistic_list
			))

		data["xeno"] = list(
			"nemesis" = xeno_nemesis,
			"death_list" = death_list,
			"caste_stats_list" = caste_stats_list,
			"statistic" = statistic_list,
			"top_caste" = top_caste
		)

//*******************************************************
//*******************ROUND DATA**************************
//*******************************************************

/datum/entity/statistic/round/proc/update_panel_data()
	var/map_name
	if(current_map)
		map_name = current_map.name

	var/list/participants_list = list()
	var/list/hijack_participants_list = list()
	var/list/final_participants_list = list()
	var/list/total_deaths_list = list()
	var/list/new_death_stats_list = list()

	for(var/iteration in participants)
		var/datum/entity/statistic/S = participants[iteration]
		participants_list += list(list("name" = S.name, "value" = S.value))

	for(var/iteration in hijack_participants)
		var/datum/entity/statistic/S = hijack_participants[iteration]
		hijack_participants_list += list(list("name" = S.name, "value" = S.value))

	for(var/iteration in final_participants)
		var/datum/entity/statistic/S = final_participants[iteration]
		final_participants_list += list(list("name" = S.name, "value" = S.value))

	for(var/iteration in total_deaths)
		var/datum/entity/statistic/S = total_deaths[iteration]
		total_deaths_list += list(list("name" = S.name, "value" = S.value))

	for(var/datum/entity/statistic/death/S in death_stats_list)
		if(new_death_stats_list.len >= STATISTICS_DEATH_LIST_LEN)
			break
		var/list/damage_list = list()
		if(S.total_brute)
			damage_list += list(list("name" = "brute", "value" = S.total_brute))
		if(S.total_burn)
			damage_list += list(list("name" = "burn", "value" = S.total_burn))
		if(S.total_oxy)
			damage_list += list(list("name" = "oxy", "value" = S.total_oxy))
		if(S.total_tox)
			damage_list += list(list("name" = "tox", "value" = S.total_tox))

		var/death = list(list(
			"mob_name" = sanitize(S.mob_name),
			"job_name" = S.role_name,
			"area_name" = sanitize(S.area_name),
			"cause_name" = sanitize(S.cause_name),
			"total_kills" = S.total_kills,
			"total_damage" = damage_list,
			"time_of_death" = S.time_of_death,
			"total_time_alive" = S.total_time_alive,
			"total_damage_taken" = S.total_damage_taken,
			"x" = S.x,
			"y" = S.y,
			"z" = S.z
		))
		if(new_death_stats_list.len < STATISTICS_DEATH_LIST_LEN)
			new_death_stats_list += death

	death_data["death_stats_list"] = new_death_stats_list
	round_data["round"] = list(
		"name" = round_name,
		"game_mode" = game_mode,
		"map_name" = map_name,
		"round_result" = round_result,
		"real_time_start" = real_time_start,
		"real_time_end" = real_time_end,
		"round_length" = round_length,
		"round_hijack_time" = round_hijack_time,
		"end_round_player_population" = end_round_player_population,
		"total_projectiles_fired" = total_projectiles_fired,
		"total_projectiles_hit" = total_projectiles_hit,
		"total_projectiles_hit_human" = total_projectiles_hit_human,
		"total_projectiles_hit_xeno" = total_projectiles_hit_xeno,
		"total_slashes" = total_slashes,
		"total_friendly_fire_instances" = total_friendly_fire_instances,
		"total_friendly_fire_kills" = total_friendly_fire_kills,
		"total_huggers_applied" = total_huggers_applied,
		"total_larva_burst" = total_larva_burst,
		"participants" = participants_list,
		"hijack_participants" = hijack_participants_list,
		"final_participants" = final_participants_list,
		"total_deaths" = total_deaths_list,
	)
