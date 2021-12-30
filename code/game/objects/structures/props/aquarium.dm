/obj/structure/aquarium
	name = "aquarium"
	desc = "A wonderful tank full of wonderful fishes."
	icon = 'icons/obj/structures/aquarium.dmi'
	icon_state = "aquarium"
	// even though it is set in parent, just letting it be known
	anchored = TRUE
	// let us move the aquarium around
	wrenchable = TRUE
	// you probably shouldnt' be allowed to walk through this
	density = TRUE
	// 3 hits and you're dead
	health = 3

/obj/structure/aquarium/examine(mob/user)
	. = ..()
	switch(health)
		if(3)
			to_chat(user, SPAN_NOTICE("\The [src] is in pristine condition!"))
		if(2)
			to_chat(user, SPAN_WARNING("\The [src] has been slightly damaged."))
		if(1)
			to_chat(user, SPAN_WARNING("\The [src] is falling apart..."))

/obj/structure/aquarium/proc/spawn_dead()
	new /obj/structure/aquarium/dead(loc)
	playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
	Destroy()

/obj/structure/aquarium/proc/try_interaction(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	to_chat(living_user, SPAN_NOTICE("You start to lean on the glass of \the [src], looking at the cute little fishes..."))
	if(!do_after(living_user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY))
		to_chat(living_user, SPAN_NOTICE("You step away from \the [src], admiring the view."))
		return
	if(living_user.a_intent != INTENT_HARM)
		to_chat(living_user, SPAN_NOTICE("You think of an idyllic past, soothing waters constantly ebbing and flowing..."))
		return
	to_chat(living_user, SPAN_WARNING("You monster..."))
	spawn_dead()
	return

/obj/structure/aquarium/bullet_act(obj/item/projectile/P)
	spawn_dead()
	return

/obj/structure/aquarium/ex_act(severity, direction)
	Destroy()
	return

/obj/structure/aquarium/attack_alien(mob/living/carbon/Xenomorph/M)
	spawn_dead()
	return

/obj/structure/aquarium/attack_animal(mob/living/user)
	spawn_dead()
	return

/obj/structure/aquarium/attack_hand(mob/user)
	try_interaction(user)

/obj/structure/aquarium/attack_robot(mob/user)
	try_interaction(user)

/obj/structure/aquarium/attackby(obj/item/W, mob/user)
	if(!HAS_TRAIT(W, TRAIT_TOOL_WRENCH))
		spawn_dead()
		return
	return ..()

/obj/structure/aquarium/dead
	desc = "A wonderful tank full of... it could have been full of wonderful fishes..."
	icon_state = "aquarium_dead"
	// at this point, its dead, sk allow moving it around
	wrenchable = FALSE
	anchored = FALSE

/obj/structure/aquarium/dead/proc/deal_damage()
	health--
	playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
	if(health <= 0)
		Destroy()
	return

/obj/structure/aquarium/dead/Destroy()
	playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)\
	new /obj/item/stack/sheet/wood(loc)
	return ..()

/obj/structure/aquarium/dead/attack_robot(mob/user)
	return

/obj/structure/aquarium/dead/attack_hand(mob/user)
	return

/obj/structure/aquarium/dead/bullet_act(obj/item/projectile/P)
	deal_damage()

/obj/structure/aquarium/dead/ex_act(severity, direction)
	Destroy()

/obj/structure/aquarium/dead/attack_animal(mob/living/user)
	deal_damage()

/obj/structure/aquarium/dead/attack_alien(mob/living/carbon/Xenomorph/M)
	deal_damage()

/obj/structure/aquarium/dead/attackby(obj/item/W, mob/user)
	deal_damage()
