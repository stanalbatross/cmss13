GLOBAL_LIST_EMPTY_TYPED(railgun_computer_turf_position, /datum/railgun_computer_location)

/datum/tech/railgun
    name = "Enable Stellar Vessel Armements"
    desc = "Enables the two railguns attached to CIC, allowing for bombardment of enemy positions."
    icon_state = "red"

    flags = TREE_FLAG_MARINE

    required_points = 0
    tier = /datum/tier/three

/datum/tech/railgun/on_unlock(datum/techtree/tree)
    . = ..()

    for(var/a in GLOB.railgun_computer_turf_position)
        var/datum/railgun_computer_location/RCL = a
        var/obj/structure/machinery/computer/railgun/RG = new(RCL.location)
        RG.dir = RCL.direction

/datum/railgun_computer_location
    var/turf/location
    var/direction

/obj/effect/landmark/railgun_computer
    name = "Railgun computer landmark"

/obj/effect/landmark/railgun_computer/Initialize(mapload, ...)
    . = ..()
    var/datum/railgun_computer_location/RCL = new()
    RCL.location = loc
    RCL.direction = dir

    GLOB.railgun_computer_turf_position.Add(RCL)

    return INITIALIZE_HINT_QDEL

/obj/structure/machinery/computer/railgun
    name = "railgun computer"

    var/mob/hologram/railgun/eye
    var/turf/last_location
    var/target_z = SURFACE_Z_LEVEL

/obj/structure/machinery/computer/railgun/attackby(var/obj/I as obj, var/mob/user as mob)  //Can't break or disassemble.
	return

/obj/structure/machinery/computer/railgun/bullet_act(var/obj/item/projectile/Proj) //Can't shoot it
	return FALSE

/obj/structure/machinery/computer/railgun/proc/set_operator(var/mob/living/carbon/human/H)
    if(!istype(H))
        return
    remove_current_operator()

    operator = H
    RegisterSignal(operator, COMSIG_PARENT_QDELETING, .proc/remove_current_operator)
    RegisterSignal(operator, COMSIG_MOB_MOVE, .proc/remove_current_operator)

    if(!last_location)
        last_location = locate(1, 1, target_z)

    eye = new(last_location, operator)
    RegisterSignal(eye, COMSIG_MOB_MOVE, .proc/check_and_set_zlevel)
    RegisterSignal(eye, COMSIG_PARENT_QDELETING, .proc/remove_current_operator)

/obj/structure/machinery/computer/railgun/proc/check_and_set_zlevel(var/mob/hologram/railgun/H, var/turf/NewLoc, var/direction)
    if(!NewLoc)
        H.loc = last_location
        return COMPONENT_OVERRIDE_MOVE
        

    if(NewLoc.z != target_z && H.z != target_z)
        H.z = target_z
        return COMPONENT_OVERRIDE_MOVE
        
/obj/structure/machinery/computer/railgun/proc/remove_current_operator()
    SIGNAL_HANDLER
    if(!operator) return

    if(eye)
        last_location = eye.loc
        if(eye.gc_destroyed)
            eye = null
        else
            QDEL_NULL(eye)

    UnregisterSignal(operator, COMSIG_PARENT_QDELETING)
    UnregisterSignal(operator, COMSIG_MOB_MOVE)
    operator.update_sight()
    operator = null

/obj/structure/machinery/computer/railgun/attack_hand(var/mob/living/carbon/human/H)
    if(..())
        return

    if(!istype(H))
        return

    if(operator && operator.stat == CONSCIOUS)
        to_chat(H, SPAN_WARNING("Someone is already using this computer!"))
        return

    set_operator(H)

/mob/hologram/railgun
    name = "Camera"
    density = FALSE

/mob/hologram/railgun/Initialize(mapload, mob/M)
    . = ..(mapload, M)
    RegisterSignal(M, COMSIG_HUMAN_UPDATE_SIGHT, .proc/see_only_turf)
    RegisterSignal(src, COMSIG_TURF_ENTER, .proc/allow_turf_entry)
    M.update_sight()

/mob/hologram/railgun/proc/see_only_turf(var/mob/living/carbon/human/H)
    SIGNAL_HANDLER

    H.see_in_dark = 50
    H.sight = (SEE_TURFS|BLIND)
    H.see_invisible = SEE_INVISIBLE_MINIMUM
    return COMPONENT_OVERRIDE_UPDATE_SIGHT

/mob/hologram/railgun/handle_view(var/mob/M, var/atom/target)
    if(M.client)
        M.client.perspective = EYE_PERSPECTIVE
        M.client.eye = src

    return COMPONENT_OVERRIDE_VIEW

/mob/hologram/railgun/proc/allow_turf_entry()
    SIGNAL_HANDLER
    return COMPONENT_TURF_ALLOW_MOVEMENT