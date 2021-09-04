/datum/entity/statistic/death
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
        "time_of_death" = DB_FIELDTYPE_BIGINT,
        "total_time_alive" = DB_FIELDTYPE_BIGINT,

        "total_brute" = DB_FIELDTYPE_INT,
        "total_burn" = DB_FIELDTYPE_INT,
        "total_oxy" = DB_FIELDTYPE_INT,
        "total_tox" = DB_FIELDTYPE_INT,

        "x" = DB_FIELDTYPE_INT,
        "y" = DB_FIELDTYPE_INT,
        "z" = DB_FIELDTYPE_INT
    )

/mob/proc/track_mob_death(var/datum/cause_data/cause_data)
	if(!mind || statistic_exempt)
		return

	var/mob/cause_mob = cause_data?.resolve_mob()
	if(cause_mob)
		cause_mob.life_kills_total += 1

	/*
	 * It's important to note that while this proc is normally called right after death
	 * but before mob deletion (in cases such as gib), the blocking database operations
	 * in things such as get_player_from_key() will mean a number of things might not be
	 * valid anymore later down through it.
	 * The way the death data is gathered is generally arguable as a result -
	 * they should likely be recorded separately beforehand ?
	 * Exact refactor scope and method is left as an exercice to the reader,
	 * for now we just do our best to handle this in correct order to avoid issues.
	 */

	var/datum/entity/statistic/death/new_death = DB_ENTITY(/datum/entity/statistic/death)

	var/area/A = get_area(src)
	var/turf/T = get_turf(src)

	var/observer_message = "<b>[real_name]</b> has died"
	if(cause_data?.cause_name)
		observer_message += " to <b>[cause_data.cause_name]</b>"
	if(A.name)
		observer_message += " at \the <b>[A.name]</b>"

	msg_admin_attack(observer_message, T.x, T.y, T.z)
	to_chat(src, SPAN_DEADSAY(observer_message))
	for(var/mob/dead/observer/obs as anything in GLOB.observer_list)
		to_chat(obs, SPAN_DEADSAY(observer_message + " (<a href='?src=\ref[obs];jumptocoord=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)"))

	new_death.area_name = A?.name
	new_death.x = T?.x
	new_death.y = T?.y
	new_death.z = T?.z

	new_death.round_id = SSperf_logging.round.id
	new_death.role_name = get_role_name()
	new_death.mob_name = real_name
	new_death.faction_name = faction
	new_death.cause_name = cause_data?.cause_name
	new_death.cause_role_name = cause_data?.role
	new_death.cause_faction_name = cause_data?.faction
	new_death.time_of_death = world.time
	new_death.total_steps = life_steps_total
	new_death.total_kills = life_kills_total
	new_death.total_time_alive = life_time_total

	if(getBruteLoss())
		new_death.total_brute = round(getBruteLoss())
	if(getFireLoss())
		new_death.total_burn = round(getFireLoss())
	if(getOxyLoss())
		new_death.total_oxy = round(getOxyLoss())
	if(getToxLoss())
		new_death.total_tox = round(getToxLoss())

	if(round_statistics)
		round_statistics.track_death(new_death)

	var/datum/entity/player/player_entity = get_player_from_key(mind.ckey)
	if(player_entity)
		new_death.player_id = player_entity.id

	if(cause_data)
		var/datum/entity/player/cause_player = get_player_from_key(cause_data.ckey)
		if(cause_player)
			new_death.cause_player_id = cause_player.id

	new_death.save()
	new_death.detach()
	return new_death

/mob/living/carbon/human/track_mob_death(var/cause, var/cause_mob)
	. = ..(cause, cause_mob, job)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	if(human_stats && human_stats.death_list)
		human_stats.death_list.Insert(1, .)

/mob/living/carbon/Xenomorph/track_mob_death(var/cause, var/cause_mob)
	. = ..(cause, cause_mob, caste_type)
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/xeno/xeno_stats = mind.setup_xeno_stats()
	if(xeno_stats && xeno_stats.death_list)
		xeno_stats.death_list.Insert(1, .)
