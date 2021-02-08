//finally a second element, oh wait
/datum/element/magnetic_sling
	element_flags = ELEMENT_DETACH

/datum/element/magnetic_sling/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/weapon/gun))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_PRE_THROW, .proc/cancel_throw)
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/dropped)

/datum/element/magnetic_sling/Detach(datum/source, force)
	UnregisterSignal(source, list(
		COMSIG_MOVABLE_PRE_THROW,
		COMSIG_ITEM_DROPPED,
	))
	return ..()

/datum/element/magnetic_sling/proc/cancel_throw(datum/source, mob/thrower)
	SIGNAL_HANDLER
	if(thrower)
		to_chat(thrower, SPAN_WARNING("The magnetic sling yanks your [source] and clings it to your back."))
	return COMPONENT_CANCEL_THROW

/datum/element/magnetic_sling/proc/dropped(obj/item/weapon/gun/G, mob/user)
	SIGNAL_HANDLER
	G.handle_sling(user)
