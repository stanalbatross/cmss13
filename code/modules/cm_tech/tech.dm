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

/datum/tech/proc/can_unlock(var/mob/M)
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
