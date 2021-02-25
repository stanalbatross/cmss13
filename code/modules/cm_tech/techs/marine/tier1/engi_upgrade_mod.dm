/datum/tech/droppod/item/engi_czsp
	name = "Squad Engineer Combat Zone Support Package"
	desc = {"Gives upgraded composite (deployable) cades to regulars. \
			Gives squad engineers a mod kit for their deployable."}
	icon_state = "engi_kit"

	flags = TREE_FLAG_MARINE

	required_points = 0
	tier = /datum/tier/one

	options = list()

/datum/tech/droppod/item/engi_czsp/on_pod_access(mob/living/carbon/human/H, obj/structure/droppod/D)
	// We can change the options depending on who's accessing this
	var/list/newOptions
	LAZYINITLIST(newOptions)

	if(H.job == JOB_SQUAD_ENGI)
		LAZYSET(newOptions, "Engineering Upgrade Kit", /obj/item/engi_upgrade_kit)
	else
		LAZYSET(newOptions, "Random Tool", pick(common_tools))

	. = ..(H, D, newOptions)
	return

/obj/item/engi_upgrade_kit
	name = "engineering upgrade kit"
	desc = "It seems to be a kit to upgrade an engineer's structure"

	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrench"

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
