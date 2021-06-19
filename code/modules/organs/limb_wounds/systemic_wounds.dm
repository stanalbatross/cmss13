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


