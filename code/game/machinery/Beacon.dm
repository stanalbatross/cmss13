/obj/structure/machinery/bluespace_beacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = UNDERFLOOR_OBJ_LAYER
	anchored = 1
	use_power = 1
	idle_power_usage = 0
	var/obj/item/device/radio/beacon/Beacon

/obj/structure/machinery/bluespace_beacon/New()
	..()
	var/turf/T = loc
	Beacon = new /obj/item/device/radio/beacon
	Beacon.invisibility = INVISIBILITY_MAXIMUM
	Beacon.loc = T

	hide(T.intact_tile)

/obj/structure/machinery/bluespace_beacon/Destroy()
	if(Beacon)
		qdel(Beacon)
		Beacon = null
	return ..()

/obj/structure/machinery/bluespace_beacon
	// update the invisibility and icon
	hide(var/intact)
		invisibility = intact ? 101 : 0
		updateicon()

	// update the icon_state
	proc/updateicon()
		var/state="floor_beacon"

		if(invisibility)
			icon_state = "[state]f"

		else
			icon_state = "[state]"

	process()
		if(!Beacon)
			var/turf/T = loc
			Beacon = new /obj/item/device/radio/beacon
			Beacon.invisibility = INVISIBILITY_MAXIMUM
			Beacon.loc = T
		if(Beacon)
			if(Beacon.loc != loc)
				Beacon.loc = loc

		updateicon()


