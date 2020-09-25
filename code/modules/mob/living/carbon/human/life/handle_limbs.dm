
/mob/living/carbon/human/proc/handle_limbs()
    for(var/obj/limb/L in limbs_to_process)
        L.process()
