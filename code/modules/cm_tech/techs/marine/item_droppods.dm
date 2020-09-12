/datum/tech/droppod/item
    name = "PLEASE SET ME!!!!!!"
    icon_state = "red"

    var/droppod_input_message = "Choose an item to retrieve from the droppod."

    var/list/options = list()

/datum/tech/droppod/item/on_pod_access(mob/living/carbon/human/H, obj/structure/droppod/D)
    
    var/player_input
    if(LAZYLEN(options) == 1)
        player_input = options[1]
    else
        player_input = input(H, droppod_input_message, name) as null|anything in options

    if(!D || !player_input)
        return

    var/type_to_give = options[player_input]

    var/atom/item_to_give = new type_to_give()

    if(H.put_in_active_hand(item_to_give))
        . = ..()
    else
        qdel(item_to_give)