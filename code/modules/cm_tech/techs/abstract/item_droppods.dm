/datum/tech/droppod/item
	name = "PLEASE SET ME!!!!!!"
	icon_state = "red"

	var/droppod_input_message = "Choose an item to retrieve from the droppod."

/datum/tech/droppod/item/proc/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	return list()

/datum/tech/droppod/item/on_pod_access(mob/living/carbon/human/H, obj/structure/droppod/D)
	var/list/options = get_options(H, D)
	if(!length(options))
		return

	var/player_input
	if(length(options) == 1)
		player_input = options[1]
	else
		player_input = tgui_input_list(H, droppod_input_message, name, options)

	if(!player_input || !can_access(H, D))
		return

	var/type_to_give = options[player_input]

	if(!type_to_give)
		return

	var/atom/item_to_give = new type_to_give()

	if(H.put_in_active_hand(item_to_give))
		. = ..()
	else
		qdel(item_to_give)

/datum/tech/droppod/item/on_unlock()
	. = ..()
	for(var/i in GLOB.radio_packs)
		var/obj/item/storage/backpack/marine/satchel/rto/backpack = i
		backpack.new_droppod_tech_unlocked(src)

