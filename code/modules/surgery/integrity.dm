
/datum/surgery/stitching
    name = "Regenerative Stitching"
    steps = list(/datum/surgery_step/desinfect,
                 /datum/surgery_step/apply_healing_paste,
                 /datum/surgery_step/pull_skin,
                 /datum/surgery_step/sew_flesh)

/datum/surgery/stitching/can_start(mob/user, mob/living/carbon/patient)
    . = FALSE
    var/obj/limb/L = patient.get_limb(user.zone_selected)
    if(L)
        if(L.integrity_level == LIMB_INTEGRITY_OKAY)
            return TRUE

/datum/surgery_step/desinfect
    name = "Desinfect"
    time = 5 SECONDS
    tools = list(/obj/item/reagent_container/spray/cleaner = 100)

/datum/surgery_step/desinfect/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    user.visible_message(SPAN_NOTICE("[user] begins to disinfect [target]'s [parse_zone(target_zone)]."),
		SPAN_NOTICE("You begin to disinfect [target]'s [parse_zone(target_zone)]..."))
    
/datum/surgery_step/apply_healing_paste
    name = "Apply healing paste"
    time = 5 SECONDS
    tools = list(/obj/item/stack/medical/advanced/bruise_pack = 100)

/datum/surgery_step/apply_healing_paste/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    user.visible_message(SPAN_NOTICE("[user] starts applying [tool] to [target]'s [parse_zone(target_zone)]."),
		SPAN_NOTICE("You start applying [tool] to [target]'s [parse_zone(target_zone)]..."))

/datum/surgery_step/apply_healing_paste/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    . = ..()
    target.apply_damage(3, BRUTE,target_zone)

/datum/surgery_step/pull_skin
    name = "Pull skin"
    time = 5 SECONDS
    tools = list(/obj/item/tool/surgery/hemostat = 100)

/datum/surgery_step/pull_skin/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    user.visible_message(SPAN_NOTICE("[user] grabs [target]'s [parse_zone(target_zone)]'s skin with \the [tool]."),
		SPAN_NOTICE("You pull \the [parse_zone(target_zone)]'s skin with \the [tool]..."))

/datum/surgery_step/sew_flesh
    name = "Sew Flesh"
    time = 5 SECONDS    
    tools = list(/obj/item/stack/cable_coil = 100)

/datum/surgery_step/sew_flesh/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    user.visible_message(SPAN_NOTICE("[user] starts sewing [target]'s [parse_zone(target_zone)]'s skin shut with \the [tool]."),
		SPAN_NOTICE("You start sewing \the [parse_zone(target_zone)]'s skin shut with \the [tool]..."))

/datum/surgery_step/sew_flesh/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    user.visible_message(SPAN_NOTICE("[user] sews [target]'s [parse_zone(target_zone)]'s skin shut."),
		SPAN_NOTICE("You sew \the [parse_zone(target_zone)]'s skin shut!"))

    if(surgery.affected_limb)
        surgery.affected_limb.set_integrity_level(LIMB_INTEGRITY_PERFECT)
    
    return TRUE    