#define SELF_SURGERY_SLOWDOWN 1.5

/datum/surgery_step
	var/name
	var/list/tools = list()	
	var/tool_type
	var/accept_hand = FALSE				//does the surgery step require an open hand? If true, ignores tools. Compatible with accept_any_item.
	var/accept_any_item = FALSE			//does the surgery step accept any item? If true, ignores tools. Compatible with require_hand.
	var/time = 10						//how long does the step take?
	var/repeatable = FALSE				//can this step be repeated? Make shure it isn't last step, or it used in surgery with `can_cancel = 1`. Or surgion will be stuck in the loop
	var/required_surgery_skill = SKILL_SURGERY_DEFAULT

/datum/surgery_step/proc/try_op(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/success = FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE

	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = TRUE

	else if(tool)
		for(var/key in tools)
			var/match = FALSE

			if(istype(tool, key))
				match = TRUE

			if(match)
				tool_type = key
				if(tool_check(user, tool))
					success = TRUE
					break

	if(success)
		if(target_zone == surgery.location)
			initiate(user, target, target_zone, tool, surgery)
			return TRUE
	
	if(repeatable)
		var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
		if(next_step)
			surgery.status++
			if(next_step.try_op(user, target, user.zone_selected, user.get_active_hand(), surgery))
				return TRUE
			else
				surgery.status--

	return FALSE

/datum/surgery_step/proc/initiate(mob/living/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(user.action_busy) //already doing an action
		return TRUE
	if(!skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		to_chat(user, SPAN_WARNING("You have no idea how to do surgery..."))
		return TRUE
	if(!skillcheck(user, SKILL_SURGERY, required_surgery_skill))
		to_chat(user, SPAN_WARNING("This procedure is too hard for you!"))
		return TRUE		

	surgery.step_in_progress = TRUE

	var/advance = FALSE

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = FALSE
		return FALSE

	var/step_duration = time
	if(user.mind && user.skills)
		step_duration *= user.get_skill_duration_multiplier(SKILL_SURGERY)

	if(tool_type)	//this means it isn't a require hand or any item step.
		step_duration /= tools[tool_type] / 100.0
	
	if(user == target)
		step_duration *= SELF_SURGERY_SLOWDOWN

	if(target.stat == CONSCIOUS)
		var/pain_failure_chance = max(0,surgery.pain_reduction_required - target.pain.reduction_pain) * 2 //Each extra pain unit increases the chance by 2
		if(prob(pain_failure_chance))
			failure(user, target, target_zone, tool, surgery)
			target.emote("pain")
			to_chat(user, SPAN_DANGER("[target] moved during the surgery! Use anesthetics!"))
			surgery.step_in_progress = FALSE
			return FALSE


	if(do_after(user, step_duration, INTERRUPT_ALL, BUSY_ICON_FRIENDLY,target,INTERRUPT_MOVED,BUSY_ICON_MEDICAL))
		if(success(user, target, target_zone, tool, surgery))
			advance = TRUE
	else
		if(failure(user, target, target_zone, tool, surgery))
			advance = TRUE
			
	if(advance && !repeatable)
		surgery.status++
		if(surgery.status > surgery.steps.len)
			surgery.complete()

	surgery.step_in_progress = FALSE
	return advance

/datum/surgery_step/proc/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to perform surgery on [target]."),
		SPAN_NOTICE("You begin to perform surgery on [target]..."))

/datum/surgery_step/proc/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] succeeds!"),
			SPAN_NOTICE("You succeed."))
	return TRUE

/datum/surgery_step/proc/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] fails to finish the surgery"),
			SPAN_NOTICE("You fail to finish the surgery"))
	return FALSE

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE
