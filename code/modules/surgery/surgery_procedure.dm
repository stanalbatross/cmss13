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
/*
/datum/surgery/proc/is_avaiable()
	return TRUE

/datum/surgery/proc/try_do_step(mob/living/carbon/human/user, def_zone)
	if(!ishuman(user))
		return FALSE
	if(affected_mob.get_limb(def_zone) != affected_limb)
		return FALSE
	if(user.a_intent == INTENT_HARM) //Check for Hippocratic Oath
		return FALSE
	if(user.action_busy) //already doing an action
		return TRUE
	if(!skillcheck(user, SKILL_SURGERY, SKILL_SURGERY_TRAINED))
		to_chat(user, SPAN_WARNING("You have no idea how to do surgery..."))
		return TRUE
	if(step_in_progress)
		return FALSE
	var/obj/item/tool = user.get_active_hand()
	var/datum/surgery_step/S = new step_sequence[current_step]
	if(!S.can_do_step(user, src, tool))
		return FALSE

	S.begin_step(user)
	step_in_progress = TRUE
	var/sucess_multiplier = get_sucess_multipliers()

	//calculate step duration
	var/step_duration = rand(S.min_duration, S.max_duration)
	if(user.mind && user.skills)
		//1 second reduction per level above minimum for performing surgery
		step_duration = max(5, (step_duration * user.get_skill_duration_multiplier(SKILL_SURGERY)))

	//Multiply tool success rate with multiplier
	if(prob(S.tool_quality(tool) * sucess_multiplier) &&  do_after(user, step_duration, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, affected_mob, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
		if(S.can_do_step(user, src, tool)) //to check nothing changed during the do_after
			S.end_step(user, src) //Finish successfully
			if(!advance_step())
				end_sucess(user)
				finish()
	else
		S.fail_step(user, src) //Malpractice
	step_in_progress = FALSE
	return TRUE

/datum/surgery/proc/cancel_procedure(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	if(user.a_intent == INTENT_HARM) //Check for Hippocratic Oath
		return
	if(user.action_busy) //already doing an action
		return
	if(!skillcheck(user, SKILL_SURGERY, SKILL_SURGERY_TRAINED))
		to_chat(user, SPAN_WARNING("You have no idea how to do surgery..."))
		return
	if(step_in_progress)
		return
	if(!istype(user.get_inactive_hand(), /obj/item/tool/surgery/cautery))
		to_chat(user, SPAN_WARNING("You need to hold a cautery in your hands to stop the procedure!"))
		return
	user.swap_hand()

	to_chat(user, SPAN_NOTICE("You begin to revert your progress on the [name]"))

	if(cur_step == 1 || do_after(user, 6 SECONDS, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, affected_mob, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
		to_chat(user, SPAN_HELPFUL("You cancel the [name]"))
		finish()
	else
		to_chat(user, SPAN_WARNING("You mess some steps while reverting the [name]"))
		end_interrupted()
		finish()

/datum/surgery/proc/advance_step()
	if(++cur_step > length(step_sequence)))
		return FALSE
	return TRUE

/datum/surgery/proc/get_sucess_multipliers()
	var/multipler = 1
	. = multipler
	//Need to replace this with surgery speed
	/*
	if(!isSynth(affected_mob) && !isYautja(affected_mob))
		if(locate(/obj/structure/bed/roller, affected_mob.loc))
			multipler -= SURGERY_MULTIPLIER_SMALL
		else if(locate(/obj/structure/surface/table/, affected_mob.loc))
			multipler -= SURGERY_MULTIPLIER_MEDIUM
		if(affected_mob.stat == CONSCIOUS)//If not on anesthetics or not unconsious
			multipler -= SURGERY_MULTIPLIER_LARGE
			switch(affected_mob.pain.reduction_pain)
				if(PAIN_REDUCTION_MEDIUM to PAIN_REDUCTION_HEAVY)
					multipler += SURGERY_MULTIPLIER_MEDIUM
				if(PAIN_REDUCTION_HEAVY to PAIN_REDUCTION_FULL)
					multipler += SURGERY_MULTIPLIER_LARGE
		if(istype(affected_mob.loc, /turf/open/shuttle/dropship))
			multipler -= SURGERY_MULTIPLIER_HUGE
		multipler = Clamp(multipler, 0, 1)
	*/

/datum/surgery/proc/finish()
	affected_mob.surgeries -= src
	qdel(src)

/datum/surgery/proc/end_sucess()

/datum/surgery/proc/end_interrupted() //Deal damage or something

//LIMB INTEGRITY HEALING PROCEDURES
//INTEGRITY DAMAGE LEVEL 2 -> 1

/datum/surgery/stitching
	step_sequence = list()
/datum/surgery/stitching/is_avaiable()
	if(affected_limb.integrity_level == LIMB_INTEGRITY_OKAY)
		return TRUE
	else
		return FALSE
/datum/surgery/stitching/end_interrupted()
	affected_limb.take_damage(5)	

/datum/surgery/stitching/end_sucess()
	affected_limb.set_integrity_level(LIMB_INTEGRITY_PERFECT)
	
*/