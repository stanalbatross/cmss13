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

/datum/tech/droppod/item/prototype_equipment/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["Thermal Goggles"] = /obj/item/device/implanter/nvg
	.["B17 Armor"] = /obj/item/device/implanter/rejuv
	.["XM12-P Railgun"] = /obj/item/device/implanter/agility

