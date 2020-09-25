/obj/item/organ
	name = "organ"
	desc = "It looks like it probably just plopped out."
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "appendix"

	health = 100                              // Process() ticks before death.

	var/fresh = 3                             // Squirts of blood left in it.
	var/dead_icon                             // Icon used when the organ dies.
	var/robotic                               // Is the limb prosthetic?


/obj/item/organ/attack_self(mob/user as mob)

	// Convert it to an edible form, yum yum.
	if(!robotic && user.a_intent == INTENT_HELP && user.zone_selected == "mouth")
		bitten(user)
		return

/obj/item/organ/Initialize(mapload, organ_datum)
	. = ..()
	create_reagents(5)
	if(!robotic)
		START_PROCESSING(SSobj, src)


/obj/item/organ/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/organ/process()

	if(robotic)
		STOP_PROCESSING(SSobj, src)
		return

	// Don't process if we're in a freezer, an MMI or a stasis bag. //TODO: ambient temperature?
	if(istype(loc,/obj/item/device/mmi) || istype(loc,/obj/item/bodybag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer))
		return

	if(fresh && prob(40))
		fresh--
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
		if(B)
			var/turf/TU = get_turf(src)
			TU.add_blood(B.color)
		//blood_splatter(src,B,1)

	health -= rand(0,1)
	if(health <= 0)
		die()

/obj/item/organ/proc/die()
	name = "dead [initial(name)]"
	if(dead_icon) icon_state = dead_icon
	health = 0
	STOP_PROCESSING(SSobj, src)
	//TODO: Grey out the icon state.
	//TODO: Inject an organ with peridaxon to make it alive again.


// Brain is defined in brain_item.dm.
/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	fresh = 6 // Juicy.
	dead_icon = "heart-off"

/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL

/obj/item/organ/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL

/obj/item/organ/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"

//These are here so they can be printed out via the fabricator.
/obj/item/organ/heart/prosthetic
	name = "circulatory pump"
	icon_state = "heart-prosthetic"
	robotic = ORGAN_ROBOT

/obj/item/organ/lungs/prosthetic
	robotic = ORGAN_ROBOT
	name = "gas exchange system"
	icon_state = "lungs-prosthetic"

/obj/item/organ/kidneys/prosthetic
	robotic = ORGAN_ROBOT
	name = "prosthetic kidneys"
	icon_state = "kidneys-prosthetic"


/obj/item/organ/eyes/prosthetic
	robotic = ORGAN_ROBOT
	name = "visual prosthesis"
	icon_state = "eyes-prosthetic"

/obj/item/organ/liver/prosthetic
	robotic = ORGAN_ROBOT
	name = "toxin filter"
	icon_state = "liver-prosthetic"
/obj/item/organ/brain/prosthetic
	robotic = ORGAN_ROBOT
	name = "cyberbrain"
	icon_state = "brain-prosthetic"

/obj/item/organ/proc/bitten(mob/user)

	if(robotic)
		return

	to_chat(user, SPAN_NOTICE(" You take an experimental bite out of \the [src]."))
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
	if(B)
		var/turf/TU = get_turf(src)
		TU.add_blood(B.color)


	user.temp_drop_inv_item(src)
	var/obj/item/reagent_container/food/snacks/organ/O = new(get_turf(src))
	O.name = name
	O.icon_state = dead_icon ? dead_icon : icon_state

	// Pass over the blood.
	reagents.trans_to(O, reagents.total_volume)

	if(fingerprintshidden) O.fingerprintshidden = fingerprintshidden.Copy()
	if(fingerprintslast) O.fingerprintslast = fingerprintslast

	user.put_in_active_hand(O)
	qdel(src)
