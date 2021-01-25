/*
Lever-action bullet handfuls!
Similar to shotguns.dm but not exactly.
*/

/obj/item/ammo_magazine/lever_action
	name = "box of 45-70 rounds"
	desc = "A box filled with handfuls of 45-70 Govt. rounds, for the old-timed."
	icon_state = "45-70-box"
	item_state = "45-70-box"
	default_ammo = /datum/ammo/bullet/lever_action
	caliber = "45-70"
	gun_type = /obj/item/weapon/gun/lever_action
	max_rounds = 50
	w_class = SIZE_LARGE
	flags_magazine = AMMUNITION_REFILLABLE|AMMUNITION_HANDFUL_BOX

/obj/item/ammo_magazine/lever_action/base

/obj/item/ammo_magazine/lever_action/heavy
	name = "box of heavy 45-70 rounds"
	desc = "A box filled with handfuls of heavy 45-70 Govt. rounds, which have a higher-density, more impactful bullet package."
	icon_state = "45-70-heavy-box"
	item_state = "45-70-heavy-box"
	default_ammo = /datum/ammo/bullet/lever_action/heavy

/obj/item/ammo_magazine/lever_action/marksman
	name = "box of marksman 45-70 rounds"
	desc = "A box filled with marksman lever action 45-70 rounds, which have a lower-density, more precise bullet package."
	icon_state = "45-70-marksman-box"
	item_state = "45-70-marksman-box"
	default_ammo = /datum/ammo/bullet/lever_action/marksman

/obj/item/ammo_magazine/lever_action/tracker
	name = "box of tracker 45-70 rounds"
	desc = "A box filled with tracker lever action 45-70 rounds, which replace some of the bullet package with an electronic tracking chip."
	icon_state = "45-70-tracker-box"
	item_state = "45-70-tracker-box"
	default_ammo = /datum/ammo/bullet/lever_action/tracker

/obj/item/ammo_magazine/lever_action/training
	name = "box of training rounds"
	desc = "A box filled with training lever action 45-70 rounds that aren't very damaging.. unless you fire them directly into someone's face."
	icon_state = "45-70-training-box"
	item_state = "45-70-training-box"
	default_ammo = /datum/ammo/bullet/lever_action/training

//-------------------------------------------------------

/obj/item/ammo_magazine/internal/lever_action
	name = "lever action tube"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = /datum/ammo/bullet/lever_action/base
	caliber = "45-70"
	max_rounds = 9
	chamber_closed = 0

//-------------------------------------------------------

/*
Handfuls of lever_action rounds. For spawning directly on mobs in roundstart, ERTs, etc
*/

/obj/item/ammo_magazine/handful/lever_action
	name = "handful of rounds (45-70)"
	desc = "A handful of standard 45-70 Govt. rounds."
	icon_state = "lever_action_bullet"
	default_ammo = /datum/ammo/bullet/lever_action/base
	caliber = "45-70"
	max_rounds = 8
	current_rounds = 8
	gun_type = /obj/item/weapon/gun/lever_action

/obj/item/ammo_magazine/handful/lever_action/base

/obj/item/ammo_magazine/handful/lever_action/heavy
	name = "handful of heavy rounds (45-70)"
	desc = "A handful of heavy 45-70 Govt. rounds. Their dense bullet package reduces penetration, speed, and accuracy, but makes them throw their target back on hit."
	icon_state = "heavy_lever_action_bullet"
	default_ammo = /datum/ammo/bullet/lever_action/heavy

/obj/item/ammo_magazine/handful/lever_action/tracker
	name = "handful of tracker 45-70 rounds (45-70)"
	desc = "A handful of tracker 45-70 Govt. rounds. Some of their bullet package's been replaced with a chip that when fired can be picked up by Motion Detectors."
	icon_state = "tracking_lever_action_bullet"
	default_ammo = /datum/ammo/bullet/lever_action/tracker

/obj/item/ammo_magazine/handful/lever_action/training
	name = "handful of training blanks (45-70)"
	desc = "A handful of tracker 45-70 Govt. rounds. These rounds are blanks, which are mostly harmless.... just don't shoot them at point-blank range."
	icon_state = "training_lever_action_bullet"
	default_ammo = /datum/ammo/bullet/lever_action/training

/obj/item/ammo_magazine/handful/lever_action/marksman
	name = "handful of marksman 45-70 rounds (45-70)"
	desc = "A handful of heavy 45-70 Govt. rounds. Their small bullet package reduces damage, but increases penetration and bullet velocity."
	icon_state = "marksman_lever_action_bullet"
	default_ammo = /datum/ammo/bullet/lever_action/marksman
