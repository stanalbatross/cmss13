/obj/effect
	var/handled_by_master_subsystem = TRUE

/obj/effect/New()
	. = ..()
	if(handled_by_master_subsystem)
		effect_list += src

/obj/effect/Destroy()
	. = ..()
	if(handled_by_master_subsystem)
		effect_list -= src


