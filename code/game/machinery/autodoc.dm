
/obj/structure/machinery/autodoc
	name = "\improper autodoc medical system"
	desc = "A fancy machine developed to be capable of operating on people with minimal human intervention. The interface is rather complex and would only be useful to trained Doctors however."
	icon = 'icons/obj/structures/machinery/cryogenics.dmi'
	icon_state = "autodoc_open"
	density = 1
	anchored = 1
	var/mob/living/carbon/human/occupant = null
	var/heal_rate = 3.5
	var/healing_limb = FALSE
	var/list/limbs_to_heal
	var/obj/limb/cur_limb
	var/time_to_start
	var/obj/structure/machinery/autodoc_console/connected

	var/filtering
	var/blood_transfer
	var/heal_brute
	var/heal_burn
	var/heal_toxin
	//It uses power
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 450 //Capable of doing various activities


/obj/structure/machinery/autodoc/Initialize()
	. = ..()
	connect_autodoc_console()

/obj/structure/machinery/autodoc/proc/connect_autodoc_console()
	if(connected)
		return
	if(dir == EAST || dir == SOUTH)
		connected = locate(/obj/structure/machinery/autodoc_console,get_step(src, EAST))
	if(dir == WEST || dir == NORTH)
		connected = locate(/obj/structure/machinery/autodoc_console,get_step(src, WEST))
	if(connected)
		connected.connected = src

/obj/structure/machinery/autodoc/Destroy()
	if(occupant)
		occupant.forceMove(loc)
		occupant = null
		stop_processing()
		if(connected)
			connected.stop_processing()
	if(connected)
		connected.connected = null
		QDEL_NULL(connected)
	. = ..()



/obj/structure/machinery/autodoc/power_change(var/area/master_area = null)
	..()
	if(stat & NOPOWER)
		visible_message("\The [src] engages the safety override, ejecting the occupant.")
		go_out()
		return
/*
/obj/structure/machinery/autodoc/proc/heal_limb(var/mob/living/carbon/human/human, var/brute, var/burn)
	var/list/obj/limb/parts = human.get_damaged_limbs(brute,burn)
	if(!parts.len)	return
	var/obj/limb/picked = pick(parts)
	if(picked.status & LIMB_ROBOT)
		picked.heal_damage(brute, burn, 0, 1)
		human.pain.apply_pain(-brute, BRUTE)
		human.pain.apply_pain(-burn, BURN)
	else
		human.apply_damage(-brute, BRUTE, picked)
		human.apply_damage(-burn, BURN, picked)

	human.UpdateDamageIcon()
	human.updatehealth()
*/

/obj/structure/machinery/autodoc/start_processing()
	..()
	healing_limb = FALSE
	filtering = TRUE
	blood_transfer = TRUE
	heal_brute = TRUE
	heal_burn = TRUE
	heal_toxin = TRUE
	time_to_start = 20 SECONDS
	if(ishuman(occupant))
		limbs_to_heal = occupant.get_damaged_limbs(null,null,TRUE)

/obj/structure/machinery/autodoc/process()
	if(occupant)
		if(occupant.stat == DEAD)
			visible_message("[htmlicon(src, viewers(src), viewers(src))] \The <b>[src]</b> speaks: Patient has expired.")
			go_out()
			return
		if(!cur_limb)
			if(!length(limbs_to_heal))
				visible_message("[htmlicon(src, viewers(src), viewers(src))] \The <b>[src]</b> speaks: Patient at full integrity.")
				go_out()
				return
			cur_limb = pick(limbs_to_heal)//Random for inconvenience
		if(!healing_limb)
			time_to_start -= 3.5 SECONDS
			if(time_to_start > 0)
				return
			healing_limb = TRUE
			icon_state = "autodoc_operate"
		else
			if(!cur_limb.integrity_damage)
				limbs_to_heal -= cur_limb
				healing_limb = FALSE
				cur_limb = null
				icon_state = "autodoc_closed"
				return
			cur_limb.take_integrity_damage(-heal_rate)
			// keep them alive
			occupant.apply_damage(-1 * REM, TOX) // pretend they get IV dylovene
			occupant.apply_damage(-occupant.getOxyLoss(), OXY) // keep them breathing, pretend they get IV dexplus
			if(filtering)
				var/filtered = 0
				for(var/datum/reagent/x in occupant.reagents.reagent_list)
					occupant.reagents.remove_reagent(x.id, 3) // same as sleeper, may need reducing
					filtered += 3
				if(!filtered)
					filtering = 0
					visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> speaks: Blood filtering complete.")
				else if(prob(10))
					visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> whirrs and gurgles as the dialysis module operates.")
					to_chat(occupant, SPAN_INFO("You feel slightly better."))

			if(blood_transfer)
				if(occupant.blood_volume < BLOOD_VOLUME_MAXIMUM)
					occupant.blood_volume = min(occupant.blood_volume + 2, BLOOD_VOLUME_MAXIMUM)
					if(prob(10))
						visible_message("\The [src] whirrs and gurgles as it tranfuses blood.")
						to_chat(occupant, SPAN_INFO("You feel slightly less faint."))
				else
					blood_transfer = FALSE
					visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> speaks: Blood transfer complete.")
			if(heal_brute)
				if(occupant.getBruteLoss() > 0)
					occupant.apply_damage(-3, BRUTE)
					if(prob(10))
						visible_message("\The [src] whirrs and clicks as it stitches flesh together.")
						to_chat(occupant, SPAN_INFO("You feel your wounds being stitched and sealed shut."))
				else
					heal_brute = FALSE
					visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> speaks: Trauma repair surgery complete.")
			if(heal_burn)
				if(occupant.getFireLoss() > 0)
					occupant.apply_damage(-3, BURN)
					if(prob(10))
						visible_message("\The [src] whirrs and clicks as it grafts synthetic skin.")
						to_chat(occupant, SPAN_INFO("You feel your burned flesh being sliced away and replaced."))
				else
					heal_burn = FALSE
					visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> speaks: Skin grafts complete.")
			if(heal_toxin)
				if(occupant.getToxLoss() > 0)
					occupant.apply_damage(-3, TOX)
					if(prob(10))
						visible_message("\The [src] whirrs and gurgles as it kelates the occupant.")
						to_chat(occupant, SPAN_INFO("You feel slighly less ill."))
				else
					heal_toxin = 0
					visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> speaks: Chelation complete.")

/obj/structure/machinery/autodoc/verb/eject()
	set name = "Eject Med-Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.stat == DEAD)
		return // nooooooooooo
	if(occupant)
		if(isXeno(usr)) // let xenos eject people hiding inside.
			message_staff("[key_name(usr)] ejected [key_name(occupant)] from the autodoc.")
			go_out()
			add_fingerprint(usr)
			return
		if(!ishuman(usr))
			return
		if(usr == occupant)
			if(healing_limb)
				to_chat(usr, SPAN_WARNING("There's no way you're getting out while this thing is operating on you!"))
			else
				visible_message("[usr] engages the internal release mechanism, and climbs out of \the [src].")
			return
		if(!skillcheck(usr, SKILL_SURGERY, SKILL_SURGERY_TRAINED))
			to_chat(usr, SPAN_WARNING("You don't have the training to use this."))
			return
		if(healing_limb)
			visible_message("[htmlicon(src, viewers(src))] \The <b>[src]</b> malfunctions as [usr] aborts the surgery in progress.")
			occupant.take_limb_damage(rand(30,50),rand(30,50))
			// message_staff for now, may change to message_admins later
			message_staff("[key_name(usr)] ejected [key_name(occupant)] from the autodoc during surgery causing damage.")
		go_out()
		add_fingerprint(usr)

/obj/structure/machinery/autodoc/verb/move_inside()
	set name = "Enter Autodoc"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !ishuman(usr)) return

	if(occupant)
		to_chat(usr, SPAN_NOTICE("\The [src] is already occupied!"))
		return

	if(inoperable())
		to_chat(usr, SPAN_NOTICE("\The [src] is non-functional!"))
		return

	usr.visible_message(SPAN_NOTICE("[usr] starts climbing into \the [src]."),
	SPAN_NOTICE("You start climbing into \the [src]."))
	if(do_after(usr, 20, INTERRUPT_NO_NEEDHAND, BUSY_ICON_GENERIC))
		if(occupant)
			to_chat(usr, SPAN_NOTICE("\The [src] is already occupied!"))
			return
		go_in_autodoc(usr)
		add_fingerprint(usr)

/obj/structure/machinery/autodoc/proc/go_in_autodoc(mob/M)
	M.forceMove(src)
	update_use_power(2)
	occupant = M
	icon_state = "autodoc_closed"
	start_processing()
	if(connected)
		connected.start_processing()
	//prevents occupant's belonging from landing inside the machine
	for(var/obj/O in src)
		O.loc = loc



/obj/structure/machinery/autodoc/proc/go_out()
	if(!occupant) return
	occupant.forceMove(loc)
	occupant.update_med_icon()
	occupant = null
	cur_limb = null
	update_use_power(1)
	icon_state = "autodoc_open"
	stop_processing()
	if(connected)
		connected.stop_processing()
		connected.process() // one last update


/obj/structure/machinery/autodoc/attackby(obj/item/W, mob/living/user)
	if(!ishuman(user))
		return // no
	/*
	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		to_chat(user, SPAN_NOTICE("\The [src] processes \the [W]."))
		stored_metal += M.amount * 100
		user.drop_held_item()
		qdel(W)
		return
	*/
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ishuman(G.grabbed_thing)) // stop fucking monkeys and xenos being put in.
			return
		var/mob/M = G.grabbed_thing
		if(src.occupant)
			to_chat(user, SPAN_NOTICE("\The [src] is already occupied!"))
			return

		if(inoperable())
			to_chat(user, SPAN_NOTICE("\The [src] is non-functional!"))
			return

		if(!skillcheck(user, SKILL_SURGERY, SKILL_SURGERY_TRAINED))
			to_chat(user, SPAN_WARNING("You have no idea how to put someone into \the [src]!"))
			return

		visible_message(SPAN_NOTICE("[user] starts putting [M] into [src]."), null, null, 3)

		if(do_after(user, 20, INTERRUPT_NO_NEEDHAND, BUSY_ICON_GENERIC))
			if(src.occupant)
				to_chat(user, SPAN_NOTICE("\The [src] is already occupied!"))
				return
			if(!G || !G.grabbed_thing) return
			go_in_autodoc(M)

			add_fingerprint(user)

#ifdef OBJECTS_PROXY_SPEECH
// Transfers speech to occupant
/obj/structure/machinery/autodoc/hear_talk(mob/living/sourcemob, message, verb, language, italics)
	if(!QDELETED(occupant) && istype(occupant) && occupant.stat != DEAD)
		proxy_object_heard(src, sourcemob, occupant, message, verb, language, italics)
	else
		..(sourcemob, message, verb, language, italics)
#endif // ifdef OBJECTS_PROXY_SPEECH

/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/structure/machinery/autodoc_console
	name = "\improper autodoc medical system control console"
	icon = 'icons/obj/structures/machinery/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/structure/machinery/autodoc/connected = null
	dir = 2
	anchored = 1 //About time someone fixed this.
	density = 0

	use_power = 1
	idle_power_usage = 40

/obj/structure/machinery/autodoc_console/Initialize()
	. = ..()
	connect_autodoc()

/obj/structure/machinery/autodoc_console/proc/connect_autodoc()
	if(connected)
		return
	if(dir == EAST || dir == SOUTH)
		connected = locate(/obj/structure/machinery/autodoc,get_step(src, WEST))
	if(dir == WEST || dir == NORTH)
		connected = locate(/obj/structure/machinery/autodoc,get_step(src, EAST))
	if(connected)
		connected.connected = src


/obj/structure/machinery/autodoc_console/Destroy()
	if(connected)
		if(connected.occupant)
			connected.go_out()

		connected.connected = null
		qdel(connected)
		connected = null
	. = ..()


/obj/structure/machinery/autodoc_console/power_change(var/area/master_area = null)
	..()
	if(stat & NOPOWER)
		if(icon_state != "sleeperconsole-p")
			icon_state = "sleeperconsole-p"
		return
	if(icon_state != "sleeperconsole")
		icon_state = "sleeperconsole"

/obj/structure/machinery/autodoc_console/process()
	updateUsrDialog()



/obj/structure/machinery/autodoc/event