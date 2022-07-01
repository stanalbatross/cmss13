/obj/item/weapon/gun/grappling
	icon_state = "m4a3"
	item_state = "m4a3"
	reload_sound = 'sound/weapons/flipblade.ogg'
	cocked_sound = 'sound/weapons/gun_pistol_cocked.ogg'

	matter = list("metal" = 2000)
	flags_equip_slot = SLOT_WAIST
	w_class = SIZE_MEDIUM
	force = 6
	current_mag = /obj/item/ammo_magazine/pistol
	movement_onehanded_acc_penalty_mult = 3
	wield_delay = WIELD_DELAY_VERY_FAST //If you modify your pistol to be two-handed, it will still be fast to aim
	fire_sound = 'sound/weapons/gun_servicepistol.ogg'
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/reflex,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED //For easy reference.
	gun_category = GUN_CATEGORY_HANDGUN
