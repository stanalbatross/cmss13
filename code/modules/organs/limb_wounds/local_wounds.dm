/datum/limb_wound/fracture
	name = "Fracture"
	local = TRUE

/datum/limb_wound/fracture/apply_debuffs()
	..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/walk_damage)

/datum/limb_wound/fracture/remove_debuffs()
	..()    
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/limb_wound/fracture/proc/walk_damage()
	SIGNAL_HANDLER
	if((!owner.lying && world.time - owner.l_move_time < 2 SECONDS) && affected_limb.integrity_damage < LIMB_INTEGRITY_BONE_MOVEMENT_CAP)
		to_chat(owner, SPAN_WARNING("You feel your [affected_limb.display_name]'s bones shift around, further ripping and damaging it!"))
		affected_limb.take_integrity_damage(PASSIVE_INT_DAMAGE_PER_STEP)