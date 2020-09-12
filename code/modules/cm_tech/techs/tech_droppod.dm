var/global/list/unlocked_droppod_techs = list()

/datum/tech/droppod
    name = "droppod tech"
    desc = "placeholder description"

    var/list/already_accessed = list()

/datum/tech/droppod/show_info(var/mob/M)
    . = ..()

    var/list/data = .

    data["desc"] += SPAN_BOLDNOTICE("\nRequires an RTO; deployed via droppod.")

    return data

/datum/tech/droppod/on_unlock()
    unlocked_droppod_techs += src

    for(var/obj/item/storage/backpack/marine/satchel/rto/radio_pack in radio_packs)
        if(!radio_pack)
            continue

        if(ismob(radio_pack.loc))
            var/mob/M = radio_pack.loc
            if(!M.client)
                continue
            
            playsound_client(M.client, 'sound/items/bikehorn.ogg', M, 75)
        else
            playsound(radio_pack.loc, 'sound/items/bikehorn.ogg', 75)
    return

// Called as to whether on_pod_access should be called
/datum/tech/droppod/proc/can_access(var/mob/living/carbon/human/H, var/obj/structure/droppod/D)
    if(H.ckey in already_accessed)
        return FALSE
    
    return TRUE

// Called when attack_hand() on a pod, and can_access check has passed
/datum/tech/droppod/proc/on_pod_access(var/mob/living/carbon/human/H, var/obj/structure/droppod/D)
    already_accessed += H.ckey
    return

/datum/tech/droppod/proc/on_pod_created(var/obj/structure/droppod/D)
    return