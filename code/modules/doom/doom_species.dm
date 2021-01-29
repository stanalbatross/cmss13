
/datum/species/proc/glory_kill(mob/living/user, mob/living/carbon/staggered_mob)
	staggered_mob.visible_message(SPAN_HIGHDANGER("[user] slams the Doomblade into [staggered_mob.name]'s mouth and quickly slides it out!"))
	var/heal_amount = 40
	var/ammo_refill = 1
	return list(heal_amount, ammo_refill)

//datum/species/human

/datum/species/synthetic/glory_kill(mob/living/user, mob/living/carbon/staggered_mob)
	staggered_mob.visible_message(SPAN_HIGHDANGER("[user] slices his Doomblade out of [staggered_mob.name] and cleanly amputates its head!"))
	var/heal_amount = 120
	var/ammo_refill = 2
	var/obj/limb/O = staggered_mob.get_limb(check_zone("head"))
	O.droplimb(TRUE, FALSE, "doom")
	return list(heal_amount, ammo_refill)

/datum/species/yautja/glory_kill(mob/living/user, mob/living/carbon/staggered_mob)
	staggered_mob.visible_message(SPAN_HIGHDANGER("[staggered_mob.name] roars, and [user] stabs him twice in the chest, then slams the Doomblade into [staggered_mob.name]'s forehead!"))
	staggered_mob.emote("roar")
	var/heal_amount = 200
	var/ammo_refill = 3
	return list(heal_amount, ammo_refill)

/datum/species/zombie/glory_kill(mob/living/user, mob/living/carbon/staggered_mob)
	staggered_mob.visible_message(SPAN_HIGHDANGER("[user] slams his fist into [staggered_mob.name]'s head, smashing it into its torso!"))
	var/heal_amount = 40
	var/ammo_refill = 1
	return list(heal_amount, ammo_refill)
