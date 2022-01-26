#define LOW_MODE_RECH		4 SECONDS
#define HALF_MODE_RECH		8 SECONDS
#define FULL_MODE_RECH		16 SECONDS

#define LOW_MODE_CHARGE		60
#define HALF_MODE_CHARGE	120
#define FULL_MODE_CHARGE	180

#define LOW_MODE_DMGHEAL	5
#define HALF_MODE_DMGHEAL	20
#define FULL_MODE_DMGHEAL	80

#define LOW_MODE_HEARTD		5
#define HALF_MODE_HEARTD	10
#define FULL_MODE_HEARTD	25

#define LOW_MODE_DEF		"Low Power Mode"
#define HALF_MODE_DEF		"Half Power Mode"
#define FULL_MODE_DEF		"Full Power Mode"

#define PROB_DMGHEART		10 //%

/obj/item/device/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to restore fibrillating patients. Can optionally bring people back from the dead."
	icon_state = "defib"
	item_state = "defib"
	flags_atom = FPRINT|CONDUCT
	flags_item = NOBLUDGEON
	flags_equip_slot = SLOT_WAIST
	force = 5
	throwforce = 5
	w_class = SIZE_MEDIUM

	var/icon_state_for_paddles

	var/blocked_by_suit = TRUE
	var/heart_damage_to_deal = FULL_MODE_HEARTD
	var/damage_heal_threshold = FULL_MODE_DMGHEAL //This is the maximum non-oxy damage the defibrillator will heal to get a patient above -100, in all categories
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	var/charge_cost = FULL_MODE_CHARGE //How much energy is used.
	var/obj/item/cell/dcell = null
	var/datum/effect_system/spark_spread/sparks = new
	var/defib_cooldown = 0 //Cooldown for defib

	var/paddles = /obj/item/device/paddles
	var/obj/item/device/paddles/paddles_type

	var/atom/tether_holder

	var/heart_damage_mult = 1.0 //Don't set on 0, bad move.
	var/additional_charge_cost = 1.0 // 0.5 cost lower
	var/boost_recharge = 1.0 // 0.5 faster
	var/healing_mult = 1.0 // 1.5 heal more

	var/skill_req = SKILL_MEDICAL_MEDIC

	var/range = 4
	var/list/difib_mode_choices = list(LOW_MODE_DEF, HALF_MODE_DEF, FULL_MODE_DEF)
	var/defib_mode = FULL_MODE_DEF
	var/defib_recharge = FULL_MODE_RECH //Recharge defib

/mob/living/carbon/human/proc/check_tod()
	if(!undefibbable && world.time <= timeofdeath + revive_grace_period)
		return TRUE
	return FALSE

/obj/item/device/defibrillator/Initialize(mapload, ...)
	. = ..()

	icon_state_for_paddles = initial(icon_state)

	paddles_type = new paddles(src)

	sparks.set_up(5, 0, src)
	sparks.attach(src)
	dcell = new/obj/item/cell(src)
	RegisterSignal(paddles_type, COMSIG_PARENT_PREQDELETED, .proc/override_delete)
	update_icon()

/obj/item/device/defibrillator/update_icon()
	icon_state = initial(icon_state)

	update_overlays()

/obj/item/device/defibrillator/proc/update_overlays()
	if(overlays) overlays.Cut()

	if(paddles_type.loc == src)
		overlays += image(icon, "+paddles_[icon_state_for_paddles]")

	if(dcell && dcell.charge)
		switch(round(dcell.charge * 100 / dcell.maxcharge))
			if(67 to INFINITY)
				overlays += image(icon, "+full")
			if(34 to 66)
				overlays += image(icon, "+half")
			if(1 to 33)
				overlays += image(icon, "+low")
	else
		overlays += image(icon, "+empty")

/obj/item/device/defibrillator/examine(mob/user)
	..()
	var/maxuses = 0
	var/currentuses = 0
	maxuses = round(dcell.maxcharge / charge_cost)
	currentuses = round(dcell.charge / charge_cost)

	to_chat(user, SPAN_INFO("It has [currentuses] out of [maxuses] uses left in its internal battery. Currently [name] in [defib_mode] mode, recharge take [defib_recharge] seconds."))

/obj/item/device/defibrillator/clicked(mob/user, list/mods)
	if(!ishuman(usr))
		return
	if(mods["alt"])
		change_defib_mode(user)
		return 1
	return ..()

/obj/item/device/defibrillator/proc/change_defib_mode(mob/user)
	if(!skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		to_chat(user, SPAN_WARNING("You don't seem to know how to use [src]..."))
		return

	if(paddles_type.charged)
		to_chat(user, SPAN_WARNING("Paddles already charged, you don't can change mode."))
		return

	var/difib_modes_to_choise = difib_mode_choices - defib_mode

	defib_mode = tgui_input_list(usr, "Select Defib Mode", "Defib Mode Selecting", difib_modes_to_choise)

	if(!defib_mode)
		return

	switch(defib_mode)
		if(FULL_MODE_DEF)
			heart_damage_to_deal = FULL_MODE_HEARTD * heart_damage_mult
			damage_heal_threshold = FULL_MODE_DMGHEAL * healing_mult
			charge_cost = FULL_MODE_CHARGE * additional_charge_cost
			defib_recharge = FULL_MODE_RECH * boost_recharge
		if(HALF_MODE_DEF)
			heart_damage_to_deal = HALF_MODE_HEARTD * heart_damage_mult
			damage_heal_threshold = HALF_MODE_DMGHEAL * healing_mult
			charge_cost = HALF_MODE_CHARGE * additional_charge_cost
			defib_recharge = HALF_MODE_RECH * boost_recharge
		if(HALF_MODE_DEF)
			heart_damage_to_deal = LOW_MODE_HEARTD * heart_damage_mult
			damage_heal_threshold = LOW_MODE_DMGHEAL * healing_mult
			charge_cost = LOW_MODE_CHARGE * additional_charge_cost
			defib_recharge = LOW_MODE_RECH * boost_recharge

	defib_cooldown = world.time + 20
	user.visible_message(SPAN_NOTICE("[user] turns [src] in [defib_mode]."),
	SPAN_NOTICE("You change [src] mode, now it in [defib_mode] mode, recharge take [defib_recharge/10] seconds."))
	if(defib_mode == FULL_MODE_DEF)
		to_chat(user, SPAN_WARNING("This is mode only for emergency! You can deal alot damage to patient heart!"))

	add_fingerprint(user)

/obj/item/device/defibrillator/attack_self(mob/living/carbon/human/user)
	..()

/obj/item/device/defibrillator/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user))
		return

	if(user.belt == src && paddles_type && paddles_type.loc == src)
		paddles_type.attack_hand(user)
		to_chat(user, SPAN_PURPLE("[icon2html(src, user)] Picked up a paddles."))
		playsound(get_turf(src), "sparks", 25, 1, 4)

		user.put_in_active_hand(paddles_type)
		paddles_type.update_icon()
		update_icon()
		add_fingerprint(usr)
	else
		. = ..()

/obj/item/device/defibrillator/MouseDrop(obj/over_object as obj)
	if(!CAN_PICKUP(usr, src))
		return ..()
	if(!istype(over_object, /obj/screen))
		return ..()
	if(loc != usr)
		return ..()

	switch(over_object.name)
		if("r_hand")
			if(usr.drop_inv_item_on_ground(src))
				usr.put_in_r_hand(src)
		if("l_hand")
			if(usr.drop_inv_item_on_ground(src))
				usr.put_in_l_hand(src)
	add_fingerprint(usr)

/obj/item/device/defibrillator/attackby(obj/item/W, mob/user)
	if(W == paddles_type)
		paddles_type.unwield(user)
		recall_paddles()
	else
		. = ..()

/obj/item/device/defibrillator/proc/set_tether_holder(var/atom/A)
	tether_holder = A

	if(paddles_type)
		paddles_type.reset_tether()

/obj/item/device/defibrillator/forceMove(atom/dest)
	. = ..()
	if(isturf(dest))
		set_tether_holder(src)
	else
		set_tether_holder(loc)

/obj/item/device/defibrillator/proc/override_delete()
	SIGNAL_HANDLER
	paddles_type.unwield()
	recall_paddles()
	return COMPONENT_ABORT_QDEL

/obj/item/device/defibrillator/proc/recall_paddles()
	if(ismob(paddles_type.loc))
		var/mob/M = paddles_type.loc
		M.drop_held_item(paddles_type)
		playsound(get_turf(src), "sparks", 25, 1, 4)
		paddles_type.charged = FALSE
		paddles_type.update_icon()

	paddles_type.forceMove(src)

	update_icon()

/obj/item/device/defibrillator/on_enter_storage(obj/item/storage/S)
	. = ..()
	if(paddles_type.loc != src)
		paddles_type.unwield()
		recall_paddles()

/obj/item/device/defibrillator/Destroy()
	if(paddles_type)
		if(paddles_type.loc == src)
			UnregisterSignal(paddles_type, COMSIG_PARENT_PREQDELETED)
			qdel(paddles_type)
		else
			paddles_type.attached_to = null
			paddles_type = null

	return ..()

/mob/living/carbon/human/proc/get_ghost()
	if(client)
		return FALSE

	for(var/mob/dead/observer/G in GLOB.observer_list)
		if(G.mind && G.mind.original == src)
			var/mob/dead/observer/ghost = G
			if(ghost && ghost.client && ghost.can_reenter_corpse)
				return ghost

/mob/living/carbon/human/proc/is_revivable()
	if(isnull(internal_organs_by_name) || isnull(internal_organs_by_name["heart"]))
		return FALSE
	var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]
	var/obj/limb/head = get_limb("head")

	if(chestburst || !head || head.status & LIMB_DESTROYED || !heart || heart.is_broken() || !has_brain() || status_flags & PERMANENTLY_DEAD)
		return FALSE
	return TRUE

/obj/item/device/defibrillator/proc/check_revive(var/mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(!ishuman(H) || isYautja(H))
		to_chat(user, SPAN_WARNING("You can't defibrilate [H]. You don't even know where to put the paddles!"))
		return
	if(dcell.charge <= charge_cost)
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src]'s battery is too low! It needs to recharge."))
		return
	if(H.stat != DEAD)
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Vital signs detected. Aborting."))
		return

	if(!H.is_revivable())
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Patient's general condition does not allow reviving."))
		return

	if(blocked_by_suit && H.wear_suit && (istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/storage/marine)) && prob(95))
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Paddles registering >100,000 ohms, Possible cause: Suit or Armor interfering."))
		return

	if((!H.check_tod() && !isSynth(H))) //synthetic species have no expiration date
		user.visible_message(SPAN_WARNING("[icon2html(src, viewers(src))] \The [src] buzzes: Patient is braindead."))
		return

	return TRUE

/obj/item/device/defibrillator/compact_adv
	name = "advanced compact defibrillator"
	desc = "An advanced compact defibrillator that trades capacity for strong immediate power. Ignores armor and heals strongly and quickly, at the cost of very low charge."
	icon = 'icons/obj/items/experimental_tools.dmi'
	icon_state = "compact_defib"
	item_state = "defib"
	w_class = SIZE_MEDIUM
	blocked_by_suit = FALSE
	heart_damage_mult = 0.4
	additional_charge_cost = 2.0
	boost_recharge = 0.8
	healing_mult = 1.75
	skill_req = SKILL_MEDICAL_TRAINED

/obj/item/device/defibrillator/compact
	name = "compact defibrillator"
	desc ="This particular defibrillator has halved charge capacity compared to the standard emergency defibrillator, but can fit in your pocket."
	icon = 'icons/obj/items/experimental_tools.dmi'
	icon_state = "compact_defib"
	item_state = "defib"
	w_class = SIZE_SMALL
	additional_charge_cost = 1.5
