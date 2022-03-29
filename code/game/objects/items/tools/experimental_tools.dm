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

/obj/item/auto_cpr
	name = "auto-compressor" //autocompressor
	desc = "A device that gives regular compression to the victim's ribcage, used in case of urgent heart issues."
	icon = 'icons/obj/items/experimental_tools.dmi'
	icon_state = "autocpr"
	item_state = "autocpr"
	w_class = SIZE_MEDIUM
	flags_equip_slot = SLOT_OCLOTHING
	var/last_pump
	var/skilled_setup

/obj/item/auto_cpr/mob_can_equip(mob/living/carbon/human/H, slot, disable_warning = 0, force = 0)
	. = ..()
	if(force || !isHumanStrict(H) || slot != WEAR_JACKET)
		return
	else
		return FALSE

/obj/item/auto_cpr/attack(mob/living/carbon/human/M, mob/living/user, var/target_zone)
	if(istype(M) && user.a_intent == INTENT_HELP)
		if(M.wear_suit)
			to_chat(user, SPAN_WARNING("Their [M.wear_suit] is in the way, remove it first!"))
			return
		user.affected_message(M,
							SPAN_NOTICE("You start fitting \the [src] onto [M]'s chest."),
							SPAN_WARNING("[user] starts fitting \the [src] onto your chest!"),
							SPAN_NOTICE("[user] starts fitting \the [src] onto [M]'s chest."))
		if(!do_after(user, 20, BUSY_ICON_MEDICAL, target = M, show_target_icon = BUSY_ICON_MEDICAL))
			return

		user.drop_inv_item_on_ground(src)
		if(!M.equip_to_slot_if_possible(src, WEAR_JACKET))
			user.put_in_active_hand(src)
			return
	else
		return ..()

/obj/item/auto_cpr/equipped(mob/user, slot)
	..()
	START_PROCESSING(SSobj,src)

/obj/item/auto_cpr/attack_hand(mob/user)
	skilled_setup = skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC)
	..()

/obj/item/auto_cpr/dropped(mob/user)
	STOP_PROCESSING(SSobj,src)
	..()

/obj/item/auto_cpr/process()
	if(!ishuman(loc))
		return PROCESS_KILL

	var/mob/living/carbon/human/H = loc
	if(H.wear_suit != src)
		return PROCESS_KILL

	if(world.time > last_pump + 15 SECONDS)
		last_pump = world.time
//		playsound(src, 'sound/machines/pump.ogg', 25)
		if(!skilled_setup && prob(20))
			var/obj/limb/chest/E = H.limbs["c"]
			H.pain.apply_pain(PAIN_BONE_BREAK) //ouch!
			to_chat(H, "<span class='danger'>Your [E] is compressed painfully!</span>")
			if(prob(5))
				E.fracture()
		else
			if(H.stat != DEAD)
				var/suff = min(H.getOxyLoss(), 10) //Pre-merge level, less healing, more prevention of dieing.
				H.apply_damage(-suff, OXY)
				H.updatehealth()
				H.affected_message(src,
					SPAN_HELPFUL("You feel a <b>breath of fresh air</b> enter your lungs. It feels good."),
					message_viewer = SPAN_NOTICE("<b>[src]</b> performs <b>CPR</b> on <b>[H]</b>."))
			if(H.is_revivable() && H.stat == DEAD)
				if(H.cpr_cooldown < world.time)
					H.revive_grace_period += 7 SECONDS
					src.visible_message(SPAN_NOTICE("<b>[src]</b> performs <b>CPR</b> on <b>[H]</b>."))
				else
					H.visible_message(SPAN_NOTICE("<b>[src]</b> fails to perform CPR on <b>[H]</b>."))
				H.cpr_cooldown = world.time + 7 SECONDS
