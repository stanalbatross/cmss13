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

    eye = new(last_location)
    RegisterSignal(eye, COMSIG_MOB_MOVE, .proc/check_and_set_zlevel)
    RegisterSignal(eye, COMSIG_PARENT_QDELETING, .proc/remove_current_operator)

/obj/structure/machinery/computer/railgun/proc/check_and_set_zlevel(var/mob/hologram/H, var/turf/NewLoc, var/direction)
    if(H.z != target_z)
        H.z = target_z
        
/obj/structure/machinery/computer/railgun/proc/remove_current_operator()
    SIGNAL_HANDLER
    if(!operator) return

    if(eye)
        if(eye.gc_destroyed)
            eye = null
        else
            QDEL_NULL(eye)

    UnregisterSignal(operator, COMSIG_PARENT_QDELETING)
    UnregisterSignal(operator, COMSIG_MOB_MOVE)
    operator = null

/obj/structure/machinery/computer/railgun/attack_hand(var/mob/living/carbon/human/H)
    if(!..())
        return

    if(!istype(H))
        return

    if(operator && operator.stat == CONSCIOUS)
        to_chat(H, SPAN_WARNING("Someone is already using this computer!"))
        return

    remove_current_operator()