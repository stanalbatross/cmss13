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
- MD backend changes, unused mini MD, can see toggled range mode
- Internal mag guns no longer switch hands on unload if preference enabled

- BREAKING ONEHAND FIRING IS BROKEN
*/


/datum/tech/droppod/item/prototype_equipment/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["M2 Thermal Goggles"] = /obj/item/storage/box/m2t_thermals
	.["B18 Defensive Armor"] = /obj/item/clothing/suit/storage/marine/b18_tech
	.["XM-42b Railgun"] = /obj/item/weapon/gun/lever_action/railgun

/obj/item/storage/box/m2t_thermals
	name = "M2T storage Case"
	desc = "This case contains a set of M2T thermal goggles, a screwdriver, and a backup battery."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "m43case"
	w_class = SIZE_SMALL
	max_w_class = SIZE_TINY
	storage_slots = 3

/obj/item/storage/box/m2t_thermals/fill_preset_inventory()
	new /obj/item/prop/helmetgarb/helmet_nvg/functional/thermal(src)
	new /obj/item/cell/crap(src)
	new /obj/item/tool/screwdriver(src)
