


/datum/equipment_preset/fun/doomguy
	name = "Fun - Doomguy"
	paygrade = "???"
	flags = EQUIPMENT_PRESET_EXTRA

	skills = /datum/skills/everything //as the doomguy, and also as an event role, he can do anything. leadership is fine too
	idtype = null //none
	faction_group = FACTION_MARINE //purely for IFF. technically he *is* the doom marine though

/datum/equipment_preset/fun/doomguy/load_name(mob/living/carbon/human/H, var/randomise)
	H.gender = MALE
	H.change_real_name(H, "Unknown")
	H.f_style = "Shaved"
	H.h_style = "Crewcut"
	H.sdisabilities |= MUTE
	H.able_to_speak = FALSE
	H.age = null //he is... eternal
	H.r_hair = 143
	H.g_hair = 95
	H.b_hair = 55
	H.r_eyes = 15
	H.g_eyes = 15
	H.b_eyes = 15

/datum/equipment_preset/fun/doomguy/load_gear(mob/living/carbon/human/H)
	//back
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/plasmagun(H), WEAR_BACK)
	//uniform
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/doomguy(H), WEAR_BODY)
	//limbs
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/doomguy(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/doomguy(H), WEAR_HANDS)
	//no headset. doomguy walks alone.
	//helmet
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/doomguy(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/doomplaceholder(H), WEAR_EYES)
	//armor
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/doomguy(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/double/doomguy(H), WEAR_J_STORE)
	//armor storage
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/plasmagun(H), WEAR_IN_JACKET)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/plasmagun(H), WEAR_IN_JACKET)
	//belt
	H.equip_to_slot_or_del(new /obj/item/storage/belt/shotgun/heavy(H), WEAR_WAIST)
	//pockets empty

	H.set_species("Human Hero") //Doomguy is STRONG.

	to_chat(H, SPAN_HIGHDANGER("You are *The* Doom Slayer. Rip and tear, until it is done. Unless an administrator tells you otherwise, you are to eviscerate the xenomorph menace, any Yautja and completely ignore the marine force."))
	to_chat(H, SPAN_HIGHDANGER("Despite being the Slayer, you are not invincible. Kill Xenomorphs, and once you're low on health or ammo, glory kill them via stabbing them with the Doomblade below 25% health to regain health and ammunition."))
	to_chat(H, SPAN_HIGHDANGER("Examine your gear to see what it does."))
