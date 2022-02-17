/datum/entity/statistic/death
	var/round_id

	var/role_name
	var/faction_name
	var/mob_name
	var/area_name

	var/cause_name
	var/cause_player_id
	var/cause_role_name
	var/cause_faction_name

	var/total_steps = 0
	var/total_kills = 0
	var/time_of_death
	var/total_time_alive
	var/total_damage_taken

	var/total_brute = 0
	var/total_burn = 0
	var/total_oxy = 0
	var/total_tox = 0

	var/x
	var/y
	var/z

BSQL_PROTECT_DATUM(/datum/entity/statistic/death)

/datum/entity_meta/statistic_death
    entity_type = /datum/entity/statistic/death
    table_name = "log_player_statistic_death"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "round_id" = DB_FIELDTYPE_BIGINT,

        "role_name" = DB_FIELDTYPE_STRING_LARGE,
        "faction_name" = DB_FIELDTYPE_STRING_LARGE,
        "mob_name" = DB_FIELDTYPE_STRING_LARGE,
        "area_name" = DB_FIELDTYPE_STRING_LARGE,

        "cause_name" = DB_FIELDTYPE_STRING_LARGE,
        "cause_player_id" = DB_FIELDTYPE_BIGINT,
        "cause_role_name" = DB_FIELDTYPE_STRING_LARGE,
        "cause_faction_name" = DB_FIELDTYPE_STRING_LARGE,

        "total_steps" = DB_FIELDTYPE_INT,
        "total_kills" = DB_FIELDTYPE_INT,
        "time_of_death" = DB_FIELDTYPE_STRING_SMALL,
        "total_time_alive" = DB_FIELDTYPE_STRING_SMALL,
        "total_damage_taken" = DB_FIELDTYPE_INT,

        "total_brute" = DB_FIELDTYPE_INT,
        "total_burn" = DB_FIELDTYPE_INT,
        "total_oxy" = DB_FIELDTYPE_INT,
        "total_tox" = DB_FIELDTYPE_INT,

        "x" = DB_FIELDTYPE_INT,
        "y" = DB_FIELDTYPE_INT,
        "z" = DB_FIELDTYPE_INT
    )

/datum/view_record/statistic_death
	var/player_id
	var/round_id

	var/role_name
	var/faction_name
	var/mob_name
	var/area_name

	var/cause_name
	var/cause_player_id
	var/cause_role_name
	var/cause_faction_name

	var/total_steps = 0
	var/total_kills = 0
	var/time_of_death
	var/total_time_alive

	var/total_brute = 0
	var/total_burn = 0
	var/total_oxy = 0
	var/total_tox = 0

	var/x
	var/y
	var/z

/datum/entity_view_meta/statistic_death_ordered
    root_record_type = /datum/entity/statistic/death
    destination_entity = /datum/view_record/statistic_death
    fields = list(
        "player_id",
        "round_id",

        "role_name",
        "faction_name",
        "mob_name",
        "area_name",

        "cause_name",
        "cause_player_id",
        "cause_role_name",
        "cause_faction_name",

        "total_steps",
        "total_kills",
        "time_of_death",
        "total_time_alive",

        "total_brute",
        "total_burn",
        "total_oxy",
        "total_tox",

        "x",
        "y",
        "z",
    )
    order_by = list("round_id" = DB_ORDER_BY_DESC)

/mob/proc/track_mob_death(var/datum/cause_data/cause_data, var/turf/death_loc)
	if(!mind || statistic_exempt)
		return

	var/datum/entity/statistic/death/Dlog = DB_ENTITY(/datum/entity/statistic/death)
	var/datum/entity/player/player_entity = get_player_from_key(mind.ckey)
	if(player_entity)
		Dlog.player_id = player_entity.id

	Dlog.round_id = SSperf_logging.round.id

	Dlog.role_name = get_role_name()
	Dlog.mob_name = real_name
	Dlog.faction_name = faction

	var/area/A = get_area(death_loc)
	Dlog.area_name = A.name

	Dlog.cause_name = cause_data.cause_name
	var/datum/entity/player/cause_player = get_player_from_key(cause_data.ckey)
	if(cause_player)
		Dlog.cause_player_id = cause_player.id
	Dlog.cause_role_name = cause_data.role
	Dlog.cause_faction_name = cause_data.faction

	var/mob/cause_mob = cause_data.resolve_mob()
	var/cause_name = cause_data.cause_name
	if(cause_mob)
		cause_mob.life_kills_total += 1

	if(getBruteLoss())
		Dlog.total_brute = round(getBruteLoss())
	if(getFireLoss())
		Dlog.total_burn = round(getFireLoss())
	if(getOxyLoss())
		Dlog.total_oxy = round(getOxyLoss())
	if(getToxLoss())
		Dlog.total_tox = round(getToxLoss())

	Dlog.time_of_death = duration2text(world.time)

	Dlog.x = death_loc.x
	Dlog.y = death_loc.y
	Dlog.z = death_loc.z

	Dlog.total_steps = life_steps_total
	Dlog.total_kills = life_kills_total
	Dlog.total_time_alive = duration2text(life_time_total)
	Dlog.total_damage_taken = life_damage_taken_total

	var/observer_message = "<b>[real_name]</b> has died"
	if(cause_data && cause_data.cause_name)
		observer_message += " to <b>[cause_name]</b>"
	if(A.name)
		observer_message += " at \the <b>[A.name]</b>"

	msg_admin_attack(observer_message, death_loc.x, death_loc.y, death_loc.z)

	if(src)
		to_chat(src, SPAN_DEADSAY(observer_message))
	for(var/mob/dead/observer/g in GLOB.observer_list)
		to_chat(g, SPAN_DEADSAY(observer_message + " (<a href='?src=\ref[g];jumptocoord=1;X=[death_loc.x];Y=[death_loc.y];Z=[death_loc.z]'>JMP</a>)"))

	if(round_statistics)
		round_statistics.track_death(Dlog)

	player_entity.player_entity.DS.Insert(1, Dlog)

	if(isXeno(cause_mob))
		var/datum/entity/player_stats/xeno/xeno_stats = cause_mob.mind.setup_xeno_stats()
		if(xeno_stats)
			if(cause_mob.faction != faction)
				xeno_stats.count_kill(cause_data.role, cause_name, cause_player.id, STATISTICS_KILL)
			else
				xeno_stats.count_kill(cause_data.role, cause_name, cause_player.id, STATISTICS_KILL_FF)
	else if(ishuman(cause_mob))
		var/datum/entity/player_stats/human/human_stats = cause_mob.mind.setup_human_stats()
		if(human_stats)
			if(cause_mob.faction != faction)
				human_stats.count_kill(cause_data.role, cause_name, cause_player.id, STATISTICS_KILL)
			else
				human_stats.count_kill(cause_data.role, cause_name, cause_player.id, STATISTICS_KILL_FF)
				if(round_statistics)
					round_statistics.total_friendly_fire_kills++

	if(isXeno(src))
		var/role = get_role_name()
		var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
		if(xeno_stats)
			if(cause_mob.faction != faction)
				xeno_stats.count_death(role, cause_name, player_entity.id, STATISTICS_DEATH)
			else
				xeno_stats.count_death(role, cause_name, player_entity.id, STATISTICS_DEATH_FF)
	else if(ishuman(src))
		var/role = get_role_name()
		var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
		if(human_stats)
			if(cause_mob.faction != faction)
				human_stats.count_death(role, cause_name, player_entity.id, STATISTICS_DEATH)
			else
				human_stats.count_death(role, cause_name, player_entity.id, STATISTICS_DEATH_FF)
				if(round_statistics)
					round_statistics.total_friendly_fire_kills++

	Dlog.save()
	Dlog.detach()
	return Dlog