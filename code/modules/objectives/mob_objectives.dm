// --------------------------------------------
// *** Get a mob to an area/level ***
// --------------------------------------------
#define MOB_CAN_COMPLETE_AFTER_DEATH 1
#define MOB_FAILS_ON_DEATH 2

/datum/cm_objective/move_mob
	var/mob/living/target
	var/mob_can_die = MOB_CAN_COMPLETE_AFTER_DEATH
	objective_flags = OBJ_DO_NOT_TREE | OBJ_FAILABLE | OBJ_CONTROL_EXCLUSIVE | OBJ_CONTROL_FLAG

/datum/cm_objective/move_mob/New(var/mob/living/H)
	if(istype(H, /mob/living))
		target = H
	. = ..()

/datum/cm_objective/move_mob/Destroy()
	target = null
	return ..()

/datum/cm_objective/move_mob/check_completion()
	. = ..()
	if(target.stat == DEAD && mob_can_die & MOB_FAILS_ON_DEATH)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!H.check_tod() || !H.is_revivable()) // they went unrevivable
				//Synths can (almost) always be revived, so don't fail their objective...
				if(!isSynth(H))
					fail()
				return FALSE
		else
			fail()
			return FALSE

	if(target.stat != DEAD || mob_can_die & MOB_CAN_COMPLETE_AFTER_DEATH)
		if(validate_destination())
			complete()
			return TRUE

/datum/cm_objective/proc/validate_destination()
	return TRUE

/datum/cm_objective/move_mob/almayer
	controller = TREE_MARINE
/datum/cm_objective/move_mob/validate_destination()
	if(istype(get_area(target), /area/almayer))
		return TRUE

/datum/cm_objective/move_mob/almayer/survivor
	name = "Rescue the Survivor"
	mob_can_die = MOB_FAILS_ON_DEATH
	priority = OBJECTIVE_EXTREME_VALUE
	display_category = "Rescue the Survivors"

/datum/cm_objective/move_mob/almayer/vip
	name = "Rescue the VIP"
	mob_can_die = MOB_FAILS_ON_DEATH
	priority = OBJECTIVE_ABSOLUTE_VALUE
	display_category = "Rescue the VIP"
	objective_flags = OBJ_DO_NOT_TREE | OBJ_FAILABLE | OBJ_CAN_BE_UNCOMPLETED | OBJ_CONTROL_EXCLUSIVE | OBJ_CONTROL_FLAG

// --------------------------------------------
// *** Recover the dead ***
// --------------------------------------------
/datum/cm_objective/recover_corpses
	name = "Recover corpses"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END | OBJ_DISPLAY_UBIQUITOUS
	/// List of list of active corpses per tech-faction ownership
	var/list/corpses
	/// Base scoring points for each faction, eg. to account for consumed corpses
	var/list/points_base
	/// Cache of point values as per last update for each faction
	var/list/points_cache
	/// Cache of total baseline value of objectives as per last update (informative, inexact)
	var/list/points_potential

/datum/cm_objective/recover_corpses/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CORPSE_CONSUMED, .proc/handle_corpse_consumption)
	RegisterSignal(SSdcs, COMSIG_GLOB_MARINE_DEATH, .proc/handle_marine_deaths)
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_DEATH, .proc/handle_xeno_deaths)
	corpses          = list(TREE_MARINE = list(), TREE_XENO = list(), TREE_NONE = list())
	points_base      = list(TREE_MARINE = 0, TREE_XENO = 0, TREE_NONE = 0)
	points_cache     = list(TREE_MARINE = 0, TREE_XENO = 0, TREE_NONE = 0)
	points_potential = list(TREE_MARINE = 0, TREE_XENO = 0, TREE_NONE = 0)
	awarded_points   = list(TREE_MARINE = 0, TREE_XENO = 0, TREE_NONE = 0)

/datum/cm_objective/recover_corpses/post_round_start()
	// Populate list at round start with survivors
	for(var/mob/living/carbon/human/H as anything in GLOB.human_mob_list)
		var/turf/T = get_turf(H)
		if(is_ground_level(T?.z) && H.stat == DEAD)
			LAZYADD(corpses[TREE_NONE], H)

//TODOIO PROPER DELETION HANDLING
/datum/cm_objective/recover_corpses/proc/handle_marine_deaths(datum/source, mob/living/carbon/human/H, gibbed)
	SIGNAL_HANDLER
	if(gibbed || !istype(H) || !istype(H.assigned_squad))
		return
	LAZYDISTINCTADD(corpses[TREE_MARINE], H)
	RegisterSignal(H, list(
		COMSIG_LIVING_REJUVENATED,
		COMSIG_HUMAN_REVIVED,
	), .proc/handle_marine_revival)

/datum/cm_objective/recover_corpses/proc/handle_marine_revival(mob/living/carbon/human/H)
	UnregisterSignal(H, list(
		COMSIG_LIVING_REJUVENATED,
		COMSIG_HUMAN_REVIVED,
	))
	LAZYREMOVE(corpses[TREE_MARINE], H)

/datum/cm_objective/recover_corpses/proc/handle_xeno_deaths(datum/source, mob/living/X, gibbed)
	SIGNAL_HANDLER
	if(isXeno(X) && !gibbed)
		LAZYDISTINCTADD(corpses[TREE_XENO], X)

/// Get score value for a given corpse
/datum/cm_objective/recover_corpses/proc/score_corpse(mob/target, owner = TREE_NONE, scorer = TREE_NONE)
	// TODOIO standardize points
	var/value = 0

	if(isYautja(target))
		value = 100

	else if(isXeno(target))
		var/mob/living/carbon/Xenomorph/X = target
		switch(X.tier)
			if(1)
				if(isXenoPredalien(X))
					value = 100
				else value = 25
			if(2)
				value = 50
			if(3)
				value = 75
			else
				if(isXenoQueen(X)) //Queen is Tier 0 for some reason...
					value = 100

		if(owner == scorer)
			value *= 2

	else if(isHumanSynthStrict(target))
		switch(owner)
			if(TREE_NONE) // Survivors
				value = 60
			if(TREE_MARINE)
				value = 10

	return value

/// Handle consumption of a corpse by a spawn pool or eggmorpher and addition to base point pool
/datum/cm_objective/recover_corpses/proc/handle_corpse_consumption(datum/source, mob/target, target_hive)
	var/current = LAZYACCESS(points_base, TREE_XENO) // TODO handle mapping the day techtrees support multi hive
	current += score_corpse(target, TREE_XENO, TREE_XENO)
	LAZYSET(points_base, TREE_XENO, current)
	for(var/F as anything in corpses)
		LAZYREMOVE(corpses[F], target)

/datum/cm_objective/recover_corpses/process(delta_time)
	. = ..()
	if(!.)
		return

	// Reset points cache
	points_cache = list()
	for(var/F as anything in points_base)
		points_cache[F] = points_base[F]
		points_potential[F] = points_base[F]

	// Recompute all corpses ownership for scoring
	for(var/F as anything in corpses)
		for(var/mob/target as anything in corpses[F])
			if(QDELETED(target))
				LAZYREMOVE(corpses[F], target)
				continue

			// Get the corpse value
			var/marine_value = score_corpse(target, F, TREE_MARINE)
			points_potential[TREE_MARINE] += marine_value
			var/xeno_value   = score_corpse(target, F, TREE_XENO)
			points_potential[TREE_XENO] += xeno_value

			// Add points depending on who controls it
			var/turf/T = get_turf(target)
			var/area/A = get_area(T)
			if(istype(A, /area/almayer/medical/morgue) || istype(A, /area/almayer/medical/containment))
				points_cache[TREE_MARINE] += marine_value
			else
				var/obj/effect/alien/weeds/weed = locate() in T
				if(weed)
					if(weed?.weed_strength >= WEED_LEVEL_HIVE)
						points_cache[TREE_XENO] += xeno_value

/// Update awarded points to the controlling tech-faction
/datum/cm_objective/recover_corpses/award_points()
	for(var/F as anything in points_cache)
		var/current = points_cache[F]
		if(!current)
			continue
		if(!awarded_points[F])
			awarded_points[F] = 0
		var/diff = current - awarded_points[F]
		if(diff > 0)
			var/datum/techtree/TT = GET_TREE(F)
			if(TT)
				TT.add_points(diff * OBJ_VALUE_TO_TECHPOINTS)
				awarded_points[F] = current

/datum/cm_objective/recover_corpses/total_point_value(tree = TREE_NONE)
	if(tree == TREE_NONE || !points_potential[tree])
		return points_potential[TREE_MARINE]
	return points_potential[tree]

/datum/cm_objective/recover_corpses/get_completion_status(tree = TREE_NONE)
	if(tree == TREE_NONE) // Observer mode
		return "[points_cache[TREE_MARINE]]pts controlled by Marines (awarded [awarded_points[TREE_MARINE]]/[points_potential[TREE_MARINE]]pts), [points_cache[TREE_XENO]]pts controlled by Xenos (awarded [awarded_points[TREE_XENO]]/[points_potential[TREE_XENO]]pts)"

	var/enemy_points = 0
	var/claimable_points = points_potential[tree] - points_cache[tree]
	for(var/F as anything in points_cache)
		claimable_points -= points_base[F]
		if(F == tree) continue
		enemy_points += points_cache[F]
	return "<span class='objectivesuccess'>[points_cache[tree]]pts recovered</span>, [awarded_points[tree]]pts awarded, <span class='objectivefail'>[enemy_points]pts controlled by enemy</span>, [claimable_points]pts can still be reclaimed"

/datum/cm_objective/recover_corpses/get_point_value(tree = TREE_NONE)
	if(points_cache[tree])
		return points_cache[tree]
	return 0


/datum/cm_objective/contain
	// TODOIO make an equivalent for nesting capping
	name = "Contain alien specimens"
	objective_flags = OBJ_DO_NOT_TREE | OBJ_CONTROL_EXCLUSIVE
	display_flags = OBJ_DISPLAY_AT_END
	controller = TREE_MARINE
	var/area/recovery_area = /area/almayer/medical/containment/cell
	var/contained_specimen_points = 0

	var/points_per_specimen_tier_0 = 10
	var/points_per_specimen_tier_1 = 50
	var/points_per_specimen_tier_2 = 100
	var/points_per_specimen_tier_3 = 150
	var/points_per_specimen_tier_4 = 200

/datum/cm_objective/contain/process()
	contained_specimen_points = 0
	for(var/mob/living/carbon/Xenomorph/X as anything in GLOB.living_xeno_list)
		if(istype(get_area(X),recovery_area))
			switch(X.tier)
				if(1)
					if(isXenoPredalien(X))
						contained_specimen_points += points_per_specimen_tier_4
					else
						contained_specimen_points += points_per_specimen_tier_1
				if(2)
					contained_specimen_points += points_per_specimen_tier_2
				if(3)
					contained_specimen_points += points_per_specimen_tier_3
				else
					if(isXenoQueen(X)) //Queen is Tier 0 for some reason...
						contained_specimen_points += points_per_specimen_tier_4
					else
						contained_specimen_points += points_per_specimen_tier_0


	for(var/mob/living/carbon/human/Y in GLOB.yautja_mob_list)
		if(Y.stat == DEAD) continue
		if(istype(get_area(Y),recovery_area))
			contained_specimen_points += points_per_specimen_tier_4

/datum/cm_objective/contain/get_point_value()
	return contained_specimen_points

/datum/cm_objective/contain/total_point_value()
	//This objective is always 100% since tracking it otherwise would be really hard
	//Plus getting it is hard enough, so why not?
	return contained_specimen_points

/datum/cm_objective/contain/get_completion_status()
	return "[get_point_value()]pts Contained"
