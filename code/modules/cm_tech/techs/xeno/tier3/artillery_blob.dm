/datum/tech/xeno/powerup/artillery_blob
	name = "Artillery Blob"
	desc = "The queen can fire a glob of gas to siege fortified enemies or stall attackers!"
	icon_state = "red"

	flags = TREE_FLAG_XENO
	powerup_type = POWERUP_QUEEN

	required_points = 20 // placeholder
	tier = /datum/tier/three

/datum/tech/xeno/powerup/artillery_blob/apply_powerup(mob/living/carbon/Xenomorph/target)
	RegisterSignal(target, COMSIG_POWERUP_PRE_UNLOCK, .proc/cancel_unlock_active)
	var/datum/action/xeno_action/activable/bombard/queen/B = give_action(target, /datum/action/xeno_action/activable/bombard/queen)
	RegisterSignal(B, COMSIG_ACTION_REMOVED, .proc/untoggle_active)

/datum/tech/xeno/powerup/artillery_blob/proc/untoggle_active(datum/source, mob/owner)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ACTION_REMOVED)
	UnregisterSignal(owner, COMSIG_POWERUP_PRE_UNLOCK)
