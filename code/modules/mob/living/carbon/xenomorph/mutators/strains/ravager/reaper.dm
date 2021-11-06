/datum/xeno_mutator/reaper
	name = "STRAIN: Ravager - Reaper"
	description = "You trade some of your health for more speed and the ability to tranform into two stronger forms. Each form gives some movement speed and attack speed. The final form also gives extra delimb chance. You gain forms by either slashing your enemies or by sacrificing some of your own blood."
	flavor_description = "You are the claw of the Queen. Those who stand against you meet their death."
	cost = MUTATOR_COST_EXPENSIVE
	individual_only = TRUE
	caste_whitelist = list(XENO_CASTE_RAVAGER)
	mutator_actions_to_remove = list(
		/datum/action/xeno_action/activable/empower,
		/datum/action/xeno_action/activable/pounce/charge,
		/datum/action/xeno_action/activable/scissor_cut,
	)
	mutator_actions_to_add = list(
		/datum/action/xeno_action/activable/pounce/leap,
		/datum/action/xeno_action/activable/blood_sacrifice,
		/datum/action/xeno_action/activable/repose,
	)
	keystone = TRUE
	behavior_delegate_type = /datum/behavior_delegate/ravager_reaper

/datum/xeno_mutator/reaper/apply_mutator(datum/mutator_set/individual_mutators/MS)
	. = ..()
	if (. == 0)
		return

	var/mob/living/carbon/Xenomorph/Ravager/R = MS.xeno
	R.mutation_type = RAVAGER_REAPER
	R.plasma_max = 0
	R.health_modifier -= XENO_HEALTH_MOD_REAPER
	R.speed_modifier += XENO_SPEED_FASTMOD_TIER_3

	mutator_update_actions(R)
	MS.recalculate_actions(description, flavor_description)

	apply_behavior_holder(R)

	R.recalculate_everything()

// Mutator delegate for Reaper ravager
/datum/behavior_delegate/ravager_reaper
	name = "Reaper Ravager Behavior Delegate"

	var/form = 0
	var/form_timer_id = TIMER_ID_NULL
	var/form1_speed_modifier = 0.3
	var/form2_speed_modifier = 0.4
	var/form1_attack_speed_modifier = 0.6
	var/form2_attack_speed_modifier = 0.6

	// Bloodlust config
	var/max_bloodlust = 3
	var/bloodlust_decay_time = 30 // How many deciseconds between slashes until we start to decay bloodlust
	var/bloodlust = 0
	var/bloodlust_cooldown_start_time = 0
	var/last_slash_time = 0

/datum/behavior_delegate/ravager_reaper/proc/reaper_form()
	if(form_timer_id != TIMER_ID_NULL)
		deltimer(form_timer_id)
		form_timer_id = TIMER_ID_NULL
	form_timer_id = addtimer(CALLBACK(src, /datum/behavior_delegate/ravager_reaper/proc/remove_reaper_form), 10 SECONDS, TIMER_STOPPABLE)
	var/datum/action/xeno_action/activable/pounce/leap/cAction = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/leap)
	if (!cAction.action_cooldown_check())
		cAction.reduce_cooldown(14 SECONDS)

	var/color = "#fc4e03"
	var/alpha = 70
	color += num2text(alpha, 2, 16)
	if(form == 0)
		bound_xeno.visible_message(SPAN_DANGER("[bound_xeno] suddenly starts glowing in earie orange!"), SPAN_XENODANGER("The hour is near and your power grows!"))
		bound_xeno.add_filter("empower_rage", 1, list("type" = "outline", "color" = color, "size" = 2))
		bound_xeno.attack_speed_modifier -= form1_attack_speed_modifier
		bound_xeno.speed_modifier -= form1_speed_modifier
		bound_xeno.recalculate_speed()
		form = 1
	else if(form == 1)
		bound_xeno.visible_message(SPAN_DANGER("glow gets even stronger!"), SPAN_XENODANGER("You have reached your final form! Rejoice, for it is time for the Reckoning!"))
		bound_xeno.add_filter("empower_rage", 1, list("type" = "outline", "color" = color, "size" = 3))
		bound_xeno.attack_speed_modifier -= form2_attack_speed_modifier
		bound_xeno.speed_modifier -= form2_speed_modifier
		bound_xeno.recalculate_speed()
		form = 2

/datum/behavior_delegate/ravager_reaper/proc/remove_reaper_form()
	if(form > 0)
		bound_xeno.visible_message(SPAN_DANGER("[bound_xeno]'s glow slowly dims."), SPAN_XENODANGER("Your glow fades away and so does your power. Time to rest, my child."))
	bound_xeno.remove_filter("empower_rage")
	bound_xeno.attack_speed_modifier = 0
	bound_xeno.speed_modifier = 0 + XENO_SPEED_FASTMOD_TIER_3
	bound_xeno.recalculate_speed()
	form = 0

/datum/behavior_delegate/ravager_reaper/melee_attack_additional_effects_target(mob/living/carbon/A)
	if (!isXenoOrHuman(A))
		return

	var/mob/living/carbon/H = A
	if (form == 2 && !iszombie(H) && prob(isYautja(H)?2.5:5)) // lets halve this for preds
		var/obj/limb/L = H.get_limb(check_zone(bound_xeno.zone_selected))
		if (L.body_part != BODY_FLAG_CHEST && L.body_part != BODY_FLAG_GROIN && L.body_part != BODY_FLAG_HEAD && L.brute_dam > 25) //Only limbs.
			L.droplimb()

/datum/behavior_delegate/ravager_reaper/melee_attack_additional_effects_self()
	..()

	if (bloodlust != max_bloodlust && !bloodlust_cooldown_start_time)
		bloodlust = bloodlust + 1
		last_slash_time = world.time

		if (bloodlust == max_bloodlust)
			bloodlust = 0
			reaper_form()

/datum/behavior_delegate/ravager_reaper/append_to_stat()
	. = list()
	. += "Bloodlust: [bloodlust]/[max_bloodlust]"

/datum/behavior_delegate/ravager_reaper/on_life()
	// Compute our current bloodlust (demerit if necessary)
	if (((last_slash_time + bloodlust_decay_time) < world.time) && !(bloodlust <= 0))
		decrement_bloodlust()

// Handles internal state from decrementing bloodlust
/datum/behavior_delegate/ravager_reaper/proc/decrement_bloodlust(amount = 1)
	var/real_amount = amount
	if (amount > bloodlust)
		real_amount = bloodlust

	bloodlust -= real_amount
	return

/datum/behavior_delegate/ravager_reaper/proc/blood_sacrifice()
	bound_xeno.adjustBruteLoss(170)
	bound_xeno.updatehealth()
	reaper_form()

/datum/behavior_delegate/ravager_reaper/proc/repose()
	bound_xeno.armor_modifier += 10
	bound_xeno.recalculate_armor()
	addtimer(CALLBACK(src, .proc/repose_callback, form), 4 SECONDS)
	remove_reaper_form()
	var/datum/action/xeno_action/activable/pounce/leap/cAction = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/leap)
	cAction.apply_cooldown_override(14 SECONDS)
	var/datum/action/xeno_action/activable/blood_sacrifice/sAction = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/blood_sacrifice)
	sAction.apply_cooldown_override(6 SECONDS)
	bloodlust_cooldown_start_time = world.time

/datum/behavior_delegate/ravager_reaper/proc/repose_callback(previous_form)
	bound_xeno.xeno_jitter(1 SECONDS)
	bound_xeno.flick_heal_overlay(3 SECONDS, "#fc4e03")
	if(previous_form == 1)
		bound_xeno.gain_health(140)
	else if(previous_form == 2)
		bound_xeno.gain_health(200)
	else
		bound_xeno.gain_health(80)
	bound_xeno.updatehealth()
	bound_xeno.armor_modifier -= 10
	bound_xeno.recalculate_armor()
	bloodlust_cooldown_start_time = 0
