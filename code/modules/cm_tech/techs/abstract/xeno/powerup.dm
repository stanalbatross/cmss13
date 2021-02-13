/datum/tech/xeno/powerup
	name = "Xeno Powerup Tech"

	tech_flags = TECH_FLAG_MULTIUSE

	var/powerup_type

	/// Blacklist for which castes cannot receive this powerup in the form of a typecache
	/// `null` if no caste is unable to receive this powerup
	var/list/caste_blacklist
	/// Whitelist for which castes can receive this powerup in the form of a typecache
	/// `null` if any caste can receive this powerup
	var/list/caste_whitelist

/datum/tech/xeno/powerup/check_tier_level(var/mob/M, var/datum/techtree/tree)
	. = ..()
	if(!.)
		return FALSE
	if(tree.tier.tier != tier.tier)
		to_chat(M, SPAN_WARNING("You can only buy powerup techs for the current tier level!"))
		return FALSE
	return TRUE

/// Override this proc if you want to apply any more or complex filters
/// to the candidates list
/datum/tech/xeno/powerup/proc/filter_through_candidates(list/candidates)
	return candidates

/**
 * At the minimum, the first argument to be passed should be the xeno or
 * list of xenos receiving the powerups
 */
/datum/tech/xeno/powerup/get_additional_args(var/mob/M)
	if(powerup_type == POWERUP_QUEEN)
		// Should be equivalent to M (at the time this was written)
		// but this is more readable
		return hive.living_xeno_queen

	var/list/potential_candidates
	for(var/x in hive.totalXenos)
		var/mob/living/carbon/Xenomorph/X = x
		if(caste_whitelist && !caste_whitelist[X.caste.type])
			continue
		if(caste_blacklist && caste_blacklist[X.caste.type])
			continue
		LAZYADD(potential_candidates, X)
	potential_candidates = filter_through_candidates(potential_candidates)
	if(!potential_candidates)
		return

	if(powerup_type == POWERUP_HIVEWIDE)
		// This list is nested because you don't want
		// each item passed as an individual argument
		return list(potential_candidates)
	else if(powerup_type == POWERUP_PICKED)
		var/mob/choice = tgui_input_list(M, "Which xenomorph do you want to powerup ?", "Apply [name]", potential_candidates)
		if(choice)
			return choice

/datum/tech/xeno/powerup/can_unlock(mob/M, datum/techtree/tree, target_or_targets)
	. = ..()
	if(!.)
		return FALSE
	if(!target_or_targets)
		to_chat(M, SPAN_WARNING("There are no xenomorphs who can accept this powerup!"))
		return FALSE
	if(!islist(target_or_targets))
		var/mob/target = target_or_targets
		if(SEND_SIGNAL(target, COMSIG_POWERUP_PRE_UNLOCK, M) & COMPONENT_CANNOT_UNLOCK)
			return FALSE
	return TRUE

/datum/tech/xeno/powerup/on_unlock(datum/techtree/tree, target_or_targets)
	. = ..()
	if(islist(target_or_targets))
		var/list/targets = target_or_targets
		for(var/target in targets)
			apply_powerup(target)
	else
		var/target = target_or_targets
		apply_powerup(target)

/datum/tech/xeno/powerup/proc/apply_powerup(mob/living/carbon/Xenomorph/target)
	return

/datum/tech/xeno/powerup/proc/cancel_unlock_active(datum/source, mob/M)
	SIGNAL_HANDLER
	to_chat(M, SPAN_WARNING("This powerup is still active!"))
	return COMPONENT_CANNOT_UNLOCK
