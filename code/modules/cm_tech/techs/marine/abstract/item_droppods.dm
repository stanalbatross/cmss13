/datum/tech/droppod/item
    name = "PLEASE SET ME!!!!!!"
    icon_state = "red"

    var/droppod_input_message = "Choose an item to retrieve from the droppod."

    var/list/options = list()

/datum/tech/droppod/item/on_pod_access(mob/living/carbon/human/H, obj/structure/droppod/D, list/option_override)
    
    var/list/listToUse = options

    if(option_override)
        listToUse = option_override

    var/player_input
    if(LAZYLEN(listToUse) == 1)
        player_input = LAZYACCESS(listToUse, 1)
    else
        player_input = input(H, droppod_input_message, name) as null|anything in listToUse

    if(!D || !player_input)
        return

    var/type_to_give = LAZYACCESS(listToUse, player_input)

    if(!type_to_give)
        return

    var/atom/item_to_give = new type_to_give()

    if(H.put_in_active_hand(item_to_give))
        . = ..()
    else
        qdel(item_to_give)

/datum/tech/droppod/item/on_unlock()
    . = ..()
    for(var/obj/structure/transmitter/internal/I in transmitters)
        if(!istype(I.loc, /obj/item/storage/backpack/marine/satchel/rto))
            continue
        var/obj/item/storage/backpack/marine/satchel/rto/RTO = I.loc
        RTO.new_droppod_tech_unlocked(src)
            
        