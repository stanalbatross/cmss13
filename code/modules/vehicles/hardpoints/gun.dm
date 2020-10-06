/obj/item/hardpoint/gun
	name = "big gun"
	desc = "big gun with big bulet :)"

	activatable = 1

	// Sounds to play when the gun is fired
	var/list/firing_sounds

	// Accuracy of the hardpoint
	var/accuracy = 1
	// The firing arc of this hardpoint
	var/firing_arc = 360
	// Multiplier for max range of projectiles
	var/range_multiplier = 1

	// Currently loaded ammo
	var/obj/item/ammo_magazine/ammo
	var/list/backup_clips = list()
	var/max_clips = 1 //1 so they can reload their backups and actually reload once

	// Whether or not to make a muzzle flash when the gun is fired
	var/use_muzzle_flash = TRUE
	// List of offsets for where to place the muzzle flash for each direction
	var/list/muzzle_flash_pos = list(
		"1" = list(0, 0),
		"2" = list(0, 0),
		"4" = list(0, 0),
		"8" = list(0, 0)
	)

	// debug vars
	var/use_mz_px_offsets = FALSE
	var/use_mz_trt_offsets = FALSE

	var/const_mz_offset_x = 0
	var/const_mz_offset_y = 0

/obj/item/hardpoint/gun/Destroy()
	for(var/obj/O in backup_clips)
		qdel(O)
	backup_clips = null

	if(ammo)
		qdel(ammo)
	ammo = null

	. = ..()

/obj/item/hardpoint/gun/get_hardpoint_info()
	var/dat = "<hr>"
	dat += "[name]<br>"
	if(health <= 0)
		dat += "Integrity: <font color=\"red\">\[DESTROYED\]</font>"
	else
		dat += "Integrity: [round(get_integrity_percent())]% | Ammo: [ammo ? (ammo.current_rounds ? ammo.current_rounds : "<font color=\"red\">0</font>") : "<font color=\"red\">0</font>"]/[ammo ? ammo.max_rounds : "<font color=\"red\">0</font>"] | Mags: [LAZYLEN(backup_clips) ? LAZYLEN(backup_clips) : "<font color=\"red\">0</font>"]/[max_clips]"
	return dat

/obj/item/hardpoint/gun/activate(var/mob/user, var/atom/A)
	..()
	fire(user, A)

/obj/item/hardpoint/gun/proc/reload(var/mob/user)
	if(!LAZYLEN(backup_clips))
		to_chat(usr, SPAN_WARNING("\The [src] has no remaining backup clips."))
		return

	var/obj/item/ammo_magazine/A = backup_clips[1]
	if(!A)
		to_chat(user, SPAN_DANGER("Something went wrong! Ahelp and ask for a developer! Code: HP_RLDHP"))
		return

	to_chat(user, SPAN_NOTICE("You begin reloading \the [src]."))

	sleep(20)

	forceMove(ammo, get_turf(src))
	ammo.update_icon()
	ammo = A
	backup_clips.Remove(A)

	to_chat(user, SPAN_NOTICE("You reload \the [src]."))

/obj/item/hardpoint/gun/proc/try_add_clip(var/obj/item/ammo_magazine/A, var/mob/user)
	if(max_clips == 0)
		to_chat(user, SPAN_WARNING("\The [src] does not have room for additional ammo."))
		return FALSE
	else if(backup_clips.len >= max_clips)
		to_chat(user, SPAN_WARNING("\The [src]'s reloader is full."))
		return FALSE

	to_chat(user, SPAN_NOTICE("You begin loading \the [A] into \the [src]."))

	if(!do_after(user, 10, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
		to_chat(user, SPAN_WARNING("Something interrupted you while reloading \the [src]."))
		return FALSE

	if(backup_clips.len >= max_clips)
		to_chat(user, SPAN_WARNING("\The [src]'s reloader is full."))
		return FALSE

	user.drop_inv_item_to_loc(A, src)
	to_chat(user, SPAN_NOTICE("You load \the [A] into \the [src]."))
	playsound(loc, 'sound/machines/hydraulics_2.ogg', 50)
	backup_clips += A
	return TRUE

/obj/item/hardpoint/gun/proc/in_firing_arc(var/atom/A)
	if(!owner)
		return FALSE

	var/turf/T = get_turf(A)
	if(!T)
		return FALSE

	var/dx = T.x - (owner.x + origins[1]/2)
	var/dy = T.y - (owner.y + origins[2]/2)

	var/deg = 0
	switch(dir)
		if(EAST)
			deg = 0
		if(NORTH)
			deg = -90
		if(WEST)
			deg = 180
		if(SOUTH)
			deg = 90

	var/nx = dx * cos(deg) - dy * sin(deg)
	var/ny = dx * sin(deg) + dy * cos(deg)
	if(nx == 0)
		return firing_arc >= 90

	var/angle = arctan(ny/nx)
	if(nx < 0)
		angle += 180

	return abs(angle) <= (firing_arc/2)

// Traces backwards from the gun origin to the vehicle to check for obstacles between the vehicle and the muzzle
/obj/item/hardpoint/gun/proc/clear_los(var/atom/A)
	var/turf/muzzle_turf = locate(owner.x + origins[1], owner.y + origins[2], owner.z)

	var/turf/checking_turf = muzzle_turf
	while(!(owner in checking_turf))
		// Dense turfs block LoS
		if(checking_turf.density)
			return FALSE

		// Ensure that we can pass over all objects in the turf
		for(var/obj/O in checking_turf)
			// Since vehicles are multitile the 
			if(O == owner)
				continue

			// Non-dense objects are irrelevant
			if(!O.density)
				continue

			// Make sure we can pass object from all directions
			if(!(LIST_FLAGS_COMPARE(O.pass_flags.flags_can_pass_all, PASS_OVER_THROW_ITEM)))
				if(!(O.flags_atom & ON_BORDER))
					return FALSE
				//If we're behind the object, check the behind pass flags
				else if(dir == O.dir && !(LIST_FLAGS_COMPARE(O.pass_flags.flags_can_pass_behind, PASS_OVER_THROW_ITEM)))
					return FALSE
				//If we're in front, check front pass flags
				else if(dir == turn(O.dir, 180) && !(LIST_FLAGS_COMPARE(O.pass_flags.flags_can_pass_front, PASS_OVER_THROW_ITEM)))
					return FALSE

		// Trace back towards the vehicle
		checking_turf = get_step(checking_turf, turn(dir,180))

	return TRUE

/obj/item/hardpoint/gun/can_activate(var/mob/user, var/atom/A)
	if(!owner)
		return

	if(!owner.seats[VEHICLE_GUNNER] || owner.seats[VEHICLE_GUNNER] != user)
		to_chat(user, SPAN_WARNING("<b>Wrong user detected. Please, report this to developer.</b>"))
		return FALSE

	if(world.time < next_use)
		if(cooldown >= 20)	//filter out guns with high firerate to prevent message spam.
			to_chat(user, SPAN_WARNING("\The [src] will be ready to shoot in [SPAN_HELPFUL((next_use - world.time) / 10)] seconds."))
		return FALSE
	if(health <= 0)
		to_chat(user, SPAN_WARNING("<b>\The [src] is broken!</b>"))
		return FALSE

	if(ammo.current_rounds <= 0)
		to_chat(user, SPAN_WARNING("<b>\The [src] is out of ammo!</b> Magazines: <b>[SPAN_HELPFUL(LAZYLEN(backup_clips))]/[SPAN_HELPFUL(max_clips)]</b>"))
		return FALSE

	if(!in_firing_arc(A))
		to_chat(user, SPAN_WARNING("<b>The target is not within your firing arc!</b>"))
		return FALSE

	if(!clear_los(A))
		to_chat(user, SPAN_WARNING("<b>You don't have a clear line of sight to the target!</b>"))
		return FALSE

	return TRUE

/obj/item/hardpoint/gun/proc/fire(var/mob/user, var/atom/A)
	if(ammo.current_rounds <= 0)
		return

	next_use = world.time + cooldown * owner.misc_multipliers["cooldown"]
	if(!prob((accuracy * 100) / owner.misc_multipliers["accuracy"]))
		A = get_step(get_turf(A), pick(cardinal))

	if(LAZYLEN(firing_sounds))
		playsound(get_turf(src), pick(firing_sounds), 60, 1)

	fire_projectile(user, A)

	to_chat(user, SPAN_WARNING("[src] Ammo: <b>[SPAN_HELPFUL(ammo ? ammo.current_rounds : 0)]/[SPAN_HELPFUL(ammo ? ammo.max_rounds : 0)]</b> | Mags: <b>[SPAN_HELPFUL(LAZYLEN(backup_clips))]/[SPAN_HELPFUL(max_clips)]</b>"))

/obj/item/hardpoint/gun/proc/fire_projectile(var/mob/user, var/atom/A, var/iff_on = FALSE)
	set waitfor = 0

	var/turf/origin_turf = get_turf(src)
	origin_turf = locate(origin_turf.x + origins[1], origin_turf.y + origins[2], origin_turf.z)

	var/obj/item/projectile/P = new(initial(name), user)
	P.loc = origin_turf
	P.generate_bullet(new ammo.default_ammo)
	if(iff_on)
		P.fire_at(A, owner.seats[VEHICLE_GUNNER], src, P.ammo.max_range, P.ammo.shell_speed, iff_group = owner.seats[VEHICLE_GUNNER].faction_group)
	else
		P.fire_at(A, owner.seats[VEHICLE_GUNNER], src, P.ammo.max_range, P.ammo.shell_speed)

	if(use_muzzle_flash)
		muzzle_flash(Get_Angle(owner, A))

	ammo.current_rounds--

/obj/item/hardpoint/gun/proc/muzzle_flash(var/angle)
	if(isnull(angle)) return

	// The +48 and +64 centers the muzzle flash
	var/muzzle_flash_x = muzzle_flash_pos["[dir]"][1] + 48
	var/muzzle_flash_y = muzzle_flash_pos["[dir]"][2] + 64

	// Account for turret rotation
	if(istype(loc, /obj/item/hardpoint/holder))
		var/obj/item/hardpoint/holder/H = loc
		if(LAZYLEN(H.px_offsets))
			muzzle_flash_x += H.px_offsets["[H.loc.dir]"][1]
			muzzle_flash_y += H.px_offsets["[H.loc.dir]"][2]

	var/image_layer = owner.layer + 0.1

	var/image/I = image('icons/obj/items/weapons/projectiles.dmi',src,"muzzle_flash",image_layer)
	var/matrix/rotate = matrix() //Change the flash angle.
	rotate.Turn(angle)
	rotate.Translate(muzzle_flash_x, muzzle_flash_y)
	I.transform = rotate
	I.flick_overlay(owner, 3)

// debug proc
/obj/item/hardpoint/gun/proc/set_mf_offset(var/dir, var/x, var/y)
	if(!muzzle_flash_pos)
		muzzle_flash_pos = list(
			"1" = list(0,0),
			"2" = list(0,0),
			"4" = list(0,0),
			"8" = list(0,0)
		)

	muzzle_flash_pos[dir] = list(x,y)

// debug proc
/obj/item/hardpoint/gun/proc/set_mf_use_px(var/use)
	use_mz_px_offsets = use

// debug proc
/obj/item/hardpoint/gun/proc/set_mf_use_trt(var/use)
	use_mz_trt_offsets = use
