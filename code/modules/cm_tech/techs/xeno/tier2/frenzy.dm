/datum/tech/xeno/frenzy
	name = "Frenzy"
	desc = "The hive is put on a frenzy! Xenos move faster and more savagely rend flesh!"
	icon_state = "blue"

	flags = TREE_FLAG_XENO
	tech_flags = TECH_FLAG_MULTIUSE

	required_points = 20 // placeholder
	tier = /datum/tier/two

	var/active = FALSE
	var/frenzy_duration = 5 MINUTES // placeholder duration

/datum/tech/xeno/frenzy/can_unlock(mob/M, datum/techtree/tree)
	. = ..()
	if(!.)
		return
	if(active)
		to_chat(M, SPAN_WARNING("This tech is still active!"))
		return FALSE

/datum/tech/xeno/frenzy/on_unlock(datum/techtree/tree, target_or_targets)
	. = ..()
	active = TRUE
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, .proc/give_frenzy)
	for(var/xeno in hive.totalXenos)
		give_frenzy(src, xeno)
	addtimer(CALLBACK(src, .proc/end_frenzy), frenzy_duration)

/datum/tech/xeno/frenzy/proc/give_frenzy(datum/source, mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	if(X.hivenumber != hivenumber)
		return
	X.speed_modifier += XENO_SPEED_FASTMOD_TIER_2
	X.recalculate_speed()
	X.damage_modifier += XENO_DAMAGE_MOD_VERYSMALL
	X.recalculate_damage()
	to_chat(X, SPAN_XENODANGER("You are overcome with a frenzy!"))

/datum/tech/xeno/frenzy/proc/end_frenzy()
	active = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN)
	for(var/xeno in hive.totalXenos)
		var/mob/living/carbon/Xenomorph/X = xeno
		X.speed_modifier -= XENO_SPEED_FASTMOD_TIER_2
		X.recalculate_speed()
		X.damage_modifier -= XENO_DAMAGE_MOD_VERYSMALL
		X.recalculate_damage()
		to_chat(X, SPAN_XENODANGER("You are no longer overcome with a frenzy!"))
