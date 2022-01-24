/obj/item/paddles
	name = "telephone"
	icon = 'icons/obj/items/misc.dmi'
	icon_state = "paddles"

	w_class = SIZE_LARGE

	var/obj/item/device/defibrillator/attached_to
	var/datum/effects/tethering/tether_effect

	var/raised = FALSE
	var/zlevel_transfer = FALSE
	var/zlevel_transfer_timer = TIMER_ID_NULL
	var/zlevel_transfer_timeout = 5 SECONDS
	var/charging = FALSE

	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	var/datum/effect_system/spark_spread/sparks = new

/obj/item/paddles/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/structure/transmitter))
		attach_to(loc)

	sparks.set_up(5, 0, src)
	sparks.attach(src)

/obj/item/paddles/Destroy()
	remove_attached()
	return ..()

/obj/item/paddles/proc/attach_to(var/obj/item/device/defibrillator/to_attach)
	if(!istype(to_attach))
		return

	remove_attached()

	attached_to = to_attach


/obj/item/paddles/proc/remove_attached()
	attached_to = null
	reset_tether()

/obj/item/paddles/proc/reset_tether()
	SIGNAL_HANDLER
	if (tether_effect)
		UnregisterSignal(tether_effect, COMSIG_PARENT_QDELETING)
		if(!QDESTROYING(tether_effect))
			qdel(tether_effect)
		tether_effect = null
	if(!do_zlevel_check())
		on_beam_removed()

/obj/item/paddles/attack_hand(mob/user)
	if(attached_to && get_dist(user, attached_to) > attached_to.range)
		return FALSE
	return ..()


/obj/item/paddles/proc/on_beam_removed()
	if(!attached_to)
		return

	if(loc == attached_to)
		return

	if(get_dist(attached_to, src) > attached_to.range)
		attached_to.recall_paddles()

	var/atom/tether_to = src

	if(loc != get_turf(src))
		tether_to = loc
		if(tether_to.loc != get_turf(tether_to))
			attached_to.recall_paddles()
			return

	var/atom/tether_from = attached_to

	if(attached_to.tether_holder)
		tether_from = attached_to.tether_holder

	if(tether_from == tether_to)
		return

	var/list/tether_effects = apply_tether(tether_from, tether_to, range = attached_to.range, icon = "wire", always_face = FALSE)
	tether_effect = tether_effects["tetherer_tether"]
	RegisterSignal(tether_effect, COMSIG_PARENT_QDELETING, .proc/reset_tether)

/obj/item/paddles/attack_self(mob/user)
	..()
	if(!skillcheck(user, SKILL_MEDICAL, attached_to.skill_req))
		to_chat(user, SPAN_WARNING("You don't seem to know how to use [src]..."))
		return
	if(user.action_busy)
		return
	if(!charging)
		to_chat(user, SPAN_NOTICE("You already charging it."))
	else
		playsound(get_turf(src), "sparks", 30, 2, 5)
		if(!do_after(user, attached_to.defib_recharge * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_NO_NEEDHAND|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY, user, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
			to_chat(user, SPAN_NOTICE("Charge not complited!"))
			return
		playsound(get_turf(src), "sparks", 25, 1, 4)
		charging = TRUE
		to_chat(user, SPAN_NOTICE("You charges defib"))


/obj/item/paddles/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(attached_to.defib_cooldown > world.time) //Both for pulling the paddles out (2 seconds) and shocking (1 second)
		return

	attached_to.defib_cooldown = world.time + 20 //2 second cooldown before you can try shocking again

	if(user.action_busy) //Currently deffibing
		return

	//job knowledge requirement
	if(user.skills)
		if(!skillcheck(user, SKILL_MEDICAL, attached_to.skill_req))
			to_chat(user, SPAN_WARNING("You don't seem to know how to use [src]..."))
			return

	if(!charging)
		to_chat(user, SPAN_WARNING("You need charge [src]..."))
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
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) //Do NOT vary this tune, it needs to be precisely 7 seconds

	//Taking square root not to make defibs too fast...
	if(!do_after(user, 9 SECONDS * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_NO_NEEDHAND|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY, H, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
		user.visible_message(SPAN_WARNING("[user] stops setting up the paddles on [H]'s chest"), \
		SPAN_WARNING("You stop setting up the paddles on [H]'s chest"))
		return

	if(!attached_to.check_revive(H, user))
		return

	//Do this now, order doesn't matter
	sparks.start()
	attached_to.sparks.start()
	attached_to.dcell.use(attached_to.charge_cost)
	update_icon()
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] shocks [H] with the paddles."),
		SPAN_HELPFUL("You shock <b>[H]</b> with the paddles."))
	H.visible_message(SPAN_DANGER("[H]'s body convulses a bit."))
	attached_to.defib_cooldown = world.time + 40

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


/obj/item/paddles/on_enter_storage(obj/item/storage/S)
	. = ..()
	if(attached_to)
		attached_to.recall_paddles()

/obj/item/paddles/forceMove(atom/dest)
	. = ..()
	if(.)
		reset_tether()

/obj/item/paddles/proc/do_zlevel_check()
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
		RegisterSignal(attached_to, COMSIG_MOVABLE_MOVED, .proc/transmitter_move_handler)
		return TRUE
	return FALSE

/obj/item/paddles/proc/transmitter_move_handler(var/datum/source)
	SIGNAL_HANDLER
	zlevel_transfer = FALSE
	if(zlevel_transfer_timer)
		deltimer(zlevel_transfer_timer)
	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
	reset_tether()

/obj/item/paddles/proc/try_doing_tether()
	zlevel_transfer_timer = TIMER_ID_NULL
	zlevel_transfer = FALSE
	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
	reset_tether()