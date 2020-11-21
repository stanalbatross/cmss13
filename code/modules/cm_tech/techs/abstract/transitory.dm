/datum/tech/transitory
    name = "Transitory tech"
    desc = "Transitions the tree to another tier."

    processing_info = TECH_NEVER_PROCESS

    var/datum/tier/before
    var/datum/tier/next

/datum/tech/transitory/can_unlock(var/mob/M, var/datum/techtree/tree) // messages_to is the 
    if(before && before != tree.tier.type)
        to_chat(M, SPAN_WARNING("You can't unlock this node!"))
        return
    
    return TRUE

/datum/tech/transitory/on_unlock(var/datum/techtree/tree)
    if(!next) return

    var/datum/tier/next_tier = LAZYACCESS(tree.tree_tiers, next)

    if(next_tier)
        tree.tier = next_tier
        for(var/a in next_tier.tier_turfs)
            var/turf/T = a
            T.color = next_tier.color
    
    return

/datum/tech/transitory/tier1
    name = "Unlock tier 1"
    tier = /datum/tier/free

    flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

    next = /datum/tier/one

/datum/tech/transitory/tier2
    name = "Unlock tier 2"
    tier = /datum/tier/one_transition_two

    flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

    before = /datum/tier/one
    next = /datum/tier/two

/datum/tech/transitory/tier3
    name = "Unlock tier 3"
    tier = /datum/tier/two_transition_three

    flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

    before = /datum/tier/two
    next = /datum/tier/three

/datum/tech/transitory/tier4
    name = "Unlock tier 4"
    tier = /datum/tier/three_transition_four

    flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

    before = /datum/tier/three
    next = /datum/tier/four
