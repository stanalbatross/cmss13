/datum/job/marine/rto
	title = JOB_SQUAD_RTO
	total_positions = 8
	spawn_positions = 8
	allow_additional = 1
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADD_TO_SQUAD
	gear_preset = "USCM (Cryo) Squad RT Operator"
	minimum_playtimes = list(
		JOB_SQUAD_ROLES = HOURS_6
	)
/datum/job/marine/rto/equipped
	flags_startup_parameters = ROLE_ADD_TO_SQUAD
	gear_preset = "USCM Cryo RTO (Equipped)"

AddTimelock(/datum/job/marine/rto, list(
	JOB_SQUAD_ROLES = 8 HOURS
))