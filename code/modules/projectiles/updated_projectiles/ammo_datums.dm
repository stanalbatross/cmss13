//Bitflag defines are in setup.dm. Referenced here.
/*
#define AMMO_EXPLOSIVE 		1
#define AMMO_XENO_ACID 		2
#define AMMO_XENO_TOX		4
#define AMMO_ENERGY 		8
#define AMMO_ROCKET			16
#define AMMO_SNIPER			32
#define AMMO_INCENDIARY		64
#define AMMO_SKIPS_ALIENS 	256
#define AMMO_IS_SILENCED 	512
#define AMMO_IGNORE_ARMOR	1024
#define AMMO_IGNORE_RESIST	2048
#define AMMO_BALLISTIC		4096
*/

/datum/ammo
	var/name 		= "generic bullet"
	var/impact_name	= null // Name of icon when trying to give a mob a projectile impact overlay
	var/impact_limbs = BODY_FLAG_NO_BODY // The body parts that have an impact icon
	var/icon 		= 'icons/obj/items/weapons/projectiles.dmi'
	var/icon_state 	= "bullet"
	var/ping 		= "ping_b" //The icon that is displayed when the bullet bounces off something.
	var/sound_hit //When it deals damage.
	var/sound_armor //When it's blocked by human armor.
	var/sound_miss //When it misses someone.
	var/sound_bounce //When it bounces off something.

	var/accuracy 					= 0 		// This is added to the bullet's base accuracy
	var/accuracy_var_low			= 0 		// How much the accuracy varies when fired
	var/accuracy_var_high			= 0
	var/accurate_range 				= 0 		// For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though
	var/accurate_range_min 			= 0			// Snipers use this to simulate poor accuracy at close ranges
	var/max_range 					= 0 		// This will de-increment a counter on the bullet
	var/scatter  					= 0 		// How much the ammo scatters when burst fired, added to gun scatter, along with other mods
	var/stamina_damage 				= 0
	var/damage 						= 0 		// This is the base damage of the bullet as it is fired
	var/damage_var_low				= 0 		// Same as with accuracy variance
	var/damage_var_high				= 0
	var/damage_falloff 				= 0 		// How much damage the bullet loses per turf traveled after the effective range
	var/damage_buildup 				= 0 		// How much damage the bullet loses per turf away before the effective range
	var/effective_range_min			= 0			//What minimum range the ammo deals full damage, builds up the closer you get. 0 for no minimum. Added onto gun range as a modifier.
	var/effective_range_max			= 0			//What maximum range the ammo deals full damage, tapers off using damage_falloff after hitting this value. 0 for no maximum. Added onto gun range as a modifier.
	var/damage_type 				= BRUTE 	// BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/penetration					= 0 		// How much armor it ignores before calculations take place
	var/shrapnel_chance 			= 0 		// The % chance it will imbed in a human
	var/shrapnel_type				= 0			// The shrapnel type the ammo will embed, if the chance rolls
	var/shell_speed 				= 0 		// How fast the projectile moves
	var/bonus_projectiles_type 					// Type path of the extra projectiles
	var/bonus_projectiles_amount 	= 0 		// How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together
	var/debilitate[]				= null 		// Stun,knockdown,knockout,irradiate,stutter,eyeblur,drowsy,agony
	var/pen_armor_punch				= 0.5		// how much armor breaking will be done per point of penetration. This is for weapons that penetrate with their shape (like needle bullets)
	var/damage_armor_punch			= 0.5		// how much armor breaking is done by sheer weapon force. This is for big blunt weapons
	var/sound_override				= null		// if we should play a special sound when firing.
	var/flags_ammo_behavior 		= NO_FLAGS

/datum/ammo/can_vv_modify()
	return FALSE

/datum/ammo/New()
	accuracy 			= config.min_hit_accuracy 	// This is added to the bullet's base accuracy.
	accuracy_var_low	= config.min_proj_variance 	// How much the accuracy varies when fired.
	accuracy_var_high	= config.min_proj_variance
	accurate_range 		= config.close_shell_range 	// For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though.
	max_range 			= config.norm_shell_range 	// This will de-increment a counter on the bullet.
	damage_var_low		= config.min_proj_variance 	// Same as with accuracy variance.
	damage_var_high		= config.min_proj_variance
	damage_falloff 		= config.reg_damage_falloff // How much damage the bullet loses per turf traveled after the effective range
	damage_buildup 		= config.reg_damage_buildup // How much damage the bullet loses per turf away before the effective range
	effective_range_min	= config.no_effective_range_min	//What minimum range the ammo deals full damage, builds up the closer you get. 0 for no minimum. Added onto gun range as a modifier.
	effective_range_max	= config.no_effective_range_max	//What maximum range the ammo deals full damage, tapers off using damage_falloff after hitting this value. 0 for no maximum. Added onto gun range as a modifier.
	shell_speed 		= config.slow_shell_speed 	// How fast the projectile moves.

/datum/ammo/proc/do_at_half_range(obj/item/projectile/P)
	return

/datum/ammo/proc/on_embed(var/mob/embedded_mob, var/obj/limb/target_organ)
	return

/datum/ammo/proc/do_at_max_range(obj/item/projectile/P)
	return

/datum/ammo/proc/on_shield_block(mob/M, obj/item/projectile/P) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
	return

/datum/ammo/proc/on_hit_turf(turf/T, obj/item/projectile/P) //Special effects when hitting dense turfs.
	return

/datum/ammo/proc/on_hit_mob(mob/M, obj/item/projectile/P) //Special effects when hitting mobs.
	return

/datum/ammo/proc/on_pointblank(mob/M, obj/item/projectile/P, mob/living/user) //Special effects when pointblanking mobs.
	return

/datum/ammo/proc/on_hit_obj(obj/O, obj/item/projectile/P) //Special effects when hitting objects.
	return

/datum/ammo/proc/on_near_target(turf/T, obj/item/projectile/P) //Special effects when passing near something. Range of things that triggers it is controlled by other ammo flags.
	return 0 //return 0 means it flies even after being near something. Return 1 means it stops

/datum/ammo/proc/knockback(mob/M, obj/item/projectile/P, var/max_range = 2)
	if(!M || M == P.firer) return
	if(P.distance_travelled > max_range || M.lying) shake_camera(M, 2, 1) //Two tiles away or more, basically.

	else //One tile away or less.
		shake_camera(M, 3, 4)
		if(isliving(M)) //This is pretty ugly, but what can you do.
			if(isXeno(M))
				var/mob/living/carbon/Xenomorph/target = M
				if(target.mob_size == MOB_SIZE_BIG)
					target.apply_effect(2, SLOW)
					return //Big xenos are not affected.
				target.apply_effect(0.7, WEAKEN) // 0.9 seconds of stun, per agreement from Balance Team when switched from MC stuns to exact stuns
				target.apply_effect(1, SUPERSLOW)
				target.apply_effect(2, SLOW)
				to_chat(target, SPAN_XENODANGER("You are shaken by the sudden impact!"))
			else
				var/mob/living/L = M
				L.apply_stamina_damage(P.ammo.damage, P.def_zone, ARMOR_BULLET)
		step_away(M,P)

/datum/ammo/proc/heavy_knockback(mob/M, obj/item/projectile/P, var/max_range = 6) //crazier version of knockback
	if(!M || M == P.firer) return
	if(P.distance_travelled > max_range || M.lying) shake_camera(M, 3, 2)
	shake_camera(M, 3, 4)
	if(isliving(M)) //This is pretty ugly, but what can you do.
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/target = M
			to_chat(target, SPAN_XENODANGER("You are shaken by the sudden impact!"))
			if(target.mob_size == MOB_SIZE_BIG)
				target.apply_effect(0.3, DAZE)
				target.apply_effect(2, SLOW)
				return
			target.apply_effect(0.5, WEAKEN)
			target.apply_effect(4, DAZE)
			target.apply_effect(2, SUPERSLOW)
			target.apply_effect(5, SLOW)
		else
			var/mob/living/target = M
			if(!isYautja(M)) //Not predators.
				target.apply_effect(5, DAZE)
				target.apply_effect(5, SUPERSLOW)
				target.apply_effect(8, SLOW)
				to_chat(target, SPAN_HIGHDANGER("The blast knocks you off your feet!"))
			target.apply_stamina_damage(P.ammo.damage, P.def_zone, ARMOR_BULLET)
	step_away(M,P)

/datum/ammo/proc/burst(atom/target, obj/item/projectile/P, damage_type = BRUTE, range = 1, damage_div = 2, show_message = 1) //damage_div says how much we divide damage
	if(!target || !P) return
	for(var/mob/living/carbon/M in orange(range,target))
		if(P.firer == M)
			continue
		if(show_message)
			var/msg = "You are hit by backlash from \a </b>[P.name]</b>!"
			M.visible_message(SPAN_DANGER("[M] is hit by backlash from \a [P.name]!"),isXeno(M) ? SPAN_XENODANGER("[msg]"):SPAN_HIGHDANGER("[msg]"))
		var/damage = P.damage/damage_div
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/XNO = M
			var/total_explosive_resistance = XNO.caste.xeno_explosion_resistance + XNO.armor_explosive_buff
			damage = armor_damage_reduction(config.xeno_explosive, damage, total_explosive_resistance , 60, 0, 0.5, XNO.armor_integrity)
			var/armor_punch = armor_break_calculation(config.xeno_explosive, damage, total_explosive_resistance, 60, 0, 0.5, XNO.armor_integrity)
			XNO.apply_armorbreak(armor_punch)

		M.apply_damage(damage,damage_type)
		P.play_damage_effect(M)

/datum/ammo/proc/fire_bonus_projectiles(obj/item/projectile/original_P)
	set waitfor = 0

	var/turf/curloc = get_turf(original_P.shot_from)
	var/initial_angle = Get_Angle(curloc, original_P.target_turf)

	var/i
	for(i = 0 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.

		var/final_angle = initial_angle

		var/obj/item/projectile/P = new /obj/item/projectile(original_P.weapon_source, original_P.weapon_source_mob, original_P.shot_from)
		P.generate_bullet(ammo_list[bonus_projectiles_type]) //No bonus damage or anything.
		P.accuracy = round(P.accuracy * original_P.accuracy/initial(original_P.accuracy)) //if the gun changes the accuracy of the main projectile, it also affects the bonus ones.

		var/total_scatter_angle = P.scatter
		final_angle += rand(-total_scatter_angle, total_scatter_angle)
		var/turf/new_target = get_angle_target_turf(curloc, final_angle, 30)

		P.fire_at(new_target, original_P.firer, original_P.shot_from, P.ammo.max_range, P.ammo.shell_speed, original_P.original, iff_group = original_P.iff_group) //Fire!

/datum/ammo/proc/drop_flame(turf/T, var/source, var/source_mob) // ~Art updated fire 20JAN17
	if(!istype(T)) return
	if(locate(/obj/flamer_fire) in T) return

	var/datum/reagent/napalm/ut/R = new()
	new /obj/flamer_fire(T, source, source_mob, R)


/*
//================================================
					Default Ammo
//================================================
*/
//Only when things screw up do we use this as a placeholder.
/datum/ammo/bullet
	name = "default bullet"
	icon_state = "bullet"
	flags_ammo_behavior = AMMO_BALLISTIC
	sound_hit 	 = "ballistic_hit"
	sound_armor  = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"
	accurate_range_min = 0

/datum/ammo/bullet/New()
	..()
	damage = config.base_hit_damage
	shrapnel_chance = config.low_shrapnel_chance
	shrapnel_type = /obj/item/shard/shrapnel
	shell_speed = config.super_shell_speed

/*
//================================================
					Pistol Ammo
//================================================
*/

// Used by M4A3, M4A3 Custom and B92FS
/datum/ammo/bullet/pistol
	name = "pistol bullet"

/datum/ammo/bullet/pistol/New()
	..()
	damage = config.med_hit_damage
	accuracy = config.low_hit_accuracy

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"

/datum/ammo/bullet/pistol/tranq
	name = "tranq bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_IGNORE_RESIST
	stamina_damage = 300

	var/knockout_period = SECONDS_10

/datum/ammo/bullet/pistol/tranq/New()
	. = ..()
	shrapnel_chance = 0

/datum/ammo/bullet/pistol/tranq/on_hit_mob(mob/M, obj/item/projectile/P)
	. = ..()
	if(isliving(M))
		var/mob/living/L = M
		if(L.stamina)
			L.stamina.apply_rest_period(knockout_period)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"

/datum/ammo/bullet/pistol/hollow/New()
	..()
	accuracy = -config.med_hit_accuracy
	shrapnel_chance = config.high_shrapnel_chance

// Used by M4A3 AP, Highpower and mod88
/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"

/datum/ammo/bullet/pistol/ap/New()
	..()
	damage = config.hlmed_hit_damage
	accuracy = config.low_hit_accuracy
	penetration= config.med_armor_penetration
	shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/le
	name = "armor-shredding pistol bullet"

/datum/ammo/bullet/pistol/le/New()
	..()
	damage = config.min_hit_damage
	penetration = config.low_armor_penetration
	pen_armor_punch = 3

/datum/ammo/bullet/pistol/rubber
	name = "rubber pistol bullet"
	sound_override = 'sound/weapons/gun_c99.ogg'

/datum/ammo/bullet/pistol/rubber/New()
	..()
	damage = config.no_hit_damage
	stamina_damage = config.low_hit_damage
	shrapnel_chance = 0

// Used by M1911, Deagle and KT-42
/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"

/datum/ammo/bullet/pistol/heavy/New()
	..()
	accuracy = -config.med_hit_accuracy
	accuracy_var_low = config.med_proj_variance
	damage = config.hmed_hit_damage
	penetration= config.mlow_armor_penetration
	shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/pistol/incendiary/New()
	..()
	accuracy = config.med_hit_accuracy
	damage = config.mlow_hit_damage

// Used by VP78 and Auto 9
/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	debilitate = list(0,0,0,0,0,0,0,2)

/datum/ammo/bullet/pistol/squash/New()
	..()
	accuracy = config.med_hit_accuracy
	damage = config.hmed_hit_damage
	penetration= config.hlow_armor_penetration
	shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/mankey
	name = "live monkey"
	icon_state = "monkey1"
	ping = null //no bounce off.
	damage_type = BURN
	debilitate = list(4,4,0,0,0,0,0,0)
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR

/datum/ammo/bullet/pistol/mankey/New()
	..()
	damage = config.min_hit_damage
	damage_var_high = config.high_proj_variance
	shell_speed = config.reg_shell_speed

/datum/ammo/bullet/pistol/mankey/on_hit_mob(mob/M,obj/item/projectile/P)
	if(P && P.loc && !M.stat && !istype(M,/mob/living/carbon/human/monkey))
		P.visible_message(SPAN_DANGER("The [src] chimpers furiously!"))
		new /mob/living/carbon/human/monkey(P.loc)

/datum/ammo/bullet/pistol/smart
	name = "smartpistol bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

/datum/ammo/bullet/pistol/smart/New()
	..()
	accuracy = config.max_hit_accuracy
	damage = config.hlow_hit_damage
	penetration= config.hlow_armor_penetration
	shrapnel_chance = config.med_shrapnel_chance

/*
//================================================
					Revolver Ammo
//================================================
*/

/datum/ammo/bullet/revolver
	name = "revolver bullet"
	debilitate = list(1,0,0,0,0,0,0,0)

/datum/ammo/bullet/revolver/New()
	..()
	damage = config.high_hit_damage
	penetration = config.min_armor_penetration
	accuracy = config.min_hit_accuracy

/datum/ammo/bullet/revolver/marksman
	name = "marksman revolver bullet"
	shrapnel_chance = 0
	damage_falloff = 0

/datum/ammo/bullet/revolver/marksman/New()
	..()
	accurate_range = config.short_shell_range
	penetration = config.hmed_armor_penetration

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"

/datum/ammo/bullet/revolver/heavy/New()
	..()
	damage = config.med_hit_damage
	penetration = config.low_armor_penetration
	accuracy = config.med_hit_accuracy

/datum/ammo/bullet/revolver/heavy/on_hit_mob(mob/M, obj/item/projectile/P)
	knockback(M, P, 4)

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"

/datum/ammo/bullet/revolver/small/New()
	..()
	damage = config.lmed_hit_damage

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	impact_name = "mateba"
	impact_limbs = BODY_FLAG_HEAD
	debilitate = list(0,2,0,0,0,1,0,0)

/datum/ammo/bullet/revolver/highimpact/New()
	..()
	damage = config.high_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.med_proj_variance
	penetration = config.mlow_armor_penetration

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/M, obj/item/projectile/P)
	knockback(M, P, 4)

/datum/ammo/bullet/revolver/highimpact/on_pointblank(mob/M, obj/item/projectile/P, mob/living/user) //Special effects when pointblanking mobs.
	if(!user || !isHumanStrict(M) || user.zone_selected != "head")
		return ..()
	var/mob/living/carbon/human/H = M
	user.visible_message(SPAN_DANGER("[user] aims at [M]'s head!"), SPAN_HIGHDANGER("You aim at [M]'s head!"))

	if(!do_after(user, 10, INTERRUPT_ALL, BUSY_ICON_HOSTILE) || !user.Adjacent(H))
		return -1

	H.apply_damage(500, BRUTE, "head", no_limb_loss = TRUE, impact_name = impact_name, impact_limbs = impact_limbs, permanent_kill = TRUE) //not coming back
	H.visible_message(SPAN_DANGER("[M] WAS EXECUTED!"), \
		SPAN_HIGHDANGER("You were Executed!"))

	user.count_niche_stat(STATISTICS_NICHE_EXECUTION, 1, P.weapon_source)

	var/area/A = get_area(H)

	msg_admin_attack(FONT_SIZE_HUGE("[key_name(usr)] has battlefield executed [key_name(H)] in [get_area(usr)] ([usr.loc.x],[usr.loc.y],[usr.loc.z])."), usr.loc.x, usr.loc.y, usr.loc.z)
	log_attack("[key_name(usr)] battlefield executed [key_name(H)] at [A.name].")

/*
//================================================
					SMG Ammo
//================================================
*/

/datum/ammo/bullet/smg
	name = "submachinegun bullet"

/datum/ammo/bullet/smg/New()
	..()
	damage = config.med_hit_damage
	accurate_range = config.lshort_shell_range
	penetration = 0
	shell_speed = config.fast_shell_speed
	damage_falloff = config.med_damage_falloff
	scatter = config.med_scatter_value
	accuracy = config.med_hit_accuracy

/datum/ammo/bullet/smg/ap
	name = "armor-piercing submachinegun bullet"

/datum/ammo/bullet/smg/ap/New()
	..()
	scatter = config.min_scatter_value
	damage = config.hlmed_hit_damage
	penetration = config.hlow_armor_penetration
	damage_falloff = config.med_damage_falloff

/datum/ammo/bullet/smg/incendiary
	name = "incendiary submachinegun bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/smg/incendiary/New()
	..()
	damage = config.hlow_hit_damage
	accuracy = -config.low_hit_accuracy
	shell_speed = config.fast_shell_speed
	damage_falloff = config.reg_damage_falloff

/datum/ammo/bullet/smg/le
	name = "armor-shredding submachinegun bullet"

/datum/ammo/bullet/smg/le/New()
	..()
	scatter = config.min_scatter_value
	damage = config.mlow_hit_damage
	penetration = config.low_armor_penetration
	shell_speed = config.fast_shell_speed
	damage_falloff = config.reg_damage_falloff
	pen_armor_punch = 4

/datum/ammo/bullet/smg/rubber
	name = "rubber submachinegun bullet"
	sound_override = 'sound/weapons/gun_c99.ogg'

/datum/ammo/bullet/smg/rubber/New()
	..()
	damage = config.no_hit_damage
	stamina_damage = config.base_hit_damage
	shrapnel_chance = 0

/*
//================================================
					Rifle Ammo
//================================================
*/

/datum/ammo/bullet/rifle
	name = "rifle bullet"

/datum/ammo/bullet/rifle/New()
	..()
	accurate_range = config.moderate_shell_range
	damage = config.hmed_hit_damage
	accuracy = config.hmed_hit_accuracy
	scatter = config.min_scatter_value
	shell_speed = config.ultra_shell_speed
	damage_falloff = config.tactical_damage_falloff

/datum/ammo/bullet/rifle/explosive
	name = "explosive rifle bullet"

/datum/ammo/bullet/rifle/explosive/New()
	..()
	accurate_range = config.norm_shell_range
	damage = config.hlow_hit_damage
	accuracy = 0
	shell_speed = config.super_shell_speed
	damage_falloff = config.med_damage_falloff

/datum/ammo/bullet/rifle/explosive/on_hit_mob(mob/M, obj/item/projectile/P)
	cell_explosion(get_turf(M), 80, 40, EXPLOSION_FALLOFF_SHAPE_LINEAR, P.dir, P.weapon_source, P.weapon_source_mob)

/datum/ammo/bullet/rifle/explosive/on_hit_obj(obj/O, obj/item/projectile/P)
	cell_explosion(get_turf(O), 80, 40, EXPLOSION_FALLOFF_SHAPE_LINEAR, P.dir, P.weapon_source, P.weapon_source_mob)

/datum/ammo/bullet/rifle/explosive/on_hit_turf(turf/T, obj/item/projectile/P)
	if(T.density)
		cell_explosion(T, 80, 40, EXPLOSION_FALLOFF_SHAPE_LINEAR, P.dir, P.weapon_source, P.weapon_source_mob)

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"

/datum/ammo/bullet/rifle/ap/New()
	..()
	damage = config.hlow_hit_damage
	penetration = config.med_armor_penetration

/datum/ammo/bullet/rifle/le
	name = "armor-shredding rifle bullet"

/datum/ammo/bullet/rifle/le/New()
	..()
	damage = config.mlow_hit_damage
	penetration = config.low_armor_penetration
	pen_armor_punch = 5

/datum/ammo/bullet/rifle/rubber
	name = "rubber rifle bullet"
	sound_override = 'sound/weapons/gun_c99.ogg'

/datum/ammo/bullet/rifle/rubber/New()
	..()
	damage = config.no_hit_damage
	stamina_damage = config.min_hit_damage
	shrapnel_chance = 0

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/rifle/incendiary/New()
	..()
	damage = config.hlmed_hit_damage
	shell_speed = config.super_shell_speed
	accuracy = -config.low_hit_accuracy
	damage_falloff = config.reg_damage_falloff


/datum/ammo/bullet/rifle/m4ra
	name = "A19 high velocity bullet"
	shrapnel_chance = 0
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC
	accurate_range_min = 4

/datum/ammo/bullet/rifle/m4ra/New()
	..()
	damage = config.high_hit_damage
	scatter = -config.low_scatter_value
	penetration= config.hmed_armor_penetration
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/rifle/m4ra/incendiary
	name = "A19 high velocity incendiary bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/rifle/m4ra/incendiary/New()
	..()
	damage = config.hmed_hit_damage
	accuracy = config.hmed_hit_accuracy
	scatter = -config.low_scatter_value
	penetration= config.hlow_armor_penetration
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/rifle/m4ra/impact
	name = "A19 high velocity impact bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

/datum/ammo/bullet/rifle/m4ra/impact/New()
	..()
	damage = config.hmed_hit_damage
	accuracy = -config.low_hit_accuracy
	scatter = -config.low_scatter_value
	penetration= config.high_armor_penetration
	shell_speed = config.ultra_shell_speed

/datum/ammo/bullet/rifle/m4ra/impact/on_hit_mob(mob/M, obj/item/projectile/P)
	knockback(M, P, config.max_shell_range)	// Can knockback basically at max range
	M.Daze(3)

/datum/ammo/bullet/rifle/mar40
	name = "heavy rifle bullet"

/datum/ammo/bullet/rifle/mar40/New()
	..()
	damage = config.high_hit_damage

/*
//================================================
					Shotgun Ammo
//================================================
*/

/datum/ammo/bullet/shotgun

/datum/ammo/bullet/shotgun/slug
	name = "shotgun slug"
	impact_name = "slug"
	impact_limbs = BODY_FLAG_HEAD

/datum/ammo/bullet/shotgun/slug/New()
	..()
	accurate_range = config.short_shell_range
	max_range = config.short_shell_range*1.4
	damage = config.high_hit_damage
	penetration = config.mlow_armor_penetration
	damage_armor_punch = 2

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/M,obj/item/projectile/P)
	heavy_knockback(M, P, 5)

/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	icon_state = "beanbag"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_IGNORE_RESIST
	sound_override = 'sound/weapons/gun_shotgun_small.ogg'

/datum/ammo/bullet/shotgun/beanbag/New()
	..()
	max_range = config.short_shell_range
	shrapnel_chance = 0
	damage = config.no_hit_damage
	stamina_damage = config.lhigh_hit_damage
	accuracy = config.med_hit_accuracy
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/shotgun/beanbag/on_hit_mob(mob/M, obj/item/projectile/P)
	if(!M || M == P.firer) return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		shake_camera(H, 2, 1)


/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	damage_type = BURN
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/shotgun/incendiary/New()
	..()
	accuracy = -config.low_hit_accuracy
	max_range = config.short_shell_range
	damage = config.med_hit_damage
	penetration= config.min_armor_penetration

/datum/ammo/bullet/shotgun/incendiary/on_hit_mob(mob/M,obj/item/projectile/P)
	burst(get_turf(M),P,damage_type)
	knockback(M,P)

/datum/ammo/bullet/shotgun/incendiary/on_hit_obj(obj/O,obj/item/projectile/P)
	burst(get_turf(P),P,damage_type)

/datum/ammo/bullet/shotgun/incendiary/on_hit_turf(turf/T,obj/item/projectile/P)
	burst(get_turf(T),P,damage_type)


/datum/ammo/bullet/shotgun/flechette
	name = "shotgun flechette shell"
	icon_state = "flechette"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/flechette_spread

/datum/ammo/bullet/shotgun/flechette/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	max_range = config.short_shell_range
	damage = config.lmed_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.low_proj_variance
	penetration	= config.hmed_armor_penetration
	bonus_projectiles_amount = config.low_proj_extra

/datum/ammo/bullet/shotgun/flechette_spread
	name = "additional flechette"
	icon_state = "flechette"

/datum/ammo/bullet/shotgun/flechette_spread/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	max_range = config.short_shell_range
	damage = config.low_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.low_proj_variance
	penetration	= config.hlow_armor_penetration
	scatter = config.hmed_scatter_value

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	icon_state = "buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread

/datum/ammo/bullet/shotgun/buckshot/New()
	..()
	accuracy_var_low = config.high_proj_variance
	accuracy_var_high = config.high_proj_variance
	accurate_range = config.min_shell_range
	max_range = config.close_shell_range - 1
	damage = config.mhigh_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.low_proj_variance
	damage_falloff = config.buckshot_v2_damage_falloff
	penetration	= 0
	bonus_projectiles_amount = config.low_proj_extra
	shell_speed = config.reg_shell_speed
	damage_armor_punch = 0
	pen_armor_punch = 0

/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/M,obj/item/projectile/P)
	knockback(M,P)

//buckshot variant only used by the masterkey shotgun attachment.
/datum/ammo/bullet/shotgun/buckshot/masterkey
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread/masterkey

/datum/ammo/bullet/shotgun/buckshot/masterkey/New()
	..()
	damage = config.high_hit_damage

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"

/datum/ammo/bullet/shotgun/spread/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	accurate_range = config.min_shell_range
	max_range = config.close_shell_range
	damage = config.mhigh_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.low_proj_variance
	damage_falloff = config.buckshot_v2_damage_falloff
	penetration = config.min_armor_penetration
	shell_speed = config.reg_shell_speed
	scatter = config.super_scatter_value
	damage_armor_punch = 0
	pen_armor_punch = 0

/datum/ammo/bullet/shotgun/spread/masterkey/New()
	..()
	damage = config.mlow_hit_damage


/*
//================================================
					Sniper Ammo
//================================================
*/

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER
	accurate_range_min = 4

/datum/ammo/bullet/sniper/New()
	..()
	accuracy = config.max_hit_accuracy
	accurate_range = config.max_shell_range
	max_range = config.max_shell_range
	scatter = 0
	damage = config.max_hit_damage
	penetration= config.max_armor_penetration
	shell_speed = config.ultra_shell_speed
	damage_falloff = 0

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary sniper bullet"
	accuracy = 0
	damage_type = BURN
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SNIPER|AMMO_IGNORE_COVER

/datum/ammo/bullet/sniper/incendiary/New()
	..()
	accuracy_var_high = config.med_proj_variance
	scatter = 0
	damage = config.mhigh_hit_damage
	penetration = config.low_armor_penetration

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	damage_type = BRUTE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IGNORE_COVER

/datum/ammo/bullet/sniper/flak/New()
	..()
	accuracy = config.max_hit_accuracy
	scatter = config.low_scatter_value
	damage = config.high_hit_damage
	damage_var_high = config.low_proj_variance
	penetration = 0

/datum/ammo/bullet/sniper/flak/on_hit_mob(mob/M,obj/item/projectile/P)
	burst(get_turf(M),P,damage_type, 2 , 2)
	burst(get_turf(M),P,damage_type, 1 , 2 , 0)

/datum/ammo/bullet/sniper/flak/on_near_target(turf/T, obj/item/projectile/P)
	burst(T,P,damage_type, 2 , 2)
	burst(T,P,damage_type, 1 , 2, 0)
	return 1

/datum/ammo/bullet/tank/flak
	name = "flak autocannon bullet"
	icon_state 	= "autocannon"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC
	accurate_range_min = 4

/datum/ammo/bullet/tank/flak/New()
	..()
	accuracy = config.max_hit_accuracy
	scatter = 0
	damage = config.mhigh_hit_damage
	damage_var_high = config.low_proj_variance
	penetration	= config.med_armor_penetration
	accurate_range = config.max_shell_range
	max_range = config.max_shell_range
	shell_speed = config.ultra_shell_speed

/datum/ammo/bullet/tank/flak/on_hit_mob(mob/M,obj/item/projectile/P)
	burst(get_turf(M),P,damage_type, 2 , 3)
	burst(get_turf(M),P,damage_type, 1 , 3 , 0)

/datum/ammo/bullet/tank/flak/on_near_target(turf/T, obj/item/projectile/P)
	burst(get_turf(T),P,damage_type, 2 , 3)
	burst(get_turf(T),P,damage_type, 1 , 3, 0)
	return 1

/datum/ammo/bullet/tank/flak/on_hit_obj(obj/O,obj/item/projectile/P)
	burst(get_turf(P),P,damage_type, 2 , 3)
	burst(get_turf(P),P,damage_type, 1 , 3 , 0)

/datum/ammo/bullet/tank/flak/on_hit_turf(turf/T,obj/item/projectile/P)
	burst(get_turf(T),P,damage_type, 2 , 3)
	burst(get_turf(T),P,damage_type, 1 , 3 , 0)

/datum/ammo/bullet/tank/flak/weak
	name = "dualcannon flak bullet"

/datum/ammo/bullet/tank/flak/weak/New()
	..()
	damage = config.lmed_hit_damage

/datum/ammo/bullet/sniper/svd
	name = "crude sniper bullet"

/datum/ammo/bullet/sniper/anti_tank
	name = "anti-tank sniper bullet"

/datum/ammo/bullet/sniper/anti_tank/New()
	..()
	accuracy = config.max_hit_accuracy
	damage = config.super_hit_damage
	shell_speed = config.ultra_shell_speed


/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"

/datum/ammo/bullet/sniper/elite/New()
	..()
	accuracy = config.max_hit_accuracy
	damage = config.super_hit_damage
	shell_speed = config.ultra_shell_speed + 1

/*
//================================================
					Special Ammo
//================================================
*/

/datum/ammo/bullet/smartgun
	name = "smartgun bullet"
	icon_state = "redbullet"
	flags_ammo_behavior = AMMO_BALLISTIC

/datum/ammo/bullet/smartgun/New()
	..()
	max_range = config.hshort_shell_range
	accuracy = config.med_hit_accuracy
	damage_falloff = config.tactical_damage_falloff
	damage = config.lmed_plus_hit_damage
	penetration = 0

/datum/ammo/bullet/smartgun/armor_piercing
	flags_ammo_behavior = AMMO_BALLISTIC
	icon_state = "bullet"

/datum/ammo/bullet/smartgun/armor_piercing/New()
	..()
	accurate_range = config.short_shell_range
	accuracy = config.min_hit_accuracy
	damage_falloff = config.tactical_damage_falloff
	damage = config.mlow_hit_damage
	penetration = config.hmed_armor_penetration
	damage_armor_punch = 1

/datum/ammo/bullet/smartgun/marine/armor_piercing
	icon_state = "bullet"

/datum/ammo/bullet/smartgun/marine/armor_piercing/New()
	..()
	accurate_range = config.short_shell_range
	accuracy = config.min_hit_accuracy
	damage_falloff = config.tactical_damage_falloff
	damage = config.mlow_hit_damage
	penetration = config.hmed_armor_penetration
	damage_armor_punch = 1

/datum/ammo/bullet/smartgun/dirty
	name = "irradiated smartgun bullet"
	debilitate = list(0,0,0,3,0,0,0,1)

/datum/ammo/bullet/smartgun/dirty/New()
	..()
	shrapnel_chance = config.max_shrapnel_chance
	accurate_range = config.long_shell_range
	accuracy = config.med_hit_accuracy
	damage_falloff = config.tactical_damage_falloff
	damage = config.hmed_hit_damage
	penetration = 0

/datum/ammo/bullet/smartgun/dirty/armor_piercing
	debilitate = list(0,0,0,3,0,0,0,1)

/datum/ammo/bullet/smartgun/dirty/armor_piercing/New()
	..()
	accurate_range = config.norm_shell_range
	accuracy = config.med_hit_accuracy
	damage_falloff = config.tactical_damage_falloff
	damage = config.med_hit_damage
	penetration = config.hmed_armor_penetration
	damage_armor_punch = 3


/datum/ammo/bullet/turret
	name = "autocannon bullet"
	icon_state 	= "redbullet" //Red bullets to indicate friendly fire restriction
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_IGNORE_COVER

/datum/ammo/bullet/turret/New()
	..()
	accurate_range = config.norm_shell_range
	accuracy_var_low = config.low_proj_variance
	accuracy_var_high = config.low_proj_variance
	max_range = config.norm_shell_range
	damage = config.lmed_hit_damage
	penetration = config.hmed_armor_penetration
	damage_armor_punch = 0
	pen_armor_punch = 0
	shell_speed = 2*config.ultra_shell_speed
	accuracy = config.high_hit_accuracy

/datum/ammo/bullet/turret/dumb
	icon_state 	= "bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state 	= "bullet" // Keeping it bog standard with the turret but allows it to be changed. Had to remove IFF so you have to watch out.

/datum/ammo/bullet/machinegun/New()
	..()
	accurate_range = config.short_shell_range
	damage = config.med_hit_damage
	penetration= config.mhigh_armor_penetration //Bumped the penetration to serve a different role from sentries, MGs are a bit more offensive
	accuracy = config.med_hit_accuracy

/datum/ammo/bullet/minigun
	name = "minigun bullet"

/datum/ammo/bullet/minigun/New()
	..()

	accuracy = -config.med_hit_accuracy
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	accurate_range = config.hshort_shell_range
	damage = config.lmed_plus_hit_damage

	penetration = config.hmed_armor_penetration

/datum/ammo/bullet/m60
	name = "M60 bullet"

/datum/ammo/bullet/m60/New()
	..()
	accuracy = -config.med_hit_accuracy
	accuracy_var_low = config.low_proj_variance
	accuracy_var_high = config.med_proj_variance
	accurate_range = config.short_shell_range
	damage = config.low_hit_damage
	penetration= config.med_armor_penetration
	shrapnel_chance = config.med_shrapnel_chance

/*
//================================================
					Rocket Ammo
//================================================
*/

/datum/ammo/rocket
	name = "high explosive rocket"
	icon_state = "missile"
	ping = null //no bounce off.
	sound_bounce	= "rocket_bounce"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_STRIKES_SURFACE
	var/datum/effect_system/smoke_spread/smoke

/datum/ammo/rocket/New()
	..()
	smoke = new()
	accuracy = config.low_hit_accuracy
	accurate_range = config.norm_shell_range
	max_range = config.long_shell_range
	damage = config.min_hit_damage
	shell_speed = config.slow_shell_speed

/datum/ammo/rocket/Destroy()
	qdel(smoke)
	smoke = null
	. = ..()

/datum/ammo/rocket/on_hit_mob(mob/M, obj/item/projectile/P)
	cell_explosion(get_turf(M), 200, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, get_turf(M))
	if(isHumanStrict(M)) // No yautya or synths. Makes humans gib on direct hit.
		M.ex_act(350, P.dir, P.weapon_source, P.weapon_source_mob, 100)
	smoke.start()

/datum/ammo/rocket/on_hit_obj(obj/O, obj/item/projectile/P)
	cell_explosion(get_turf(O), 200, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, get_turf(O))
	smoke.start()

/datum/ammo/rocket/on_hit_turf(turf/T, obj/item/projectile/P)
	cell_explosion(T, 200, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/do_at_max_range(obj/item/projectile/P)
	cell_explosion(get_turf(P), 200, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, get_turf(P))
	smoke.start()

/datum/ammo/rocket/ap
	name = "anti-armor rocket"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/ap/New()
	..()
	accuracy = config.max_hit_accuracy
	accuracy_var_low = config.min_proj_variance
	accurate_range = config.near_shell_range
	max_range = config.norm_shell_range
	damage = config.base_hit_damage
	penetration= config.max_armor_penetration

/datum/ammo/rocket/ap/on_hit_mob(mob/M, obj/item/projectile/P)
	var/turf/T = get_turf(M)
	M.ex_act(150, P.dir, P.weapon_source, P.weapon_source_mob, 100)
	M.KnockDown(2)
	M.KnockOut(2)
	if(isHumanStrict(M)) // No yautya or synths. Makes humans gib on direct hit.
		M.ex_act(350, P.dir, P.weapon_source, P.weapon_source_mob, 100)
	cell_explosion(T, 100, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/ap/on_hit_obj(obj/O, obj/item/projectile/P)
	var/turf/T = get_turf(O)
	O.ex_act(150, P.dir, P.weapon_source, P.weapon_source_mob, 100)
	cell_explosion(T, 100, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/ap/on_hit_turf(turf/T, obj/item/projectile/P)
	var/hit_something = 0
	for(var/mob/M in T)
		M.ex_act(150, P.dir, P.weapon_source, P.weapon_source_mob, 100)
		M.KnockDown(4)
		M.KnockOut(4)
		hit_something = 1
		continue
	if(!hit_something)
		for(var/obj/O in T)
			if(O.density)
				O.ex_act(150, P.dir, P.weapon_source, P.weapon_source_mob, 100)
				hit_something = 1
				continue
	if(!hit_something)
		T.ex_act(150, P.dir, P.weapon_source, P.weapon_source_mob, 200)

	cell_explosion(T, 100, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/ap/do_at_max_range(obj/item/projectile/P)
	var/turf/T = get_turf(P)
	var/hit_something = 0
	for(var/mob/M in T)
		M.ex_act(250, P.dir, P.weapon_source, P.weapon_source_mob, 100)
		M.KnockDown(2)
		M.KnockOut(2)
		hit_something = 1
		continue
	if(!hit_something)
		for(var/obj/O in T)
			if(O.density)
				O.ex_act(250, P.dir, P.weapon_source, P.weapon_source_mob, 100)
				hit_something = 1
				continue
	if(!hit_something)
		T.ex_act(250, P.dir, P.weapon_source, P.weapon_source_mob)
	cell_explosion(T, 100, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/ltb
	name = "cannon round"
	icon_state = "ltb"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_STRIKES_SURFACE

/datum/ammo/rocket/ltb/New()
	..()
	accuracy = config.med_hit_accuracy
	accurate_range = config.long_shell_range
	max_range = config.max_shell_range
	damage = config.low_hit_damage
	shell_speed = config.fast_shell_speed

/datum/ammo/rocket/ltb/on_hit_mob(mob/M, obj/item/projectile/P)
	cell_explosion(get_turf(M), 220, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	cell_explosion(get_turf(M), 200, 100, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/ltb/on_hit_obj(obj/O, obj/item/projectile/P)
	cell_explosion(get_turf(O), 220, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	cell_explosion(get_turf(O), 200, 100, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/ltb/on_hit_turf(turf/T, obj/item/projectile/P)
	cell_explosion(get_turf(T), 220, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	cell_explosion(get_turf(T), 200, 100, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/ltb/do_at_max_range(obj/item/projectile/P)
	cell_explosion(get_turf(P), 220, 50, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)
	cell_explosion(get_turf(P), 200, 100, EXPLOSION_FALLOFF_SHAPE_LINEAR, null, P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_INCENDIARY|AMMO_EXPLOSIVE|AMMO_STRIKES_SURFACE
	damage_type = BURN

/datum/ammo/rocket/wp/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accurate_range = config.short_shell_range
	damage = config.super_hit_damage
	max_range = config.norm_shell_range

/datum/ammo/rocket/wp/drop_flame(turf/T, var/source, var/source_mob)
	playsound(T, 'sound/weapons/gun_flamethrower3.ogg', 75, 1, 7)
	if(!istype(T)) return
	smoke.set_up(1, T)
	smoke.start()
	var/datum/reagent/napalm/blue/R = new()
	new /obj/flamer_fire(T, source, source_mob, R, 3)

	var/datum/effect_system/smoke_spread/phosphorus/landingSmoke = new /datum/effect_system/smoke_spread/phosphorus
	landingSmoke.set_up(3, 0, T, null, 6)
	landingSmoke.start()
	landingSmoke = null

	var/shard_type = /datum/ammo/bullet/shrapnel/incendiary
	var/shard_amount = 12
	create_shrapnel(T, shard_amount, , ,shard_type, source, source_mob)


/datum/ammo/rocket/wp/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/rocket/wp/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/rocket/wp/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T)

/datum/ammo/rocket/wp/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_STRIKES_SURFACE

/datum/ammo/rocket/wp/quad/New()
	..()
	damage = config.ultra_hit_damage
	max_range = config.long_shell_range

/datum/ammo/rocket/wp/quad/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M))
	explosion(P.loc,  -1, 2, 4, 5, , , ,P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/wp/quad/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O))
	explosion(P.loc,  -1, 2, 4, 5, , , ,P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/wp/quad/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T)
	explosion(P.loc,  -1, 2, 4, 5, , , ,P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/wp/quad/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P))
	explosion(P.loc,  -1, 2, 4, 5, , , ,P.weapon_source, P.weapon_source_mob)

/datum/ammo/rocket/custom
	name = "custom rocket"

/datum/ammo/rocket/custom/proc/prime(atom/A, obj/item/projectile/P)
	var/obj/item/weapon/gun/launcher/rocket/launcher = P.shot_from
	var/obj/item/ammo_magazine/rocket/custom/rocket = launcher.current_mag
	if(rocket.locked && rocket.warhead && rocket.warhead.detonator)
		if(rocket.fuel && rocket.fuel.reagents.get_reagent_amount(rocket.fuel_type) >= rocket.fuel_requirement)
			rocket.loc = P.loc
		rocket.warhead.prime()
		qdel(rocket)
	smoke.set_up(1, get_turf(A))
	smoke.start()

/datum/ammo/rocket/custom/on_hit_mob(mob/M, obj/item/projectile/P)
	prime(M, P)

/datum/ammo/rocket/custom/on_hit_obj(obj/O, obj/item/projectile/P)
	prime(O, P)

/datum/ammo/rocket/custom/on_hit_turf(turf/T, obj/item/projectile/P)
	prime(T, P)

/datum/ammo/rocket/custom/do_at_max_range(obj/item/projectile/P)
	prime(null, P)

/*
//================================================
					Energy Ammo
//================================================
*/

/datum/ammo/energy
	ping = null //no bounce off. We can have one later.
	sound_hit 	 	= "energy_hit"
	sound_miss		= "energy_miss"
	sound_bounce	= "energy_bounce"

	damage_type = BURN
	flags_ammo_behavior = AMMO_ENERGY

/datum/ammo/energy/New()
	..()
	accuracy = config.hmed_hit_accuracy

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_ARMOR

/datum/ammo/energy/emitter/New()
	..()
	accurate_range 	= config.near_shell_range
	max_range 		= config.near_shell_range

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	damage_type = OXY
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST|AMMO_ALWAYS_FF //Not that ignoring will do much right now.

/datum/ammo/energy/taser/New()
	..()
	stamina_damage = config.high_hit_damage
	accuracy = config.max_hit_accuracy
	shell_speed = config.slow_shell_speed // Slightly faster

/datum/ammo/energy/taser/on_hit_mob(mob/M, obj/item/projectile/P)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.disable_special_items() // Disables scout cloak

/datum/ammo/energy/yautja/New()
	..()
	accurate_range = config.short_shell_range
	shell_speed = config.fast_shell_speed

/datum/ammo/energy/yautja/pistol
	name = "plasma pistol bolt"
	icon_state = "ion"
	flags_ammo_behavior = AMMO_ENERGY

/datum/ammo/energy/yautja/pistol/New()
	..()
	damage = config.lmed_hit_damage
	shell_speed = config.reg_shell_speed

/datum/ammo/energy/yautja/caster/bolt
	name = "plasma bolt"
	icon_state = "ion"
	debilitate = list(2,2,0,0,0,1,0,0)
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST

/datum/ammo/energy/yautja/caster/bolt/New()
	..()
	damage = config.base_hit_damage

/datum/ammo/energy/yautja/caster/blast
	name = "plasma blast"
	icon_state = "pulse1"

/datum/ammo/energy/yautja/caster/blast/New()
	..()
	damage = config.low_hit_damage
	shell_speed = config.ultra_shell_speed

/datum/ammo/energy/yautja/caster/sphere
	name = "plasma eradication sphere"
	icon_state = "bluespace"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ENERGY|AMMO_HITS_TARGET_TURF
	var/stun_range = 4 // Big
	var/stun_time = 6

/datum/ammo/energy/yautja/caster/sphere/New()
	..()
	damage = 0
	shell_speed = config.super_shell_speed
	accuracy = config.max_hit_accuracy
	accurate_range = config.max_shell_range
	max_range = config.long_shell_range


/datum/ammo/energy/yautja/caster/sphere/on_hit_mob(mob/M,obj/item/projectile/P)
	do_area_stun(P)
	..()

/datum/ammo/energy/yautja/caster/sphere/on_hit_turf(turf/T,obj/item/projectile/P)
	do_area_stun(P)
	..()

/datum/ammo/energy/yautja/caster/sphere/on_hit_obj(obj/O,obj/item/projectile/P)
	do_area_stun(P)
	..()

/datum/ammo/energy/yautja/caster/sphere/do_at_max_range(obj/item/projectile/P)
	do_area_stun(P)
	..()

/datum/ammo/energy/yautja/caster/sphere/proc/do_area_stun(obj/item/projectile/P)
	playsound(P, 'sound/weapons/wave.ogg', 75, 1, 25)
	for (var/mob/living/carbon/M in view(src.stun_range, get_turf(P)))
		var/stun_time = src.stun_time
		if (isYautja(M))
			stun_time -= 2
		else if (isXeno(M))
			if(isXenoPredalien(M))
				continue
			stun_time += 1
		to_chat(M, SPAN_DANGER("A powerful electric shock ripples through your body, freezing you in place!"))
		M.stunned += stun_time

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.KnockDown(stun_time)
		else
			M.KnockDown(stun_time, 1)




/datum/ammo/energy/yautja/rifle/bolt
	name = "plasma rifle bolt"
	icon_state = "ion"
	debilitate = list(0,2,0,0,0,0,0,0)
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST

/datum/ammo/energy/yautja/rifle/bolt/New()
	..()
	damage = config.high_hit_damage

/datum/ammo/energy/yautja/rifle/blast
	name = "plasma rifle blast"
	icon_state = "bluespace"

/datum/ammo/energy/yautja/rifle/blast/New()
	..()
	shell_speed = config.super_shell_speed
	damage = config.hmed_hit_damage

/datum/ammo/energy/yautja/rifle/blast/on_hit_mob(mob/M,obj/item/projectile/P)
	knockback(M,P)
	playsound(M.loc, 'sound/weapons/pulse.ogg', 25, 1)
	explosion(get_turf(M), -1, -1, 2, -1, P.weapon_source, P.weapon_source_mob)

/datum/ammo/energy/yautja/rifle/blast/on_hit_turf(turf/T,obj/item/projectile/P)
	explosion(T, -1, -1, 2, -1, P.weapon_source, P.weapon_source_mob)

/datum/ammo/energy/yautja/rifle/blast/on_hit_obj(obj/O,obj/item/projectile/P)
	explosion(get_turf(P), -1, -1, 2, -1, P.weapon_source, P.weapon_source_mob)


/*
//================================================
					Xeno Spits
//================================================
*/
/datum/ammo/xeno
	icon_state = "neurotoxin"
	ping = "ping_x"
	damage_type = TOX
	flags_ammo_behavior = AMMO_XENO_ACID
	var/added_spit_delay = 0 //used to make cooldown of the different spits vary.
	var/spit_cost

/datum/ammo/xeno/New()
	..()
	accuracy = config.max_hit_accuracy*2
	max_range = config.short_shell_range

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_IGNORE_RESIST
	spit_cost = 25
	var/effect_power = 1.75

/proc/apply_neuro(mob/M, power, insta_neuro)
	var/pass_down_the_line = FALSE
	if(isSynth(M) || isYautja(M))
		return // unaffected
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.chem_effect_flags & CHEM_EFFECT_RESIST_NEURO)
			return

	if(M.knocked_out || pass_down_the_line) //second part is always false, but consistency is a great thing
		pass_down_the_line = TRUE

	if(!isXeno(M))		
		if(insta_neuro)
			if(M.knocked_down < 3)
				M.AdjustKnockeddown(1 * power)
			return

		if(M.knocked_down>4 || pass_down_the_line)
			if(!pass_down_the_line)
				M.visible_message(SPAN_DANGER("[M] falls limp on the ground."))
			M.KnockOut(30) //KO them. They already got rekt too much
			pass_down_the_line = TRUE
		
		var/no_clothes_neuro = FALSE

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.wear_suit || H.wear_suit.slowdown == 0)
				no_clothes_neuro = TRUE

		if(M.dazed || pass_down_the_line || no_clothes_neuro)
			if(M.knocked_down < 5)
				M.AdjustKnockeddown(1 * power) // KD them a bit more
				if(!pass_down_the_line)
					M.visible_message(SPAN_DANGER("[M] falls prone."))
			pass_down_the_line = TRUE

		if(M.superslowed || pass_down_the_line)
			if(M.dazed < 6)
				M.AdjustDazed(3 * power) // Daze them a bit more
				if(!pass_down_the_line)
					M.visible_message(SPAN_DANGER("[M] is visibly confused."))
			pass_down_the_line = TRUE

	if(M.superslowed < 10)
		M.AdjustSuperslowed(3 * power) // Superslow them a bit more
		if(!pass_down_the_line)
			M.visible_message(SPAN_DANGER("[M] movements are slowed."))

/proc/neuro_flak(turf/T,obj/item/projectile/P , power, insta_neuro, radius)
	if(!T) return FALSE
	var/firer = P.firer
	var/hit_someone = FALSE
	for(var/mob/living/carbon/M in orange(radius,T))
		if(isXeno(M) && isXeno(firer) && M:hivenumber == firer:hivenumber)
			continue

		if(istype(M.buckled, /obj/structure/bed/nest))
			continue

		hit_someone = TRUE
		apply_neuro(M, power, insta_neuro)

		P.play_damage_effect(M)

	return hit_someone

/datum/ammo/xeno/toxin/on_hit_mob(mob/M,obj/item/projectile/P)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.status_flags & XENO_HOST)
			apply_neuro(H, effect_power, TRUE)
			return

	apply_neuro(M, effect_power, FALSE)

/datum/ammo/xeno/toxin/New()
	..()
	shell_speed = config.reg_shell_speed
	max_range = config.near_shell_range

/datum/ammo/xeno/toxin/medium //Spitter
	name = "neurotoxic spatter"
	spit_cost = 50
	effect_power = 1

/datum/ammo/xeno/toxin/queen
	name = "neurotoxic spit"
	spit_cost = 50
	effect_power = 2

/datum/ammo/xeno/toxin/queen/New()
	..()
	accuracy = config.high_hit_accuracy*2
	max_range = config.near_shell_range - 1

/datum/ammo/xeno/toxin/queen/on_hit_mob(mob/M,obj/item/projectile/P)
	apply_neuro(M, effect_power, TRUE)


/datum/ammo/xeno/toxin/medium/New()
	..()
	shell_speed = config.fast_shell_speed

/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	effect_power = 1.5
	spit_cost = 50


/datum/ammo/xeno/toxin/burst //sentinel burst
	name = "neurotoxic air splash"
	effect_power = 1
	spit_cost = 50
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_IGNORE_RESIST

/datum/ammo/xeno/toxin/shotgun
	name = "neurotoxic droplet"
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_IGNORE_RESIST
	spit_cost = 30
	added_spit_delay = 15
	effect_power = 1.5
	bonus_projectiles_type = /datum/ammo/xeno/toxin/shotgun/additional

/datum/ammo/xeno/toxin/shotgun/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	accurate_range = config.close_shell_range
	max_range = config.close_shell_range
	scatter = config.giga_scatter_value
	bonus_projectiles_amount = config.low_proj_extra

/datum/ammo/xeno/toxin/shotgun/additional
	name = "additional neurotoxic droplets"
	effect_power = 1.5

/datum/ammo/xeno/toxin/shotgun/additional/New()
	..()
	bonus_projectiles_amount = 0

/datum/ammo/xeno/toxin/burst/on_hit_mob(mob/M, obj/item/projectile/P)
	if(isXeno(M) && isXeno(P.firer) && M:hivenumber == P.firer:hivenumber)
		apply_neuro(M, effect_power*1.5, TRUE)

	neuro_flak(get_turf(M), P, effect_power, FALSE, 1)

/datum/ammo/xeno/toxin/burst/on_near_target(turf/T, obj/item/projectile/P)
	return neuro_flak(T,P, effect_power, FALSE, 1)

/datum/ammo/xeno/sticky
	name = "sticky resin spit"
	icon_state = "sticky"
	ping = null
	flags_ammo_behavior = AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE
	added_spit_delay = 5
	spit_cost = 40

/datum/ammo/xeno/sticky/New()
	..()
	shell_speed = config.fast_shell_speed
	accuracy_var_high = config.max_proj_variance
	max_range = config.max_shell_range

/datum/ammo/xeno/sticky/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_resin(T)

/datum/ammo/xeno/sticky/do_at_max_range(obj/item/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/proc/drop_resin(turf/T)
	if(T.density)
		return

	for(var/obj/O in T.contents)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			return
		if(istype(O, /obj/effect/alien/egg))
			return
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/effect/alien/resin) || istype(O, /obj/structure/bed))
			return
		if(O.density && !(O.flags_atom & ON_BORDER))
			return

	new /obj/effect/alien/resin/sticky/thin(T)





/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	damage_type = BURN
	added_spit_delay = 10
	spit_cost = 100

/datum/ammo/xeno/acid/New()
	..()
	accuracy = config.med_hit_accuracy
	damage = config.low_hit_damage
	penetration = config.mlow_armor_penetration
	shell_speed = config.reg_shell_speed

/datum/ammo/xeno/acid/on_shield_block(mob/M, obj/item/projectile/P)
	burst(M,P,damage_type)

/datum/ammo/xeno/acid/on_hit_mob(mob/M, obj/item/projectile/P)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.status_flags & XENO_HOST && istype(C.buckled, /obj/structure/bed/nest) || C.stat == DEAD)
			return
	..()

/datum/ammo/xeno/acid/medium
	name = "acid spatter"

/datum/ammo/xeno/acid/medium/New()
	..()
	damage = 20
	shell_speed = config.fast_shell_speed
	accuracy = config.high_hit_accuracy*3
	max_range = config.near_shell_range

/datum/ammo/xeno/acid/praetorian
	name = "acid splash"

/datum/ammo/xeno/acid/praetorian/New()
	..()
	damage_falloff = config.med_damage_falloff
	accuracy = config.high_hit_accuracy*3
	max_range = config.near_shell_range
	damage = config.hlow_hit_damage
	damage_var_low = config.med_proj_variance
	damage_var_high = config.low_proj_variance
	shell_speed = config.reg_shell_speed
	added_spit_delay = 0

/datum/ammo/xeno/acid/dot
	name = "acid spit"

/datum/ammo/xeno/acid/prae_nade // Used by base prae's acid nade
	name = "acid spatter"

/datum/ammo/xeno/acid/prae_nade/New()
	..()
	accuracy = config.high_hit_accuracy
	accurate_range = config.max_shell_range
	max_range = config.close_shell_range - 1
	damage = config.hlmed_hit_damage
	damage_falloff = config.buckshot_damage_falloff
	shell_speed = config.slow_shell_speed
	scatter = config.med_scatter_value

/datum/ammo/xeno/acid/prae_nade/on_hit_mob(mob/M, obj/item/projectile/P)
	if (!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	var/datum/effects/prae_acid_stacks/PAS = null 
	for (var/datum/effects/prae_acid_stacks/prae_acid_stacks in H.effects_list)
		PAS = prae_acid_stacks
		break

	if (PAS == null)
		PAS = new /datum/effects/prae_acid_stacks(H)
	else
		PAS.increment_stack_count()

/datum/ammo/xeno/prae_skillshot
	name = "blob of acid"
	icon_state = "boiler_gas2"
	ping = "ping_x"
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_IGNORE_RESIST

/datum/ammo/xeno/prae_skillshot/New()
	..()
	accuracy = config.high_hit_accuracy
	accurate_range = config.max_shell_range
	max_range = config.close_shell_range + 2
	damage = config.mlow_hit_damage
	damage_falloff = config.reg_damage_falloff
	shell_speed = config.slow_shell_speed
	scatter = config.min_scatter_value

/datum/ammo/xeno/prae_skillshot/on_hit_mob(mob/M, obj/item/projectile/P)
	acid_stacks_aoe(get_turf(P))

/datum/ammo/xeno/prae_skillshot/on_hit_obj(obj/O, obj/item/projectile/P)
	acid_stacks_aoe(get_turf(P))

/datum/ammo/xeno/prae_skillshot/on_hit_turf(turf/T, obj/item/projectile/P)
	acid_stacks_aoe(get_turf(P))

/datum/ammo/xeno/prae_skillshot/do_at_max_range(obj/item/projectile/P)
	acid_stacks_aoe(get_turf(P))

/datum/ammo/xeno/prae_skillshot/proc/acid_stacks_aoe(var/turf/T)

	if (!istype(T))
		return

	for (var/mob/living/carbon/human/H in orange(1, T))
		to_chat(H, SPAN_XENODANGER("You are spattered with acid!"))
		animation_flash_color(H)
		var/datum/effects/prae_acid_stacks/PAS = null 
		for (var/datum/effects/prae_acid_stacks/prae_acid_stacks in H.effects_list)
			PAS = prae_acid_stacks
			break

		if (PAS == null)
			PAS = new /datum/effects/prae_acid_stacks(H)
			PAS.increment_stack_count()
		else
			PAS.increment_stack_count()
			PAS.increment_stack_count()

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "boiler_gas2"
	ping = "ping_x"
	debilitate = list(19,21,0,0,11,12,0,0)
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_IGNORE_RESIST
	var/datum/effect_system/smoke_spread/smoke_system

/datum/ammo/xeno/boiler_gas/New()
	..()
	set_xeno_smoke()
	accuracy_var_high = config.max_proj_variance
	max_range = config.long_shell_range

/datum/ammo/xeno/boiler_gas/Destroy()
	qdel(smoke_system)
	smoke_system = null
	. = ..()

/datum/ammo/xeno/boiler_gas/on_hit_mob(mob/M, obj/item/projectile/P)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.status_flags & XENO_HOST && istype(C.buckled, /obj/structure/bed/nest) || C.stat == DEAD)
			return
	drop_nade(get_turf(P), P)

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/O, obj/item/projectile/P)
	drop_nade(get_turf(P), P)

/datum/ammo/xeno/boiler_gas/on_hit_turf(turf/T, obj/item/projectile/P)
	if(T.density && isturf(P.loc))
		drop_nade(P.loc, P) //we don't want the gas globs to land on dense turfs, they block smoke expansion.
	else
		drop_nade(T, P)

/datum/ammo/xeno/boiler_gas/do_at_max_range(obj/item/projectile/P)
	drop_nade(get_turf(P), P)

/datum/ammo/xeno/boiler_gas/proc/set_xeno_smoke(obj/item/projectile/P)
	smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()

/datum/ammo/xeno/boiler_gas/proc/drop_nade(turf/T, obj/item/projectile/P)
	var/amount = 4
	var/lifetime_mult = 1.0
	if(isXenoBoiler(P.firer))
		smoke_system.source = P.weapon_source
		smoke_system.source_mob = P.weapon_source_mob
	smoke_system.set_up(amount, 0, T)
	smoke_system.lifetime = 12 * lifetime_mult
	smoke_system.start()
	T.visible_message(SPAN_DANGER("A glob of acid lands with a splat and explodes into noxious fumes!"))


/datum/ammo/xeno/bone_chips
	name = "bone chips"
	icon_state = "shrapnel_light"
	ping = null
	flags_ammo_behavior = AMMO_SKIPS_ALIENS|AMMO_STOPPED_BY_COVER|AMMO_IGNORE_ARMOR
	bonus_projectiles_type = /datum/ammo/xeno/bone_chips/spread

/datum/ammo/xeno/bone_chips/on_hit_mob(mob/M, obj/item/projectile/P)
	if(isHumanStrict(M) || isXeno(M))
		playsound(M, 'sound/effects/spike_hit.ogg', 25, 1, 1)
		if(M.slowed < 7)
			M.AdjustSlowed(6)

/datum/ammo/xeno/bone_chips/New()
	..()
	damage = 5
	max_range = 5
	damage_type = BRUTE
	accuracy = config.max_hit_accuracy
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	bonus_projectiles_amount = config.high_proj_extra
	shrapnel_type = /obj/item/shard/shrapnel/bone_chips
	shrapnel_chance = 60

/datum/ammo/xeno/bone_chips/spread
	name = "small bone chips"

/datum/ammo/xeno/bone_chips/spread/New()
	..()
	scatter = 30 // We want a wild scatter angle
	max_range = 5
	bonus_projectiles_amount = 0

/datum/ammo/xeno/bone_chips/spread/short_range
    name = "small bone chips"

/datum/ammo/xeno/bone_chips/spread/short_range/New()
    ..()
    max_range = 3 // Very short range

/datum/ammo/xeno/bone_chips/spread/runner_skillshot
    name = "bone chips"

/datum/ammo/xeno/bone_chips/spread/runner_skillshot/New()
    ..()
    scatter = 0
    max_range = 5
    damage = 10
    shrapnel_chance = 0    

/datum/ammo/xeno/bone_chips/spread/runner/on_hit_mob(mob/M, obj/item/projectile/P)
    if(isHumanStrict(M) || isXeno(M))
        playsound(M, 'sound/effects/spike_hit.ogg', 25, 1, 1)
        if(M.slowed < 5)
            M.AdjustSlowed(4)

/*
//================================================
					Shrapnel
//================================================
*/
/datum/ammo/bullet/shrapnel
	name = "shrapnel"
	icon_state = "buckshot"
	accurate_range_min = 5
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_STOPPED_BY_COVER

/datum/ammo/bullet/shrapnel/New()
	..()
	accuracy = config.med_hit_accuracy
	accurate_range = config.max_shell_range
	max_range = 7
	damage = config.hlmed_hit_damage
	damage_var_low = -config.med_proj_variance
	damage_var_high = config.med_proj_variance
	damage_falloff = config.reg_damage_falloff
	penetration = config.low_armor_penetration
	shell_speed = config.reg_shell_speed
	shrapnel_chance = 5

/datum/ammo/bullet/shrapnel/on_hit_obj(obj/O, obj/item/projectile/P)
	if(istype(O, /obj/structure/barricade))
		var/obj/structure/barricade/B = O
		B.health -= rand(2, 5)
		B.update_health(1)

/datum/ammo/bullet/shrapnel/incendiary
	name = "flaming shrapnel"
	icon_state = "beanbag" // looks suprisingly a lot like flaming shrapnel chunks
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_STOPPED_BY_COVER

/datum/ammo/bullet/shrapnel/incendiary/New()
	..()
	shell_speed = config.slow_shell_speed
	damage = config.mlow_hit_damage
	penetration = config.low_armor_penetration

/datum/ammo/bullet/shrapnel/light // weak shrapnel
	name = "light shrapnel"
	icon_state = "shrapnel_light"

/datum/ammo/bullet/shrapnel/light/New()
	..()
	damage = config.base_hit_damage
	penetration = config.min_armor_penetration
	shell_speed = config.slow_shell_speed
	shrapnel_chance = 0

/datum/ammo/bullet/shrapnel/light/human
	name = "human bone fragments"
	icon_state = "shrapnel_human"

/datum/ammo/bullet/shrapnel/light/human/New()
	..()
	shrapnel_chance = 50
	shrapnel_type = /obj/item/shard/shrapnel/bone_chips/human

/datum/ammo/bullet/shrapnel/light/human/var1 // sprite variants
	icon_state = "shrapnel_human1"

/datum/ammo/bullet/shrapnel/light/human/var2 // sprite variants
	icon_state = "shrapnel_human2"

/datum/ammo/bullet/shrapnel/light/xeno
	name = "alien bone fragments"
	icon_state = "shrapnel_xeno"

/datum/ammo/bullet/shrapnel/light/xeno/New()
	..()
	shrapnel_chance = 50
	shrapnel_type = /obj/item/shard/shrapnel/bone_chips/xeno

/datum/ammo/bullet/shrapnel/spall // weak shrapnel
	name = "spall"
	icon_state = "shrapnel_light"

/datum/ammo/bullet/shrapnel/spall/New()
	..()
	damage = config.base_hit_damage
	penetration = config.min_armor_penetration
	shell_speed = config.slow_shell_speed
	shrapnel_chance = 0

/datum/ammo/bullet/shrapnel/light/glass
	name = "glass shrapnel"
	icon_state = "shrapnel_glass"

/datum/ammo/bullet/shrapnel/light/effect/ // no damage, but looks bright and neat
	name = "sparks"

/datum/ammo/bullet/shrapnel/light/effect/ver1
	icon_state = "shrapnel_bright1"

/datum/ammo/bullet/shrapnel/light/effect/ver2
	icon_state = "shrapnel_bright2"

/datum/ammo/bullet/shrapnel/light/effect/New()
	..()
	damage = 1 // Tickle tickle

/*
//================================================
					Misc Ammo
//================================================
*/

/datum/ammo/alloy_spike
	name = "alloy spike"
	ping = "ping_s"
	icon_state = "MSpearFlight"
	sound_hit 	 	= "alloy_hit"
	sound_armor	 	= "alloy_armor"
	sound_bounce	= "alloy_bounce"

/datum/ammo/alloy_spike/New()
	..()
	accuracy = config.max_hit_accuracy
	accurate_range = config.short_shell_range
	max_range = config.short_shell_range
	damage = config.lmed_hit_damage
	penetration= config.high_armor_penetration
	shrapnel_chance = config.max_shrapnel_chance

/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR

/datum/ammo/flamethrower/New()
	..()
	max_range = config.close_shell_range
	damage = config.med_hit_damage

/datum/ammo/flamethrower/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/flamethrower/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/flamethrower/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T)

/datum/ammo/flamethrower/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/tank_flamer/drop_flame(var/turf/T, var/source, var/source_mob)
	if(!istype(T)) 
		return
	if(locate(/obj/flamer_fire) in T) 
		return
	var/datum/reagent/napalm/blue/R = new()
	new /obj/flamer_fire(T, source, source_mob, R, 2)

/datum/ammo/flamethrower/sentry_flamer
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR|AMMO_IGNORE_COVER

/datum/ammo/flamethrower/sentry_flamer/New()
	..()
	accuracy = config.max_hit_accuracy
	accurate_range = config.near_shell_range
	max_range = config.short_shell_range
	shell_speed = config.fast_shell_speed

/datum/ammo/flamethrower/sentry_flamer/drop_flame(var/turf/T, var/source, var/source_mob)
	if(!istype(T)) 
		return
	var/datum/reagent/napalm/blue/R = new()
	new /obj/flamer_fire(T, source, source_mob, R, 0)

/datum/ammo/flare
	name = "flare"
	ping = null //no bounce off.
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_HITS_TARGET_TURF

/datum/ammo/flare/New()
	..()
	damage = config.min_hit_damage
	accuracy = config.med_hit_accuracy
	max_range = 13
	shell_speed = config.fast_shell_speed

/datum/ammo/flare/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flare(get_turf(P))

/datum/ammo/flare/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flare(get_turf(P))

/datum/ammo/flare/on_hit_turf(turf/T, obj/item/projectile/P)
	if(T.density && isturf(P.loc))
		drop_flare(P.loc)
	else
		drop_flare(T)

/datum/ammo/flare/do_at_max_range(obj/item/projectile/P)
	drop_flare(get_turf(P))

/datum/ammo/flare/proc/drop_flare(var/turf/T)
	var/obj/item/device/flashlight/flare/on/G = new (T)
	G.visible_message(SPAN_WARNING("\A [G] bursts into brilliant light nearby!"))

/datum/ammo/souto/
	name = "Souto Can"
	ping = null //no bounce off.
	damage_type = BRUTE
	shrapnel_type = /obj/item/reagent_container/food/drinks/cans/souto/classic
	flags_ammo_behavior = AMMO_SKIPS_ALIENS|AMMO_IGNORE_ARMOR|AMMO_IGNORE_RESIST|AMMO_BALLISTIC|AMMO_STOPPED_BY_COVER|AMMO_SPECIAL_EMBED
	var/obj/item/reagent_container/food/drinks/cans/souto/can_type
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = "souto_classic"

/datum/ammo/souto/New()
	..()
	max_range = config.short_shell_range
	shrapnel_chance = 10
	accuracy = config.max_hit_accuracy + config.max_hit_accuracy
	accurate_range = config.short_shell_range
	shell_speed = config.slow_shell_speed

/datum/ammo/souto/on_embed(var/mob/embedded_mob, var/obj/limb/target_organ)
	if(ishuman(embedded_mob) && !isYautja(embedded_mob))
		if(istype(target_organ))
			target_organ.embed(new can_type)

/datum/ammo/souto/on_hit_mob(mob/M, obj/item/projectile/P)
	if(!M || M == P.firer) return
	if(M.throw_mode && !M.get_active_hand())	//empty active hand and we're in throw mode. If so we catch the can.
		if(!M.is_mob_incapacitated()) // People who are not able to catch cannot catch.
			if(P.contents.len == 1)
				for(var/obj/item/reagent_container/food/drinks/cans/souto/S in P.contents)
					M.put_in_active_hand(S)
					for(var/mob/O in viewers(world_view_size, P)) //find all people in view.
						O.show_message(SPAN_DANGER("[M] catches the [S]!"), 1) //Tell them the can was caught.
					return //Can was caught.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == "Human") //no effect on synths or preds.
			H.apply_effect(6, STUN)
			H.apply_effect(8, WEAKEN)
			H.apply_effect(15, DAZE)
			H.apply_effect(15, SLOW)
		shake_camera(H, 2, 1)
		if(P.contents.len)
			drop_can(P.loc, P) //We make a can at the location.

/datum/ammo/souto/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_can(P.loc, P) //We make a can at the location.

/datum/ammo/souto/on_hit_turf(turf/T, obj/item/projectile/P)
	drop_can(P.loc, P) //We make a can at the location.

/datum/ammo/souto/do_at_max_range(obj/item/projectile/P)
	drop_can(P.loc, P) //We make a can at the location.

/datum/ammo/souto/on_shield_block(mob/M, obj/item/projectile/P)
	drop_can(P.loc, P) //We make a can at the location.

/datum/ammo/souto/proc/drop_can(var/loc, obj/item/projectile/P)
	if(P.contents.len)
		for(var/obj/item/I in P.contents)
			I.forceMove(loc)
	randomize_projectile(P)

/datum/ammo/souto/proc/randomize_projectile(obj/item/projectile/P)
	shrapnel_type = pick(typesof(/obj/item/reagent_container/food/drinks/cans/souto)-/obj/item/reagent_container/food/drinks/cans/souto)

/datum/ammo/grenade_container
	name = "grenade shell"
	ping = null
	damage_type = BRUTE
	var/nade_type = /obj/item/explosive/grenade/HE
	icon_state = "grenade"

	flags_ammo_behavior = AMMO_IGNORE_COVER|AMMO_SKIPS_ALIENS

/datum/ammo/grenade_container/New()
	..()
	damage = config.min_hit_damage
	accuracy = config.med_hit_accuracy
	max_range = config.near_shell_range

/datum/ammo/grenade_container/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_nade(P)

/datum/ammo/grenade_container/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_nade(P)

/datum/ammo/grenade_container/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_nade(P)

/datum/ammo/grenade_container/do_at_max_range(obj/item/projectile/P)
	drop_nade(P)

/datum/ammo/grenade_container/proc/drop_nade(var/obj/item/projectile/P)
	var/turf/T = get_turf(P)
	var/obj/item/explosive/grenade/G = new nade_type(T)
	G.visible_message(SPAN_WARNING("\A [G] lands on [T]!"))
	G.det_time = 10
	G.source_mob = P.weapon_source_mob
	G.activate()

/datum/ammo/grenade_container/rifle
	flags_ammo_behavior = NO_FLAGS

/datum/ammo/grenade_container/smoke
	name = "smoke grenade shell"
	nade_type = /obj/item/explosive/grenade/smokebomb
	icon_state = "smoke_shell"

/datum/ammo/hugger_container
	name = "hugger shell"
	ping = null
	damage_type = BRUTE
	var/hugger_hive = XENO_HIVE_NORMAL
	icon_state = "smoke_shell"

/datum/ammo/hugger_container/New()
		..()
		damage = config.min_hit_damage
		accuracy = config.med_hit_accuracy
		max_range = config.near_shell_range

/datum/ammo/hugger_container/on_hit_mob(mob/M,obj/item/projectile/P)
	spawn_hugger(get_turf(P))

/datum/ammo/hugger_container/on_hit_obj(obj/O,obj/item/projectile/P)
	spawn_hugger(get_turf(P))

/datum/ammo/hugger_container/on_hit_turf(turf/T,obj/item/projectile/P)
	spawn_hugger(get_turf(P))

/datum/ammo/hugger_container/do_at_max_range(obj/item/projectile/P)
	spawn_hugger(get_turf(P))

/datum/ammo/hugger_container/proc/spawn_hugger(var/turf/T)
	var/obj/item/clothing/mask/facehugger/child = new(T)
	child.hivenumber = hugger_hive
	child.leap_at_nearest_target()
