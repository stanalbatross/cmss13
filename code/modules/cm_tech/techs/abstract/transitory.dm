/datum/tech/transitory
    name = "Transitory tech"
    desc = "Transitions the tree to another tier."

    processing_info = TECH_NEVER_PROCESS

    var/datum/tier/before
    var/datum/tier/next

/datum/tech/transitory/check_tier_level(var/mob/M, var/datum/techtree/tree) // messages_to is the 
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
    var/techs_to_unlock = 3

    required_points = 0

/datum/tech/transitory/tier2/check_tier_level(var/mob/M, var/datum/techtree/tree)
    . = ..()

    if(!.)
        return .

    var/amount_of_unlocked_techs = LAZYLEN(tree.unlocked_techs[before])

    if(amount_of_unlocked_techs < techs_to_unlock)
        to_chat(M, SPAN_WARNING("You must unlock [techs_to_unlock - amount_of_unlocked_techs] techs from [initial(before.name)]"))
        return FALSE

/datum/tech/transitory/tier3
    name = "Unlock tier 3"
    tier = /datum/tier/two_transition_three

    flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

    required_points = 0

    before = /datum/tier/two
    next = /datum/tier/three

/datum/tech/transitory/tier4
    name = "Unlock tier 4"
    tier = /datum/tier/three_transition_four

    flags = TREE_FLAG_MARINE|TREE_FLAG_XENO

    required_points = 0

    before = /datum/tier/three
    next = /datum/tier/four

    // This is sadly disabled for now
    var/control_points_needed = 0.5

/datum/tech/transitory/tier4/check_tier_level(var/mob/M, var/datum/techtree/tree) // Can unlock this at any tier after 2
    if(tree.tier.tier < initial(before.tier))
        to_chat(M, SPAN_WARNING("You can't unlock this node!"))
        return
    
    /*
    var/list/resources = SStechtree.resources

    var/total = 0
    var/controlled = 0
    for(var/a in resources)
        var/obj/structure/resource_node/R = a

        if(!(R.z in GAME_PLAY_Z_LEVELS))
            continue

        if(R.tree == tree)
            controlled++
        
        total++

    */

    return TRUE