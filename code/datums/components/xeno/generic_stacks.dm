/datum/component/generic_stacks
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/stat_name
	var/max_stacks = 3
	var/stacks_per_slash = 1
	var/stored_stacks = 0

/datum/component/generic_stacks/Initialize(var/max_stacks = 3, var/stacks_per_slash = 1, var/stat_name = "Stacks", var/datum/behavior_delegate/BD)
	if(!isXeno(parent))
		return COMPONENT_INCOMPATIBLE

	src.max_stacks = max_stacks
	src.stacks_per_slash = stacks_per_slash
	src.stat_name = stat_name

/datum/component/generic_stacks/RegisterWithParent()
	RegisterSignal(parent, COMSIG_XENO_SLASH_ADDITIONAL_EFFECTS_SELF, .proc/handle_stacks_buildup)
	RegisterSignal(parent, COMSIG_XENO_APPEND_TO_STAT, .proc/handle_stat_display)

/datum/component/generic_stacks/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_XENO_SLASH_ADDITIONAL_EFFECTS_SELF,
		COMSIG_XENO_APPEND_TO_STAT
	))

/datum/component/generic_stacks/PostTransfer()
	if(!isXeno(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/generic_stacks/proc/handle_stat_display(var/mob/living/carbon/Xenomorph/X, var/list/statdata)
	SIGNAL_HANDLER
	statdata += "Stored [stat_name]: [stored_stacks]/[max_stacks]"

/datum/component/generic_stacks/proc/handle_stacks_buildup(var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	stored_stacks += stacks_per_slash
	if(stored_stacks < max_stacks)
		return
	if(isXenoWarrior(X))
		var/datum/behavior_delegate/warrior_base/BD = X.caste.behavior_delegate_type
		BD.increase_stack_level(1)
	stored_stacks = 0
	X.visible_message(SPAN_XENOWARNING("[X] roars as it mauls its target, its exoskeleton shimmering for a second!"), SPAN_XENOHIGHDANGER("You feel your rage increase your resiliency to damage!"))
	X.xeno_jitter(1 SECONDS)
	X.flick_heal_overlay(2 SECONDS, "#FFA800")
	X.emote("roar")
