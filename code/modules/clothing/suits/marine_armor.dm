#define DEBUG_ARMOR_PROTECTION 0

#if DEBUG_ARMOR_PROTECTION
/mob/living/carbon/human/verb/check_overall_protection()
	set name = "Get Armor Value"
	set category = "Debug"
	set desc = "Shows the armor value of the bullet category."

	var/armor = 0
	var/counter = 0
	for(var/X in H.limbs)
		var/obj/limb/E = X
		armor = getarmor_organ(E, ARMOR_BULLET)
		to_chat(src, SPAN_DEBUG("<b>[E.name]</b> is protected with <b>[armor]</b> armor against bullets."))
		counter += armor
	to_chat(src, SPAN_DEBUG("The overall armor score is: <b>[counter]</b>."))
#endif

//=======================================================================\\
//=======================================================================\\

#define ALPHA		1
#define BRAVO		2
#define CHARLIE		3
#define DELTA		4
#define ECHO		5
#define NOSQUAD 	6

var/list/armormarkings = list()
var/list/armormarkings_sql = list()
var/list/helmetmarkings = list()
var/list/helmetmarkings_sql = list()
var/list/squad_colors = list(rgb(230,25,25), rgb(255,195,45), rgb(200,100,200), rgb(65,72,200), rgb(103,214,146))
var/list/squad_colors_chat = list(rgb(230,125,125), rgb(255,230,80), rgb(255,150,255), rgb(130,140,255), rgb(103,214,146))

/proc/initialize_marine_armor()
	var/i
	for(i=1, i<6, i++)
		var/image/armor
		var/image/helmet
		armor = image('icons/mob/humans/onmob/suit_1.dmi',icon_state = "std-armor")
		armor.color = squad_colors[i]
		armormarkings += armor
		armor = image('icons/mob/humans/onmob/suit_1.dmi',icon_state = "sql-armor")
		armor.color = squad_colors[i]
		armormarkings_sql += armor

		helmet = image('icons/mob/humans/onmob/head_1.dmi',icon_state = "std-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings += helmet
		helmet = image('icons/mob/humans/onmob/head_1.dmi',icon_state = "sql-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings_sql += helmet




// MARINE STORAGE ARMOR

/obj/item/clothing/suit/storage/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/obj/items/clothing/cm_suits.dmi'
	icon_state = "1"
	item_state = "marine_armor" //Make unique states for Officer & Intel armors.
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/suit_1.dmi'
	)
	flags_atom = FPRINT|CONDUCT
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	min_cold_protection_temperature = ARMOR_min_cold_protection_temperature
	max_heat_protection_temperature = ARMOR_max_heat_protection_temperature
	blood_overlay_type = "armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	movement_compensation = SLOWDOWN_ARMOR_LIGHT
	storage_slots = 3
	siemens_coefficient = 0.7
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/storage/bible,
		/obj/item/attachable/bayonet,
		/obj/item/storage/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/storage/belt/gun/m4a3,
		/obj/item/storage/belt/gun/m44,
		/obj/item/storage/belt/gun/smartpistol,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman
	)

	var/brightness_on = 6 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/armor_overlays[]
	actions_types = list(/datum/action/item_action/toggle)
	var/flags_marine_armor = ARMOR_SQUAD_OVERLAY|ARMOR_LAMP_OVERLAY
	var/specialty = "M3 pattern marine" //Same thing here. Give them a specialty so that they show up correctly in vendors.
	w_class = SIZE_HUGE
	uniform_restricted = list(/obj/item/clothing/under/marine)
	sprite_sheets = list(SPECIES_MONKEY = 'icons/mob/humans/species/monkeys/onmob/suit_monkey_1.dmi')
	time_to_unequip = 20
	time_to_equip = 20
	equip_sounds = list('sound/handling/putting_on_armor1.ogg')

/obj/item/clothing/suit/storage/marine/New(loc)
	if(!(flags_atom & UNIQUE_ITEM_TYPE))
		name = "[specialty]"
		if(map_tag in MAPS_COLD_TEMP)
			name += " snow armor" //Leave marine out so that armors don't have to have "Marine" appended (see: admirals).
		else
			name += " armor"
	if(type == /obj/item/clothing/suit/storage/marine)
		var/armor_variation = rand(1,6)
		icon_state = "[armor_variation]"

	if(!(flags_atom & NO_SNOW_TYPE))
		select_gamemode_skin(type)
	..()
	armor_overlays = list("lamp") //Just one for now, can add more later.
	update_icon()
	pockets.max_w_class = SIZE_SMALL //Can contain small items AND rifle magazines.
	pockets.bypass_w_limit = list(
	/obj/item/ammo_magazine/rifle,
	/obj/item/ammo_magazine/smg,
	/obj/item/ammo_magazine/sniper,
	 )
	pockets.max_storage_space = 8

/obj/item/clothing/suit/storage/marine/update_icon(mob/user)
	var/image/I
	I = armor_overlays["lamp"]
	overlays -= I
	qdel(I)
	if(flags_marine_armor & ARMOR_LAMP_OVERLAY)
		if(flags_marine_armor & ARMOR_LAMP_ON)
			I = image('icons/obj/items/clothing/cm_suits.dmi', src, "lamp-on")
		else
			I = image('icons/obj/items/clothing/cm_suits.dmi', src, "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else armor_overlays["lamp"] = null
	if(user) user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/marine/pickup(mob/user)
	if(flags_marine_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(brightness_on)
		SetLuminosity(0)
	..()

/obj/item/clothing/suit/storage/marine/dropped(mob/user)
	if(loc != user)
		turn_off_light(user)
	..()


/obj/item/clothing/suit/storage/marine/proc/is_light_on()
	return flags_marine_armor & ARMOR_LAMP_ON

/obj/item/clothing/suit/storage/marine/proc/turn_off_light(mob/wearer)
	if(is_light_on())
		if(wearer)
			wearer.SetLuminosity(-brightness_on)
		SetLuminosity(brightness_on)
		toggle_armor_light() //turn the light off
		return 1
	return 0

/obj/item/clothing/suit/storage/marine/Destroy()
	if(ismob(src.loc))
		src.loc.SetLuminosity(-brightness_on)
	else
		SetLuminosity(0)
	return ..()

/obj/item/clothing/suit/storage/marine/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, SPAN_WARNING("You cannot turn the light on while in [user.loc].")) //To prevent some lighting anomalities.
		return

	if(flashlight_cooldown > world.time)
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src) return

	toggle_armor_light(user)
	return 1

/obj/item/clothing/suit/storage/marine/item_action_slot_check(mob/user, slot)
	if(!ishuman(user)) return FALSE
	if(slot != WEAR_JACKET) return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/marine/proc/toggle_armor_light(mob/user)
	flashlight_cooldown = world.time + 20 //2 seconds cooldown every time the light is toggled
	if(is_light_on()) //Turn it off.
		if(user) user.SetLuminosity(-brightness_on)
		else SetLuminosity(0)
		playsound(src,'sound/handling/click_2.ogg', 50, 1)
	else //Turn it on.
		if(user) user.SetLuminosity(brightness_on)
		else SetLuminosity(brightness_on)

	flags_marine_armor ^= ARMOR_LAMP_ON

	playsound(src,'sound/handling/light_on_1.ogg', 50, 1)
	update_icon(user)

	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()

/obj/item/clothing/suit/storage/marine/mob_can_equip(mob/living/carbon/human/M, slot, disable_warning = 0)
	. = ..()
	if (.)
		if(isSynth(M) && M.allow_gun_usage == FALSE)
			M.visible_message(SPAN_DANGER("Your programming prevents you from wearing this!"))
			return 0

/obj/item/clothing/suit/storage/marine/padded
	name = "M3 pattern padded marine armor"
	icon_state = "1"
	specialty = "M3 pattern padded marine"

/obj/item/clothing/suit/storage/marine/padless
	name = "M3 pattern padless marine armor"
	icon_state = "2"
	specialty = "M3 pattern padless marine"

/obj/item/clothing/suit/storage/marine/padless_lines
	name = "M3 pattern ridged marine armor"
	icon_state = "3"
	specialty = "M3 pattern ridged marine"

/obj/item/clothing/suit/storage/marine/carrier
	name = "M3 pattern carrier marine armor"
	icon_state = "4"
	specialty = "M3 pattern carrier marine"

/obj/item/clothing/suit/storage/marine/skull
	name = "M3 pattern skull marine armor"
	icon_state = "5"
	specialty = "M3 pattern skull marine"

/obj/item/clothing/suit/storage/marine/smooth
	name = "M3 pattern smooth marine armor"
	icon_state = "6"
	specialty = "M3 pattern smooth marine"

/obj/item/clothing/suit/storage/marine/intel
	icon_state = "io"
	name = "\improper XM4 pattern intelligence officer plate armor"
	desc = "A well tinkered and crafted hybrid of Smart-Gunner mesh and M3 pattern plates. Robust, yet nimble, with room for all your pouches."
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 4
	uniform_restricted = list(/obj/item/clothing/under/marine/officer, /obj/item/clothing/under/rank/ro_suit, /obj/item/clothing/under/marine/officer/intel,)
	specialty = "XM4 pattern intel"

/obj/item/clothing/suit/storage/marine/MP
	name = "\improper M2 pattern MP armor"
	desc = "A standard Colonial Marines M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMLOW
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_atom = NO_SNOW_TYPE
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/melee/baton,
		/obj/item/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/device/binoculars,
		/obj/item/attachable/bayonet,
		/obj/item/storage/sparepouch,
		/obj/item/device/hailer,
		/obj/item/storage/belt/gun,
		/obj/item/weapon/melee/claymore/mercsword/ceremonial,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman)
	uniform_restricted = list(/obj/item/clothing/under/marine/mp)
	specialty = "M2 pattern MP"
	item_state_slots = list(WEAR_JACKET = "mp")

/obj/item/clothing/suit/storage/marine/MP/warden
	icon_state = "warden"
	name = "\improper M3 pattern warden MP armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically distributed to Wardens. Useful for letting your men know who is in charge."
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMLOW
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/warden)
	specialty = "M3 pattern warden MP"
	item_state_slots = list(WEAR_JACKET = "warden")

/obj/item/clothing/suit/storage/marine/MP/WO
	icon_state = "warrant_officer"
	name = "\improper M3 pattern chief MP armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically distributed to Chief MPs. Useful for letting your men know who is in charge."
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMLOW
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/warrant)
	specialty = "M3 pattern chief MP"
	item_state_slots = list(WEAR_JACKET = "warrant_officer")

/obj/item/clothing/suit/storage/marine/MP/admiral
	icon_state = "admiral"
	name = "\improper M3 pattern admiral armor"
	desc = "A well-crafted suit of M3 Pattern Armor with a gold shine. It looks very expensive, but shockingly fairly easy to carry and wear."
	w_class = SIZE_MEDIUM
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMLOW
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/admiral)
	specialty = "M3 pattern admiral"
	item_state_slots = list(WEAR_JACKET = "admiral")

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "\improper M3 pattern officer armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"
	flags_atom = null
	uniform_restricted = list(/obj/item/clothing/under/marine/officer, /obj/item/clothing/under/rank/ro_suit)
	specialty = "M2 pattern officer"
	item_state_slots = list(WEAR_JACKET = "officer")

//Making a new object because we might want to edit armor values and such.
//Or give it its own sprite. It's more for the future.
/obj/item/clothing/suit/storage/marine/MP/CO
	icon_state = "co_officer"
	item_state = "co_officer"
	name = "\improper M3 pattern captain armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"
	uniform_restricted = list(/obj/item/clothing/under/marine/officer, /obj/item/clothing/under/rank/ro_suit)
	flags_atom = NO_SNOW_TYPE
	armor_bullet = CLOTHING_ARMOR_HIGH
	specialty = "M3 pattern captain"
	item_state_slots = list(WEAR_JACKET = "co_officer")
	


/obj/item/clothing/suit/storage/marine/smartgunner
	name = "M56 combat harness"
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories."
	icon_state = "8"
	item_state = "armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/explosive/mine,
					/obj/item/attachable/bayonet,
					/obj/item/weapon/gun/smartgun,
					/obj/item/storage/sparepouch,
					/obj/item/device/motiondetector,
					/obj/item/device/walkman)

/obj/item/clothing/suit/storage/marine/smartgunner/New(loc)
	. = ..()
	if(map_tag in MAPS_COLD_TEMP && name == "M56 combat harness")
		name = "M56 snow combat harness"
	else
		name = "M56 combat harness"
	//select_gamemode_skin(type)


/obj/item/clothing/suit/storage/marine/leader
	name = "\improper B12 pattern leader marine armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Designed in a lovely forest green. Use it to toggle the built-in flashlight."
	icon_state = "7"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	specialty = "B12 pattern leader marine"

/obj/item/clothing/suit/storage/marine/tanker
	name = "\improper M3 pattern tanker armor"
	desc = "A modified and refashioned suit of M3 Pattern armor designed to be worn by the loader of a USCM vehicle crew. While the suit is a bit more encumbering to wear with the crewman uniform, it offers the loader a degree of protection that would otherwise not be enjoyed."
	icon_state = "tanker"
	uniform_restricted = list(/obj/item/clothing/under/marine/officer/tanker)
	specialty = "M3 pattern tanker"
	storage_slots = 2

//===========================//PFC ARMOR CLASSES\\================================\\
//=================================================================================\\
/obj/item/clothing/suit/storage/marine/class //We need a separate type to handle the special icon states.
	name = "\improper M3 pattern classed armor"
	desc = "You shouldn't be seeing this."
	icon_state = "1" //This should be the default icon state.

	var/class = "H" //This variable should be what comes before the variation number (H6 -> H).

/obj/item/clothing/suit/storage/marine/class/New()
	if(!(flags_atom & UNIQUE_ITEM_TYPE))
		name = "[specialty]"
		if(map_tag in MAPS_COLD_TEMP)
			name += " snow armor" //Leave marine out so that armors don't have to have "Marine" appended (see: admirals).
		else
			name += " armor"
	if(istype(src, /obj/item/clothing/suit/storage/marine/class))
		var/armor_variation = rand(1,6)
		icon_state = "[class]" + "[armor_variation]"
	..()
	armor_overlays = list("lamp") //Just one for now, can add more later.
	update_icon()
	pockets.max_w_class = SIZE_SMALL //Can contain small items AND rifle magazines.
	pockets.bypass_w_limit = list(
	/obj/item/ammo_magazine/rifle,
	/obj/item/ammo_magazine/smg,
	/obj/item/ammo_magazine/sniper,
	 )
	pockets.max_storage_space = 8

/obj/item/clothing/suit/storage/marine/class/light
	name = "\improper M3-L pattern light armor"
	desc = "A lighter, cut down version of the standard M3 pattern armor. It sacrifices durability for more speed."
	specialty = "\improper M3-L pattern light"
	icon_state = "L1"
	class = "L"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_LOW
	storage_slots = 2
	movement_compensation = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/class/heavy
	name = "\improper M3-H pattern heavy armor"
	desc = "A heavier version of the standard M3 pattern armor, cladded with additional plates. It sacrifices speed for more durability."
	specialty = "\improper M3-H pattern heavy"
	icon_state = "H1"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	class = "H"
	slowdown = SLOWDOWN_ARMOR_LOWHEAVY
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	movement_compensation = SLOWDOWN_ARMOR_MEDIUM

//===========================//SPECIALIST\\================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/specialist
	name = "\improper B18 defensive armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with two tricord injectors in each arm guard."
	icon_state = "xarmor"
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_VERYHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	flags_inventory = BLOCK_KNOCKDOWN
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	slowdown = SLOWDOWN_ARMOR_HEAVY
	var/injections = 4
	unacidable = TRUE
	specialty = "B18 defensive"

/obj/item/clothing/suit/storage/marine/specialist/verb/inject()
	set name = "Create Injector"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.is_mob_restrained())
		return 0

	if(!injections)
		to_chat(usr, "Your armor is all out of injectors.")
		return 0

	if(usr.get_active_hand())
		to_chat(usr, "Your active hand must be empty.")
		return 0

	to_chat(usr, "You feel a faint hiss and an injector drops into your hand.")
	var/obj/item/reagent_container/hypospray/autoinjector/skillless/O = new(usr)
	usr.put_in_active_hand(O)
	injections--
	playsound(src,'sound/machines/click.ogg', 15, 1)
	return

/obj/item/clothing/suit/storage/marine/M3G
	name = "\improper M3-G4 grenadier armor"
	desc = "A custom set of M3 armor packed to the brim with padding, plating, and every form of ballistic protection under the sun. Used exclusively by USCM Grenadiers."
	icon_state = "grenadier"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_VERYHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	flags_inventory = BLOCK_KNOCKDOWN
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	slowdown = SLOWDOWN_ARMOR_HEAVY
	unacidable = TRUE
	specialty = "M3-G4 grenadier"
	flags_item = MOB_LOCK_ON_EQUIP

/obj/item/clothing/suit/storage/marine/M3T
	name = "\improper M3-T light armor"
	desc = "A custom set of M3 armor designed for users of long ranged explosive weaponry."
	icon_state = "demolitionist"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_HIGH
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	slowdown = SLOWDOWN_ARMOR_LIGHT
	unacidable = TRUE
	specialty = "M3-T light"
	flags_item = MOB_LOCK_ON_EQUIP

/obj/item/clothing/suit/storage/marine/M3S
	name = "\improper M3-S light armor"
	desc = "A custom set of M3 armor designed for USCM Scouts."
	icon_state = "scout_armor"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	slowdown = SLOWDOWN_ARMOR_LIGHT
	unacidable = TRUE
	specialty = "M3-S light"
	flags_item = MOB_LOCK_ON_EQUIP

#define FIRE_SHIELD_CD 150

/obj/item/clothing/suit/storage/marine/M35
	name = "\improper M35 pyrotechnician armor"
	desc = "A custom set of M35 armor designed for use by USCM Pyrotechnicians."
	icon_state = "pyro_armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	max_heat_protection_temperature = FIRESUIT_max_heat_protection_temperature
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	unacidable = TRUE
	specialty = "M35 pyrotechnician"
	flags_item = MOB_LOCK_ON_EQUIP
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/specialist/fire_shield)
	var/fire_shield_on = FALSE
	var/can_activate = TRUE

/obj/item/clothing/suit/storage/marine/M35/Initialize(mapload, ...)
	. = ..()

/obj/item/clothing/suit/storage/marine/M35/verb/fire_shield()
	set name = "Activate Fire Shield"
	set desc = "Activate your armor's FIREWALK protocol for a short duration."
	set category = "Pyro"

	if(!usr || usr.is_mob_incapacitated(TRUE))
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	
	if(H.wear_suit != src)
		to_chat(H, SPAN_WARNING("You must be wearing the M35 pyro armor to activate FIREWALK protocol!"))
		return
	
	if(!skillcheck(H, SKILL_SPEC_WEAPONS, SKILL_SPEC_TRAINED) && H.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_PYRO)
		to_chat(H, SPAN_WARNING("You don't seem to know how to use [src]..."))
		return

	if(fire_shield_on)
		to_chat(H, SPAN_WARNING("You already have FIREWALK protocol activated!"))
		return
	
	if(!can_activate)
		to_chat(H, SPAN_WARNING("FIREWALK protocol was recently activated, wait before trying to activate it again."))
		return

	to_chat(H, SPAN_NOTICE("FIREWALK protocol has been activated. You will now be immune to fire for 6 seconds!"))
	registerListener(H, EVENT_PREIGNITION_CHECK, "fireshield_\ref[src]", CALLBACK(src, .proc/fire_shield_is_on))
	registerListener(H, EVENT_PRE_FIRE_BURNED_CHECK, "fireshield_\ref[src]", CALLBACK(src, .proc/fire_shield_is_on))
	fire_shield_on = TRUE
	can_activate = FALSE
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()
	addtimer(CALLBACK(src, .proc/end_fire_shield, H), SECONDS_6)

/obj/item/clothing/suit/storage/marine/M35/proc/end_fire_shield(var/mob/living/carbon/human/user)
	if(!istype(user))
		return
	to_chat(user, SPAN_NOTICE("FIREWALK protocol has finished."))
	unregisterListener(user, EVENT_PREIGNITION_CHECK, "fireshield_\ref[src]")
	unregisterListener(user, EVENT_PRE_FIRE_BURNED_CHECK, "fireshield_\ref[src]")
	fire_shield_on = FALSE
	
	addtimer(CALLBACK(src, .proc/enable_fire_shield, user), FIRE_SHIELD_CD)

/obj/item/clothing/suit/storage/marine/M35/proc/enable_fire_shield(var/mob/living/carbon/human/user)
	if(!istype(user))
		return
	to_chat(user, SPAN_NOTICE("FIREWALK protocol can be activated again."))
	can_activate = TRUE

	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()

// This proc is solely so that raiseEventSync returns TRUE (i.e. fire shield is on)
/obj/item/clothing/suit/storage/marine/M35/proc/fire_shield_is_on()
	return TRUE

/obj/item/clothing/suit/storage/marine/M35/dropped(var/mob/user)
	if (!istype(user))
		return
	unregisterListener(user, EVENT_PREIGNITION_CHECK, "fireshield_\ref[src]")
	unregisterListener(user, EVENT_PRE_FIRE_BURNED_CHECK, "fireshield_\ref[src]")

#undef FIRE_SHIELD_CD

/datum/action/item_action/specialist/fire_shield
	ability_primacy = SPEC_PRIMARY_ACTION_2

/datum/action/item_action/specialist/fire_shield/New(var/mob/living/user, var/obj/item/holder)
	..()
	name = "Activate Fire Shield"
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/obj/items/clothing/cm_suits.dmi', button, "pyro_armor")
	button.overlays += IMG

/datum/action/item_action/specialist/fire_shield/action_cooldown_check()
	var/obj/item/clothing/suit/storage/marine/M35/armor = holder_item
	if (!istype(armor))
		return FALSE
	
	return !armor.can_activate

/datum/action/item_action/specialist/fire_shield/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(istype(H) && !H.is_mob_incapacitated() && H.wear_suit == holder_item)
		return TRUE

/datum/action/item_action/specialist/fire_shield/action_activate()
	var/obj/item/clothing/suit/storage/marine/M35/armor = holder_item
	if (!istype(armor))
		return
	
	armor.fire_shield()

/obj/item/clothing/suit/storage/marine/ghillie
	name = "\improper M45 pattern ghillie armor"
	desc = "A lightweight ghillie camouflage suit, used by USCM snipers on recon missions. Very lightweight, but doesn't protect much."
	icon_state = "ghillie_armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	slowdown = SLOWDOWN_ARMOR_LIGHT
	specialty = "M45 pattern ghillie"
	flags_marine_armor = ARMOR_LAMP_OVERLAY
	flags_item = MOB_LOCK_ON_EQUIP

//=============================//PMCS\\==================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/veteran
	flags_marine_armor = ARMOR_LAMP_OVERLAY
	flags_atom = NO_SNOW_TYPE|UNIQUE_ITEM_TYPE //Let's make these keep their name and icon.

/obj/item/clothing/suit/storage/marine/veteran/PMC
	name = "\improper M4 pattern PMC armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind."
	icon_state = "pmc_armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_atom = NO_SNOW_TYPE|UNIQUE_ITEM_TYPE
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/melee/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/melee/claymore/mercsword/machete,
		/obj/item/attachable/bayonet,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC)
	item_state_slots = list(WEAR_JACKET = "pmc_armor")

/obj/item/clothing/suit/storage/marine/veteran/PMC/leader
	name = "\improper M4 pattern PMC leader armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_armor"
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/leader)
	item_state_slots = list(WEAR_JACKET = "officer_armor")

/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper
	name = "\improper M4 pattern PMC sniper armor"
	icon_state = "pmc_sniper"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDELOWHAIR
	item_state_slots = list(WEAR_JACKET = "pmc_sniper")

/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC
	name = "\improper PMC gunner armor"
	desc = "A modification of the standard Armat Systems M3 armor. Hooked up with harnesses and straps allowing the user to carry an M56 Smartgun."
	icon_state = "heavy_armor"
	flags_inventory = BLOCK_KNOCKDOWN
	flags_atom = NO_SNOW_TYPE|UNIQUE_ITEM_TYPE
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	item_state_slots = list(WEAR_JACKET = "heavy_armor")

/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC/terminator
	name = "\improper M5Xg exoskeleton gunner armor"
	desc = "A complex system of overlapping plates intended to render the wearer all but impervious to small arms fire. A passive exoskeleton supports the weight of the armor, allowing a human to carry its massive bulk. This varient is designed to support a M56 Smartgun."
	icon_state = "commando_armor"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	movement_compensation = SLOWDOWN_ARMOR_VERY_HEAVY
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_VERYHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	flags_inventory = BLOCK_KNOCKDOWN
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	storage_slots = 2
	unacidable = TRUE
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/commando)
	item_state_slots = list(WEAR_SUIT = "commando_armor")

/obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	name = "\improper M5X exoskeleton armor"
	desc = "A complex system of overlapping plates intended to render the wearer all but impervious to small arms fire. A passive exoskeleton supports the weight of the armor, allowing a human to carry its massive bulk."
	icon_state = "commando_armor"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	movement_compensation = SLOWDOWN_ARMOR_VERY_HEAVY
	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_VERYHIGH
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMHIGH
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	flags_inventory = BLOCK_KNOCKDOWN
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_FEET
	storage_slots = 2
	unacidable = TRUE
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/PMC/commando)
	item_state_slots = list(WEAR_JACKET = "commando_armor")

//===========================//DISTRESS\\================================\\
//=======================================================================\\

/obj/item/clothing/suit/storage/marine/veteran/bear
	name = "\improper H1 Iron Bears vest"
	desc = "A protective vest worn by Iron Bears mercenaries."
	icon_state = "bear_armor"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/bear)

/obj/item/clothing/suit/storage/marine/veteran/dutch
	name = "\improper D2 armored vest"
	desc = "A protective vest worn by some seriously experienced mercs."
	icon_state = "dutch_armor"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/dutch)




//===========================//U.P.P\\================================\\
//=====================================================================\\

/obj/item/clothing/suit/storage/marine/faction
	flags_atom = NO_SNOW_TYPE|UNIQUE_ITEM_TYPE
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	min_cold_protection_temperature = ARMOR_min_cold_protection_temperature
	max_heat_protection_temperature = ARMOR_max_heat_protection_temperature
	blood_overlay_type = "armor"
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUM
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	movement_compensation = SLOWDOWN_ARMOR_LIGHT


/obj/item/clothing/suit/storage/marine/faction/UPP
	name = "\improper UM5 personal armor"
	desc = "Standard body armor of the UPP military, the UM5 (Union Medium MK5) is a medium body armor, roughly on par with the venerable M3 pattern body armor in service with the USCM. Unlike the M3, however, the plate has a heavier neckplate, but unfortunately restricts movement slightly more. This has earned many UA members to refer to UPP soldiers as 'tin men'."
	icon_state = "upp_armor"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/UPP)

/obj/item/clothing/suit/storage/marine/faction/UPP/commando
	name = "\improper UM5CU personal armor"
	desc = "A modification of the UM5, designed for stealth operations."
	icon_state = "upp_armor_commando"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/faction/UPP/heavy
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the UPP military, the UH7 (Union Heavy MK5) is known for being a rugged set of armor, capable of taking immesnse punishment. Although the armor doesn't protect certain areas, it provides unmatchable protection from the front, which UPP engineers summerized as the most likely target for enemy fire. In order to cut costs, the head shielding in the MK6 has been stripped down a bit in the MK7, but this comes at much more streamlined production.  "
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_inventory = BLOCK_KNOCKDOWN
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_HIGH
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2

/obj/item/clothing/suit/storage/marine/smartgunner/UPP
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the UPP military, the UH7 (Union Heavy MK5) is known for being a rugged set of armor, capable of taking immesnse punishment. Although the armor doesn't protect certain areas, it provides unmatchable protection from the front, which UPP engineers summerized as the most likely target for enemy fire. In order to cut costs, the head shielding in the MK6 has been stripped down a bit in the MK7, but this comes at much more streamlined production.  "
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_inventory = BLOCK_KNOCKDOWN
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_HIGH
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/UPP)

/obj/item/clothing/suit/storage/marine/faction/UPP/ivan
	name = "\improper UM6 Camo Jacket"
	desc = "An experimental heavily armored variant of the UM5 given to only the most elite units."
	icon_state = "ivan_jacket"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_ARMS|BODY_FLAG_HANDS|BODY_FLAG_FEET
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_HIGH
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HIGH
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/UPP)
//===========================//FREELANCER\\================================\\
//=====================================================================\\

/obj/item/clothing/suit/storage/marine/faction/freelancer
	name = "freelancer cuirass"
	desc = "A armored protective chestplate scrapped together from various plates. It keeps up remarkably well, as the craftsmanship is solid, and the design mirrors such armors in the UPP and the USCM. The many skilled craftsmen in the freelancers ranks produce these vests at a rate about one a month."
	icon_state = "freelancer_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/freelancer)

//this one is for CLF
/obj/item/clothing/suit/storage/militia
	name = "colonial militia hauberk"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While not the most powerful form of armor, and primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. It is also quick to don, easy to hide, and cheap to produce in large workshops."
	icon = 'icons/obj/items/clothing/cm_suits.dmi'
	icon_state = "rebel_armor"
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/suit_1.dmi'
	)
	sprite_sheets = list(SPECIES_MONKEY = 'icons/mob/humans/species/monkeys/onmob/suit_monkey_1.dmi')
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_ARMS
	movement_compensation = SLOWDOWN_ARMOR_MEDIUM
	armor_melee = CLOTHING_ARMOR_MEDIUM
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUM
	storage_slots = 2
	uniform_restricted = list(/obj/item/clothing/under/colonist)
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/device/binoculars,
		/obj/item/attachable/bayonet,
		/obj/item/storage/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/melee/baseballbat,
		/obj/item/weapon/melee/baseballbat/metal,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman)
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_FEET|BODY_FLAG_ARMS|BODY_FLAG_HANDS
	min_cold_protection_temperature = SPACE_SUIT_min_cold_protection_temperature

/obj/item/clothing/suit/storage/militia/New()
	..()
	pockets.max_w_class = SIZE_SMALL //Can contain small items AND rifle magazines.
	pockets.bypass_w_limit = list(
	/obj/item/ammo_magazine/rifle,
	/obj/item/ammo_magazine/smg,
	/obj/item/ammo_magazine/sniper,
	 )
	pockets.max_storage_space = 8

/obj/item/clothing/suit/storage/militia/vest
	name = "colonial militia vest"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While not the most powerful form of armor, and primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. It is also quick to don, easy to hide, and cheap to produce in large workshops. This extremely light variant protects only the chest and abdomen."
	icon_state = "clf_2"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	slowdown = 0.2
	movement_compensation = SLOWDOWN_ARMOR_MEDIUM

/obj/item/clothing/suit/storage/militia/brace
	name = "colonial militia brace"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While not the most powerful form of armor, and primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. It is also quick to don, easy to hide, and cheap to produce in large workshops. This extremely light variant has some of the chest pieces removed."
	icon_state = "clf_3"
	flags_armor_protection = BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	slowdown = 0.2
	movement_compensation = SLOWDOWN_ARMOR_MEDIUM

/obj/item/clothing/suit/storage/militia/partial
	name = "colonial militia partial hauberk"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While not the most powerful form of armor, and primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. It is also quick to don, easy to hide, and cheap to produce in large workshops. This even lighter variant has some of the arm pieces removed."
	icon_state = "clf_4"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	slowdown = 0.2

/obj/item/clothing/suit/storage/CMB
	name = "\improper CMB jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_ARMS

/obj/item/clothing/suit/storage/RO
	name = "\improper RO jacket"
	desc = "A green jacket worn by USCM personnel. The back has the flag of the United Americas on it."
	icon_state = "RO_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_ARMS

//===========================//HELGHAST - MERCENARY\\================================\\
//=====================================================================\\

/obj/item/clothing/suit/storage/marine/veteran/mercenary
	name = "\improper K12 ceramic plated armor"
	desc = "A set of grey, heavy ceramic armor with dark blue highlights. It is the standard uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_heavy_armor"
	flags_inventory = BLOCK_KNOCKDOWN
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/melee/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/melee/claymore/mercsword/machete,
		/obj/item/attachable/bayonet,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/mercenary)
	item_state_slots = list(WEAR_JACKET = "mercenary_heavy_armor")

/obj/item/clothing/suit/storage/marine/veteran/mercenary/miner
	name = "\improper Y8 armored miner vest"
	desc = "A set of beige, light armor built for protection while mining. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_miner_armor"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/melee/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/melee/claymore/mercsword/machete,
		/obj/item/attachable/bayonet,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/mercenary)
	item_state_slots = list(WEAR_JACKET = "mercenary_miner_armor")

/obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer
	name = "\improper Z7 armored engineer vest"
	desc = "A set of blue armor with yellow highlights built for protection while building in highly dangerous environments. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_engineer_armor"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMLOW
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUM
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
	storage_slots = 2
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/melee/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/melee/claymore/mercsword/machete,
		/obj/item/attachable/bayonet,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman)
	uniform_restricted = list(/obj/item/clothing/under/marine/veteran/mercenary)
	item_state_slots = list(WEAR_JACKET = "mercenary_engineer_armor")

/obj/item/clothing/suit/storage/marine/M3G/hefa
	name = "\improper HEFA Knight armor"
	desc = "A thick piece of armor adorning a HEFA. Usually seen on a HEFA knight."
	specialty = "HEFA Knight"
	icon_state = "hefadier"
	flags_atom = UNIQUE_ITEM_TYPE|NO_SNOW_TYPE
	flags_marine_armor = ARMOR_LAMP_OVERLAY
