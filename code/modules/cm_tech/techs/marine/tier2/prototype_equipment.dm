/datum/tech/droppod/item/prototype_equipment
	name = "Prototype Equipment"
	desc = "Gain access to prototype USCM weaponry and equipment."
	icon_state = "equipment"

	droppod_name = "Prototype Equipment"

	flags = TREE_FLAG_MARINE

	required_points = 20
	tier = /datum/tier/two

	droppod_input_message = "Choose a piece of prototype gear to retrieve from the droppod."
	options_to_give = 1

/*
INTERNAL CL
- New T2 tech
- Added Thermal NVGs
- Added b18, breaks apart over time, has injectors and self-scan
- Added pogers railgun, lever-action mechanics
- Added lever-action rifle to freelancers (not yet)

Code changes:
- NVG backend
- Added two item procs that happen in every u_/equip() call
- Added new signal for direct bullet hits.
- MD backend changes
- Internal mag guns no longer switch hands on unload if preference enabled
*/


/datum/tech/droppod/item/prototype_equipment/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["M2 Thermal Goggles"] = /obj/item/storage/box/m3t_thermals
	.["B17 Armor"] = /obj/item/clothing/suit/storage/marine/b18_tech
	.["XM12-P Railgun"] = /obj/item/weapon/gun/rifle/m16

/obj/item/storage/box/m3t_thermals
	name = "M2T storage Case"
	desc = "This case contains a set of M2T thermal goggles and a backup battery."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "m43case"
	w_class = SIZE_SMALL
	max_w_class = SIZE_TINY
	storage_slots = 2

/obj/item/storage/box/m3t_thermals/fill_preset_inventory()
	new /obj/item/prop/helmetgarb/helmet_nvg/functional/thermal(src)
	new /obj/item/cell/crap(src)

/obj/item/clothing/suit/storage/marine/b18_tech
	name = "\improper B18 prototype defensive armor"
	desc = "A proof-of-concept prototype based on MG-GL armor intended to absorb more damage. Unfortunately. due to internal flaws it has been known to break after heavy usage."
	icon_state = "xarmor"
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_VERYHIGH
	armor_bio = CLOTHING_ARMOR_HIGHPLUS
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_HIGHPLUS
	storage_slots = 2
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	slowdown = SLOWDOWN_ARMOR_LOWHEAVY
	unacidable = FALSE
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/specialist/quick_scan, /datum/action/item_action/specialist/create_injector)
	var/injections = 4
	var/integrity = 100
	var/integrity_mult = 0.35
	var/flat_dmg_mult = 0.75
	var/BBs_to_resist = 3

/obj/item/clothing/suit/storage/marine/b18_tech/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("A readout on the side says [integrity]% INTEGRITY. [BBs_to_resist]/3 of its plasteel plates are intact."))

/obj/item/clothing/suit/storage/marine/b18_tech/on_equip(var/mob/living/carbon/human/user)
	RegisterSignal(user, COMSIG_HUMAN_TAKE_DAMAGE, .proc/handle_integrity)
	RegisterSignal(user, COMSIG_HUMAN_BONEBREAK_PROBABILITY, .proc/handle_bonebreak)

/obj/item/clothing/suit/storage/marine/b18_tech/on_unequip(var/mob/living/carbon/human/user)
	UnregisterSignal(user, list(COMSIG_HUMAN_TAKE_DAMAGE, COMSIG_HUMAN_BONEBREAK_PROBABILITY))

/obj/item/clothing/suit/storage/marine/b18_tech/proc/handle_integrity(var/mob/living/carbon/human/user, list/damagedata, damagetype)
	SIGNAL_HANDLER
	//flat reduce some incoming damage (because only god knows how our damage + armor system works)
	damagedata["damage"] = damagedata["damage"] * flat_dmg_mult

	var/armor_damage = damagedata["damage"] * integrity_mult
	integrity = integrity - armor_damage

	if(integrity <= 0)
		to_chat(user, SPAN_HIGHDANGER("[src] breaks apart!!"))
		playsound(user, 'sound/effects/metal_crash.ogg', 20, TRUE)
		new /obj/item/stack/sheet/metal(user.loc, 2)
		new /obj/item/stack/sheet/plasteel(user.loc, 2)
		new /obj/item/stack/rods(user.loc, 4)
		new /obj/item/stack/rods/plasteel(user.loc, 4)
		UnregisterSignal(user, list(COMSIG_HUMAN_TAKE_DAMAGE, COMSIG_HUMAN_BONEBREAK_PROBABILITY))
		for(var/obj/item/I in pockets) //make sure items inside armor aren't qdelled
			pockets.remove_from_storage(I, user.loc)
		qdel(src)
		return

/obj/item/clothing/suit/storage/marine/b18_tech/proc/handle_bonebreak(var/mob/living/carbon/human/user, list/bonebreak_data)
	SIGNAL_HANDLER
	if(BBs_to_resist)
		playsound(user, "bonk", 75, TRUE)
		user.visible_message(SPAN_NOTICE("[user]'s armor protects him from the blow!"), SPAN_NOTICE("Your [src] protects you from the blow!"))
		bonebreak_data["bonebreak_probability"] = 0
		BBs_to_resist--

/datum/action/item_action/specialist/quick_scan
	ability_primacy = SPEC_PRIMARY_ACTION_1
	name = "Scan Health"

/datum/action/item_action/specialist/quick_scan/New(var/mob/living/user, var/obj/item/holder)
	..()
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "quick_scan")
	button.overlays += IMG

//ideally this would be a component, but i am not going to do that
/datum/action/item_action/specialist/quick_scan/update_button_icon()
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "quick_scan")
	button.overlays += IMG

/datum/action/item_action/specialist/quick_scan/can_use_action()
	return TRUE

/datum/action/item_action/specialist/quick_scan/action_activate()
	var/mob/living/carbon/human/H = owner
	H.health_scan(H, TRUE, 1, 1)

/datum/action/item_action/specialist/create_injector
	ability_primacy = SPEC_PRIMARY_ACTION_2
	name = "Create Injector"

/datum/action/item_action/specialist/create_injector/New(var/mob/living/user, var/obj/item/holder)
	..()
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "firstaid")
	button.overlays += IMG

/datum/action/item_action/specialist/create_injector/update_button_icon()
	button.overlays.Cut()
	var/obj/item/clothing/suit/storage/marine/b18_tech/armor = holder_item
	var/image/IMG
	if(armor.injections)
		IMG = image('icons/mob/hud/actions.dmi', button, "firstaid")
	else
		IMG = image('icons/mob/hud/actions.dmi', button, "firstaid_e")
	button.overlays += IMG

/datum/action/item_action/specialist/create_injector/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(!H.is_mob_incapacitated() && !H.lying && holder_item == H.wear_suit)
		return TRUE

/datum/action/item_action/specialist/create_injector/action_activate()
	var/mob/living/carbon/human/H = owner
	var/obj/item/clothing/suit/storage/marine/b18_tech/armor = holder_item
	if(!armor.injections)
		to_chat(H, SPAN_NOTICE("[armor] is out of injectors!"))
		return

	var/active_hand_place = TRUE
	if(H.get_active_hand())
		if(H.get_inactive_hand())
			to_chat(H, SPAN_NOTICE("Your hands are full!"))
			return
		else
			active_hand_place = FALSE

	var/obj/item/reagent_container/hypospray/autoinjector/skillless/injector = new(H)
	to_chat(H, SPAN_NOTICE(" You feel a faint hiss as a [src] slides off the arm guard into your hand."))
	active_hand_place ? H.put_in_active_hand(injector) : H.put_in_inactive_hand(injector)
	playsound(H, 'sound/machines/click.ogg', 15, TRUE)
	armor.injections--
	update_button_icon()
