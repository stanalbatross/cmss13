/obj/item/clothing/under/marine/veteran/doomguy
	name = "turtleneck"
	desc = "Apparently the Doom Slayer wears a turtleneck. Who could have known?"
	icon_state = "syndicate"
	worn_state = "syndicate"
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_NONE
	armor_rad = CLOTHING_ARMOR_NONE
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	suit_restricted = list(/obj/item/clothing/suit/storage/marine/veteran/doomguy)
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_ARMS|BODY_FLAG_FEET|BODY_FLAG_HANDS
	flags_item = NODROP

/obj/item/clothing/gloves/marine/veteran/doomguy
	name = "reinforced gloves"
	desc = "These gloves seem to be made out of studded leather, but they're extremely hard to the touch. The fingertips seem to have a faint red tint..." //its blood
	icon_state = "doomgloves"
	item_state = "doomgloves"
	siemens_coefficient = 0
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HARDCORE
	armor_bomb = CLOTHING_ARMOR_HARDCORE
	armor_bio = CLOTHING_ARMOR_VERYHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HARDCORE

/obj/item/clothing/gloves/marine/veteran/doomguy/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("Press the blade button at your top-left to toggle the Doomblade."))

/obj/item/clothing/shoes/veteran/doomguy
	name = "reinforced boots"
	desc = "These boots seem to be made out of studded leather, but they're extremely hard to the touch. The bottom seems to have a faint red tint..." //its blood
	icon_state = "doomboots"
	item_state = "doomboots"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HARDCORE
	armor_bomb = CLOTHING_ARMOR_HARDCORE
	armor_bio = CLOTHING_ARMOR_VERYHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HARDCORE
	flags_cold_protection = BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_FEET
	flags_inventory = NOSLIPPING|NOWEEDSLOW
	siemens_coefficient = 0

/obj/item/clothing/shoes/veteran/doomguy/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("These boots will allow you to pass through weeds unslowed."))

/obj/item/clothing/head/helmet/marine/veteran/doomguy
	name = "\improper Praetor helmet"
	desc = "A colossal, extremely durable-looking helmet. Features a Heads-Up-Display which displays vital data such as how many things you've slayed so far."
	icon_state = "doomhelmet"
	item_state = "doomhelmet"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HARDCORE
	armor_bomb = CLOTHING_ARMOR_HARDCORE
	armor_bio = CLOTHING_ARMOR_VERYHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HARDCORE
	flags_inventory = BLOCKSHARPOBJ
	flags_item = NODROP
	flags_inv_hide = NO_FLAGS
	flags_marine_helmet = NO_FLAGS
	anti_hug = 616

/obj/item/clothing/head/helmet/marine/veteran/doomguy/equipped(mob/living/carbon/human/user, slot)
	//i have to do this because huds can't be bitflags normally, so you can't add more than 1 hudtype to glasses
	if(slot == WEAR_HEAD)
		var/datum/mob_hud/HUD = huds[MOB_HUD_MEDICAL_OBSERVER]
		HUD.add_hud_to(user)
		HUD = huds[MOB_HUD_XENO_STATUS]
		HUD.add_hud_to(user)
		//uncomment this once someone fixes update_sight() fucking processing glasses to look for sight flags
		//user.sight |= SEE_MOBS
	..()

/obj/item/clothing/head/helmet/marine/veteran/doomguy/dropped(mob/living/carbon/human/user)
	if(istype(user)) //inventory reference is only cleared after dropped().
		var/datum/mob_hud/HUD = huds[MOB_HUD_MEDICAL_OBSERVER]
		HUD.remove_hud_from(user)
		HUD = huds[MOB_HUD_XENO_STATUS]
		HUD.remove_hud_from(user)
		//user.sight &= SEE_MOBS
	..()

/obj/item/clothing/head/helmet/marine/veteran/doomguy/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("You have slayed [user.life_kills_total] enemies so far."))

//remove this once someone fixes update_sight() fucking processing glasses to look for sight flags
/obj/item/clothing/glasses/thermal/doomplaceholder
	name = "Praetor HUD"
	desc = "The Praetor Helmet's popup HUD."
	icon_state = "thermalimplants"
	item_state = "BLANK"
	toggleable = FALSE
	eye_protection = 2
	fullscreen_vision = null
	flags_item = NODROP|DELONDROP

/obj/item/clothing/glasses/thermal/doomplaceholder/emp_act(severity)
	return

/obj/item/clothing/suit/storage/marine/veteran/doomguy
	name = "\improper Praetor suit"
	desc = "A colossal, extremely durable-looking piece of probably metal. Unrelated to actual Praetorians."
	icon_state = "doomsuit"
	item_state = "doomsuit"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HARDCORE
	armor_bomb = CLOTHING_ARMOR_HARDCORE
	armor_bio = CLOTHING_ARMOR_VERYHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HARDCORE
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_NONE
	flags_inventory = BLOCK_KNOCKDOWN
	flags_item = NODROP
	allowed = list(/obj/item/weapon/gun/shotgun/double/doomguy)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/doomguy)
	time_to_unequip = 0 //stops it from being unequipped, we do not want doomguy to take off his suit
	var/equipment_launcher_active
	var/last_cryo_nade = 1
	var/last_frag_nade = 1
	var/nade_cooldown = 20 SECONDS
	actions_types = list(
	 					 /datum/action/item_action/specialist/doomguy_extend_doomblade,
						 /datum/action/item_action/specialist/doomguy_extend_equipment_launcher,
						 /datum/action/item_action/quick_scan)

/obj/item/clothing/suit/storage/marine/veteran/doomguy/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("You have three unique actions: Doomblade, Equipment Launcher, and Scan Health."))
	to_chat(user, SPAN_NOTICE("Toggle Doomblade will give you a blade that deals good damage and will glory kill on low-health enemies, granting you health and ammo. It can also force open airlocks."))
	to_chat(user, SPAN_NOTICE("Toggle Equipment Launcher will extend a launcher than you can press inhand to switch between throwing a cryogenic grenade that slows enemies down, or a fragmentation grenade. They both have separate 30-second cooldowns."))
	to_chat(user, SPAN_NOTICE("Scan Health will instantly give you a readout of your current health."))

/obj/item/clothing/suit/storage/marine/veteran/doomguy/proc/grenade_reloaded(mob/living/user, var/mode)
	to_chat(user, SPAN_WARNING("Your suit informs you that your [mode] grenade has been recharged!"))
	playsound(user, 'sound/effects/refill.ogg', 25, 1, 3)

/datum/action/item_action/quick_scan
	name = "Scan Health"

/datum/action/item_action/quick_scan/New(var/mob/living/user, var/obj/item/holder)
	..()
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "health_ability")
	button.overlays += IMG

//ideally this would be a component, but i am not going to do that
/datum/action/item_action/quick_scan/update_button_icon()
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "health_ability")
	button.overlays += IMG

/datum/action/item_action/quick_scan/can_use_action()
	return TRUE

/datum/action/item_action/quick_scan/action_activate()
	var/mob/living/carbon/human/H = owner
	H.health_scan(H, TRUE, 1, 1)
