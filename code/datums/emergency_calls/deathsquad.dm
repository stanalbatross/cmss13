


//Deathsquad Commandos
/datum/emergency_call/death
	name = "Weyland Deathsquad"
	mob_max = 8
	mob_min = 5
	arrival_message = "Intercepted Transmission: '!`2*%slau#*jer t*h$em a!l%. le&*ve n(o^ w&*nes%6es.*v$e %#d ou^'"
	objectives = "Wipe out everything. Ensure there are no traces of the infestation or any witnesses."
	probability = 0
	shuttle_id = "Distress_PMC"
	name_of_spawn = /obj/effect/landmark/ert_spawns/distress_pmc
	item_spawn = /obj/effect/landmark/ert_spawns/distress_pmc/item
	max_medics = 1
	max_heavies = 2



// DEATH SQUAD--------------------------------------------------------------------------------
/datum/emergency_call/death/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()

	if(!istype(spawn_loc))
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/H = new(spawn_loc)
	M.transfer_to(H, TRUE)
	H.set_skills(/datum/skills/commando/deathsquad)

	if(!leader)       //First one spawned is always the leader.
		leader = H
		to_chat(H, SPAN_ROLE_HEADER("You are the Deathsquad Leader!"))
		to_chat(H, SPAN_ROLE_BODY("You must clear out any traces of the infestation and its survivors."))
		to_chat(H, SPAN_ROLE_BODY("Follow any orders directly from Weyland-Yutani!"))
		arm_equipment(H, "Weyland-Yutani Deathsquad Leader", TRUE, TRUE)
	else if(medics < max_medics)
		medics++
		to_chat(H, SPAN_ROLE_HEADER("You are a Deathsquad Medic!"))
		to_chat(H, SPAN_ROLE_BODY("You must clear out any traces of the infestation and its survivors."))
		to_chat(H, SPAN_ROLE_BODY("Follow any orders directly from Weyland-Yutani!"))
		arm_equipment(H, "Weyland-Yutani Deathsquad Medic", TRUE, TRUE)
	else if(heavies < max_heavies)
		heavies++
		to_chat(H, SPAN_ROLE_HEADER("You are a Deathsquad Terminator!"))
		to_chat(H, SPAN_ROLE_BODY("You must clear out any traces of the infestation and its survivors."))
		to_chat(H, SPAN_ROLE_BODY("Follow any orders directly from Weyland-Yutani!"))
		arm_equipment(H, "Weyland-Yutani Deathsquad Terminator", TRUE, TRUE)
	else
		to_chat(H, SPAN_ROLE_HEADER("You are a Deathsquad Commando!"))
		to_chat(H, SPAN_ROLE_BODY("You must clear out any traces of the infestation and its survivors."))
		to_chat(H, SPAN_ROLE_BODY("Follow any orders directly from Weyland-Yutani!"))
		arm_equipment(H, "Weyland-Yutani Deathsquad", TRUE, TRUE)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, H, SPAN_BOLD("Objectives: [objectives]")), 1 SECONDS)

// MARSOC commandos - USCM Deathsquad. Event only
/datum/emergency_call/marsoc
	name = "MARSOC Operatives"
	mob_max = 8
	mob_min = 5
	probability = 0
	shuttle_id = "Distress_PMC"
	name_of_spawn = "Distress_PMC"

	var/operator_team_designation
	var/curr_operator_number = 1

// DEATH SQUAD--------------------------------------------------------------------------------
/datum/emergency_call/marsoc/create_member(datum/mind/M)

	if (!operator_team_designation)
		operator_team_designation = pick(nato_phonetic_alphabet)

	var/turf/spawn_loc = get_spawn_point()

	if(!istype(spawn_loc))
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/H = new(spawn_loc)
	M.transfer_to(H, TRUE)
	H.set_skills(/datum/skills/commando/deathsquad)

	var/operator_name = "[operator_team_designation]-[curr_operator_number]"
	H.change_real_name(H, operator_name)

	to_chat(H, SPAN_WARNING(FONT_SIZE_BIG("You are an elite MARSOC Operative, the best of the best.")))
	to_chat(H, "<B> You are absolutely loyal to High Command and must follow their directives.</b>")
	to_chat(H, "<B> Execute the mission assigned to you with extreme prejudice!</b>")
	arm_equipment(H, "MARSOC Operator", TRUE, TRUE)

	curr_operator_number++
	return
