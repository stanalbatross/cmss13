/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items/items.dmi'
	amount = 10
	max_amount = 10
	w_class = SIZE_SMALL
	throw_speed = SPEED_VERY_FAST
	throw_range = 20
	var/application_time = 2 SECONDS
	var/minimum_skill
	var/max_limb_damage
	var/list/wounds_stabilized = list()
	var/category
	var/icon/onbody_icon
	var/onbody_icon_state

/obj/item/stack/medical/Initialize(mapload, amount)
	. = ..()
	RegisterSignal(src, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_SELF), .proc/try_apply_to_limb)

/obj/item/stack/medical/proc/try_apply_to_limb(applied, mob/living/carbon/human/limb_owner, mob/user)
	if(isnull(user))
		user = limb_owner

	if(!istype(limb_owner) || user.a_intent == INTENT_HARM)
		return
	var/obj/limb/L = limb_owner.get_limb(user.zone_selected)
	if(isnull(L))
		return

	var/list/found = list()
	var/obj/item/stack/medical/prev_applied = null
	SEND_SIGNAL(L, COMSIG_LIMB_GET_APPLIED_ITEMS, found)

	if(length(found))
		for(var/obj/item/stack/medical/I in found)
			if(!istype(I))
				continue
			if(I.category == category)
				prev_applied = I
				break
	if(!skillcheck(user, SKILL_MEDICAL, minimum_skill))
		to_chat(user, SPAN_WARNING("You're not skilled enough to apply \the [src]."))
	else
		INVOKE_ASYNC(src, .proc/apply_to_limb, L, prev_applied, limb_owner, user)

	return COMPONENT_CANCEL_ATTACK

/obj/item/stack/medical/proc/apply_to_limb(obj/limb/L, obj/item/stack/medical/prev_applied, mob/limb_owner, mob/user)
	var/msg_apply
	var/obj/applied = src

	if(prev_applied)
		if(prev_applied.type == type)
			to_chat(user, SPAN_NOTICE("[limb_owner.name]'s [parse_zone(user.zone_selected)] already has \an [prev_applied.name] applied."))
			return	
		msg_apply = "replacing the [prev_applied.name] on [limb_owner.name]'s [parse_zone(user.zone_selected)] with the [src]"
	else
		msg_apply = "applying the [src] to [limb_owner.name]'s [parse_zone(user.zone_selected)]"

	to_chat(user, SPAN_NOTICE("You start [msg_apply]..."))
	if(do_after(user, application_time * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_ALL, BUSY_ICON_MEDICAL, limb_owner, INTERRUPT_OUT_OF_RANGE))
		if(prev_applied)
			prev_applied.remove_from_limb(L)

		if(amount > 1) //"Take out" from the stack
			use(1)
			applied = new type(L, 1)
		else
			user.drop_held_item()
			applied.forceMove(L) //applied == src

		applied.RegisterSignal(L, COMSIG_PRE_LOCAL_WOUND_EFFECTS, .proc/stabilize)
		applied.RegisterSignal(L, COMSIG_LIMB_TAKEN_DAMAGE, .proc/on_limb_damaged)
		applied.RegisterSignal(L, COMSIG_LIMB_GET_APPLIED_ITEMS, .proc/get_item)
		applied.RegisterSignal(applied, COMSIG_LIMB_ITEM_REMOVED, .proc/on_item_removed)

		SEND_SIGNAL(L, COMSIG_LIMB_WOUND_STABILIZER_ADDED)
		limb_owner.update_med_icon()

		to_chat(user, SPAN_HELPFUL("You succeed!"))

/obj/item/stack/medical/proc/stabilize(obj/limb/L, wound_type)
	SIGNAL_HANDLER
	if(wounds_stabilized.Find(wound_type))
		return COMPONENT_STABILIZE_WOUND

/obj/item/stack/medical/proc/on_limb_damaged(obj/limb/L, is_ff)
	SIGNAL_HANDLER
	if(!is_ff)
		var/dmg = L.brute_dam + L.burn_dam
		if(dmg > max_limb_damage)
			var/chance = (dmg - max_limb_damage) * 5
			if(prob(chance))
				remove_from_limb(L, TRUE)

/obj/item/stack/medical/proc/get_item(limb, list/item_list)
	SIGNAL_HANDLER
	item_list += src

/obj/item/stack/medical/proc/remove_from_limb(obj/limb/located_limb, destroy = FALSE)
	if(loc == located_limb)
		forceMove(get_turf(located_limb))
	
	on_item_removed(src, located_limb)

	if(destroy)
		qdel(src)

/obj/item/stack/medical/proc/on_item_removed(item, obj/limb/located_limb)
	SIGNAL_HANDLER
	if(item == src)
		UnregisterSignal(located_limb, list(COMSIG_PRE_LOCAL_WOUND_EFFECTS, COMSIG_LIMB_TAKEN_DAMAGE,
											COMSIG_LIMB_GET_APPLIED_ITEMS))
		UnregisterSignal(src, COMSIG_LIMB_ITEM_REMOVED)

		SEND_SIGNAL(located_limb, COMSIG_LIMB_WOUND_STABILIZER_REMOVED)

		located_limb.owner.update_med_icon()

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "medical gauze"
	desc = "Some sterile gauze to wrap around bloody stumps and lacerations."
	icon_state = "brutepack"

	stack_id = "bruise pack"
	onbody_icon_state = "gauze"
	category = CATEGORY_GAUZES

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat burns, infected wounds, and relieve itching in unusual places."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	stack_id = "ointment"

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"

	stack_id = "advanced bruise pack"
/obj/item/stack/medical/advanced/bruise_pack/predator
	name = "mending herbs"
	singular_name = "mending herb"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/items/hunter/pred_gear.dmi'
	icon_state = "brute_herbs"
	stack_id = "mending herbs"

/obj/item/stack/medical/advanced/ointment/predator
	name = "soothing herbs"
	singular_name = "soothing herb"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/items/hunter/pred_gear.dmi'
	icon_state = "burn_herbs"
	stack_id = "soothing herbs"

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"

	stack_id = "advanced burn kit"
/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "A collection of different splints and securing gauze. What, did you think we only broke legs out here?"
	icon_state = "splint"
	amount = 5
	max_amount = 5
	stack_id = "splint"

	var/indestructible_splints = FALSE
	application_time = 8 SECONDS
	wounds_stabilized = list(/datum/limb_wound/fracture)
	onbody_icon_state = "splint"
	category = CATEGORY_SPLINTS
