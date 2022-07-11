/datum/caste_datum/crusher
	caste_type = XENO_CASTE_CRUSHER
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_5
	melee_damage_upper = XENO_DAMAGE_TIER_5
	max_health = XENO_HEALTH_TIER_12
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_10
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_3
	heal_standing = 0.66
	//small_explosives_stun = FALSE this probably does something
	behavior_delegate_type = /datum/behavior_delegate/crusher_base

	tackle_min = 2
	tackle_max = 6
	tackle_chance = 25

	evolution_allowed = FALSE
	deevolves_to = list(XENO_CASTE_WARRIOR)
	caste_desc = "A huge tanky xenomorph."

/mob/living/carbon/Xenomorph/Crusher
	caste_type = XENO_CASTE_CRUSHER
	name = XENO_CASTE_CRUSHER
	desc = "A huge alien with an enormous armored head crest."
	icon_size = 64
	icon_state = "Crusher Walking"
	plasma_types = list(PLASMA_CHITIN)
	tier = 3
	drag_delay = 6 //pulling a big dead xeno is hard

	small_explosives_stun = FALSE

	mob_size = MOB_SIZE_IMMOBILE

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3

	rebounds = FALSE // no more fucking pinball crooshers

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/onclick/charger_charge,
		/datum/action/xeno_action/onclick/crusher_stomp/charger,
		/datum/action/xeno_action/activable/tumble,
		/datum/action/xeno_action/activable/pounce/ram
	)

	mutation_type = CRUSHER_NORMAL
	claw_type = CLAW_TYPE_VERY_SHARP

	icon_xenonid = 'icons/mob/xenonids/crusher.dmi'

/mob/living/carbon/Xenomorph/Crusher/Initialize(mapload, mob/living/carbon/Xenomorph/oldXeno, h_number)
	icon_xeno = get_icon_from_source(CONFIG_GET(string/alien_crusher))
	. = ..()

// Mutator delegate for base crusher
/datum/behavior_delegate/crusher_base
	name = "Base Crusher Behavior Delegate"

	var/frontal_armor = 32
	var/side_armor = 15
/datum/behavior_delegate/crusher_base/add_to_xeno()
	RegisterSignal(bound_xeno, COMSIG_MOB_SET_FACE_DIR, .proc/cancel_dir_lock)
	RegisterSignal(bound_xeno, COMSIG_XENO_PRE_CALCULATE_ARMOURED_DAMAGE_PROJECTILE, .proc/apply_directional_armor)
//crusher_base

/datum/behavior_delegate/crusher_base/on_update_icons()
	if(bound_xeno.throwing) //Let it build up a bit so we're not changing icons every single turf
		bound_xeno.icon_state = "[bound_xeno.mutation_type] Crusher Charging"
		return TRUE

/datum/behavior_delegate/crusher_base/proc/cancel_dir_lock()
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_SET_FACE_DIR

/datum/behavior_delegate/crusher_base/proc/apply_directional_armor(mob/living/carbon/Xenomorph/X, list/damagedata)
	SIGNAL_HANDLER
	var/projectile_direction = damagedata["direction"]
	if(X.dir & REVERSE_DIR(projectile_direction))
		// During the charge windup, crusher gets an extra 15 directional armor in the direction its charging
		damagedata["armor"] += frontal_armor
	else
		for(var/side_direction in get_perpen_dir(X.dir))
			if(projectile_direction == side_direction)
				damagedata["armor"] += side_armor
				return

/datum/behavior_delegate/crusher_base/on_update_icons()
	if(HAS_TRAIT(bound_xeno, TRAIT_CHARGING) && !bound_xeno.lying)
		bound_xeno.icon_state = "[bound_xeno.mutation_type] Crusher Charging"
		return TRUE

// -------------------- General/Legacy collision procs

/mob/living/carbon/Xenomorph/proc/handle_collision(atom/target)
	var/datum/effect_system/spark_spread/s = new
	if(!target)
		return FALSE

	//Barricade collision
	else if (istype(target, /obj/structure/barricade))
		var/obj/structure/barricade/B = target
		visible_message(SPAN_DANGER("[src] rams into [B] and skids to a halt!"), SPAN_XENOWARNING("You ram into [B] and skid to a halt!"))

		B.Collided(src)
		. =  FALSE

	else if (istype(target, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/M = target
		visible_message(SPAN_DANGER("[src] rams into [M] and skids to a halt!"), SPAN_XENOWARNING("You ram into [M] and skid to a halt!"))

		M.Collided(src)
		. = FALSE

// below doesnt work
	else if (istype(target,/obj/structure/machinery/m56d_hmg/auto)) // we don't want to charge it to the point of downgrading it (:
		var/obj/structure/machinery/m56d_hmg/auto/O = target
		var/obj/item/device/m2c_gun/HMG
		O.CrusherImpact()
		to_chat(world, "TEST STEST")
		s.set_up(1, 1, O.loc)
		s.start()
		playsound(src, "sound/effects/metal_crash.ogg", 25, TRUE)
		HMG = new(O.loc)
		HMG.health = O.health
		HMG.set_name_label(name_label)
		HMG.rounds = O.rounds //Inherent the amount of ammo we had.
		HMG.update_icon()
		qdel(O)
		. =  FALSE

	else if (istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if (W.unacidable)
			. = FALSE
		else
			W.shatter_window(1)
			. =  TRUE // Continue throw

	else if (istype(target, /obj/structure/machinery/door/airlock))
		var/obj/structure/machinery/door/airlock/A = target

		if (A.unacidable)
			. = FALSE
		else
			A.destroy_airlock()

	else if (istype(target, /obj/structure/grille))
		var/obj/structure/grille/G = target
		if(G.unacidable)
			. =  FALSE
		else
			G.health -=  80 //Usually knocks it down.
			G.healthcheck()
			. = TRUE

	else if (istype(target, /obj/structure/surface/table))
		var/obj/structure/surface/table/T = target
		T.Crossed(src)
		. = TRUE

	else if (istype(target, /obj/structure/machinery/defenses))
		var/obj/structure/machinery/defenses/DF = target
		visible_message(SPAN_DANGER("[src] rams [DF]!"), SPAN_XENODANGER("You ram [DF]!"))
		s.set_up(5, 5, DF.loc)
		s.start()
		if (!DF.unacidable)
			playsound(loc, "punch", 25, 1)
			DF.stat = 1
			DF.update_icon()
			DF.update_health(40)

		. =  FALSE

	else if (istype(target, /obj/structure/machinery/vending))
		var/obj/structure/machinery/vending/V = target

		if (V.unslashable)
			. = FALSE
		else
			visible_message(SPAN_DANGER("[src] smashes straight into [V]!"), SPAN_XENODANGER("You smash straight into [V]!"))
			playsound(loc, "punch", 25, 1)
			V.tip_over()
			s.set_up(2, 2, V.loc)
			s.start()
			var/impact_range = 1
			var/turf/TA = get_diagonal_step(V, dir)
			TA = get_step_away(TA, src)
			var/launch_speed = 2
			launch_towards(TA, impact_range, launch_speed)

			. =  TRUE

	else if (istype(target, /obj/structure/machinery/cm_vending))
		var/obj/structure/machinery/cm_vending/V = target
		if (V.unslashable)
			. = FALSE
		else
			visible_message(SPAN_DANGER("[src] smashes straight into [V]!"), SPAN_XENODANGER("You smash straight into [V]!"))
			playsound(loc, "punch", 25, 1)
			V.tip_over()

			var/impact_range = 1
			var/turf/TA = get_diagonal_step(V, dir)
			TA = get_step_away(TA, src)
			var/launch_speed = 2
			throw_atom(TA, impact_range, launch_speed)

			. =  TRUE

	// Anything else?
	else
		if (isobj(target))
			var/obj/O = target
			if (O.unacidable)
				. = FALSE
			else if (O.anchored)
				visible_message(SPAN_DANGER("[src] crushes [O]!"), SPAN_XENODANGER("You crush [O]!"))
				if(O.contents.len) //Hopefully won't auto-delete things inside crushed stuff.
					var/turf/T = get_turf(src)
					for(var/atom/movable/S in T.contents) S.forceMove(T)

				qdel(O)
				. = TRUE

			else
				if(O.buckled_mob)
					O.unbuckle()
				visible_message(SPAN_WARNING("[src] knocks [O] aside!"), SPAN_XENOWARNING("You knock [O] aside.")) //Canisters, crates etc. go flying.
				playsound(loc, "punch", 25, 1)

				var/impact_range = 2
				var/turf/TA = get_diagonal_step(O, dir)
				TA = get_step_away(TA, src)
				var/launch_speed = 2
				throw_atom(TA, impact_range, launch_speed)

				. = TRUE

	if (!.)
		update_icons()

// Mutator delegate for base ravager
/datum/behavior_delegate/crusher_base
	name = "Base Crusher Behavior Delegate"

/obj/structure/window/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(unacidable)
		CCA.stop_momentum()
		return

	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	health -= CCA.momentum * 40 //Usually knocks it down.
	healthcheck()

	if(QDELETED(src))
		CCA.lose_momentum(2) //Lose two turfs worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Grills

/obj/structure/grille/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(unacidable)
		CCA.stop_momentum()
		return

	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	health -= CCA.momentum * 40 //Usually knocks it down.
	healthcheck()

	if(QDELETED(src))
		CCA.lose_momentum(1) //Lose one turf worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Airlock Doors

/obj/structure/machinery/door/airlock/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	// Need at least 4 momentum to destroy a full health door
	take_damage(CCA.momentum * damage_cap * 0.25, X)
	if(QDELETED(src))
		CCA.lose_momentum(2) //Lose two turfs worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Vending machines

/obj/structure/machinery/vending/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum >= 3)
		if(unacidable)
			CCA.stop_momentum()
			return
		X.visible_message(
			SPAN_DANGER("[X] smashes straight into [src]!"),
			SPAN_XENODANGER("You smash straight into [src]!")
		)
		playsound(loc, "punch", 25, TRUE)
		tip_over()
		step_away(src, X)
		step_away(src, X)
		CCA.lose_momentum(2)
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()


// Barine Vending machines

/obj/structure/machinery/cm_vending/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum >= 3)
		X.visible_message(
			SPAN_DANGER("[X] smashes straight into [src]!"),
			SPAN_XENODANGER("You smash straight into [src]!")
		)
		playsound(loc, "punch", 25, TRUE)
		tip_over()
		CCA.lose_momentum(2)
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

/datum/behavior_delegate/crusher_base/on_update_icons()
	if(bound_xeno.throwing) //Let it build up a bit so we're not changing icons every single turf
		bound_xeno.icon_state = "[bound_xeno.mutation_type] Crusher Charging"
		return TRUE
