/obj/item/device/paddles
	name = "paddles"
	icon_state = "paddles"

	w_class = SIZE_LARGE

	var/obj/item/device/defibrillator/attached_to
	var/datum/effects/tethering/tether_effect

	var/zlevel_transfer = FALSE
	var/zlevel_transfer_timer = TIMER_ID_NULL
	var/zlevel_transfer_timeout = 5 SECONDS
	var/charged = FALSE

	var/wieldsound = null

	var/skill_req = SKILL_MEDICAL_MEDIC
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	var/datum/effect_system/spark_spread/sparks = new

/obj/item/device/paddles/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/device/defibrillator))
		attach_to(loc)

	sparks.set_up(5, 0, src)
	sparks.attach(src)

	name = "[attached_to.name] [name]"
	icon_state = "[attached_to.icon_state_for_paddles]_[icon_state]"

/obj/item/device/paddles/Destroy()
	remove_attached()
	return ..()

/obj/item/device/paddles/proc/attach_to(var/obj/item/device/defibrillator/to_attach)
	if(!istype(to_attach))
		return

	remove_attached()

	attached_to = to_attach

/obj/item/device/paddles/proc/remove_attached()
	attached_to = null
	reset_tether()

/obj/item/device/paddles/proc/reset_tether()
	SIGNAL_HANDLER
	if (tether_effect)
		UnregisterSignal(tether_effect, COMSIG_PARENT_QDELETING)
		if(!QDESTROYING(tether_effect))
			qdel(tether_effect)
		tether_effect = null
	if(!do_zlevel_check())
		on_beam_removed()

/obj/item/device/paddles/proc/on_beam_removed()
	if(!attached_to)
		return

	if(loc == attached_to)
		return

	if(get_dist(attached_to, src) > attached_to.range)
		unwield()
		attached_to.recall_paddles()

	var/atom/tether_to = src

	if(loc != get_turf(src))
		tether_to = loc
		if(tether_to.loc != get_turf(tether_to))
			unwield()
			attached_to.recall_paddles()
			return

	var/atom/tether_from = attached_to

	if(attached_to.tether_holder)
		tether_from = attached_to.tether_holder

	if(tether_from == tether_to)
		return

	var/list/tether_effects = apply_tether(tether_from, tether_to, range = attached_to.range, icon = "paddles_wire", always_face = FALSE)
	tether_effect = tether_effects["tetherer_tether"]
	RegisterSignal(tether_effect, COMSIG_PARENT_QDELETING, .proc/reset_tether)

/obj/item/device/paddles/attack_self(mob/user)
	..()

	if(flags_item & WIELDED)
		unwield(user) // Trying to unwield it
	else
		wield(user) // Trying to wield it

/obj/item/device/paddles/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(attached_to.defib_cooldown > world.time) //Both for pulling the paddles out (2 seconds) and shocking (1 second)
		return

	attached_to.defib_cooldown = world.time + 20 //2 second cooldown before you can try shocking again

	if(user.action_busy) //Currently deffibing
		return

	//job knowledge requirement
	if(user.skills)
		if(!skillcheck(user, SKILL_MEDICAL, skill_req))
			to_chat(user, SPAN_WARNING("You don't seem to know how to use [src]..."))
			return

	if(!charged)
		to_chat(user, SPAN_WARNING("You need charge [src]..."))
		return

	if(!(flags_item & WIELDED))
		to_chat(user, SPAN_WARNING("You need wield [src]..."))
		return

	if(!attached_to.check_revive(H, user))
		return

	var/mob/dead/observer/G = H.get_ghost()
	if(istype(G) && G.client)
		playsound_client(G.client, 'sound/effects/adminhelp_new.ogg')
		to_chat(G, SPAN_BOLDNOTICE(FONT_SIZE_LARGE("Someone is trying to revive your body. Return to it if you want to be resurrected! \
			(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[G];reentercorpse=1'>click here!</a>)")))

	user.visible_message(SPAN_NOTICE("[user] starts setting up the paddles on [H]'s chest"), \
		SPAN_HELPFUL("You start <b>setting up</b> the paddles on <b>[H]</b>'s chest."))

	//Taking square root not to make defibs too fast...
	overlays += image(icon, "+paddle_zap")
	if(!do_after(user, 1 SECONDS * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_NO_NEEDHAND|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY, H, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
		user.visible_message(SPAN_WARNING("[user] stops setting up the paddles on [H]'s chest"), \
		SPAN_WARNING("You stop setting up the paddles on [H]'s chest"))
		update_icon()
		attached_to.update_icon()
		return

	if(!attached_to.check_revive(H, user))
		update_icon()
		attached_to.update_icon()
		return

	//Do this now, order doesn't matter
	sparks.start()
	attached_to.sparks.start()
	attached_to.dcell.use(attached_to.charge_cost)
	charged = FALSE
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] shocks [H] with the paddles."),
		SPAN_HELPFUL("You shock <b>[H]</b> with the paddles."))
	H.visible_message(SPAN_DANGER("[H]'s body convulses a bit."))
	attached_to.defib_cooldown = world.time + 40
	update_icon()
	attached_to.update_icon()

	var/datum/internal_organ/heart/heart = H.internal_organs_by_name["heart"]
	if(heart && prob(25))
		heart.damage += attached_to.heart_damage_to_deal //Allow the defibrilator to possibly worsen heart damage. Still rare enough to just be the "clone damage" of the defib

	if(!H.is_revivable())
		if(heart && heart.is_broken())
			user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Defibrillation failed. Patient's heart is too damaged. Immediate surgery is advised."))
			return
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Defibrillation failed. Patient's general condition does not allow reviving."))
		return

	if(!H.client) //Freak case, no client at all. This is a braindead mob (like a colonist)
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: No soul detected, Attempting to revive..."))

	if(isobserver(H.mind?.current) && !H.client) //Let's call up the correct ghost! Also, bodies with clients only, thank you.
		H.mind.transfer_to(H, TRUE)

	//At this point, the defibrillator is ready to work
	H.apply_damage(-attached_to.damage_heal_threshold, BRUTE)
	H.apply_damage(-attached_to.damage_heal_threshold, BURN)
	H.apply_damage(-attached_to.damage_heal_threshold, TOX)
	H.apply_damage(-attached_to.damage_heal_threshold, CLONE)
	H.apply_damage(-H.getOxyLoss(), OXY)
	H.updatehealth() //Needed for the check to register properly

	if(!(H.species?.flags & NO_CHEM_METABOLIZATION))
		for(var/datum/reagent/R in H.reagents.reagent_list)
			var/datum/chem_property/P = R.get_property(PROPERTY_ELECTROGENETIC)//Adrenaline helps greatly at restarting the heart
			if(P)
				P.trigger(H)
				H.reagents.remove_reagent(R.id, 1)
				break
	if(H.health > HEALTH_THRESHOLD_DEAD)
		user.visible_message(SPAN_NOTICE("[icon2html(src, viewers(src))] \The [src] beeps: Defibrillation successful."))
		user.track_life_saved(user.job)
		if(attached_to.defib_mode == FULL_MODE_DEF)
			H.electrocute_act(120, src)//god damn Doktor...
			to_chat(H, SPAN_NOTICE("You got shocked!"))
		H.handle_revive()
		to_chat(H, SPAN_NOTICE("You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane."))
		if(H.client?.prefs.toggles_flashing & FLASH_CORPSEREVIVE)
			window_flash(H.client)
	else
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Defibrillation failed. Vital signs are too weak, repair damage and try again.")) //Freak case
		H.electrocute_act(40, src)


/obj/item/device/paddles/on_enter_storage(obj/item/storage/S)
	. = ..()
	if(attached_to)
		unwield()
		attached_to.recall_paddles()

/obj/item/device/paddles/forceMove(atom/dest)
	. = ..()
	if(.)
		reset_tether()

/obj/item/device/paddles/proc/do_zlevel_check()
	if(!attached_to || !loc.z || !attached_to.z)
		return FALSE

	if(zlevel_transfer)
		if(loc.z == attached_to.z)
			zlevel_transfer = FALSE
			if(zlevel_transfer_timer)
				deltimer(zlevel_transfer_timer)
			UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
			return FALSE
		return TRUE

	if(attached_to && loc.z != attached_to.z)
		zlevel_transfer = TRUE
		zlevel_transfer_timer = addtimer(CALLBACK(src, .proc/try_doing_tether), zlevel_transfer_timeout, TIMER_UNIQUE|TIMER_STOPPABLE)
		RegisterSignal(attached_to, COMSIG_MOVABLE_MOVED, .proc/paddles_move_handler)
		return TRUE
	return FALSE

/obj/item/device/paddles/proc/paddles_move_handler(var/datum/source)
	SIGNAL_HANDLER
	zlevel_transfer = FALSE
	if(zlevel_transfer_timer)
		deltimer(zlevel_transfer_timer)
	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
	reset_tether()

/obj/item/device/paddles/proc/try_doing_tether()
	zlevel_transfer_timer = TIMER_ID_NULL
	zlevel_transfer = FALSE
	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
	reset_tether()

/obj/item/device/paddles/clicked(mob/user, list/mods)
	if(!ishuman(usr))
		return
	if(mods["alt"])
		paddles_charge(user)
		return 1
	return ..()

/obj/item/device/paddles/proc/paddles_charge(mob/user)
	if(!skillcheck(user, SKILL_MEDICAL, skill_req))
		to_chat(user, SPAN_WARNING("You don't seem to know how to use [src]..."))
		return
	if(user.action_busy)
		return

	if(!(flags_item & WIELDED))
		to_chat(user, SPAN_WARNING("You need wield [src]..."))
		return

	if(charged)
		to_chat(user, SPAN_NOTICE("You already charged it."))
		return
	else
		charged = TRUE
		user.visible_message(SPAN_NOTICE("[user] starts charging the paddles"), \
		SPAN_HELPFUL("You start <b>charging</b> the paddles."))
		playsound(get_turf(src), "sparks", 30, 2, 5)
		playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) //Do NOT vary this tune, it needs to be precisely 7 seconds
		if(!do_after(user, attached_to.defib_recharge * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_NO_NEEDHAND|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY, user, INTERRUPT_ALL))
			user.visible_message(SPAN_NOTICE("[user] stop charging the paddles"), \
			SPAN_HELPFUL("You stop <b>charging</b> the paddles."))
			charged = FALSE
			return
		sparks.start()
		attached_to.sparks.start()
		playsound(get_turf(src), "sparks", 25, 1, 4)
		update_icon()
		user.visible_message(SPAN_NOTICE("[user] charges the paddles"), \
		SPAN_HELPFUL("You <b>charges</b> the paddles."))

/obj/item/device/paddles/unwield(mob/user)
	if( (flags_item|WIELDED) != flags_item)
		return FALSE//Have to be actually a wielded.
	flags_item ^= WIELDED
	SEND_SIGNAL(src, COMSIG_ITEM_UNWIELD, user)
	name 	    = copytext(name,1,-10)
	item_state  = copytext(item_state,1,-2)
	remove_offhand(user)
	return TRUE

/obj/item/device/paddles/place_offhand(var/mob/user,item_name)
	to_chat(user, SPAN_NOTICE("You grab [item_name] with both hands."))
	user.recalculate_move_delay = TRUE
	var/obj/item/device/paddles/offhand/offhand = new /obj/item/device/paddles/offhand(user)
	offhand.name = "[item_name] - offhand"
	offhand.desc = "Your second grip on the [item_name]."
	offhand.flags_item |= WIELDED
	update_icon()
	offhand.icon_state = icon_state
	user.put_in_inactive_hand(offhand)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand()

/obj/item/device/paddles/remove_offhand(var/mob/user)
	to_chat(user, SPAN_NOTICE("You are now grab [name] with one hand."))
	user.recalculate_move_delay = TRUE
	var/obj/item/device/paddles/offhand/offhand = user.get_inactive_hand()
	if(istype(offhand)) offhand.unwield(user)
	update_icon()
	user.update_inv_l_hand(0)
	user.update_inv_r_hand()

/obj/item/device/paddles/wield(mob/user)
	if(flags_item & WIELDED) return

	var/obj/item/I = user.get_inactive_hand()
	if(I)
		user.drop_inv_item_on_ground(I)

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/obj/limb/hand = wielder.get_limb(check_hand)
		if( !istype(hand) || !hand.is_usable() )
			to_chat(user, SPAN_WARNING("Your other hand can't hold [src]!"))
			return

	flags_item 	   ^= WIELDED
	name 	   += " (Wielded)"
	place_offhand(user,initial(name))
	user.recalculate_move_delay = TRUE
	if(wieldsound) playsound(user, wieldsound, 15, 1)

/obj/item/device/paddles/update_icon()
	update_overlays()

	icon_state = initial(icon_state)

	icon_state = "[icon_state]_[attached_to.icon_state_for_paddles]"
	if(flags_item & WIELDED)
		icon_state += "_paddle"

/obj/item/device/paddles/proc/update_overlays()
	if(overlays) overlays.Cut()

///////////OFFHAND///////////////
/obj/item/device/paddles/offhand
	w_class = SIZE_HUGE
	icon_state = "offhand"
	name = "offhand"
	flags_item = DELONDROP|TWOHANDED|WIELDED

/obj/item/device/paddles/offhand/unwield(var/mob/user)
	if(flags_item & WIELDED)
		flags_item &= ~WIELDED
		user.temp_drop_inv_item(src)
		qdel(src)

/obj/item/device/paddles/offhand/wield()
	qdel(src) //This shouldn't even happen.

/obj/item/device/paddles/offhand/dropped(mob/user)
	..()
	//This hand should be holding the main weapon. If everything worked correctly, it should not be wielded.
	//If it is, looks like we got our hand torn off or something.
	if(!QDESTROYING(src))
		var/obj/item/main_hand = user.get_active_hand()
		if(main_hand) main_hand.unwield(user)

#undef LOW_MODE_RECH
#undef HALF_MODE_RECH
#undef FULL_MODE_RECH

#undef LOW_MODE_CHARGE
#undef HALF_MODE_CHARGE
#undef FULL_MODE_CHARGE

#undef LOW_MODE_DMGHEAL
#undef HALF_MODE_DMGHEAL
#undef FULL_MODE_DMGHEAL

#undef LOW_MODE_HEARTD
#undef HALF_MODE_HEARTD
#undef FULL_MODE_HEARTD

#undef LOW_MODE_DEF
#undef HALF_MODE_DEF
#undef FULL_MODE_DEF