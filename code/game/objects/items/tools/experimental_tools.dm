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

obj/item/tool/omnitool
	name = "omnitool"
	desc = "A tool that can switch between a screwdriver, wrench, wirecutters, crowbar, and multitool."
	icon = 'icons/obj/items/experimental_tools.dmi'
	icon_state = "omnitool"
	flags_equip_slot = SLOT_WAIST
	w_class = SIZE_SMALL
	var/on = 0

obj/item/tool/omnitool/verb/set_screwdriver()
	set name = "Set to screwdriver mode"
	set category = "Omnitool"
	set desc = "Change the active tool to a screwdriver"
	set src in usr

/obj/item/tool/omnitool/set_screwdriver(mob/living/user)
	if(user.get_active_hand() != src)
		return
	else
		initial(icon_state)
		REMOVE_TRAITS_IN(src, T)
		user.visible_message(SPAN_INFO("With a flick of their wrist, [user] extends [src]."),\
		SPAN_NOTICE("You extend [src]."),\
		"You hear tools extending.")
		playsound(src,'sound/handling/combistick_open.ogg', 50, TRUE, 3)
		icon_state = initial(icon_state) + "_scr"
		for(var/T in tool_traits_init)
			ADD_TRAIT(src, T, TRAIT_TOOL_SCREWDRIVER)
		on = TRUE
		update_icon()

obj/item/tool/omnitool/verb/set_wrench()
	set name = "Set to wrench mode"
	set category = "Omnitool"
	set desc = "Change the active tool to a wrench"
	set src in usr

/obj/item/tool/omnitool/set_wrench(mob/living/user)
	if(user.get_active_hand() != src)
		return
	else
		initial(icon_state)
		REMOVE_TRAITS_IN(src, T)
		user.visible_message(SPAN_INFO("With a flick of their wrist, [user] extends [src]."),\
		SPAN_NOTICE("You extend [src]."),\
		"You hear tools extending.")
		playsound(src,'sound/handling/combistick_open.ogg', 50, TRUE, 3)
		icon_state = initial(icon_state) + "_wrn"
		for(var/T in tool_traits_init)
			ADD_TRAIT(src, T, TRAIT_TOOL_WRENCH)
		on = TRUE
		update_icon()

obj/item/tool/omnitool/verb/set_crowbar()
	set name = "Set to crowbar mode"
	set category = "Omnitool"
	set desc = "Change the active tool to a crowbar"
	set src in usr

/obj/item/tool/omnitool/set_crowbar(mob/living/user)
	if(user.get_active_hand() != src)
		return
	else
		initial(icon_state)
		REMOVE_TRAITS_IN(src, T)
		user.visible_message(SPAN_INFO("With a flick of their wrist, [user] extends [src]."),\
		SPAN_NOTICE("You extend [src]."),\
		"You hear tools extending.")
		playsound(src,'sound/handling/combistick_open.ogg', 50, TRUE, 3)
		icon_state = initial(icon_state) + "_cro"
		for(var/T in tool_traits_init)
			ADD_TRAIT(src, T, TRAIT_TOOL_CROWBAR)
		on = TRUE
		update_icon()

obj/item/tool/omnitool/verb/set_wirecutter()
	set name = "Set to wirecutter mode"
	set category = "Omnitool"
	set desc = "Change the active tool to a wirecutter"
	set src in usr

/obj/item/tool/omnitool/set_wirecutter(mob/living/user)
	if(user.get_active_hand() != src)
		return
	else
		initial(icon_state)
		REMOVE_TRAITS_IN(src, T)
		user.visible_message(SPAN_INFO("With a flick of their wrist, [user] extends [src]."),\
		SPAN_NOTICE("You extend [src]."),\
		"You hear tools extending.")
		playsound(src,'sound/handling/combistick_open.ogg', 50, TRUE, 3)
		icon_state = initial(icon_state) + "_wrc"
		for(var/T in tool_traits_init)
			ADD_TRAIT(src, T, TRAIT_TOOL_WIRECUTTERS)
		on = TRUE
		update_icon()

obj/item/tool/omnitool/verb/set_multitool()
	set name = "Set to multitool mode"
	set category = "Omnitool"
	set desc = "Change the active tool to a multitool"
	set src in usr

/obj/item/tool/omnitool/set_multitool(mob/living/user)
	if(user.get_active_hand() != src)
		return
	else
		initial(icon_state)
		REMOVE_TRAITS_IN(src, T)
		user.visible_message(SPAN_INFO("With a flick of their wrist, [user] extends [src]."),\
		SPAN_NOTICE("You extend [src]."),\
		"You hear tools extending.")
		playsound(src,'sound/handling/combistick_open.ogg', 50, TRUE, 3)
		icon_state = initial(icon_state) + "_mlt"
		for(var/T in tool_traits_init)
			ADD_TRAIT(src, T, TRAIT_TOOL_MULTITOOL)
		on = TRUE
		update_icon()
