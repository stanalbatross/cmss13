//****************************************************
//				EXTERNAL ORGANS
//****************************************************/
/obj/limb
	name = "limb"
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_DIR
	var/icon_name = null
	var/body_part = null
	var/icon_position = 0
	var/damage_state = "=="
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/max_size = 0
	var/last_dam = -1
	var/display_name

	var/tmp/perma_injury = 0

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood

	var/obj/limb/parent
	var/list/obj/limb/children

	// Internal organs of this body part
	var/list/datum/internal_organ/internal_organs

	var/damage_msg = "<span class='danger'>You feel an intense pain</span>"

	var/surgery_open_stage = 0
	var/bone_repair_stage = 0
	var/limb_replacement_stage = 0
	var/cavity = 0

	var/in_surgery_op = FALSE //whether someone is currently doing a surgery step to this limb
	var/surgery_organ //name of the organ currently being surgically worked on (detach/remove/etc)

	var/encased       // Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	var/list/implants = list()
	var/artery_name = "artery"

	var/status //limb status flags

	var/mob/living/carbon/human/owner = null
	var/vital //Lose a vital limb, die immediately.

	var/has_stump_icon = FALSE
	var/image/wound_overlay //Used to save time redefining it every wound update. Doesn't remember anything but the most recently used icon state.

	// Integrity mechanic vars
	var/list/bleeding_effects_list = list()
	var/integrity_level = 0

	var/brute_autoheal = 0.02 //per life tick
	var/burn_autoheal = 0.04
	var/integrity_autoheal = 0.1
	var/can_autoheal = TRUE
	var/integrity_damage = 0
	var/last_dam_time = 0

	var/natural_int_dmg_resist = 0.8 // less = better


/obj/limb/Initialize(mapload, obj/limb/P, mob/mob_owner)
	. = ..()
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	if(mob_owner)
		owner = mob_owner

	wound_overlay = image('icons/mob/humans/dam_human.dmi', "grayscale_[0]")
	wound_overlay.blend_mode = BLEND_INSET_OVERLAY
	wound_overlay.color = owner.species.blood_color

	forceMove(mob_owner)



/*
/obj/limb/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")
*/

/obj/limb/process()
		return 0

/obj/limb/Destroy()
	if(parent)
		parent.children -= src
	parent = null
	if(children)
		for(var/obj/limb/L in children)
			L.parent = null
		children = null

	if(hidden)
		qdel(hidden)
		hidden = null

	if(internal_organs)
		for(var/datum/internal_organ/IO in internal_organs)
			IO.owner = null
			qdel(IO)
		internal_organs = null

	if(implants)
		for(var/I in implants)
			qdel(I)
		implants = null

	if(bleeding_effects_list)
		for(var/datum/effects/bleeding/B in bleeding_effects_list)
			qdel(B)
		bleeding_effects_list = null

	if(owner && owner.limbs)
		owner.limbs -= src
		owner.limbs_to_process -= src
		owner.update_body()
	owner = null

	return ..()

//Autopsy stuff

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/obj/limb/O = pick(limbs)
		O.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/obj/limb/proc/add_autopsy_data(var/used_weapon, var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time



/*
			DAMAGE PROCS
*/

/obj/limb/emp_act(severity)
	if(!(status & LIMB_ROBOT))	//meatbags do not care about EMP
		return
	var/probability = 30
	var/damage = 15
	if(severity == 2)
		probability = 1
		damage = 3
	if(prob(probability))
		droplimb(0, 0, "EMP")
	else
		take_damage(damage, 0, 1, 1, used_weapon = "EMP")

/*
	Describes how limbs (body parts) of human mobs get damage applied.
	Less clear vars:
	*	impact_name: name of an "impact icon." For now, is only relevant for projectiles but can be expanded to apply to melee weapons with special impact sprites.
*/
/obj/limb/proc/take_damage(brute, burn, int_dmg_multiplier = 1, used_weapon = null, list/forbidden_limbs = list(), no_limb_loss, impact_name = null, var/damage_source = "dismemberment", var/mob/attack_source = null)
	if((brute <= 0) && (burn <= 0))
		return 0

	if(status & LIMB_DESTROYED)
		return 0

	var/is_ff = FALSE
	if(istype(attack_source) && attack_source.faction == owner.faction)
		is_ff = TRUE

	if((owner.stat != DEAD))
		var/int_conversion = owner.skills ? min(0.7, 1 - owner.skills.get_skill_level(SKILL_ENDURANCE) / 10) : 0.7
		take_integrity_damage(brute * int_conversion * int_dmg_multiplier * owner.int_dmg_malus * natural_int_dmg_resist) //Need to adjust to skills and armor

	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)


	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	if((brute_dam + burn_dam + brute + burn) < max_damage || !CONFIG_GET(flag/limbs_can_break))
		if(brute)
			brute_dam += brute
		if(burn)
			burn_dam += burn
	else
		//If we can't inflict the full amount of damage, spread the damage in other ways
		//How much damage can we actually cause?
		var/can_inflict = max_damage * CONFIG_GET(number/organ_health_multiplier) - (brute_dam + burn_dam)
		var/remain_brute = brute
		var/remain_burn = burn
		if(can_inflict)
			if(brute > 0)
				//Inflict all brute damage we can
				brute_dam += min(brute, can_inflict)
				var/temp = can_inflict
				//How much more damage can we inflict
				can_inflict = max(0, can_inflict - brute)
				//How much brute damage is left to inflict
				remain_brute = max(0, brute - temp)

			if(burn > 0 && can_inflict)
				//Inflict all burn damage we can
				burn_dam += min(burn,can_inflict)
				//How much burn damage is left to inflict
				remain_burn = max(0, burn - can_inflict)

		//If there are still hurties to dispense
		if(remain_burn || remain_brute)
			//List organs we can pass it to
			var/list/obj/limb/possible_points = list()
			if(parent)
				possible_points += parent
			if(children)
				possible_points += children
			if(forbidden_limbs.len)
				possible_points -= forbidden_limbs
			if(possible_points.len)
				//And pass the damage around, but not the chance to cut the limb off.
				var/obj/limb/target = pick(possible_points)
				target.take_damage(remain_brute, remain_burn, int_dmg_multiplier , used_weapon, forbidden_limbs + src, TRUE, attack_source = attack_source)

	SEND_SIGNAL(src, COMSIG_LIMB_TAKEN_DAMAGE, is_ff)


	/*
	//If limb was damaged before and took enough damage, try to cut or tear it off
	var/no_perma_damage = owner.status_flags & NO_PERMANENT_DAMAGE
	if(old_brute_dam > 0 && !is_ff && body_part != BODY_FLAG_CHEST && !no_limb_loss && !no_perma_damage)
		droplimb(0, 0, damage_source)
		return
	*/

	last_dam_time = world.time
	owner.updatehealth()
	update_icon()
	start_processing()

/obj/limb/proc/take_integrity_damage(amount)
	integrity_damage = max(min(integrity_damage + amount, MAX_LIMB_INTEGRITY),0)
	recalculate_integrity_level()

/obj/limb/proc/recalculate_integrity()
	recalculate_health_effects()
	recalculate_integrity_level()

/obj/limb/proc/recalculate_integrity_level()
	var/old_level = integrity_level
	integrity_level = 0
	if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_OKAY)
		integrity_level++
		if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_CONCERNING)
			integrity_level++
			if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_SERIOUS)
				integrity_level++
				if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_CRITICAL)
					integrity_level++

	if(integrity_level == old_level)
		return

	if(integrity_level > old_level)
		on_integrity_tier_increased(old_level)
	else
		on_integrity_tier_lowered(old_level)

//Set damage to the desired level's threshold, so when the effects are recalculated
//the level is set
/obj/limb/proc/set_integrity_level(new_level)
	switch(new_level)
		if(LIMB_INTEGRITY_OKAY)
			integrity_damage = LIMB_INTEGRITY_THRESHOLD_OKAY
		if(LIMB_INTEGRITY_CONCERNING)
			integrity_damage = LIMB_INTEGRITY_THRESHOLD_CONCERNING
		if(LIMB_INTEGRITY_SERIOUS)
			integrity_damage = LIMB_INTEGRITY_THRESHOLD_SERIOUS
		if(LIMB_INTEGRITY_CRITICAL)
			integrity_damage = LIMB_INTEGRITY_THRESHOLD_CRITICAL
		if(LIMB_INTEGRITY_NONE)
			integrity_damage = LIMB_INTEGRITY_THRESHOLD_CRITICAL
		else
			integrity_damage = LIMB_INTEGRITY_THRESHOLD_PERFECT
	recalculate_integrity()

//This proc handles what happens when integrity increase, including when limb wounds are added
/obj/limb/proc/on_integrity_tier_increased(old_level)
	SEND_SIGNAL(src, COMSIG_LIMB_INTEGRITY_INCREASED, old_level)
	
	switch(integrity_level)
		if(LIMB_INTEGRITY_OKAY)
			playsound(owner, 'sound/effects/bone_break2.ogg', 45, 1)
			to_chat(owner, SPAN_WARNING("Your [display_name] starts to ache, but it's nothing to worry about."))
		if(LIMB_INTEGRITY_CONCERNING)
			playsound(owner, 'sound/effects/bone_break4.ogg', 45, 1)
			to_chat(owner, SPAN_DANGER("Your [display_name] hurts badly from the wounds; but you can definitely continue fighting."))
		if(LIMB_INTEGRITY_SERIOUS)
			playsound(owner, 'sound/effects/bone_break6.ogg', 45, 1)
			to_chat(owner, SPAN_DANGER("Your [display_name] is in pain; all you can see is blood, cuts and rips littered all over it. The only thing stopping you is your resolve and hubris."))
		if(LIMB_INTEGRITY_CRITICAL)
			playsound(owner, 'sound/effects/bone_break1.ogg', 45, 1)
			to_chat(owner, SPAN_HIGHDANGER("Your [display_name] feels like hell, only hanging on by threads of flesh and sinew. You sure you want to continue fighting?"))
		if(LIMB_INTEGRITY_NONE)
			playsound(owner, 'sound/effects/limb_gore.ogg', 45, 1)
			to_chat(owner, SPAN_HIGHDANGER("You can't feel your [display_name]. It's gone, and all that's left is blood and gore."))

	if(integrity_level >= LIMB_INTEGRITY_CONCERNING && old_level < LIMB_INTEGRITY_CONCERNING)
		owner.add_limb_wound(/datum/limb_wound/fracture, src, LIMB_INTEGRITY_CONCERNING)
		to_chat(owner, SPAN_HIGHDANGER("Something feels like it shattered in your [display_name], fragments ripping all over it!"))

//This proc doesn't necessarily need to handle removing limb wounds, as they remove themselves when integrity is below their assigned level
/obj/limb/proc/on_integrity_tier_lowered(old_level)
	SEND_SIGNAL(src, COMSIG_LIMB_INTEGRITY_LOWERED, old_level)

/mob/living/carbon/human/proc/add_limb_wound(wound_type, limb, integrity_level)
	for(var/datum/limb_wound/W in limb_wounds)
		if(W.type == wound_type)
			qdel(W)
			break
	new wound_type(src, limb, integrity_level)

/mob/living/carbon/human/proc/get_limb_wounds_by_limb()
	var/list/wounds_by_limbs = list()
	for(var/datum/limb_wound/W in limb_wounds)
		LAZYADD(wounds_by_limbs[W.affected_limb.name], W)
	return wounds_by_limbs

/obj/limb/proc/recalculate_health_effects()
	if(can_autoheal)
		brute_autoheal = initial(brute_autoheal)
		burn_autoheal = initial(burn_autoheal)
		integrity_autoheal = initial(integrity_autoheal)
	else
		brute_autoheal = 0
		burn_autoheal = 0
		integrity_autoheal = 0

/obj/limb/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(status & LIMB_ROBOT && !robo_repair)
		return

	if(brute)
		remove_all_bleeding(TRUE)

	if(internal)
		remove_all_bleeding(FALSE, TRUE)

	brute_dam = max(0, brute_dam - brute)
	burn_dam = max(0, burn_dam - burn)

	owner.pain.apply_pain(brute)
	owner.pain.apply_pain(burn)

	if(internal)
		status |= LIMB_REPAIRED
		perma_injury = 0


	owner.updatehealth()

	update_icon()

/*
This function completely restores a damaged organ to perfect condition.
*/
/obj/limb/proc/rejuvenate()
	damage_state = "=="
	if(status & LIMB_ROBOT)	//Robotic organs stay robotic.  Fix because right click rejuvinate makes IPC's organs organic.
		status = LIMB_ROBOT
	else
		status = 0
	perma_injury = 0
	brute_dam = 0
	burn_dam = 0

	// heal internal organs
	for(var/datum/internal_organ/current_organ in internal_organs)
		current_organ.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in implants)
		if(!istype(implanted_object,/obj/item/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.forceMove(owner.loc)
			implants -= implanted_object
			if(is_sharp(implanted_object) || istype(implanted_object, /obj/item/shard/shrapnel))
				owner.embedded_items -= implanted_object

	owner.pain.recalculate_pain()
	owner.updatehealth()
	owner.update_body()
	update_icon()

/obj/limb/proc/add_bleeding(var/W, var/internal = FALSE)
	if(!(SSticker.current_state >= GAME_STATE_PLAYING)) //If the game hasnt started, don't add bleed. Hacky fix to avoid having 100 bleed effect from roundstart.
		return

	if(status & LIMB_ROBOT)
		return

	if(bleeding_effects_list.len)
		if(!internal)
			for(var/datum/effects/bleeding/external/B in bleeding_effects_list)
				B.add_on(W)
				return
		else
			for(var/datum/effects/bleeding/internal/B in bleeding_effects_list)
				B.add_on(30)
				return

	var/datum/effects/bleeding/bleeding_status

	if(internal)
		bleeding_status = new /datum/effects/bleeding/internal(owner, src, (max(40, brute_dam)+ (0.15 * integrity_damage)))
	else
		bleeding_status = new /datum/effects/bleeding/external(owner, src, W)

	bleeding_effects_list += bleeding_status

/obj/limb/proc/remove_all_bleeding(var/external = FALSE, var/internal = FALSE)
	if(external)
		for(var/datum/effects/bleeding/external/B in bleeding_effects_list)
			qdel(B)
		for(var/datum/effects/bleeding/arterial/A in bleeding_effects_list)
			qdel(A)

	if(internal)
		for(var/datum/effects/bleeding/internal/I in bleeding_effects_list)
			qdel(I)


/*
			PROCESSING & UPDATING
*/

//Determines if we even need to process this organ.

/obj/limb/proc/need_process()
	if(status & LIMB_DESTROYED)	//Missing limb is missing
		return 0
	if(status && !(status & LIMB_ROBOT) && !(status & LIMB_REPAIRED)) // Any status other than destroyed or robotic requires processing
		return 1
	if(brute_dam || burn_dam)
		return 1
	if(last_dam != brute_dam + burn_dam) // Process when we are fully healed up.
		last_dam = brute_dam + burn_dam
		return 1
	else
		last_dam = brute_dam + burn_dam

	return 0

/obj/limb/process()
	if(!brute_dam && !burn_dam && !integrity_damage)
		return
	if(world.time - last_dam_time < MINIMUM_AUTOHEAL_DAMAGE_INTERVAL)
		return
	/*if(healing_naturally)
		if(!can_autoheal)
			stop_processing()
			return
		if((brute_dam + burn_dam) > MINIMUM_AUTOHEAL_HEALTH || owner.stat == DEAD)
			return*/
	//Integrity autoheal
	if(integrity_autoheal && integrity_damage < LIMB_INTEGRITY_AUTOHEAL_THRESHOLD)
		take_integrity_damage(-integrity_autoheal)
	if(brute_autoheal || burn_autoheal)
		heal_damage(brute_autoheal, burn_autoheal, TRUE, TRUE)

	//Chem traces slowly vanish
	if(owner.life_tick % 10 == 0)
		for(var/chemID in trace_chemicals)
			trace_chemicals[chemID] = trace_chemicals[chemID] - 1
			if(trace_chemicals[chemID] <= 0)
				trace_chemicals.Remove(chemID)

/obj/limb/update_icon(forced = FALSE)
	if(parent && parent.status & LIMB_DESTROYED)
		icon_state = ""
		return

	if(status & LIMB_DESTROYED)
		if(has_stump_icon && !(status & LIMB_AMPUTATED))
			icon = 'icons/mob/humans/dam_human.dmi'
			icon_state = "stump_[icon_name]"
		else
			icon_state = ""
		return

	var/race_icon = owner.species.icobase

	if (status & LIMB_ROBOT && !(owner.species && owner.species.flags & IS_SYNTHETIC))
		icon = 'icons/mob/robotic.dmi'
		icon_state = "[icon_name]"
		return

	var/datum/ethnicity/E = GLOB.ethnicities_list[owner.ethnicity]
	var/datum/body_type/B = GLOB.body_types_list[owner.body_type]

	var/e_icon
	var/b_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	if (!B)
		b_icon = "mesomorphic"
	else
		b_icon = B.icon_name

	icon = race_icon
	icon_state = "[get_limb_icon_name(owner.species, b_icon, owner.gender, icon_name, e_icon)]"
	wound_overlay.color = owner.species.blood_color

	var/n_is = damage_state_text()
	if (forced || n_is != damage_state)
		overlays.Cut()
		damage_state = n_is
		update_overlays()


/obj/limb/proc/update_overlays()
	update_damage_icon_part()

// new damage icon system
// returns just the brute/burn damage code
/obj/limb/proc/damage_state_text()
	if(status & LIMB_DESTROYED)
		return "--"

	var/tburn = 0
	var/tbrute = 0

	if(burn_dam == 0)
		tburn = 0
	else if (burn_dam < (max_damage * 0.25 / 1.5))
		tburn = 1
	else if (burn_dam < (max_damage * 0.75 / 1.5))
		tburn = 2
	else
		tburn = 3

	if (brute_dam == 0)
		tbrute = 0
	else if (brute_dam < (max_damage * 0.25 / 1.5))
		tbrute = 1
	else if (brute_dam < (max_damage * 0.75 / 1.5))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

/*
			DISMEMBERMENT
*/

//Recursive setting of self and all child organs to amputated
/obj/limb/proc/setAmputatedTree()
	status |= LIMB_AMPUTATED
	update_icon()
	for(var/obj/limb/O as anything in children)
		O.setAmputatedTree()

/mob/living/carbon/human/proc/remove_random_limb(var/delete_limb = 0)
	var/list/limbs_to_remove = list()
	for(var/obj/limb/E in limbs)
		if(istype(E, /obj/limb/chest) || istype(E, /obj/limb/groin) || istype(E, /obj/limb/head))
			continue
		limbs_to_remove += E
	if(limbs_to_remove.len)
		var/obj/limb/L = pick(limbs_to_remove)
		var/limb_name = L.display_name
		L.droplimb(0, delete_limb)
		return limb_name
	return null

/obj/limb/proc/start_processing()
	if(!(src in owner.limbs_to_process))
		owner.limbs_to_process += src

/obj/limb/proc/stop_processing()
	owner.limbs_to_process -= src

//Handles dismemberment
/obj/limb/proc/droplimb(amputation, var/delete_limb = 0, var/cause)
	if(!owner)
		return
	if(status & LIMB_DESTROYED)
		return
	else
		if(body_part == BODY_FLAG_CHEST)
			return
		stop_processing()
		if(status & LIMB_ROBOT)
			status = LIMB_DESTROYED|LIMB_ROBOT
		else
			status = LIMB_DESTROYED
			owner.pain.apply_pain(PAIN_BONE_BREAK)
		if(amputation)
			status |= LIMB_AMPUTATED
		for(var/i in implants)
			implants -= i
			if(is_sharp(i) || istype(i, /obj/item/shard/shrapnel))
				owner.embedded_items -= i
			qdel(i)

		remove_all_bleeding(TRUE, TRUE)

		if(hidden)
			hidden.forceMove(owner.loc)
			hidden = null

		// If any organs are attached to this, destroy them
		for(var/obj/limb/O in children)
			O.droplimb(amputation, delete_limb, cause)

		//we reset the surgery related variables
		reset_limb_surgeries()

		var/obj/organ	//Dropped limb object
		switch(body_part)
			if(BODY_FLAG_HEAD)
				if(owner.species.flags & IS_SYNTHETIC) //special head for synth to allow brainmob to talk without an MMI
					organ= new /obj/item/limb/head/synth(owner.loc, owner)
				else
					organ= new /obj/item/limb/head(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.glasses, null, TRUE)
				owner.drop_inv_item_on_ground(owner.head, null, TRUE)
				owner.drop_inv_item_on_ground(owner.wear_ear, null, TRUE)
				owner.drop_inv_item_on_ground(owner.wear_mask, null, TRUE)
				owner.update_hair()
			if(BODY_FLAG_ARM_RIGHT)
				if(status & LIMB_ROBOT)
					organ = new /obj/item/robot_parts/r_arm(owner.loc)
				else
					organ = new /obj/item/limb/arm/r_arm(owner.loc, owner)
				if(owner.w_uniform && !amputation)
					var/obj/item/clothing/under/U = owner.w_uniform
					U.removed_parts |= body_part
					owner.update_inv_w_uniform()
			if(BODY_FLAG_ARM_LEFT)
				if(status & LIMB_ROBOT)
					organ = new /obj/item/robot_parts/l_arm(owner.loc)
				else
					organ = new /obj/item/limb/arm/l_arm(owner.loc, owner)
				if(owner.w_uniform && !amputation)
					var/obj/item/clothing/under/U = owner.w_uniform
					U.removed_parts |= body_part
					owner.update_inv_w_uniform()
			if(BODY_FLAG_LEG_RIGHT)
				if(status & LIMB_ROBOT)
					organ = new /obj/item/robot_parts/r_leg(owner.loc)
				else
					organ = new /obj/item/limb/leg/r_leg(owner.loc, owner)
				if(owner.w_uniform && !amputation)
					var/obj/item/clothing/under/U = owner.w_uniform
					U.removed_parts |= body_part
					owner.update_inv_w_uniform()
			if(BODY_FLAG_LEG_LEFT)
				if(status & LIMB_ROBOT)
					organ = new /obj/item/robot_parts/l_leg(owner.loc)
				else
					organ = new /obj/item/limb/leg/l_leg(owner.loc, owner)
				if(owner.w_uniform && !amputation)
					var/obj/item/clothing/under/U = owner.w_uniform
					U.removed_parts |= body_part
					owner.update_inv_w_uniform()
			if(BODY_FLAG_HAND_RIGHT)
				if(!(status & LIMB_ROBOT))
					organ= new /obj/item/limb/hand/r_hand(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.gloves, null, TRUE)
				owner.drop_inv_item_on_ground(owner.r_hand, null, TRUE)
			if(BODY_FLAG_HAND_LEFT)
				if(!(status & LIMB_ROBOT))
					organ= new /obj/item/limb/hand/l_hand(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.gloves, null, TRUE)
				owner.drop_inv_item_on_ground(owner.l_hand, null, TRUE)
			if(BODY_FLAG_FOOT_RIGHT)
				if(!(status & LIMB_ROBOT))
					organ= new /obj/item/limb/foot/r_foot/(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.shoes, null, TRUE)
			if(BODY_FLAG_FOOT_LEFT)
				if(!(status & LIMB_ROBOT))
					organ = new /obj/item/limb/foot/l_foot(owner.loc, owner)
				owner.drop_inv_item_on_ground(owner.shoes, null, TRUE)

		if(delete_limb)
			qdel(organ)
		else
			owner.visible_message(SPAN_WARNING("[owner.name]'s [display_name] flies off in an arc!"),
			SPAN_HIGHDANGER("<b>Your [display_name] goes flying off!</b>"),
			SPAN_WARNING("You hear a terrible sound of ripping tendons and flesh!"), 3)

			if(organ)
				//Throw organs around
				var/lol = pick(cardinal)
				step(organ,lol)

		overlays.Cut() //Severed limbs shouldn't have damage overlays. This prevents issues with permanently bloody robot replacement limbs and excessively bloody stumps.
		owner.update_body(1)
		owner.update_med_icon()

		// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
		release_restraints()

		if(vital) owner.death(cause)

/*
			HELPERS
*/

/obj/limb/proc/release_restraints()
	if(!owner)
		return
	if (owner.handcuffed && (body_part in list(BODY_FLAG_ARM_LEFT, BODY_FLAG_ARM_RIGHT, BODY_FLAG_HAND_LEFT, BODY_FLAG_HAND_RIGHT)))
		owner.visible_message(\
			"\The [owner.handcuffed.name] falls off of [owner.name].",\
			"\The [owner.handcuffed.name] falls off you.")

		owner.drop_inv_item_on_ground(owner.handcuffed)

	if (owner.legcuffed && (body_part in list(BODY_FLAG_FOOT_LEFT, BODY_FLAG_FOOT_RIGHT, BODY_FLAG_LEG_LEFT, BODY_FLAG_LEG_RIGHT)))
		owner.visible_message(\
			"\The [owner.legcuffed.name] falls off of [owner.name].",\
			"\The [owner.legcuffed.name] falls off you.")

		owner.drop_inv_item_on_ground(owner.legcuffed)

/obj/limb/proc/bandage()
	var/rval = 0
	remove_all_bleeding(TRUE)

	owner.update_med_icon()
	return rval

/obj/limb/proc/is_bandaged()
	if (surgery_open_stage != 0)
		return TRUE
	var/not_bandaged = FALSE

	return !not_bandaged

/obj/limb/proc/clamp_wounds()
	var/rval = 0
	remove_all_bleeding(TRUE)

	return rval

/obj/limb/proc/salve()
	var/rval = 0

	return rval

/obj/limb/proc/is_salved()
	if (surgery_open_stage != 0)
		return TRUE
	var/not_salved = FALSE

	return !not_salved

/*
/obj/limb/proc/handle_dislocated()
	owner.recalculate_move_delay = TRUE
	owner.visible_message(\
		SPAN_WARNING("You hear a loud crunching sound coming from [owner] as their [display_name] dislocates out of place!"),
		SPAN_HIGHDANGER("Something feels out of place in your [display_name], as you feel your bones shift!"),
		SPAN_HIGHDANGER("You see bones being shifted out of place!"))
	playsound(owner, "bone_break", 45, TRUE)
	start_processing()

	status |= LIMB_DISLOCATED
	status &= ~LIMB_REPAIRED
	owner.pain.apply_pain(PAIN_DISLOCATED_BREAK)
	perma_injury = min_broken_damage
*/

/obj/limb/proc/robotize()
	status &= ~LIMB_AMPUTATED
	status &= ~LIMB_DESTROYED
	status &= ~LIMB_MUTATED
	status &= ~LIMB_REPAIRED
	status |= LIMB_ROBOT
	stop_processing()
	reset_limb_surgeries()

	perma_injury = 0
	for (var/obj/limb/T in children)
		if(T)
			T.robotize()

	update_icon()

/obj/limb/proc/mutate()
	src.status |= LIMB_MUTATED
	owner.update_body()

/obj/limb/proc/unmutate()
	src.status &= ~LIMB_MUTATED
	owner.update_body()

///Returns total damage, or, if broken, the minimum fracture threshold, whichever is higher.
/obj/limb/proc/get_damage()
	return max(brute_dam + burn_dam, perma_injury)	//could use health?

/obj/limb/proc/is_usable()
	return !(status & (LIMB_DESTROYED|LIMB_MUTATED))

/obj/limb/proc/is_malfunctioning()
	return ((status & LIMB_ROBOT) && prob(brute_dam + burn_dam))

//for arms and hands


/obj/limb/proc/embed(var/obj/item/W, var/silent = 0)
	if(!W || QDELETED(W) || (W.flags_item & (NODROP|DELONDROP)) || W.embeddable == FALSE)
		return
	if(!silent)
		owner.visible_message(SPAN_DANGER("\The [W] sticks in the wound!"))
	implants += W
	start_processing()

	if(is_sharp(W) || istype(W, /obj/item/shard/shrapnel))
		W.embedded_organ = src
		owner.embedded_items += W
		if(is_sharp(W)) // Only add the verb if its not a shrapnel
			add_verb(owner, /mob/proc/yank_out_object)
	W.add_mob_blood(owner)

	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_held_item()
	if(W)
		W.forceMove(owner)

/obj/limb/proc/update_damage_icon_part()
	var/brutestate = copytext(damage_state, 1, 2)
	var/burnstate = copytext(damage_state, 2)
	if(brutestate != "0")
		wound_overlay.icon_state = "grayscale_[brutestate]"
		overlays += wound_overlay

	if(burnstate != "0")
		wound_overlay.icon_state = "burn_[burnstate]"
		overlays += wound_overlay

	// for(var/datum/wound/W in wounds)
	// 	if(W.impact_icon)
	// 		DI = new /image(W.impact_icon)
	// 		DI.blend_mode = BLEND_INSET_OVERLAY
	// 		overlays += DI


//called when limb is removed or robotized, any ongoing surgery and related vars are reset
/obj/limb/proc/reset_limb_surgeries()
	surgery_open_stage = 0
	bone_repair_stage = 0
	limb_replacement_stage = 0
	surgery_organ = null
	cavity = 0

/*
			LIMB TYPES AND INTEGRITY EFFECTS
*/
/obj/limb/chest
	name = "chest"
	icon_name = "torso"
	display_name = "chest"
	max_damage = 200
	body_part = BODY_FLAG_CHEST
	vital = 1
	encased = "ribcage"
	artery_name = "aorta"

/obj/limb/chest/on_integrity_tier_increased(old_level)
	..()
	if(integrity_level >= LIMB_INTEGRITY_CONCERNING && old_level < LIMB_INTEGRITY_CONCERNING)
		to_chat(owner, SPAN_DANGER("You feel like your very flesh and skin has become more vulnerable and softer to attacks!"))
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("Adrenaline puppets you for a little longer, but your wounds are nearing critical limits; no shock will patch you if you fail now!"))
		owner.add_limb_wound(/datum/limb_wound/low_adrenaline, src, LIMB_INTEGRITY_SERIOUS)
	if(integrity_level >= LIMB_INTEGRITY_CRITICAL && old_level < LIMB_INTEGRITY_CRITICAL)
		to_chat(owner, SPAN_HIGHDANGER("Looking down, you see small parts of your guts waiting to liberate themselves from your feeble chest; you sure you want to challenge destiny, [owner.name]?"))

/obj/limb/groin
	name = "groin"
	icon_name = "groin"
	display_name = "groin"
	max_damage = 200
	body_part = BODY_FLAG_GROIN
	artery_name = "iliac artery"

/obj/limb/groin/on_integrity_tier_increased(old_level)
	..()
	if(integrity_level >= LIMB_INTEGRITY_CONCERNING && old_level < LIMB_INTEGRITY_CONCERNING)
		to_chat(owner, SPAN_DANGER("You start to feel more vulnerable to toxins, as you feel your kidneys start to oppose your mad persistence."))
		owner.add_limb_wound(/datum/limb_wound/neurotoxin_vulnerability, src, LIMB_INTEGRITY_CONCERNING)
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("Your stomach and guts begin to shut off like a power grid. God save you, for no medicine will."))
		owner.add_limb_wound(/datum/limb_wound/vomit_reflex, src, LIMB_INTEGRITY_SERIOUS)

/obj/limb/leg
	name = "leg"
	display_name = "leg"
	max_damage = 35
	artery_name = "femoral artery"

/obj/limb/leg/on_integrity_tier_increased(old_level)
	if(integrity_level >= LIMB_INTEGRITY_CONCERNING && old_level < LIMB_INTEGRITY_CONCERNING)
		to_chat(owner, SPAN_DANGER("Your [display_name] feels limper and weaker; perhaps climbing and dragging wouldn't be a good idea."))
		owner.add_limb_wound(/datum/limb_wound/limited_joint_mobility, src, LIMB_INTEGRITY_CONCERNING)
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("Your [display_name] buckles and your knees flare in pain just standing up, this could be very bad if you got knocked over!"))
		owner.add_limb_wound(/datum/limb_wound/weakened_knee_musculature, src, LIMB_INTEGRITY_SERIOUS)
	if(integrity_level >= LIMB_INTEGRITY_CRITICAL && old_level < LIMB_INTEGRITY_CRITICAL)
		to_chat(owner, SPAN_HIGHDANGER("You hear a sound like paper tearing inside of your [display_name] and your next step is noticeably painful. You should probably find a cane or a doctor."))
		//todo add rip sound
		owner.add_limb_wound(/datum/limb_wound/severely_torn_ligaments, src, LIMB_INTEGRITY_CRITICAL)

/obj/limb/foot
	name = "foot"
	display_name = "foot"
	max_damage = 30
	var/move_delay_mult = HUMAN_SLOWED_AMOUNT
	artery_name = "plantar artery"

/obj/limb/foot/on_integrity_tier_increased(old_level)
	..()
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("You feel significantly more slower, as your feet can no longer handle your movement!"))
		owner.add_limb_wound(/datum/limb_wound/ruptured_tendon, src, LIMB_INTEGRITY_SERIOUS)

/obj/limb/arm
	name = "arm"
	display_name = "arm"
	max_damage = 35
	artery_name = "basilic vein"

/obj/limb/arm/on_integrity_tier_increased(old_level)
	..()
	if(integrity_level >= LIMB_INTEGRITY_CONCERNING && old_level < LIMB_INTEGRITY_CONCERNING)
		to_chat(owner, SPAN_DANGER("Your arms begin to tremble in weakness; this may be horrible for any work you have planned."))
		owner.add_limb_wound(/datum/limb_wound/decreased_arm_muscle_functionality, src, LIMB_INTEGRITY_CONCERNING)
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("You feel as if your arms have weights strapped against them, forcing you to exert yourself to raise any weapon or tool!"))
		owner.add_limb_wound(/datum/limb_wound/ruptured_forearm_muscles, src, LIMB_INTEGRITY_SERIOUS)
	if(integrity_level >= LIMB_INTEGRITY_CRITICAL && old_level < LIMB_INTEGRITY_CRITICAL)	
		to_chat(owner, SPAN_DANGER("Your arms look flayed and beaten like two roadkills, looking like any plans you had for them are borderline Heruclean."))
		owner.add_limb_wound(/datum/limb_wound/decreased_arm_muscle_functionality, src, LIMB_INTEGRITY_CRITICAL)	

/obj/limb/arm/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	body_part = BODY_FLAG_ARM_LEFT
	has_stump_icon = TRUE

/obj/limb/arm/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	body_part = BODY_FLAG_ARM_RIGHT
	has_stump_icon = TRUE

/obj/limb/hand
	name = "hand"
	display_name = "hand"
	max_damage = 30
	var/obj/item/c_hand
	var/hand_name = "ambidexterous hand"


/obj/limb/hand/on_integrity_tier_increased(old_level)
	if(integrity_level >= LIMB_INTEGRITY_CONCERNING && old_level < LIMB_INTEGRITY_CONCERNING)
		to_chat(owner, SPAN_DANGER("Your hands become less responsive due to the tears on them, you're definitely going to need more time to solve stuff now."))
		owner.add_limb_wound(/datum/limb_wound/sprained_hand_muscle, src, LIMB_INTEGRITY_THRESHOLD_CONCERNING)
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("Your hands struggle to deal with any future recoil, as the wounds eat away at your flesh and bone."))
		owner.add_limb_wound(/datum/limb_wound/fractured_wrist, src, LIMB_INTEGRITY_SERIOUS)

/obj/limb/hand/proc/process_grasp(c_hand, hand_name)
	/*	
	if (!c_hand)
		return

	var/drop_probability = 0.6 * ((brute_dam + burn_dam) + (integrity_damage * 0.5))
	if(is_broken())
		drop_probability *= 1.25 //25% bonus

	if(is_integrity_disabled())
		if(prob(drop_probability))
			owner.drop_inv_item_on_ground(c_hand)
			var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
			owner.emote("me", 1, "[(!owner.pain.feels_pain) ? "" : emote_scream ] drops what they were holding in their [hand_name]!")
	*/
	/* NEED TO THINK ON HOW TO REWORK THIS TO BE HONEST WITH YOU
	if(is_malfunctioning())
		if(prob(10))
			owner.drop_inv_item_on_ground(c_hand)
			owner.emote("me", 1, "drops what they were holding, their [hand_name] malfunctioning!")
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(5, 0, owner)
			spark_system.attach(owner)
			spark_system.start()
			QDEL_IN(spark_system, 1 SECONDS) */

/obj/limb/hand/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	body_part = BODY_FLAG_HAND_RIGHT
	has_stump_icon = TRUE
	hand_name = "right hand"

/obj/limb/hand/r_hand/Initialize()
	..()
	c_hand = owner.r_hand

/obj/limb/hand/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	body_part = BODY_FLAG_HAND_LEFT
	has_stump_icon = TRUE
	hand_name = "left hand"

/obj/limb/hand/l_hand/Initialize()
	..()
	c_hand = owner.l_hand

/obj/limb/leg/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	body_part = BODY_FLAG_LEG_LEFT
	icon_position = LEFT
	has_stump_icon = TRUE

/obj/limb/leg/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	body_part = BODY_FLAG_LEG_RIGHT
	icon_position = RIGHT
	has_stump_icon = TRUE

/obj/limb/foot/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	body_part = BODY_FLAG_FOOT_LEFT
	icon_position = LEFT
	has_stump_icon = TRUE

/obj/limb/foot/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	body_part = BODY_FLAG_FOOT_RIGHT
	icon_position = RIGHT
	has_stump_icon = TRUE

/obj/limb/head
	name = "head"
	icon_name = "head"
	display_name = "head"
	max_damage = 60
	body_part = BODY_FLAG_HEAD
	vital = 1
	encased = "skull"
	has_stump_icon = TRUE
	var/disfigured = 0 //whether the head is disfigured.
	var/face_surgery_stage = 0
	artery_name = "cartoid artery"

	natural_int_dmg_resist = 0.6

/obj/limb/head/on_integrity_tier_increased(old_level)
	..()
	if(integrity_level >= LIMB_INTEGRITY_SERIOUS && old_level < LIMB_INTEGRITY_SERIOUS)
		to_chat(owner, SPAN_DANGER("The damage to your head has caused black and red to splay all over your eyesight, and force a fuzzy feeling in your head."))
		owner.add_limb_wound(/datum/limb_wound/minor_concussion, src, LIMB_INTEGRITY_SERIOUS)
	if(integrity_level >= LIMB_INTEGRITY_CRITICAL && old_level < LIMB_INTEGRITY_CRITICAL)
		to_chat(owner, SPAN_DANGER("You definitely feel hell in your head, as you struggle to see, think or feel anything. Any more damage might make your head burst!"))
		owner.add_limb_wound(/datum/limb_wound/ruptured_globe, src, LIMB_INTEGRITY_CRITICAL)

/obj/limb/head/update_overlays()
	..()

	var/image/eyes = new/image('icons/mob/humans/onmob/human_face.dmi', owner.species.eyes)
	eyes.color = list(null, null, null, null, rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes))
	overlays += eyes

	if(owner.lip_style && (owner.species && owner.species.flags & HAS_LIPS))
		var/icon/lips = new /icon('icons/mob/humans/onmob/human_face.dmi', "paint_[owner.lip_style]")
		overlays += lips

/obj/limb/head/take_damage(brute, burn, int_dmg_multiplier = 1, used_weapon = null, list/forbidden_limbs = list(), no_limb_loss, impact_name = null, var/mob/attack_source = null)
	. = ..()
	if (!disfigured)
		if (brute_dam > 50 || brute_dam > 40 && prob(50))
			disfigure("brute")
		if (burn_dam > 40)
			disfigure("burn")

/obj/limb/head/proc/disfigure(var/type = "brute")
	if (disfigured)
		return
	if(type == "brute")
		owner.visible_message(SPAN_DANGER("You hear a sickening cracking sound coming from \the [owner]'s face."),	\
		SPAN_DANGER("<b>Your face becomes an unrecognizible mangled mess!</b>"),	\
		SPAN_DANGER("You hear a sickening crack."))
	else
		owner.visible_message(SPAN_DANGER("[owner]'s face melts away, turning into a mangled mess!"),	\
		SPAN_DANGER("<b>Your face melts off!</b>"),	\
		SPAN_DANGER("You hear a sickening sizzle."))
	disfigured = 1
	owner.name = owner.get_visible_name()

/obj/limb/head/reset_limb_surgeries()
	..()
	face_surgery_stage = 0
