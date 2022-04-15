
/datum/action/xeno_action/activable/pounce/crusher_charge/additional_effects_always()
	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	for (var/mob/living/carbon/H in orange(1, get_turf(X)))
		if(X.can_not_harm(H))
			continue

		new /datum/effects/xeno_slow(H, X, null, null, 3.5 SECONDS)
		to_chat(H, SPAN_XENODANGER("You are slowed as the impact of [X] shakes the ground!"))

/datum/action/xeno_action/activable/pounce/crusher_charge/additional_effects(mob/living/L)
	if (!isXenoOrHuman(L))
		return

	var/mob/living/carbon/H = L
	if (H.stat == DEAD)
		return

	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	X.emote("roar")
	L.KnockDown(2)
	X.visible_message(SPAN_XENODANGER("[X] overruns [H], brutally trampling them underfoot!"), SPAN_XENODANGER("You brutalize [H] as you crush them underfoot!"))

	H.apply_armoured_damage(get_xeno_damage_slash(H, direct_hit_damage), ARMOR_MELEE, BRUTE)
	xeno_throw_human(H, X, X.dir, 3)

	H.last_damage_data = create_cause_data(X.caste_type, X)
	return

/datum/action/xeno_action/activable/pounce/crusher_charge/pre_windup_effects()
	RegisterSignal(owner, COMSIG_XENO_PRE_CALCULATE_ARMOURED_DAMAGE_PROJECTILE, .proc/check_directional_armor)

/datum/action/xeno_action/activable/pounce/crusher_charge/post_windup_effects(var/interrupted)
	UnregisterSignal(owner, COMSIG_XENO_PRE_CALCULATE_ARMOURED_DAMAGE_PROJECTILE)

/datum/action/xeno_action/activable/pounce/crusher_charge/proc/check_directional_armor(mob/living/carbon/Xenomorph/X, list/damagedata)
	SIGNAL_HANDLER
	var/projectile_direction = damagedata["direction"]
	if(X.dir & REVERSE_DIR(projectile_direction))
		// During the charge windup, crusher gets an extra 15 directional armor in the direction its charging
		damagedata["armor"] += frontal_armor


// This ties the pounce/throwing backend into the old collision backend
/mob/living/carbon/Xenomorph/Crusher/pounced_obj(var/obj/O)
	var/datum/action/xeno_action/activable/pounce/crusher_charge/CCA = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce/crusher_charge)
	if (istype(CCA) && !CCA.action_cooldown_check() && !(O.type in CCA.not_reducing_objects))
		CCA.reduce_cooldown(50)

	gain_plasma(10)

	if (!handle_collision(O)) // Check old backend
		obj_launch_collision(O)

/mob/living/carbon/Xenomorph/Crusher/pounced_turf(var/turf/T)
	T.ex_act(EXPLOSION_THRESHOLD_MLOW, , create_cause_data(caste_type, src))
	..(T)

/datum/action/xeno_action/onclick/crusher_stomp/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	if (!action_cooldown_check())
		return

	if (!X.check_state())
		return

	if (!check_and_use_plasma_owner())
		return

	playsound(get_turf(X), 'sound/effects/bang.ogg', 25, 0)
	X.visible_message(SPAN_XENODANGER("[X] smashes into the ground!"), SPAN_XENODANGER("You smash into the ground!"))
	X.create_stomp()

	for (var/mob/living/carbon/H in get_turf(X))
		if (H.stat == DEAD || X.can_not_harm(H))
			continue

		new effect_type_base(H, X, , , get_xeno_stun_duration(H, effect_duration))
		to_chat(H, SPAN_XENOHIGHDANGER("You are slowed as [X] knocks you off balance!"))

		if(H.mob_size < MOB_SIZE_BIG)
			H.KnockDown(get_xeno_stun_duration(H, 0.2))

		H.apply_armoured_damage(get_xeno_damage_slash(H, damage), ARMOR_MELEE, BRUTE)
		H.last_damage_data = create_cause_data(X.caste_type, X)

	for (var/mob/living/carbon/H in orange(distance, get_turf(X)))
		if (H.stat == DEAD || X.can_not_harm(H))
			continue

		new effect_type_base(H, X, , , get_xeno_stun_duration(H, effect_duration))
		if(H.mob_size < MOB_SIZE_BIG)
			H.KnockDown(get_xeno_stun_duration(H, 0.2))
		to_chat(H, SPAN_XENOHIGHDANGER("You are slowed as [X] knocks you off balance!"))

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/onclick/crusher_stomp/charger/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	var/mob/living/carbon/V
	if (!istype(X))
		return

	if (!action_cooldown_check())
		return

	if (!X.check_state())
		return

	if (!check_and_use_plasma_owner())
		return

	playsound(get_turf(X), 'sound/effects/bang.ogg', 25, 0)
	X.visible_message(SPAN_XENODANGER("[X] smashes into the ground!"), SPAN_XENODANGER("You smash into the ground!"))
	X.create_stomp()

	for (var/mob/living/carbon/H in get_turf(X)) // MOBS ONTOP
		if (H.stat == DEAD || X.can_not_harm(H))
			continue

		new effect_type_base(H, X, , , get_xeno_stun_duration(H, effect_duration))
		to_chat(H, SPAN_XENOHIGHDANGER("You are BRUTALLY crushed an stompted on by [X] !!!"))

		if(H.mob_size < MOB_SIZE_BIG)
			H.KnockDown(get_xeno_stun_duration(H, 0.2))

		H.apply_armoured_damage(get_xeno_damage_slash(H, damage), ARMOR_MELEE, BRUTE,"chest", 3)
		H.apply_armoured_damage(15, BRUTE) // random
		H.last_damage_data = create_cause_data(X.caste_type, X)
		H.emote("pain")
		V = H
	for (var/mob/living/carbon/H in orange(distance, get_turf(X))) // MOBS AROUND
		if (H.stat == DEAD || X.can_not_harm(H))
			continue
		//new effect_type_base(H, X, , , get_xeno_stun_duration(H, effect_duration))
		//if(H.mob_size < MOB_SIZE_BIG)
			//H.KnockDown(get_xeno_stun_duration(H, 0.2))
		if(H.client)
			shake_camera(H, 2, 2)
		//to_chat(H, SPAN_XENOHIGHDANGER("You are slowed as [X] knocks you off balance!"))
		if(V)
			to_chat(H, SPAN_XENOHIGHDANGER("You watch as [V] gets crushed by [X]!"))
		to_chat(H, SPAN_XENOHIGHDANGER("You are shaken as [X] quakes the earth!"))

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/onclick/crusher_shield/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

	if (!istype(X))
		return

	if (!action_cooldown_check())
		return

	if (!X.check_state())
		return

	if (!check_and_use_plasma_owner())
		return

	X.visible_message(SPAN_XENOWARNING("[X] hunkers down and bolsters its defenses!"), SPAN_XENOHIGHDANGER("You hunker down and bolster your defenses!"))

	X.create_crusher_shield()

	X.add_xeno_shield(shield_amount, XENO_SHIELD_SOURCE_CRUSHER, /datum/xeno_shield/crusher)
	X.overlay_shields()

	X.explosivearmor_modifier += 1000
	X.recalculate_armor()

	addtimer(CALLBACK(src, .proc/remove_explosion_immunity), 25, TIMER_UNIQUE)
	addtimer(CALLBACK(src, .proc/remove_shield), 70, TIMER_UNIQUE)

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/onclick/crusher_shield/proc/remove_explosion_immunity()
	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	X.explosivearmor_modifier -= 1000
	X.recalculate_armor()
	to_chat(X, SPAN_XENODANGER("Your immunity to explosion damage ends!"))

/datum/action/xeno_action/onclick/crusher_shield/proc/remove_shield()
	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	var/datum/xeno_shield/found
	for (var/datum/xeno_shield/XS in X.xeno_shields)
		if (XS.shield_source == XENO_SHIELD_SOURCE_CRUSHER)
			found = XS
			break

	if (istype(found))
		found.on_removal()
		qdel(found)
		to_chat(X, SPAN_XENOHIGHDANGER("You feel your enhanced shield end!"))

	X.overlay_shields()

/datum/action/xeno_action/onclick/charger_charge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

	activated = !activated
	var/will_charge = "[activated ? "now" : "no longer"]"
	to_chat(X, SPAN_XENONOTICE("You will [will_charge] charge when moving."))
	if(activated)
		RegisterSignal(X, COMSIG_MOVABLE_MOVED, .proc/handle_movement)
		RegisterSignal(X, COMSIG_ATOM_DIR_CHANGE, .proc/handle_dir_change)
		RegisterSignal(X, COMSIG_XENO_RECALCULATE_SPEED, .proc/update_speed)
		RegisterSignal(X, COMSIG_XENO_STOP_MOMENTUM, .proc/stop_momentum)
		RegisterSignal(X, COMSIG_MOVABLE_ENTERED_RIVER, .proc/handle_river)
		RegisterSignal(X, COMSIG_LIVING_PRE_COLLIDE, .proc/handle_collision)
		RegisterSignal(X, COMSIG_XENO_START_CHARGING, .proc/start_charging)
		button.icon_state = "template_on"
	else
		stop_momentum()
		UnregisterSignal(X, list(
			COMSIG_MOVABLE_MOVED,
			COMSIG_ATOM_DIR_CHANGE,
			COMSIG_XENO_RECALCULATE_SPEED,
			COMSIG_MOVABLE_ENTERED_RIVER,
			COMSIG_LIVING_PRE_COLLIDE,
			COMSIG_XENO_STOP_MOMENTUM,
			COMSIG_XENO_START_CHARGING,
			button.icon_state = "template"
		))
	if(!activated)
		button.icon_state = "template"

/datum/action/xeno_action/activable/croosh/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

/datum/action/xeno_action/activable/tumble/use_ability(atom/A)
	if(!action_cooldown_check())
		return
	var/mob/living/carbon/Xenomorph/X = owner
	if (!X.check_state())
		return
	if(X.plasma_stored <= plasma_cost)
		return
	var/target_dist = get_dist(X, A)
	var/dir_between = get_dir(X, A)
	var/target_dir
	for(var/perpen_dir in get_perpen_dir(X.dir))
		if(dir_between & perpen_dir)
			target_dir = perpen_dir
			break

	if(!target_dir)
		return

	X.visible_message(SPAN_XENOWARNING("[X] tumbles over to the side!"), SPAN_XENOHIGHDANGER("You tumble over to the side!"))
	X.spin(5,1) // note: This spins the sprite and DOES NOT affect directional armor
	var/start_charging = HAS_TRAIT(X, TRAIT_CHARGING)
	SEND_SIGNAL(X, COMSIG_XENO_STOP_MOMENTUM)
	X.flags_atom |= DIRLOCK
	playsound(X,"alien_tail_swipe", 50, 1)

	X.use_plasma(plasma_cost)
	var/datum/launch_metadata/LM = new()
	LM.target = get_step(get_step(X, target_dir), target_dir)
	LM.range = target_dist
	LM.speed = SPEED_FAST
	LM.thrower = X
	LM.spin = FALSE
	LM.pass_flags = PASS_CRUSHER_CHARGE
	LM.collision_callbacks = list(/mob/living/carbon/human = CALLBACK(src, .proc/handle_mob_collision))
	LM.end_throw_callbacks = list(CALLBACK(src, .proc/on_end_throw, start_charging))

	X.launch_towards(LM)

	apply_cooldown()
	..()
