/obj/item/explosive/satchel_charge
	name = "satchel charge"
	desc = "boomer"
	//desc = "After linked to a detonator, and thrown, will become primed and able to be detonated."
	gender = PLURAL
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "satchel"
	flags_item = NOBLUDGEON
	w_class = SIZE_SMALL
	max_container_volume = 180
	reaction_limits = list(	"max_ex_power" = 260,	"base_ex_falloff" = 90,	"max_ex_shards" = 64,
							"max_fire_rad" = 6,		"max_fire_int" = 26,	"max_fire_dur" = 30,
							"min_fire_rad" = 2,		"min_fire_int" = 4,		"min_fire_dur" = 5
	)

	var/prime_time_usa = 3 SECONDS
	detonator = null

/obj/item/explosive/satchel_charge/proc/primer()
	icon_state = "satchel_primed"

/obj/item/explosive/satchel_charge/throw_atom(atom/target, range, speed, atom/thrower, spin, launch_type, pass_flags)
	. = ..()
	icon_state = "satchel_armed"
	addtimer(CALLBACK(src, .proc/primer), prime_time_usa, TIMER_UNIQUE)


/obj/item/explosive/satchel_charge/pickup(mob/user)
	. = ..()
	if(icon_state == "satchel_primed")
		explosion(src.loc, 5,5,5,5)
	icon_state = "satchel"


