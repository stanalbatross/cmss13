
#define MODE_OFF 0
#define MODE_NVG 1
#define MODE_THERMALS 2
#define MODE_MESONS 3

/obj/item/clothing/mask/gas/yautja
	name = "clan mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."
	icon = 'icons/obj/items/clothing/masks.dmi'
	icon_state = "pred_mask1"
	item_state = "helmet"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	min_cold_protection_temperature = SPACE_HELMET_min_cold_protection_temperature
	flags_armor_protection = BODY_FLAG_HEAD|BODY_FLAG_FACE|BODY_FLAG_EYES
	flags_cold_protection = BODY_FLAG_HEAD
	flags_inventory = COVEREYES|COVERMOUTH|NOPRESSUREDMAGE|ALLOWINTERNALS|ALLOWREBREATH|BLOCKGASEFFECT|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDELOWHAIR
	flags_item = ITEM_PREDATOR
	filtered_gases = list("phoron", "sleeping_agent", "carbon_dioxide")
	gas_filter_strength = 3
	eye_protection = 2
	vision_impair = VISION_IMPAIR_NONE
	unacidable = TRUE
	anti_hug = 100
	item_state_slots = list(WEAR_FACE = "pred_mask1")
	time_to_unequip = 20
	unequip_sounds = list('sound/items/air_release.ogg')
	var/current_vision_mode = 0 //0: OFF. 1: NVG. 2: Thermals. 3: Mesons

/obj/item/clothing/mask/gas/yautja/New(location, mask_number = rand(1,12), elder_restricted = 0)
	..()
	forceMove(location)

	var/mask_input[] = list(1,2,3,4,5,6,7,8,9,10,11,12)
	if(mask_number in mask_input)
		icon_state = "pred_mask[mask_number]"
		item_state_slots = list(WEAR_FACE = "pred_mask[mask_number]")
	if(elder_restricted) //Not possible for non-elders.
		switch(mask_number)
			if(1341)
				name = "\improper 'Mask of the Dragon'"
				icon_state = "pred_mask_elder_tr"
				item_state_slots = list(WEAR_FACE = "pred_mask_elder_tr")
			if(7128)
				name = "\improper 'Mask of the Swamp Horror'"
				icon_state = "pred_mask_elder_joshuu"
				item_state_slots = list(WEAR_FACE = "pred_mask_elder_joshuu")
			if(4879)
				name = "\improper 'Mask of the Ambivalent Collector'"
				icon_state = "pred_mask_elder_n"
				item_state_slots = list(WEAR_FACE = "pred_mask_elder_n")

/obj/item/clothing/mask/gas/yautja/verb/toggle_zoom()
	set name = "Toggle Mask Zoom"
	set desc = "Toggle your mask's zoom function."
	set category = "Yautja"
	set src in usr
	if(!usr || usr.stat)
		return

	zoom(usr, 11, 12)

/obj/item/clothing/mask/gas/yautja/verb/togglesight()
	set name = "Toggle Mask Visors"
	set desc = "Toggle your mask visor sights. You must only be wearing a type of Yautja visor for this to work."
	set category = "Yautja"
	set src in usr
	if(!usr || usr.stat)
		return
	var/mob/living/carbon/human/M = usr
	if(!istype(M))
		return
	if(!HAS_TRAIT(M, TRAIT_YAUTJA_TECH))
		to_chat(M, SPAN_WARNING("You have no idea how to work these things!"))
		return
	toggle_add_sight(M)

/obj/item/clothing/mask/gas/yautja/proc/toggle_add_sight(var/mob/living/carbon/human/M)
	if(!(M.gloves && M.gloves.flags_item & ITEM_PREDATOR))
		to_chat(M, SPAN_WARNING("You must be wearing your bracers, as they have the power source."))
		return
	switch(current_vision_mode)
		if(MODE_OFF)
			current_vision_mode = MODE_NVG
			playsound(src,'sound/effects/pred_vision.ogg', 15, TRUE)
		if(MODE_NVG)
			current_vision_mode = MODE_THERMALS
			playsound(src,'sound/effects/pred_vision.ogg', 15, TRUE)
		if(MODE_THERMALS)
			current_vision_mode = MODE_MESONS
			playsound(src,'sound/effects/pred_vision.ogg', 15, TRUE)
		if(MODE_MESONS)
			current_vision_mode = MODE_OFF
			playsound(src,'sound/machines/click.ogg', 15, TRUE)
	add_vision(M)

/obj/item/clothing/mask/gas/yautja/proc/add_vision(mob/living/carbon/human/user)
	if(!(user.gloves && user.gloves.flags_item & ITEM_PREDATOR))
		to_chat(user, SPAN_WARNING("You must be wearing your bracers, as they have the power source."))
		return
	var/obj/item/G = user.glasses
	if(G && G.flags_item & ITEM_ABSTRACT)
		user.temp_drop_inv_item(G)
		qdel(G)
	else if(G)
		to_chat(user, SPAN_WARNING("You should probably take those glasses off."))
		return
	var/success
	switch(current_vision_mode)
		if(MODE_OFF)
			success = user.equip_to_slot_or_del(new /obj/item/clothing/glasses/yautja(user), WEAR_EYES)
		if(MODE_NVG)
			success = user.equip_to_slot_or_del(new /obj/item/clothing/glasses/yautja/nightvision(user), WEAR_EYES)
		if(MODE_THERMALS)
			success = user.equip_to_slot_or_del(new /obj/item/clothing/glasses/yautja/thermal(user), WEAR_EYES)
		if(MODE_MESONS)
			success = user.equip_to_slot_or_del(new /obj/item/clothing/glasses/yautja/meson(user), WEAR_EYES)
	if(!success)
		to_chat(user, SPAN_WARNING("Your mask beeps angrily, and nothing happens."))
		log_debug("Failed to apply [src] vision to [user]. Mode: [current_vision_mode]")
	user.update_inv_glasses()

/obj/item/clothing/glasses/yautja
	name = "bio-mask vision"
	desc = "A vision overlay generated by the Bio-Mask. This one isn't doing much."
	icon = 'icons/obj/items/weapons/predator.dmi'
	icon_state = "visor"
	flags_inventory = COVEREYES
	flags_item = NODROP|DELONDROP|ITEM_ABSTRACT
	fullscreen_vision = null

/obj/item/clothing/glasses/yautja/nightvision
	name = "bio-mask nightvision"
	desc = "A vision overlay generated by the Bio-Mask. Allows you to see in the dark!"
	icon = 'icons/obj/items/weapons/predator.dmi'
	icon_state = "visor_nvg"
	darkness_view = 7

obj/item/clothing/glasses/yautja/thermal
	name = "bio-mask thermalvision"
	desc = "A vision overlay generated by the Bio-Mask. Used to sense the heat of prey."
	icon = 'icons/obj/items/weapons/predator.dmi'
	icon_state = "visor_thermal"
	vision_flags = SEE_MOBS
	fullscreen_vision = /obj/screen/fullscreen/thermal

/obj/item/clothing/glasses/yautja/meson
	name = "bio-mask x-ray vision"
	desc = "A vision overlay generated by the Bio-Mask. Used to see through objects. Probably doesn't give your surroundings cancer."
	icon = 'icons/obj/items/weapons/predator.dmi'
	icon_state = "visor_meson"
	vision_flags = SEE_TURFS

#undef MODE_OFF
#undef MODE_NVG
#undef MODE_THERMALS
#undef MODE_MESONS

/obj/item/clothing/mask/gas/yautja/equipped(mob/living/carbon/human/user, slot)
	if(slot == WEAR_FACE)
		var/datum/mob_hud/H = huds[MOB_HUD_MEDICAL_OBSERVER]
		H.add_hud_to(user)
		H = huds[MOB_HUD_XENO_STATUS]
		H.add_hud_to(user)
		H = huds[MOB_HUD_HUNTER_CLAN]
		H.add_hud_to(user)
		H = huds[MOB_HUD_HUNTER]
		H.add_hud_to(user)
		add_vision(user)
		RegisterSignal(user, COMSIG_HUMAN_EXAMINED, .proc/handle_examine)
	..()

/obj/item/clothing/mask/gas/yautja/dropped(mob/living/carbon/human/user) //Clear the gogglors if the helmet is removed.
	if(istype(user) && user.wear_mask == src) //inventory reference is only cleared after dropped().
		var/obj/item/G = user.glasses
		if(G && G.flags_item & ITEM_ABSTRACT)
			user.temp_drop_inv_item(G)
			qdel(G)
			user.update_inv_glasses()
		var/datum/mob_hud/H = huds[MOB_HUD_MEDICAL_OBSERVER]
		H.remove_hud_from(user)
		H = huds[MOB_HUD_XENO_STATUS]
		H.remove_hud_from(user)
		H = huds[MOB_HUD_HUNTER_CLAN]
		H.remove_hud_from(user)
		H = huds[MOB_HUD_HUNTER]
		H.remove_hud_from(user)
		UnregisterSignal(user, COMSIG_HUMAN_EXAMINED, .proc/handle_examine)
	add_to_missing_pred_gear(src)
	..()

/obj/item/clothing/mask/gas/yautja/pickup(mob/living/user)
	if(isYautja(user))
		remove_from_missing_pred_gear(src)
	..()

/obj/item/clothing/mask/gas/yautja/Destroy()
	remove_from_missing_pred_gear(src)
	return ..()

/obj/item/clothing/mask/gas/yautja/proc/handle_examine(var/mob/living/carbon/human/user, var/mob/living/carbon/human/examined_H)

	if(HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		to_chat(user, SPAN_BLUE("[examined_H] has the scent of [examined_H.life_kills_total] defeated prey."))

		if(examined_H.hunter_data.hunted)
			to_chat(user, SPAN_ORANGE("[examined_H] is being hunted by [examined_H.hunter_data.hunter.real_name]."))

		if(examined_H.hunter_data.dishonored)
			to_chat(user, SPAN_RED("[examined_H] was marked as dishonorable for '[examined_H.hunter_data.dishonored_reason]'."))
		else if(examined_H.hunter_data.honored)
			to_chat(user, SPAN_GREEN("[examined_H] was honored for '[examined_H.hunter_data.honored_reason]'."))

		if(examined_H.hunter_data.thralled)
			to_chat(user, SPAN_GREEN("[examined_H] was thralled by [examined_H.hunter_data.thralled_set.real_name] for '[examined_H.hunter_data.thralled_reason]'."))
		else if(examined_H.hunter_data.gear)
			to_chat(user, SPAN_RED("[examined_H] was marked as carrying gear by [examined_H.hunter_data.gear_set]."))	

	else
		to_chat(user, SPAN_BLUE("A weird symbol shows up next to [examined_H]. It kind of looks like a [rand(examined_H.life_kills_total - 1, examined_H.life_kills_total + 1)]."))

//flavor, not a subtype
/obj/item/clothing/mask/yautja_flavor
	name = "stone clan mask"
	desc = "A beautifully designed face mask, ornate but non-functional and made entirely of stone."
	icon_state = "pred_mask1"
	item_state = "helmet"
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_NONE
	armor_rad = CLOTHING_ARMOR_NONE
	armor_internaldamage = CLOTHING_ARMOR_NONE
	flags_armor_protection = BODY_FLAG_HEAD|BODY_FLAG_FACE|BODY_FLAG_EYES
	flags_cold_protection = BODY_FLAG_HEAD
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDELOWHAIR
	flags_item = ITEM_PREDATOR
	unacidable = TRUE
	item_state_slots = list(WEAR_FACE = "pred_mask1")
	var/map_random = FALSE

/obj/item/clothing/mask/yautja_flavor/Initialize(mapload, ...)
	. = ..()
	if(mapload && !map_random)
		return

	var/list/possible_masks = list(1,2,3,4,5,6,7,8,9,10,11) //12
	var/mask_number = rand(1,11)
	if(mask_number in possible_masks)
		icon_state = "pred_mask[mask_number]"
		item_state_slots = list(WEAR_FACE = "pred_mask[mask_number]")

/obj/item/clothing/mask/yautja_flavor/map_random
	map_random = TRUE
