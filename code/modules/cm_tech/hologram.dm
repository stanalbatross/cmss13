/mob/hologram
    name = "hologram"
    desc = "It seems to be a visual projection of someone" //jinkies!
    icon = 'icons/mob/mob.dmi'
    icon_state = "ghost"
    canmove = TRUE 
    blinded = 0

    mouse_opacity = FALSE

    var/mob/linked_mob
    var/datum/action/leave_hologram/leave_button
    alpha = 0

/mob/hologram/movement_delay()
    . = -2 // Very fast speed, so they can navigate through easily, they can't ever have movement delay whilst as a hologram

/mob/hologram/Initialize(mapload, var/mob/M)
    if(!M)
        return INITIALIZE_HINT_QDEL

    . = ..()

    RegisterSignal(M, COMSIG_CLIENT_MOB_MOVE, .proc/handle_move)
    RegisterSignal(M, COMSIG_MOB_RESET_VIEW, .proc/handle_view)
    RegisterSignal(M, COMSIG_MOB_TAKE_DAMAGE, .proc/take_damage)
    RegisterSignal(M, COMSIG_MOB_ENTER_TREE, .proc/disallow_tree_entering)

    linked_mob = M
    linked_mob.reset_view()

    leave_button = new()
    leave_button.linked_hologram = src
    leave_button.give_action(M)

/mob/hologram/proc/disallow_tree_entering(var/mob/M, var/datum/techtree/T, var/force)
    SIGNAL_HANDLER
    return COMPONENT_CANCEL_TREE_ENTRY

/mob/hologram/proc/take_damage(var/mob/M, var/damage, var/damagetype)
    SIGNAL_HANDLER
    
    if(damage > 5)
        qdel(src)

/mob/hologram/proc/handle_move(var/mob/M, NewLoc, direct)
    SIGNAL_HANDLER

    src.Move(get_step(src.loc, direct), direct)
    return COMPONENT_OVERRIDE_MOVE

/mob/hologram/proc/handle_view(var/mob/M, var/atom/target)
    if(M.client)
        M.client.perspective = EYE_PERSPECTIVE
        M.client.eye = src
    
    return COMPONENT_OVERRIDE_VIEW

/mob/hologram/Destroy()
    UnregisterSignal(linked_mob, COMSIG_MOB_RESET_VIEW)
    linked_mob.reset_view()
    linked_mob = null

    return ..()

/datum/action/leave_hologram
    name = "Leave"
    action_icon_state = "techtree_exit"

    var/mob/hologram/linked_hologram

/datum/action/leave_hologram/action_activate()
    remove_action(owner)

    QDEL_NULL(linked_hologram)
    qdel(src)

/datum/action/leave_hologram/Destroy()
    QDEL_NULL(linked_hologram)
    return ..()