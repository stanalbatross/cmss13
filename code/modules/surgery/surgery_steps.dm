/datum/surgery_step
	var/name
	var/list/tools = list()	
	var/tool_type
	var/accept_hand = FALSE				//does the surgery step require an open hand? If true, ignores tools. Compatible with accept_any_item.
	var/accept_any_item = FALSE			//does the surgery step accept any item? If true, ignores tools. Compatible with require_hand.
	var/time = 10						//how long does the step take?
	var/repeatable = FALSE				//can this step be repeated? Make shure it isn't last step, or it used in surgery with `can_cancel = 1`. Or surgion will be stuck in the loop

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
	if(!skillcheck(user, SKILL_SURGERY, SKILL_SURGERY_TRAINED))
		to_chat(user, SPAN_WARNING("You have no idea how to do surgery..."))
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


/*

/datum/surgery_step
	var/list/allowed_tools = list(null) //Array of type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_species = null //List of names referencing mutantraces that this step applies to.
	var/list/disallowed_species = null

	var/min_duration = 0 //Minimum duration of the step
	var/max_duration = 0 //Maximum duration of the step

	var/can_infect = 0 //Evil infection stuff that will make everyone hate me
	var/blood_level = 0 //How much blood this step can get on surgeon. 1 - hands, 2 - full body

	//Returns how well tool is suited for this step
	proc/tool_quality(obj/item/tool)
		for(var/T in allowed_tools)
			if(isnull(T) && isnull(tool)) //Bare hands
				return 100
			else
				if(istype(tool, T))
					return allowed_tools[T]
		return FALSE

//Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return FALSE
	if(allowed_species)
		for(var/species in allowed_species)
			if(target.species.name == species)
				return TRUE

	if(disallowed_species)
		for(var/species in disallowed_species)
			if(target.species.name == species)
				return FALSE
	return TRUE


//Checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_do_step(mob/living/carbon/human/user, datum/surgery/surgery, obj/item/tool)
	if(isnull(tool)) 
		if(allowed_tools.Find(null))
			return TRUE
	else
		if(allowed_tools.Find(tool.type))
			return TRUE

//Does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/carbon/human/user, datum/surgery/surgery)
	if(prob(60))
		if(blood_level)
			user.bloody_hands(user, 0)
		if(blood_level > 1)
			user.bloody_body(user, 0)
	return

//Does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/carbon/human/user, datum/surgery/surgery)
	return

//Stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/carbon/human/user, datum/surgery/surgery)
	return null




/datum/surgery_step/incision
	allowed_tools = list(/obj/item/tool/surgery/scalpel = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/clamp
	allowed_tools = list(/obj/item/tool/surgery/hemostat = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/retract
	allowed_tools = list(/obj/item/tool/surgery/retractor = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/unretract
	allowed_tools = list(/obj/item/tool/surgery/retractor = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/cauterize
	allowed_tools = list(/obj/item/tool/surgery/cautery = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/pick_bone
	allowed_tools = list(/obj/item/tool/surgery/hemostat = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/set_bone
	allowed_tools = list(/obj/item/tool/surgery/bonesetter = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/glue_bone
	allowed_tools = list(/obj/item/tool/surgery/bonegel = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS		
*/