/datum/entity/statistic/medal
	var/round_id

	var/medal_type
	var/recipient_name
	var/recipient_role
	var/citation

	var/giver_name
	var/giver_player_id

BSQL_PROTECT_DATUM(/datum/entity/statistic/medal)

/datum/entity_meta/statistic_medal
    entity_type = /datum/entity/statistic/medal
    table_name = "log_player_statistic_medal"
    field_types = list(
        "player_id" = DB_FIELDTYPE_BIGINT,
        "round_id" = DB_FIELDTYPE_BIGINT,

        "medal_type" = DB_FIELDTYPE_STRING_LARGE,
        "recipient_name" = DB_FIELDTYPE_STRING_LARGE,
        "recipient_role" = DB_FIELDTYPE_STRING_LARGE,
        "citation" = DB_FIELDTYPE_STRING_MAX,

        "giver_name" = DB_FIELDTYPE_STRING_LARGE,
        "giver_player_id" = DB_FIELDTYPE_BIGINT
    )

/datum/view_record/statistic_medal
	var/player_id
	var/round_id

	var/medal_type
	var/recipient_name
	var/recipient_role
	var/citation

	var/giver_name
	var/giver_player_id

/datum/entity_view_meta/statistic_medal_ordered
    root_record_type = /datum/entity/statistic/medal
    destination_entity = /datum/view_record/statistic_medal
    fields = list(
        "player_id",
        "round_id",

        "medal_type",
        "recipient_name",
        "recipient_role",
        "citation",

        "giver_name",
        "giver_player_id",
    )
    order_by = list("player_id" = DB_ORDER_BY_DEFAULT)

/datum/entity/player_entity/proc/track_medal_earned(var/new_medal_type, var/mob/new_recipient, var/new_recipient_role, var/new_citation, var/mob/giver)
	if(!new_medal_type || !new_recipient || new_recipient.statistic_exempt || !new_recipient_role || !new_citation || !giver)
		return

	var/datum/entity/statistic/medal/Mlog = DB_ENTITY(/datum/entity/statistic/medal)
	var/datum/entity/player/player_entity = get_player_from_key(new_recipient.ckey)
	if(player_entity)
		Mlog.player_id = player_entity.id

	Mlog.round_id = SSperf_logging.round.id
	Mlog.medal_type = new_medal_type
	Mlog.recipient_name = new_recipient.real_name
	Mlog.recipient_role = new_recipient_role
	Mlog.citation = new_citation

	Mlog.giver_name = giver.real_name

	var/datum/entity/player/giver_player = get_player_from_key(giver.ckey)
	if(giver_player)
		Mlog.giver_player_id = giver_player.id

	Mlog.save()
	Mlog.detach()

	track_statistic_human_earned(STATISTICS_MEDALS, 1, new_recipient.client.player_data.id)
	MS.Insert(1, Mlog)
