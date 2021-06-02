/datum/tech/droppod/item/support_czsp
	name = "Support Combat Zone Package"
	desc = "Gives medics to use powerful tools to heal marines, and gives squad engineers a mod kit for their deployable."
	icon_state = "support_kit"
	droppod_name = "Support Package"

	flags = TREE_FLAG_MARINE

	required_points = 20
	tier = /datum/tier/one

/datum/tech/droppod/item/support_czsp/pre_item_stats(mob/user)
	. = ..()
	var/datum/supply_packs/SP = /datum/supply_packs/upgraded_medical_kits

	. += list(
		list(
			"content" = "Restricted usecase",
			"color" = "orange",
			"icon" = "exclamation-triangle",
			"tooltip" = "Only usable by medics or engineers."
		),
		list(
			"content" = "Requisition Unlock",
			"color" = "orange",
			"icon" = "unlock",
			"tooltip" = "Unlocks the option to purchase [initial(SP.name)]"
		)
	)

/datum/tech/droppod/item/support_czsp/on_unlock()
	. = ..()
	var/datum/supply_packs/SP = /datum/supply_packs/upgraded_medical_kits
	SP = supply_controller.supply_packs[initial(SP.name)]
	SP.buyable = TRUE

/datum/tech/droppod/item/support_czsp/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	if(!H || H.job == JOB_SQUAD_ENGI)
		.["Engineering Upgrade Kit"] = /obj/item/engi_upgrade_kit
	else if(!H || skillcheck(H, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		.["Medical CZSP"] = /obj/item/storage/box/combat_zone_support_package
	else
		var/type_to_add = /obj/item/storage/firstaid/regular

		.["First-Aid Kit"] = type_to_add

/obj/item/storage/box/combat_zone_support_package
	name = "medical combat support kit"
	use_sound = "toolbox"
	desc = "Contains upgraded medical kits, nanosplints and an upgraded defibrillator."
	icon_state = "medicbox"
	storage_slots = 4

/obj/item/storage/box/combat_zone_support_package/Initialize()
	. = ..()
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
	new /obj/item/stack/medical/advanced/ointment/upgraded(src)
	new /obj/item/stack/medical/splint/nano(src)
	new /obj/item/device/defibrillator/upgraded(src)


/obj/item/storage/box/medic_upgraded_kits
	name = "medical upgrade kit"
	icon_state = "upgradedkitbox"
	desc = "This kit holds upgraded trauma and burn kits, for critical injuries."
	max_w_class = SIZE_MEDIUM

	storage_slots = 2

/obj/item/storage/box/medic_upgraded_kits/Initialize()
	. = ..()
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
	new /obj/item/stack/medical/advanced/ointment/upgraded(src)

/obj/item/stack/medical/advanced/ointment/upgraded
	name = "upgraded burn kit"
	singular_name = "upgraded burn kit"
	stack_id = "upgraded advanced burn kit"

	icon_state = "burnkit_upgraded"
	desc = "An upgraded advanced burn treatment kit. Three times as effective as standard-issue, and non-replenishible. Use sparingly on only the most critical burns."

	max_amount = 10
	amount = 10

/obj/item/stack/medical/advanced/ointment/upgraded/Initialize(mapload, ...)
	. = ..()
	heal_burn = initial(heal_burn) * 3 // 3x stronger

/obj/item/stack/medical/advanced/bruise_pack/upgraded
	name = "upgraded trauma kit"
	singular_name = "upgraded trauma kit"
	stack_id = "upgraded advanced trauma kit"

	icon_state = "traumakit_upgraded"
	desc = "An upgraded advanced trauma treatment kit. Three times as effective as standard-issue, and non-replenishible. Use sparingly on only the most critical wounds."

	max_amount = 10
	amount = 10

/obj/item/stack/medical/advanced/bruise_pack/upgraded/Initialize(mapload, ...)
	. = ..()
	heal_brute = initial(heal_brute) * 3 // 3x stronger

/obj/item/stack/medical/splint/nano
	name = "nano splints"
	singular_name = "nano splint"

	icon_state = "nanosplint"
	desc = "Advanced technology allows these splints to hold bones in place while being flexible and damage-resistant. These aren't plentiful, so use them sparingly on critical areas."

	indestructible_splints = TRUE
	amount = 5
	max_amount = 5

	stack_id = "nano splint"

/obj/item/device/defibrillator/upgraded
	name = "upgraded emergency defibrillator"
	icon_state = "adv_defib"
	desc = "An advanced rechargeable defibrillator using induction to deliver shocks through metallic objects, such as armor, and does so with much greater efficiency than the standard variant."

	blocked_by_suit = FALSE
	heart_damage_to_deal = 0
	damage_heal_threshold = 35

/obj/item/engi_upgrade_kit
	name = "engineering upgrade kit"
	desc = "A kit used to upgrade the defenses of an engineer's sentry."

	icon = 'icons/obj/items/pro_case.dmi'
	icon_state = "pro_case_large"

/obj/item/engi_upgrade_kit/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/item/engi_upgrade_kit/update_icon()
	overlays.Cut()
	. = ..()

	overlays += "+defense"

/obj/item/engi_upgrade_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!ishuman(user))
		return ..()

	if(!istype(target, /obj/item/defenses/handheld))
		return ..()

	var/obj/item/defenses/handheld/D = target
	var/mob/living/carbon/human/H = user

	var/chosen_upgrade = tgui_input_list(user, "Please select a valid upgrade to apply to this kit", "Droppod", D.upgrade_list)

	if(QDELETED(D) || !D.upgrade_list[chosen_upgrade])
		return

	var/type_to_change_to = D.upgrade_list[chosen_upgrade]

	if(!type_to_change_to)
		return

	H.drop_inv_item_on_ground(D)
	qdel(D)

	D = new type_to_change_to()
	H.put_in_any_hand_if_possible(D)

	if(D.loc != H)
		D.forceMove(H.loc)

	H.drop_held_item(src)
	qdel(src)
