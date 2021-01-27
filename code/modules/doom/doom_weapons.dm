
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
	aim_slowdown = SLOWDOWN_ADS_VERSATILE
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
	flags_magazine = 0 //so you can't grab plasma ball bullets from the magazine

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
		to_chat(user, SPAN_NOTICE("The Super Shotgun is your primary weapon, dealing massive damage at close range. Fire two quick blasts then execute with the Doomblade for a powerful combo. Be careful of running out of ammo!"))

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
	var/list/glory_kill_messages = list(
	//t1
	XENO_CASTE_LARVA      = "DOOM_MARINE crushes the KILLED_XENOMORPH into a fine green mist!",
	XENO_CASTE_DRONE      = "DOOM_MARINE pulls out the blade from the KILLED_XENOMORPH's body and sweeps it across its neck, decapitating it!",
	XENO_CASTE_RUNNER     = "DOOM_MARINE grabs the KILLED_XENOMORPH's head and slowly tears it away from the body!",
	XENO_CASTE_SENTINEL   = "DOOM_MARINE pulls out the blade from the KILLED_XENOMORPH's body and smashes it through its body, tearing it in half!",
	XENO_CASTE_DEFENDER   = "DOOM_MARINE grabs the KILLED_XENOMORPH's head by the crest and slams it down into his knee, pulverizing it!",
	//t2
	XENO_CASTE_BURROWER   = "DOOM_MARINE rapidly jabs the KILLED_XENOMORPH several times in the chest, pressurized acid blood spurting out of the holes!",
	XENO_CASTE_CARRIER    = "DOOM_MARINE slices into the abdomen of the KILLED_XENOMORPH, weird alien organs spilling out!",
	XENO_CASTE_HIVELORD   = "DOOM_MARINE rips the dorsal spines off the KILLED_XENOMORPH and jabs them into its head!",
	XENO_CASTE_LURKER     = "DOOM_MARINE slices the tail off the KILLED_XENOMORPH and caves in its head with the tip!",
	XENO_CASTE_WARRIOR    = "DOOM_MARINE directs a fist into the KILLED_XENOMORPH's face, it attempts to block DOOM_MARINE's fist, but instead DOOM_MARINE extends the Doomblade, impaling it into its crest!",
	XENO_CASTE_SPITTER    = "DOOM_MARINE slashes the acid glands off the KILLED_XENOMORPH, acid and acid blood spurting out the holes, before impaling its head!",
	//t3
	XENO_CASTE_BOILER     = "DOOM_MARINE slices open the KILLED_XENOMORPH's crest gland, gas spilling out, before dealing a tremendous punch to its head!",
	XENO_CASTE_PRAETORIAN = "DOOM_MARINE consecutively slices the legs off the KILLED_XENOMORPH, then smashes the Doomblade down into its head!",
	XENO_CASTE_CRUSHER    = "DOOM_MARINE places his clenched fist on the KILLED_XENOMORPH's massive crest for a second, then suddenly extends the Doomblade, piercing through the exkoseleton!",
	XENO_CASTE_RAVAGER    = "DOOM_MARINE slices the blade claws off the KILLED_XENOMORPH and impales them in its eyes!",
	//special
	XENO_CASTE_QUEEN      = "The KILLED_XENOMORPH roars in DOOM_MARINE's face, and he quickly pulls out the equipment launcher and fires a fragmentation grenade right into the KILLED_XENOMORPH's mouth",
	XENO_CASTE_PREDALIEN  = "The KILLED_XENOMORPH roars in DOOM_MARINE's face, then DOOM_MARINE cleanly slashes through the KILLED_XENOMORPH's neck, grabbing the dismembered head and crushing it!"
	)
	//XENO_CASTE_FUTURE   = "DOOM_MARINE painfully forces the Doomblade through the KILLED_XENOMORPH's head!"

	var/list/special_glory_kills = list(XENO_CASTE_PREDALIEN, XENO_CASTE_QUEEN)

/obj/item/weapon/doomblade/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("This blade deals decent damage, pries open airlocks and will glory kill on low-health enemies, granting you health and ammo, depending on the tier of the killed Xenomorph or the strength of the humanoid."))
	to_chat(user, SPAN_NOTICE("ABILITY MACRO: 'Specialist-Activation-One'"))

/obj/item/weapon/doomblade/dropped(mob/living/carbon/human/M)
	if(glory_killing)
		return
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
		if(D.density && do_after(user, 1 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE, D))
			D.open(TRUE)

//to future coders: i apologize
/obj/item/weapon/doomblade/attack(mob/target, mob/living/user)
	if(glory_killing) //cannot attack during a glory kill
		return
	..()
	var/mob/living/carbon/staggered_mob = target

	if(user == target)
		return //no

	var/mob_threshold_increase = 0
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
		animate(staggered_mob, pixel_y = 5, time = 5, easing = SINE_EASING|EASE_OUT, loop = 0)
		//freeze and immunify the doomguy
		user.anchored = TRUE
		user.frozen = TRUE
		user.update_canmove()
		RegisterSignal(user, COMSIG_HUMAN_TAKE_DAMAGE, .proc/handle_damage)
		//freeze the xeno so they're not pulled away (not that it would do anything, as the do_after cannot be interrupted)
		staggered_mob.anchored = TRUE
		staggered_mob.frozen = TRUE
		staggered_mob.update_canmove()
		staggered_mob.updatehealth()
		//set glory kill to true, stopping you from being able to attack with the doomblade while glory killing.
		glory_killing = TRUE
		//you buffoon, you dealt too much damage
		if(!do_after(user, 20, INTERRUPT_NONE, BUSY_ICON_HOSTILE, target) || staggered_mob.stat == DEAD)
			to_chat(user, SPAN_DANGER("They died already! Be more careful next time!"))
			//fix their status
			user.anchored = FALSE
			user.frozen = FALSE
			user.update_canmove()
			UnregisterSignal(user, COMSIG_HUMAN_TAKE_DAMAGE)
			glory_killing = FALSE
			return
		//ideally these wouldn't be size checks but you know how it is
		if(is_xeno)
			xeno_glorykill(user, staggered_mob)
		else
			humanoid_glorykill(user, staggered_mob)
		//give the people a little time to take in what just happened and read the glory kill text
		addtimer(CALLBACK(staggered_mob, /mob.proc/gib), 3 SECONDS)

/obj/item/weapon/doomblade/proc/xeno_glorykill(mob/living/user, mob/living/carbon/staggered_mob)
	var/mob/living/carbon/Xenomorph/X = staggered_mob
	var/heal_amount = (X.tier * 40)
	var/xeno_tier = (X.tier) //turns into ammo refill, is used for time to finish glorykill, can't be direct as some xenos have dumb tiers
	var/raw_glory_kill_string = "[glory_kill_messages[X.caste_name]]"
	raw_glory_kill_string = replacetext(raw_glory_kill_string, "DOOM_MARINE", "[user]")
	raw_glory_kill_string = replacetext(raw_glory_kill_string, "KILLED_XENOMORPH", "[X.name]")
	var/final_glory_kill_string = raw_glory_kill_string
	user.visible_message(SPAN_HIGHDANGER("[final_glory_kill_string]"))

	if(X.caste_name in special_glory_kills)
		X.emote("roar")
		heal_amount = 200
		xeno_tier = 3

	var/list/resupply = list(heal_amount, xeno_tier)

	X.apply_damage(X.health, BRUTE)
	//give the people a little time to take in what just happened and read the glory kill text
	addtimer(CALLBACK(staggered_mob, /mob.proc/gib), (1 * xeno_tier) SECONDS)

	addtimer(CALLBACK(src, .proc/finish_glorykill, user, resupply), (2 * xeno_tier) SECONDS)

/obj/item/weapon/doomblade/proc/humanoid_glorykill(mob/living/user, mob/living/carbon/staggered_mob)

	var/mob/living/carbon/human/H = staggered_mob

	var/list/resupply = H.species.glory_kill(user, H)

	addtimer(CALLBACK(staggered_mob, /mob.proc/gib), 1.5 SECONDS)

	addtimer(CALLBACK(src, .proc/finish_glorykill, user, resupply), 3.5 SECONDS)

/obj/item/weapon/doomblade/proc/finish_glorykill(mob/living/user, resupply)

	var/mob/living/carbon/human/H = user

	var/heal_amount = resupply[1]
	var/ammo_refill = resupply[2]

	//heal as a reward for glory killing
	user.heal_overall_damage(heal_amount, heal_amount/2, TRUE) //heals less burn
	user.visible_message(SPAN_BOLDNOTICE("[user] strange suit's runes glow eerily as you notice his wounds knitting themselves shut."), SPAN_BOLDNOTICE("Your Praetor suit's runes glow eerily as you feel a soothing sensation cover your whole body, your wounds knitting themselves shut."))
	//un-freeze them
	user.anchored = FALSE
	user.unfreeze()
	//so he doesn't inmediately die if he glory kills and gets ganged on inmediately
	addtimer(CALLBACK(src, .proc/end_immunity, user), 2 SECONDS)
	//allow attacking again
	glory_killing = FALSE

	while(ammo_refill--)
		to_chat(user, SPAN_BOLDNOTICE("Your suit feels heavier, the glory kill resupplying your equipment!"))
		for(var/i in 1 to 2)
			var/obj/item/ammo_magazine/handful/handful = new(src)
			handful.generate_handful(/datum/ammo/bullet/shotgun/heavy/buckshot, "8g", 4, 4, /obj/item/weapon/gun/shotgun)
			H.equip_to_slot_or_del(handful, WEAR_IN_BELT)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/plasmagun(H), WEAR_IN_JACKET)

/obj/item/weapon/doomblade/proc/end_immunity(mob/living/user)
	UnregisterSignal(user, COMSIG_HUMAN_TAKE_DAMAGE)
	to_chat(user, SPAN_BOLDNOTICE("Your immunity to damage has expired."))

/obj/item/weapon/doomblade/proc/handle_damage(var/mob/user, var/datum/damage_value/dmg)
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_DAMAGE

/obj/item/weapon/doomblade/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user))
		return

	dig_out_shrapnel(0.5 SECONDS, user)

/obj/item/weapon/doomblade/dropped(mob/living/carbon/human/user)
	playsound(user.loc,'sound/weapons/wristblades_off.ogg', 15, 1)
	..()

/datum/action/item_action/specialist/doomguy_extend_doomblade
	ability_primacy = SPEC_PRIMARY_ACTION_1
	name = "Toggle Doomblade"

/datum/action/item_action/specialist/doomguy_extend_doomblade/New(var/mob/living/user, var/obj/item/holder)
	..()
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
	if(!.)
		return FALSE
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
			ammo = GLOB.ammo_list[/datum/ammo/grenade_container/stickfrag] //why are these brackets
			playsound(user,'sound/machines/click.ogg', 15, 1)

		if("fragmentation")
			//SET TO CRYO
			mode = "cryogenic"
			icon_state = "doomlauncher_cryo"
			fire_sound = 'sound/weapons/armbomb.ogg'
			to_chat(user, SPAN_NOTICE("[src] is now set to fire cryogenic grenades."))
			ammo = GLOB.ammo_list[/datum/ammo/grenade_container/cryogenic]
			playsound(user,'sound/machines/click.ogg', 15, 1)

/datum/action/item_action/specialist/doomguy_extend_equipment_launcher
	ability_primacy = SPEC_PRIMARY_ACTION_2
	name = "Toggle Equipment Launcher"

/datum/action/item_action/specialist/doomguy_extend_equipment_launcher/New(var/mob/living/user, var/obj/item/holder)
	..()
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "equipment_launcher")
	button.overlays += IMG

/datum/action/item_action/specialist/doomguy_extend_equipment_launcher/action_activate()
	if(!usr.loc || !usr.canmove || usr.stat)
		return FALSE
	var/mob/living/carbon/human/M = usr
	if(!istype(M))
		return FALSE
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
			return FALSE

		var/obj/item/weapon/gun/equipment_launcher/E
		if(!istype(E))
			E = new(usr)
		usr.put_in_active_hand(E)
		E.doom_armor = holder_item
		doom_armor.equipment_launcher_active = TRUE
		to_chat(usr, SPAN_NOTICE("You activate your equipment launcher."))
	return TRUE
