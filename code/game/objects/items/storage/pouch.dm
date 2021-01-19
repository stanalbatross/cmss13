/obj/item/storage/pouch
	name = "abstract pouch"
	desc = "The physical manifestation of a concept of a pouch. Woah."
	icon = 'icons/obj/items/clothing/pouches.dmi'
	icon_state = "small_drop"
	w_class = SIZE_LARGE //does not fit in backpack
	max_w_class = SIZE_SMALL
	flags_equip_slot = SLOT_STORE
	storage_slots = 1
	storage_flags = STORAGE_FLAGS_POUCH


/obj/item/storage/pouch/update_icon()
	overlays.Cut()
	if(!contents.len)
		return
	else if(contents.len <= storage_slots * 0.5)
		overlays += "+[icon_state]_half"
	else
		overlays += "+[icon_state]_full"


/obj/item/storage/pouch/examine(mob/user)
	..()
	to_chat(user, "Can be worn by attaching it to a pocket.")


/obj/item/storage/pouch/equipped(mob/user, slot)
	if(slot == WEAR_L_STORE || slot == WEAR_R_STORE)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/pouch/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()




/obj/item/storage/pouch/general
	name = "light general pouch"
	desc = "A general purpose pouch used to carry small items and ammo magazines."
	icon_state = "small_drop"
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
	)

/obj/item/storage/pouch/general/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/ammo_magazine/shotgun))
		var/obj/item/ammo_magazine/shotgun/M = W
		dump_into(M,user)
	else if(istype(W, /obj/item/storage/box/nade_box))
		var/obj/item/storage/box/nade_box/M = W
		dump_into(M,user)
	else if(istype(W, /obj/item/storage/box/m94))
		var/obj/item/storage/box/m94/M = W
		dump_into(M,user)
	else
		return ..()

/obj/item/storage/pouch/general/medium
	name = "medium general pouch"
	storage_slots = 2
	icon_state = "medium_drop"
	storage_flags = STORAGE_FLAGS_POUCH

/obj/item/storage/pouch/general/large
	name = "large general pouch"
	storage_slots = 3
	icon_state = "large_drop"
	storage_flags = STORAGE_FLAGS_POUCH

/obj/item/storage/pouch/flamertank
	name = "fuel tank strap pouch"
	desc = "Two rings straps that loop around M240 variety napalm tanks. Handle with care."
	storage_slots = 2
	icon_state = "fueltank_pouch"
	storage_flags = STORAGE_FLAGS_POUCH
	can_hold = list(
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/tool/extinguisher
					)
	bypass_w_limit = list(
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/tool/extinguisher
					)

/obj/item/storage/pouch/general/large/m39ap/fill_preset_inventory()
	new /obj/item/ammo_magazine/smg/m39/ap(src)
	new /obj/item/ammo_magazine/smg/m39/ap(src)
	new /obj/item/ammo_magazine/smg/m39/ap(src)

/obj/item/storage/pouch/bayonet
	name = "bayonet sheath"
	desc = "Knife to meet you!"
	can_hold = list(
		/obj/item/weapon/melee/throwing_knife,
		/obj/item/attachable/bayonet
	)
	icon_state = "bayonet"
	storage_slots = 5
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD
	var/draw_cooldown = 0
	var/draw_cooldown_interval = 1 SECONDS

/obj/item/storage/pouch/bayonet/Initialize()
	. = ..()
	for(var/total_storage_slots in 1 to storage_slots)
		new /obj/item/weapon/melee/throwing_knife(src)

/obj/item/storage/pouch/bayonet/upp/Initialize()
	. = ..()
	for(var/total_storage_slots in 1 to storage_slots)
		new /obj/item/attachable/bayonet/upp(src)

/obj/item/storage/pouch/bayonet/handle_item_insertion(obj/item/W, prevent_warning = 0)
	. = ..()
	if(.)
		playsound(src,'sound/weapons/gun_shotgun_shell_insert.ogg', 15, 1)

/obj/item/storage/pouch/bayonet/remove_from_storage(obj/item/W, atom/new_location)
	. = ..()
	if(.)
		playsound(src,'sound/weapons/gun_shotgun_shell_insert.ogg', 15, 1)

/obj/item/storage/pouch/bayonet/attack_hand(mob/user)
	if(draw_cooldown < world.time)
		..()
		draw_cooldown = world.time + draw_cooldown_interval
		playsound(src,'sound/weapons/gun_shotgun_shell_insert.ogg', 15, 1)
	else
		to_chat(user, SPAN_WARNING("You need to wait before drawing another knife!"))
		return 0

/obj/item/storage/pouch/survival
	name = "survival pouch"
	desc = "It can contain flashlights, a pill, a crowbar, metal sheets, and some bandages."
	icon_state = "survival"
	storage_slots = 5
	max_w_class = SIZE_MEDIUM
	can_hold = list(
		/obj/item/device/flashlight,
		/obj/item/tool/crowbar,
		/obj/item/reagent_container/pill,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/sheet/metal
	)

/obj/item/storage/pouch/survival/full/fill_preset_inventory()
	new /obj/item/device/flashlight(src)
	new /obj/item/tool/crowbar/red(src)
	new /obj/item/reagent_container/pill/tramadol(src)
	new /obj/item/stack/medical/bruise_pack (src, 3)
	new /obj/item/stack/sheet/metal(src, 60)


/obj/item/storage/pouch/firstaid
	name = "first-aid pouch"
	desc = "It can contain autoinjectors, ointments, and bandages."
	icon_state = "firstaid"
	storage_slots = 4
	can_hold = list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_container/hypospray/autoinjector/skillless/tramadol,
		/obj/item/reagent_container/hypospray/autoinjector/skillless,
		/obj/item/stack/medical/bruise_pack
	)

/obj/item/storage/pouch/firstaid/full
	desc = "Contains a painkiller autoinjector, first-aid autoinjector, some ointment, and some bandages."

/obj/item/storage/pouch/firstaid/full/fill_preset_inventory()
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_container/hypospray/autoinjector/skillless/tramadol(src)
	new /obj/item/reagent_container/hypospray/autoinjector/skillless(src)
	new /obj/item/stack/medical/bruise_pack(src)

/obj/item/storage/pouch/pistol
	name = "sidearm pouch"
	desc = "It can contain a pistol. Useful for emergencies."
	icon_state = "pistol"
	max_w_class = SIZE_MEDIUM
	can_hold = list(/obj/item/weapon/gun/pistol, /obj/item/weapon/gun/revolver/m44,/obj/item/weapon/gun/flare)
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD



//// MAGAZINE POUCHES /////

/obj/item/storage/pouch/magazine
	name = "magazine pouch"
	desc = "It can contain ammo magazines."
	icon_state = "medium_ammo_mag"
	max_w_class = SIZE_MEDIUM
	storage_slots = 3
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg/m39
	)
	can_hold = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful
	)

/obj/item/storage/pouch/magazine/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/ammo_magazine/shotgun))
		var/obj/item/ammo_magazine/shotgun/M = W
		dump_into(M,user)
	else
		return ..()

/obj/item/storage/pouch/magazine/large
	name = "large magazine pouch"
	desc = "It can contain many ammo magazines."
	icon_state = "large_ammo_mag"
	storage_slots = 4

/obj/item/storage/pouch/magazine/large/with_beanbags

/obj/item/storage/pouch/magazine/large/with_beanbags/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		var/obj/item/ammo_magazine/handful/H = new(src)
		H.generate_handful(/datum/ammo/bullet/shotgun/beanbag, "12g", 5, 5, /obj/item/weapon/gun/shotgun)


/obj/item/storage/pouch/magazine/pistol
	name = "pistol magazine pouch"
	desc = "It can contain pistol ammo magazines and revolver speedloaders."
	max_w_class = SIZE_SMALL
	icon_state = "pistol_mag"
	storage_slots = 3

	can_hold = list(
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/pouch/magazine/pistol/large
	name = "large pistol magazine pouch"
	desc = "It can contain many pistol ammo magazines and revolver speedloaders."
	storage_slots = 6
	icon_state = "large_pistol_mag"


/obj/item/storage/pouch/magazine/pistol/pmc_mateba/fill_preset_inventory()
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)

/obj/item/storage/pouch/magazine/pistol/pmc_mod88/fill_preset_inventory()
	new /obj/item/ammo_magazine/pistol/mod88(src)
	new /obj/item/ammo_magazine/pistol/mod88(src)
	new /obj/item/ammo_magazine/pistol/mod88(src)

/obj/item/storage/pouch/magazine/pistol/pmc_vp78/fill_preset_inventory()
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)

/obj/item/storage/pouch/magazine/upp/fill_preset_inventory()
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)

/obj/item/storage/pouch/magazine/large/upp/fill_preset_inventory()
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)

/obj/item/storage/pouch/magazine/upp_smg/fill_preset_inventory()
	new /obj/item/ammo_magazine/smg/skorpion(src)
	new /obj/item/ammo_magazine/smg/skorpion(src)
	new /obj/item/ammo_magazine/smg/skorpion(src)

/obj/item/storage/pouch/magazine/large/pmc_m39/fill_preset_inventory()
	new /obj/item/ammo_magazine/smg/m39/ap(src)
	new /obj/item/ammo_magazine/smg/m39/ap(src)
	new /obj/item/ammo_magazine/smg/m39/ap(src)
	new /obj/item/ammo_magazine/smg/m39/ap(src)

/obj/item/storage/pouch/magazine/large/pmc_p90/fill_preset_inventory()
	new /obj/item/ammo_magazine/smg/fp9000(src)
	new /obj/item/ammo_magazine/smg/fp9000(src)
	new /obj/item/ammo_magazine/smg/fp9000(src)
	new /obj/item/ammo_magazine/smg/fp9000(src)

/obj/item/storage/pouch/magazine/large/pmc_lmg/fill_preset_inventory()
	new /obj/item/ammo_magazine/rifle/lmg(src)
	new /obj/item/ammo_magazine/rifle/lmg(src)
	new /obj/item/ammo_magazine/rifle/lmg(src)
	new /obj/item/ammo_magazine/rifle/lmg(src)

/obj/item/storage/pouch/magazine/large/pmc_sniper/fill_preset_inventory()
	new /obj/item/ammo_magazine/sniper/elite(src)
	new /obj/item/ammo_magazine/sniper/elite(src)
	new /obj/item/ammo_magazine/sniper/elite(src)
	new /obj/item/ammo_magazine/sniper/elite(src)

/obj/item/storage/pouch/magazine/large/pmc_rifle/fill_preset_inventory()
	new /obj/item/ammo_magazine/rifle/ap(src)
	new /obj/item/ammo_magazine/rifle/ap(src)
	new /obj/item/ammo_magazine/rifle/ap(src)
	new /obj/item/ammo_magazine/rifle/ap(src)

/obj/item/storage/pouch/magazine/large/pmc_sg/fill_preset_inventory()
	new /obj/item/ammo_magazine/smartgun/dirty(src)
	new /obj/item/ammo_magazine/smartgun/dirty(src)
	new /obj/item/ammo_magazine/smartgun/dirty(src)
	new /obj/item/ammo_magazine/smartgun/dirty(src)

/obj/item/storage/pouch/explosive
	name = "explosive pouch"
	desc = "It can contain grenades, plastic explosives, mine boxes, and other explosives."
	icon_state = "large_explosive"
	storage_slots = 3
	max_w_class = SIZE_MEDIUM
	can_hold = list(
		/obj/item/explosive/plastic,
		/obj/item/explosive/mine,
		/obj/item/explosive/grenade,
		/obj/item/storage/box/explosive_mines
	)

/obj/item/storage/pouch/explosive/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/box/nade_box))
		var/obj/item/storage/box/nade_box/M = W
		dump_into(M,user)
	else
		return ..()

/obj/item/storage/pouch/explosive/full/fill_preset_inventory()
	new /obj/item/explosive/grenade/HE(src)
	new /obj/item/explosive/grenade/HE(src)
	new /obj/item/explosive/grenade/HE(src)

/obj/item/storage/pouch/explosive/upp/fill_preset_inventory()
	new /obj/item/explosive/plastic(src)
	new /obj/item/explosive/plastic(src)
	new /obj/item/explosive/plastic(src)

/obj/item/storage/pouch/medical
	name = "medical pouch"
	desc = "It can contain small medical supplies."
	icon_state = "medical"
	storage_slots = 3

	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/reagent_container/dropper,
		/obj/item/reagent_container/pill,
		/obj/item/reagent_container/glass/bottle,
		/obj/item/reagent_container/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/device/flashlight/pen,
		/obj/item/reagent_container/hypospray
	)

/obj/item/storage/pouch/medical/full/fill_preset_inventory()
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)

/obj/item/storage/pouch/medical/frt_kit
	name = "first responder technical pouch"
	desc = "Holds everything one might need for rapid field triage and treatment. Make sure to coordinate with the proper field medics."
	icon_state = "frt_med"
	storage_slots = 4
	can_hold = list(
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle,
		/obj/item/device/healthanalyzer,
		/obj/item/reagent_container/hypospray,
		/obj/item/tool/extinguisher/mini,
		/obj/item/reagent_container/glass/bottle,
		/obj/item/storage/syringe_case,
	)

/obj/item/storage/pouch/medical/frt_kit/full/fill_preset_inventory()
	new /obj/item/device/healthanalyzer(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)

/obj/item/storage/pouch/vials
	name = "vial pouch"
	desc = "A pouch for carrying glass vials."
	icon_state = "vial"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_container/glass/beaker/vial)

/obj/item/storage/pouch/vials/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/fancy/vials))
		var/obj/item/storage/fancy/vials/M = W
		dump_into(M,user)
	else
		return ..()

/obj/item/storage/pouch/vials/full/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		new /obj/item/reagent_container/glass/beaker/vial(src)

/obj/item/storage/pouch/chem
	name = "chemist pouch"
	desc = "A pouch for carrying glass beakers."
	icon_state = "chemist"
	storage_slots = 2
	can_hold = list(
		/obj/item/reagent_container/glass/beaker,
		/obj/item/reagent_container/glass/bottle
	)

/obj/item/storage/pouch/chem/fill_preset_inventory()
	new /obj/item/reagent_container/glass/beaker/large(src)
	new /obj/item/reagent_container/glass/beaker(src)

/obj/item/storage/pouch/autoinjector
	name = "auto-injector pouch"
	desc = "A pouch specifically for auto-injectors."
	icon_state = "injectors"
	storage_slots = 7
	can_hold = list(/obj/item/reagent_container/hypospray/autoinjector)

/obj/item/storage/pouch/autoinjector/full/fill_preset_inventory()
	new /obj/item/reagent_container/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_container/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_container/hypospray/autoinjector/kelotane(src)
	new /obj/item/reagent_container/hypospray/autoinjector/kelotane(src)
	new /obj/item/reagent_container/hypospray/autoinjector/tramadol(src)
	new /obj/item/reagent_container/hypospray/autoinjector/tramadol(src)
	new /obj/item/reagent_container/hypospray/autoinjector/emergency(src)

/obj/item/storage/pouch/syringe
	name = "syringe pouch"
	desc = "It can contain syringes."
	icon_state = "syringe"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_container/syringe)

/obj/item/storage/pouch/syringe/full/fill_preset_inventory()
	new /obj/item/reagent_container/syringe(src)
	new /obj/item/reagent_container/syringe(src)
	new /obj/item/reagent_container/syringe(src)
	new /obj/item/reagent_container/syringe(src)
	new /obj/item/reagent_container/syringe(src)
	new /obj/item/reagent_container/syringe(src)

/obj/item/storage/pouch/medkit
	name = "medkit pouch"
	max_w_class = SIZE_MEDIUM
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD
	icon_state = "medkit"
	desc = "It's specifically made to hold a medkit."
	can_hold = list(/obj/item/storage/firstaid)


/obj/item/storage/pouch/medkit/full/fill_preset_inventory()
	new /obj/item/storage/firstaid/regular(src)

/obj/item/storage/pouch/medkit/full_advanced/fill_preset_inventory()
	new /obj/item/storage/firstaid/adv(src)


/obj/item/storage/pouch/pressurized_reagent_canister
	name = "Pressurized Reagent Canister Pouch"
	max_w_class = SIZE_SMALL
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD
	icon_state = "pressurized_reagent_canister"
	desc = "A pressurized reagent canister pouch. It is used to refill custom injectors, and can also store one. May be refilled with a reagent tank or a Chemical Dispenser."
	can_hold = list(/obj/item/reagent_container/hypospray/autoinjector/empty)
	var/obj/item/reagent_container/glass/pressurized_canister/inner
	matter = list("plastic" = 3000)

/obj/item/storage/pouch/pressurized_reagent_canister/Initialize()
	. = ..()
	inner = new /obj/item/reagent_container/glass/pressurized_canister()
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/bicaridine/Initialize()
	. = ..()
	inner.reagents.add_reagent("bicaridine", inner.volume)
	new /obj/item/reagent_container/hypospray/autoinjector/empty/medic(src)
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/kelotane/Initialize()
	. = ..()
	inner.reagents.add_reagent("kelotane", inner.volume)
	new /obj/item/reagent_container/hypospray/autoinjector/empty/medic/(src)
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/revival/Initialize()
	. = ..()
	inner.reagents.add_reagent("adrenaline", inner.volume/2.5)
	inner.reagents.add_reagent("inaprovaline", inner.volume/2.5)
	inner.reagents.add_reagent("peridaxon", inner.volume/5)
	new /obj/item/reagent_container/hypospray/autoinjector/empty/medic(src)
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_container/glass/pressurized_canister))
		if(inner)
			to_chat(user, SPAN_WARNING("There already is a container inside [src]!"))
		else
			user.drop_inv_item_to_loc(W, src)
			inner = W
			contents -= W
			to_chat(user, SPAN_NOTICE("You insert [W] into [src]!"))
			update_icon()
		return

	if(istype(W, /obj/item/reagent_container/hypospray/autoinjector/empty))
		var/obj/item/reagent_container/hypospray/autoinjector/A = W
		var/max_uses = A.volume / A.amount_per_transfer_from_this
		max_uses = round(max_uses) == max_uses ? max_uses : round(max_uses) + 1
		if(inner && inner.reagents.total_volume > 0 && (A.uses_left < max_uses))
			inner.reagents.trans_to(A, A.volume)
			var/uses_left = A.reagents.total_volume / A.amount_per_transfer_from_this
			uses_left = round(uses_left) == uses_left ? uses_left : round(uses_left) + 1
			A.uses_left = uses_left
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			A.update_icon()
		return ..()
	else if(istype(W, /obj/item/reagent_container/hypospray/autoinjector))
		to_chat(user, SPAN_WARNING("[W] is not compatible with this system!"))
	return ..()


/obj/item/storage/pouch/pressurized_reagent_canister/afterattack(obj/target, mob/user, flag) //refuel at fueltanks & chem dispensers.
	if(!inner)
		to_chat(user, SPAN_WARNING("[src] has no internal container!"))
		return ..()

	if(istype(target, /obj/structure/machinery/chem_dispenser))
		var/obj/structure/machinery/chem_dispenser/cd = target
		if(!cd.beaker)
			to_chat(user, SPAN_NOTICE("You unhook the inner container and connect it to [target]."))
			inner.forceMove(cd)
			cd.beaker = inner
			inner = null
			update_icon()
		else
			to_chat(user, SPAN_WARNING("[cd] already has a container!"))
		return

	if(!istype(target, /obj/structure/reagent_dispensers/fueltank))
		return ..()

	if(get_dist(user,target) > 1)
		return ..()

	var/obj/O = target
	if(!O.reagents || O.reagents.reagent_list.len < 1)
		to_chat(user, SPAN_WARNING("[O] is empty!"))
		return

	var/amt_to_remove = Clamp(O.reagents.total_volume, 0, inner.volume)
	if(!amt_to_remove)
		to_chat(user, SPAN_WARNING("[O] is empty!"))
		return

	O.reagents.trans_to(inner, amt_to_remove)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)

	to_chat(user, SPAN_NOTICE("You refill the [src]."))
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/examine(mob/user)
	..()
	display_contents(user)

/obj/item/storage/pouch/pressurized_reagent_canister/update_icon()
	..()
	if(inner)
		overlays += "+[icon_state]_loaded"


/obj/item/storage/pouch/pressurized_reagent_canister/empty(mob/user)
	return //Useless, it's a one slot.

/obj/item/storage/pouch/pressurized_reagent_canister/proc/display_contents(mob/user) // Used on examine for properly skilled people to see contents.
	if(isXeno(user))
		return
	if(!inner)
		to_chat(user, "This [src] has no container inside!")
		return
	if(skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_TRAINED))
		to_chat(user, "This [src] contains: [get_reagent_list_text()]")
	else
		to_chat(user, "You don't know what's in it.")

//returns a text listing the reagents (and their volume) in the atom. Used by Attack logs for reagents in pills
/obj/item/storage/pouch/pressurized_reagent_canister/proc/get_reagent_list_text()
	if(inner && inner.reagents && inner.reagents.reagent_list && inner.reagents.reagent_list.len)
		var/datum/reagent/R = inner.reagents.reagent_list[1]
		. = "[R.name]([R.volume]u)"

		if(inner.reagents.reagent_list.len < 2)
			return

		for(var/i in 2 to inner.reagents.reagent_list.len)
			R = inner.reagents.reagent_list[i]

			if(!R)
				continue

			. += "; [R.name]([R.volume]u)"
	else
		. = "No reagents"

/obj/item/storage/pouch/pressurized_reagent_canister/verb/flush_container()
	set category = "Weapons"
	set name = "Flush Container"
	set desc = "Forces the container to empty its reagents."
	set src in usr
	if(!inner)
		to_chat(usr, SPAN_WARNING("There is no container inside this pouch!"))
		return

	to_chat(usr, SPAN_NOTICE("You hold down the emergency flush button. Wait 3 seconds..."))
	if(do_after(usr, 3 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		if(inner)
			to_chat(usr, SPAN_NOTICE("You flush the [src]."))
			inner.reagents.clear_reagents()


/obj/item/storage/pouch/document
	name = "large document pouch"
	desc = "It can contain papers, folders, disks, technical manuals, and clipboards."
	icon_state = "document"
	storage_slots = 21
	max_w_class = SIZE_MEDIUM
	max_storage_space = 21
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_CLICK_GATHER
	can_hold = list(
		/obj/item/paper,
		/obj/item/clipboard,
		/obj/item/document_objective/paper,
		/obj/item/document_objective/report,
		/obj/item/document_objective/folder,
		/obj/item/disk/objective,
		/obj/item/document_objective/technical_manual
	)

/obj/item/storage/pouch/document/small
	name = "small document pouch"
	storage_slots = 7

/obj/item/storage/pouch/flare
	name = "flare pouch"
	desc = "A pouch designed to hold flares. Refillable with a M94 flare pack."
	max_w_class = SIZE_SMALL
	storage_slots = 8
	max_storage_space = 8
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD
	icon_state = "flare"
	can_hold = list(/obj/item/device/flashlight/flare,/obj/item/device/flashlight/flare/signal)

/obj/item/storage/pouch/flare/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/box/m94))
		var/obj/item/storage/box/m94/M = W
		dump_into(M,user)
	else
		return ..()

/obj/item/storage/pouch/flare/full/fill_preset_inventory()
	for(var/i = 1 to storage_slots)
		new /obj/item/device/flashlight/flare(src)

/obj/item/storage/pouch/radio
	name = "radio pouch"
	storage_slots = 2
	icon_state = "radio"
	storage_flags = STORAGE_FLAGS_POUCH|STORAGE_USING_DRAWING_METHOD
	desc = "It can contain two handheld radios."
	can_hold = list(/obj/item/device/radio)


/obj/item/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"
	storage_slots = 6
	can_hold = list(
		/obj/item/circuitboard,
		/obj/item/cell
	)

/obj/item/storage/pouch/electronics/full/fill_preset_inventory()
	new /obj/item/circuitboard/apc(src)
	new /obj/item/cell/high(src)

/obj/item/storage/pouch/construction
	name = "construction pouch"
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has two hooks for an entrenching tool and light replacer."
	storage_slots = 3
	max_w_class = SIZE_MEDIUM
	icon_state = "construction"
	can_hold = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/stack/tile,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/sandbags_empty,
		/obj/item/device/lightreplacer,
	)

/obj/item/storage/pouch/construction/full/fill_preset_inventory()
	var/obj/item/stack/sheet/plasteel/PLAS = new /obj/item/stack/sheet/plasteel(src)
	PLAS.amount = 50
	var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(src)
	MET.amount = 50
	var/obj/item/stack/sandbags_empty/SND1 = new /obj/item/stack/sandbags_empty(src)
	SND1.amount = 50

/obj/item/storage/pouch/tools
	name = "tools pouch"
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool."
	storage_slots = 4
	max_w_class = SIZE_MEDIUM
	icon_state = "tools"
	can_hold = list(
		/obj/item/tool/wirecutters,
		/obj/item/tool/shovel/etool,
		/obj/item/tool/screwdriver,
		/obj/item/tool/crowbar,
		/obj/item/tool/weldingtool,
		/obj/item/device/multitool,
		/obj/item/tool/wrench,
		/obj/item/stack/cable_coil,
		/obj/item/tool/extinguisher/mini,
		/obj/item/tool/shovel/etool
	)
	bypass_w_limit = list(/obj/item/tool/shovel/etool)

/obj/item/storage/pouch/tools/full/fill_preset_inventory()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/device/multitool(src)
	new /obj/item/tool/wrench(src)

/obj/item/storage/pouch/tools/pfc/fill_preset_inventory()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/wrench(src)

/obj/item/storage/pouch/tools/synth/fill_preset_inventory()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/device/multitool(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/stack/cable_coil(src)

/obj/item/storage/pouch/tools/tank/fill_preset_inventory()
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool/hugetank(src)
	new /obj/item/tool/extinguisher/mini(src)
