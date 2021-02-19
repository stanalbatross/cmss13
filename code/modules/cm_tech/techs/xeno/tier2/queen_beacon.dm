/datum/tech/xeno/powerup/queen_beacon
	name = "Queen Beacon"
	desc = "Rally the hive to a specific position!"
	icon_state = "blue"

	flags = TREE_FLAG_XENO
	powerup_type = POWERUP_QUEEN

	required_points = 20 // placeholder
	// tier = /datum/tier/two

/datum/tech/xeno/powerup/queen_beacon/apply_powerup(mob/living/carbon/Xenomorph/target)
	RegisterSignal(target, COMSIG_POWERUP_PRE_UNLOCK, .proc/cancel_unlock_active)
	var/datum/action/xeno_action/activable/place_queen_beacon/A = give_action(target, /datum/action/xeno_action/activable/place_queen_beacon)
	RegisterSignal(A, COMSIG_ACTION_REMOVED, .proc/untoggle_active)

/datum/tech/xeno/powerup/queen_beacon/proc/untoggle_active(datum/source, mob/owner)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ACTION_REMOVED)
	UnregisterSignal(owner, COMSIG_POWERUP_PRE_UNLOCK)
