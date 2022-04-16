/obj/item/tool/crew_monitor
	name = "crew monitor"
	desc = "A tool used to get coordinates to deployed personnel. It was invented after it was found out 3/4 command officers couldn't read numbers."
	icon = 'icons/obj/items/experimental_tools.dmi'
	icon_state = "crew_monitor"
	flags_equip_slot = SLOT_WAIST
	w_class = SIZE_SMALL

	var/cooldown_to_use = 0

/obj/item/tool/crew_monitor/attack_self(var/mob/user)
	..()

	if(cooldown_to_use > world.time)
		return

	ui_interact(user)

	cooldown_to_use = world.time + 2 SECONDS

/obj/item/tool/crew_monitor/ui_interact(var/mob/user as mob)
	user.set_interaction(src)

	var/dat = "<head><title>Crew Monitor</title></head><body>"
	dat += get_crew_info(user)

	dat += "<BR><A HREF='?src=\ref[user];mach_close=crew_monitor'>Close</A>"
	show_browser(user, dat, name, "crew_monitor", "size=600x700")
	onclose(user, "crew_monitor")

/obj/item/tool/crew_monitor/proc/get_crew_info(var/mob/user)
	var/dat = ""
	dat += {"
	<script type="text/javascript">
		function updateSearch() {
			var filter_text = document.getElementById("filter");
			var filter = filter_text.value.toLowerCase();

			var marine_list = document.getElementById("marine_list");
			var ltr = marine_list.getElementsByTagName("tr");

			for(var i = 0; i < ltr.length; ++i) {
				try {
					var tr = ltr\[i\];
					tr.style.display = '';
					var ltd = tr.getElementsByTagName("td")
					var name = ltd\[0\].innerText.toLowerCase();
					var role = ltd\[1\].innerText.toLowerCase()
					if(name.indexOf(filter) == -1 && role.indexOf(filter) == -1) {
						tr.style.display = 'none';
					}
				} catch(err) {}
			}
		}
	</script>
	"}

	var/turf/user_turf = get_turf(user)

	dat += "<center><b>Search:</b> <input type='text' id='filter' value='' onkeyup='updateSearch();' style='width:300px;'></center>"
	dat += "<table id='marine_list' border='2px' style='width: 100%; border-collapse: collapse;' align='center'><tr>"
	dat += "<th>Name</th><th>Squad</th><th>Role</th><th>State</th><th>Location</th><th>Distance</th></tr>"
	for(var/datum/squad/S in RoleAuthority.squads)
		var/list/squad_roles = ROLES_MARINES.Copy()
		for(var/i in squad_roles)
			squad_roles[i] = ""
		var/misc_roles = ""

		for(var/X in S.marines_list)
			if(!X)
				continue //just to be safe
			var/mob_name = "unknown"
			var/mob_state = ""
			var/squad = "None"
			var/role = "unknown"
			var/dist = "<b>???</b>"
			var/area_name = "<b>???</b>"
			var/mob/living/carbon/human/H
			if(ishuman(X))
				H = X
				mob_name = H.real_name
				var/area/A = get_area(H)
				var/turf/M_turf = get_turf(H)
				if(A)
					area_name = sanitize(A.name)

				if(H.undefibbable)
					continue

				if(H.job)
					role = H.job
				else if(istype(H.wear_id, /obj/item/card/id)) //decapitated marine is mindless,
					var/obj/item/card/id/ID = H.wear_id		//we use their ID to get their role.
					if(ID.rank)
						role = ID.rank

				if(M_turf && (M_turf.z == user_turf.z))
					dist = "[get_dist(H, user)] ([dir2text_short(get_dir(user, H))])"

				if(H.assigned_squad)
					squad = H.assigned_squad.name

				switch(H.stat)
					if(CONSCIOUS)
						mob_state = "Conscious"
					if(UNCONSCIOUS)
						mob_state = "<b>Unconscious</b>"
					else
						mob_state = "<b>Dead</b>"

			var/marine_infos = "<tr><td>[mob_name]</a></td><td>[squad]</td><td>[role]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(role in squad_roles)
				squad_roles[role] += marine_infos
			else
				misc_roles += marine_infos

		for(var/i in squad_roles)
			dat += squad_roles[i]
		dat += misc_roles

	dat += "</table>"
	dat += "<br><hr>"
	return dat

/obj/item/tool/portadialysis
	name = "portable dialysis machine"
	desc = "A man-portable dialysis machine, with a small internal battery that can be recharged. Filters out all foreign compounds from the bloodstream of whoever it's attached to, but also typically ends up removing some blood as well."
	icon = 'icons/obj/items/experimental_tools.dmi'
	icon_state = "portadialysis"
	item_state = "syringe_0"
	flags_equip_slot = SLOT_WAIST
	w_class = SIZE_MEDIUM
	var/attaching = FALSE
	var/filtering = FALSE
	var/mob/living/carbon/human/attached = null
	var/reagent_removed_per_second = AMOUNT_PER_TIME(3, 2 SECONDS)
	var/obj/item/cell/pdcell = null
	var/filter_cost = AMOUNT_PER_TIME(20, 2 SECONDS)
	var/blood_cost = AMOUNT_PER_TIME(12, 2 SECONDS)

/obj/item/tool/portadialysis/Initialize(mapload, ...)
	. = ..()

	pdcell = new/obj/item/cell(src) //has 1000 charge
	update_icon()

/obj/item/tool/portadialysis/update_icon()
	if(attaching)
		flick("portadialysis_starting", src)

	else if(filtering)
		icon_state = "portadialysis_running"

	else
		flick("portadialysis", src) //we do this to override the previous flick()
		icon_state = "portadialysis"

	if(pdcell && pdcell.charge)
		overlays.Cut()
		switch(round(pdcell.charge * 100 / pdcell.maxcharge))
			if(85 to INFINITY)
				overlays += "dialysis_battery_100"
			if(60 to 84)
				overlays += "dialysis_battery_85"
			if(45 to 59)
				overlays += "dialysis_battery_60"
			if(30 to 44)
				overlays += "dialysis_battery_45"
			if(15 to 29)
				overlays += "dialysis_battery_30"
			if(1 to 14)
				overlays += "dialysis_battery_15"

/obj/item/tool/portadialysis/examine(mob/user)
	..()
	var/currentpercent = 0
	currentpercent = round(pdcell.charge * 100 / pdcell.maxcharge)
	to_chat(user, SPAN_INFO("It has [currentpercent]% charge left in its internal battery."))

/obj/item/tool/portadialysis/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(!isHumanStrict(target))
		return ..()

	if(!skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		to_chat(user, SPAN_WARNING("You don't seem to know how to use \the [src]..."))
		return

	if(!pdcell || pdcell.charge == 0)
		to_chat(user, SPAN_NOTICE("\The [src] flashes its 'battery low' light, and refuses to attach."))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.stat || H.blinded || H.lying)
			return

		if(attaching)
			return

		if(attached && !(target == attached)) //are we already attached to something that isn't the target?
			to_chat(H, SPAN_WARNING("You're already using \the [src] on someone else!"))
			return

		if(target == attached) //are we attached to the target?
			H.visible_message("[H] detaches \the [src] from [attached].", \
			"You detach \the [src] from [attached].")
			attached = null
			filtering = FALSE
			attaching = FALSE
			update_icon()
			STOP_PROCESSING(SSobj, src)
			return

		else
			//check for if they actually have arms...
			var/obj/limb/l_arm = target.get_limb("l_arm")
			var/obj/limb/r_arm = target.get_limb("r_arm")
			if((l_arm.status & LIMB_DESTROYED) && (r_arm.status & LIMB_DESTROYED))
				to_chat(H, SPAN_WARNING("[target] has no arms to attach \the [src] to!"))
				return

			attaching = TRUE
			update_icon()
			to_chat(target, SPAN_DANGER("[H] is trying to attach \the [src] to you!"))
			H.visible_message(SPAN_WARNING("[H] starts setting up \the [src]'s needle on [target]'s arm."), \
				SPAN_WARNING("You start setting up \the [src]'s needle on [target]'s arm."))
			if(!do_after(H, 30, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, target, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
				H.visible_message(SPAN_WARNING("[H] stops setting up \the [src]'s needle on [target]'s arm."), \
				SPAN_WARNING("You stop setting up \the [src]'s needle on [target]'s arm."))
				visible_message("\The [src]'s tubing snaps back onto the machine frame.")
				attaching = FALSE
				update_icon()
				return

			H.visible_message("[H] attaches \the [src] to [target].", \
			"You attach \the [src] to [target].")
			attached = target
			filtering = TRUE
			attaching = FALSE
			update_icon()
			START_PROCESSING(SSobj, src)
			return

/obj/item/tool/portadialysis/dropped(mob/user)
	if(attached)
		attached.visible_message(SPAN_WARNING("\The [src]'s needle is ripped out of [attached], doesn't that hurt?"))
		to_chat(attached, SPAN_WARNING("Ow! A needle is ripped out of you!"))
		damage_arms(attached)
		if(attached.pain.feels_pain)
			attached.emote("scream")
		attached = null
		filtering = FALSE
		attaching = FALSE
		update_icon()
		STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/tool/portadialysis/process(delta_time)
	if(!attached)
		return

	if(get_dist(src, attached) > 1)
		attached.visible_message(SPAN_NOTICE("\The [src]'s needle is ripped out of [attached], doesn't that hurt?"))
		to_chat(attached, SPAN_WARNING("Ow! A needle is ripped out of you!"))
		damage_arms(attached)
		if(attached.pain.feels_pain)
			attached.emote("scream")
		attached = null
		filtering = FALSE
		update_icon()
		STOP_PROCESSING(SSobj, src)
		return

	if(!pdcell || pdcell.charge == 0)
		attached.visible_message(SPAN_NOTICE("\The [src] automatically detaches from [attached], blinking its 'battery low' light."))
		attached = null
		filtering = FALSE
		update_icon()
		STOP_PROCESSING(SSobj, src)
		return

	if(filtering)
		attached.reagents.remove_any_but("blood", reagent_removed_per_second*delta_time)
		attached.take_blood(attached, blood_cost*delta_time)
		if(attached.blood_volume < BLOOD_VOLUME_SAFE) if(prob(5))
			visible_message("\The [src] beeps loudly.")
		pdcell.use(filter_cost*delta_time)

	updateUsrDialog()
	update_icon()

/obj/item/tool/portadialysis/proc/damage_arms(var/mob/living/carbon/human/human_to_damage)
	var/obj/limb/l_arm = human_to_damage.get_limb("l_arm")
	var/obj/limb/r_arm = human_to_damage.get_limb("r_arm")
	var/list/arms_to_damage = list(l_arm, r_arm)
	if(l_arm.status & LIMB_DESTROYED)
		arms_to_damage -= l_arm
	if(r_arm.status & LIMB_DESTROYED)
		arms_to_damage -= r_arm
	human_to_damage.apply_damage(3, BRUTE, pick(arms_to_damage))
