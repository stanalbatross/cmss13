/datum/entity/statistic/round
	var/round_id

	var/round_name
	var/map_name
	var/game_mode

	var/real_time_start = 0 // GMT-based 11:04
	var/real_time_end = 0 // GMT-based 12:54
	var/round_length = 0 // current-time minus round-start time
	var/round_hijack_time = 0 //hijack time in-round
	var/round_result // "xeno_minor"
	var/end_round_player_population = 0

	var/total_huggers_applied = 0
	var/total_larva_burst = 0

	var/defcon_level = 5
	var/objective_points = 0
	var/total_objective_points = 0

	var/total_projectiles_fired = 0
	var/total_projectiles_hit = 0
	var/total_projectiles_hit_human = 0
	var/total_projectiles_hit_xeno = 0
	var/total_friendly_fire_instances = 0
	var/total_friendly_fire_kills = 0
	var/total_slashes = 0

	// untracked data
	var/datum/entity/statistic/map/current_map = null // reference to current map
	var/list/datum/entity/statistic/death/death_stats_list = list()

	var/list/abilities_used = list() // types of /datum/entity/statistic, "tail sweep" = 10, "screech" = 2

	var/list/participants = list() // types of /datum/entity/statistic, "[human.faction]" = 10, "xeno" = 2
	var/list/final_participants = list() // types of /datum/entity/statistic, "[human.faction]" = 0, "xeno" = 45
	var/list/hijack_participants = list() // types of /datum/entity/statistic, "[human.faction]" = 0, "xeno" = 45
	var/list/total_deaths = list() // types of /datum/entity/statistic, "[human.faction]" = 0, "xeno" = 45
	var/list/caste_stats_list = list() // list of types /datum/entity/player_stats/caste
	var/list/weapon_stats_list = list() // list of types /datum/entity/weapon_stats
	var/list/job_stats_list = list() // list of types /datum/entity/job_stats

	// nanoui data
	var/round_data[0]
	var/death_data[0]

/datum/entity_meta/statistic_round
	entity_type = /datum/entity/statistic/round
	table_name = "rounds"
	key_field = "round_id"
	field_types = list(
		"round_id" = DB_FIELDTYPE_BIGINT,

		"round_name" = DB_FIELDTYPE_STRING_LARGE,
		"map_name" = DB_FIELDTYPE_STRING_LARGE,
		"game_mode" = DB_FIELDTYPE_STRING_LARGE,

		"real_time_start" = DB_FIELDTYPE_DATE,
		"real_time_end" = DB_FIELDTYPE_DATE,
		"round_hijack_time" = DB_FIELDTYPE_STRING_SMALL,
		"round_result" = DB_FIELDTYPE_STRING_MEDIUM,
		"end_round_player_population" = DB_FIELDTYPE_INT,

		"total_huggers_applied" = DB_FIELDTYPE_INT,
		"total_larva_burst" = DB_FIELDTYPE_INT,

		"defcon_level" = DB_FIELDTYPE_INT,
		"objective_points" = DB_FIELDTYPE_INT,
		"total_objective_points" = DB_FIELDTYPE_INT,

		"total_projectiles_fired" = DB_FIELDTYPE_INT,
		"total_projectiles_hit" = DB_FIELDTYPE_INT,
		"total_projectiles_hit_human" = DB_FIELDTYPE_INT,
		"total_projectiles_hit_xeno" = DB_FIELDTYPE_INT,
		"total_friendly_fire_instances" = DB_FIELDTYPE_INT,
		"total_slashes" = DB_FIELDTYPE_INT
	)

/datum/game_mode/proc/setup_round_stats()
	if(!round_stats)
		var/operation_name
		operation_name = "[pick(operation_titles)]"
		operation_name += " [pick(operation_prefixes)]"
		operation_name += "-[pick(operation_postfixes)]"

		SSperf_logging.start_logging()

		// Round stats
		round_stats = DB_ENTITY(/datum/entity/statistic/round)
		round_stats.round_name = operation_name
		round_stats.round_id = SSperf_logging.round.id
		round_stats.map_name = SSmapping.configs[GROUND_MAP].map_name
		round_stats.game_mode = name
		round_stats.real_time_start = time2text(world.realtime)
		round_stats.save()

		// Setup the global reference
		round_statistics = round_stats

		// Map stats
		var/datum/entity/statistic/map/new_map = DB_EKEY(/datum/entity/statistic/map, SSmapping.configs[GROUND_MAP].map_name)

		// Connect map to round
		round_stats.current_map = new_map

/datum/entity/statistic/round/proc/setup_faction(var/faction)
	if(!faction)
		return
	var/faction_key = strip_improper(faction)
	if(!participants["[faction_key]"])
		var/datum/entity/statistic/S = new()
		S.name = faction_key
		S.value = 0
		participants["[faction_key]"] = S
	if(!final_participants["[faction_key]"])
		var/datum/entity/statistic/S = new()
		S.name = faction_key
		S.value = 0
		final_participants["[faction_key]"] = S
	if(!hijack_participants["[faction_key]"])
		var/datum/entity/statistic/S = new()
		S.name = faction_key
		S.value = 0
		hijack_participants["[faction_key]"] = S
	if(!total_deaths["[faction_key]"])
		var/datum/entity/statistic/S = new()
		S.name = faction_key
		S.value = 0
		total_deaths["[faction_key]"] = S

/datum/entity/statistic/round/proc/track_new_participant(var/faction, var/amount = 1)
	if(!faction)
		return
	if(!participants["[faction]"])
		setup_faction(faction)
	var/datum/entity/statistic/S = participants["[faction]"]
	S.value += amount

/datum/entity/statistic/round/proc/track_final_participant(var/faction, var/amount = 1)
	if(!faction)
		return
	if(!final_participants["[faction]"])
		setup_faction(faction)
	var/datum/entity/statistic/S = final_participants["[faction]"]
	S.value += amount

/datum/entity/statistic/round/proc/track_round_end(var/completion_type)
	real_time_end = time2text(world.realtime)
	round_result = completion_type
	for(var/i in GLOB.alive_mob_list)
		var/mob/M = i
		if(M.mind)
			track_final_participant(M.faction)
			end_round_player_population += 1
	if(current_map)
		current_map.total_rounds += 1
		current_map.save()
		current_map.detach()

	save()
	detach()

/datum/entity/statistic/round/proc/track_hijack_participant(var/faction, var/amount = 1)
	if(!faction)
		return
	if(!hijack_participants["[faction]"])
		setup_faction(faction)
	var/datum/entity/statistic/S = hijack_participants["[faction]"]
	S.value += amount

/datum/entity/statistic/round/proc/track_hijack()
	for(var/i in GLOB.alive_mob_list)
		var/mob/M = i
		if(M.mind)
			track_hijack_participant(M.faction)
	round_hijack_time = duration2text(world.time)
	save()

	if(current_map)
		current_map.total_hijacks += 1
		current_map.save()

/datum/entity/statistic/round/proc/track_dead_participant(var/faction, var/amount = 1)
	if(!faction)
		return
	if(!total_deaths["[faction]"])
		setup_faction(faction)
	var/datum/entity/statistic/S = total_deaths["[faction]"]
	S.value += amount

/datum/entity/statistic/round/proc/track_death(var/datum/entity/statistic/death/new_death)
	if(new_death)
		death_stats_list.Insert(1, new_death)
		var/list/damage_list = list()

		if(new_death.total_brute > 0)
			damage_list += list(list("name" = "brute", "value" = new_death.total_brute))
		if(new_death.total_burn > 0)
			damage_list += list(list("name" = "burn", "value" = new_death.total_burn))
		if(new_death.total_oxy > 0)
			damage_list += list(list("name" = "oxy", "value" = new_death.total_oxy))
		if(new_death.total_tox > 0)
			damage_list += list(list("name" = "tox", "value" = new_death.total_tox))

		var/death = list(list(
			"mob_name" = sanitize(new_death.mob_name),
			"job_name" = new_death.role_name,
			"area_name" = sanitize(new_death.area_name),
			"cause_name" = sanitize(new_death.cause_name),
			"total_kills" = new_death.total_kills,
			"total_damage" = damage_list,
			"time_of_death" = new_death.time_of_death,
			"total_time_alive" = new_death.total_time_alive,
			"total_damage_taken" = new_death.total_damage_taken,
			"x" = new_death.x,
			"y" = new_death.y,
			"z" = new_death.z
		))
		var/list/new_death_list = list()
		if(death_data["death_stats_list"])
			new_death_list = death_data["death_stats_list"]
		new_death_list.Insert(1, death)
		if(new_death_list.len > STATISTICS_DEATH_LIST_LEN)
			new_death_list.Cut(STATISTICS_DEATH_LIST_LEN+1, new_death_list.len)
		death_data["death_stats_list"] = new_death_list
	track_dead_participant(new_death.faction_name)

/datum/entity/statistic/round/proc/log_round_statistics()
	if(!round_stats)
		return
	var/total_xenos_created = 0
	var/total_predators_spawned = 0
	var/total_predaliens = 0
	var/total_humans_created = 0
	for(var/statistic in participants)
		var/datum/entity/statistic/S = participants[statistic]
		if(S.name in FACTION_LIST_XENOMORPH)
			total_xenos_created += S.value
		else if(S.name == FACTION_YAUTJA)
			total_predators_spawned += S.value
		else if(S.name == FACTION_PREDALIEN)
			total_predators_spawned += S.value
		else
			total_humans_created += S.value

	var/xeno_count_during_hijack = 0
	var/human_count_during_hijack = 0

	for(var/statistic in hijack_participants)
		var/datum/entity/statistic/S = hijack_participants[statistic]
		if(S.name in FACTION_LIST_XENOMORPH)
			xeno_count_during_hijack += S.value
		else if(S.name == FACTION_PREDALIEN)
			xeno_count_during_hijack += S.value
		else if(S.name == FACTION_YAUTJA)
			continue
		else
			human_count_during_hijack += S.value

	var/end_of_round_marines = 0
	var/end_of_round_xenos = 0

	for(var/statistic in final_participants)
		var/datum/entity/statistic/S = final_participants[statistic]
		if(S.name in FACTION_LIST_XENOMORPH)
			end_of_round_xenos += S.value
		else if(S.name == FACTION_PREDALIEN)
			end_of_round_xenos += S.value
		else if(S.name == FACTION_YAUTJA)
			continue
		else
			end_of_round_marines += S.value

	var/stats = ""
	stats += "[SSticker.mode.round_finished]\n"
	stats += "Game mode: [game_mode]\n"
	stats += "Map name: [current_map.name]\n"
	stats += "Round time: [round_length]\n"
	stats += "End round player population: [end_round_player_population]\n"

	stats += "Total xenos spawned: [total_xenos_created]\n"
	stats += "Total Preds spawned: [total_predators_spawned]\n"
	stats += "Total Predaliens spawned: [total_predaliens]\n"
	stats += "Total humans spawned: [total_humans_created]\n"

	stats += "Xeno count during hijack: [xeno_count_during_hijack]\n"
	stats += "Human count during hijack: [human_count_during_hijack]\n"

	stats += "Total huggers applied: [total_huggers_applied]\n"
	stats += "Total chestbursts: [total_larva_burst]\n"

	stats += "Total shots fired: [total_projectiles_fired]\n"
	stats += "Total friendly fire instances: [total_friendly_fire_instances]\n"
	stats += "Total friendly fire kills: [total_friendly_fire_kills]\n"

	stats += "DEFCON level: [defcon_level]\n"
	stats += "Objective points earned: [objective_points]\n"
	stats += "Objective points total: [total_objective_points]\n"

	stats += "Marines remaining: [end_of_round_marines]\n"
	stats += "Xenos remaining: [end_of_round_xenos]\n"
	stats += "Hijack time: [round_hijack_time]\n"

	stats += "[log_end]"

	round_stats << stats // Logging to data/logs/round_stats.log

/datum/action/show_round_statistics
	name = "View End-Round Statistics"

/datum/action/show_round_statistics/can_use_action()
	if(!..())
		return FALSE

	if(!owner.client || !owner.client.player_entity)
		return FALSE

	return TRUE

/datum/action/show_round_statistics/action_activate()
	if(!can_use_action())
		return

	owner.client.player_entity.show_statistics(owner, round_statistics, TRUE)
