/datum/tech/droppod/item/prototype_equipment
	name = "Prototype Equipment"
	desc = "Gain access to prototype USCM weaponry and equipment."
	icon_state = "ammo" //placeholder

	droppod_name = "Prototype Equipment"

	flags = TREE_FLAG_MARINE

	required_points = 20
	tier = /datum/tier/two

	droppod_input_message = "Choose a piece of prototype gear to retrieve from the droppod."
	options_to_give = 1

/datum/tech/droppod/item/prototype_equipment/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["M2 Thermal Goggles"] = /obj/item/storage/box/m2t_thermals
	.["B18 Defensive Armor"] = /obj/item/storage/box/spec/b18_tech
	.["Experimental Hoverpack"] = /obj/item/hoverpack

/obj/item/storage/box/m2t_thermals
	name = "M2T storage case"
	desc = "This case contains a set of M2T thermal goggles, a screwdriver, a backup battery, and a disclaimer at the bottom indicating that the USCM is 'not responsible for any permanent eye or brain damage incurred by the use of this device'."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "m43case" //placeholder :sunglasses:
	w_class = SIZE_SMALL
	max_w_class = SIZE_TINY
	storage_slots = 3

/obj/item/storage/box/m2t_thermals/fill_preset_inventory()
	new /obj/item/prop/helmetgarb/helmet_nvg/functional/thermal(src)
	new /obj/item/cell/crap(src)
	new /obj/item/tool/screwdriver(src)

/obj/item/storage/box/spec/b18_tech
	name = "\improper B18 prototype defensive case"
	desc = "A large case containing the experimental B18 armor platform. Handle with care, it's more expensive than all of Delta combined.\nDrag this sprite onto yourself to open it up! NOTE: You cannot put items back inside this case."
	kit_overlay = "b18"

/obj/item/storage/box/spec/b18_tech/fill_preset_inventory()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/b18_tech(src)
	new /obj/item/clothing/suit/storage/marine/b18_tech(src)
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/clothing/head/welding(src)
