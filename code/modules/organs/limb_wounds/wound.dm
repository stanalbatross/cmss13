
/datum/limb_wound
    var/name = "Generic Wound"
    var/applied //Has this limb wound applied it's debuffs?
    var/local //Local wounds can be stabilized
    var/integrity_level //Integrity level associated with this wound
    var/mob/living/carbon/human/owner
    var/obj/limb/affected_limb

/datum/limb_wound/New(owner_mob, limb, level)
    owner = owner_mob
    owner.limb_wounds += src
    affected_limb = limb
    integrity_level = level
    . = ..()

    //Listen to the signal in case the initial application is blocked
    RegisterSignal(affected_limb, COMSIG_LIMB_WOUND_STABILIZER_REMOVED, .proc/try_apply_debuffs)
    try_apply_debuffs()
        
/datum/limb_wound/Destroy(force)
    if(applied)
        remove_debuffs()
    owner.limb_wounds -= src
    affected_limb = null
    owner = null
    return ..()

//Tries to apply the wound's debuffs
/datum/limb_wound/proc/try_apply_debuffs()
    SIGNAL_HANDLER
    if(check_stabilized(affected_limb) || affected_limb.integrity_level < integrity_level || applied)
        return
    apply_debuffs()

//Tries to remove the wound's debuffs, and the wound itself if the integrity level is below the required
/datum/limb_wound/proc/try_remove_debuffs()
    SIGNAL_HANDLER
    if(affected_limb.integrity_level < integrity_level) //Remove the wound
        qdel(src)
    else if(check_stabilized(affected_limb) && applied) //Only remove the debuff. Wound will try to apply the debuffs later
        remove_debuffs(affected_limb)

/datum/limb_wound/proc/check_stabilized()
    if(local)
        if(SEND_SIGNAL(affected_limb, COMSIG_PRE_LOCAL_WOUND_EFFECTS, type) & COMPONENT_STABILIZE_WOUND)
            return TRUE
    return FALSE

//These procs handle the effects of the debuff
/datum/limb_wound/proc/apply_debuffs()
    applied = TRUE

    UnregisterSignal(affected_limb, COMSIG_LIMB_WOUND_STABILIZER_REMOVED)
    RegisterSignal(affected_limb, list(COMSIG_LIMB_INTEGRITY_LOWERED, COMSIG_LIMB_WOUND_STABILIZER_ADDED), .proc/try_remove_debuffs)

/datum/limb_wound/proc/remove_debuffs()
    applied = FALSE

    UnregisterSignal(affected_limb, list(COMSIG_LIMB_INTEGRITY_LOWERED, COMSIG_LIMB_WOUND_STABILIZER_ADDED))
    RegisterSignal(affected_limb, COMSIG_LIMB_WOUND_STABILIZER_REMOVED, .proc/try_apply_debuffs)

