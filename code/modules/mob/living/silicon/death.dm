
/mob/living/silicon/spawn_gibs()
	robogibs(loc, viruses)

/mob/living/silicon/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, src, "gibbed-r")



/mob/living/silicon/spawn_dust_remains()
	new /obj/effect/decal/remains/robot(loc)

/mob/living/silicon/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-r")


/mob/living/silicon/death(datum/cause_data/cause_data, var/gibbed, var/deathmessage)
	SSmob.living_misc_mobs -= src
	if(in_contents_of(/obj/structure/machinery/recharge_station))//exit the recharge station
		var/obj/structure/machinery/recharge_station/RC = loc
		RC.go_out()
	return ..(cause_data, gibbed, deathmessage)
