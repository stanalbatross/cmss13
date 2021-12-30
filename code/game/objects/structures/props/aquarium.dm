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

/obj/structure/aquarium/proc/spawn_dead()
	new /obj/structure/aquarium/dead(loc)
	playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
	Destroy()

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
	to_chat(user, SPAN_NOTICE("You lean in closer to \the [src], looking at the cute little fishes..."))
	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY))
		to_chat(user, SPAN_NOTICE("You step away from \the [src], admiring the view."))
		return
	to_chat(user, SPAN_WARNING("You monster..."))
	spawn_dead()
	return

/obj/structure/aquarium/attack_robot(mob/user)
	to_chat(user, SPAN_NOTICE("You lean in closer to \the [src], looking at the cute little fishes..."))
	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY))
		to_chat(user, SPAN_NOTICE("You step away from \the [src], admiring the view."))
	to_chat(user, SPAN_WARNING("You monster..."))
	spawn_dead()
	return

/obj/structure/aquarium/attackby(obj/item/W, mob/user)
	if(!HAS_TRAIT(W, TRAIT_TOOL_WRENCH))
		spawn_dead()
		Destroy()
		return
	toggle_anchored(W, user)

/obj/structure/aquarium/dead
	desc = "A wonderful tank full of... it could have been full of wonderful fishes..."
	icon_state = "aquarium_dead"
	wrenchable = FALSE
	anchored = FALSE

/obj/structure/aquarium/dead/Destroy()
	playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
	return ..()

/obj/structure/aquarium/dead/attack_robot(mob/user)
	return

/obj/structure/aquarium/dead/attack_hand(mob/user)
	return

/obj/structure/aquarium/dead/bullet_act(obj/item/projectile/P)
	Destroy()
	return

/obj/structure/aquarium/dead/ex_act(severity, direction)
	Destroy()
	return

/obj/structure/aquarium/dead/attack_animal(mob/living/user)
	Destroy()
	return

/obj/structure/aquarium/dead/attack_alien(mob/living/carbon/Xenomorph/M)
	Destroy()
	return

/obj/structure/aquarium/dead/attackby(obj/item/W, mob/user)
	Destroy()
	return
