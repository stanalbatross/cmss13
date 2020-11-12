/datum/surgery_step/incision
    name = "Superficial Incision"
    tools = list(/obj/item/tool/surgery/scalpel = 100, /obj/item/attachable/bayonet = 80, /obj/item/tool/kitchen/knife = 65, /obj/item/shard = 35)
    time = 2 SECONDS

/datum/surgery_step/incision/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
     user.visible_message(SPAN_NOTICE("[user] start making an incision on [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start making an incision on [target]'s [parse_zone(target_zone)] with \the [tool] ..."))
        
/datum/surgery_step/close_incision
    name = "Close incision"
    tools = list(/obj/item/tool/surgery/surgical_line = 100, /obj/item/tool/surgery/cautery = 75, /obj/item/tool/lighter = 50, /obj/item/stack/cable_coil = 10)
    time = 2 SECONDS

/datum/surgery_step/close_incision/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
     user.visible_message(SPAN_NOTICE("[user] starts closing the incision on [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start closing the incision on \the [parse_zone(target_zone)] with \the [tool] ..."))

/datum/surgery_step/retract_skin
    name = "Retract skin"
    time = 2 SECONDS
    tools = list(/obj/item/tool/surgery/retractor = 100, /obj/item/tool/surgery/hemostat = 60, /obj/item/attachable/bayonet = 40, /obj/item/stack/cable_coil = 25)

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
    user.visible_message(SPAN_NOTICE("[user] starts retracting [target]'s [parse_zone(target_zone)]'s skin with \the [tool]."),
		SPAN_NOTICE("You start retracting \the [parse_zone(target_zone)]'s skin with \the [tool]..."))
