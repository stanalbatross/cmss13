var/global/datum/controller/goals/goals_controller

#define GOALS_COST_CHEAP	100
#define GOALS_COST_MODERATE	250
#define GOALS_COST_PRICEY	500

#define GOALS_POINT_GAIN 100
#define GOALS_POINT_MODIFIER 10
#define GOALS_PROGRESS_INCREASE 0.05

/datum/controller/goals
	name = "Goals Level Accounting"
	var/current_goals_progress = 0
	var/last_objectives_scored_points = 0
	var/last_objectives_total_points = 0
	var/last_objectives_completion_percentage = 0

	var/list/purchased_rewards = list()

	var/remaining_reward_points = GOALS_POINT_GAIN

	//Probability for spawn objectives
	var/close_obj_prob = 50		//50%
	var/medium_obj_prob = 25	//25%
	var/far_obj_prob = 15		//15%
	var/science_obj_prob = 10	//10%

/datum/controller/goals/proc/check_goals_percentage()
	if(current_goals_progress == 1)
		return "MAXIMUM"
	else
		return last_objectives_completion_percentage

/datum/controller/goals/proc/add_rewards_points(var/amount)
	remaining_reward_points += amount

/datum/controller/goals/proc/goals_level()
	if(current_goals_progress < 1)
		current_goals_progress += GOALS_PROGRESS_INCREASE
		remaining_reward_points += GOALS_POINT_GAIN + (GOALS_POINT_GAIN*(current_goals_progress*GOALS_POINT_MODIFIER))
		chemical_data.update_credits(4*round(goals_controller.current_goals_progress*GOALS_POINT_MODIFIER, 1))

/datum/controller/goals/proc/check_goals_complition()
	var/list/objectives_status = SSgoals.get_objective_completion_stats()
	last_objectives_scored_points = objectives_status["scored_points"]
	last_objectives_total_points = objectives_status["total_points"]
	last_objectives_completion_percentage = last_objectives_scored_points / last_objectives_total_points

	if(current_goals_progress < 1)
		if(last_objectives_scored_points > (current_goals_progress + GOALS_PROGRESS_INCREASE))
			goals_level()

/datum/controller/goals/proc/list_and_purchase_rewards()
	var/list/rewards_for_purchase = available_rewards()
	if(rewards_for_purchase.len == 0)
		to_chat(usr, "No additional assets have been authorised at this point.")
	var/pick = tgui_input_list(usr, "Which asset would you like to enable?", "Enable asset", rewards_for_purchase)
	if(!pick)
		return
	if(GLOB.goals_reward_list[pick].apply_reward(src))
		to_chat(usr, "Asset granted!")
		GLOB.goals_reward_list[pick].announce_reward()
	else
		to_chat(usr, "Asset granting failed!")
	return

//Lists rewards available for purchase
/datum/controller/goals/proc/available_rewards()
	var/list/can_purchase = list()
	if(!remaining_reward_points) //No points - can't buy anything
		return can_purchase

	for(var/str in GLOB.goals_reward_list)
		if (can_purchase_reward(GLOB.goals_reward_list[str]))
			can_purchase += str //can purchase!

	return can_purchase

/datum/controller/goals/proc/can_purchase_reward(var/datum/goals_reward/dr)
	if(current_goals_progress > dr.minimum_goals_progress)
		return FALSE //required goals level not reached
	if(remaining_reward_points < dr.cost)
		return FALSE //reward is too expensive
	if(dr.unique)
		if(dr.name in purchased_rewards)
			return FALSE //unique reward already purchased
	return TRUE

//A class for rewarding the next goals level being reached
/datum/goals_reward
	var/name = "Reward"
	var/cost = null //Cost to get this reward
	var/minimum_goals_progress = 0 //goals needs to be at this level or LOWER
	var/unique = FALSE //Whether the reward is unique or not
	var/announcement_message = "YOU SHOULD NOT BE SEEING THIS MESSAGE. TELL A DEV." //Message to be shared after a reward is purchased

/datum/goals_reward/proc/announce_reward()
	//Send ARES message about special asset authorisation
	var/name = "ALMAYER SPECIAL ASSETS AUTHORISED"
	marine_announcement(announcement_message, name, 'sound/misc/notice2.ogg')

/datum/goals_reward/New()
	. = ..()
	name = "($[cost * GOALS_TO_MONEY_MULTIPLIER]) [name]"

/datum/goals_reward/proc/apply_reward(var/datum/controller/goals/d)
	if(d.remaining_reward_points < cost)
		return 0
	d.remaining_reward_points -= cost
	d.purchased_rewards += name
	return 1

/datum/goals_reward/supply_points
	name = "Additional Supply Budget"
	cost = GOALS_COST_MODERATE
	minimum_goals_progress = 0.1
	announcement_message = "Additional Supply Budget has been authorised for this operation."



/datum/goals_reward/supply_points/apply_reward(var/datum/controller/goals/d)
	. = ..()
	if(. == 0)
		return
	supply_controller.points += 800

/datum/goals_reward/dropship_part_fabricator_points
	name = "Additional Dropship Part Fabricator Points"
	cost = GOALS_COST_MODERATE
	minimum_goals_progress = 0.25
	announcement_message = "Additional Dropship Part Fabricator Points have been authorised for this operation."

/datum/goals_reward/dropship_part_fabricator_points/apply_reward(var/datum/controller/goals/d)
	. = ..()
	if(. == 0)
		return
	supply_controller.dropship_points += 2800 //Enough for both fuel enhancers, or about 3.5 fatties

/datum/goals_reward/ob_he
	name = "Additional OB projectiles - HE x2"
	cost = GOALS_COST_CHEAP
	minimum_goals_progress = 0.1
	announcement_message = "Additional Orbital Bombardment ordnance (HE, count:2) have been delivered to Requisitions' ASRS."

/datum/goals_reward/ob_he/apply_reward(var/datum/controller/goals/d)
	. = ..()
	if(. == 0)
		return

	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = supply_controller.ordernum
	supply_controller.ordernum++
	O.object = supply_controller.supply_packs["OB HE Crate"]
	O.orderedby = MAIN_AI_SYSTEM

	supply_controller.shoppinglist += O

/datum/goals_reward/ob_cluster
	name = "Additional OB projectiles - Cluster x2"
	cost = GOALS_COST_CHEAP
	minimum_goals_progress = 0.1
	announcement_message = "Additional Orbital Bombardment ordnance (Cluster, count:2) have been delivered to Requisitions' ASRS."

/datum/goals_reward/ob_cluster/apply_reward(var/datum/controller/goals/d)
	. = ..()
	if(. == 0)
		return

	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = supply_controller.ordernum
	supply_controller.ordernum++
	O.object = supply_controller.supply_packs["OB Cluster Crate"]
	O.orderedby = MAIN_AI_SYSTEM

	supply_controller.shoppinglist += O

/datum/goals_reward/ob_incendiary
	name = "Additional OB projectiles - Incendiary x2"
	cost = GOALS_COST_CHEAP
	minimum_goals_progress = 0.1
	announcement_message = "Additional Orbital Bombardment ordnance (Incendiary, count:2) have been delivered to Requisitions' ASRS."

/datum/goals_reward/ob_incendiary/apply_reward(var/datum/controller/goals/d)
	. = ..()
	if(. == 0)
		return

	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = supply_controller.ordernum
	supply_controller.ordernum++
	O.object = supply_controller.supply_packs["OB Incendiary Crate"]
	O.orderedby = MAIN_AI_SYSTEM

	supply_controller.shoppinglist += O

/datum/goals_reward/chemical_points
	name = "Points for researchers"
	cost = GOALS_COST_PRICEY
	minimum_goals_progress = 0.25
	announcement_message = "Additional points to researchers gived."

/datum/goals_reward/chemical_points/apply_reward(var/datum/controller/goals/d)
	if (!SSticker.mode)
		return

	. = ..()
	if(. == 0)
		return

	chemical_data.update_credits(4*round(goals_controller.current_goals_progress*GOALS_POINT_MODIFIER, 1))




//CONSOLE
/obj/structure/machinery/computer/supply_goals
	name = "supply goals control console"
	desc = "This is used for controlling supply goals and its related functions."
	icon_state = "comm_alt"
	req_access = list()
	unslashable = TRUE
	unacidable = TRUE

/obj/structure/machinery/computer/supply_goals/attack_remote(var/mob/user as mob)
	return attack_hand(user)

/obj/structure/machinery/computer/supply_goals/attack_hand(var/mob/user as mob)
	if(..() || !allowed(user) || inoperable())
		return

	ui_interact(user)

/obj/structure/machinery/computer/supply_goals/ui_interact(mob/user as mob)
	user.set_interaction(src)

	var/dat = "<head><title>Supply Goals Control Console</title></head><body>"

	dat += "<BR><hr>"
	dat += "<BR>PROGRESS [goals_controller.check_goals_percentage()]%"
	dat += "<BR>Threat assessment level: [goals_controller.last_objectives_completion_percentage*100]%"
	dat += "<BR>Remaining DEFCON asset budget: $[goals_controller.remaining_reward_points * GOALS_TO_MONEY_MULTIPLIER]."
	dat += "<BR><A href='?src=\ref[src];operation=defcon'>Activate Actives</A>"
	dat += "<BR><hr>"

	dat += "<BR><A HREF='?src=\ref[user];mach_close=supply_goals_control'>Close</A>"

	show_browser(user, dat, name, "supply_goals_control")
	onclose(user, "supply_goals_control")

/obj/structure/machinery/computer/supply_goals/Topic(href, href_list)
	if(..())
		return FALSE

	usr.set_interaction(src)

	switch(href_list["operation"])
		if("defcon")
			goals_controller.list_and_purchase_rewards()
			return

	updateUsrDialog()