

// Surgery Tools
/obj/item/tool/surgery
	icon = 'icons/obj/items/surgery_tools.dmi'
	attack_speed = 4 // reduced

/*
 * Retractor
 * Usual substitutes: crowbar for heavy prying, wirecutter for fine adjustment. Fork for extremely fine work.
 */
/obj/item/tool/surgery/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon_state = "retractor"
	matter = list("metal" = 10000, "glass" = 5000)
	flags_atom = FPRINT|CONDUCT
	w_class = SIZE_SMALL

/obj/item/tool/surgery/retractor/predatorretractor
	name = "opener"
	desc = "Retracts stuff."
	icon_state = "predator_retractor"

/*
 * Hemostat
 * Usual substitutes: wirecutter for clamping bleeds or pulling things out, fork for extremely fine work, surgical line/fixovein/cable coil for tying up blood vessels.
 */
/obj/item/tool/surgery/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon_state = "hemostat"
	matter = list("metal" = 5000, "glass" = 2500)
	flags_atom = FPRINT|CONDUCT
	w_class = SIZE_SMALL

	attack_verb = list("attacked", "pinched")

/obj/item/tool/surgery/hemostat/predatorhemostat
	name = "pincher"
	desc = "You think you have seen this before."
	icon_state = "predator_hemostat"

/*
 * Cautery
 * Usual substitutes: cigarettes, lighters, welding tools.
 */
/obj/item/tool/surgery/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon_state = "cautery"
	matter = list("metal" = 5000, "glass" = 2500)
	flags_atom = FPRINT|CONDUCT
	w_class = SIZE_TINY
	flags_item = ANIMATED_SURGICAL_TOOL

	attack_verb = list("burnt")

/obj/item/tool/surgery/cautery/predatorcautery
	name = "cauterizer"
	desc = "This stops bleeding."
	icon_state = "predator_cautery"
	flags_item = NO_FLAGS

/*
 * Surgical Drill
 * Usual substitutes: pen, metal rods.
 */
/obj/item/tool/surgery/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	matter = list("metal" = 15000, "glass" = 10000)
	flags_atom = FPRINT|CONDUCT
	force = 0
	w_class = SIZE_SMALL

	attack_verb = list("drilled")

/obj/item/tool/surgery/surgicaldrill/predatorsurgicaldrill
	name = "bone drill"
	desc = "You can drill using this item. You dig?"
	icon_state = "predator_drill"

/*
 * Scalpel
 * Usual substitutes: bayonets, kitchen knives, glass shards.
 */
/obj/item/tool/surgery/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon_state = "scalpel"
	flags_atom = FPRINT|CONDUCT
	force = 10.0
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1
	w_class = SIZE_TINY
	throwforce = 5.0
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	matter = list("metal" = 10000, "glass" = 5000)

	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/tool/surgery/scalpel/predatorscalpel
	name = "cutter"
	desc = "Cut, cut, and once more cut."
	icon_state = "predator_scalpel"

/*
 * Researchable Scalpels
 */
/obj/item/tool/surgery/scalpel/laser
	name = "prototype laser scalpel"
	desc = "A scalpel augmented with a directed laser, for controlling bleeding as the incision is made. Also functions as a cautery. This one looks like an unreliable early model."
	icon_state = "scalpel_laser"
	damtype = "fire"
	flags_item = ANIMATED_SURGICAL_TOOL
	///The likelihood an incision made with this will be bloodless.
	var/bloodlessprob = 60

/obj/item/tool/surgery/scalpel/laser/improved
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for controlling bleeding as the incision is made. Also functions as a cautery. This one looks trustworthy, though it could be better."
	icon_state = "scalpel_laser_2"
	damtype = "fire"
	force = 12.0
	bloodlessprob = 80

/obj/item/tool/surgery/scalpel/laser/advanced
	name = "advanced laser scalpel"
	desc = "A scalpel augmented with a directed laser, for controlling bleeding as the incision is made. Also functions as a cautery. This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser_3"
	damtype = "fire"
	force = 15.0
	bloodlessprob = 100

/*
 * Special Variants
 */

/obj/item/tool/surgery/scalpel/pict_system
	name = "PICT system"
	desc = "The Precision Incision and Cauterization Tool uses a high-frequency vibrating blade, laser cautery, and suction liquid control system to precisely sever target tissues while preventing all fluid leakage. Despite its troubled development program and horrifying pricetag, outside of complex experimental surgeries it isn't any better than an ordinary twenty-dollar scalpel and can't create a full-length incision bloodlessly."
	icon_state = "pict_system"
	w_class = SIZE_SMALL
	force = 7.5

/obj/item/tool/surgery/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager"
	force = 7.5
	flags_item = ANIMATED_SURGICAL_TOOL

/*
 * Circular Saw
 * Usual substitutes: fire axes, machetes, hatchets, butcher's knife, bayonet. Bayonet is better than axes etc. for sawing ribs/skull, worse for amputation.
 */

/obj/item/tool/surgery/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon_state = "saw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags_atom = FPRINT|CONDUCT
	force = 0
	w_class = SIZE_SMALL
	throwforce = 9.0
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	matter = list("metal" = 20000,"glass" = 10000)
	flags_item = ANIMATED_SURGICAL_TOOL

	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

/obj/item/tool/surgery/circular_saw/predatorbonesaw
	name = "bone saw"
	desc = "For heavy duty cutting."
	icon_state = "predator_bonesaw"
	flags_item = NO_FLAGS

/*
 * Bone Gel
 * Usual substitutes: screwdriver.
 */

/obj/item/tool/surgery/bonegel
	name = "bone gel"
	icon_state = "bone-gel"
	force = 0
	throwforce = 1.0
	w_class = SIZE_SMALL

/obj/item/tool/surgery/bonegel/predatorbonegel
	name = "gel gun"
	icon_state = "predator_bone-gel"

/*
 * Fix-o-Vein
 * Usual substitutes: surgical line, cable coil, headbands.
 */

/obj/item/tool/surgery/FixOVein
	name = "FixOVein"
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0

	w_class = SIZE_SMALL
	var/usage_amount = 10

/obj/item/tool/surgery/FixOVein/predatorFixOVein
	name = "vein fixer"
	icon_state = "predator_fixovein"

/*
 * Surgical line.
 * Usual substitutes: fixovein, cable coil, headbands.
 */

/obj/item/tool/surgery/surgical_line
	name = "surgical line"
	desc = "A roll of military-grade surgical line, able to seamlessly seal and tend any wound. Also works as a robust fishing line for maritime deployments."
	icon_state = "line"
	force = 0
	throwforce = 1.0
	w_class = SIZE_SMALL

/*
 * Bonesetter.
 * Usual substitutes: wrench.
 */

/obj/item/tool/surgery/bonesetter
	name = "bone setter"
	icon_state = "bonesetter"
	force = 0
	throwforce = 9.0
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	w_class = SIZE_SMALL
	attack_verb = list("attacked", "hit", "bludgeoned")
	matter = list("plastic" = 7500)

/obj/item/tool/surgery/bonesetter/predatorbonesetter
	name = "bone placer"
	icon_state = "predator_bonesetter"

/*
WILL BE USED AT A LATER TIME

t. optimisticdude

/obj/item/tool/surgery/handheld_pump
	name = "handheld surgical pump"
	desc = "This sucks. Literally"
	icon_state = "pump"
	force = 0
	throwforce = 9.0
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	w_class = SIZE_SMALL
	attack_verb = list("attacked", "hit", "bludgeoned")
	matter = list("plastic" = 7500)
*/

/obj/item/tool/surgery/drapes //Does nothing at present. Might be useful for increasing odds of success.
	name = "surgical drapes"
	desc = "Used to cover a limb prior to the beginning of a surgical procedure"
	icon_state = "drapes"
	w_class = SIZE_SMALL
	flags_item = NOBLUDGEON

// XENO AUTOPSY TOOL
// In the future, perhaps we can make /obj/item/XenoBio items useful?

/obj/item/tool/surgery/xeno_autopsy
	name = "Weyland Brand Automatic Autopsy System(TM)"
	desc = "Putting the FUN back in Autopsy.  This little gadget performs an entire autopsy of whatever strange life form you've found."
	icon_state = "scalpel_laser_2"
	damtype = "fire"
	force = 0
	flags_item = ANIMATED_SURGICAL_TOOL
	// just so they can't be spammed from the medilathe
	matter = list("glass" = 10000, "plastic" = 10000)
	// this is important to prevent multi-use
	in_use = FALSE

/obj/item/tool/surgery/xeno_autopsy/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("There are multiple restrictions to this tool: The xenomorph must be on an operating table and on the ship."))
	to_chat(user, SPAN_NOTICE("Additionally, you must be proficient in research."))
	to_chat(user, SPAN_NOTICE("It is recommended to have a PICT in the other hand; otherwise, there is a chance to have acid spray onto you."))

// to reduce the amount of lines required for the code
/obj/item/tool/surgery/xeno_autopsy/proc/failure_message(var/message = null, mob/living/user, var/allow_usage = FALSE)
	to_chat(user, SPAN_HELPFUL("W.B.A.A.S. states: ") + message)
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25)
	if(allow_usage)
		in_use = FALSE

// to reduce the amount of lines required for the code
/obj/item/tool/surgery/xeno_autopsy/proc/start_autopsy(var/amount, mob/living/carbon/Xenomorph/xeno, mob/living/user)
	// at minimum, a thirty(30) percent chance; at maximum, a one hundred(100) percent chance
	var/success_chance = ((3 + user.skills.get_skill_level(SKILL_MEDICAL) + user.skills.get_skill_level(SKILL_SURGERY)) * 10)
	// this is why xeno tier is so important, damn xeno queens
	for(var/iterating_autopsy in 1 to amount)
		playsound(loc, 'sound/weapons/pierce.ogg', 25)
		to_chat(user, SPAN_WARNING("You begin working carefully on [xeno]..."))
		// you have to go for it, or suffer the consequence
		if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_MEDICAL))
			failure_message(SPAN_WARNING("Warning! Aborting the operation may lead to injury!"), user, TRUE)
			user.apply_damage(10, BURN)
			xeno.autopsy_performed = TRUE
			return
		// can only work if xeno is on a table
		var/table_check = FALSE
		var/turf/xeno_turf = get_turf(xeno)
		for(var/obj/check_obj in xeno_turf.contents)
			if(check_obj.surgery_duration_multiplier == SURGERY_SURFACE_MULT_IDEAL)
				table_check = TRUE
				break
		if(!table_check)
			failure_message(SPAN_WARNING("Warning! Xenomorphs can only be operated on whilst on an operating table!"), user, TRUE)
			xeno.autopsy_performed = TRUE
			return
		// you better hope you have a PICT in your other hand
		if(!istype(user.l_hand, /obj/item/tool/surgery/scalpel/pict_system) && !istype(user.r_hand, /obj/item/tool/surgery/scalpel/pict_system))
			if(prob(75))
				// this is gonna hurt
				xeno.check_blood_splash(20, TOX, 100, 2)
				failure_message(SPAN_WARNING("Warning! It is highly recommended to hold a W-Y approved PICT system!"), user)
		// you had the skills to gain a research credit, nice
		if(prob(success_chance))
			to_chat(user, SPAN_HELPFUL("W.B.A.A.S. states: ") + SPAN_NOTICE("This portion of the autopsy was a success!"))
			chemical_data.update_credits(1)
		// you failed
		else
			failure_message(SPAN_WARNING("This portion of the autopsy was a failure!"), user)
	// we only get to this point once all the iterating_autopsy has been completed
		to_chat(user, SPAN_HELPFUL("W.B.A.A.S. states: ") + SPAN_NOTICE("Thank you for using the W.B.A.A.S.!"))
	playsound(loc, 'sound/machines/ping.ogg', 25)
	in_use = FALSE
	xeno.autopsy_performed = TRUE

/obj/item/tool/surgery/xeno_autopsy/attack(mob/living/M, mob/living/user)
	// no spamming the tool
	if(in_use)
		failure_message(SPAN_WARNING("\The [src] is already in use!"), user, FALSE)
		return
	in_use = TRUE
	// have to have some research skill
	if(!skillcheck(user, SKILL_RESEARCH, SKILL_RESEARCH_TRAINED))
		failure_message(SPAN_WARNING("Warning! You are not qualified skill-wise to use this tool!"), user, TRUE)
		return
	// can only work on xenos
	if(!isXeno(M))
		failure_message(SPAN_WARNING("Warning! This tool may only be used on Xenomorphs!"), user, TRUE)
		return
	var/mob/living/carbon/Xenomorph/attacked_xeno = M
	// can only work on *dead* xenos
	if(attacked_xeno.stat != DEAD)
		failure_message(SPAN_WARNING("Warning! This tool may only be used on DEAD Xenomorphs"), user, TRUE)
		return
	if(attacked_xeno.autopsy_performed)
		failure_message(SPAN_WARNING("Warning! This tool cannot be used on an already operated on Xenomorph"), user, TRUE)
		return
	var/turf/xeno_turf = get_turf(attacked_xeno)
	// can only work if on the ship
	if(!is_mainship_level(xeno_turf.z))
		failure_message(SPAN_WARNING("Warning! This tool can only be used in proper locations! Return to to a W-Y owned corporate vessel!"), user, TRUE)
		return
	// can only work if xeno is on a table
	var/table_check = FALSE
	for(var/obj/check_obj in xeno_turf.contents)
		if(check_obj.surgery_duration_multiplier == SURGERY_SURFACE_MULT_IDEAL)
			table_check = TRUE
			break
	if(!table_check)
		failure_message(SPAN_WARNING("Warning! Xenomorphs can only be operated on whilst on an operating table!"), user, TRUE)
		return
	// you have to actually wait a little to activate the tool
	to_chat(user, SPAN_NOTICE("You slowly raise \the [src] up to [attacked_xeno], preparing for the autopsy."))
	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_MEDICAL))
		failure_message(SPAN_WARNING("Warning! Aborting the operation may lead to injury!"), user, TRUE)
		return
	//xeno queens are tier 0... so we are going to falsify the xeno tier here
	if(isXenoQueen(attacked_xeno))
		start_autopsy(4, attacked_xeno, user)
		return
	//proceed to the autopsy with the xeno tier in mind
	start_autopsy(attacked_xeno.tier, attacked_xeno, user)
