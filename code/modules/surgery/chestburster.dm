/datum/surgery/chestburster_removal
	name = "Experimental Xenomorph Parasite Removal"
	possible_locs = list(LIMB_CHEST)
	pain_reduction_required = PAIN_REDUCTION_FULL
	steps = list(
		/datum/surgery_step/incision,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw_ribcage,
		/datum/surgery_step/open_ribcage,
		/datum/surgery_step/cut_larval_pseudoroots,
		/datum/surgery_step/remove_larva,
		/datum/surgery_step/close_ribcage,
		/datum/surgery_step/mend_ribcage,
		/datum/surgery_step/close_incision 
	)

/datum/surgery/chestburster_removal/can_start(mob/user, mob/living/patient)
	. = FALSE
	if(!locate(/obj/structure/machinery/optable) in get_turf(patient))
		return
	
	var/obj/item/alien_embryo/A = locate() in patient
	if(A)
		return TRUE

/datum/surgery_step/cut_larval_pseudoroots
	name = "Cut Larval Pseudoroots"
	tools = list(/obj/item/tool/surgery/pict_system = 100, /obj/item/tool/surgery/scalpel = 100, /obj/item/attachable/bayonet = 80, /obj/item/tool/kitchen/knife = 65, /obj/item/shard = 35)
	time = 5 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/cut_larval_pseudoroots/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	 user.visible_message(SPAN_NOTICE("[user] starts carefully cutting off the tubes connecting the alien larva to [target]'s [parse_zone(target_zone)] with \the [tool]."),
		SPAN_NOTICE("You start carefully cutting off the larva's pseudoroots from the [parse_zone(target_zone)] with \the [tool] ..."))

/datum/surgery_step/cut_larval_pseudoroots/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/tool/surgery/pict_system))
		return ..()
	else
		user.visible_message(SPAN_NOTICE("Pressurized acid is sprayed from the cut tubes as [user] finishes the procedure!"),
			SPAN_NOTICE("You suceed... but are sprayed by pressurized acid coming from the larva's cut tubes!"))
		create_shrapnel(target, 8, null, null, /datum/ammo/xeno/acid, null, target, TRUE)
		target.apply_damage(15, BURN, target_zone)

		return TRUE

/datum/surgery_step/remove_larva
	name = "Remove Larva"
	accept_hand = TRUE
	time = 4 SECONDS
	required_surgery_skill = SKILL_SURGERY_TRAINED

/datum/surgery_step/remove_larva/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	 user.visible_message(SPAN_NOTICE("[user] tries to remove the disconnected larva from [target]'s [parse_zone(target_zone)]."),
		SPAN_NOTICE("You try to remove the disconnected larva from \the [parse_zone(target_zone)] ..."))

/datum/surgery_step/remove_larva/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/alien_embryo/A = locate() in target
	if(A)
		user.visible_message(SPAN_WARNING("[user] removes a wriggling parasite out of [target]'s ribcage!"),
							 SPAN_WARNING("You remove a wriggling parasite out of [target]'s ribcage!"))
		user.count_niche_stat(STATISTICS_NICHE_SURGERY_LARVA)
		var/mob/living/carbon/Xenomorph/Larva/L = locate() in target //the larva was fully grown, ready to burst.
		if(L)
			L.forceMove(target.loc)
			qdel(A)
		else
			A.forceMove(target.loc)
			target.status_flags &= ~XENO_HOST
	return ..()
