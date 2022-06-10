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

// -------------------- Charger collision procs

/atom/proc/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	CCA.stop_momentum()

// Windows

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

// Legacy doors

/obj/structure/mineral_door/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	playsound(loc, "punch", 25, TRUE)
	Dismantle(TRUE)
	CCA.lose_momentum(2)
	return XENO_CHARGE_TRY_MOVE

// Tables & shelves, etc

/obj/structure/surface/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	Crossed(X)
	return XENO_CHARGE_TRY_MOVE

// Cades

/obj/structure/barricade/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum)
		visible_message(
			SPAN_DANGER("[X] rams into [src] and skids to a halt!"),
			SPAN_XENOWARNING("You ram into [src] and skid to a halt!")
		)
		take_damage(CCA.momentum * 22)
		playsound(src, barricade_hitsound, 25, TRUE)

	CCA.stop_momentum()

// wFrames

/obj/structure/window_frame/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum)
		playsound(src, 'sound/effects/metalhit.ogg', 25, TRUE)
		take_damage(CCA.momentum * 100)
		if(QDELETED(src))
			CCA.lose_momentum(2)
			return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Doors

/obj/structure/machinery/door/poddoor/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum < 4)
		CCA.stop_momentum()
		return

	if(!indestructible && !unacidable)
		qdel(src)
		playsound(src, 'sound/effects/metal_crash.ogg', 25, TRUE)
		CCA.lose_momentum(3)
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Closets

/obj/structure/closet/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	take_damage(CCA.momentum * 50)
	if(QDELETED(src))
		CCA.lose_momentum(2)
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Fences
/obj/structure/fence/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	update_health(CCA.momentum * 20)
	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)
	if(QDELETED(src))
		if(prob(50))
			CCA.lose_momentum(1)
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Crates

/obj/structure/largecrate/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	var/turf/T = get_turf(src)
	new /obj/item/stack/sheet/wood(T)
	for(var/obj/O in contents)
		O.forceMove(T)

	qdel(src)
	playsound(src, 'sound/effects/woodhit.ogg', 25, TRUE)
	CCA.lose_momentum(1)
	return XENO_CHARGE_TRY_MOVE

// Cargo containers

/obj/structure/cargo_container/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	qdel(src)
	CCA.lose_momentum(2)
	return XENO_CHARGE_TRY_MOVE

// Girders

/obj/structure/girder/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return

	playsound(src, 'sound/effects/metalhit.ogg', 25, TRUE)
	take_damage(CCA.momentum * 100)
	if(QDELETED(src))
		CCA.lose_momentum(2)
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// General Machinery

/obj/structure/machinery/disposal/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum < 2)
		CCA.stop_momentum()
		return
	var/obj/structure/disposalconstruct/C = new(loc)
	C.ptype = 6 //6 = disposal unit
	C.density = TRUE
	C.update()
	step_away(C, X, 2)
	qdel(src)
	CCA.lose_momentum(2)
	return XENO_CHARGE_TRY_MOVE

// Disposals

/obj/structure/disposalconstruct/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	step_away(src, X, 2)
	CCA.lose_momentum(1)
	return XENO_CHARGE_TRY_MOVE

// Humans

/mob/living/carbon/human/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	playsound(loc, "punch", 25, TRUE)
	attack_log += text("\[[time_stamp()]\] <font color='orange'>was xeno charged by [X] ([X.ckey])</font>")
	X.attack_log += text("\[[time_stamp()]\] <font color='red'>xeno charged [src] ([src.ckey])</font>")
	log_attack("[X] ([X.ckey]) xeno charged [src] ([src.ckey])")
	var/momentum_mult = 5
	if(CCA.momentum == CCA.max_momentum)
		momentum_mult = 8
	take_overall_armored_damage(CCA.momentum * momentum_mult, ARMOR_MELEE, BRUTE, 50, 13) // Giving AP because this spreads damage out and then applies armor to them
	apply_armoured_damage(CCA.momentum * momentum_mult/4,ARMOR_MELEE, BRUTE,"chest")
	X.visible_message(
		SPAN_DANGER("[X] rams [src]!"),
		SPAN_XENODANGER("You ram [src]!")
	)
	var/knockdown = 1
	if(CCA.momentum == CCA.max_momentum)
		knockdown = 2
	KnockDown(knockdown)
	animation_flash_color(src)
	if(client)
		shake_camera(src, 1, 3)
	var/list/ram_dirs = get_perpen_dir(X.dir)
	var/ram_dir = pick(ram_dirs)
	var/cur_turf = get_turf(src)
	var/target_turf = get_step(src, ram_dir)
	if(LinkBlocked(src, cur_turf, target_turf))
		ram_dir = REVERSE_DIR(ram_dir)
	step(src, ram_dir, CCA.momentum * 0.5)
	CCA.lose_momentum(1)
	return XENO_CHARGE_TRY_MOVE

// Fellow xenos

/mob/living/carbon/Xenomorph/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum)
		playsound(loc, "punch", 25, TRUE)
		if(!X.ally_of_hivenumber(hivenumber))
			attack_log += text("\[[time_stamp()]\] <font color='orange'>was xeno charged by [X] ([X.ckey])</font>")
			X.attack_log += text("\[[time_stamp()]\] <font color='red'>xeno charged [src] ([ckey])</font>")
			log_attack("[X] ([X.ckey]) xeno charged [src] ([ckey])")
			apply_damage(CCA.momentum * 10, BRUTE) // half damage to avoid sillyness
		if(anchored) //Ovipositor queen can't be pushed
			CCA.stop_momentum()
			return
		if(HAS_TRAIT(src, TRAIT_CHARGING))
			KnockDown(2)
			X.KnockDown(2)
			src.throw_atom(pick(cardinal),1,3,X,TRUE)
			X.throw_atom(pick(cardinal),1,3,X,TRUE)
			CCA.stop_momentum() // We assume the other crusher's handle_charge_collision() kicks in and stuns us too.
			playsound(get_turf(X), 'sound/effects/bang.ogg', 25, 0)
			return
		var/list/ram_dirs = get_perpen_dir(X.dir)
		var/ram_dir = pick(ram_dirs)
		var/cur_turf = get_turf(src)
		var/target_turf = get_step(src, ram_dir)
		if(LinkBlocked(src, cur_turf, target_turf))
			X.emote("roar")
			X.visible_message(SPAN_DANGER("[X] flings [src] over to the side!"),SPAN_DANGER( "You fling [src] out of the way!"))
			to_chat(src,SPAN_XENOHIGHDANGER("[src] flings you out of its way! Move it!"))
			KnockDown(1) // brief flicker stun
			src.throw_atom(src.loc,1,3,X,TRUE)
		step(src, ram_dir, CCA.momentum * 0.5)
		CCA.lose_momentum(2)
		return XENO_CHARGE_TRY_MOVE
	CCA.stop_momentum()

// Other mobs

/mob/living/carbon/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	playsound(loc, "punch", 25, TRUE)
	attack_log += text("\[[time_stamp()]\] <font color='orange'>was xeno charged by [X] ([X.ckey])</font>")
	X.attack_log += text("\[[time_stamp()]\] <font color='red'>xeno charged [src] ([src.ckey])</font>")
	log_attack("[X] ([X.ckey]) xeno charged [src] ([src.ckey])")
	var/momentum_mult = 5
	if(CCA.momentum == CCA.max_momentum)
		momentum_mult = 8
	take_overall_damage(CCA.momentum * momentum_mult)
	X.visible_message(
		SPAN_DANGER("[X] rams [src]!"),
		SPAN_XENODANGER("You ram [src]!")
	)
	var/knockdown = 1
	if(CCA.momentum == CCA.max_momentum)
		knockdown = 2
	KnockDown(knockdown)
	animation_flash_color(src)
	if(client)
		shake_camera(src, 1, 3)
	var/list/ram_dirs = get_perpen_dir(X.dir)
	var/ram_dir = pick(ram_dirs)
	var/cur_turf = get_turf(src)
	var/target_turf = get_step(src, ram_dir)
	if(LinkBlocked(src, cur_turf, target_turf))
		ram_dir = REVERSE_DIR(ram_dir)
	step(src, ram_dir, CCA.momentum * 0.5)
	CCA.lose_momentum(1)
	return XENO_CHARGE_TRY_MOVE

/*
notes

new collision procs for:
rollerbeds,	[d]
fences,	[d]
, computers [d] (handled with /obj/machinery )
, filecabinets, [d]
m56 & m2c 	[d] ( find better solution )

buff health a bit [d]

change the proc pushing xenos to something that pushes them in a random direction rather than away [d]

bell immunity [d]

*/

// Walls

/turf/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum)
		if(istype(src, /turf/closed/wall/resin))
			ex_act(CCA.momentum * 5, null, create_cause_data(initial(X.caste_type), X)) // Half damage for xeno walls?
		ex_act(CCA.momentum * 13, null, create_cause_data(initial(X.caste_type), X))

	CCA.stop_momentum()

// Powerloaders

/obj/vehicle/powerloader/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	explode()
	if(QDELETED(src))
		CCA.lose_momentum(1) //Lose one turfs worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Sentry

/obj/structure/machinery/defenses/sentry/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	var/datum/effect_system/spark_spread/s = new
	s.set_up(5, 1, loc)
	X.visible_message(
		SPAN_DANGER("[X] rams [src]!"),
		SPAN_XENODANGER("You ram [src]!")
	)
	if(health <= CCA.momentum * 9)
		new /obj/effect/spawner/gibspawner/robot(src.loc) // if we goin down ,we going down with a show.
	update_health(CCA.momentum * 9)
	s.start()
	playsound(src, "sound/effects/metalhit.ogg", 25, TRUE)

	if(QDELETED(src))
		CCA.lose_momentum(2) //Lose two turfs worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Marine MGs

/obj/structure/machinery/m56d_hmg/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(CCA.momentum > 1)
		CrusherImpact()
		update_health(CCA.momentum * 15)
		if(operator)	operator.emote("pain")
		var/datum/effect_system/spark_spread/s = new
		s.set_up(1, 1, loc)
		s.start()
		playsound(src, "sound/effects/metal_crash.ogg", 25, TRUE)
		X.visible_message(
			SPAN_DANGER("[X] rams [src]!"),
			SPAN_XENODANGER("You ram [src]!")
		)
		if(istype(src,/obj/structure/machinery/m56d_hmg/auto)) // we don't want to charge it to the point of downgrading it (:
			var/obj/item/device/m2c_gun/HMG = new(src.loc)
			to_chat(world, "TEST STEST")
			HMG = new(src.loc)
			HMG.health = src.health
			HMG.set_name_label(name_label)
			HMG.rounds = src.rounds //Inherent the amount of ammo we had.
			HMG.update_icon()
			qdel(src)
		else
			var/obj/item/device/m56d_gun/HMG = new(src.loc) // note: find a better way than a copy pasted else statement
			HMG = new(src.loc)
			HMG.health = src.health
			HMG.set_name_label(name_label)
			HMG.rounds = src.rounds //Inherent the amount of ammo we had.
			HMG.has_mount = TRUE
			HMG.update_icon()
			qdel(src) //Now we clean up the constructed gun.
	if(QDELETED(src))
		CCA.lose_momentum(1) //Lose one turfs worth of speed
		return XENO_CHARGE_TRY_MOVE
	CCA.stop_momentum()

// Prison Windows

/obj/structure/window/framed/prison/reinforced/hull/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	if(CCA.momentum > 2)
		Destroy()
		CCA.stop_momentum()
	CCA.stop_momentum()
	// snowflake check for prison windows because they are funny and crooshers can croosh to space in the brief moment where the shutters are closing

// Rollerbeds

/obj/structure/bed/roller/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	Destroy()
	playsound(src, "sound/effects/metal_crash.ogg", 25, TRUE)
	return XENO_CHARGE_TRY_MOVE // bulldoze that shitty bed and keep going, should run over the buckled mob aswell unless crusher turns last second for some reason

// Filing Cabinets

/obj/structure/filingcabinet/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	X.visible_message(
		SPAN_DANGER("[X] rams [src]!"),
		SPAN_XENODANGER("You ram [src]!")
	)
	playsound(src, "sound/effects/metalhit.ogg", 25, TRUE)
	Destroy()
	if(QDELETED(src))
		CCA.lose_momentum(1) //Lose one turfs worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()

// Legacy Tank dispenser
// Todo: Give this and other shitty fucking indestructable legacy items proper destruction mechanics. This includes being vunerable to bullets,explosions, etc and not just the charger.
// For now this is fine since priority is charger, and I'm not willing to spend all day looking for bumfuck legacy item #382321 thats used a total of three times in the entireity of CM and adding health and everything to it.

/obj/structure/dispenser/handle_charge_collision(mob/living/carbon/Xenomorph/X, datum/action/xeno_action/onclick/charger_charge/CCA)
	if(!CCA.momentum)
		CCA.stop_momentum()
		return
	X.visible_message(
		SPAN_DANGER("[X] rams [src]!"),
		SPAN_XENODANGER("You ram [src]!")
	)
	playsound(src, "sound/effects/metalhit.ogg", 25, TRUE)
	qdel(src)
	if(QDELETED(src))
		CCA.lose_momentum(1) //Lose one turfs worth of speed
		return XENO_CHARGE_TRY_MOVE

	CCA.stop_momentum()
