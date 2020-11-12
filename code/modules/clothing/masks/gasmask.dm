
/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon_state = "gas_alt"
	flags_inventory = COVERMOUTH | COVEREYES | ALLOWINTERNALS | BLOCKGASEFFECT | ALLOWREBREATH | ALLOWCPR
	flags_inv_hide = HIDEEARS|HIDEFACE|HIDELOWHAIR
	flags_cold_protection = BODY_FLAG_HEAD
	flags_equip_slot = SLOT_FACE|SLOT_WAIST
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	w_class = SIZE_SMALL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_HIGH //because why not
	armor_rad = CLOTHING_ARMOR_LOW
	armor_internaldamage = CLOTHING_ARMOR_NONE
	siemens_coefficient = 0.9
	var/gas_filter_strength = 1			//For gas mask filters
	var/vision_impair = VISION_IMPAIR_NONE //Changed system to support more than 2 versions of impairment
	var/list/filtered_gases = list("phoron", "sleeping_agent", "carbon_dioxide")

/obj/item/clothing/mask/gas/PMC
	name = "\improper M8 pattern armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter."
	item_state = "helmet"
	icon_state = "pmc_mask"
	anti_hug = 3
	vision_impair = VISION_IMPAIR_NONE
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_HIGH
	armor_rad = CLOTHING_ARMOR_LOW
	armor_internaldamage = CLOTHING_ARMOR_NONE
	flags_inventory = COVERMOUTH|ALLOWINTERNALS|BLOCKGASEFFECT|ALLOWREBREATH
	flags_inv_hide = HIDEEARS|HIDEFACE|HIDEALLHAIR
	flags_equip_slot = SLOT_FACE

/obj/item/clothing/mask/gas/PMC/upp
	name = "\improper UPP armored commando balaclava"
	icon_state = "upp_mask"

/obj/item/clothing/mask/gas/PMC/leader
	name = "\improper M8 pattern armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_mask"

/obj/item/clothing/mask/gas/bear
	name = "tactical balaclava"
	desc = "A superior balaclava worn by the Iron Bears."
	icon_state = "bear_mask"
	anti_hug = 2




//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out phoron but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor_melee = CLOTHING_ARMOR_NONE
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_NONE
	armor_rad = CLOTHING_ARMOR_NONE
	armor_internaldamage = CLOTHING_ARMOR_NONE
	flags_armor_protection = BODY_FLAG_HEAD|BODY_FLAG_FACE

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	flags_armor_protection = BODY_FLAG_FACE|BODY_FLAG_EYES

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	siemens_coefficient = 0.2
	vision_impair = VISION_IMPAIR_NONE

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	vision_impair = VISION_IMPAIR_NONE

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	vision_impair = VISION_IMPAIR_NONE

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	flags_armor_protection = BODY_FLAG_HEAD|BODY_FLAG_FACE|BODY_FLAG_EYES
	vision_impair = VISION_IMPAIR_NONE

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/fake_mustache
	name = "fake mustache"
	desc = "It is almost perfect."
	icon_state = "souto_man"
	vision_impair = VISION_IMPAIR_NONE
	unacidable = TRUE
	flags_item = NODROP|DELONDROP
	flags_inventory = CANTSTRIP|COVEREYES|COVERMOUTH|ALLOWINTERNALS|ALLOWREBREATH|BLOCKGASEFFECT|ALLOWCPR|BLOCKSHARPOBJ

/obj/item/clothing/mask/gas/anesthetic
	name = "anesthetic mask"
	desc = "A sterile mask provided with detachable anesthetic gas tanks, useful for performing surgery in unfavourable conditions. Hurry, however, as it will automatically remove itself after one minute to prevent malpractice!"
	icon_state = "anesthetic"
	item_state = "anesthetic"
	time_to_equip = 2 SECONDS
	time_to_unequip = 2 SECONDS
	var/obj/item/tank/anesthetic/internal_tank
	var/internals_on = TRUE
	var/balddoc_safety_timer

/obj/item/clothing/mask/gas/anesthetic/New(loc)
	..()
	internal_tank = new

/obj/item/clothing/mask/gas/anesthetic/Destroy()
	qdel(internal_tank)
	var/mob/living/carbon/user = loc
	if(istype(user))
		user.internal = null
	internal_tank = null
	deltimer(balddoc_safety_timer)
	. = ..()
	

/obj/item/clothing/mask/gas/anesthetic/attack_self(mob/user)
	internals_on = !internals_on
	to_chat(user, SPAN_NOTICE("You toggle the anesthetic mask [internals_on? "on":"off"]"))
	update_anesthetic()

/obj/item/clothing/mask/gas/anesthetic/equipped(mob/user, slot)
	if(slot == WEAR_FACE)
		update_anesthetic()
	return ..()

/obj/item/clothing/mask/gas/anesthetic/dropped()
	update_anesthetic()
	return ..()

/obj/item/clothing/mask/gas/anesthetic/verb/toggle_internal_tank()
	set name = "Toggle Internal Tank"
	set category = "Object"

	if(usr.stat != 0 || !ishuman(usr))
		return
	internals_on = !internals_on
	to_chat(usr, SPAN_NOTICE("You toggle the anesthetic mask [internals_on? "on":"off"]"))
	update_anesthetic()

/obj/item/clothing/mask/gas/anesthetic/proc/update_anesthetic()
	if(balddoc_safety_timer)
		deltimer(balddoc_safety_timer)
	var/mob/living/carbon/human/user = loc
	if(!istype(user))
		return
	if(user.wear_mask != src)
		return

	if(internals_on)
		user.internal = internal_tank
		to_chat(user, SPAN_NOTICE("<i>You start to feel sleepy...</i>"))
		balddoc_safety_timer = addtimer(CALLBACK(src,.proc/baldness_countermeasure), MINUTES_1)
	else
		user.internal = null
		user.AdjustSleeping(5) //Wake them up a bit

/obj/item/clothing/mask/gas/anesthetic/proc/baldness_countermeasure()
	balddoc_safety_timer = 0
	playsound(loc, 'sound/machines/twobeep.ogg', 30, sound_range = 3)
	internals_on = FALSE
	update_anesthetic()