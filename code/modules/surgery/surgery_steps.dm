/datum/surgery_step
	var/list/allowed_tools = list(null) //Array of type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_species = null //List of names referencing mutantraces that this step applies to.
	var/list/disallowed_species = null

	var/min_duration = 0 //Minimum duration of the step
	var/max_duration = 0 //Maximum duration of the step

	var/can_infect = 0 //Evil infection stuff that will make everyone hate me
	var/blood_level = 0 //How much blood this step can get on surgeon. 1 - hands, 2 - full body

	//Returns how well tool is suited for this step
	proc/tool_quality(obj/item/tool)
		for(var/T in allowed_tools)
			if(isnull(T) && isnull(tool)) //Bare hands
				return 100
			else
				if(istype(tool, T))
					return allowed_tools[T]
		return FALSE

//Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return FALSE
	if(allowed_species)
		for(var/species in allowed_species)
			if(target.species.name == species)
				return TRUE

	if(disallowed_species)
		for(var/species in disallowed_species)
			if(target.species.name == species)
				return FALSE
	return TRUE


//Checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_do_step(mob/living/carbon/human/user, datum/surgery_procedure/surgery, obj/item/tool)
	if(isnull(tool)) 
		if(allowed_tools.Find(null))
			return TRUE
	else
		if(allowed_tools.Find(tool.type))
			return TRUE

//Does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/carbon/human/user, datum/surgery_procedure/surgery)
	if(prob(60))
		if(blood_level)
			user.bloody_hands(user, 0)
		if(blood_level > 1)
			user.bloody_body(user, 0)
	return

//Does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/carbon/human/user, datum/surgery_procedure/surgery)
	return

//Stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/carbon/human/user, datum/surgery_procedure/surgery)
	return null




/datum/surgery_step/incision
	allowed_tools = list(/obj/item/tool/surgery/scalpel = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/clamp
	allowed_tools = list(/obj/item/tool/surgery/hemostat = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/retract
	allowed_tools = list(/obj/item/tool/surgery/retractor = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/unretract
	allowed_tools = list(/obj/item/tool/surgery/retractor = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/cauterize
	allowed_tools = list(/obj/item/tool/surgery/cautery = 100)
	min_duration = 3 SECONDS
	max_duration = 4 SECONDS

/datum/surgery_step/pick_bone
	allowed_tools = list(/obj/item/tool/surgery/hemostat = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/set_bone
	allowed_tools = list(/obj/item/tool/surgery/bonesetter = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/glue_bone
	allowed_tools = list(/obj/item/tool/surgery/bonegel = 100)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS		

/datum/surgery_step/move_bone
                        
/datum/surgery_step/drain_blood_bone

/datum/surgery_step/pick_fragments

/datum/surgery_step/glue_fragments

/datum/surgery_step/heal_bone

/datum/surgery_step/set_bone

/datum/surgery_step/fill_fracture

/datum/surgery_step/remove_bone

/datum/surgery_step/glue_ends

/datum/surgery_step/replace_bone

/datum/surgery_step/heal_trauma

/datum/surgery_step/realign_bone

/datum/surgery_step/drain_blood_muscle

/datum/surgery_step/tension_muscle

/datum/surgery_step/rebuild_muscle_veins

/datum/surgery_step/apply_synthmuscle

/datum/surgery_step/apply_muscle_growth

/datum/surgery_step/stitch_muscle

/datum/surgery_step/pull_tendon

/datum/surgery_step/heal_tendon_bone

/datum/surgery_step/retract_muscle