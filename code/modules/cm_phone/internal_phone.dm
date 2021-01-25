GLOBAL_LIST_EMPTY_TYPED(transmitters_internal, /obj/structure/transmitter/internal)

/obj/structure/transmitter/internal
    name = "\improper internal telephone receiver"

    phone_type = /obj/item/phone

/obj/structure/transmitter/internal/Initialize(mapload, ...)
	. = ..()

	if(!get_turf(src))
		return

	GLOB.transmitters_internal += src


/obj/structure/transmitter/internal/Destroy()
	GLOB.transmitters_internal += src
	return ..()

