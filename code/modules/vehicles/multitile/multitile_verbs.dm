//------------------------------------------------------
//------------------------VERBS-------------------------
//This file contains all basic verbs that vehicles contain


//Used to swap which module a position is using
//e.g. swapping primary gunner from the minigun to the smoke launcher
/obj/vehicle/multitile/proc/switch_hardpoint()
	set name = "A: Change Active Hardpoint"
	set category = "Vehicle"

	var/mob/M = usr
	if(!M || !istype(M))
		return

	var/obj/vehicle/multitile/V = M.interactee
	if(!V || !istype(V))
		return

	var/seat = V.get_mob_seat(M)
	if(!seat)
		return

	var/list/usable_hps = V.get_activatable_hardpoints(seat)
	if(!LAZYLEN(usable_hps))
		to_chat(M, SPAN_WARNING("None of the hardpoints can be activated or they are all broken."))
		return

	var/obj/item/hardpoint/HP = input("Select a hardpoint.") in usable_hps
	if(!HP)
		return

	V.active_hp[seat] = HP
	to_chat(M, SPAN_NOTICE("You select \the [HP]."))

//cycles through hardpoints in a activatable hardpoints list without asking anything
/obj/vehicle/multitile/proc/cycle_hardpoint()
	set name = "A: Cycle Active Hardpoint"
	set category = "Vehicle"

	var/mob/M = usr
	if(!M || !istype(M))
		return

	var/obj/vehicle/multitile/V = M.interactee
	if(!istype(V))
		return

	var/seat = V.get_mob_seat(M)
	if(!seat)
		return

	var/list/usable_hps = V.get_activatable_hardpoints(seat)
	if(!LAZYLEN(usable_hps))
		to_chat(M, SPAN_WARNING("None of the hardpoints can be activated or they are all broken."))
		return
	var/new_hp = usable_hps.Find(V.active_hp[seat])
	if(!new_hp)
		new_hp = 0

	new_hp = (new_hp % usable_hps.len) + 1
	var/obj/item/hardpoint/HP = usable_hps[new_hp]
	if(!HP)
		return

	V.active_hp[seat] = HP
	to_chat(M, SPAN_NOTICE("You select \the [HP]."))

// Used to lock/unlock the vehicle doors to anyone without proper access
/obj/vehicle/multitile/proc/toggle_door_lock()
	set name = "G: Toggle Door Locks"
	set category = "Vehicle"

	var/mob/M = usr
	if(!M || !istype(M))
		return

	var/obj/vehicle/multitile/V = M.interactee
	if(!istype(V))
		return

	var/seat = V.get_mob_seat(M)
	if(!seat)
		return
	if(seat != VEHICLE_DRIVER)
		return

	V.door_locked = !V.door_locked
	to_chat(M, SPAN_NOTICE("You [V.door_locked ? "lock" : "unlock"] the vehicle doors."))

//switches between SHIFT + Click and Middle Mouse Button Click to fire not selected currently weapon
/obj/vehicle/multitile/proc/toggle_shift_click()
	set name = "G: Toggle Middle/Shift Clicking"
	set desc = "Toggles between using Middle Mouse Button click and Shift + Click to fire not currently selected weapon if possible."
	set category = "Vehicle"

	var/obj/vehicle/multitile/V = usr.interactee
	if(!istype(V))
		return
	var/seat
	for(var/vehicle_seat in V.seats)
		if(V.seats[vehicle_seat] == usr)
			seat = vehicle_seat
			break
	if(seat == VEHICLE_GUNNER)
		V.vehicle_flags ^= TOGGLE_SHIFT_CLICK_GUNNER
		to_chat(usr, SPAN_NOTICE("You will fire not selected weapon with [(V.vehicle_flags & TOGGLE_SHIFT_CLICK_GUNNER) ? "Shift + Click" : "Middle Mouse Button click"] now, if possible."))
	return

//opens vehicle status window with HP and ammo of hardpoints
/obj/vehicle/multitile/proc/get_status_info()
	set name = "I: Get Status Info"
	set desc = "Shows all available information about your vehicle."
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return

	var/obj/vehicle/multitile/V = user.interactee
	if(!istype(V))
		return

	var/seat
	for(var/vehicle_seat in V.seats)
		if(V.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break
	if(!seat)
		return

	var/dat = "[V]<br>"
	for(var/obj/item/hardpoint/H in V.hardpoints)
		dat += H.get_hardpoint_info()

	show_browser(user, dat, "Vehicle Status Info", "vehicle_info")
	onclose(user, "vehicle_info")
	return

//opens vehicle controls guide, that contains description of all verbs and shortcuts in it
/obj/vehicle/multitile/proc/open_controls_guide()
	set name = "I: Vehicle Controls Guide"
	set desc = "MANDATORY FOR FIRST PLAY AS VEHICLE CREWMAN."
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return

	var/obj/vehicle/multitile/V = user.interactee
	if(!istype(V))
		return

	var/seat
	for(var/vehicle_seat in V.seats)
		if(V.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break
	if(!seat)
		return

	var/dat = "<b><i>Common verbs:</i></b><br>1. <b>\"G: Name Vehicle\"</b> - used to add a custom name to the vehicle. Single use. 26 characters maximum.<br> \
	 2. <b>\"I: Get Status Info\"</b> - brings up \"Vehicle Status Info\" window with all available information about your vehicle.<br> \
	<font color='#cd6500'><b><i>Driver verbs:</i></b></font><br> 1. <b>\"G: Activate Horn\"</b> - activates vehicle horn. Keep in mind, that vehicle horn is very loud and can be heard from afar by both allies and foes.<br> \
	 2. <b>\"G: Toggle Door Locks\"</b> - toggles vehicle's access restrictions. Crewman, Brig and Command accesses bypass these restrictions.<br> \
	<font color=\"red\"><b><i>Gunner verbs:</i></b></font><br> 1. <b>\"A: Change Active Hardpoint\"</b> - brings up a list of all not destroyed activatable hardpoints you have access to and allows you to switch your current active hardpoint to one from the list. To activate currently selected hardpoint, click on your target. <b>MAKE SURE NOT TO HIT MARINES</b>.<br>\
	 2. <b>\"A: Cycle Active Hardpoint\"</b> - works similarly to one above, except it automatically switches to next hardpoint in a list allowing you to switch faster.<br> \
	 3. <b>\"G: Toggle Middle/Shift Clicking\"</b> - toggles between using <i>Middle Mouse Button</i> click and <i>Shift + Click</i> to fire not currently selected weapon if possible.<br> \
	 4. <b>\"G: Toggle Turret Gyrostabilizer\"</b> - toggles Turret Gyrostabilizer allowing it to keep current direction ignoring hull turning. <i>(Exists only on vehicles with rotating turret, e.g. M34A2 Longstreet Light Tank)</i><br> \
	<font color='#cd6500'><b><i>Driver shortcuts:</i></b></font><br> 1. <b>\"CTRL + Click\"</b> - activates vehicle horn.<br> \
	<font color=\"red\"><b><i>Gunner shortcuts:</i></b></font><br> 1. <b>\"ALT + Click\"</b> - toggles Turret Gyrostabilizer. <i>(Exists only on vehicles with rotating turret, e.g. M34A2 Longstreet Light Tank)</i><br> \
	 2. <b>\"CTRL + Click\"</b> - activates not destroyed activatable support module.<br> \
	 3. <b>\"Middle Mouse Button Click (MMB)\"</b> - default shortcut to shoot currently not selected weapon if possible. Won't work if <i>SHIFT + Click</i> firing is toggled ON.<br> \
	 4. <b>\"SHIFT + Click\"</b> - examines target as usual, unless <i>\"G: Toggle Middle/Shift Clicking\"</i> verb was used to toggle <i>SHIFT + Click</i> firing ON. In this case, it will fire currently not selected weapon if possible.<br>"

	show_browser(user, dat, "Vehicle Controls Guide", "vehicle_help", "size=900x500")
	onclose(user, "vehicle_help")
	return

//toggles gyrostabilizer for vehicles that have turret, allowing it to keep direction regardless hull rotations
/obj/vehicle/multitile/proc/toggle_gyrostabilizer()
	set name = "G: Toggle Turret Gyrostabilizer"
	set desc = "Toggles Turret Gyrostabilizer allowing it independant movement regardless of hull direction."
	set category = "Vehicle"

//single use verb that allows VCs to add a nickname in "" at the end of their vehicle name
/obj/vehicle/multitile/proc/name_vehicle()
	set name = "G: Name Vehicle"
	set desc = "Allows you to add a custom name to your vehicle. Single use. 26 characters maximum."
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return

	var/obj/vehicle/multitile/V = user.interactee
	if(!istype(V))
		return

	var/seat
	for(var/vehicle_seat in V.seats)
		if(V.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break
	if(!seat)
		return

	if(V.nickname)
		to_chat(user, SPAN_WARNING("Vehicle already has a \"[V.nickname]\" nickname."))
		return

	var/new_nickname = stripped_input(user, "Enter a unique name or callsign to add to your vehicle's name. 26 characters maximum. SINGLE USE ONLY.", "Name your vehicle", "", MAX_NAME_LEN)
	if(!new_nickname)
		return
	if(alert(user, "Vehicle's name will be [initial(V.name) + "\"[new_nickname]\""]. Confirm?", "Confirmation?", "Yes", "No") == "No")
		return

	//post-checks
	if(V.seats[seat] != user)	//check that we are still in seat
		to_chat(user, SPAN_WARNING("You need to be buckled to vehicle seat to do this."))
		return

	if(V.nickname)	//check again if second VC was faster.
		to_chat(user, SPAN_WARNING("The other crewman beat you to it!"))
		return

	V.nickname = new_nickname
	V.name = initial(V.name) + " \"[V.nickname]\""
	to_chat(user, SPAN_NOTICE("You've added \"[V.nickname]\" nickname to your vehicle."))
	V.initialize_cameras(TRUE)

//Activates vehicle horn. Yes, it is annoying.
/obj/vehicle/multitile/proc/activate_horn()
	set name = "G: Activate Horn"
	set desc = "Activates vehicle signal. Beep-beep."
	set category = "Vehicle"

	var/mob/user = usr
	if(!istype(user))
		return

	var/obj/vehicle/multitile/V = user.interactee
	if(!istype(V))
		return

	var/seat
	for(var/vehicle_seat in V.seats)
		if(V.seats[vehicle_seat] == user)
			seat = vehicle_seat
			break
	if(!seat)
		return

	if(world.time < V.next_honk)
		to_chat(user, SPAN_WARNING("You need to wait [(V.next_honk - world.time) / 10] seconds."))
		return

	V.next_honk = world.time + SECONDS_10
	to_chat(user, SPAN_NOTICE("You activate vehicle's horn."))
	V.perform_honk()

/obj/vehicle/multitile/proc/perform_honk()
	if(honk_sound)
		playsound(loc, honk_sound, 75, TRUE, 15)	//heard within ~15 tiles