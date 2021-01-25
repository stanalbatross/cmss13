// THE MARINE TECH TREE
/datum/techtree/marine
	name = TREE_MARINE
	flags = TREE_FLAG_MARINE

	resource_icon_state = "node_marine"

	resource_make_sound = 'sound/machines/resource_node/node_marine_on.ogg'
	resource_destroy_sound = 'sound/machines/resource_node/node_marine_die_2.ogg'

	resource_break_sound = 'sound/effects/metalhit.ogg'

	resource_harvest_sound = 'sound/machines/resource_node/node_marine_harvest.ogg'

	resource_receive_process = TRUE

	var/last_pain_reduction = 0
	var/barricade_bonus_health = 100

	var/list/affected_barricades = list()

/datum/techtree/marine/has_access(var/mob/M, var/access_required)
	if(!ishuman(M))
		return FALSE

	var/mob/living/carbon/human/H = M

	switch(access_required)
		if(TREE_ACCESS_VIEW)
			if(H.wear_id && (ACCESS_MARINE_LEADER in H.wear_id.access))
				return TRUE
		if(TREE_ACCESS_MODIFY)
			if(H.wear_id && (ACCESS_MARINE_COMMANDER in H.wear_id.access))
				return TRUE

	return FALSE

/datum/techtree/marine/can_attack(var/mob/living/carbon/H)
	return !ishuman(H)

/datum/techtree/marine/proc/apply_barricade_health(var/obj/structure/barricade/B)
	B.maxhealth += barricade_bonus_health
	B.update_health(-barricade_bonus_health)

#define LIGHT_OK 0
/datum/techtree/marine/on_node_gained(var/obj/structure/resource_node/RN)
	. = ..()

	RN.SetLuminosity(8)

	var/area/A = RN.controlled_area
	if(!A)
		log_debug("[RN] passed as argument for on_node_gained. (Tech Tree: [name])")
		return

	A.requires_power = FALSE
	A.unlimited_power = TRUE

	for(var/obj/structure/machinery/light/L in A.area_machines)
		L.status = LIGHT_OK
		L.update(0)

	A.update_power_channels(TRUE, TRUE, TRUE)

	affected_barricades.Add(RN)
	affected_barricades[RN] = list()

	for(var/obj/structure/barricade/B in A)
		apply_barricade_health(B)
		affected_barricades[RN] += B

#undef LIGHT_OK

/datum/techtree/marine/on_node_lost(var/obj/structure/resource_node/RN)
	. = ..()

	RN.SetLuminosity(0)

	var/area/A = RN.controlled_area
	if(!A)
		log_debug("[RN] passed as argument for on_node_gained. (Tech Tree: [name])")
		return

	A.requires_power = TRUE
	A.unlimited_power = FALSE

	A.update_power_channels(FALSE, FALSE, FALSE)

	while(length(affected_barricades[RN]))
		var/obj/structure/barricade/B = affected_barricades[RN][affected_barricades.len]

		affected_barricades[RN] -= B

		if(!istype(B))
			continue

		B.maxhealth -= barricade_bonus_health
		B.update_health(barricade_bonus_health)

	affected_barricades.Remove(RN)

/datum/techtree/marine/on_process(var/obj/structure/resource_node/RN)
	if(last_pain_reduction > world.time)
		return

	var/area/A = RN.controlled_area
	if(!A)
		log_debug("[RN] passed as argument for on_node_gained. (Tech Tree: [name])")
		return

	for(var/mob/living/carbon/human/H in A)
		H.pain.apply_pain_reduction(PAIN_REDUCTION_MULTIPLIER) // Level 1 painkilling chem

	last_pain_reduction = world.time + 1 SECONDS // Every second
