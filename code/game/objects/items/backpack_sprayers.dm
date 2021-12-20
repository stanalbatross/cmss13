//Hydroponics tank and base code
/obj/item/reagent_container/glass/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/items/backpack_sprayers.dmi'
	icon_state = "backpack_sprayer"
	item_state = "backpack_sprayer"
	w_class = SIZE_LARGE
	flags_equip_slot = SLOT_BACK
	flags_atom = OPENCONTAINER
	volume = 500

	var/obj/item/noz

/obj/item/reagent_container/glass/watertank/Initialize(mapload)
	. = ..()
	overlays += "[icon_state]_nozzle"
	noz = make_noz()
	noz.AddElement(/datum/element/drop_retrieval/mister)

/obj/item/reagent_container/glass/watertank/Initialize()
	. = ..()
	reagents.add_reagent("cleaner", 500)
	update_icon()

/obj/item/reagent_container/glass/watertank/Destroy()
	QDEL_NULL(noz)
	return ..()

/obj/item/reagent_container/glass/watertank/proc/toggle_mister(mob/living/user)
	if(!istype(user))
		return
	if(user.get_item_by_slot(WEAR_BACK) != src)
		to_chat(user, SPAN_WARNING("The watertank must be worn properly to use!"))
		return
	if(user.is_mob_incapacitated())
		return

	if(QDELETED(noz))
		noz = make_noz()
		noz.AddElement(/datum/element/drop_retrieval/mister)
	if(noz in src)
		//Detach the nozzle into the user's hands
		overlays -= "[icon_state]_nozzle"
		if(!user.put_in_hands(noz))
			to_chat(user, SPAN_WARNING("You need a free hand to hold the mister!"))
			overlays += "[icon_state]_nozzle"
			return
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
		overlays += "[icon_state]_nozzle"



/obj/item/reagent_container/glass/watertank/proc/make_noz()
	return new /obj/item/reagent_container/spray/mister(src)

/obj/item/reagent_container/glass/watertank/equipped(mob/user, slot)
	..()
	if(slot != WEAR_BACK)
		remove_noz()

/obj/item/reagent_container/glass/watertank/proc/remove_noz()
	qdel(noz)
	icon_state = initial(icon_state)
	overlays += "[icon_state]_nozzle"
	if(!QDELETED(noz))
		qdel(noz)
		icon_state = initial(icon_state)

/obj/item/reagent_container/glass/watertank/attack_hand(mob/user, list/modifiers)
	if (user.get_item_by_slot(WEAR_BACK) == src)
		toggle_mister(user)
	else
		return ..()

/obj/item/reagent_container/glass/watertank/attackby(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
	else
		. = ..()


/obj/item/reagent_container/glass/watertank/verb/toggle_mister_verb()
	set name = "Toggle Mister"
	set category = "Object"
	toggle_mister(usr)

/obj/item/reagent_container/glass/watertank/MouseDrop(obj/over_object as obj)
	if(!CAN_PICKUP(usr, src))
		return ..()
	if(!istype(over_object, /obj/screen))
		return ..()
	if(loc != usr) //Makes sure that the sprayer backpack is equipped, so that we can't drag it into our hand from miles away.
		return ..()

	switch(over_object.name)
		if("r_hand")
			usr.drop_inv_item_on_ground(src)
			usr.put_in_r_hand(src)
		if("l_hand")
			usr.drop_inv_item_on_ground(src)
			usr.put_in_l_hand(src)
	add_fingerprint(usr)

/obj/item/reagent_container/glass/watertank/attackby(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
		return 1
	else
		return ..()

/obj/item/reagent_container/glass/watertank/dropped(mob/user)
	..()
	remove_noz()

/obj/item/reagent_container/glass/watertank/examine(mob/user)
	..()

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/reagent_container/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/items/backpack_sprayers.dmi'
	icon_state = "nozzle"
	item_state = "nozzle"
	w_class = SIZE_LARGE
	flags_equip_slot = null
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null
	spray_size = 5
	volume = 500
	flags_atom = FPRINT //not an opencontainer
	flags_item = NOBLUDGEON | ITEM_ABSTRACT  // don't put in storage


/obj/item/reagent_container/spray/mister/Initialize()
	. = ..()
	var/obj/item/reagent_container/glass/watertank/W
	W = loc
	if(!istype(W))
		return

/obj/item/reagent_container/spray/mister/examine(mob/user)
	..()
	var/obj/item/reagent_container/glass/watertank/W = user.back
	if(!istype(W))
		return
	to_chat(user, "It is linked to \the [W]")

/obj/item/reagent_container/spray/mister/afterattack(atom/A, mob/user, proximity)
	//this is what you get for using afterattack() TODO: make is so this is only called if attackby() returns 0 or something
	var/obj/item/reagent_container/glass/watertank/W = user.back
	if(!istype(W))
		return

	if(isstorage(A) || istype(A, /obj/structure/surface/table) || istype(A, /obj/structure/surface/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/reagent_container) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/structure/ladder) || istype(A, /obj/screen))
		return

	if(A == user) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it
		return

	if(W.reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, SPAN_NOTICE("\The [W] is empty!"))
		return

	if(safety)
		to_chat(user, SPAN_WARNING("The safety is on!"))
		return


	Spray_at(A, user)

	playsound(src.loc, 'sound/effects/spray2.ogg', 25, 1, 3)


/obj/item/reagent_container/spray/mister/Spray_at(atom/A, mob/user)
	var/obj/item/reagent_container/glass/watertank/W = user.back
	if(!istype(W))
		return
	var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	W.reagents.trans_to(D, amount_per_transfer_from_this, 1 / spray_size)
	D.color = mix_color_from_reagents(D.reagents.reagent_list)
	D.source_user = user
	D.move_towards(A, 3, spray_size)

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define METAL_LAUNCHER 1
#define METAL_FOAM 2

/obj/item/reagent_container/glass/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refrigerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, resin launcher and a smaller scale resin foamer."
	icon_state = "backpack_foamer"
	item_state = "backpack_foamer"
	volume = 500
	var/nozzle_mode = EXTINGUISHER

/obj/item/reagent_container/glass/watertank/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent("water", 200)

/obj/item/reagent_container/glass/watertank/atmos/make_noz()
	return new /obj/item/reagent_container/spray/mister/atmos(src)

/obj/item/reagent_container/glass/watertank/atmos/dropped(mob/user)
	..()
	icon_state = initial(icon_state)

/obj/item/reagent_container/spray/mister/atmos
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a firefighter's backpack tank."
	icon_state = "fnozzle"
	item_state = "fnozzle"
	w_class = SIZE_LARGE
	var/obj/item/reagent_container/glass/watertank/atmos/tank
	var/nozzle_mode = 0
	var/foamer_cost = 10
	var/launcher_cost = 100

/obj/item/reagent_container/spray/mister/atmos/Initialize(mapload)
	. = ..()
	tank = loc
	nozzle_mode = METAL_LAUNCHER

/obj/item/reagent_container/spray/mister/atmos/Destroy()
	return ..()

/obj/item/reagent_container/spray/mister/atmos/attack_self(mob/user)
	..()
	var/obj/item/reagent_container/glass/watertank/atmos/tank = user.back
	if(!istype(tank))
		return ..()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			tank.nozzle_mode = METAL_LAUNCHER
			nozzle_mode = METAL_LAUNCHER
			to_chat(user, SPAN_NOTICE("Swapped to metal foam launcher."))
			return
		if(METAL_LAUNCHER)
			nozzle_mode = METAL_FOAM
			tank.nozzle_mode = METAL_FOAM
			to_chat(user, SPAN_NOTICE("Swapped to metal foamer."))
			return
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			tank.nozzle_mode = EXTINGUISHER
			to_chat(user, SPAN_NOTICE("Swapped to water extinguisher."))
			return
	return

/obj/item/reagent_container/spray/mister/atmos/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		//put extinguisher shooting code here
		return
	var/Adj = user.Adjacent(target)
	if(nozzle_mode == METAL_LAUNCHER)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = tank.reagents
		if(R.total_volume < launcher_cost)
			to_chat(user, SPAN_WARNING("You need at least 100 units of water to use the metal foam launcher!"))
			return
		R.remove_reagent("water", launcher_cost)
		var/obj/effect/resin_container/A = new (get_turf(src))
		playsound(src,'sound/items/syringeproj.ogg',40,TRUE)
		for(var/i in 1 to 5)
			step_towards(A, target)
			sleep(2)
		A.Smoke()
		return
	if(nozzle_mode == METAL_FOAM)
		if(!Adj|| !isturf(target))
			return
		for(var/S in target)
			if(istype(S, /obj/effect/particle_effect/foam) || istype(S, /obj/structure/foamedmetal))
				to_chat(user, SPAN_WARNING("There's already metal foam here!"))
				return
		var/datum/reagents/R = tank.reagents
		if(R.total_volume < foamer_cost)
			to_chat(user, SPAN_WARNING("You need at least 10 units of water to use the metal foamer!"))
			return
		else
			var/datum/effect_system/foam_spread/S = new /datum/effect_system/foam_spread(get_turf(target))
			S.set_up(0, target, null, 2)
			S.start()
			R.remove_reagent("water", foamer_cost)
			return


/obj/effect/resin_container
	name = "resin container"
	desc = "A compacted ball of expansive resin, used to repair the atmosphere in a room, or seal off breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "foam_ball"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/effect/resin_container/proc/Smoke()
	var/datum/effect_system/foam_spread/S = new /datum/effect_system/foam_spread(get_turf(loc))
//	var/datum/effect_system/foam_spread/S = new()
//	var/obj/effect/particle_effect/foam/metal/S = new /obj/effect/particle_effect/foam/metal(get_turf(loc))
	S.set_up(16, loc, null, 2)
	S.start()
	playsound(src,'sound/effects/bamf.ogg',100,TRUE)
	qdel(src)

#undef EXTINGUISHER
#undef METAL_LAUNCHER
#undef METAL_FOAM
