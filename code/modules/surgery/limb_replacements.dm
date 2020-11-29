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

