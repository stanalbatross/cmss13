var/global/list/unlocked_droppod_techs = list()

/datum/tech/droppod
	name = "droppod tech"
	desc = "placeholder description"

	var/list/already_accessed = list()

/datum/tech/droppod/ui_static_data(mob/user)
	. = ..()
	.["desc"] += "\nRequires an RTO; deployed via droppod."

/datum/tech/droppod/on_unlock()
	. = ..()

	unlocked_droppod_techs += src

	for(var/r in GLOB.radio_packs)
		var/atom/radio_pack = r
		playsound(radio_pack.loc, 'sound/items/bikehorn.ogg', 75)
	return

// Called as to whether on_pod_access should be called
/datum/tech/droppod/proc/can_access(var/mob/living/carbon/human/H, var/obj/structure/droppod/D)
	if(!D)
		return FALSE

	if(H.ckey in already_accessed)
		return FALSE

	return TRUE

// Called when attack_hand() on a pod, and can_access check has passed
/datum/tech/droppod/proc/on_pod_access(var/mob/living/carbon/human/H, var/obj/structure/droppod/D)
	already_accessed += H.ckey
	return

/datum/tech/droppod/proc/on_pod_created(var/obj/structure/droppod/D)
	return
