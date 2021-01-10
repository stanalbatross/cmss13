
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


/obj/item/clothing/under/marine/veteran/doomguy
	name = "turtleneck"
	desc = "Apparently the Doom Slayer wears a turtleneck. Who could have known?"
	icon_state = "syndicate"
	worn_state = "syndicate"
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_LOW
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
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HIGH
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
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HIGH
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
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HIGH
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
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_HIGH
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

/datum/action/item_action/quick_scan/New(var/mob/living/user, var/obj/item/holder)
	..()
	name = "Scan Health"
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

/obj/item/weapon/gun/rifle/plasmagun
	name = "plasma rifle"
	desc = "This high-tech, futuristic weapon fires highly concentrated balls of plasma rapidly, bypassing most armor and melting the target's insides."
	icon_state = "plasmagun"
	item_state = "plasmagun"
	reload_sound = 'sound/weapons/handling/gun_plasma_rifle_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_plasma_rifle_unload.ogg'
	fire_sound = 'sound/weapons/gun_plasmagun.ogg'
	fire_rattle	= 'sound/weapons/gun_plasmagun.ogg' //cuz otherwise the high pitch at low ammo breaks it
	vary_sound = FALSE //does not randomly change pitch
	flags_equip_slot = SLOT_BACK
	w_class = SIZE_LARGE
	force = 25
	current_mag = /obj/item/ammo_magazine/rifle/plasmagun
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_FULL_AUTO_ON|GUN_HAS_FULL_AUTO|GUN_WIELDED_FIRING_ONLY
	starting_attachment_types = list(/obj/item/attachable/plasmagunbarrel)
	gun_category = GUN_CATEGORY_RIFLE
	aim_slowdown = 0.5
	wield_delay = 0 //literally instant.
	indestructible = TRUE

/obj/item/weapon/gun/rifle/plasmagun/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("The plasma rifle deals decent consistent damage at range, but it has a slow projectile speed, low ammo, and can easily be outran. It will also instantly decloak Predators, and quickly break walls.")) //only true as long as proc bullet_hit of yautja_bracers.dm is unchanged
	to_chat(user, SPAN_NOTICE("Full-auto is the default fire type, but singlefire and burst have a rather increased effective ROF resulting in extreme damage if you can withstand the effort needed to use them, though they will quickly burn through ammunition."))

/obj/item/weapon/gun/rifle/plasmagun/unique_action(mob/user)
	return

/obj/item/weapon/gun/rifle/plasmagun/Initialize()
	. = ..()
	AddElement(/datum/element/magharness)

/obj/item/weapon/gun/rifle/plasmagun/harness_return(var/mob/living/carbon/human/user)
	if (!loc || !user)
		return
	if (!isturf(loc))
		return
	if (!harness_check(user))
		return
	user.equip_to_slot_if_possible(src, WEAR_BACK)
	if(user.back == src)
		to_chat(user, SPAN_WARNING("Dropping \the [src], its magnetic sling automatically snaps it to your back."))
	user.update_inv_s_store()

/obj/item/weapon/gun/rifle/plasmagun/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 6, "muzzle_y" = 0,"rail_x" = 0, "rail_y" = 0, "under_x" = 0, "under_y" = 0, "stock_x" = 0, "stock_y" = 0)

/obj/item/weapon/gun/rifle/plasmagun/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_10
	burst_amount = BURST_AMOUNT_TIER_7
	burst_delay = FIRE_DELAY_TIER_10
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7 //CANNOT be fired one handed.
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/ammo_magazine/rifle/plasmagun
	name = "plasma capacitor"
	desc = "A capacitor supercharged with battery, and plasma, or something like that."
	caliber = "doom"
	icon_state = "plasmagun"
	item_state = "generic_mag"
	w_class = SIZE_MEDIUM
	default_ammo = /datum/ammo/bullet/plasma
	max_rounds = 35
	gun_type = /obj/item/weapon/gun/rifle/plasmagun
	flags_magazine = null //so you can't grab plasma ball bullets from the magazine

/datum/ammo/bullet/plasma
	name = "plasma ball"
	icon_state = "pulse1"
	damage = BULLET_DAMAGE_TIER_9
	damage_type = BURN
	accurate_range = 9
	accuracy = HIT_ACCURACY_TIER_4
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = AMMO_SPEED_TIER_2
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	penetration = ARMOR_PENETRATION_TIER_5
	flags_ammo_behavior = AMMO_ENERGY

/obj/item/weapon/gun/shotgun/double/doomguy
	name = "\improper Super Shotgun"
	desc = "A relic from the Slayer's past, this shotgun packs an extremely powerful punch."
	icon_state = "doomgun"
	item_state = "doomgun"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/heavy
	fire_sound = 'sound/weapons/gun_supershotgun_shoot.ogg'
	fire_rattle = 'sound/weapons/gun_supershotgun_shoot.ogg' //ditto
	break_sound = 'sound/weapons/handling/gun_supershotgun_open.ogg'
	seal_sound = 'sound/weapons/handling/gun_supershotgun_close.ogg'
	reload_sound = 'sound/weapons/handling/gun_supershotgun_reload.ogg'
	vary_sound = FALSE //does not randomly change pitch
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	attachable_allowed = list()
	wield_delay = 0 //literally instant.
	indestructible = TRUE
	var/colony_gun = FALSE

/obj/item/weapon/gun/shotgun/double/doomguy/examine(mob/user)
	..()
	if(!colony_gun)
		to_chat(user, SPAN_NOTICE("The Super Shotgun is your primary weapon, dealing massive damage at close range. Fire two quick blasts or one burst then execute with the Doomblade for a powerful combo. Be careful of running out of ammo!"))

/obj/item/weapon/gun/shotgun/double/doomguy/Initialize()
	. = ..()
	if(!colony_gun)
		AddElement(/datum/element/magharness)

/obj/item/weapon/gun/shotgun/double/doomguy/set_gun_config_values()
	..()
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = FIRE_DELAY_TIER_9
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_2
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/double/doomguy/reload(mob/user, obj/item/ammo_magazine/magazine)
	//SICKENING.
	if(magazine.default_ammo == /datum/ammo/bullet/shotgun/heavy/slug)
		to_chat(user, SPAN_WARNING("What the hell are you DOING!?"))
		return
	..()

//colony gun version
/obj/item/weapon/gun/shotgun/double/doomguy/colony
	name = "super shotgun"
	desc = "This sleek double-barreled shotgun has an unique design that you've never seen before."
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double
	icon_state = "altdoomgun"
	item_state = "altdoomgun"
	wield_delay = WIELD_DELAY_NORMAL
	colony_gun = TRUE

/obj/item/weapon/gun/shotgun/double/doomguy/colony/set_gun_config_values()
	..()
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = FIRE_DELAY_TIER_9
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_6
	scatter = SCATTER_AMOUNT_TIER_2
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/double/doomguy/colony/reload(mob/user, obj/item/ammo_magazine/magazine)
	//SICKENING.
	if(magazine.default_ammo == /datum/ammo/bullet/shotgun/slug)
		to_chat(user, SPAN_WARNING("What the hell are you DOING!?"))
		return
	..()

/obj/item/weapon/doomblade
	name = "\improper Doomblade"
	icon_state = "doomblade"
	item_state = "doomblade"
	desc = "A huge, serrated edge blade mounted on your gloves. Incredibly sleek, incredibly deadly."
	w_class = SIZE_HUGE
	edge = TRUE
	sharp = IS_SHARP_ITEM_ACCURATE
	force = MELEE_FORCE_VERY_STRONG //it's mostly a finisher, should not be the primary
	flags_item = DELONDROP
	flags_equip_slot = NO_FLAGS
	hitsound = 'sound/weapons/wristblades_hit.ogg'
	attack_verb = list("ripped", "torn", "cut", "lacerated", "impaled", "carved", "perforated", "skewered")
	attack_speed = 6
	pry_capable = IS_PRY_CAPABLE_FORCE
	var/glory_killing = FALSE

/obj/item/weapon/doomblade/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("This blade deals decent damage, pries open airlocks and will glory kill on low-health enemies, granting you health and ammo, depending on the tier of the killed Xenomorph or the strength of the humanoid."))
	to_chat(user, SPAN_NOTICE("ABILITY MACRO: 'Specialist-Activation-One'"))

/obj/item/weapon/doomblade/dropped(mob/living/carbon/human/M)
	playsound(M,'sound/weapons/wristblades_off.ogg', 15, 1)
	..()

/obj/item/weapon/doomblade/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !user) 
		return

	if(istype(A, /obj/structure/machinery/door/airlock))
		var/obj/structure/machinery/door/airlock/D = A
		if(D.operating || !D.density) return
		to_chat(user, SPAN_NOTICE("You jam [src] into [D] and start ripping it open."))
		playsound(user,'sound/weapons/wristblades_hit.ogg', 15, 1)
		if(D.density && do_after(user,7.5, INTERRUPT_ALL, BUSY_ICON_HOSTILE, D))
			D.open(1)

//to future coders: i apologize
/obj/item/weapon/doomblade/attack(mob/target, mob/living/user)
	if(glory_killing) //cannot attack during a glory kill
		return
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
	else
		..()
	var/mob/living/carbon/staggered_mob = target
=======
<<<<<<< HEAD
=======
>>>>>>> Cleans things up and fixes rebase issues
	if(!isXeno(target))
		return
	var/mob/living/carbon/Xenomorph/X = target
>>>>>>> DOOM
=======
	var/mob/living/carbon/staggered_mob = target
>>>>>>> Updates
	var/mob/living/carbon/human/H = user

	if(user == target)
		return //no

	var/mob_threshold_increase = 0
<<<<<<< HEAD
<<<<<<< HEAD
	var/is_xeno = TRUE
	if(staggered_mob.mob_size <= MOB_SIZE_HUMAN)
		mob_threshold_increase = 50 //if they are a human, glory kill hp is -125, not 25%
		is_xeno = FALSE

	if(staggered_mob.health <= (staggered_mob.maxHealth * 0.25 - mob_threshold_increase) && staggered_mob.stat != DEAD)
		//if they are near crit, we begin a glory kill
		user.visible_message(SPAN_DANGER("[user] quickly pummels [staggered_mob.name] in the back of their head and staggers them!"), SPAN_DANGER("You quickly pummel [staggered_mob.name] in the back of their head with the back of your blade and stagger them!"))
		//stun the xeno so they can't do anything
		staggered_mob.apply_effect(8, WEAKEN)
		user.visible_message(SPAN_DANGER("[user] impales the limp [staggered_mob.name] and uses his blade to lift them from the ground..."), SPAN_DANGER("You impale the limp [staggered_mob.name] and use your blade to lift them from the ground..."))
=======
	var/is_xeno = FALSE
=======
	var/is_xeno = TRUE
>>>>>>> Fixes issues
	if(staggered_mob.mob_size < MOB_SIZE_XENO_SMALL)
		mob_threshold_increase = 50 //if they are a human, glory kill hp is -125, not 25%
		is_xeno = FALSE

	if(staggered_mob.health <= (staggered_mob.maxHealth * 0.25 - mob_threshold_increase) && staggered_mob.stat != DEAD)
		//if they are near crit, we begin a glory kill
		user.visible_message(SPAN_DANGER("[user] quickly pummels [staggered_mob.name] in the back of their head and staggers them!"), SPAN_DANGER("You quickly pummel [staggered_mob.name] in the back of its head with the back of your blade and stagger them!"))
		//stun the xeno so they can't do anything
<<<<<<< HEAD
		staggered_mob.apply_effect(4, WEAKEN)
		user.visible_message(SPAN_DANGER("[user] impales the limp the [staggered_mob.name] and uses his blade to lift it from the ground..."), SPAN_DANGER("You impale the limp the [staggered_mob.name] and use your blade to lift it from the ground..."))
>>>>>>> Updates
=======
		staggered_mob.apply_effect(8, WEAKEN)
		user.visible_message(SPAN_DANGER("[user] impales the limp [staggered_mob.name] and uses his blade to lift them from the ground..."), SPAN_DANGER("You impale the limp [staggered_mob.name] and use your blade to lift them from the ground..."))
>>>>>>> Fixes issues
		animate(staggered_mob, pixel_y = 5, time = 5, easing = SINE_EASING|EASE_OUT, loop = 0)
		//freeze and immunify the doomguy
		user.anchored = TRUE
		user.frozen = TRUE
		user.update_canmove()
		H.species.brute_mod = 0
		H.species.burn_mod = 0
		//freeze the xeno so they're not pulled away (not that it would do anything, as the do_after cannot be interrupted)
		staggered_mob.anchored = TRUE
		staggered_mob.frozen = TRUE
		staggered_mob.update_canmove()
		staggered_mob.updatehealth()
		//set glory kill to true, stopping you from being able to attack with the doomblade while glory killing.
		glory_killing = TRUE
		//to do: animate the xeno slowly moving up from the ground being lifted up
		//you buffoon, you dealt too much damage
		if(!do_after(user, 20, INTERRUPT_NONE, BUSY_ICON_HOSTILE, target) || staggered_mob.stat == DEAD)
			to_chat(user, SPAN_DANGER("They died already! Be more careful next time!"))
			//fix their status
			user.anchored = FALSE
			user.frozen = FALSE
			user.update_canmove()
			H.species.brute_mod = initial(H.species.brute_mod)
			H.species.burn_mod = initial(H.species.burn_mod)
			glory_killing = FALSE
			return
		//ideally these wouldn't be size checks but you know how it is
		if(is_xeno)
			xeno_glorykill(user, staggered_mob)
		else
			humanoid_glorykill(user, staggered_mob)
<<<<<<< HEAD
<<<<<<< HEAD
=======
		//give the people a little time to take in what just happened and read the glory kill text
		addtimer(CALLBACK(staggered_mob, /mob.proc/gib), 3 SECONDS)
>>>>>>> Updates
=======
>>>>>>> Fixes issues

/obj/item/weapon/doomblade/proc/xeno_glorykill(mob/living/user, mob/living/carbon/staggered_mob)
	var/mob/living/carbon/Xenomorph/X = staggered_mob
	var/heal_amount = (X.tier * 40)
<<<<<<< HEAD
<<<<<<< HEAD
	var/xeno_tier = (X.tier) //turns into ammo refill, is used for time to finish glorykill, can't be direct as some xenos have dumb tiers
=======
	var/ammo_refill = (X.tier)
>>>>>>> Updates
=======
	var/xeno_tier = (X.tier) //turns into ammo refill, is used for time to finish glorykill, can't be direct as some xenos have dumb tiers
>>>>>>> Fixes issues
	switch(X.caste_name) //caste and unique glory kill text
		//this will never happen
		if("Bloody Larva")
			user.visible_message(SPAN_HIGHDANGER("[user] crushes the [X.name] into a fine green mist!"), SPAN_HIGHDANGER("You crush the [X.name] into a fine green mist!"))
			heal_amount = 10 //they're t0
		//T1
		if("Drone")
			user.visible_message(SPAN_HIGHDANGER("[user] pulls out the blade from the [X.name]'s body and sweeps it across its neck, decapitating it!"), SPAN_HIGHDANGER("[user] pulls out the blade from the [X.name]'s body and sweeps it across its neck, decapitating it!"))

		if("Runner")
			user.visible_message(SPAN_HIGHDANGER("[user] grabs the [X.name]'s head and slowly tears it away from the body!"), SPAN_HIGHDANGER("You grab the [X.name]'s head and slowly tear it away from the body!"))

		if("Sentinel")
			user.visible_message(SPAN_HIGHDANGER("[user] pulls out the blade from the [X.name]'s body and smashes it through its body, tearing it in half!"), SPAN_HIGHDANGER("You pull out the blade from the [X.name]'s body and smash it through its body, tearing it in half!"))

		if("Defender")
			user.visible_message(SPAN_HIGHDANGER("[user] grabs the [X.name]'s head by the crest and slams it down into his knee, pulverizing it!"), SPAN_HIGHDANGER("You grab the [X.name]'s head by the crest and slam it down into your knee, pulverizing it!"))

		//T2
		if("Hivelord")
			user.visible_message(SPAN_HIGHDANGER("[user] rips the dorsal spines off the [X.name] and jabs them into its head!"), SPAN_HIGHDANGER("You rip the dorsal spines off the [X.name] and jab them into its head!"))

		if("Burrower")
			user.visible_message(SPAN_HIGHDANGER("[user] rapidly jabs the [X.name] several times in the chest, pressurized acid blood spurting out of the holes!"), SPAN_HIGHDANGER("You rapidly jab the [X.name] several times in the chest, pressurized acid blood spurting out of the holes!"))

		if("Carrier")
			user.visible_message(SPAN_HIGHDANGER("[user] slices into the abdomen of the [X.name], weird alien organs spilling out!"), SPAN_HIGHDANGER("You slice into the abdomen of the [X.name], weird alien organs spilling out!"))

		if("Lurker")
			user.visible_message(SPAN_HIGHDANGER("[user] slices the tail off the [X.name] and caves in its head with the tip!"), SPAN_HIGHDANGER("[user] slices the tail off the [X.name] and caves in its head with the tip!"))

		if("Spitter")
			user.visible_message(SPAN_HIGHDANGER("[user] slashes the acid glands off the [X.name], acid and acid blood spurting out the holes, before impaling its head!"), SPAN_HIGHDANGER("You slash the acid glands off the [X.name], acid and acid blood spurting out the holes, before impaling its head!"))

		if("Warrior")
			user.visible_message(SPAN_HIGHDANGER("[user] directs a fist into the [X.name]'s face, it attempts to block [user]'s fist, but instead [user] extends the Doomblade, impaling it into its crest!"), SPAN_HIGHDANGER("[user] directs a fist into the [X.name]'s face, it attempts to block your fist, but instead you extend the Doomblade, impaling it into its crest!")) //https://youtu.be/NarIBADkVRU?t=28

		//T3
		if("Boiler")
			user.visible_message(SPAN_HIGHDANGER("[user] slices open the [X.name]'s crest gland, gas spilling out, before dealing a tremendous punch to its head!"), SPAN_HIGHDANGER("You slice open the [X.name]'s crest gland, gas spilling out, before dealing a tremendous punch to its head!"))

		if("Ravager")
			user.visible_message(SPAN_HIGHDANGER("[user] slices the claws off the [X.name] and impales them in its eyes!"), SPAN_HIGHDANGER("You slice the claws off the [X.name] and impale them in its eyes!"))

		if("Praetorian")
			user.visible_message(SPAN_HIGHDANGER("[user] consecutively slices the legs off the [X.name], then smashes the Doomblade down into its head!"), SPAN_HIGHDANGER("You consecutively slice the legs off the [X.name], then smash the Doomblade down into its head!"))

		if("Crusher")
			user.visible_message(SPAN_HIGHDANGER("[user] places his clenched fist on the [X.name]'s massive crest for a second, then suddenly extends the Doomblade, piercing through the exkoseleton!"), SPAN_HIGHDANGER("You place your clenched fist on the [X.name]'s massive crest for a second, then suddenly extend the Doomblade, piercing through the exkoseleton!"))

		//Special
		if("Predalien")
			user.visible_message(SPAN_HIGHDANGER("the [X.name] roars in [user]'s face, then [user] cleanly slashes through the [X.name]'s neck, grabbing the dismembered head and crushing it!"), SPAN_HIGHDANGER("the [X.name] roars in your face, and you proceed to cleanly slash through the [X.name]'s neck, grabbing the dismembered head and crushing it!"))
			X.emote("roar")
			heal_amount = 160 //they're t1
<<<<<<< HEAD
<<<<<<< HEAD
			xeno_tier = 3
=======
			ammo_refill = 3
>>>>>>> Updates
=======
			xeno_tier = 3
>>>>>>> Fixes issues

		if("Queen")
			user.visible_message(SPAN_HIGHDANGER("the [X.name] roars in [user]'s face, and he quickly pulls out the equipment launcher and fires a fragmentation grenade right into the [X.name]'s mouth"), SPAN_HIGHDANGER("the [X.name] roars in your's face, and you quickly pull out the equipment launcher and fire a fragmentation grenade right into the [X.name]'s mouth!"))
			X.emote("roar")
			heal_amount = 200 //they're t0
<<<<<<< HEAD
<<<<<<< HEAD
			xeno_tier = 3
=======
			ammo_refill = 3
>>>>>>> Updates
=======
			xeno_tier = 3
>>>>>>> Fixes issues
		//just in case
		else
			user.visible_message(SPAN_HIGHDANGER("[user] painfully forces the Doomblade through the [X.name]'s head!"), SPAN_HIGHDANGER("You painfully force the Doomblade through the [X.name]'s head!"))
			heal_amount = 80
<<<<<<< HEAD
<<<<<<< HEAD
			xeno_tier = 2

	X.apply_damage(X.health, BRUTE)
	//give the people a little time to take in what just happened and read the glory kill text
	addtimer(CALLBACK(staggered_mob, /mob.proc/gib), xeno_tier SECONDS)

	addtimer(CALLBACK(src, .proc/finish_glorykill, user, heal_amount, xeno_tier), (xeno_tier*2) SECONDS)
=======
			ammo_refill = 2

	X.apply_damage(X.health, BRUTE)
	addtimer(CALLBACK(src, .proc/finish_glorykill, user, heal_amount, ammo_refill), 5.5 SECONDS)
>>>>>>> Updates
=======
			xeno_tier = 2

	X.apply_damage(X.health, BRUTE)
	//give the people a little time to take in what just happened and read the glory kill text
	addtimer(CALLBACK(staggered_mob, /mob.proc/gib), xeno_tier SECONDS)

	addtimer(CALLBACK(src, .proc/finish_glorykill, user, heal_amount, xeno_tier), (xeno_tier*2) SECONDS)
>>>>>>> Fixes issues

/obj/item/weapon/doomblade/proc/humanoid_glorykill(mob/living/user, mob/living/carbon/staggered_mob)

	var/mob/living/carbon/human/H = staggered_mob
	var/heal_amount = 40
	var/ammo_refill = 1

	if(H.species.flags & IS_SYNTHETIC)
		user.visible_message(SPAN_HIGHDANGER("[user] slices his Doomblade out of [H.name] and cleanly amputates its head!"), SPAN_HIGHDANGER("You slice the Doomblade out of [H.name] and cleanly amputate its head!"))
		//let's make use of the funny synth behead, why not?
		heal_amount = 120
		ammo_refill = 2
		var/obj/limb/O = H.get_limb(check_zone("head"))
		O.droplimb(TRUE, FALSE, "doom")

	else if(H.species.flags & IS_YAUTJA)
<<<<<<< HEAD
<<<<<<< HEAD
		user.visible_message(SPAN_HIGHDANGER("[H.name] roars, and [user] stabs him twice in the chest, then slams the Doomblade into [H.name]'s forehead!"), SPAN_HIGHDANGER("[H.name] roars, and you stab him twice in the chest, then slam the Doomblade into [H.name]'s forehead!"))
=======
		user.visible_message(SPAN_HIGHDANGER("[H.name] roars, and [user] stabs him twice in the chest, then slams the Doomblade into [H.name]'s forehead!"), SPAN_HIGHDANGER("[H.name] roars, and You stab him twice in the chest, then slam the Doomblade into [H.name]'s forehead!"))
>>>>>>> Updates
=======
		user.visible_message(SPAN_HIGHDANGER("[H.name] roars, and [user] stabs him twice in the chest, then slams the Doomblade into [H.name]'s forehead!"), SPAN_HIGHDANGER("[H.name] roars, and you stab him twice in the chest, then slam the Doomblade into [H.name]'s forehead!"))
>>>>>>> Fixes issues
		H.emote("roar")
		heal_amount = 200
		ammo_refill = 3

	else //we're assuming they're a human then
		user.visible_message(SPAN_HIGHDANGER("[user] slams the Doomblade into [H.name]'s mouth and quickly slides it out!"), SPAN_HIGHDANGER("You slam the Doomblade into [H.name]'s mouth and quickly slide it out!"))

<<<<<<< HEAD
<<<<<<< HEAD
	addtimer(CALLBACK(staggered_mob, /mob.proc/gib), 1.5 SECONDS)

	addtimer(CALLBACK(src, .proc/finish_glorykill, user, heal_amount, ammo_refill), 3.5 SECONDS)
=======
	addtimer(CALLBACK(src, .proc/finish_glorykill, user, heal_amount, ammo_refill), 5.5 SECONDS)
>>>>>>> Updates
=======
	addtimer(CALLBACK(staggered_mob, /mob.proc/gib), 1.5 SECONDS)

	addtimer(CALLBACK(src, .proc/finish_glorykill, user, heal_amount, ammo_refill), 3.5 SECONDS)
>>>>>>> Fixes issues

/obj/item/weapon/doomblade/proc/finish_glorykill(mob/living/user, var/heal_amount, var/ammo_refill)

	var/mob/living/carbon/human/H = user
	//heal as a reward for glory killing
	user.heal_overall_damage(heal_amount, heal_amount/2, TRUE) //heals less burn
<<<<<<< HEAD
	user.visible_message(SPAN_BOLDNOTICE("[user] strange suit's runes glow eerily as you notice his wounds knitting themselves shut."), SPAN_BOLDNOTICE("Your Praetor suit's runes glow eerily as you feel a soothing sensation cover your whole body, your wounds knitting themselves shut."))
=======
	user.visible_message(SPAN_BOLDNOTICE("[user] strange suit's runes glow eerily as you notice his wounds knitting themselves shut."), SPAN_BOLDNOTICE("Your Praetor suit's runes glow eerily as you feel a soothing sensation cover your whole body, your wounds knitting themselves and bones repairing their integrity."))
>>>>>>> Updates
	//un-freeze them
	user.anchored = FALSE
	user.frozen = FALSE
	user.update_canmove()
	//so he doesn't inmediately die if he glory kills and gets ganged on inmediately
<<<<<<< HEAD
<<<<<<< HEAD
	addtimer(CALLBACK(src, .proc/end_immunity, H), 3 SECONDS)
=======
	addtimer(CALLBACK(src, .proc/end_immunity, H), 2 SECONDS)
>>>>>>> Updates
=======
	addtimer(CALLBACK(src, .proc/end_immunity, H), 3 SECONDS)
>>>>>>> Fixes issues
	//allow attacking again
	glory_killing = FALSE

	while(ammo_refill--)
		to_chat(user, SPAN_BOLDNOTICE("Your suit feels heavier, the glory kill resupplying your equipment!"))
		for(var/i in 1 to 2)
			var/obj/item/ammo_magazine/handful/handful = new(src)
			handful.generate_handful(/datum/ammo/bullet/shotgun/heavy/buckshot, "8g", 4, 4, /obj/item/weapon/gun/shotgun)
			H.equip_to_slot_or_del(handful, WEAR_IN_BELT)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/plasmagun(H), WEAR_IN_JACKET)

/obj/item/weapon/doomblade/proc/end_immunity(mob/living/carbon/human/H)
	H.species.brute_mod = initial(H.species.brute_mod)
	H.species.burn_mod = initial(H.species.burn_mod)
<<<<<<< HEAD
<<<<<<< HEAD
	to_chat(H, SPAN_BOLDNOTICE("Your immunity to damage has expired."))
=======
>>>>>>> Updates
=======
	to_chat(H, SPAN_BOLDNOTICE("Your immunity to damage has expired."))
>>>>>>> Fixes issues

/obj/item/weapon/doomblade/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user))
		return

	dig_out_shrapnel(5, user)

/obj/item/weapon/doomblade/dropped(mob/living/carbon/human/user)
	playsound(user.loc,'sound/weapons/wristblades_off.ogg', 15, 1)
	..()

/datum/action/item_action/specialist/doomguy_extend_doomblade
	ability_primacy = SPEC_PRIMARY_ACTION_1

/datum/action/item_action/specialist/doomguy_extend_doomblade/New(var/mob/living/user, var/obj/item/holder)
	..()
	name = "Toggle Doomblade"
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "doomblade")
	button.overlays += IMG

/datum/action/item_action/specialist/doomguy_extend_doomblade/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(istype(H) && !H.is_mob_incapacitated() && !H.lying && holder_item == H.wear_suit)
		return TRUE

/datum/action/item_action/specialist/doomguy_extend_doomblade/action_activate()
	if(!usr.loc || !usr.canmove || usr.stat)
		return
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	var/obj/item/weapon/doomblade/active_blade = user.get_active_hand()
	var/obj/item/weapon/doomblade/inactive_blade = user.get_inactive_hand()

	if(inactive_blade && istype(inactive_blade)) //Swap doomblade hands
		to_chat(user, SPAN_NOTICE("You retract your Doomblade in your other hand and extend it on the other."))
		//remove it
		playsound(user.loc,'sound/weapons/wristblades_off.ogg', 15, 1)
		qdel(inactive_blade)
		//add it
		var/obj/item/weapon/doomblade/N = new()
		user.put_in_active_hand(N)
		to_chat(user, SPAN_NOTICE("You activate your Doomblade!"))
		playsound(user,'sound/weapons/wristblades_on.ogg', 15, 1)
		return

	if(active_blade && istype(active_blade)) //Turn it off.
		to_chat(user, SPAN_NOTICE("You retract your Doomblade."))
		playsound(user.loc,'sound/weapons/wristblades_off.ogg', 15, 1)
		qdel(active_blade)
		return

	if(active_blade)
		to_chat(user, SPAN_WARNING("Your hand must be free to activate your Doomblade!"))
		return

	var/obj/limb/hand = user.get_limb(user.hand ? "l_hand" : "r_hand")
	if(!istype(hand) || !hand.is_usable())
		to_chat(user, SPAN_WARNING("You can't hold that!"))
		return
	
	var/obj/item/weapon/doomblade/N = new()
	user.put_in_active_hand(N)
	to_chat(user, SPAN_NOTICE("You activate your Doomblade!"))
	playsound(user,'sound/weapons/wristblades_on.ogg', 15, 1)

	return

/obj/item/explosive/grenade/cryogenic
	name = "cryogenic grenade"
	desc = "A strange grenade you've never seen before. Freezes enemies, slowing them and making them brittle."
	icon_state = "cryogrenade"
	det_time = 20
	item_state = "grenade_ex"
	underslug_launchable = FALSE
	var/datum/effect_system/smoke_spread/cryo/cryosmoke
	dangerous = 1
	harmful = TRUE

/obj/item/explosive/grenade/cryogenic/New()
	..()
	cryosmoke = new /datum/effect_system/smoke_spread/cryo
	cryosmoke.attach(src)

/obj/item/explosive/grenade/cryogenic/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	cryosmoke.set_up(3, 0, get_turf(src))
	cryosmoke.start()
	qdel(src)

/obj/item/weapon/gun/equipment_launcher
	name = "equipment launcher"
	desc = "A strange weapon, with eerily glowing runes. Activate it to swap between freezing or explosive grenades."
	icon_state = "doomlauncher_cryo"
	item_state = "doomlauncher"
	w_class = SIZE_LARGE
	fire_sound = 'sound/weapons/armbomb.ogg'
	cocked_sound = 'sound/weapons/gun_m92_cocked.ogg'
	flags_item = NOBLUDGEON|DELONDROP //Can't bludgeon with this.
	flags_gun_features = null
	ammo = /datum/ammo/grenade_container/cryogenic
	fire_delay = FIRE_DELAY_TIER_7
	var/mode = "cryogenic"
	var/obj/item/clothing/suit/storage/marine/veteran/doomguy/doom_armor = null

/obj/item/weapon/gun/equipment_launcher/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("Can be toggled via activating in-hand to switch between cryogenic and fragmentation grenades."))
	to_chat(user, SPAN_NOTICE("ABILITY MACRO: 'Specialist-Activation-Two'"))

/obj/item/weapon/gun/equipment_launcher/able_to_fire(mob/living/user)
	. = ..()
	var/obj/item/clothing/suit/storage/marine/veteran/doomguy/holder_item = doom_armor
	if(. && istype(user)) //Let's check all that other stuff first.
		if(mode == "cryogenic")
			if(holder_item.last_cryo_nade + holder_item.nade_cooldown > world.time)
				to_chat(user, SPAN_WARNING("You can't fire another cryogenic grenade so soon!"))
				return FALSE
			else
				holder_item.last_cryo_nade = world.time
				addtimer(CALLBACK(holder_item, /obj/item/clothing/suit/storage/marine/veteran/doomguy/proc/grenade_reloaded, user, mode), holder_item.nade_cooldown)
				return TRUE

		else if(mode == "fragmentation")
			if(holder_item.last_frag_nade + holder_item.nade_cooldown > world.time)
				to_chat(user, SPAN_WARNING("You can't fire another fragmentation grenade so soon!"))
				return FALSE
			else
				holder_item.last_frag_nade = world.time
				addtimer(CALLBACK(holder_item, /obj/item/clothing/suit/storage/marine/veteran/doomguy/proc/grenade_reloaded, user, mode), holder_item.nade_cooldown)
				return TRUE

/obj/item/weapon/gun/equipment_launcher/load_into_chamber()
	in_chamber = create_bullet(ammo, initial(name))
	return in_chamber

/obj/item/weapon/gun/equipment_launcher/reload_into_chamber()
	return TRUE

/obj/item/weapon/gun/equipment_launcher/attack_self(mob/living/user)
	switch(mode)
		if("cryogenic")
			//SET TO FRAG
			mode = "fragmentation"
			icon_state = "doomlauncher_frag"
			fire_sound = 'sound/weapons/armbomb.ogg'
			to_chat(user, SPAN_NOTICE("[src] is now set to fire fragmentation grenades."))
			ammo = ammo_list[/datum/ammo/grenade_container/stickfrag] //why are these brackets
			playsound(user,'sound/machines/click.ogg', 15, 1)

		if("fragmentation")
			//SET TO CRYO
			mode = "cryogenic"
			icon_state = "doomlauncher_cryo"
			fire_sound = 'sound/weapons/armbomb.ogg'
			to_chat(user, SPAN_NOTICE("[src] is now set to fire cryogenic grenades."))
			ammo = ammo_list[/datum/ammo/grenade_container/cryogenic]
			playsound(user,'sound/machines/click.ogg', 15, 1)

/datum/action/item_action/specialist/doomguy_extend_equipment_launcher
	ability_primacy = SPEC_PRIMARY_ACTION_2

/datum/action/item_action/specialist/doomguy_extend_equipment_launcher/New(var/mob/living/user, var/obj/item/holder)
	..()
	name = "Toggle Equipment Launcher"
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "equipment_launcher")
	button.overlays += IMG

/datum/action/item_action/specialist/doomguy_extend_equipment_launcher/action_activate()
	if(!usr.loc || !usr.canmove || usr.stat)
		return
	var/mob/living/carbon/human/M = usr
	if(!istype(M))
		return
	var/obj/item/clothing/suit/storage/marine/veteran/doomguy/doom_armor = holder_item
	var/obj/item/weapon/gun/equipment_launcher/R = usr.r_hand
	var/obj/item/weapon/gun/equipment_launcher/L = usr.l_hand
	if(!istype(R) && !istype(L))
		doom_armor.equipment_launcher_active = FALSE
	if(doom_armor.equipment_launcher_active) //Turn it off.
		var/found = FALSE
		if(R && istype(R))
			found = TRUE
			usr.r_hand = null
			if(R)
				M.temp_drop_inv_item(R)
				R.dropped(M)
			M.update_inv_r_hand()
		if(L && istype(L))
			found = TRUE
			usr.l_hand = null
			if(L)
				M.temp_drop_inv_item(L)
				L.dropped(M)
			M.update_inv_l_hand()
		if(found)
			to_chat(usr, SPAN_NOTICE("You deactivate your equipment launcher."))
			doom_armor.equipment_launcher_active = FALSE
		return
	else //Turn it on!
		if(usr.get_active_hand())
			to_chat(usr, SPAN_WARNING("Your hand must be free to activate your equipment launcher!"))
			return

		var/obj/item/weapon/gun/equipment_launcher/E
		if(!istype(E))
			E = new(usr)
		usr.put_in_active_hand(E)
		E.doom_armor = holder_item
		doom_armor.equipment_launcher_active = TRUE
		to_chat(usr, SPAN_NOTICE("You activate your equipment launcher."))
	return 1
