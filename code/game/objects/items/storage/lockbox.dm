//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = SIZE_LARGE
	max_w_class = SIZE_MEDIUM
	max_storage_space = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(ACCESS_MARINE_COMMANDER)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/card/id))
			if(src.broken)
				to_chat(user, SPAN_DANGER("It appears to be broken."))
				return
			if(src.allowed(user))
				src.locked = !( src.locked )
				if(src.locked)
					src.icon_state = src.icon_locked
					to_chat(user, SPAN_DANGER("You lock the [src.name]!"))
					return
				else
					src.icon_state = src.icon_closed
					to_chat(user, SPAN_DANGER("You unlock the [src.name]!"))
					return
			else
				to_chat(user, SPAN_DANGER("Access Denied"))
		if(!locked)
			..()
		else
			to_chat(user, SPAN_DANGER("It's locked!"))
		return


	show_to(mob/user as mob)
		if(locked)
			to_chat(user, SPAN_DANGER("It's locked!"))
		else
			..()
		return


/obj/item/storage/lockbox/loyalty
	name = "\improper Wey-Yu equipment lockbox"
	req_access = list(ACCESS_WY_CORPORATE)

/obj/item/storage/lockbox/loyalty/fill_preset_inventory()
	new /obj/item/ammo_magazine/pistol/mod88(src)
	new /obj/item/ammo_magazine/pistol/mod88(src)
	new /obj/item/ammo_magazine/pistol/mod88/rubber(src)
	new /obj/item/ammo_magazine/pistol/mod88/rubber(src)


/obj/item/storage/lockbox/cluster
	name = "lockbox of cluster flashbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_MARINE_BRIG)

/obj/item/storage/lockbox/clusterbang/fill_preset_inventory()
	new /obj/item/explosive/grenade/flashbang/cluster(src)

/obj/item/storage/co_wl_surv_lockbox
	name = "\improper FORECON major's briefcase"
	desc = "A brown briefcase with a fingerprint locking mechanism. 'PROPERTY OF USCM FORCE RECONNAISSANCE' Is written along the side."
	icon_state = "secure"
	item_state = "sec-case"
	max_storage_space = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4

/obj/item/storage/co_wl_surv_lockbox/fill_preset_inventory()
	new /obj/item/ammo_magazine/pistol/mod88(src)
	new /obj/item/ammo_magazine/pistol/mod88(src)
	new /obj/item/ammo_magazine/pistol/mod88/rubber(src)
	new /obj/item/ammo_magazine/pistol/mod88/rubber(src)

/obj/item/storage/co_wl_surv_lockbox/proc/wl_and_job_check(mob/user)
	var/mob/living/carbon/human/H = user
	var/whitelist_flags = RoleAuthority.roles_whitelist[user.ckey]
	if(!ishuman(user))
		return FALSE
	if(!issurvivorjob(H.job))
		to_chat(H, SPAN_WARNING("You try to open \the [src], but it won't budge! You probably don't have the right ship's access codes..."))
		return FALSE
	if(!(whitelist_flags & (WHITELIST_COMMANDER_COUNCIL|WHITELIST_COMMANDER_COUNCIL_LEGACY)))
		to_chat(H, SPAN_WARNING("You try to open \the [src], but it won't budge! You probably don't have the right rank's access codes..."))
		return FALSE
	return TRUE

/obj/item/storage/co_wl_surv_lockbox/show_to(mob/user)
	if(wl_and_job_check(user))
		. = ..()

/obj/item/storage/co_wl_surv_lockbox/attackby(obj/item/W, mob/user)
	if(wl_and_job_check(user))
		. = ..()

/obj/item/storage/co_wl_surv_lockbox/empty(mob/user, turf/T)
	if(wl_and_job_check(user))
		. = ..()

