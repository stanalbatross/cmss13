/datum/tech/droppod/item/enhanced_antibiologicals
	name = "Enhanced Antibiologicals"
	desc = "Marines get access to limited-use kits that can convert ammo magazines into the specified ammo."

	flags = TREE_FLAG_MARINE

	required_points = 0
	tier = /datum/tier/two

	droppod_input_message = "Choose an ammo kit to retrieve from the droppod."

/datum/tech/droppod/item/enhanced_antibiologicals/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["Incendiary Ammo Kit"] = /obj/item/ammo_kit/incendiary
	.["Wall-Piercing Ammo Kit"] = /obj/item/ammo_kit/penetrating
	.["Toxin Ammo Kit"] = /obj/item/ammo_kit/toxin

/obj/item/ammo_kit
	name = "ammo kit"
	desc = "An ammo kit used to convert regular ammo magazines of various weapons into a different variation."
	icon_state = "soap"

	var/list/convert_map
	var/uses = 5

/obj/item/ammo_kit/Initialize(mapload, ...)
	. = ..()
	convert_map = get_convert_map()

/obj/item/ammo_kit/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("It has [uses] uses remaining."))

/obj/item/ammo_kit/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!(target.type in convert_map))
		return ..()

	var/obj/item/ammo_magazine/M = target
	if(M.current_rounds < M.max_rounds)
		to_chat(user, SPAN_WARNING("The magazine needs to be full for you to apply this kit onto it."))
		return

	if(user.l_hand != M && user.r_hand != M)
		to_chat(user, SPAN_WARNING("The magazine needs to be in your hands for you to apply this kit onto it."))
		return

	var/type_to_convert_to = convert_map[target.type]

	user.drop_held_item(M)
	QDEL_NULL(M)
	M = new type_to_convert_to(get_turf(user))
	user.put_in_any_hand_if_possible(M)
	uses -= 1
	playsound(get_turf(user), "sound/machines/fax.ogg", 5)


/obj/item/ammo_kit/proc/get_convert_map()
	return list()

/obj/item/ammo_kit/incendiary
	name = "incendiary ammo kit"
	icon_state = "soapsyndie"

/obj/item/ammo_kit/incendiary/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/handful/shotgun] = /obj/item/ammo_magazine/handful/shotgun/incendiary
	.[/obj/item/ammo_magazine/handful/shotgun/buckshot] = /obj/item/ammo_magazine/handful/shotgun/custom/incendiary
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/incendiary
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/incendiary
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/incendiary
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/incendiary

/obj/item/ammo_kit/penetrating
	name = "wall-piercing ammo kit"
	icon_state = "soapnt"

/obj/item/ammo_kit/penetrating/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/penetrating
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/penetrating
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/penetrating
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/penetrating

/obj/item/ammo_kit/toxin
	name = "toxin ammo kit"
	icon_state = "soapdeluxe"

/obj/item/ammo_kit/toxin/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/toxin
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/toxin
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/toxin
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/toxin
