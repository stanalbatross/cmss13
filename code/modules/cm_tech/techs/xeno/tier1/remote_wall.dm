/datum/tech/xeno/powerup/resin_pillar
	name = "Resin Pillar"
	desc = "Grant builder castes access to a temporary remotely-built two-by-two unbreakable wall for use as cover. Has limited uses."

	flags = TREE_FLAG_XENO

	required_points = 0
	var/charges_to_give = 5
	tier = /datum/tier/one

/datum/tech/xeno/powerup/resin_pillar/apply_powerup(mob/living/carbon/Xenomorph/target)
	var/datum/action/xeno_action/B = get_xeno_action_by_type(target, /datum/action/xeno_action/activable/resin_pillar)

	if(!B)
		B = give_action(target, /datum/action/xeno_action/activable/resin_pillar)

	B.charges += charges_to_give

/datum/tech/xeno/powerup/resin_pillar/get_applicable_xenos(var/mob/user)
	return hive.living_xeno_queen
