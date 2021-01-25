/*
LEVER-ACTION RIFLES
mostly a copypaste of shotgun code but not *entirely*
their unique feature is that a direct hit will buff your damage and firerate
*/

/obj/item/weapon/gun/lever_action
	name = "lever-action rifle"
	desc = "Welcome to the Wild West!"
	icon_state = "m717-placeholder" //placeholder for a 'base' leveraction
	item_state = "m717-placeholder"
	w_class = SIZE_LARGE
	fire_sound = 'sound/weapons/gun_lever_action_fire.ogg'
	reload_sound = 'sound/weapons/handling/gun_lever_action_reload.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	gun_category = GUN_CATEGORY_RIFLE
	aim_slowdown = SLOWDOWN_ADS_SMG
	wield_delay = WIELD_DELAY_FAST
	has_empty_icon = FALSE
	has_open_icon = FALSE
	var/lever_sound = 'sound/weapons/handling/gun_lever_action_lever.ogg'
	var/lever_delay //Higher means longer delay.
	var/recent_lever //world.time to see when they last levered it.
	var/levered = FALSE //Used to see if the rifle has already been levered.
	var/message //To not spam the above.
	var/onehand_success_chance = 85 //here so it can be easily VVed
	//REMEMBER THE CUSTOM SOUNDS FOR LOADING IN COCKING SUPERCOKCING ETC.
	//fix shotgun unloading?
	//fix weird levering spam
	//do the glob list thing and after that fix all generate_handfula nd after taht fix dumping into belts doing 5 roudn handfus.
	//mag harning it to your back does not update icon

/obj/item/weapon/gun/lever_action/examine(user)
	..()
	to_chat(user, SPAN_NOTICE("This gun works similarly to a pump shotgun, with a bonus feature: Hitting a target directly will grant you a firerate and damage buff for your next shot."))

/obj/item/weapon/gun/lever_action/m717
	name = "M717 lever-action rifle"
	desc = "This lever-action was designed for small scout operations in harsh environments such as the jungle or particularly windy deserts, as such its internal mechanisms are simple yet robust."
	icon_state = "m717"
	item_state = "m717"
	flags_equip_slot = SLOT_BACK
	current_mag = /obj/item/ammo_magazine/internal/lever_action
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
						/obj/item/attachable/m717_sling,
						//Stock
						/obj/item/attachable/stock/m717)
	map_specific_decoration = TRUE

/obj/item/weapon/gun/lever_action/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag)
		replace_internal_mag(current_mag.current_rounds)

/obj/item/weapon/gun/lever_action/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_1
	lever_delay = FIRE_DELAY_TIER_3
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = 0
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/lever_action/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 21, "under_x" = 15, "under_y" = 12, "stock_x" = 10, "stock_y" = 9)

/obj/item/weapon/gun/lever_action/pickup(var/mob/M)
	..()
	RegisterSignal(M, COMSIG_DIRECT_BULLET_HIT, .proc/direct_hit_buff)

/obj/item/weapon/gun/lever_action/dropped(var/mob/M)
	..()
	UnregisterSignal(M, COMSIG_DIRECT_BULLET_HIT)

/obj/item/weapon/gun/lever_action/proc/direct_hit_buff(mob/user, var/one_hand_lever = FALSE)
	if(!one_hand_lever) //you haven't hit anything so
		to_chat(user, SPAN_BOLDNOTICE("Bullseye!"))
		//playsound(cool_feedback)
	lever_sound = 'sound/weapons/handling/gun_lever_action_lever.ogg'
	last_fired = world.time + 2 //shoot the next round faster
	lever_delay = FIRE_DELAY_TIER_10
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_6 //increase the damage
	wield_delay = 0 //for one-handed levering
	addtimer(CALLBACK(src, .proc/reset_hit_buff), 0.5 SECONDS)

/obj/item/weapon/gun/lever_action/proc/reset_hit_buff(mob/user)
	lever_sound = 'sound/weapons/handling/gun_lever_action_lever.ogg'
	lever_delay = initial(fire_delay)
	damage_mult = initial(damage_mult)
	wield_delay = initial(wield_delay)

/obj/item/weapon/gun/lever_action/proc/replace_internal_mag(number_to_replace)
	if(!current_mag)
		return
	current_mag.chamber_contents = list()
	current_mag.chamber_contents.len = current_mag.max_rounds
	var/i
	for(i = 1 to current_mag.max_rounds) //We want to make sure to populate the internal_mag.
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
	if(user) playsound(user, reload_sound, 25, 1)
	return 1

/obj/item/weapon/gun/lever_action/proc/empty_chamber(mob/user)
	if(!current_mag)
		return
	if(current_mag.current_rounds <= 0)
		if(in_chamber)
			in_chamber = null
			var/obj/item/ammo_magazine/handful/new_handful = retrieve_bullet(ammo.type)
			playsound(user, reload_sound, 25, 1)
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
		playsound(user, reload_sound, 25, 1)
	else new_handful.forceMove(get_turf(src))

	current_mag.current_rounds--
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	return 1

		//While there is a much smaller way to do this,
		//this is the most resource efficient way to do it.
/obj/item/weapon/gun/lever_action/proc/retrieve_bullet(selection)
	var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful
	new_handful.generate_handful(selection, "45-70", 8, 1, /obj/item/weapon/gun/lever_action)
	return new_handful

/obj/item/weapon/gun/lever_action/reload(mob/user, var/obj/item/ammo_magazine/magazine)

	if(!magazine || !istype(magazine,/obj/item/ammo_magazine/handful)) //Can only reload with handfuls.
		to_chat(user, SPAN_WARNING("You can't use that to reload!"))
		return

	//From here we know they are using shotgun type ammo and reloading via handful.
	//Makes some of this a lot easier to determine.

	var/mag_caliber = magazine.default_ammo //Handfuls can get deleted, so we need to keep this on hand for later.
	if(current_mag.transfer_ammo(magazine,user,1))
		add_to_internal_mag(user,mag_caliber) //This will check the other conditions.

/obj/item/weapon/gun/lever_action/unload(mob/user)
	empty_chamber(user)

/obj/item/weapon/gun/lever_action/proc/ready_lever_action_internal_mag()
	if(isnull(current_mag) || !length(current_mag.chamber_contents))
		return
	if(current_mag.current_rounds > 0)
		ammo = ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
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
	playsound(user, reload_sound, 25, 1)
	return 1

/obj/item/weapon/gun/lever_action/proc/work_lever(mob/living/carbon/human/user)
	if(world.time < (recent_lever + lever_delay)) 
		return
	if(levered)
		if (world.time > (message + lever_delay))
			to_chat(user, SPAN_WARNING("<i>[src] already has a bullet in the chamber!<i>"))
			message = world.time
		return
	if(in_chamber) //eject the chambered round
		in_chamber = null
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_bullet(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_lever_action_internal_mag()

	playsound(user, lever_sound, 25, 1)
	//if(one_handed)
		//flip and add buff!
	
	if(flags_item & WIELDED)
		to_chat(user, SPAN_WARNING("<i>You work the lever.<i>"))
	else
		to_chat(user, SPAN_WARNING("<i>You spin the [src] one-handed! Fuck yeah!<i>"))
		if(prob(onehand_success_chance) || skillcheck(user, SKILL_FIREARMS, SKILL_FIREARMS_TRAINED)) //may as well make it VVable
			hit_buff(TRUE)
		else
			to_chat(user, SPAN_DANGER("Augh! Your hand catches on the lever!"))
			var/obj/limb/O = user.get_limb(user.hand ? "l_hand" : "r_hand")
			O.fracture()

	flick("m717_levered", src)
	recent_lever = world.time
	if (in_chamber)
		levered = TRUE


/obj/item/weapon/gun/lever_action/reload_into_chamber(mob/user)
	if(!current_mag)
		return
	if(!active_attachable)
		levered = FALSE //It was fired, so let's unlock the lever.
		in_chamber = null
		//Time to move the tube position.
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()//No rounds, nothing chambered.

	return TRUE

/obj/item/weapon/gun/lever_action/unload(mob/user) //We can't working the lever it to get rid of the shells, so we'll make it work via the unloading mechanism.
	if(levered)
		to_chat(user, SPAN_WARNING("You open the lever on [src]."))
		levered = FALSE
	return ..()