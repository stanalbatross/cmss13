/datum/techtree
    var/name = TREE_NONE

    var/resource_icon_state = ""

    var/flags = NO_FLAGS
    
    var/zlevel = 0

    var/list/cached_unlocked_techs = list()
    var/list/unlocked_techs = list() // Unlocked techs
    var/list/all_techs = list() // All techs that can be unlocked. Each sorted into tiers

    var/points = 0

    var/datum/tier/tier = /datum/tier/free

    var/turf/entrance

    var/resource_make_sound = 'sound/machines/click.ogg'
    var/resource_destroy_sound = 'sound/machines/click.ogg'

    var/resource_break_sound = 'sound/machines/click.ogg'
    var/resource_harvest_sound = 'sound/machines/click.ogg'

    var/resource_receive_process = FALSE

    var/obj/structure/resource_node/passive_node

    var/list/datum/tier/tree_tiers = TECH_TIER_GAMEPLAY

/datum/techtree/New()
    . = ..()

    for(var/type in tree_tiers)
        var/datum/tier/T = new type()

        T.holder = src
        tree_tiers[type] = T
        

    tier = tree_tiers[tier]

/datum/techtree/proc/generate_tree()
    if(!zlevel)
        return

    var/longest_tier = 0
    for(var/tier in all_techs)
        var/tier_length = length(all_techs[tier])
        if(longest_tier < tier_length)
            longest_tier = tier_length

    // Clear out the area
    for(var/turf/pos in block(locate(1, 1, zlevel), locate(longest_tier + 4, all_techs.len * 3 + 1, zlevel)))
        for(var/atom/A in pos)
            qdel(A)

        pos.ChangeTurf(/turf/open/blank)
        pos.color = "#000000"


    var/y_offset = 1
    for(var/tier in all_techs)
        var/tier_length = length(all_techs[tier])

        var/x_offset = (longest_tier - tier_length) + 1

        var/datum/tier/T = tree_tiers[tier]
        for(var/turf/pos in block(locate(x_offset, y_offset, zlevel), locate(x_offset + tier_length*2, y_offset + 2, zlevel)))
            pos.ChangeTurf(/turf/open/blank)
            pos.color = T.disabled_color
            LAZYADD(T.tier_turfs, pos)

        var/node_pos = x_offset + 1
        for(var/node in all_techs[tier])
            var/obj/effect/node/N = new(locate(node_pos, y_offset + 1, zlevel))
            N.info = all_techs[tier][node]
            node_pos += 2
        
        y_offset += 3

    entrance = locate(Ceiling((longest_tier*2 + 1)*0.5), 2, zlevel)

/datum/techtree/proc/can_use_points(var/datum/tech/T)
    if(!istype(T))
        return FALSE
    
    if(T.required_points <= points)
        return TRUE
    else
        return FALSE

/datum/techtree/proc/check_and_use_points(var/datum/tech/T)
    if(!can_use_points(T))
        return FALSE

    points -= T.required_points
    return TRUE

/datum/techtree/proc/has_access(var/mob/M, var/access_required)
    return FALSE

/datum/techtree/proc/purchase_node(var/mob/M, var/datum/tech/T)
    if(!M || M.stat == DEAD)
        return

    if(T.type in unlocked_techs[T.tier.type])
        M.show_message(SPAN_WARNING("This node is already unlocked!"))
        return
    
    if(!T.can_unlock(M, src))
        return

    unlock_node(T)
    
    to_chat(M, SPAN_HELPFUL("You have purchased the '[T]' tech node."))

/datum/techtree/proc/unlock_node(var/datum/tech/T)
    if((T.type in unlocked_techs[T.tier.type]) || !(T.type in all_techs[T.tier.type]))
        return

    T.unlocked = TRUE
    T.on_unlock(src)

    if(T.processing_info == TECH_UNLOCKED_PROCESS)
        GLOB.processing_techs.Add(T)

    unlocked_techs[T.tier.type] += list(T.type = T)
    cached_unlocked_techs += list(T.type = T)

/datum/techtree/proc/enter_mob(var/mob/M, var/force)
    if(!M.mind || M.stat == DEAD)
        return FALSE

    if(!has_access(M, TREE_ACCESS_VIEW) && !force)
        to_chat(M, SPAN_WARNING("You do not have access to this tech tree"))
        return FALSE

    if(SEND_SIGNAL(M, COMSIG_MOB_ENTER_TREE, src, force) & COMPONENT_CANCEL_TREE_ENTRY) return

    new/mob/hologram/techtree(entrance, M)

    return TRUE

/datum/techtree/proc/is_node_unlocked(var/name as text)
    return name in cached_unlocked_techs

/datum/techtree/proc/get_unlocked_node(var/name as text)
    return cached_unlocked_techs[name]

/datum/techtree/proc/on_node_gained(var/obj/structure/resource_node/RN)
    return

/datum/techtree/proc/on_node_lost(var/obj/structure/resource_node/RN)
    return

/datum/techtree/proc/on_cycle_completed(var/obj/structure/resource_node/RN)
    playsound(RN.loc, resource_harvest_sound, 50)
    return

/datum/techtree/proc/on_process(var/obj/structure/resource_node/RN)
    return

/datum/techtree/proc/can_attack(var/mob/living/carbon/H)
    return TRUE