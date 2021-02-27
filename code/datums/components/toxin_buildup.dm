/datum/component/toxic_buildup
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/toxic_buildup = 0
	var/toxic_buildup_dissipation = AMOUNT_PER_TIME(5, 10 SECONDS)
	var/max_buildup = 75

/datum/component/toxic_buildup/Initialize(var/toxic_buildup, var/toxic_buildup_dissipation = AMOUNT_PER_TIME(1, 3 SECONDS), var/max_buildup = 75)
	. = ..()
	src.toxic_buildup = toxic_buildup
	src.toxic_buildup_dissipation = toxic_buildup_dissipation
	src.max_buildup = max_buildup

/datum/component/toxic_buildup/InheritComponent(datum/component/toxic_buildup/C, i_am_original, var/toxic_buildup)
	. = ..()
	if(!C)
		src.toxic_buildup += toxic_buildup
	else
		src.toxic_buildup += C.toxic_buildup

	src.toxic_buildup = min(src.toxic_buildup, max_buildup)

/datum/component/toxic_buildup/process(delta_time)
	toxic_buildup = max(toxic_buildup - toxic_buildup_dissipation * delta_time, 0)

	if(toxic_buildup <= 0)
		qdel(src)

/datum/component/toxic_buildup/RegisterWithParent()
	START_PROCESSING(SSdcs, src)
	RegisterSignal(parent, list(
		COMSIG_XENO_PRE_CALCULATE_ARMOURED_DAMAGE,
		COMSIG_XENO_PRE_APPLY_ARMOURED_DAMAGE
	), .proc/apply_toxic_buildup)

/datum/component/toxic_buildup/UnregisterFromParent()
	STOP_PROCESSING(SSdcs, src)
	UnregisterSignal(parent, list(
		COMSIG_XENO_PRE_CALCULATE_ARMOURED_DAMAGE,
		COMSIG_XENO_PRE_APPLY_ARMOURED_DAMAGE
	))

/datum/component/toxic_buildup/proc/apply_toxic_buildup(var/mob/living/carbon/Xenomorph/X, var/list/damagedata)
	SIGNAL_HANDLER
	damagedata["armor"] = max(damagedata["armor"] - toxic_buildup, 0)
