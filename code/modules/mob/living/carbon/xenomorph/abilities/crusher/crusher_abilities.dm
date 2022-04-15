/datum/action/xeno_action/activable/pounce/crusher_charge
	name = "Charge"
	action_icon_state = "ready_charge"
	ability_name = "charge"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 140
	plasma_cost = 5

	// Config options
	distance = 9

	knockdown = TRUE
	knockdown_duration = 2
	slash = FALSE
	freeze_self = FALSE
	windup = TRUE
	windup_duration = 12
	windup_interruptable = FALSE
	should_destroy_objects = TRUE
	throw_speed = SPEED_FAST
	tracks_target = FALSE

	var/direct_hit_damage = 60
	var/frontal_armor = 15

	// Object types that dont reduce cooldown when hit
	var/list/not_reducing_objects = list()

/datum/action/xeno_action/activable/pounce/crusher_charge/New()
	. = ..()
	not_reducing_objects = typesof(/obj/structure/barricade) + typesof(/obj/structure/machinery/defenses)

/datum/action/xeno_action/activable/pounce/crusher_charge/initialize_pounce_pass_flags()
	pounce_pass_flags = PASS_CRUSHER_CHARGE

/datum/action/xeno_action/onclick/crusher_stomp
	name = "Stomp"
	action_icon_state = "stomp"
	ability_name = "stomp"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 180
	plasma_cost = 20

	var/damage = 65

	var/distance = 2
	var/effect_type_base = /datum/effects/xeno_slow/superslow
	var/effect_duration = 10

/datum/action/xeno_action/onclick/crusher_stomp/charger
	name = "Crush"
	action_icon_state = "stomp"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charger_stomp
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	plasma_cost = 25
	damage = 75
	distance = 3
	xeno_cooldown = 12 SECONDS


/datum/action/xeno_action/onclick/crusher_shield
	name = "Defensive Shield"
	action_icon_state = "empower"
	ability_name = "defensive shield"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 260
	plasma_cost = 20

	var/shield_amount = 200

/datum/action/xeno_action/onclick/croosh
	name = "crosh"
	action_icon_state = "empower"
	ability_name = "defensive shield"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 260
	plasma_cost = 20

	var/shield_amount = 20

/datum/action/xeno_action/onclick/charger_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	plasma_cost = 0 // manually applied in the proc
	macro_path = /datum/action/xeno_action/verb/verb_crusher_toggle_charging
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1

	// Config vars
	var/max_momentum = 8
	var/steps_to_charge = 4
	var/speed_per_momentum = XENO_SPEED_FASTMOD_TIER_5 + XENO_SPEED_FASTMOD_TIER_1//2
	var/plasma_per_step = 3 // charger has 400 plasma atm, this gives a good 100 tiles of crooshing

	// State vars
	var/activated = FALSE
	var/steps_taken = 0
	var/charge_dir
	var/noise_timer = 0

	//ultimate vars
	var/ultimate_momentum = 10
	var/charged_mobs = 0
	var/ultimate_activation = 10

	/// The last time the crusher moved while charging
	var/last_charge_move
	/// Dictates speed and damage dealt via collision, increased with movement
	var/momentum = 0

/datum/action/xeno_action/onclick/charger_charge/proc/handle_movement(mob/living/carbon/Xenomorph/X, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	if(X.pulling)
		if(!momentum)
			steps_taken = 0
			return
		else
			X.stop_pulling()

	if(X.is_mob_incapacitated())
		var/lol = get_ranged_target_turf(charge_dir,momentum/2)
		INVOKE_ASYNC(X, /atom/movable.proc/throw_atom, lol, momentum/2, SPEED_FAST, null, TRUE)
		stop_momentum()
		return
	if(!isturf(X.loc))
		stop_momentum()
		return
	// Don't build up charge if you move via getting propelled by something
	if(X.throwing)
		stop_momentum()
		return

	var/do_stop_momentum = FALSE

	// Need to be constantly moving in order to maintain charge
	if(world.time > last_charge_move + 0.5 SECONDS)
		do_stop_momentum = TRUE
	if(dir != charge_dir)
		charge_dir = dir
		do_stop_momentum = TRUE

	if(do_stop_momentum)
		stop_momentum()
	if(X.plasma_stored <= plasma_per_step)
		stop_momentum()
		return
	last_charge_move = world.time
	steps_taken++
	if(steps_taken < steps_to_charge)
		return
	if(momentum < max_momentum)
		momentum++
		ADD_TRAIT(X, TRAIT_CHARGING, TRAIT_SOURCE_XENO_ACTION_CHARGE)
		X.update_icons()
		if(momentum == max_momentum)
			X.emote("roar")
	//X.use_plasma(plasma_per_step) // take if you are in toggle charge mode
	if(momentum > 0)
		X.use_plasma(plasma_per_step) // take plasma when you have momentum

	noise_timer = noise_timer ? --noise_timer : 3
	if(noise_timer == 3)
		playsound(X, 'sound/effects/alien_footstep_charge1.ogg', 50)

	for(var/mob/living/carbon/human/M in X.loc)
		if(M.lying && M.stat != DEAD)
			X.visible_message(SPAN_DANGER("[X] runs [M] over!"),
				SPAN_DANGER("You run [M] over!")
			)

			M.apply_damage(momentum * 10)
			animation_flash_color(M)

	X.recalculate_speed()

/datum/action/xeno_action/onclick/charger_charge/proc/handle_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(new_dir != charge_dir)
		charge_dir = new_dir
		if(momentum)
			stop_momentum()

/datum/action/xeno_action/onclick/charger_charge/proc/handle_river(datum/source, covered)
	SIGNAL_HANDLER
	if(!covered)
		stop_momentum()

/datum/action/xeno_action/onclick/charger_charge/proc/update_speed(mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	X.speed += momentum * speed_per_momentum

/datum/action/xeno_action/onclick/charger_charge/proc/stop_momentum(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/Xenomorph/X = owner
	if(momentum == max_momentum)
		X.visible_message(SPAN_DANGER("[X] skids to a halt!"))

	REMOVE_TRAIT(X, TRAIT_CHARGING, TRAIT_SOURCE_XENO_ACTION_CHARGE)
	steps_taken = 0
	momentum = 0
	X.recalculate_speed()
	X.update_icons()

/datum/action/xeno_action/onclick/charger_charge/proc/lose_momentum(amount)
	if(amount >= momentum)
		stop_momentum()
	else
		momentum -= amount
		var/mob/living/carbon/Xenomorph/X = owner
		X.recalculate_speed()

/datum/action/xeno_action/onclick/charger_charge/proc/handle_collision(mob/living/carbon/Xenomorph/X, atom/A)
	SIGNAL_HANDLER
	if(!momentum)
		stop_momentum()
		return

	var/result = A.handle_charge_collision(X, src)
	switch(result)
		if(XENO_CHARGE_TRY_MOVE)
			if(step(X, charge_dir))
				return COMPONENT_LIVING_COLLIDE_HANDLED

/datum/action/xeno_action/onclick/charger_charge/proc/start_charging(datum/source)
	SIGNAL_HANDLER
	steps_taken = steps_to_charge


/datum/action/xeno_action/activable/tumble
	name = "Tumble"
	action_icon_state = "tumble"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_tumble
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2

	plasma_cost = 25
	xeno_cooldown = 10 SECONDS

/datum/action/xeno_action/activable/tumble/proc/handle_mob_collision(mob/living/carbon/human/H)
	var/mob/living/carbon/Xenomorph/X = owner

	X.visible_message(SPAN_XENODANGER("[X] Sweeps to the side, knocking down [H]!"), SPAN_XENODANGER("You knock over [H] as you sweep to the side!"))

	var/turf/target_turf = get_turf(H)
	xeno_throw_human(H, X, get_dir(X, H), 1)
	H.apply_damage(15,BRUTE)
	H.KnockDown(1)
	playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	if(!LinkBlocked(X, get_turf(X), target_turf))
		X.forceMove(target_turf)

/datum/action/xeno_action/activable/tumble/proc/on_end_throw(start_charging)
	var/mob/living/carbon/Xenomorph/X = owner
	X.flags_atom &= ~DIRLOCK
	if(start_charging)
		SEND_SIGNAL(X, COMSIG_XENO_START_CHARGING)

