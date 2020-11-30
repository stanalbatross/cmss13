/datum/surgery/amputate
	name = "Amputation"
	possible_locs = EXTREMITY_LIMBS
	steps = list(
		/datum/surgery_step/incision,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/cut_muscle,
		/datum/surgery_step/saw_off_limb,
		/datum/surgery_step/carve_amputation,
		/datum/surgery_step/close_ruptured_veins,
		/datum/surgery_step/close_amputation
	)

/datum/surgery/amputate/can_start(mob/user, mob/living/patient)
	. = ..()
	

/datum/surgery_step/cut_muscle
	name = "Cut muscular tissue"
	tools = list(/obj/item/tool/surgery/scalpel = 100, /obj/item/attachable/bayonet = 80, /obj/item/tool/kitchen/knife = 65, /obj/item/shard = 35)
	required_surgery_skill = SKILL_SURGERY_TRAINED
	time = 5 SECONDS

/datum/surgery_step/cut_muscle/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts cutting through [target]'s [parse_zone(target_zone)]'s muscles with \the [tool]."),
		SPAN_NOTICE("You start cutting through \the [parse_zone(target_zone)]'s muscular tissue with \the [tool] ..."))

/datum/surgery_step/cut_muscle/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(20, BRUTE, target_zone)
	return ..()

/datum/surgery_step/cut_muscle/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(25, BRUTE, target_zone)
	return ..()
	  

/datum/surgery_step/saw_off_limb
	name = "Disconnect limb"
	tools = list(/obj/item/tool/surgery/circular_saw = 100, /obj/item/weapon/melee/claymore/mercsword/machete = 50, /obj/item/attachable/bayonet = 25, /obj/item/tool/kitchen/knife = 10, /obj/item/shard = 1)
	required_surgery_skill = SKILL_SURGERY_TRAINED
	time = 6 SECONDS

/datum/surgery_step/saw_off_limb/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to cut through [target]'s [parse_zone(target_zone)]'s bone with \the [tool]."),
		SPAN_NOTICE("You start cutting through \the [parse_zone(target_zone)]'s bone with \the [tool] ..."))

/datum/surgery_step/saw_off_limb/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(20, BRUTE, target_zone)
	surgery.affected_limb.droplimb(TRUE)
	return ..()

/datum/surgery_step/saw_off_limb/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(25, BRUTE, target_zone)
	return ..()

/datum/surgery_step/carve_amputation
	name = "Remove torn flesh"
	tools = list(/obj/item/tool/surgery/scalpel = 100, /obj/item/attachable/bayonet = 80, /obj/item/tool/kitchen/knife = 65, /obj/item/shard = 35)
	time = 5 SECONDS

/datum/surgery_step/carve_amputation/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to cut off irregular chunks of flesh on [target]'s stump with \the [tool]."),
		SPAN_NOTICE("You begin to carve out irregular chunks of flesh in \the [parse_zone(target_zone)]'s stump with \the [tool] ..."))

/datum/surgery_step/carve_amputation/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(-20, BRUTE, target_zone)
	return ..()

/datum/surgery_step/carve_amputation/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(5, BRUTE, target_zone)
	return ..()

/datum/surgery_step/close_amputation
	name = "Seal amputated limb"
	tools = list(/obj/item/tool/surgery/surgical_line = 100, /obj/item/tool/surgery/cautery = 60, /obj/item/stack/cable_coil = 20)
	time = 4 SECONDS

/datum/surgery_step/close_amputation/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to close [target]'s stump with \the [tool]."),
		SPAN_NOTICE("You begin to close \the [parse_zone(target_zone)]'s stump with \the [tool] ..."))

/datum/surgery_step/close_amputation/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/limb/L = surgery.affected_limb
	L.heal_damage(200, 200)
	L.set_integrity_level(LIMB_INTEGRITY_PERFECT)
	return ..()

/datum/surgery_step/close_amputation/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(2, BURN, target_zone)
	return ..()

/datum/surgery/prosthetical_replacement
	name = "Prosthetical replacement"
	steps = list(
		/datum/surgery_step/connect_prosthesis,
		/datum/surgery_step/strenghten_prosthesis_connection,
		/datum/surgery_step/calibrate_prosthesis
	)
	possible_locs = EXTREMITY_LIMBS
	pain_reduction_required = 0
	can_cancel = FALSE
	requires_bodypart = FALSE

/datum/surgery/prosthetical_replacement/can_start(mob/user, mob/living/carbon/patient)
	var/obj/limb/L = patient.get_limb(user.zone_selected)
	if(!L)
		return FALSE
	if(L.get_damage() > 5)
		return FALSE
	return ..()

/datum/surgery_step/connect_prosthesis
	name = "Connect prosthesis"
	tools = list(/obj/item/robot_parts = 100)
	time = 5 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/connect_prosthesis/preop(mob/user, mob/living/target, target_zone, obj/item/robot_parts/tool, datum/surgery/surgery)
	if(!(tool.body_part & surgery.affected_limb.body_part))
		to_chat(user, SPAN_WARNING("\The [tool] cannot be used to replaced a missing [parse_zone(target_zone)]"))
		return -1
	
	user.visible_message(SPAN_NOTICE("[user] starts connecting \the [tool] to [target]'s [parse_zone(target_zone)]."),
		SPAN_NOTICE("You start connecting \the [tool] to \the [parse_zone(target_zone)] ..."))
	
/datum/surgery_step/connect_prosthesis/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/limb/L = surgery.affected_limb
	L.status = LIMB_ROBOTIC
	L.destroyed = FALSE
	L.heal_damage(1000, 1000, FALSE, TRUE)
	L.set_integrity_level(LIMB_INTEGRITY_EFFECT_CRITICAL)
	target.update_body()
	user.temp_drop_inv_item(tool)
	qdel(tool)
	return ..()
	
/datum/surgery_step/strenghten_prosthesis_connection
	name = "Strenghten prosthesis connection"
	accept_hand = TRUE
	time = 3 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/strenghten_prosthesis_connection/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts to strenghten [target]'s prosthetical [parse_zone(target_zone)] connection to the body."),
		SPAN_NOTICE("You start strenghtening the prosthetical [parse_zone(target_zone)]'s connection to [target]'s body ..."))

/datum/surgery_step/strenghten_prosthesis_connection/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.affected_limb.set_integrity_level(LIMB_INTEGRITY_THRESHOLD_CONCERNING)
	return ..()
	
/datum/surgery_step/calibrate_prosthesis
	name = "Calibrate prosthesis"
	accept_hand = TRUE
	time = 3 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/calibrate_prosthesis/datum/surgery_step/strenghten_prosthesis_connection/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts calibrating [target]'s prosthetical [parse_zone(target_zone)]."),
		SPAN_NOTICE("You start calibrating the prosthetical [parse_zone(target_zone)] ..."))

/datum/surgery_step/calibrate_prosthesis/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.affected_limb.set_integrity_level(LIMB_INTEGRITY_THRESHOLD_PERFECT)
	return ..()
