/datum/tech
    var/name = "tech"
    var/desc = "placeholder description"

    var/icon_state = "red"

    var/flags = NO_FLAGS

    var/processing_info = TECH_ALWAYS_PROCESS

    var/required_points = 0
    var/tier = TECH_TIER_ONE

    var/unlocked = FALSE

    var/datum/techtree/holder

/datum/tech/proc/fire()
    return

/datum/tech/proc/can_unlock(var/mob/M, var/datum/techtree/tree) // messages_to is the 
    if(!tree.has_access(M, TREE_ACCESS_MODIFY))
        to_chat(M, SPAN_WARNING("You lack the necessary permission required to use this tree"))
        return 

    var/datum/tier/t_target = GLOB.tech_tiers[tier]
    if(LAZYLEN(tree.unlocked_techs[tier]) >= t_target.max_techs)
        to_chat(M, SPAN_WARNING("You can't purchase any more techs of this tier!"))
        return

    if(!(type in tree.all_techs[tier]))
        to_chat(M, SPAN_WARNING("You cannot purchase this node!"))
        return
        
    if(!tree.check_and_use_points(src))
        to_chat(M, SPAN_WARNING("Not enough points to purchase this node."))
        return
    
    return TRUE

/datum/tech/proc/on_unlock()
    return

/datum/tech/proc/show_info(var/mob/M)
    var/total_points = 0
    if(holder)
        total_points = holder.points

    var/list/data = list(
        "xeno" = TREE_FLAG_XENO & flags,
        "name" = name,
        "desc" = desc,
        "cost" = required_points,
        "total_points" = total_points,
        "unlocked" = unlocked
    )

    return data
