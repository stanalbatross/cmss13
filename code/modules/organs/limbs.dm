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
	var/knitting_time = -1
	var/time_to_knit = -1 // snowflake vars for doing self-bone healing, think preds and magic research chems

	var/display_name
	var/list/wounds = list()
	var/number_wounds = 0 // cache the number of wounds, which is NOT wounds.len!

	var/tmp/perma_injury = 0

	var/min_broken_damage = 30

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

	// how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1
	var/status //limb status flags

	var/mob/living/carbon/human/owner = null
	var/vital //Lose a vital limb, die immediately.

	var/has_stump_icon = FALSE
	var/image/wound_overlay //Used to save time redefining it every wound update. Doesn't remember anything but the most recently used icon state.

	var/splint_icon_amount = 1
	var/bandage_icon_amount = 1

	var/icon/splinted_icon = null

	// Integrity mechanic vars
	var/list/bleeding_effects_list = list()
	var/integrity_level = 0
	var/integrity_level_effects = NO_FLAGS //Levels are not cumulative, but instead, are flags. This is so to allow some levels to be neutralized without changing the others (ex: level 3 effects are neutralized, but 2 and 4 are in effect)
	var/perma_min_damage = 0

	var/brute_autoheal = 0.02 //per life tick
	var/burn_autoheal = 0.04
	var/integrity_autoheal = 0.1
	var/can_autoheal = TRUE
	var/integrity_damage = 0
	var/last_dam_time = 0

	var/neutralized_integrity_effects = NO_FLAGS
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

	splinted_icon = null

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


/obj/limb/proc/take_damage_organ_damage(brute, sharp)
	if(!owner)
		return

	var/armor = owner.getarmor_organ(src, ARMOR_INTERNALDAMAGE)
	var/damage = armor_damage_reduction(GLOB.marine_organ_damage, brute, armor, sharp ? ARMOR_SHARP_INTERNAL_PENETRATION : 0, 0, 0, max_damage ? (100*(max_damage - brute_dam) / max_damage) : 100)

	if(internal_organs && (integrity_level_effects & LIMB_INTEGRITY_SERIOUS) && damage > 10)
		//Damage an internal organ
		var/datum/internal_organ/I = pick(internal_organs)
		I.take_damage(damage / 2)
		return TRUE
	return FALSE

/obj/limb/proc/take_damage_bone_break(brute)
	if(!owner)
		return
	var/armor = owner.getarmor_organ(src, ARMOR_INTERNALDAMAGE)
	var/damage = armor_damage_reduction(GLOB.marine_organ_damage, brute*3, armor, 0, 0, 0, max_damage ? (100*(max_damage - brute_dam) / max_damage) : 100)

	if(brute_dam + brute  > min_broken_damage)
		fracture(damage)

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

	if(CONFIG_GET(flag/bones_can_break) && !(status & LIMB_ROBOT))
		take_damage_bone_break(brute)

	if(status & LIMB_BROKEN && prob(40) && brute > 10)
		if(owner.pain.feels_pain)
			INVOKE_ASYNC(owner, /mob.proc/emote, "scream") //Getting hit on broken hand hurts
	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)

	var/can_cut = (prob(brute*2) && !(status & LIMB_ROBOT))
	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	if((brute_dam + burn_dam + brute + burn) < max_damage || !CONFIG_GET(flag/limbs_can_break))
		if(brute)
			if(can_cut)
				createwound(CUT, brute, impact_name, is_ff = is_ff)
			else
				createwound(BRUISE, brute, impact_name, is_ff = is_ff)
		if(burn)
			createwound(BURN, burn, impact_name, is_ff = is_ff)
	else
		//If we can't inflict the full amount of damage, spread the damage in other ways
		//How much damage can we actually cause?
		var/can_inflict = max_damage * CONFIG_GET(number/organ_health_multiplier) - (brute_dam + burn_dam)
		var/remain_brute = brute
		var/remain_burn = burn
		if(can_inflict)
			if(brute > 0)
				//Inflict all brute damage we can
				if(can_cut)
					createwound(CUT, min(brute, can_inflict), impact_name, is_ff = is_ff)
				else
					createwound(BRUISE, min(brute, can_inflict), impact_name, is_ff = is_ff)
				var/temp = can_inflict
				//How much more damage can we inflict
				can_inflict = max(0, can_inflict - brute)
				//How much brute damage is left to inflict
				remain_brute = max(0, brute - temp)

			if(burn > 0 && can_inflict)
				//Inflict all burn damage we can
				createwound(BURN, min(burn,can_inflict), impact_name, is_ff = is_ff)
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

	// Check what the damage was before
	var/old_brute_dam = brute_dam

	//Sync the organ's damage with its wounds
	src.update_damages()

	//If limb was damaged before and took enough damage, try to cut or tear it off
	var/no_perma_damage = owner.status_flags & NO_PERMANENT_DAMAGE
	if(old_brute_dam > 0 && !is_ff && body_part != BODY_FLAG_CHEST && !no_limb_loss && !no_perma_damage)
		if(integrity_level_effects & LIMB_INTEGRITY_EFFECT_CRTICAL)
			droplimb(0, 0, damage_source)
			return

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
	var/new_effects
	if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_OKAY)
		integrity_level++
		new_effects |= LIMB_INTEGRITY_EFFECT_MINOR
		if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_CONCERNING)
			integrity_level++
			new_effects |= LIMB_INTEGRITY_EFFECT_MODERATE
			if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_SERIOUS)
				integrity_level++
				new_effects |= LIMB_INTEGRITY_EFFECT_MAJOR
				if(integrity_damage >= LIMB_INTEGRITY_THRESHOLD_CRITICAL)
					integrity_level++
					new_effects |= LIMB_INTEGRITY_EFFECT_CRTICAL

	if(integrity_level > old_level)
		integrity_warning()

	new_effects &= ~neutralized_integrity_effects

	if(new_effects == integrity_level_effects)
		return

	var/added_effects = ~integrity_level_effects & new_effects
	var/removed_effects = integrity_level_effects & ~new_effects
	integrity_level_effects = new_effects

	reapply_integrity_effects(added_effects, removed_effects)

/obj/limb/proc/reapply_integrity_effects(added, removed)
	if(added & LIMB_INTEGRITY_THRESHOLD_CRITICAL)
		perma_min_damage += 80
	else if(removed & LIMB_INTEGRITY_THRESHOLD_CRITICAL)
		perma_min_damage -= 80

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

/obj/limb/proc/integrity_warning()
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

/obj/limb/proc/recalculate_health_effects()
	if(can_autoheal)
		brute_autoheal = initial(brute_autoheal)
		burn_autoheal = initial(burn_autoheal)
		integrity_autoheal = initial(integrity_autoheal)
	else
		brute_autoheal = 0
		burn_autoheal = 0
		integrity_autoheal = 0
	var/old_neutralized = neutralized_integrity_effects
	neutralized_integrity_effects = 0

	/*for(var/obj/item/stack/medical/M in medical_items)
		if(M.brute_autoheal > brute_autoheal)
			brute_autoheal = M.brute_autoheal
			healing_naturally = FALSE
		if(M.burn_autoheal > burn_autoheal)
			burn_autoheal = M.burn_autoheal
			healing_naturally = FALSE
		if(M.integrity_autoheal > integrity_autoheal)
			integrity_autoheal = M.integrity_autoheal

		neutralized_integrity_effects |= M.limb_integrity_levels_neutralized*/
	if(neutralized_integrity_effects != old_neutralized)
		recalculate_integrity_level()


/obj/limb/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(status & LIMB_ROBOT && !robo_repair)
		return

	if(brute)
		remove_all_bleeding(TRUE)

	if(internal)
		remove_all_bleeding(FALSE, TRUE)

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			var/old_brute = brute
			brute = W.heal_damage(brute)
			owner.pain.apply_pain(brute - old_brute)
		else if(W.damage_type == BURN)
			var/old_burn = burn
			burn = W.heal_damage(burn)
			owner.pain.apply_pain(burn - old_burn)

	if(internal)
		owner.pain.apply_pain(-PAIN_BONE_BREAK)
		status &= ~LIMB_BROKEN
		status &= ~LIMB_DISLOCATED
		status |= LIMB_REPAIRED
		perma_injury = 0

	//Sync the organ's damage with its wounds
	src.update_damages()
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
	wounds.Cut()
	number_wounds = 0

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

/obj/limb/proc/take_damage_internal_bleeding(damage)
	if(!owner)
		return

	var/armor = owner.getarmor_organ(src, ARMOR_INTERNALDAMAGE)
	var/endurance_buff = 0
	if(owner.mind && owner.skills)
		endurance_buff = owner.skills.get_skill_level(SKILL_ENDURANCE)*5
		armor += endurance_buff

	var/damage_ratio = armor_damage_reduction(GLOB.marine_organ_damage, 2*damage/3, armor, 0, 0, 0, max_damage ? (100*(max_damage - brute_dam) / max_damage) : 100)
	var/ib_probability = 40 + (brute_dam + damage_ratio) + (integrity_damage * 0.40) - max(armor, endurance_buff , 0)

	if(((integrity_level_effects & LIMB_INTEGRITY_EFFECT_SERIOUS) || ((integrity_level_effects & LIMB_INTEGRITY_EFFECT_MAJOR && prob(ib_probability)))) && damage_ratio > 10)
		var/datum/wound/internal_bleeding/I = new (0)
		add_bleeding(I, TRUE)
		wounds += I
		owner.custom_pain("You feel something tear in your [display_name], causing you to suddenly feel a lot weaker than usual!", 1)

/obj/limb/proc/createwound(var/type = CUT, var/damage, var/impact_name, var/is_ff = FALSE)
	if(!damage)
		return

	//moved this before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Possibly trigger an internal wound, too.
	if(!is_ff && type != BURN && !(status & LIMB_ROBOT))
		take_damage_internal_bleeding(damage)

	if(!(status & LIMB_SPLINTED_INDESTRUCTIBLE) && (status & LIMB_SPLINTED) && damage > 5 && prob(50 + damage * 2.5)) //If they have it splinted, the splint won't hold.
		status &= ~LIMB_SPLINTED
		to_chat(owner, SPAN_DANGER("The splint on your [display_name] comes apart!"))
		owner.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED)
		owner.update_med_icon()

	// first check whether we can widen an existing wound
	var/datum/wound/W
	if(wounds.len > 0 && prob(max(50+(number_wounds-1)*10,90)))
		if((type == CUT || type == BRUISE) && damage >= 5)
			//we need to make sure that the wound we are going to worsen is compatible with the type of damage...
			var/compatible_wounds[] = new
			for(W in wounds)
				if(W.can_worsen(type, damage)) compatible_wounds += W

			if(compatible_wounds.len)
				W = pick(compatible_wounds)
				W.open_wound(damage)
				if(type != BURN)
					add_bleeding(W)
					owner.add_splatter_floor(get_turf(loc))
				if(prob(25))
					//maybe have a separate message for BRUISE type damage?
					owner.visible_message(SPAN_WARNING("The wound on [owner.name]'s [display_name] widens with a nasty ripping noise."),
					SPAN_WARNING("The wound on your [display_name] widens with a nasty ripping noise."),
					SPAN_WARNING("You hear a nasty ripping noise, as if flesh is being torn apart."))
				return

	//Creating wound
	var/wound_type = get_wound_type(type, damage)

	if(wound_type)
		W = new wound_type(damage)
		if(damage >= 10 && type != BURN) //Only add bleeding when its over 10 damage
			add_bleeding(W)
			owner.add_splatter_floor(get_turf(loc))

		//Check whether we can add the wound to an existing wound
		for(var/datum/wound/other in wounds)
			if(other.can_merge(W))
				other.merge_wound(W)
				W = null // to signify that the wound was added
				break
		if(W)
			wounds += W


/obj/limb/proc/add_bleeding(var/datum/wound/W, var/internal = FALSE, var/arterial = FALSE)
	if(!(SSticker.current_state >= GAME_STATE_PLAYING)) //If the game hasnt started, don't add bleed. Hacky fix to avoid having 100 bleed effect from roundstart.
		return

	if(status & LIMB_ROBOT)
		return

	if(bleeding_effects_list.len)
		if(!internal)
			for(var/datum/effects/bleeding/external/B in bleeding_effects_list)
				B.add_on(W.damage)
				return
		else
			for(var/datum/effects/bleeding/internal/B in bleeding_effects_list)
				B.add_on(30)
				return

	var/datum/effects/bleeding/bleeding_status
	if(internal)
		bleeding_status = new /datum/effects/bleeding/internal(owner, src, (max(40, brute_dam)+ (0.15 * integrity_damage)))
	else
		bleeding_status = new /datum/effects/bleeding/external(owner, src, W.damage)
		if(arterial)
			bleeding_status = new /datum/effects/bleeding/arterial(owner, src, W.damage)

	bleeding_effects_list += bleeding_status

/obj/limb/proc/remove_all_bleeding(var/external = FALSE, var/internal = FALSE, var/arterial = FALSE)
	if(external)
		for(var/datum/effects/bleeding/external/B in bleeding_effects_list)
			qdel(B)

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
	if(knitting_time > 0)
		return 1
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

	// Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(owner.life_tick % wound_update_accuracy == 0)
		update_wounds()

	//Chem traces slowly vanish
	if(owner.life_tick % 10 == 0)
		for(var/chemID in trace_chemicals)
			trace_chemicals[chemID] = trace_chemicals[chemID] - 1
			if(trace_chemicals[chemID] <= 0)
				trace_chemicals.Remove(chemID)

	//Bone fractures
	if(!(status & (LIMB_BROKEN|LIMB_DISLOCATED)))
		perma_injury = 0
	if(knitting_time > 0)
		if(world.time > knitting_time)
			to_chat(owner, SPAN_WARNING("The bones in your [display_name] feel fully knitted."))
			owner.pain.apply_pain(-PAIN_BONE_BREAK)
			status &= ~LIMB_BROKEN //Let it be known that this code never unbroke the limb.
			status &= ~LIMB_DISLOCATED
			knitting_time = -1

//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/obj/limb/proc/update_wounds()
	if((status & LIMB_ROBOT)) //Robotic limbs don't heal or get worse.
		return

	owner.recalculate_move_delay = TRUE

	var/wound_disappeared = FALSE
	for(var/datum/wound/W in wounds)
		// we don't care about wounds after we heal them. We are not an antag simulator
		if(W.damage <= 0 && !W.internal)
			wounds -= W
			wound_disappeared = TRUE
			continue
			// let the GC handle the deletion of the wound

		// Internal wounds get worse over time. Low temperatures (cryo) stop them.
		if(W.internal)
			if(owner.bodytemperature < T0C && (owner.reagents.get_reagent_amount("cryoxadone") || owner.reagents.get_reagent_amount("clonexadone"))) // IB is healed in cryotubes
				if(W.created + 2 MINUTES <= world.time)	// sped up healing due to cryo magics
					remove_all_bleeding(FALSE, TRUE)
					wounds -= W
					wound_disappeared = TRUE
					if(istype(owner.loc, /obj/structure/machinery/cryo_cell))	// check in case they cheesed the location
						var/obj/structure/machinery/cryo_cell/cell = owner.loc
						cell.display_message("internal bleeding is")
			if(owner.reagents.get_reagent_amount("thwei") >= 0.05)
				remove_all_bleeding(FALSE, TRUE)

		// slow healing
		var/heal_amt = 0


		// if damage >= 50 AFTER treatment then it's probably too severe to heal within the timeframe of a round.
		if (W.can_autoheal() && owner.health >= 0 && !W.is_treated() && owner.bodytemperature > owner.species.cold_level_1)
			heal_amt += 0.3 * 0.35 //They can't autoheal if in critical
		else if (W.is_treated())
			heal_amt += 0.5 * 0.75 //Treated wounds heal faster

		if(heal_amt)
			//we only update wounds once in [wound_update_accuracy] ticks so have to emulate realtime
			heal_amt = heal_amt * wound_update_accuracy
			//configurable regen speed woo, no-regen hardcore or instaheal hugbox, choose your destiny
			heal_amt = heal_amt * CONFIG_GET(number/organ_regeneration_multiplier)
			// amount of healing is spread over all the wounds
			heal_amt = heal_amt / (wounds.len + 1)
			// making it look prettier on scanners
			heal_amt = round(heal_amt,0.1)

			if(istype(W, /datum/wound/bruise) || istype(W, /datum/wound/cut))
				owner.pain.apply_pain(-heal_amt, BRUTE)
			else if(istype(W, /datum/wound/burn))
				owner.pain.apply_pain(-heal_amt, BURN)
			else
				owner.pain.recalculate_pain()

			W.heal_damage(heal_amt)

	// sync the organ's damage with its wounds
	update_damages()
	update_icon()
	if (wound_disappeared)
		owner.update_med_icon()

//Updates brute_damn and burn_damn from wound damages.
/obj/limb/proc/update_damages()
	number_wounds = 0
	brute_dam = 0
	burn_dam = 0

	for(var/datum/wound/W in wounds)
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute_dam += W.damage
		else if(W.damage_type == BURN)
			burn_dam += W.damage

		number_wounds += W.amount

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

		//Replace all wounds on that arm with one wound on parent organ.
		wounds.Cut()
		if(parent && !amputation)
			var/datum/wound/W
			if(max_damage < 50) W = new/datum/wound/lost_limb/small(max_damage)
			else 				W = new/datum/wound/lost_limb(max_damage)

			parent.wounds += W
			parent.update_damages()
		update_damages()

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
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.bandaged
		W.bandaged = 1
	owner.update_med_icon()
	return rval

/obj/limb/proc/is_bandaged()
	if (surgery_open_stage != 0)
		return TRUE
	var/not_bandaged = FALSE
	for (var/datum/wound/W in wounds)
		if (W.internal)
			continue
		not_bandaged |= !W.bandaged
	return !not_bandaged

/obj/limb/proc/clamp_wounds()
	var/rval = 0
	remove_all_bleeding(TRUE)
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.clamped
		W.clamped = 1
	return rval

/obj/limb/proc/salve()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
		W.salved = 1
	return rval

/obj/limb/proc/is_salved()
	if (surgery_open_stage != 0)
		return TRUE
	var/not_salved = FALSE
	for (var/datum/wound/W in wounds)
		not_salved |= !W.salved
	return !not_salved

/obj/limb/proc/fracture(var/damage_input, var/fracture_probability)
	if(status & (LIMB_DISLOCATED|LIMB_BROKEN|LIMB_DESTROYED|LIMB_ROBOT))
		if (knitting_time != -1)
			knitting_time = -1
			to_chat(owner, SPAN_WARNING("You feel your [display_name] stop knitting together as it is impacted by damage!"))
		return

	if(owner.status_flags & NO_PERMANENT_DAMAGE)
		owner.visible_message(\
			SPAN_WARNING("[owner] withstands the attack!"),
			SPAN_WARNING("Your [display_name] withstands the attack, preventing a fracture!"))
		return

	if((owner.chem_effect_flags & CHEM_EFFECT_RESIST_FRACTURE) || owner.species.flags & SPECIAL_BONEBREAK) //stops division by zero
		return

	var/armor = owner.getarmor_organ(src, ARMOR_INTERNALDAMAGE)
	var/endurance_buff = 0
	if(owner.skills)
		endurance_buff = owner.skills.get_skill_level(SKILL_ENDURANCE) - 1

	var/hairline_probability = 0
	if(integrity_level_effects & LIMB_INTEGRITY_EFFECT_MODERATE || !(status & LIMB_DISLOCATED))
		hairline_probability = 50 - (endurance_buff * 2.0) + (damage_input * 0.5) - (armor * 0.25) + (integrity_damage * 0.10) + (brute_dam * 0.20)
		message_staff("fracture success = [fracture_probability]")

	if(integrity_level_effects & LIMB_INTEGRITY_EFFECT_MAJOR)
		if(prob(hairline_probability))
			handle_dislocated()
			return

		if(!fracture_probability)
			fracture_probability = fracture_probability - (brute_dam + damage_input) + (integrity_damage * 0.40) - max(armor, endurance_buff * 4.0 , 0)
			message_staff("fracture success = [fracture_probability]")

	if(integrity_level_effects & LIMB_INTEGRITY_EFFECT_SERIOUS || prob(fracture_probability))
		handle_fracture()
	else
		owner.visible_message(\
			SPAN_WARNING("[owner] seems to withstand the blow!"),
			SPAN_WARNING("Your [display_name] manages to withstand the blow!"))

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

/obj/limb/proc/handle_fracture()
	owner.recalculate_move_delay = TRUE
	owner.visible_message(\
		SPAN_WARNING("You hear a loud cracking sound coming from [owner] as their bones shatter!"),
		SPAN_HIGHDANGER("Something feels like it shattered in your [display_name], fragments ripping all over it!"),
		SPAN_HIGHDANGER("You hear a sickening cracking noise!"))
	playsound(owner, "bone_break", 45, TRUE)
	start_processing()

	status |= LIMB_BROKEN
	status &= ~LIMB_REPAIRED
	owner.pain.apply_pain(PAIN_BONE_BREAK)
	perma_injury = min_broken_damage
	addtimer(CALLBACK(src, .proc/register_fracture_effects), 8 SECONDS)

/obj/limb/proc/register_fracture_effects()
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, .proc/handle_fracture_int_damage)

/obj/limb/proc/handle_fracture_int_damage()
	SIGNAL_HANDLER
	if(!owner)
		return
	if(!(status & LIMB_BROKEN))
		UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)

	if(is_broken() && (!owner.lying && world.time - owner.l_move_time < 15) && integrity_damage < LIMB_INTEGRITY_BONE_MOVEMENT_CAP) // kinda messy but it'll do
		to_chat(owner, SPAN_WARNING("You feel your [display_name]'s bones shift around, further ripping and damaging it!"))
		take_integrity_damage(PASSIVE_INT_DAMAGE_PER_STEP)

/obj/limb/proc/robotize()
	status &= ~LIMB_BROKEN
	status &= ~LIMB_DISLOCATED
	status &= ~LIMB_SPLINTED
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

/obj/limb/proc/is_broken()
	return ((status & LIMB_BROKEN) && !(status & LIMB_SPLINTED))

/obj/limb/proc/is_integrity_disabled()
	return (!(status & LIMB_SPLINTED) && integrity_level_effects & LIMB_INTEGRITY_EFFECT_MAJOR)

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

/obj/limb/proc/apply_splints(obj/item/stack/medical/splint/S, mob/living/user, mob/living/carbon/human/target, var/indestructible_splints = FALSE)
	if(!(status & LIMB_DESTROYED) && !(status & LIMB_SPLINTED))
		var/time_to_take = 5 SECONDS
		if (target == user)
			user.visible_message(SPAN_WARNING("[user] fumbles with the [S]"), SPAN_WARNING("You fumble with the [S]..."))
			time_to_take = 15 SECONDS

		if(do_after(user, time_to_take * user.get_skill_duration_multiplier(SKILL_MEDICAL), INTERRUPT_NO_NEEDHAND, BUSY_ICON_FRIENDLY, target, INTERRUPT_MOVED, BUSY_ICON_MEDICAL))
			var/possessive = "[user == target ? "your" : "[target]'s"]"
			var/possessive_their = "[user == target ? "their" : "[target]'s"]"
			user.affected_message(target,
				SPAN_HELPFUL("You finish applying <b>[S]</b> to [possessive] [display_name]."),
				SPAN_HELPFUL("[user] finishes applying <b>[S]</b> to your [display_name]."),
				SPAN_NOTICE("[user] finish applying [S] to [possessive_their] [display_name]."))
			status |= LIMB_SPLINTED
			if(indestructible_splints)
				status |= LIMB_SPLINTED_INDESTRUCTIBLE

			if(status & LIMB_BROKEN)
				owner.pain.apply_pain(-PAIN_BONE_BREAK_SPLINTED)
			else if(status & LIMB_DISLOCATED)
				owner.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED * 0.5) // half
			. = TRUE
			owner.update_med_icon()



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
	min_broken_damage = 30
	body_part = BODY_FLAG_CHEST
	vital = 1
	encased = "ribcage"
	splint_icon_amount = 4
	bandage_icon_amount = 4
	var/burn_damage_bonus = 1.65

/obj/limb/chest/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_MODERATE)
		owner.int_dmg_malus -= 0.3
	else if(added & LIMB_INTEGRITY_EFFECT_MODERATE)
		to_chat(owner, SPAN_DANGER("You feel like your very flesh and skin has become more vulnerable and softer to attacks!"))
		owner.int_dmg_malus += 0.3
	if(removed & LIMB_INTEGRITY_EFFECT_MAJOR)
		UnregisterSignal(owner, list(COMSIG_MOB_STOP_DEFIBHEAL,
		COMSIG_MOB_BONUS_DAMAGE))
	else if(added & LIMB_INTEGRITY_EFFECT_MAJOR)
		to_chat(owner, SPAN_DANGER("Adrenaline puppets you for a little longer, but your wounds are nearing critical limits; no shock will patch you if you fail now!"))
		RegisterSignal(owner, COMSIG_MOB_STOP_DEFIBHEAL, .proc/cancel_defib_heal)
		RegisterSignal(owner, COMSIG_MOB_BONUS_DAMAGE, .proc/bonus_burn_damage)
	if(removed & LIMB_INTEGRITY_EFFECT_SERIOUS)
	else if(added & LIMB_INTEGRITY_EFFECT_SERIOUS)
		to_chat(owner, SPAN_HIGHDANGER("Looking down, you see small parts of your guts waiting to liberate themselves from your feeble chest; you sure you want to challenge destiny, [owner.name]?"))

/obj/limb/chest/proc/cancel_defib_heal()
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_DEFIB_HEAL

/obj/limb/chest/proc/bonus_burn_damage(var/mob/living/M, list/damagedata)
	SIGNAL_HANDLER
	damagedata["damage_bonus"] *= burn_damage_bonus

/obj/limb/groin
	name = "groin"
	icon_name = "groin"
	display_name = "groin"
	max_damage = 200
	min_broken_damage = 30
	body_part = BODY_FLAG_GROIN
	splint_icon_amount = 1
	bandage_icon_amount = 2

/obj/limb/groin/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_MAJOR)
		owner.xeno_neurotoxin_buff -= 1.5
	else if(added & LIMB_INTEGRITY_EFFECT_MAJOR)
		to_chat(owner, SPAN_DANGER("You start to feel more vulnerable to toxins, as you feel your kidneys start to oppose your mad persistence."))
		owner.xeno_neurotoxin_buff += 1.5
	if(removed & LIMB_INTEGRITY_EFFECT_SERIOUS)
		UnregisterSignal(owner, COMSIG_MOB_INGESTION)
	else if(added & LIMB_INTEGRITY_EFFECT_SERIOUS)
		to_chat(owner, SPAN_DANGER("Your stomach and guts begin to shut off like a power grid. God save you, for no medicine will."))
		RegisterSignal(owner, COMSIG_MOB_INGESTION, .proc/ingestion_cancel)

/obj/limb/groin/proc/ingestion_cancel(mob/living/carbon/human/H, obj/item/reagent_container/ingested)
	SIGNAL_HANDLER
	var/turf/T = get_turf(H)
	to_chat(H, SPAN_WARNING("You violently throw up a chunk of the contents of \the [ingested] as your body fails to properly digest it!")) // hey maybe you should go to a doctor MAYBE
	H.nutrition -= 20
	H.apply_damage(-3, TOX)
	playsound(T, 'sound/effects/splat.ogg', 25, 1, 7)
	T.add_vomit_floor(H)

	for(var/datum/reagent/R in ingested.reagents.reagent_list)
		H.reagents.remove_reagent(R.id, R.volume/2)

/obj/limb/leg
	name = "leg"
	display_name = "leg"
	max_damage = 35
	min_broken_damage = 20
	var/climb_delay_mult = 2.0
	var/drag_delay_mult = 1.5
	var/bonus_knockdown = 1

/obj/limb/leg/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_MAJOR)
		UnregisterSignal(owner, list(
			COMSIG_LIVING_CLIMB_STRUCTURE,
			COMSIG_MOB_ADD_DRAG_DELAY))
	else if(added & LIMB_INTEGRITY_EFFECT_MAJOR)
		to_chat(owner, SPAN_DANGER("Your legs feel limper and weaker; perhaps climbing and dragging wouldn't be a good idea."))
		RegisterSignal(owner, COMSIG_LIVING_CLIMB_STRUCTURE, .proc/handle_climb_delay)
		RegisterSignal(owner, COMSIG_MOB_ADD_DRAG_DELAY, .proc/handle_drag_delay)
	if(removed & LIMB_INTEGRITY_EFFECT_SERIOUS)
		UnregisterSignal(owner, COMSIG_MOB_ADD_KNOCKDOWN)
	else if(added & LIMB_INTEGRITY_EFFECT_SERIOUS)
		to_chat(owner, SPAN_DANGER("Your legs buckle just standing up, this could be very bad if you got knocked over!"))
		RegisterSignal(owner, COMSIG_MOB_ADD_KNOCKDOWN, .proc/add_knockdown)

/obj/limb/leg/proc/add_knockdown(var/mob/living/M, list/knockdowndata)
	SIGNAL_HANDLER
	knockdowndata["knockdown"] += bonus_knockdown

/obj/limb/leg/proc/handle_climb_delay(var/mob/living/M, list/climbdata)
	SIGNAL_HANDLER
	climbdata["climb_delay"] *= climb_delay_mult

/obj/limb/leg/proc/handle_drag_delay(var/mob/living/M, list/dragdata)
	SIGNAL_HANDLER
	dragdata["drag_delay"] *= drag_delay_mult

/obj/limb/foot
	name = "foot"
	display_name = "foot"
	max_damage = 30
	min_broken_damage = 20
	var/move_delay_mult = HUMAN_SLOWED_AMOUNT

/obj/limb/foot/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_SERIOUS)
		UnregisterSignal(owner, COMSIG_HUMAN_POST_MOVE_DELAY)
	else if(added & LIMB_INTEGRITY_EFFECT_SERIOUS)
		to_chat(owner, SPAN_DANGER("You feel significantly more slower, as your feet can no longer handle your movement!"))
		RegisterSignal(owner, COMSIG_HUMAN_POST_MOVE_DELAY, .proc/increase_move_delay)

/obj/limb/foot/proc/increase_move_delay(var/mob/living/M, list/movedata)
	SIGNAL_HANDLER
	return COMPONENT_HUMAN_MOVE_DELAY_MALUS

/obj/limb/arm
	name = "arm"
	display_name = "arm"
	max_damage = 35
	min_broken_damage = 20
	var/work_delay_mult = 1.3 // 30% increase

/obj/limb/arm/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_MINOR)
		UnregisterSignal(owner, COMSIG_MOB_ADD_DELAY)
	else if(added & LIMB_INTEGRITY_EFFECT_MINOR)
		to_chat(owner, SPAN_DANGER("Your arms begin to tremble in weakness; this may be horrible for any work you have planned."))
		RegisterSignal(owner, COMSIG_MOB_ADD_DELAY, .proc/increase_work_delay)
	if(removed & LIMB_INTEGRITY_EFFECT_MAJOR)
		owner.minimum_wield_delay -= 5
	else if(added & LIMB_INTEGRITY_EFFECT_MAJOR)
		to_chat(owner, SPAN_DANGER("You feel as if your arms have weights strapped against them, forcing you to exert yourself to raise any weapon or tool!"))
		owner.minimum_wield_delay += 5
	if(removed & LIMB_INTEGRITY_EFFECT_SERIOUS)
		work_delay_mult = 1.3
	else if(added & LIMB_INTEGRITY_EFFECT_SERIOUS)
		to_chat(owner, SPAN_DANGER("Your arms look flayed and beaten like two roadkills, looking like any plans you had for them are borderline Heruclean."))
		work_delay_mult = 2.0

/obj/limb/arm/proc/increase_work_delay(var/mob/living/M, list/delaydata)
	SIGNAL_HANDLER
	delaydata["work_delay"] *= work_delay_mult

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
	min_broken_damage = 20
	var/obj/item/c_hand
	var/hand_name = "ambidexterous hand"

/obj/limb/hand/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_MINOR)
		owner.action_delay -= 8
	else if(added & LIMB_INTEGRITY_EFFECT_MINOR)
		to_chat(owner, SPAN_DANGER("Your hands become less responsive due to the tears on them, you're definitely going to need more time to solve stuff now."))
		owner.action_delay += 8
	if(removed & LIMB_INTEGRITY_EFFECT_MAJOR)
		UnregisterSignal(owner, COMSIG_MOB_ADD_RECOIL)
	else if(added & LIMB_INTEGRITY_EFFECT_MAJOR)
		to_chat(owner, SPAN_DANGER("Your hands struggle to deal with any future recoil, as the wounds eat away at your flesh and bone."))
		RegisterSignal(owner, COMPONENT_ADD_RECOIL, .proc/decrease_gun_handling)

/obj/limb/hand/proc/decrease_gun_handling()
	SIGNAL_HANDLER
	return COMPONENT_ADD_RECOIL

/obj/limb/hand/process()
	..()
	process_grasp(c_hand, hand_name)

/obj/limb/hand/proc/process_grasp(c_hand, hand_name)
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
	min_broken_damage = 30
	body_part = BODY_FLAG_HEAD
	vital = 1
	encased = "skull"
	has_stump_icon = TRUE
	splint_icon_amount = 4
	bandage_icon_amount = 4
	var/disfigured = 0 //whether the head is disfigured.
	var/face_surgery_stage = 0

	natural_int_dmg_resist = 0.6

/obj/limb/head/reapply_integrity_effects(added, removed)
	..()
	if(removed & LIMB_INTEGRITY_EFFECT_MAJOR)
		UnregisterSignal(owner, list(COMSIG_MOB_PRE_ITEM_ZOOM,
		 COMSIG_MOB_APPLY_STUTTER))
	else if(added & LIMB_INTEGRITY_EFFECT_MAJOR)
		to_chat(owner, SPAN_DANGER("The damage to your head has caused black and red to splay all over your eyesight, and force a fuzzy feeling in your head."))
		RegisterSignal(owner, COMSIG_MOB_PRE_ITEM_ZOOM, .proc/block_zoom)
		RegisterSignal(owner, COMSIG_MOB_APPLY_STUTTER, .proc/handle_stutter)
	if(removed & LIMB_INTEGRITY_EFFECT_SERIOUS)
		UnregisterSignal(owner, list(COMSIG_MOB_PRE_GLASSES_SIGHT_BONUS,
		 COMSIG_MOB_PRE_EYE_TINTCHECK))
	else if(added & LIMB_INTEGRITY_EFFECT_SERIOUS)
		to_chat(owner, SPAN_DANGER("You definitely feel hell in your head, as you struggle to see, think or feel anything. Any more damage might make your head burst!"))
		RegisterSignal(owner, COMSIG_MOB_PRE_GLASSES_SIGHT_BONUS, .proc/block_night_vision)
		RegisterSignal(owner, COMSIG_MOB_PRE_EYE_TINTCHECK, .proc/add_eye_tint)

/obj/limb/head/proc/block_zoom(obj/item/O)
	SIGNAL_HANDLER
	to_chat(owner, SPAN_WARNING("You try to look through [O], but the blood and pain clouding your vision forces you to rub your eyes, lowering it in the process!"))
	return COMPONENT_CANCEL_ZOOM

/obj/limb/head/proc/block_night_vision()
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_GLASSES_SIGHT_BONUS

/obj/limb/head/proc/add_eye_tint()
	SIGNAL_HANDLER
	return COMPONENT_ADD_EYETINT

/obj/limb/head/proc/handle_stutter()
	SIGNAL_HANDLER
	return COMPONENT_ADD_STUTTERING

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
