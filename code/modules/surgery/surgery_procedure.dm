
/datum/surgery_procedure
	var/cur_step = 1
	var/list/common_steps = list(/datum/surgery_step)
	var/special_sequence_change_point = 0
	var/list/special_sequence = list()
	var/using_special_sequence = FALSE
	var/name = "procedure"
	var/desc = ""
	var/open_stage = 1
	var/step_in_progress = FALSE
	var/mob/living/carbon/human/affected_mob
	var/obj/limb/affected_limb

/datum/surgery_procedure/New(subject, limb)
	affected_mob = subject
	affected_limb = limb
	..()

/datum/surgery_procedure/Destroy()
	affected_mob = null
	affected_limb = null
	. = ..()

/datum/surgery_procedure/proc/is_avaiable()
	if(affected_limb.surgery_open_stage == open_stage)
		return TRUE
	return FALSE

/datum/surgery_procedure/proc/try_do_step(mob/living/carbon/human/user, def_zone)
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
	var/datum/surgery_step/S
	var/can_procede = FALSE
	var/step_type
	if(cur_step == special_sequence_change_point)
		step_type = special_sequence[cur_step]
		S = new step_type
		if(S.can_do_step(user, src, tool))
			using_special_sequence = TRUE
			can_procede = TRUE
	if(!can_procede)
		if(using_special_sequence)
			step_type = special_sequence[cur_step]
		else
			step_type = common_steps[cur_step]
		S = new step_type
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

/datum/surgery_procedure/proc/cancel_procedure(mob/living/carbon/human/user)
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

/datum/surgery_procedure/proc/advance_step()
	if(++cur_step > (using_special_sequence ? length(special_sequence) : length(common_steps)))
		return FALSE
	return TRUE

/datum/surgery_procedure/proc/get_sucess_multipliers()
	var/multipler = 1
	. = multipler
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

/datum/surgery_procedure/proc/finish()
	affected_mob.surgery_procedures -= src
	qdel(src)

/datum/surgery_procedure/proc/end_sucess() //Heal wounds and whatever else
	SEND_SIGNAL(affected_limb, COMSIG_SURGERY_SUCESS, type)

/datum/surgery_procedure/proc/end_interrupted() //Deal damage or something
	if(cur_step == 1)
		return FALSE

/datum/surgery_procedure/open_limb
	common_steps = list(/datum/surgery_step/incision, /datum/surgery_step/clamp, /datum/surgery_step/retract)
	name = "Open Limb"
	open_stage = 0

/datum/surgery_procedure/open_limb/end_sucess()
	..()
	affected_limb.surgery_open_stage = 1

/datum/surgery_procedure/close_limb
	common_steps = list(/datum/surgery_step/unretract, /datum/surgery_step/cauterize)
	name = "Close limb"
	open_stage = 1

/datum/surgery_procedure/close_limb/end_sucess()
	..()
	affected_limb.surgery_open_stage = 0

/datum/surgery_procedure/replace_missing_limb
	name = "Prosthetical Replacement"
	common_steps = list(/datum/surgery_step,
						/datum/surgery_step,
						/datum/surgery_step,
						/datum/surgery_step,
						/datum/surgery_step,
						/datum/surgery_step)

/datum/surgery_procedure/replace_missing_limb/is_avaiable()
	if(!(affected_limb.status) & LIMB_DESTROYED)
		return FALSE
	. = ..()

/datum/surgery_procedure/replace_missing_limb/end_sucess()
	. = ..()
	affected_limb.rejuvenate()				

/datum/surgery_procedure/alien_embryo_removal
	name = "Alien Embryo Removal"

/datum/surgery_procedure/alien_embryo_removal/end_sucess(mob/user)
	. = ..()
	var/obj/item/alien_embryo/A = locate() in affected_mob
	if(A)
		user.visible_message(SPAN_WARNING("[user] rips a wriggling parasite out of [affected_mob]'s ribcage!"),
							 SPAN_WARNING("You rip a wriggling parasite out of [affected_mob]'s ribcage!"))
		user.count_niche_stat(STATISTICS_NICHE_SURGERY_LARVA)
		var/mob/living/carbon/Xenomorph/Larva/L = locate() in affected_mob //the larva was fully grown, ready to burst.
		if(L)
			L.forceMove(affected_mob.loc)
			qdel(A)
		else
			A.forceMove(affected_mob.loc)
			affected_mob.status_flags &= ~XENO_HOST
	
//Death stack removal
/*
/datum/surgery_procedure/remove_death_stack
	var/req_stacks = 1 //Only avaiable if you have this many stacks
	var/limited_to_req_stacks = TRUE //If false, also avaiable when there are more stacks than required

/datum/surgery_procedure/remove_death_stack/is_avaiable()
	. = ..()
	if(!.)
		return
	if(limited_to_req_stacks)
		if(affected_mob.stacked_deaths == req_stacks)
			return TRUE
	else
		if(affected_mob.stacked_deaths >= req_stacks)
			return TRUE

/datum/surgery_procedure/remove_death_stack/end_sucess()
	if(affected_mob.stacked_deaths)
		affected_mob.stacked_deaths--
	. = ..()

//Gonna make these the coolest procedures
/datum/surgery_procedure/remove_death_stack/brain_repair
/datum/surgery_procedure/remove_death_stack/heart_transplant
/datum/surgery_procedure/remove_death_stack/intestinal_cleansing
*/
/*

	Mild wound procedures
	General idea is that you're fixing the upper to mid "layers" of the body

*/

/datum/surgery_procedure/fix_bone
    name = "Bone Reparation Procedure"
    common_steps = list(/datum/surgery_step/move_bone,
                        /datum/surgery_step/drain_blood_bone,
                        /datum/surgery_step/pick_fragments,
                        /datum/surgery_step/glue_fragments,
                        /datum/surgery_step/heal_bone,
                        /datum/surgery_step/set_bone)
    open_stage = 1

/datum/surgery_procedure/fix_bone/hairline
    name = "Bone Reparation Procedure (Hairline)"
    special_sequence_change_point = 3
    special_sequence = list(null,
                          null,
                          /datum/surgery_step/fill_fracture,
                          /datum/surgery_step/heal_bone
                          )//Skips fragment picking & setting

/datum/surgery_procedure/fix_bone/broken
    name = "Bone Reparation Procedure (Broken)"
    special_sequence_change_point = 1
    special_sequence = list(/datum/surgery_step/remove_bone,
                          /datum/surgery_step/drain_blood_bone,
                          /datum/surgery_step/glue_ends,
                          /datum/surgery_step/replace_bone
                          )
/datum/surgery_procedure/fix_bone/dislocation
    name = "Bone Reparation Procedure (Dislocation)"
    special_sequence_change_point = 1
    special_sequence = list(/datum/surgery_step/heal_trauma,
                          /datum/surgery_step/realign_bone,
                          /datum/surgery_step/set_bone,
                          /datum/surgery_step/heal_bone
                          )

/datum/surgery_procedure/fix_muscle
    name = "Muscle Reparation Procedure"
    open_stage = 1
    common_steps = list(/datum/surgery_step/drain_blood_muscle,
                        /datum/surgery_step/tension_muscle,
                        /datum/surgery_step/rebuild_muscle_veins,
                        /datum/surgery_step/apply_synthmuscle,
                        /datum/surgery_step/apply_muscle_growth,
                        /datum/surgery_step/stitch_muscle)

/datum/surgery_procedure/fix_muscle/tendon
    name = "Muscle Reparation Procedure (Severed Tendon)"
    special_sequence_change_point = 1
    special_sequence = list(/datum/surgery_step/pull_tendon,
                          /datum/surgery_step/stitch_muscle,
                          /datum/surgery_step/apply_muscle_growth,
                          /datum/surgery_step/heal_tendon_bone
                          )

/datum/surgery_procedure/fix_muscle/tear
    name = "Muscle Reparation Procedure (Partial Tear)"
    special_sequence_change_point = 2
    special_sequence = list(null,
                          /datum/surgery_step/apply_synthmuscle,
                          /datum/surgery_step/apply_muscle_growth,
                          /datum/surgery_step/stitch_muscle
                          )

/datum/surgery_procedure/fix_muscle/hemorrage
    name = "Muscle Reparation Procedure (Hemorraging)"
    special_sequence_change_point = 2
    special_sequence = list(null,
                          /datum/surgery_step/retract_muscle,
                          /datum/surgery_step/rebuild_muscle_veins,
                          /datum/surgery_step/apply_muscle_growth
                          )

/*

	Severe wound procedures
	Messing with organs

*/