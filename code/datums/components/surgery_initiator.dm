/**
  *
  * Allows parent (obj) to initiate surgeries.
  *
  */
/datum/component/surgery_initiator
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///allows for post-selection manipulation of parent
	var/datum/callback/after_select_cb

/datum/component/surgery_initiator/Initialize(_after_select_cb)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	after_select_cb = _after_select_cb

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/datum/component/surgery_initiator/Destroy()
	if(after_select_cb)
		QDEL_NULL(after_select_cb)
	return ..()

	/**
	  *
	  * Does the surgery initiation.
	  *
	  */
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER_DOES_SLEEP

	if(!isliving(target))
		return
	var/mob/living/livingtarget = target
	var/mob/living/carbon/carbontarget
	var/obj/limb/affecting
	var/selected_zone = user.zone_selected
	if(iscarbon(livingtarget)) 
		carbontarget = target
		affecting = carbontarget.get_limb(check_zone(user.zone_selected))

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	var/datum/surgery/current_surgery

	for(var/i_one in livingtarget.surgeries)
		var/datum/surgery/surgeryloop = i_one
		if(surgeryloop.location == selected_zone)
			current_surgery = surgeryloop

	if(!current_surgery)
		var/list/all_surgeries = GLOB.surgeries_list.Copy()
		var/list/available_surgeries = list()

		for(var/i_two in all_surgeries)
			var/datum/surgery/surgeryloop_two = i_two
			if(!surgeryloop_two.possible_locs.Find(selected_zone))
				continue
			if(affecting)
				if(surgeryloop_two.requires_bodypart) //Temporary while limbs aren't LITERALLY removed
					if(affecting.destroyed)
						continue
				else
					if(!affecting.destroyed)
						continue
				if(surgeryloop_two.requires_bodypart_type && affecting.status != surgeryloop_two.requires_bodypart_type)
					continue
			else if(carbontarget && surgeryloop_two.requires_bodypart) //mob with no limb in surgery zone when we need a limb
				continue
			if(surgeryloop_two.lying_required && !livingtarget.lying)
				continue
			if(!surgeryloop_two.can_start(user, livingtarget))
				continue
			for(var/path in surgeryloop_two.target_mobtypes)
				if(istype(livingtarget, path))
					available_surgeries[surgeryloop_two.name] = surgeryloop_two
					break

		if(!available_surgeries.len)
			return

		var/pick_your_surgery = input("Begin which procedure?", "Surgery", null, null) as null|anything in sortList(available_surgeries)
		if(pick_your_surgery && user?.Adjacent(livingtarget) && (parent in user))
			var/datum/surgery/surgeryinstance_notonmob = available_surgeries[pick_your_surgery]

			for(var/i_three in livingtarget.surgeries)
				var/datum/surgery/surgeryloop_three = i_three
				if(surgeryloop_three.location == selected_zone)
					return //during the input() another surgery was started at the same location.

			//we check that the surgery is still doable after the input() wait.
			if(carbontarget)
				affecting = carbontarget.get_limb(check_zone(selected_zone))
			if(affecting)
				if(surgeryinstance_notonmob.requires_bodypart) //Temporary while limbs aren't LITERALLY removed
					if(affecting.destroyed)
						return
				else
					if(!affecting.destroyed)
						return
				if(surgeryinstance_notonmob.requires_bodypart_type && affecting.status != surgeryinstance_notonmob.requires_bodypart_type)
					return
			else if(carbontarget && surgeryinstance_notonmob.requires_bodypart)
				return
			if(surgeryinstance_notonmob.lying_required && !livingtarget.lying)
				return
			if(!surgeryinstance_notonmob.can_start(user, livingtarget))
				return

			var/datum/surgery/procedure = new surgeryinstance_notonmob.type(livingtarget, selected_zone, affecting)
			user.visible_message("<span class='notice'>[user] prepares [livingtarget]'s [parse_zone(selected_zone)] for surgery with \the [parent].</span>", \
				"<span class='notice'>You use \the [parent] to prepare [livingtarget]'s [parse_zone(selected_zone)] for \an [procedure.name].</span>")
			
			after_select_cb?.Invoke()
	else if(!current_surgery.step_in_progress)
		attempt_cancel_surgery(current_surgery, parent, livingtarget, user)

		/**
		  *
		  * Does the surgery de-initiation.
		  *
		  */
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, obj/item/the_item, mob/living/the_patient, mob/user)
	var/selected_zone = user.zone_selected

	if(the_surgery.status == 1)
		the_patient.surgeries -= the_surgery
		user.visible_message("<span class='notice'>[user] removes [the_item] from [the_patient]'s [parse_zone(selected_zone)].</span>", \
			"<span class='notice'>You remove [the_item] from [the_patient]'s [parse_zone(selected_zone)].</span>")
		qdel(the_surgery)
		return

	if(!the_surgery.can_cancel)
		return
	var/obj/item/tool/surgery/cautery/close_tool = user.get_inactive_hand()
	if(!istype(close_tool))
		to_chat(user, "<span class='warning'>You need to hold a cautery in your inactive hand to stop [the_patient]'s surgery!</span>")
		return

	the_patient.surgeries -= the_surgery
	user.visible_message("<span class='notice'>[user] closes [the_patient]'s [parse_zone(selected_zone)] with [close_tool] and removes [the_item].</span>", \
		"<span class='notice'>You close [the_patient]'s [parse_zone(selected_zone)] with [close_tool] and remove [the_item].</span>")
	qdel(the_surgery)