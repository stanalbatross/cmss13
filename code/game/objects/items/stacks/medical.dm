/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items/items.dmi'
	amount = 10
	max_amount = 10
	w_class = SIZE_SMALL
	throw_speed = SPEED_VERY_FAST
	throw_range = 20
	var/onlimb_health = 10
	var/brute_autoheal //damage healed per life tick
	var/burn_autoheal
	var/integrity_autoheal //Only heals integrity if it's below level 1 
	var/limb_integrity_levels_neutralized = NO_FLAGS
	var/stops_bleeding = TRUE
	var/destroy_on_removal = TRUE

	var/application_sound = 'sound/handling/bandage.ogg'
	var/required_skill = SKILL_MEDICAL_MEDIC
	var/low_skill_delay = 2 SECONDS
	var/regular_delay = 0
	var/heals_prosthesis = FALSE
	//onmob icon
	var/icon/cached_limb_icon
	var/icon_state_prefix

/obj/item/stack/medical/Destroy()
	if(istype(loc, /obj/limb))
		var/obj/limb/L = loc
		L.remove_medical_item(src)
	. = ..()


/obj/item/stack/medical/proc/take_onlimb_damage(brute, burn)
	onlimb_health = max(0, onlimb_health - brute - burn)
	if(!onlimb_health)
		return FALSE
	return TRUE

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!istype(M))
		to_chat(user, SPAN_DANGER("\The [src] cannot be applied to [M]!"))
		return 1

	if(!ishuman(user) && !isrobot(user))
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return 1

	var/mob/living/carbon/human/H = M
	var/obj/limb/affecting = H.get_limb(user.zone_selected)

	if(!affecting)
		to_chat(user, SPAN_WARNING("[H] has no [parse_zone(user.zone_selected)]!"))
		return 1
	if(heals_prosthesis)
		if(!(affecting.status == LIMB_ROBOTIC))
			to_chat(user, SPAN_WARNING("This isn't useful at all on an organic limb."))
			return 1
	else
		if(affecting.status == LIMB_ROBOTIC)
			to_chat(user, SPAN_WARNING("This isn't useful at all on a robotic limb."))
			return 1

	if(affecting.apply_medical_item(src, user))
		return TRUE

/*

	da items

*/

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "medical gauze"
	desc = "Some sterile gauze to wrap around bloody stumps and lacerations."
	icon_state = "brutepack"
	brute_autoheal = 0.2
	stack_id = "bruise pack"


/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat burns, infected wounds, and relieve itching in unusual places."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	burn_autoheal = 0.2
	integrity_autoheal = 1
	stack_id = "ointment"
	application_sound = 'sound/handling/ointment_spreading.ogg'


/obj/item/stack/medical/advanced/bruise_pack
	name = "restoration patches"
	singular_name = "restoration patch"
	desc = "A high-tech patch containing microscopic needles and contracting microfibers that promotes the accelerated healing of wounds, such as cuts and punctures"
	icon_state = "traumakit"
	brute_autoheal = 0.6
	stack_id = "advanced bruise pack"
	low_skill_delay = 3

/obj/item/stack/medical/advanced/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "shandp"
	stack_id = "Hand leaf"

/obj/item/stack/medical/advanced/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petal"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "mtearp"
	stack_id = "Tear petals"

/obj/item/stack/medical/advanced/ointment
	name = "rejuvenation patches"
	singular_name = "rejuvenation patch"
	desc = "A high-tech patch containing microscopic needles and contracting microfibers that relaxes muscles and stimulates cell growth around the application area, making it useful for healing burns and trauma"
	icon_state = "burnkit"
	burn_autoheal = 0.8
	integrity_autoheal = 3
	stack_id = "advanced burn kit"
	low_skill_delay = 3

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "A collection of different splints and securing gauze. What, did you think we only broke legs out here?"
	icon_state = "splint"
	amount = 5
	max_amount = 5
	stack_id = "splint"
	limb_integrity_levels_neutralized = LIMB_INTEGRITY_EFFECT_CONCERNING
	application_sound = 'sound/handling/splint1.ogg'
	stops_bleeding = FALSE

	low_skill_delay = 7 SECONDS
	regular_delay = 3 SECONDS


/obj/item/stack/medical/nanopaste
	name = "nanopaste"
	singular_name = "nanopaste"
	desc = "A greyish paste used to repair damaged prosthetic and synthetic limbs"
	icon_state = "tube"

	amount = 10
	max_amount = 10
	brute_autoheal = 0.8
	burn_autoheal = 0.8
	heals_prosthesis = TRUE
	w_class = SIZE_SMALL
	stack_id = "nanopaste"
	application_sound = 'sound/handling/ointment_spreading.ogg'


