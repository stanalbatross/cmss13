/datum/xeno_mutator/knight
	name = "STRAIN: Warrior - Knight"
	description = "In exchange for your ability to pounce and fling, as well as lowering your max HP, you become capable of generating a shield to withstand punishment for longer and your punch both hits harder and slows more."
	cost = MUTATOR_COST_EXPENSIVE
	individual_only = TRUE
	caste_whitelist = list(XENO_CASTE_WARRIOR)
	mutator_actions_to_remove = list(
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/warrior_punch
	)
	mutator_actions_to_add = list(
		/datum/action/xeno_action/activable/knight_crush,
		/datum/action/xeno_action/activable/knight_bash,
		/datum/action/xeno_action/onclick/hard_carapace

	)
	behavior_delegate_type = /datum/behavior_delegate/knight
	keystone = TRUE

/datum/xeno_mutator/knight/apply_mutator(datum/mutator_set/individual_mutators/MS)
	. = ..()
	if (. == 0)
		return
	var/mob/living/carbon/Xenomorph/Warrior/W = MS.xeno
	W.health_modifier -= XENO_HEALTH_MOD_MASSIVE
	W.agility = FALSE
	W.mutation_type = WARRIOR_KNIGHT
	apply_behavior_holder(W)
	mutator_update_actions(W)
	MS.recalculate_actions(description, flavor_description)

	W.recalculate_everything()
	W.mutation_type = WARRIOR_KNIGHT

/datum/action/xeno_action/onclick/hard_carapace
	name = "Harden Carapace"
	action_icon_state = "warden_shield"
	ability_name = "harden"
	macro_path = /datum/action/xeno_action/verb/verb_hard_carapace
	ability_primacy = XENO_PRIMARY_ACTION_3
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 300

/datum/action/xeno_action/activable/knight_bash
	name = "Launch"
	action_icon_state = "fling"
	ability_name = "Launch"
	macro_path = /datum/action/xeno_action/verb/verb_knight_bash
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 35

	var/bash_distance = 7
	var/bash_stun_power = 1
	var/bash_weaken_power = 2
	
/datum/action/xeno_action/activable/knight_crush
	name = "Crush"
	action_icon_state = "punch"
	ability_name = "Crush"
	macro_path = /datum/action/xeno_action/verb/verb_knight_crush
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 45

	var/knight_crush_damage = 20
	var/knight_crush_knockdown = 3
	var/damage_variance = 5
