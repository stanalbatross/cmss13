/*
LEVER-ACTION RIFLES
mostly a copypaste of shotgun code but not *entirely*
their unique feature is that a direct hit will buff your damage and firerate
*/

/obj/item/weapon/gun/lever_action
	name = "lever-action rifle"
	desc = "Welcome to the Wild West!"
	icon_state = "lever_action"
	item_state = "lever_action"
	w_class = SIZE_LARGE
	fire_sound = 'sound/weapons/gun_lever_action_fire.ogg'
	reload_sound = 'sound/weapons/handling/gun_lever_action_reload.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	current_mag = /obj/item/ammo_magazine/internal/lever_action
	flags_equip_slot = SLOT_BACK
	attachable_allowed = list(
						//Barrel
						/obj/item/attachable/bayonet/upp,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/suppressor,
						/obj/item/attachable/compensator,
						//Rail
						/obj/item/attachable/reddot,
						/obj/item/attachable/reflex,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/magnetic_harness,
						//Under
						/obj/item/attachable/flashlight/grip,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/lever_sling,
						//Stock
						/obj/item/attachable/stock/lever
						)
	starting_attachment_types = list(/obj/item/attachable/stock/lever)
	gun_category = GUN_CATEGORY_RIFLE
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_FAST
	has_empty_icon = FALSE
	has_open_icon = FALSE
	var/lever_sprite = TRUE
	var/lever_sound = 'sound/weapons/handling/gun_lever_action_lever.ogg'
	var/lever_super_sound = 'sound/weapons/handling/gun_lever_action_superload.ogg'
	var/lever_hitsound = 'sound/weapons/handling/gun_lever_action_hitsound.ogg'
	var/lever_delay
	var/recent_lever
	var/levered = FALSE
	var/message_cooldown
	var/cur_onehand_chance = 85
	var/reset_onehand_chance = 85
	var/lever_message = "<i>You work the lever.<i>"
	var/buff_fire_reduc = 2
	var/streak

/obj/item/weapon/gun/lever_action/examine(user)
	..()
	to_chat(user, SPAN_NOTICE("This gun is levered via Unique-Action, but it has a bonus feature: Hitting a target directly will grant you a firerate and damage buff for your next shot during a short interval. Combo precision hits for massive damage."))

/obj/item/weapon/gun/lever_action/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag)
		replace_internal_mag(current_mag.current_rounds)

/obj/item/weapon/gun/lever_action/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_1 + FIRE_DELAY_TIER_10
	lever_delay = FIRE_DELAY_TIER_3
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = 0
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

/obj/item/weapon/gun/lever_action/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 21, "under_x" = 15, "under_y" = 12, "stock_x" = 15, "stock_y" = 11)

/obj/item/weapon/gun/lever_action/wield(var/mob/M)
	. = ..()
	if(!.)
		return
	RegisterSignal(M, COMSIG_DIRECT_BULLET_HIT, .proc/direct_hit_effect)

/obj/item/weapon/gun/lever_action/unwield(var/mob/M)
	. = ..()
	if(!.)
		return
	UnregisterSignal(M, COMSIG_DIRECT_BULLET_HIT)

/obj/item/weapon/gun/lever_action/proc/direct_hit_effect(var/mob/M, mob/target, var/one_hand_lever = FALSE)
	direct_hit_buff(M, target, one_hand_lever)

/obj/item/weapon/gun/lever_action/proc/direct_hit_buff(mob/user, mob/target, var/one_hand_lever = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = user
	if(one_hand_lever) //base marines should never be able to easily pass the skillcheck, only specialists and etc.
		if(prob(cur_onehand_chance) || skillcheck(human_user, SKILL_FIREARMS, SKILL_FIREARMS_TRAINED)) 
			cur_onehand_chance = cur_onehand_chance - 20 //gets steadily worse if you spam it
		else
			to_chat(user, SPAN_DANGER("Augh! Your hand catches on the lever!!"))
			var/obj/limb/O = human_user.get_limb(human_user.hand ? "l_hand" : "r_hand")
			if(O.status & LIMB_BROKEN)
				O = human_user.get_limb(user.hand ? "l_arm" : "r_arm")
				human_user.drop_held_item()
			O.fracture()
			O &= ~LIMB_SPLINTED
			human_user.pain.recalculate_pain()
			return

	else if(target && target.stat == DEAD)
		return

	else
		if(streak)
			to_chat(user, SPAN_BOLDNOTICE("Bullseye! [streak + 1] hits in a row!"))
		else
			to_chat(user, SPAN_BOLDNOTICE("Bullseye!"))
		streak++
		playsound(user, lever_hitsound, 25, FALSE)
	lever_sound = lever_super_sound
	lever_message = "<b><i>You quickly work the lever!<i><b>"
	lever_delay = FIRE_DELAY_TIER_10
	last_fired = world.time - buff_fire_reduc //to shoot the next round faster
	fire_delay = FIRE_DELAY_TIER_5
	damage_mult = initial(damage_mult) + BULLET_DAMAGE_MULT_TIER_10
	wield_delay = 0 //for one-handed levering
	addtimer(CALLBACK(src, .proc/reset_hit_buff, user, one_hand_lever), 1 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE) //continously override timer as long as streak continues

/obj/item/weapon/gun/lever_action/proc/reset_hit_buff(mob/user, var/one_hand_lever)
	SIGNAL_HANDLER
	streak = 0
	lever_sound = initial(lever_sound)
	lever_message = initial(lever_message)
	wield_delay = initial(wield_delay)
	//cur_onehand_chance = initial(cur_onehand_chance)
	//these are init configs and so cannot be initial()
	lever_delay = FIRE_DELAY_TIER_3
	fire_delay = FIRE_DELAY_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recalculate_attachment_bonuses() //stock wield delay
	if(one_hand_lever)
		addtimer(VARSET_CALLBACK(src, cur_onehand_chance, reset_onehand_chance), 4 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/item/weapon/gun/lever_action/proc/replace_internal_mag(number_to_replace)
	if(!current_mag)
		return
	current_mag.chamber_contents = list()
	current_mag.chamber_contents.len = current_mag.max_rounds
	for(var/i = 1 to current_mag.max_rounds) //We want to make sure to populate the internal_mag.
		current_mag.chamber_contents[i] = i > number_to_replace ? "empty" : current_mag.default_ammo
	current_mag.chamber_position = current_mag.current_rounds //The position is always in the beginning [1]. It can move from there.

/obj/item/weapon/gun/lever_action/proc/add_to_internal_mag(mob/user,selection) //bullets are added forward.
	if(!current_mag)
		return
	current_mag.chamber_position++ //We move the position up when loading ammo. New rounds are always fired next, in order loaded.
	current_mag.chamber_contents[current_mag.chamber_position] = selection //Just moves up one, unless the mag is full.
	if(current_mag.current_rounds == 1 && !in_chamber) //The previous proc in the reload() cycle adds ammo, so the best workaround here,
		update_icon()	//This is not needed for now. Maybe we'll have loaded sprites at some point, but I doubt it. Also doesn't play well with double barrel.
		ready_in_chamber()
		cock_gun(user)
	if(user) playsound(user, reload_sound, 25, TRUE)
	return TRUE

/obj/item/weapon/gun/lever_action/proc/empty_chamber(mob/user)
	if(!current_mag)
		return
	if(current_mag.current_rounds <= 0)
		if(in_chamber)
			in_chamber = null
			var/obj/item/ammo_magazine/handful/new_handful = retrieve_bullet(ammo.type)
			playsound(user, reload_sound, 25, TRUE)
			new_handful.forceMove(get_turf(src))
		else
			if(user) to_chat(user, SPAN_WARNING("[src] is already empty."))
		return

	unload_bullet(user)
	if(!current_mag.current_rounds && !in_chamber) update_icon()

/obj/item/weapon/gun/lever_action/proc/unload_bullet(mob/user)
	if(isnull(current_mag) || !length(current_mag.chamber_contents))
		return
	var/obj/item/ammo_magazine/handful/new_handful = retrieve_bullet(current_mag.chamber_contents[current_mag.chamber_position])

	if(user)
		user.put_in_hands(new_handful)
		playsound(user, reload_sound, 25, TRUE)
	else new_handful.forceMove(get_turf(src))

	current_mag.current_rounds--
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	return TRUE

/obj/item/weapon/gun/lever_action/proc/retrieve_bullet(selection)
	var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful
	new_handful.generate_handful(selection, "45-70", 9, 1, /obj/item/weapon/gun/lever_action)
	return new_handful

/obj/item/weapon/gun/lever_action/reload(mob/user, var/obj/item/ammo_magazine/magazine)

	if(!magazine || !istype(magazine,/obj/item/ammo_magazine/handful)) //Can only reload with handfuls.
		to_chat(user, SPAN_WARNING("You can't use that to reload!"))
		return

	var/mag_caliber = magazine.default_ammo //Handfuls can get deleted, so we need to keep this on hand for later.
	if(current_mag.transfer_ammo(magazine,user,1))
		add_to_internal_mag(user,mag_caliber) //This will check the other conditions.

/obj/item/weapon/gun/lever_action/proc/ready_lever_action_internal_mag()
	if(isnull(current_mag) || !length(current_mag.chamber_contents))
		return
	if(current_mag.current_rounds > 0)
		ammo = GLOB.ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
		in_chamber = create_bullet(ammo, initial(name))
		current_mag.current_rounds--
		current_mag.chamber_contents[current_mag.chamber_position] = "empty"
		current_mag.chamber_position--
		return in_chamber

/obj/item/weapon/gun/lever_action/ready_in_chamber()
	return ready_lever_action_internal_mag()

/obj/item/weapon/gun/lever_action/reload_into_chamber(mob/user)
	if(!active_attachable)
		in_chamber = null

		//Time to move the internal_mag position.
		ready_in_chamber() //We're going to try and reload. If we don't get anything, icon change.
		if(!current_mag.current_rounds && !in_chamber) //No rounds, nothing chambered.
			update_icon()

	return TRUE

/obj/item/weapon/gun/lever_action/unique_action(mob/user)
	work_lever(user)

/obj/item/weapon/gun/lever_action/ready_in_chamber()
	return

/obj/item/weapon/gun/lever_action/add_to_internal_mag(mob/user, selection) //Load it on the go, nothing chambered.
	if(!current_mag)
		return
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, TRUE)
	return TRUE

/obj/item/weapon/gun/lever_action/proc/work_lever(mob/living/carbon/human/user)
	if(world.time < (recent_lever + lever_delay)) 
		return
	if(levered)
		if (world.time > (message_cooldown + lever_delay))
			to_chat(user, SPAN_WARNING("<i>[src] already has a bullet in the chamber!<i>"))
			message_cooldown = world.time
		return
	if(in_chamber) //eject the chambered round
		in_chamber = null
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_bullet(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_lever_action_internal_mag()

	recent_lever = world.time
	if(in_chamber)
		if(lever_sprite)
			flick("[icon_state]_lever", src)
		if(world.time < (last_fired + 2 SECONDS)) //if it's not wielded and you shot recently, one-hand lever
			try_onehand_lever(user)
		else
			twohand_lever(user)

		playsound(user, lever_sound, 25, TRUE) //should be TRUE not 1
		levered = TRUE

/obj/item/weapon/gun/lever_action/proc/twohand_lever(mob/living/carbon/human/user)
	to_chat(user, SPAN_WARNING(lever_message))
	animation_move_up_slightly(src)

/obj/item/weapon/gun/lever_action/proc/try_onehand_lever(mob/living/carbon/human/user)
	if(flags_item & WIELDED)
		twohand_lever(user)
		return
	to_chat(user, SPAN_WARNING("<i>You spin the [src] one-handed! Fuck yeah!<i>"))
	animation_wrist_flick(src)
	direct_hit_buff(user, ,TRUE)

/obj/item/weapon/gun/lever_action/reload_into_chamber(mob/user)
	if(!current_mag)
		return
	if(!active_attachable)
		levered = FALSE //It was fired, so let's unlock the lever.
		in_chamber = null
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()//No rounds, nothing chambered.

	return TRUE

/obj/item/weapon/gun/lever_action/unload(mob/user)
	if(levered)
		to_chat(user, SPAN_WARNING("You open the lever on [src]."))
		levered = FALSE
	return empty_chamber(user)

//don't think about how this incredibly expensive railgun is roughly as effective as a 19th century lever-action rifle
/obj/item/weapon/gun/lever_action/railgun
	name = "XM-42b infantry railgun"
	desc = "This extremely advanced and expensive gun was marketed as the future of the USCM for a year, and then severe fundamental structural flaws that were being covered up to keep the project afloat were exposed to the USCM. Despite the scandal that proceeded, many of these guns were still produced as heavy support."
	icon_state = "xm42b"
	item_state = "xm42b"
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AMMO_COUNTER
	attachable_allowed = list()
	starting_attachment_types = list()
	lever_sprite = FALSE
	var/obj/item/attachable/scope/railgun/scope

/obj/item/weapon/gun/lever_action/railgun/handle_starting_attachment()
	..()
	scope = new /obj/item/attachable/scope/railgun(src)
	scope.hidden = TRUE
	scope.flags_attach_features &= ~ATTACH_REMOVABLE
	scope.Attach(src)
	update_attachable(scope.slot)

/obj/item/weapon/gun/lever_action/railgun/direct_hit_effect(var/mob/M, mob/target, var/one_hand_lever = FALSE)
	direct_hit_buff(M, target, one_hand_lever)
	if(scope.broken)
		return
	break_scope(M)

/obj/item/weapon/gun/lever_action/railgun/proc/break_scope(var/mob/M)
	scope.broken = TRUE
	M.visible_message(SPAN_DANGER("[src]'s scope's lens shatters in [M]'s hands!"),
	SPAN_DANGER("[src]'s scope's lens shatters in your hands!"))
	playsound(src, "shatter", 25, TRUE)
	new /obj/item/shard(M.loc)

//purely an excuse to keep the scope in the sprite. also fits with the flavor desc of the gun
/obj/item/attachable/scope/railgun
	name = "XM-42b 8x telescopic scope"
	var/broken

/obj/item/attachable/scope/railgun/activate_attachment(obj/item/weapon/gun/G, mob/living/carbon/user, turn_off)
	if(broken)
		to_chat(user, SPAN_WARNING("The stress of firing [G] shattered this scope's lens."))
		return
	else
		..()
