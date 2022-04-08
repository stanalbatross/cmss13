///*****************************LV-522 Force Recon Survivors*******************************************************/
//Nanu told me to put them here so they dont clutter up survivors.dm
/datum/equipment_preset/survivor/FORCON_Standard/lv522
	name = "Survivor - USCM Reconnaissance Marine"
	assignment = "Reconnaissance Squad Marine"
	paygrade = "E5"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR
	faction = FACTION_MARINE
	skills = /datum/skills/military/Survivor/FORCON_Standard
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Standard/lv522/load_gear(mob/living/carbon/human/H)
	var/random_head = rand(1,6)
	var/random_gun = rand(1,3)
	var/obj/item/clothing/under/marine/random/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/attachable/suppressor(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)

	switch(random_head)
		if(1)

		if(2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if(5)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)

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
	..()

///*****************************//

/datum/equipment_preset/survivor/FORCON_Tech/lv522
	name = "Survivor - USCM Reconnaissance Support Technician"
	assignment = "Reconnaissance Squad Support Technician"
	paygrade = "E5"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR	
	faction = FACTION_MARINE
	skills = /datum/skills/military/Survivor/FORCON_Tech
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Tech/lv522/load_gear(mob/living/carbon/human/H)
	var/random_head = rand(1,6)
	var/obj/item/clothing/under/marine/random/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
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
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)

	switch(random_head)
		if(1)

		if(2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if(5)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)

	..()

///*****************************//

/datum/equipment_preset/survivor/FORCON_Marksman/lv522
	name = "Survivor - USCM Reconnaissance Designated Marksman"
	assignment = "Reconnaissance Squad Specialist"
	paygrade = "E5"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR	
	faction = FACTION_MARINE
	skills = /datum/skills/military/Survivor/FORCON_Marksman
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Marksman/lv522/load_gear(mob/living/carbon/human/H)
	var/random_head = rand(1,6)
	var/obj/item/clothing/under/marine/random/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/attachable/suppressor(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m4ra(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m4ra(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m4ra(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)

	switch(random_head)
		if(1)

		if(2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if(5)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/scout(H), WEAR_HEAD)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)
	..()

///*****************************//

/datum/equipment_preset/survivor/FORCON_Machinegunner/lv522
	name = "Survivor - USCM Reconnaissance Machinegunner"
	assignment = "Reconnaissance Squad Specialist"
	paygrade = "E5"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR	
	faction = FACTION_MARINE
	skills = /datum/skills/military/Survivor/FORCON_Machinegunner
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Machinegunner/lv522/load_gear(mob/living/carbon/human/H)
	var/random_head = rand(1,6)
	var/obj/item/clothing/under/marine/random/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/smartgunner(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)

	switch(random_head)
		if(1)

		if(2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if(5)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(H), WEAR_HEAD)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)

	..()
	
///*****************************//

/datum/equipment_preset/survivor/FORCON_Grenadier/lv522
	name = "Survivor - USCM Reconnaissance Grenadier"
	assignment = "Reconnaissance Squad Specialist"
	paygrade = "E5"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR	
	faction = FACTION_MARINE
	skills = /datum/skills/military/Survivor/FORCON_Grenadier
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Grenadier/lv522/load_gear(mob/living/carbon/human/H)
	var/random_head = rand(1,6)
	var/obj/item/clothing/under/marine/random/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/grenade/m81(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/grenade(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)
	
	switch(random_head)
		if(1)

		if(2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if(5)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/grenadier(H), WEAR_HEAD)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)

	..()
	
///*****************************//

/datum/equipment_preset/survivor/FORCON_Squad_Leader/lv522
	name = "Survivor - USCM Reconnaissance Squad Leader"
	assignment = "Reconnaissance Squad Leader"
	paygrade = "E6"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR	
	faction = FACTION_MARINE
	skills = /datum/skills/military/Survivor/FORCON_Squad_Lead
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Squad_Leader/lv522/load_gear(mob/living/carbon/human/H)
	var/random_head = rand(1,6)
	var/obj/item/clothing/under/marine/random/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE(H), WEAR_IN_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump(H), WEAR_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3(H), WEAR_WAIST)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911(H), WEAR_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/slugs(H), WEAR_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/clothing/accessory/health(H), WEAR_IN_BACK)

	switch(random_head)
		if(1)

		if(2)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), WEAR_HEAD)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie/gray(H), WEAR_HEAD)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/durag(H), WEAR_HEAD)			
		if(5)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/leader(H), WEAR_HEAD)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(H), WEAR_HEAD)

	..()
	
///*****************************//

/datum/equipment_preset/survivor/FORCON_Officer/lv522
	name = "Survivor - USCM Reconnaissance Captain"
	assignment = "Reconnaissance Captain"
	paygrade = "O5"
	role_comm_title = "FORCON"
	idtype = /obj/item/card/id/dogtag
	rank = JOB_SURVIVOR	
	faction = FACTION_MARINE
	skills = /datum/skills/commander
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
		ACCESS_CIVILIAN_ENGINEERING,
		ACCESS_CIVILIAN_LOGISTICS
	)
/datum/equipment_preset/survivor/FORCON_Captain/lv522/load_gear(mob/living/carbon/human/H)
	var/obj/item/clothing/under/marine/FORCON = new()
	var/obj/item/clothing/accessory/storage/webbing/W = new()
	FORCON.attach_accessory(H, W)
	H.equip_to_slot_or_del(FORCON, WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine(H), WEAR_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(H), WEAR_FEET)

	..()

///*****************************//
