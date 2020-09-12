var/global/list/transmitters = list()

/obj/structure/transmitter
    name = "\improper telephone receiver"
    icon = 'icons/obj/structures/structures.dmi'
    icon_state = "wall_phone"

    var/phone_id = "Telephone"

    var/obj/item/phone/attached_to

    var/obj/structure/transmitter/calling
    var/obj/structure/transmitter/caller

    var/next_ring = 0
    var/ring_channel = 0

    var/phone_type = /obj/item/phone

    var/enabled = TRUE

/obj/structure/transmitter/update_icon()
    . = ..()
    if(attached_to.loc != src)
        icon_state = "wall_phone_ear"
    else
        icon_state = "wall_phone"

/obj/structure/transmitter/Initialize(mapload, ...)
    . = ..()
    attached_to = new phone_type(src)
    update_icon()

    transmitters += src

/obj/structure/transmitter/internal/proc/set_external_object(var/atom/A)
    if(attached_to)
        if(attached_to.external_object)
            attached_to.external_object.to_untether = TRUE
        
        attached_to.external_object = A
        return TRUE

    return FALSE

#define TRANSMITTER_UNAVAILABLE(T) (T.get_calling_phone() || !T.attached_to || T.attached_to.loc != T || !T.enabled)

/proc/get_transmitters()
    var/list/phone_list = list()

    for(var/obj/structure/transmitter/T in transmitters)
        if(TRANSMITTER_UNAVAILABLE(T)) // Phone not available
            continue

        var/id = T.phone_id
        var/num_id = 1
        while(id in phone_list)
            id = "[T.phone_id] [num_id]"
            num_id++
        
        T.phone_id = id
        phone_list += list("[id]" = T)

    return phone_list

/obj/structure/transmitter/attack_hand(mob/user)
    . = ..()

    if(!attached_to || attached_to.loc != src)
        return

    if(!ishuman(user))
        return

    if(!enabled)
        return

    if(!get_calling_phone())
        var/list/transmitters = get_transmitters()
        transmitters -= phone_id

        if(!transmitters.len)
            to_chat(user, SPAN_PURPLE("[htmlicon(src, user)] No transmitters could be located to call!"))
            return

        var/to_call = input(user, "Select a station to call", "Call list") as null|anything in transmitters

        if(!to_call)
            return
        
        var/obj/structure/transmitter/T = transmitters[to_call]
        if(!istype(T) || QDELETED(T))
            transmitters -= T
            CRASH("Qdelled/improper atom inside transmitters list! (istype returned: [istype(T)], QDELETED returned: [QDELETED(T)])")
            return

        if(TRANSMITTER_UNAVAILABLE(T))
            return
        
        calling = T
        T.caller = src

        to_chat(user, SPAN_PURPLE("[htmlicon(src, user)] Dialing [to_call].."))

        processing_objects += T
    else
        var/obj/structure/transmitter/T = get_calling_phone()

        if(T.attached_to && ismob(T.attached_to.loc))
            var/mob/M = T.attached_to.loc
            to_chat(M, SPAN_PURPLE("[htmlicon(src, M)] [phone_id] has picked up."))
        
        to_chat(user, SPAN_PURPLE("[htmlicon(src, user)] Picked up a call from [T.phone_id]."))

    var/mob/living/carbon/human/H = user

    playsound(loc, null, channel = ring_channel)

    H.put_in_active_hand(attached_to)
    attached_to.setup_beam(H)
    
    update_icon()

#undef TRANSMITTER_UNAVAILABLE

/obj/structure/transmitter/proc/reset_call()
    var/obj/structure/transmitter/T = get_calling_phone()
    if(T)
        if(T.attached_to && ismob(T.attached_to.loc))
            var/mob/M = T.attached_to.loc
            to_chat(M, SPAN_PURPLE("[htmlicon(src, M)] [phone_id] has hung up on you."))

        if(attached_to && ismob(attached_to.loc))
            var/mob/M = attached_to.loc
            to_chat(M, SPAN_PURPLE("[htmlicon(src, M)] You have hung up on [T.phone_id]."))

    if(calling)
        processing_objects -= calling
        calling.caller = null
        calling = null
    
    if(caller)
        processing_objects -= caller
        caller.calling = null
        caller = null

    processing_objects -= src

/obj/structure/transmitter/process()
    if(caller)
        if(!attached_to)
            processing_objects -= src
            return

        if(attached_to.loc == src)
            if(next_ring < world.time)
                ring_channel = playsound(loc, 'sound/machines/telephone/telephone_ring.ogg', 75)
                next_ring = world.time + SECONDS_3

    else if(calling)
        var/obj/structure/transmitter/T = get_calling_phone()
        if(!T)
            processing_objects -= src
            return
        
        var/obj/item/phone/P = T.attached_to

        if(P && attached_to.loc == src && P.loc == T && next_ring < world.time)
            ring_channel = playsound(attached_to.loc, 'sound/machines/telephone/telephone_ring.ogg', 20) // placeholder for now, need a sound to tell that the phone is ringing
            next_ring = world.time + SECONDS_3
        
    else
        processing_objects -= src
        return


/obj/structure/transmitter/proc/recall_phone()
    if(ismob(attached_to.loc))
        var/mob/M = attached_to.loc
        M.drop_held_item(attached_to)
    
    attached_to.forceMove(src)
    attached_to.setup_beam()
    update_icon()

    reset_call()

/obj/structure/transmitter/proc/get_calling_phone()
    if(calling)
        return calling
    else if(caller)
        return caller

    return

/obj/structure/transmitter/proc/handle_speak(var/message, var/datum/language/L, var/mob/speaking)
    var/obj/structure/transmitter/T = get_calling_phone()

    if(!istype(T))
        return

    var/obj/item/phone/P = T.attached_to

    if(!P || !attached_to)
        return
    
    P.handle_hear(message, L, speaking)
    attached_to.handle_hear(message, L, speaking)

/obj/structure/transmitter/attackby(obj/item/W, mob/user)
    if(W == attached_to)
        recall_phone()
    else
        . = ..()

/obj/structure/transmitter/Dispose()
    . = ..()
    if(attached_to)
        if(attached_to.loc == src)
            qdel(attached_to)
        else
            attached_to.attached_to = null
            attached_to = null
    
    transmitters -= src

    reset_call()

/obj/item/phone
    name = "\improper telephone"
    icon = 'icons/obj/items/misc.dmi'
    icon_state = "rpb_phone"
    
    w_class = SIZE_LARGE

    var/obj/structure/transmitter/attached_to
    var/atom/external_object

    var/raised = FALSE

/obj/item/phone/Initialize(mapload)
    . = ..()
    if(istype(loc, /obj/structure/transmitter))
        attach_to(loc)
        external_object = attached_to
    
/obj/item/phone/Dispose()
    . = ..()
    remove_attached()

/obj/item/phone/proc/handle_speak(var/message, var/datum/language/L, var/mob/speaking)
    if(!attached_to)
        return

    attached_to.handle_speak(message, L, speaking)

/obj/item/phone/proc/handle_hear(var/message, var/datum/language/L, var/mob/speaking)
    if(!attached_to)
        return

    var/obj/structure/transmitter/T = attached_to.get_calling_phone()

    if(!T)
        return

    if(!ismob(loc))
        return

    var/loudness = 0
    if(raised)
        loudness = 3

    var/mob/M = loc
    var/vname = T.phone_id
    
    if(M == speaking)
        vname = attached_to.phone_id

    M.hear_radio(message, "says", L, part_a = "<span class='purple'><span class='name'>", part_b = "</span><span class='message'> ", vname = vname, speaker = speaking, command = loudness)

/obj/item/phone/proc/attach_to(var/obj/structure/transmitter/to_attach)
    if(!istype(to_attach))
        return

    remove_attached()

    attached_to = to_attach

/obj/item/phone/proc/remove_attached()
    attached_to = null
    external_object = null
    setup_beam()

/obj/item/phone/proc/on_beam_removed()
    set waitfor = FALSE
    . = ..()

    var/tether_to
    if(isturf(loc))
        tether_to = src
    else
        tether_to = loc

    if(isturf(external_object.loc))
        external_object = external_object
    else
        external_object = external_object.loc

    if(external_object && tether_to && external_object.Beam(tether_to, "wire", 'icons/effects/beam.dmi', -1, 5, FALSE, CALLBACK(src, .proc/on_beam_removed)))
        return .
    else if(attached_to)
        tether_to = null
        attached_to.recall_phone()

/obj/item/phone/attack_self(mob/user)
    if(raised)
        set_raised(FALSE, user)
        to_chat(user, SPAN_NOTICE("You lower [src]."))
    else
        set_raised(TRUE, user)
        to_chat(user, SPAN_NOTICE("You raise [src] to your ear."))
        

/obj/item/phone/proc/set_raised(var/to_raise, var/mob/living/carbon/human/H)
    if(!istype(H))
        return

    if(!to_raise)
        raised = FALSE
        item_state = "rpb_phone"

        var/obj/item/device/radio/R = H.wear_ear
        if(istype(R))
            R.on = TRUE
    else
        raised = TRUE
        item_state = "rpb_phone_ear"

        var/obj/item/device/radio/R = H.wear_ear
        if(istype(R))
            R.on = TRUE

    H.update_inv_r_hand()
    H.update_inv_l_hand()

/obj/item/phone/on_dropped(var/mob/user)
    . = ..()

    set_raised(FALSE, user)
    setup_beam(src)

/obj/item/phone/on_enter_storage(obj/item/storage/S)
    . = ..()
    if(attached_to)
        attached_to.recall_phone()

/obj/item/phone/pickup(mob/user)
    . = ..()
    setup_beam(user)

/obj/item/phone/proc/setup_beam(var/atom/A)
    if(external_object && A && external_object != A)
        external_object.to_untether = TRUE

        if(!external_object.tethered)
            on_beam_removed()