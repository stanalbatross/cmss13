/datum/surgery_step/incision
	name = "Make Incision"
	tools = list(/obj/item/tool/surgery/scalpel = 100, /obj/item/attachable/bayonet = 80, /obj/item/tool/kitchen/knife = 65, /obj/item/shard = 35)
	time = 1.5 SECONDS

/datum/surgery_step/incision/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts making an incision on [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start making an incision on [target]'s [parse_zone(target_zone)] with \the [tool] ..."))

/datum/surgery_step/incision/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(2, BRUTE, target_zone)
	return ..()
	

/datum/surgery_step/clamp_bleeders
	name = "Clamp Bleeders"
	tools = list(/obj/item/tool/surgery/hemostat = 100, /obj/item/tool/wirecutters = 65, /obj/item/stack/cable_coil = 15)
	time = 2 SECONDS

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to clamp bleeders on [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start clamping bleeders on [target]'s [parse_zone(target_zone)] with \the [tool] ..."))

/datum/surgery_step/clamp_bleeders/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.affected_limb.add_bleeding(5)
	. = ..()
	

/datum/surgery_step/close_incision
	name = "Close incision"
	tools = list(/obj/item/tool/surgery/surgical_line = 100, /obj/item/tool/surgery/cautery = 75, /obj/item/tool/lighter = 50, /obj/item/stack/cable_coil = 10)
	time = 2 SECONDS

/datum/surgery_step/close_incision/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts closing the incision on [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start closing the incision on \the [parse_zone(target_zone)] with \the [tool] ..."))

/datum/surgery_step/retract_skin
	name = "Retract skin"
	time = 1.5 SECONDS
	tools = list(/obj/item/tool/surgery/retractor = 100, /obj/item/tool/surgery/hemostat = 60, /obj/item/attachable/bayonet = 40, /obj/item/stack/cable_coil = 25)

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts retracting [target]'s [parse_zone(target_zone)]'s skin with \the [tool]."),
		SPAN_NOTICE("You start retracting \the [parse_zone(target_zone)]'s skin with \the [tool]..."))

/datum/surgery_step/saw_ribcage
	name = "Saw ribcage"
	tools = list(/obj/item/tool/surgery/circular_saw = 100,/obj/item/attachable/bayonet = 60, /obj/item/weapon/melee/twohanded/fireaxe = 50, /obj/item/tool/hatchet = 35, /obj/item/tool/kitchen/knife/butcher = 25)
	time = 4 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/saw_ribcage/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to saw [target]'s ribcage with \the [tool]."),
		SPAN_NOTICE("You start sawing [target]'s ribcage with \the [tool] ..."))

/datum/surgery_step/saw_ribcage/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] saws [target]'s ribcage open!"),
		SPAN_NOTICE("You saw [target]'s ribcage open!"))
	target.apply_damage(50, BRUTE, target_zone)
	return ..()

/datum/surgery_step/saw_ribcage/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.affected_limb.take_damage(25)
	. = ..()
	

/datum/surgery_step/open_ribcage
	name = "Open ribcage"
	tools = list(/obj/item/tool/surgery/retractor = 100, /obj/item/tool/crowbar = 25)
	time = 3 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/open_ribcage/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to force [target]'s ribcage open with \the [tool]."),
		SPAN_NOTICE("You start forcing [target]'s ribcage open with \the [tool] ..."))

/datum/surgery_step/close_ribcage
	name = "Close ribcage"
	tools = list(/obj/item/tool/surgery/retractor = 100, /obj/item/tool/crowbar = 25)
	time = 3 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/close_ribcage/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to close [target]'s ribcage with \the [tool]."),
		SPAN_NOTICE("You start closing [target]'s ribcage with \the [tool] ..."))

/datum/surgery_step/mend_ribcage
	name = "Mend ribcage"
	tools = list(/obj/item/tool/surgery/cell_gel = 100, /obj/item/tool/surgery/surgical_line = 25, /obj/item/stack/cable_coil = 5)
	time = 4 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/mend_ribcage/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] tries to mend the [target]'s ribcage with \the [tool]."),
		SPAN_NOTICE("You start mending [target]'s ribcage with \the [tool] ..."))

/datum/surgery_step/mend_ribcage/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/tool/surgery/cell_gel))
		surgery.affected_limb.heal_damage(50)
		return ..()
	else
		user.visible_message(SPAN_NOTICE("[user] succeeds... somewhat"),
			SPAN_NOTICE("You succeed... more or less"))
	return TRUE

/datum/surgery_step/cauterize
	name = "Cauterize"
	tools = list(/obj/item/tool/surgery/cautery = 100, /obj/item/tool/lighter = 35)
	time = 6 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/cauterize/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] starts cauterizing [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start cauterizing \the [parse_zone(target_zone)] with \the [tool] ..."))

/datum/surgery_step/cauterize/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.affected_limb.remove_all_bleeding()
	return ..()

/datum/surgery_step/cauterize/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(5, BURN, target_zone)
	return ..()