/*
Each human has an agent_holder, which contains this datum if they're an Agent, otherwise null.

Creating an agent:
	Make a new /datum/agent(human mob) with a human mob as args, 
	if given a faction as a second arg, the agent will be of that faction, else random,
	The agent is added to a global list human_agent_list

Giving objectives to an agent:
	Call give_objective(), 
	if given an arg of an objective typepath, it will be that objective else random
*/

/datum/agent
	var/mob/living/carbon/human/source_human
	var/obj/item/device/portable_vendor/antag/tools
	var/faction = FACTION_WY

	var/objectives_list

/datum/agent/New(var/mob/living/carbon/human/H, var/chosen_faction, var/start_with_objective = TRUE)
	. = ..()
	if(!istype(H))
		qdel(src)

	source_human = H
	source_human.agent_holder = src

	if(!isnull(chosen_faction))
		faction = chosen_faction
	else
		faction = pick(FACTION_LIST_AGENT)

	generate_message()

	log_game("[key_name(usr)] has been made an agent.")

	LAZYADD(human_agent_list, source_human)

	if(source_human.skills)
		source_human.skills.set_skill(SKILL_ANTAG, SKILL_ANTAG_TRAINED)
		source_human.skills.set_skill(SKILL_FIREARMS, SKILL_FIREARMS_DEFAULT)

	if(start_with_objective)
		give_objective()

	receive_tools()
	apply_hud()

/datum/agent/proc/receive_tools()
	tools = new(source_human.loc, src)
	tools.faction_belonging = faction

	if(!source_human.equip_to_slot_if_possible(tools, WEAR_IN_BACK))
		// Failed, trying to put in hands else drop
		if(!source_human.put_in_any_hand_if_possible(tools))
			tools.loc = source_human.loc

/datum/agent/proc/generate_message()
	var/faction_name = "Weston-Yamada"
	switch(faction)
		if(FACTION_RESS)
			faction_name = "Royal Empire of the Shining Sun"
		if(FACTION_UPP)
			faction_name = "Union of Progressive Peoples"
		if(FACTION_CLF)
			faction_name = "Colonial Liberation Front"

	var/text = {"
		[SPAN_ROLE_BODY("|______________________|")]
		[SPAN_ROLE_HEADER("You are an agent working for [faction_name].")]
		[SPAN_ROLE_BODY("[faction_name] will periodically assign you new objectives, that you must complete in their interest. \
			DO NOT under any circumstances kill people unless properly escalated, the situation is tense and we cannot risk another war breaking out. \
			You may seek out other agents of [faction_name], you will know them when you see them.")]
		[SPAN_ROLE_BODY("|______________________|")]
		"}
	to_chat(source_human, text)

/datum/agent/proc/apply_hud()
	var/hud_name = MOB_HUD_FACTION_WY
	switch(faction)
		if(FACTION_RESS)
			hud_name = MOB_HUD_FACTION_RESS
		if(FACTION_UPP)
			hud_name = MOB_HUD_FACTION_UPP
		if(FACTION_CLF)
			hud_name = MOB_HUD_FACTION_CLF

	var/datum/mob_hud/H = huds[hud_name]
	H.add_hud_to(source_human)
	H.add_to_hud(source_human)

	var/image/holder = source_human.hud_list[FACTION_HUD]
	holder.icon_state = "hud[faction]"

/datum/agent/proc/give_objective(var/objective_type)
	var/typepath = pick(OBJECTIVES_TO_PICK_FROM)
	if(ispath(objective_type, /datum/agent_objective))
		typepath = objective_type

	var/datum/action/human_action/activable/receive_objective/transmission = new()
	transmission.objective_to_receive = typepath

	transmission.give_action(source_human)

/datum/agent/Destroy()
	. = ..()
	
	source_human.agent_holder = null

	if(objectives_list)
		for(var/datum/agent_objective/O in objectives_list)
			O.belonging_to_agent = null
			qdel(O)


/datum/action/human_action/activable/receive_objective
	name = "Receive Incoming Transmission"
	var/objective_to_receive

	action_icon_state = "antag_objective_receive"

/datum/action/human_action/activable/receive_objective/can_use_action()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/H = owner
	if(!H.agent_holder)
		return FALSE

	if(!objective_to_receive)
		return FALSE

	return TRUE

/datum/action/human_action/activable/receive_objective/action_activate()
	if(alert(owner, "Are you sure you want to receive your next objective?", "Receive Objective", "Yes", "No") == "No")
		return

	if(!can_use_action())
		return

	var/mob/living/carbon/human/H = owner

	ai_silent_announcement("SUSPICIOUS TRANSMISSION DETECTED.", ":p")

	LAZYADD(H.agent_holder.objectives_list, new objective_to_receive(H.agent_holder))

	remove_action(H)