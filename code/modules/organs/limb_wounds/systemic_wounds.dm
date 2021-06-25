//All names are placeholders

//Chest

/datum/limb_wound/low_adrenaline
    name = "Low Adrenaline"
/datum/limb_wound/low_adrenaline/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_STOP_DEFIBHEAL, .proc/cancel_defib_heal)
    RegisterSignal(owner, COMSIG_MOB_BONUS_DAMAGE, .proc/bonus_burn_damage)

/datum/limb_wound/low_adrenaline/remove_debuffs()
    ..()
    UnregisterSignal(owner, list(COMSIG_MOB_STOP_DEFIBHEAL, COMSIG_MOB_BONUS_DAMAGE))

/datum/limb_wound/low_adrenaline/proc/bonus_burn_damage(var/mob/living/M, list/damagedata)
	SIGNAL_HANDLER
	damagedata["damage_bonus"] *= 1.65

/datum/limb_wound/low_adrenaline/proc/cancel_defib_heal()
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_DEFIB_HEAL

//Head

/datum/limb_wound/minor_concussion
    name = "Minor Concussion"

/datum/limb_wound/minor_concussion/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_PRE_ITEM_ZOOM, .proc/block_zoom)
    RegisterSignal(owner, COMSIG_MOB_APPLY_STUTTER, .proc/handle_stutter)

/datum/limb_wound/minor_concussion/remove_debuffs()
    ..()
    UnregisterSignal(owner, list(COMSIG_MOB_PRE_ITEM_ZOOM, COMSIG_MOB_APPLY_STUTTER))

/datum/limb_wound/minor_concussion/proc/block_zoom(obj/item/O)
	SIGNAL_HANDLER
	to_chat(owner, SPAN_WARNING("You try to look through [O], but the blood and pain clouding your vision forces you to rub your eyes, lowering it in the process!"))
	return COMPONENT_CANCEL_ZOOM

/datum/limb_wound/minor_concussion/proc/handle_stutter()
	SIGNAL_HANDLER
	return COMPONENT_ADD_STUTTERING

/datum/limb_wound/ruptured_globe
    name = "Ruptured Globe"

/datum/limb_wound/ruptured_globe/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_PRE_GLASSES_SIGHT_BONUS, .proc/block_night_vision)
    RegisterSignal(owner, COMSIG_MOB_PRE_EYE_TINTCHECK, .proc/add_eye_tint)

/datum/limb_wound/ruptured_globe/remove_debuffs()
    ..()
    UnregisterSignal(owner, list(COMSIG_MOB_PRE_GLASSES_SIGHT_BONUS, COMSIG_MOB_PRE_EYE_TINTCHECK))

/datum/limb_wound/ruptured_globe/proc/block_night_vision()
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_GLASSES_SIGHT_BONUS

/datum/limb_wound/ruptured_globe/proc/add_eye_tint()
	SIGNAL_HANDLER
	return COMPONENT_ADD_EYETINT

//Groin

/datum/limb_wound/vomit_reflex
    name = "Vomit Reflex"

/datum/limb_wound/vomit_reflex/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_INGESTION, .proc/ingestion_cancel)
/datum/limb_wound/vomit_reflex/remove_debuffs()
    ..()
    UnregisterSignal(owner, COMSIG_MOB_INGESTION)

/datum/limb_wound/vomit_reflex/proc/ingestion_cancel(mob/living/carbon/human/H, obj/item/reagent_container/ingested)
	SIGNAL_HANDLER
	var/turf/T = get_turf(H)
	to_chat(H, SPAN_WARNING("You violently throw up a chunk of the contents of \the [ingested] as your body fails to properly digest it!")) // hey maybe you should go to a doctor MAYBE
	H.nutrition -= 20
	H.apply_damage(-3, TOX)
	playsound(T, 'sound/effects/splat.ogg', 25, 1, 7)
	T.add_vomit_floor(H)

	for(var/datum/reagent/R in ingested.reagents.reagent_list)
		H.reagents.remove_reagent(R.id, R.volume/2)

/datum/limb_wound/neurotoxin_vulnerability
    name = "Neurotoxin Vulnerability"

/datum/limb_wound/neurotoxin_vulnerability/apply_debuffs()
    ..()
    owner.xeno_neurotoxin_buff += 1.5
/datum/limb_wound/neurotoxin_vulnerability/remove_debuffs()
    ..()
    owner.xeno_neurotoxin_buff -= 1.5

//Legs

/datum/limb_wound/limited_joint_mobility
    name = "Limited Joint Mobility"

/datum/limb_wound/limited_joint_mobility/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_LIVING_CLIMB_STRUCTURE, .proc/handle_climb_delay)
    RegisterSignal(owner, COMSIG_MOB_ADD_DRAG_DELAY, .proc/handle_drag_delay)

/datum/limb_wound/limited_joint_mobility/remove_debuffs()
    ..()
    UnregisterSignal(owner, list(
			COMSIG_LIVING_CLIMB_STRUCTURE,
			COMSIG_MOB_ADD_DRAG_DELAY))

/datum/limb_wound/limited_joint_mobility/proc/handle_climb_delay(var/mob/living/M, list/climbdata)
	SIGNAL_HANDLER
	climbdata["climb_delay"] *= 2

/datum/limb_wound/limited_joint_mobility/proc/handle_drag_delay(var/mob/living/M, list/dragdata)
	SIGNAL_HANDLER
	dragdata["drag_delay"] *= 1.5

/datum/limb_wound/weakened_knee_musculature
    name = "Weakened Knee Musculature"

/datum/limb_wound/weakened_knee_musculature/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_ADD_KNOCKDOWN, .proc/add_knockdown)

/datum/limb_wound/weakened_knee_musculature/remove_debuffs()
    ..()
    UnregisterSignal(owner, COMSIG_MOB_ADD_KNOCKDOWN, .proc/add_knockdown)

/datum/limb_wound/weakened_knee_musculature/proc/add_knockdown(var/mob/living/M, list/knockdowndata)
	SIGNAL_HANDLER
	knockdowndata["knockdown"] += 1

//not variables to save on overhead

#define STUMBLE_TILES_UNTIL_COLLAPSE 20

#define WARNING_MESSAGE STUMBLE_TILES_UNTIL_COLLAPSE * 0.3
#define DANGER_MESSAGE STUMBLE_TILES_UNTIL_COLLAPSE * 0.6

#define MESSAGE_COOLDOWN 1.5 SECONDS

/datum/limb_wound/severely_torn_ligaments
	name = "Severely Torn Ligaments"
	var/steps_walking
	var/last_message_time
	var/datum/action/human_action/rest_legs/bound_action

/datum/limb_wound/severely_torn_ligaments/apply_debuffs()
	..()
	RegisterSignal(owner, COMSIG_MOVABLE_TURF_ENTERED, .proc/stumble)
	give_action(owner, /datum/action/human_action/rest_legs, null, null, src)

/datum/limb_wound/severely_torn_ligaments/remove_debuffs()
	..()
	UnregisterSignal(owner, COMSIG_MOVABLE_TURF_ENTERED, .proc/stumble)
	bound_action.unique_remove_action(owner, /datum/action/human_action/rest_legs, src)

/datum/limb_wound/severely_torn_ligaments/proc/stumble(var/mob/living/M)
	SIGNAL_HANDLER

	if(HAS_TRAIT(M, TRAIT_HOLDS_CANE))
		if(last_message_time + MESSAGE_COOLDOWN * 10 < world.time) //longer cooldown if using canes
			M.visible_message(SPAN_NOTICE("[M] paces \his movement with \his cane."), SPAN_NOTICE("Your cane lets you pace your movement, lessening the suffering on your [affected_limb.display_name]."))
			last_message_time = world.time // has the unfortunate downside of showing those messages when forcibly moved (thrown), but oh well
		steps_walking = max(steps_walking - 1, 0)
		return

	steps_walking++

	switch(steps_walking)
		if(WARNING_MESSAGE to DANGER_MESSAGE)
			if(last_message_time + MESSAGE_COOLDOWN < world.time)
				to_chat(M, SPAN_WARNING("Your damaged [affected_limb.display_name] skips half a step as you lose control of it from the increasing pain."))
				last_message_time = world.time
		if(DANGER_MESSAGE to STUMBLE_TILES_UNTIL_COLLAPSE)
			if(last_message_time + MESSAGE_COOLDOWN < world.time)
				to_chat(M, SPAN_DANGER("You stumble for an agonizing moment as your [affected_limb.display_name] rebels against you. You feel like you need to take a breath before walking again."))
				last_message_time = world.time
		if(STUMBLE_TILES_UNTIL_COLLAPSE to INFINITY)
			to_chat(M, SPAN_HIGHDANGER("Your [affected_limb.display_name] jerks wildly from incoherent pain!"))
			steps_walking = max(steps_walking - WARNING_MESSAGE, 0) //pity reduction
			var/stun_time = 3 SECONDS
			M.Shake(15, 0, stun_time)
			INVOKE_ASYNC(M, /mob/living/carbon/human.proc/emote, "pain")
			M.Stun(stun_time * 0.1) //already are seconds in Stun()
			addtimer(CALLBACK(src, .proc/rest_legs_pain, M, FALSE), stun_time)
			return

	INVOKE_ASYNC(src, .proc/rest_legs, M, FALSE)

/datum/limb_wound/severely_torn_ligaments/proc/rest_legs_pain(var/mob/living/M, var/action = FALSE)
	to_chat(M, SPAN_NOTICE("You can move again, but you should probably rest for a bit."))
	rest_legs(M, action)

/datum/limb_wound/severely_torn_ligaments/proc/rest_legs(var/mob/living/M, var/action = FALSE)

	if(!steps_walking)
		bound_action.in_use = FALSE
		if(!action)
			return FALSE
		to_chat(M, SPAN_WARNING("Your [affected_limb.display_name] seems to be as stable as it's going to get."))
		return FALSE

	var/show_icon = action ? BUSY_ICON_FRIENDLY : NO_BUSY_ICON
	bound_action.in_use = TRUE
	if(!do_after(M, 1.5 SECONDS, INTERRUPT_MOVED, show_icon))
		bound_action.in_use = FALSE
		if(!action)
			return FALSE
		to_chat(M, SPAN_WARNING("You need to stand still to rest your [affected_limb.display_name] for a moment."))
		return FALSE

	to_chat(M, SPAN_HELPFUL("The pain in your [affected_limb.display_name] [ (steps_walking > WARNING_MESSAGE) ? "slightly abates" : "subsides"] after your short rest."))
	steps_walking = max(steps_walking - WARNING_MESSAGE, 0)
	bound_action.in_use = FALSE
	rest_legs(M, action)
	return TRUE

/datum/action/human_action/rest_legs
	name = "Rest Leg"
	action_icon_state = "stumble"
	var/in_use = FALSE
	var/datum/limb_wound/severely_torn_ligaments/bound_wound

/datum/action/human_action/rest_legs/New(target, override_icon_state, var/datum/limb_wound/severely_torn_ligaments/bound_wound)
	. = ..()
	if(bound_wound)
		name = "Rest [bound_wound.affected_limb.display_name]"
		src.bound_wound = bound_wound
		src.bound_wound.bound_action = src
	else
		CRASH("No bound wound to link action")

/datum/action/human_action/rest_legs/action_activate()
	var/mob/living/carbon/human/H = owner
	if(in_use)
		to_chat(H, SPAN_WARNING("You're already doing that!"))
		return
	in_use = bound_wound.rest_legs(H, TRUE)

// Needs unique remove action due to possibility of two of these on the same mob.
/datum/action/human_action/rest_legs/proc/unique_remove_action(mob/L, action_path, var/datum/limb_wound/severely_torn_ligaments/bound_wound)
	for(var/datum/action/A as anything in L.actions)
		if(A.type == action_path && src.bound_wound == bound_wound)
			A.remove_from(L)
			return A

/obj/item/card/id/verb/break_leg()
	set name = "Debug break leg"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = usr
	var/obj/limb/leg/r_leg/RL
	for(var/obj/limb/L as anything in H.limbs)
		if(istype(L, /obj/limb/leg/r_leg))
			RL = L
	RL.integrity_damage = 200
	RL.integrity_level = 4
	to_chat(H, SPAN_HIGHDANGER("You hear a sound like paper tearing inside of your leg and your next step is noticeably painful. You should probably find a cane or a doctor."))
	H.add_limb_wound(/datum/limb_wound/severely_torn_ligaments, RL, LIMB_INTEGRITY_CRITICAL)

#undef STUMBLE_TILES_UNTIL_COLLAPSE

#undef WARNING_MESSAGE
#undef DANGER_MESSAGE

#undef MESSAGE_COOLDOWN

//Feet

/datum/limb_wound/ruptured_tendon
    name = "Ruptured Achilles Tendon"

/datum/limb_wound/ruptured_tendon/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_HUMAN_POST_MOVE_DELAY, .proc/increase_move_delay)

/datum/limb_wound/ruptured_tendon/remove_debuffs()
    UnregisterSignal(owner, COMSIG_HUMAN_POST_MOVE_DELAY)

/datum/limb_wound/ruptured_tendon/proc/increase_move_delay(var/mob/living/M, list/movedata)
	SIGNAL_HANDLER
	return COMPONENT_HUMAN_MOVE_DELAY_MALUS

//Arms

/datum/limb_wound/decreased_arm_muscle_functionality
    name = "Strained Muscles"
    var/work_delay_mult = 1.3

/datum/limb_wound/decreased_arm_muscle_functionality/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_ADD_DELAY, .proc/increase_work_delay)
    if(integrity_level > LIMB_INTEGRITY_CRITICAL)
        name = "Muscular Paralysis"
        work_delay_mult = 2
      
/datum/limb_wound/decreased_arm_muscle_functionality/remove_debuffs()
    ..()
    UnregisterSignal(owner, COMSIG_MOB_ADD_DELAY)

/datum/limb_wound/decreased_arm_muscle_functionality/proc/increase_work_delay(var/mob/living/M, list/delaydata)
	SIGNAL_HANDLER
	delaydata["work_delay"] *= work_delay_mult

/datum/limb_wound/ruptured_forearm_muscles
    name = "Ruptured Forearm Muscles"

/datum/limb_wound/ruptured_forearm_muscles/apply_debuffs()
    ..()
    owner.minimum_wield_delay += 5
    
/datum/limb_wound/ruptured_forearm_muscles/remove_debuffs()
    ..()
    owner.minimum_wield_delay -= 5

//Hands

/datum/limb_wound/sprained_hand_muscle
    name = "Sprained Muscles"

/datum/limb_wound/sprained_hand_muscle/apply_debuffs()
    ..()
    owner.action_delay += 8
    
/datum/limb_wound/sprained_hand_muscle/remove_debuffs()
    ..()
    owner.action_delay -= 8

/datum/limb_wound/fractured_wrist
    name = "Fractured Wrist"

/datum/limb_wound/fractured_wrist/apply_debuffs()
    ..()
    RegisterSignal(owner, COMSIG_MOB_ADD_RECOIL, .proc/decrease_gun_handling)
    
/datum/limb_wound/fractured_wrist/remove_debuffs()
    ..()
    UnregisterSignal(owner, COMPONENT_ADD_RECOIL)

/datum/limb_wound/fractured_wrist/proc/decrease_gun_handling()
	SIGNAL_HANDLER
	return COMPONENT_ADD_RECOIL 


