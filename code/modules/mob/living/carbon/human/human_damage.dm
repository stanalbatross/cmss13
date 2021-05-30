//Updates the mob's health from limbs and mob damage variables
/mob/living/carbon/human/updatehealth()

	if(status_flags & GODMODE)
		health = species.total_health
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	for(var/obj/limb/O in limbs)	//hardcoded to streamline things a bit
		total_brute	+= O.brute_dam
		total_burn	+= O.burn_dam

	var/oxy_l = ((species && species.flags & NO_BREATHE) ? 0 : getOxyLoss())
	var/tox_l = ((species && species.flags & NO_POISON) ? 0 : getToxLoss())
	var/clone_l = getCloneLoss()

	health = ((species != null)? species.total_health : 200) - oxy_l - tox_l - clone_l - total_burn - total_brute

	if(isSynth(src) && pulledby && health <= 0 && isXeno(pulledby))	// Xenos lose grab on critted synths
		pulledby.stop_pulling()

	recalculate_move_delay = TRUE

	med_hud_set_health()
	med_hud_set_armor()
	med_hud_set_status()



/mob/living/carbon/human/adjustBrainLoss(var/amount)

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(sponge)
			sponge.take_damage(amount)
			sponge.damage = Clamp(sponge.damage, 0, maxHealth*2)
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/setBrainLoss(var/amount)

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(sponge)
			sponge.damage = Clamp(amount, 0, maxHealth*2)
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/getBrainLoss()

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(istype(sponge)) //Make sure they actually have a brain
			brainloss = min(sponge.damage,maxHealth*2)
		else
			brainloss = 50 //No brain!
	else
		brainloss = 0
	return brainloss

//These procs fetch a cumulative total damage from all limbs
/mob/living/carbon/human/getBruteLoss(var/organic_only=0)
	var/amount = 0
	for(var/obj/limb/O in limbs)
		if(!(organic_only && O.status & LIMB_ROBOT))
			amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss(var/organic_only=0)
	var/amount = 0
	for(var/obj/limb/O in limbs)
		if(!(organic_only && O.status & LIMB_ROBOT))
			amount += O.burn_dam
	return amount


/mob/living/carbon/human/adjustBruteLoss(var/amount)
	if(species.brute_mod && amount > 0)
		amount = amount*species.brute_mod

	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)


/mob/living/carbon/human/adjustFireLoss(var/amount)
	if(species && species.burn_mod && amount > 0)
		amount = amount*species.burn_mod

	if(amount > 0)
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)


/mob/living/carbon/human/proc/adjustBruteLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	if(species && species.brute_mod && amount > 0)
		amount = amount*species.brute_mod

	for(var/X in limbs)
		var/obj/limb/O = X
		if(O.name == organ_name)
			if(amount > 0)
				O.take_damage(amount, 0, int_dmg_multiplier = INT_DMG_MULTIPLIER_NORMAL, used_weapon=damage_source)
			else
				//if you don't want to heal robot limbs, they you will have to check that yourself before using this proc.
				O.heal_damage(-amount, 0, internal=0, robo_repair=(O.status & LIMB_ROBOT))
			break



/mob/living/carbon/human/proc/adjustFireLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	if(species && species.burn_mod && amount > 0)
		amount = amount*species.burn_mod

	for(var/X in limbs)
		var/obj/limb/O = X
		if(O.name == organ_name)
			if(amount > 0)
				O.take_damage(0, amount, 0, used_weapon=damage_source)
			else
				//if you don't want to heal robot limbs, they you will have to check that yourself before using this proc.
				O.heal_damage(0, -amount, internal=0, robo_repair=(O.status & LIMB_ROBOT))
			break



/mob/living/carbon/human/getCloneLoss()
	if(species && species.flags & (IS_SYNTHETIC|NO_CLONE_LOSS))
		cloneloss = 0
	return ..()

/mob/living/carbon/human/setCloneLoss(var/amount)
	if(species && species.flags & (IS_SYNTHETIC|NO_CLONE_LOSS))
		cloneloss = 0
	else
		..()

/mob/living/carbon/human/adjustCloneLoss(var/amount)
	..()

	if(species && species.flags & (IS_SYNTHETIC|NO_CLONE_LOSS))
		cloneloss = 0
		return

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss()+10)
	if(amount > 0)
		if(prob(mut_prob))
			var/list/obj/limb/candidates = list()
			for(var/obj/limb/O in limbs)
				if(O.status & (LIMB_ROBOT|LIMB_DESTROYED|LIMB_MUTATED)) continue
				candidates |= O
			if(candidates.len)
				var/obj/limb/O = pick(candidates)
				O.mutate()
				to_chat(src, SPAN_NOTICE("Something is not right with your [O.display_name]..."))
				return
	else
		if(prob(heal_prob))
			for(var/obj/limb/O in limbs)
				if(O.status & LIMB_MUTATED)
					O.unmutate()
					to_chat(src, SPAN_NOTICE("Your [O.display_name] is shaped normally again."))
					return

	if(getCloneLoss() < 1)
		for(var/obj/limb/O in limbs)
			if(O.status & LIMB_MUTATED)
				O.unmutate()
				to_chat(src, SPAN_NOTICE("Your [O.display_name] is shaped normally again."))


// Defined here solely to take species flags into account without having to recast at mob/living level.
/mob/living/carbon/human/getOxyLoss()
	if(species && species.flags & NO_BREATHE)
		oxyloss = 0
	return ..()

/mob/living/carbon/human/adjustOxyLoss(var/amount)
	if(species && species.flags & NO_BREATHE)
		oxyloss = 0
	else
		..()

/mob/living/carbon/human/setOxyLoss(var/amount)
	if(species && species.flags & NO_BREATHE)
		oxyloss = 0
	else
		..()

/mob/living/carbon/human/getToxLoss()
	if(species && species.flags & NO_POISON)
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(var/amount)
	if(species && species.flags & NO_POISON)
		toxloss = 0
	else
		..()

/mob/living/carbon/human/setToxLoss(var/amount)
	if(species && species.flags & NO_POISON)
		toxloss = 0
	else
		..()

////////////////////////////////////////////

//Returns a list of damaged limbs
/mob/living/carbon/human/proc/get_damaged_limbs(var/brute, var/burn, var/integrity)
	var/list/obj/limb/parts = list()
	for(var/obj/limb/O in limbs)
		if((brute && O.brute_dam) || (burn && O.burn_dam) || (internal && O.integrity_damage))
			parts += O
	return parts


//Returns a list of damageable limbs
/mob/living/carbon/human/proc/get_damageable_limbs()
	var/list/obj/limb/parts = list()
	for(var/obj/limb/O in limbs)
		if(O.brute_dam + O.burn_dam < O.max_damage)
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_limb_damage(var/brute, var/burn)
	var/list/obj/limb/parts = get_damaged_limbs(brute,burn)
	if(!parts.len)
		return
	var/obj/limb/picked = pick(parts)
	if(brute != 0)
		apply_damage(-brute, BRUTE, picked)
	if(burn != 0)
		apply_damage(-burn, BURN, picked)
	UpdateDamageIcon()
	updatehealth()


/*
In most cases it makes more sense to use apply_damage() instead! And make sure to check armour if applicable.
*/
//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_limb_damage(var/brute, var/burn, var/int_dmg_multiplier = INT_DMG_MULTIPLIER_NORMAL)
	var/list/obj/limb/parts = get_damageable_limbs()
	if(!parts.len)	return
	var/obj/limb/picked = pick(parts)
	if(brute != 0)
		apply_damage(brute, BRUTE, picked, int_dmg_multiplier = INT_DMG_MULTIPLIER_NORMAL)
	if(burn != 0)
		apply_damage(burn, BURN, picked, int_dmg_multiplier = INT_DMG_MULTIPLIER_NORMAL)
	UpdateDamageIcon()
	updatehealth()
	speech_problem_flag = 1

//Heal MANY limbs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn, var/robo_repair = FALSE)
	var/list/obj/limb/parts = get_damaged_limbs(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute, burn, 0, robo_repair)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	speech_problem_flag = 1
	if(update)	UpdateDamageIcon()

// damage MANY limbs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn, var/sharp = 0, var/edge = 0, var/used_weapon = null)
	if(status_flags & GODMODE)
		return	//godmode
	var/list/obj/limb/parts = get_damageable_limbs()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.take_damage(brute,burn,sharp,edge,used_weapon)
		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked
	updatehealth()
	if(update)	UpdateDamageIcon()


////////////////////////////////////////////



/*
This function restores all limbs.
*/
/mob/living/carbon/human/restore_all_organs()
	for(var/obj/limb/E in limbs)
		E.rejuvenate()

	//replace missing internal organs
	for(var/organ_slot in species.has_organ)
		var/internal_organ_type = species.has_organ[organ_slot]
		if(!internal_organs_by_name[organ_slot])
			var/datum/internal_organ/IO = new internal_organ_type(src)
			internal_organs_by_name[organ_slot] = IO

/mob/living/carbon/human/heal_integrity_damage()
	for(var/obj/limb/E in limbs)
		E.set_integrity_level(LIMB_INTEGRITY_PERFECT)

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/limb/E = get_limb(zone)
	if(E.heal_damage(brute, burn))
		UpdateDamageIcon()


/mob/living/carbon/proc/get_limb(zone)
	return

/mob/living/carbon/human/get_limb(zone)
	RETURN_TYPE(/obj/limb)
	zone = check_zone(zone)
	return (locate(limb_types_by_name[zone]) in limbs)


/mob/living/carbon/human/apply_armoured_damage(var/damage = 0, var/armour_type = ARMOR_MELEE, var/damage_type = BRUTE, var/def_zone = null, var/penetration = 0, var/armour_break_pr_pen = 0, var/armour_break_flat = 0)
	if(damage <= 0)
		return ..(damage, armour_type, damage_type, def_zone)

	var/obj/limb/target_limb = null
	if(def_zone)
		target_limb = get_limb(check_zone(def_zone))
	else
		target_limb = get_limb(check_zone(rand_zone()))
	if(isnull(target_limb))
		return FALSE

	var/armor = getarmor(target_limb, armour_type)

	var/armour_config = GLOB.marine_ranged
	if(armour_type == ARMOR_MELEE)
		armour_config = GLOB.marine_melee

	var/modified_damage = armor_damage_reduction(armour_config, damage, armor, penetration, 0, 0)
	apply_damage(modified_damage, damage_type, target_limb)

	return modified_damage

/*
	Describes how human mobs get damage applied.
	Less clear vars:
	*	impact_name: name of an "impact icon." For now, is only relevant for projectiles but can be expanded to apply to melee weapons with special impact sprites.
	*	impact_limbs: the flags for which limbs (body parts) have an impact icon associated with impact_name.
	*	permanent_kill: whether this attack causes human to become irrevivable
*/
/mob/living/carbon/human/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, \
	var/int_dmg_multiplier = 1,var/obj/used_weapon = null, var/no_limb_loss = FALSE, \
	var/impact_name = null, var/impact_limbs = null, var/permanent_kill = FALSE, var/mob/firer = null, \
	var/force = FALSE
)
	if(protection_aura && damage > 0)
		damage = round(damage * ((ORDER_HOLD_CALC_LEVEL - protection_aura) / ORDER_HOLD_CALC_LEVEL))

	//Handle other types of damage
	if(damage < 0 || (damagetype != BRUTE) && (damagetype != BURN))
		if(damagetype == HALLOSS && pain.feels_pain)
			if((damage > 25 && prob(20)) || (damage > 50 && prob(60)))
				INVOKE_ASYNC(src, .proc/emote, "pain")

		..(damage, damagetype, def_zone)
		return TRUE

	if(SEND_SIGNAL(src, COMSIG_HUMAN_TAKE_DAMAGE, damage, damagetype) & COMPONENT_BLOCK_DAMAGE) return

	var/obj/limb/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)
			def_zone = rand_zone(def_zone)
		organ = get_limb(check_zone(def_zone))
	if(!organ)
		return FALSE

	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(species.brute_mod && !force)
				damage = damage * species.brute_mod

			organ.take_damage(damage, 0, int_dmg_multiplier, attack_source = firer)

		if(BURN)
			damageoverlaytemp = 20
			if(species.burn_mod && !force)
				damage = damage * species.burn_mod
			if(SEND_SIGNAL(src, COMSIG_MOB_BONUS_DAMAGE) & COMPONENT_ADD_DMG_MODIFIER)
				damage = damage * 1.5

			organ.take_damage(0, damage, int_dmg_multiplier, attack_source = firer)


	pain.apply_pain(damage, damagetype)

	if(permanent_kill)
		status_flags |= PERMANENTLY_DEAD

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()
	return TRUE

// Heal or damage internal organs
// Organ has to be either a internal organ by string or a limb with internal organs in.
/mob/living/carbon/human/apply_internal_damage(var/damage = 0, var/organ)
	if(!damage)
		return

	var/obj/limb/L = null
	var/datum/internal_organ/I
	if(internal_organs_by_name[organ])
		I = internal_organs_by_name[organ]
	else if(istype(organ, /datum/internal_organ))
		I = organ
	else
		if(isorgan(organ))
			L = organ
		else
			L = get_limb(check_zone(organ))
		if(istype(L) && !isnull(L) && L.internal_organs)
			I = pick(internal_organs)

	if(isnull(I))
		return

	if(istype(I) && !isnull(I))
		if(damage > 0)
			I.take_damage(damage)
		else
			// The damage is negative so we want to heal, but heal damage only takes positive numbers.
			I.heal_damage(-1 * damage)

	pain.apply_pain(damage * PAIN_ORGAN_DAMAGE_MULTIPLIER)

/mob/living/carbon/human/apply_stamina_damage(var/damage, var/def_zone, var/armor_type)
	if(!def_zone || !armor_type || !stamina)
		return ..()

	var/armor = getarmor(def_zone, armor_type)

	var/damage_to_deal = damage * max(1 - (armor / CLOTHING_ARMOR_ULTRAHIGH), 0.1) // stamina damage. Has to deal 10% or less stamina damage, can't be any lower

	if(reagents && reagents.has_reagent("antag_stimulant"))
		damage_to_deal *= 0.25 // Massively reduced effectiveness

	stamina.apply_damage(damage_to_deal)
