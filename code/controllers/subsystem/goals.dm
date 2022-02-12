SUBSYSTEM_DEF(goals_points)
	name		= "goals points"
	wait		= 5.5 SECONDS
	init_order = SS_INIT_GOALS
	priority = SS_PRIORITY_GOALS
	flags     = SS_DISABLE_FOR_TESTING
	var/list/current_inactive_run = list()
	var/list/current_active_run = list()

/datum/controller/subsystem/goals_points/Initialize(start_timeofday)
	if(!goals_controller)
		goals_controller = new /datum/controller/goals()
	return ..()

/datum/controller/subsystem/goals_points/fire(resumed = FALSE)
	if(!resumed)
		goals_controller.check_goals_complition()
		current_inactive_run = SSgoals.inactive_objectives.Copy()
		current_active_run = SSgoals.active_objectives.Copy()

	while(length(current_inactive_run))
		var/datum/cm_goals/O = current_inactive_run[length(current_inactive_run)]
		current_inactive_run.len--
		if(O.can_be_activated())
			O.activate()
		if(MC_TICK_CHECK)
			return

	while(length(current_active_run))
		var/datum/cm_goals/O = current_active_run[length(current_active_run)]
		current_active_run.len--
		O.process()
		O.check_completion()
		if(O.is_complete())
			O.deactivate()
		if(MC_TICK_CHECK)
			return