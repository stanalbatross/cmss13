/datum/tech/xeno/powerup
	name = "Xeno Powerup Tech"

	tech_flags = TECH_FLAG_MULTIUSE
	var/purchase_cooldown = 10 SECONDS
	var/next_purchase = 0

/datum/tech/xeno/powerup/check_tier_level(var/mob/M)
	. = ..()
	if(!.)
		return FALSE
	if(holder.tier.tier != tier.tier)
		to_chat(M, SPAN_WARNING("You can only buy powerup techs for the current tier level!"))
		return FALSE
	return TRUE

/datum/tech/xeno/powerup/can_unlock(mob/M)
	. = ..()
	if(next_purchase > world.time)
		to_chat(M, SPAN_WARNING("You recently purchased this powerup! Wait [DisplayTimeText(next_purchase - world.time, "ss")]"))
		return FALSE

/datum/tech/xeno/powerup/on_unlock(var/mob/M)
	var/list/applicable_xenos = get_applicable_xenos(M)
	if(!applicable_xenos)
		to_chat(M, SPAN_WARNING("No applicable xenos found! Refunding points."))
		return FALSE

	..()

	if(!islist(applicable_xenos))
		applicable_xenos = list(applicable_xenos)

	for(var/i in applicable_xenos)
		apply_powerup(i)

	next_purchase = world.time + purchase_cooldown
	return FALSE

/datum/tech/xeno/powerup/proc/get_applicable_xenos(mob/user)
	return

/datum/tech/xeno/powerup/proc/apply_powerup(mob/living/carbon/Xenomorph/target)
	return

/datum/tech/xeno/powerup/proc/cancel_unlock_active(datum/source, mob/M)
	SIGNAL_HANDLER
	to_chat(M, SPAN_WARNING("This powerup is still active!"))
	return COMPONENT_CANNOT_UNLOCK
