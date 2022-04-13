///*****************************LV-522 Force Recon Survivors*******************************************************/
//Nanu told me to put them here so they dont clutter up survivors.dm

/datum/equipment_preset/survivor/forecon/
	paygrade = "E5 "
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)

/datum/equipment_preset/survivor/forecon/add_survivor_weapon(var/mob/living/carbon/human/H)
	var/random_gun = rand(1,3)
	switch(random_gun)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_L_HAND)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/l42a(H), WEAR_L_HAND)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/l42a(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/l42a(H), WEAR_IN_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), WEAR_L_HAND)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)

/datum/equipment_preset/survivor/forecon/add_survivor_weapon_pistol(mob/living/carbon/human/H)
	var/random_pistol = rand(1,6)
	switch(random_pistol)
		if(1 , 2 , 3 , 4) 
			H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_IN_BELT)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
		if(5 , 6)
			H.equip_to_slot_or_del(new /obj/item/device/motiondetector(H),WEAR_WAIST)

/datum/equipment_preset/survivor/forecon/add_random_survivor_equipment(mob/living/carbon/human/H)
	var/random_equipment = rand(1,3)
	switch(random_equipment)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/device/walkman(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/cassette_tape/indie(H), WEAR_IN_BACK)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/toy/deck(H), WEAR_IN_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/lucky_strikes(H), WEAR_IN_BACK)

/datum/equipment_preset/survivor/forecon/proc/spawn_random_headgear(var/mob/living/carbon/human/H)
	var/i = rand(1,10)
	switch(i)
		if (1 , 2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if (3 , 4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if (5 , 6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if (7 , 8)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)
		if (9)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)

/datum/equipment_preset/survivor/forecon/standard
	name = "Survivor - USCM Reconnaissance Marine"
	assignment = "Reconnaissance Squad Marine"
	skills = /datum/skills/military/Survivor/forecon_Standard

/datum/equipment_preset/survivor/forecon/standard/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/random/forecon = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	forecon.attach_accessory(H, W)
	H.equip_to_slot_or_del(forecon, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	spawn_random_headgear(H)

	..()

///*****************************//

/datum/equipment_preset/survivor/forecon/Tech
	name = "Survivor - USCM Reconnaissance Support Technician"
	assignment = "Reconnaissance Squad Support Technician"
	skills = /datum/skills/military/Survivor/forecon_Tech

/datum/equipment_preset/survivor/forecon/Tech/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/random/forecon = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	forecon.attach_accessory(H, W)
	H.equip_to_slot_or_del(forecon, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/autoinjector(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/insulated(H), WEAR_HANDS)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/defibrillator(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	spawn_random_headgear(H)
	
	..()

///*****************************//

/datum/equipment_preset/survivor/forecon/Marksman
	name = "Survivor - USCM Reconnaissance Designated Marksman"
	assignment = "Reconnaissance Squad Specialist"
	skills = /datum/skills/military/Survivor/forecon_Marksman

/datum/equipment_preset/survivor/forecon/Marksman/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/random/forecon = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	forecon.attach_accessory(H, W)
	H.equip_to_slot_or_del(forecon, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m4ra(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m4ra(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m4ra(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	spawn_random_headgear(H)

	..()

///*****************************//

/datum/equipment_preset/survivor/forecon/Machinegunner
	name = "Survivor - USCM Reconnaissance Machinegunner"
	assignment = "Reconnaissance Squad Specialist"
	skills = /datum/skills/military/Survivor/forecon_Machinegunner

/datum/equipment_preset/survivor/forecon/Machinegunner/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/random/forecon = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	forecon.attach_accessory(H, W)
	H.equip_to_slot_or_del(forecon, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/smartgunner(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	spawn_random_headgear(H)

	..()
	
///*****************************//

/datum/equipment_preset/survivor/forecon/Grenadier
	name = "Survivor - USCM Reconnaissance Grenadier"
	assignment = "Reconnaissance Squad Specialist"
	skills = /datum/skills/military/Survivor/forecon_Grenadier

/datum/equipment_preset/survivor/forecon/Grenadier/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/random/forecon = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	forecon.attach_accessory(H, W)
	H.equip_to_slot_or_del(forecon, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/grenade/m81/m79(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/grenade(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	spawn_random_headgear(H)

	..()
	
//---------------------------\\

//datum/equipment_preset/survivor/forecon/Officer
//	name = "Survivor - USCM Reconnaissance Captain"
//	assignment = "Reconnaissance Captain"
//	skills = /datum/skills/commander
//
//datum/equipment_preset/survivor/forecon/Officer/load_gear(mob/living/carbon/human/H)
//	var/obj/item/clothing/under/marine/forecon = new()
//	var/obj/item/clothing/accessory/storage/webbing/W = new()
//	forecon.attach_accessory(H, W)
//	H.equip_to_slot_or_del(forecon, WEAR_BODY)
//	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_ACCESSORY)
//	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_ACCESSORY)
//	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine(H), WEAR_IN_ACCESSORY)
//	H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), WEAR_R_STORE)
//	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
//
//	..()


//---------------------------\\

/datum/equipment_preset/survivor/forecon/Squad_Leader
	name = "Survivor - USCM Reconnaissance Squad Leader"
	assignment = "Reconnaissance Squad Leader"
	skills = /datum/skills/military/Survivor/forecon_Squad_Lead

/datum/equipment_preset/survivor/forecon/Squad_Leader/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/random/forecon = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	forecon.attach_accessory(H, W)
	H.equip_to_slot_or_del(forecon, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/slugs(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	spawn_random_headgear(H)

	..()