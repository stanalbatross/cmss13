turf/open/floor/cobaltite
	icon = 'icons/turf/leucanth.dmi'
	icon_state = "cobaltite_gravel"

turf/open/floor/cobaltite/edge
	icon_state = "cobaltite_gravel_edge"

turf/open/floor/cobaltite/edge_2
	icon_state = "cobaltite_gravel_edge_2"

turf/open/cobaltite_wall
	icon = 'icons/turf/leucanth.dmi'
	opacity = FALSE
	density = TRUE

turf/open/cobaltite_wall/base
	icon_state = "cobaltite_wall_1st"

turf/open/cobaltite_wall/covecorner
	icon_state = "cobaltite_wall_covecorner"

turf/open/cobaltite_wall/mid
	icon_state = "cobaltite_wall_2nd"

turf/open/cobaltite_wall/top
	icon_state = "cobaltite_wall_3rd"
	opacity = TRUE

turf/open/cobaltite_wall/top_2
	icon_state = "cobaltite_wall_3rd_2"
	opacity = TRUE

turf/open/gm/river/ichor
	name = "ichor"
	desc = "A substance poorly understood, known to cause acid burns and be slightly toxic to humans."
	icon = 'icons/turf/leucanth.dmi'
	icon_state = "ichor"
	icon_overlay = "ichor_overlay"
	cover_icon = 'icons/turf/leucanth.dmi'
	cover_icon_state = "ichor_solid"
	baseturfs = /turf/open/gm/river/ichor


/turf/open/gm/river/ichor/Entered(atom/A)
	. = ..()
	if(istype(A, /obj/effect/particle_effect/water))
		covered = TRUE
		update_overlays()
		return

	var/mob/M = A

	if(!iscarbon(M) || M.throwing)
		return

	if(!covered)
		var/mob/living/carbon/C = M
		var/river_slowdown = 4.75

		if(ishuman(C))
			var/mob/living/carbon/human/H = M
			cleanup(H)
			if(H.gloves && rand(0,100) < 60)
				if(istype(H.gloves,/obj/item/clothing/gloves/yautja))
					var/obj/item/clothing/gloves/yautja/Y = H.gloves
					if(Y && istype(Y) && Y.cloaked)
						to_chat(H, SPAN_WARNING(" Your bracers hiss and spark as they short out!"))
						Y.decloak(H, TRUE)

		else if(isXeno(C))
			river_slowdown = 3.0
			if(isXenoBoiler(C))
				river_slowdown = -0.5

		var/new_slowdown = C.next_move_slowdown + river_slowdown
		C.next_move_slowdown = new_slowdown

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.bloody_footsteps)
			SEND_SIGNAL(H, COMSIG_HUMAN_CLEAR_BLOODY_FEET)

	if(!istype(M.loc, /turf) || covered) //if mob is inside a xeno
		return

	for(var/turf/open/floor/F in range(0, src)) //stops the effect??
		return

	if(isXeno(M))
		if(M.pulling)
			to_chat(M, SPAN_WARNING("The current forces you to release [M.pulling]!"))
			M.stop_pulling()

	cause_damage(M)
	START_PROCESSING(SSobj, src)

turf/open/gm/river/ichor/process()
	if(covered)
		return

	var/mobs_present = 0
	for(var/mob/living/carbon/M in range(0, src))
		mobs_present++
		cause_damage(M)
	if(mobs_present < 1)
		STOP_PROCESSING(SSobj, src)


turf/open/gm/river/ichor/proc/cause_damage(mob/living/M)
	if(M.stat == DEAD)
		return
	M.last_damage_data = create_cause_data("toxic ichor")
	if(isXeno(M))
		M.apply_damage(5,TOX)
	else if(isYautja(M))
		M.apply_damage(0.5,TOX)
	else
		var/dam_amount = 1
		if(M.lying)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
		else
			M.apply_damage(dam_amount,BURN,"l_leg")
			M.apply_damage(dam_amount,BURN,"l_foot")
			M.apply_damage(dam_amount,BURN,"r_leg")
			M.apply_damage(dam_amount,BURN,"r_foot")
			M.apply_damage(dam_amount,BURN,"groin")
		M.apply_effect(20,IRRADIATE,0)
		if(!isSynth(M) ) to_chat(M, SPAN_DANGER("The ichor feels like needles on your skin!"))
	playsound(M, 'sound/effects/toxic_ichor_geiger.ogg', 10, 1)




