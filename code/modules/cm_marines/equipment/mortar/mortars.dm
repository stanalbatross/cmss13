// The Marine mortar, the M402 Mortar
// Works like a contemporary crew weapon mortar
/obj/structure/mortar
	name = "\improper M402 mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Uses an advanced targeting computer. Insert round to fire."
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_m402"
	anchored = TRUE
	unslashable = TRUE
	unacidable = TRUE
	density = 1
	// So you can't hide it under corpses
	layer = ABOVE_MOB_LAYER
	flags_atom = RELAY_CLICK
	var/computer_enabled = TRUE
	// Initial target coordinates
	var/targ_x = 0
	var/targ_y = 0
	// Automatic offsets from target
	var/offset_x = 0
	var/offset_y = 0
	/// Number of turfs to offset from target by 1
	var/offset_per_turfs = 20
	// Dial adjustments from target
	var/dial_x = 0
	var/dial_y = 0
	/// Constant, assuming perfect parabolic trajectory. ONLY THE DELAY BEFORE INCOMING WARNING WHICH ADDS 45 TICKS
	var/travel_time = 4.5 SECONDS
	var/busy = FALSE
	/// Used for deconstruction and aiming sanity
	var/firing = FALSE
	/// If set to 1, can't unanchor and move the mortar, used for map spawns and WO
	var/fixed = FALSE

	var/obj/structure/machinery/computer/security/mortar/internal_camera

	var/undeploy_time = 4 SECONDS

	var/minimum_range = 10
	var/maximum_range

	var/kit_type = /obj/item/mortar_kit
	var/shell_calibre = MORTAR_SHELL_80MM

/obj/structure/mortar/breaching
	name = "\improper M420 breaching mortar"
	desc = "A manual, crew-operated mortar system intended to breach through enemy defenses with low yield 60mm shells. Uses an advanced targeting computer. Insert round to fire."
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_m402"

	undeploy_time = 2 SECONDS
	travel_time = 2 SECONDS
	minimum_range = 6
	maximum_range = 12

	kit_type = /obj/item/mortar_kit/breaching
	shell_calibre = MORTAR_SHELL_60MM

/obj/structure/mortar/Initialize()
	. = ..()
	// Makes coords appear as 0 in UI
	targ_x = deobfuscate_x(0)
	targ_y = deobfuscate_y(0)
	internal_camera = new(loc)

/obj/structure/mortar/Destroy()
	qdel(internal_camera)
	return ..()

/obj/structure/mortar/attack_hand(mob/user)
	if(isYautja(user))
		to_chat(user, SPAN_WARNING("You kick [src] but nothing happens."))
		return
	if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_TRAINED))
		to_chat(user, SPAN_WARNING("You don't have the training to use [src]."))
		return
	if(busy)
		to_chat(user, SPAN_WARNING("Someone else is currently using [src]."))
		return
	if(firing)
		to_chat(user, SPAN_WARNING("[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it."))
		return
	add_fingerprint(user)

	if(computer_enabled)
		tgui_interact(user)
	else
		var/choice = alert(user, "Would you like to set the mortar's target coordinates, or dial the mortar? Setting coordinates will make you lose your fire adjustment.", "Mortar Dialing", "Target", "Dial", "Cancel")
		if(choice == "Cancel")
			return
		if(choice == "Target")
			handle_target(user, manual = TRUE)
		if(choice == "Dial")
			handle_dial(user, manual = TRUE)

/obj/structure/mortar/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mortar", "Mortar Interface")
		ui.open()

/obj/structure/mortar/ui_data(mob/user)
	return list(
		"data_target_x" = obfuscate_x(targ_x),
		"data_target_y" = obfuscate_y(targ_y),
		"data_dial_x" = dial_x,
		"data_dial_y" = dial_y
	)

/obj/structure/mortar/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(get_dist(user, src) > 1)
		return FALSE

	switch(action)
		if("set_target")
			handle_target(user, text2num(params["target_x"]), text2num(params["target_y"]))
			return TRUE

		if("set_offset")
			handle_dial(user, text2num(params["dial_x"]), text2num(params["dial_y"]))
			return TRUE

		if("operate_cam")
			internal_camera.tgui_interact(user)

/obj/structure/mortar/proc/handle_target(mob/user, temp_targ_x = 0, temp_targ_y = 0, manual = FALSE)
	if(manual)
		temp_targ_x = input("Input the longitude of the target.") as num
		temp_targ_y = input("Input the latitude of the target.") as num

	if(!can_fire_at(user, test_targ_x = deobfuscate_x(temp_targ_x), test_targ_y = deobfuscate_y(temp_targ_y)))
		return

	user.visible_message(SPAN_NOTICE("[user] starts adjusting [src]'s firing angle and distance."),
	SPAN_NOTICE("You start adjusting [src]'s firing angle and distance to match the new coordinates."))
	busy = TRUE

	var/soundfile = 'sound/machines/scanning.ogg'
	if(manual)
		soundfile = 'sound/items/Ratchet.ogg'
	playsound(loc, soundfile, 25, 1)

	var/success = do_after(user, 3 SECONDS, INTERRUPT_NO_NEEDHAND, BUSY_ICON_FRIENDLY)
	busy = FALSE
	if(!success)
		return
	user.visible_message(SPAN_NOTICE("[user] finishes adjusting [src]'s firing angle and distance."),
	SPAN_NOTICE("You finish adjusting [src]'s firing angle and distance to match the new coordinates."))
	targ_x = deobfuscate_x(temp_targ_x)
	targ_y = deobfuscate_y(temp_targ_y)
	var/offset_x_max = round(abs((targ_x) - x)/offset_per_turfs) //Offset of mortar shot, grows by 1 every 20 tiles travelled
	var/offset_y_max = round(abs((targ_y) - y)/offset_per_turfs)
	offset_x = rand(-offset_x_max, offset_x_max)
	offset_y = rand(-offset_y_max, offset_y_max)

	SStgui.update_uis(src)

/obj/structure/mortar/proc/handle_dial(mob/user, temp_dial_x = 0, temp_dial_y = 0, manual = FALSE)
	if(manual)
		temp_dial_x = input("Set longitude adjustement from -10 to 10.") as num
		temp_dial_y = input("Set latitude adjustement from -10 to 10.") as num

	if(!can_fire_at(user, test_dial_x = temp_dial_x, test_dial_y = temp_dial_y))
		return

	user.visible_message(SPAN_NOTICE("[user] starts dialing [src]'s firing angle and distance."),
	SPAN_NOTICE("You start dialing [src]'s firing angle and distance to match the new coordinates."))
	busy = TRUE

	var/soundfile = 'sound/machines/scanning.ogg'
	if(manual)
		soundfile = 'sound/items/Ratchet.ogg'
	playsound(loc, soundfile, 25, 1)

	var/success = do_after(user, 1.5 SECONDS, INTERRUPT_NO_NEEDHAND, BUSY_ICON_FRIENDLY)
	busy = FALSE
	if(!success)
		return
	user.visible_message(SPAN_NOTICE("[user] finishes dialing [src]'s firing angle and distance."),
	SPAN_NOTICE("You finish dialing [src]'s firing angle and distance to match the new coordinates."))
	dial_x = temp_dial_x
	dial_y = temp_dial_y

	SStgui.update_uis(src)

/obj/structure/mortar/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/mortar_shell))
		var/obj/item/mortar_shell/mortar_shell = O
		if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_TRAINED))
			to_chat(user, SPAN_WARNING("You don't have the training to fire [src]."))
			return
		if(mortar_shell.shell_calibre != shell_calibre)
			to_chat(user, SPAN_WARNING("\The [mortar_shell] doesn't fit into \the [src]!"))
			return
		if(busy)
			to_chat(user, SPAN_WARNING("Someone else is currently using [src]."))
			return
		if(!is_ground_level(z))
			to_chat(user, SPAN_WARNING("You cannot fire [src] here."))
			return
		if(targ_x == 0 && targ_y == 0) //Mortar wasn't set
			to_chat(user, SPAN_WARNING("[src] needs to be aimed first."))
			return
		var/turf/T = locate(targ_x + dial_x + offset_x, targ_y + dial_y + offset_y, z)
		if(!T)
			to_chat(user, SPAN_WARNING("You cannot fire [src] to this target."))
			return
		var/area/A = get_area(T)
		if(istype(A) && CEILING_IS_PROTECTED(A.ceiling, mortar_shell.ceiling_piercing))
			to_chat(user, SPAN_WARNING("You cannot hit the target. It is probably underground."))
			return
		if((!mortar_shell.pylon_bypass && protected_by_pylon(TURF_PROTECTION_MORTAR, T)) || protected_by_pylon(TURF_PROTECTION_OB, T))
			to_chat(user, SPAN_WARNING("You cannot hit the target. It is probably underground."))
			return

		//Small amount of spread so that consecutive mortar shells don't all land on the same tile
		var/turf/T1 = locate(T.x + pick(-1,0,0,1), T.y + pick(-1,0,0,1), T.z)
		if(T1)
			T = T1

		user.visible_message(SPAN_NOTICE("[user] starts loading \a [mortar_shell.name] into [src]."),
		SPAN_NOTICE("You start loading \a [mortar_shell.name] into [src]."))
		playsound(loc, 'sound/weapons/gun_mortar_reload.ogg', 50, 1)
		busy = TRUE
		var/success = do_after(user, 1.5 SECONDS, INTERRUPT_NO_NEEDHAND, BUSY_ICON_HOSTILE)
		busy = FALSE
		if(success)
			user.visible_message(SPAN_NOTICE("[user] loads \a [mortar_shell.name] into [src]."),
			SPAN_NOTICE("You load \a [mortar_shell.name] into [src]."))
			visible_message("[icon2html(src, viewers(src))] [SPAN_DANGER("The [name] fires!")]")
			user.drop_inv_item_to_loc(mortar_shell, src)
			playsound(loc, 'sound/weapons/gun_mortar_fire.ogg', 50, 1)
			busy = FALSE
			firing = TRUE
			flick(icon_state + "_fire", src)
			mortar_shell.source_mob = user
			mortar_shell.forceMove(src)

			var/turf/G = get_turf(src)
			G.ceiling_debris_check(2)

			for(var/mob/M in range(7))
				shake_camera(M, 3, 1)

			addtimer(CALLBACK(src, .proc/handle_shell, T, mortar_shell), travel_time)

	if(HAS_TRAIT(O, TRAIT_TOOL_WRENCH))
		if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_TRAINED))
			to_chat(user, SPAN_WARNING("You don't have the training to undeploy [src]."))
			return
		if(fixed)
			to_chat(user, SPAN_WARNING("[src]'s supports are bolted and welded into the floor. It looks like it's going to be staying there."))
			return
		if(busy)
			to_chat(user, SPAN_WARNING("Someone else is currently using [src]."))
			return
		if(firing)
			to_chat(user, SPAN_WARNING("[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it."))
			return
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message(SPAN_NOTICE("[user] starts undeploying [src]."), \
				SPAN_NOTICE("You start undeploying [src]."))
		if(do_after(user, undeploy_time, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
			user.visible_message(SPAN_NOTICE("[user] undeploys [src]."), \
				SPAN_NOTICE("You undeploy [src]."))
			playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
			var/obj/item/mortar_kit/M = new kit_type(loc)
			M.set_name_label(name_label)
			qdel(src)

	if(HAS_TRAIT(O, TRAIT_TOOL_SCREWDRIVER))
		if(do_after(user, 1 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
			user.visible_message(SPAN_NOTICE("[user] toggles the targeting computer on [src]."), \
				SPAN_NOTICE("You toggle the targeting computer on [src]."))
			computer_enabled = !computer_enabled
			playsound(loc, 'sound/machines/switch.ogg', 25, 1)

/obj/structure/mortar/ex_act(severity)
	switch(severity)
		if(EXPLOSION_THRESHOLD_MEDIUM to INFINITY)
			qdel(src)

/obj/structure/mortar/proc/handle_shell(var/turf/target, var/obj/item/mortar_shell/shell)
	if((!shell.pylon_bypass && protected_by_pylon(TURF_PROTECTION_MORTAR, target)) || protected_by_pylon(TURF_PROTECTION_OB, target))
		firing = FALSE
		return

	playsound(target, 'sound/weapons/gun_mortar_travel.ogg', 50, 1)
	var/relative_dir
	for(var/mob/M in range(15, target))
		relative_dir = get_dir(M, target)
		M.show_message( \
			SPAN_DANGER("A SHELL IS COMING DOWN TOWARDS THE [SPAN_UNDERLINE(uppertext(dir2text(relative_dir)))]!"), 1, \
			SPAN_DANGER("YOU HEAR SOMETHING COMING DOWN TOWARDS THE [SPAN_UNDERLINE(uppertext(dir2text(relative_dir)))]!"), 2 \
		)
	sleep(2.5 SECONDS) // Sleep a bit to give a message
	for(var/mob/M in range(10, target))
		relative_dir = get_dir(M, target)
		M.show_message( \
			SPAN_HIGHDANGER("A SHELL IS ABOUT TO IMPACT TOWARDS THE [SPAN_UNDERLINE(uppertext(dir2text(relative_dir)))]!"), 1, \
			SPAN_HIGHDANGER("YOU HEAR SOMETHING VERY CLOSE COMING DOWN TOWARDS THE [SPAN_UNDERLINE(uppertext(dir2text(relative_dir)))]!"), 2 \
		)
	sleep(2 SECONDS) // Wait out the rest of the landing time
	target.ceiling_debris_check(2)
	if(!protected_by_pylon(TURF_PROTECTION_MORTAR, target) || (shell.pylon_bypass && !protected_by_pylon(TURF_PROTECTION_OB, target)))
		shell.detonate(target)
	qdel(shell)
	firing = FALSE

/obj/structure/mortar/proc/can_fire_at(mob/user, test_targ_x = targ_x, test_targ_y = targ_y, test_dial_x, test_dial_y)
	var/dialing = test_dial_x || test_dial_y
	if(test_dial_x + test_targ_x > world.maxx || test_dial_x + test_targ_x < 0)
		to_chat(user, SPAN_WARNING("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is outside of the area of operations."))
		return FALSE
	if(test_dial_x < -10 || test_dial_x > 10 || test_dial_y < -10 || test_dial_y > 10)
		to_chat(user, SPAN_WARNING("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is too far away from the original target."))
		return FALSE
	if(test_dial_y + test_targ_y > world.maxy || test_dial_y + test_targ_y < 0)
		to_chat(user, SPAN_WARNING("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is outside of the area of operations."))
		return FALSE
	if(minimum_range && get_dist(src, locate(test_targ_x + test_dial_x, test_targ_y + test_dial_y, z)) < minimum_range)
		to_chat(user, SPAN_WARNING("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is too close to your mortar."))
		return FALSE
	if(maximum_range && get_dist(src, locate(test_targ_x + test_dial_x, test_targ_y + test_dial_y, z)) > maximum_range)
		to_chat(user, SPAN_WARNING("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is too far from your mortar."))
		return FALSE
	if(busy)
		to_chat(user, SPAN_WARNING("Someone else is currently using this mortar."))
		return FALSE
	return TRUE

/obj/structure/mortar/fixed
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Uses manual targetting dials. Insert round to fire. This one is bolted and welded into the ground."
	fixed = TRUE

/obj/structure/mortar/wo
	fixed = TRUE
	offset_per_turfs = 50 // The mortar is located at the edge of the map in WO, This to to prevent mass FF

//The portable mortar item
/obj/item/mortar_kit
	name = "\improper M402 mortar portable kit"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first."
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_m402_carry"
	unacidable = TRUE
	w_class = SIZE_HUGE //No dumping this in a backpack. Carry it, fatso

	var/ceiling_deploy_blocker = CEILING_PROTECTION_TIER_1 /// Able to be deployed under ceilings up to but not including this level
	var/deploy_type = 4 SECONDS
	var/mortar_type = /obj/structure/mortar

/obj/item/mortar_kit/breaching
	name = "\improper M420 breaching mortar portable kit"
	desc = "A manual, crew-operated mortar system intended intended to breach through enemy defenses with low yield 60mm shells. Needs to be set down first."

	ceiling_deploy_blocker = CEILING_PROTECTION_TIER_4
	deploy_type = 2 SECONDS
	mortar_type = /obj/structure/mortar/breaching

/obj/item/mortar_kit/ex_act(severity)
	switch(severity)
		if(EXPLOSION_THRESHOLD_MEDIUM to INFINITY)
			qdel(src)

/obj/item/mortar_kit/attack_self(mob/user)
	..()
	var/turf/deploy_turf = get_turf(user)
	if(!deploy_turf)
		return
	if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_TRAINED))
		to_chat(user, SPAN_WARNING("You don't have the training to deploy [src]."))
		return
	if(!is_ground_level(deploy_turf.z))
		to_chat(user, SPAN_WARNING("You cannot deploy [src] here."))
		return
	var/area/A = get_area(deploy_turf)
	if(CEILING_IS_PROTECTED(A.ceiling, ceiling_deploy_blocker))
		to_chat(user, SPAN_WARNING("You probably shouldn't deploy [src] indoors."))
		return
	user.visible_message(SPAN_NOTICE("[user] starts deploying [src]."), \
		SPAN_NOTICE("You start deploying [src]."))
	playsound(deploy_turf, 'sound/items/Deconstruct.ogg', 25, 1)
	if(do_after(user, deploy_type, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		user.visible_message(SPAN_NOTICE("[user] deploys [src]."), \
			SPAN_NOTICE("You deploy [src]."))
		playsound(deploy_turf, 'sound/weapons/gun_mortar_unpack.ogg', 25, 1)
		var/obj/structure/mortar/M = new mortar_type(deploy_turf)
		M.set_name_label(name_label)
		M.setDir(user.dir)
		qdel(src)
