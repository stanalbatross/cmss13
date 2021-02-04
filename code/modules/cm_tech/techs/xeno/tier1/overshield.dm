/datum/tech/xeno/powerup/overshield
	name = "Temporary Overshield"
	desc = "Give the hive overshields for protection!"
	icon_state = "red"

	flags = TREE_FLAG_XENO
	powerup_type = POWERUP_HIVEWIDE

	required_points = 5 // placeholder

/datum/tech/xeno/powerup/overshield/apply_powerup(mob/living/carbon/Xenomorph/target)
	// placeholder values for overshield amount and time
	target.add_xeno_shield(200, XENO_SHIELD_SOURCE_OVERSHIELD_TECH, duration = 5 MINUTES)
