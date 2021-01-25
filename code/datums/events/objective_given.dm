/datum/round_event/objection_given
	name = "New Objective To Agent"
	tickets = 10

/datum/round_event/objection_given/check_prerequisite()
	. = ..()
	if(!.)
		return FALSE

	// Check that agents exist and alive
	for(var/i in GLOB.human_agent_list)
		var/mob/living/carbon/human/H = i
		if(H.stat == CONSCIOUS)
			return TRUE

	return FALSE

/datum/round_event/objection_given/activate()
	var/lowest_number = 100
	var/mob/living/carbon/human/lowest_human
	for(var/i in GLOB.human_agent_list)
		var/mob/living/carbon/human/H = i
		if(!(H.stat == CONSCIOUS))
			continue

		var/pending_objective = FALSE
		for(var/datum/action/human_action/activable/receive_objective/B in H.actions)
			pending_objective = TRUE
			break

		if(pending_objective)
			continue

		var/current_number = LAZYLEN(H.agent_holder.objectives_list)
		if(isnull(current_number) || current_number <= lowest_number)
			lowest_number = current_number
			lowest_human = H

	if(!isnull(lowest_human))
		lowest_human.agent_holder.give_objective()

	return
