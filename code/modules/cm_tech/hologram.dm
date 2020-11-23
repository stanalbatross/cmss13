/mob/hologram
    name = "Hologram"
    desc = "It seems to be a visual projection of someone" //jinkies!
    icon = 'icons/mob/mob.dmi'
    icon_state = "hologram"
    canmove = TRUE 
    blinded = FALSE

    var/mob/linked_mob
    var/datum/action/leave_hologram/leave_button
    invisibility = INVISIBILITY_OBSERVER
    sight = SEE_SELF

/mob/hologram/movement_delay()
    . = -2 // Very fast speed, so they can navigate through easily, they can't ever have movement delay whilst as a hologram

/mob/hologram/Initialize(mapload, var/mob/M)
    if(!M)
        return INITIALIZE_HINT_QDEL

    . = ..()

    RegisterSignal(M, COMSIG_CLIENT_MOB_MOVE, .proc/handle_move)
    RegisterSignal(M, COMSIG_MOB_RESET_VIEW, .proc/handle_view)
    RegisterSignal(M, COMSIG_MOB_TAKE_DAMAGE, .proc/take_damage)
    RegisterSignal(M, COMSIG_HUMAN_TAKE_DAMAGE, .proc/take_damage)
    RegisterSignal(M, COMSIG_XENO_TAKE_DAMAGE, .proc/take_damage)
    

    linked_mob = M
    linked_mob.reset_view()

    name = "[initial(name)] ([M.name])"

    leave_button = new()
    leave_button.linked_hologram = src
    leave_button.give_action(M)

/mob/hologram/proc/take_damage(var/mob/M, var/damage, var/damagetype)
    SIGNAL_HANDLER
    
    if(damage > 5)
        qdel(src)

/mob/hologram/proc/handle_move(var/mob/M, NewLoc, direct)
    SIGNAL_HANDLER

    src.Move(get_step(src.loc, direct), direct)
    return COMPONENT_OVERRIDE_MOVE

/mob/hologram/proc/handle_view(var/mob/M, var/atom/target)
    SIGNAL_HANDLER

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
    qdel(src)

/datum/action/leave_hologram/Destroy()
    linked_hologram.leave_button = null
    QDEL_NULL(linked_hologram)
    return ..()

/mob/hologram/techtree/Initialize(mapload, mob/M)
    . = ..()
    RegisterSignal(M, COMSIG_MOB_ENTER_TREE, .proc/disallow_tree_entering)


/mob/hologram/techtree/proc/disallow_tree_entering(var/mob/M, var/datum/techtree/T, var/force)
    SIGNAL_HANDLER
    return COMPONENT_CANCEL_TREE_ENTRY