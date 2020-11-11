//Mostly ported from tg

/datum/surgery
	var/name = "surgery"
	var/desc = "surgery description"
	var/step_in_progress = FALSE
	var/list/steps = list()
	var/status = 1 
	var/mob/living/target
	var/obj/limb/affected_limb
	var/list/possible_locs = ALL_LIMBS 							//Multiple locations

	var/can_cancel = TRUE										//Can cancel this surgery after step 1 with cautery
	var/list/target_mobtypes = list(/mob/living/carbon/human)	//Acceptable Species
	var/location = LIMB_CHEST									//Surgery location
	var/requires_bodypart_type = LIMB_ORGANIC				//Prevents you from performing an operation on incorrect limbs. 0 for any limb type

	var/requires_bodypart = TRUE								//Surgery available only when a bodypart is present, or only when it is missing.
	var/requires_real_bodypart = FALSE							//Some surgeries don't work on limbs that don't really exist
	var/lying_required = TRUE									//Does the vicitm needs to be lying down.
	var/self_operable = FALSE									//Can the surgery be performed on yourself.

	var/pain_reduction_required = PAIN_REDUCTION_FULL

/datum/surgery/New(surgery_target, surgery_location, surgery_limb)
	..()
	if(surgery_target)
		target = surgery_target
		target.surgeries += src
		if(surgery_location)
			location = surgery_location
		if(surgery_limb)
			affected_limb = surgery_limb

/datum/surgery/Destroy()
	affected_limb = null
	if(target)
		target.surgeries -= src
	target = null
	affected_limb = null
	. = ..()

/datum/surgery/proc/can_start(mob/user, mob/living/patient) //FALSE to not show in list
	return TRUE
	//Might add the surgery computer later

/datum/surgery/proc/next_step(mob/user, intent)
	if(location != user.zone_selected)
		return FALSE
	if(step_in_progress)
		return TRUE

	var/try_to_fail = FALSE
	if(intent == INTENT_DISARM)
		try_to_fail = TRUE
	
	var/datum/surgery_step/S = get_surgery_step()
	if(S)
		var/obj/item/tool = user.get_active_hand()
		if(S.try_op(user, target, user.zone_selected, tool, src, try_to_fail))
			return TRUE
		if(tool && tool.flags_item & SURGERY_TOOL) //Just because you used the wrong tool it doesn't mean you meant to whack the patient with it
			to_chat(user, "<span class='warning'>This step requires a different tool!</span>")
			return TRUE
	return FALSE

/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[status]
	return new step_type

/datum/surgery/proc/get_surgery_next_step()
	if(status < steps.len)
		var/step_type = steps[status + 1]
		return new step_type
	else
		return null

/datum/surgery/proc/complete()
	qdel(src)
