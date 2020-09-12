var/list/hologram_list = list()

/mob/living/carbon/hologram
    name = "hologram"
    desc = "It seems to be a visual projection of someone" //jinkies!
    icon = 'icons/mob/mob.dmi'
    icon_state = "ghost"
    canmove = TRUE 
    blinded = 0

    mouse_opacity = FALSE

    var/mob/linked_mob
    alpha = 0

/mob/living/carbon/hologram/movement_delay()
    . = -2 // Very fast speed, so they can navigate through easily, they can't ever have movement delay whilst as a hologram

/datum/hud/hologram/New(mob/living/carbon/hologram, ui_style='icons/mob/hud/human_midnight.dmi')
	..()

/mob/living/carbon/hologram/create_hud()
    if(!hud_used)
        hud_used = new /datum/hud/hologram(src)

/mob/living/carbon/hologram/Initialize()
    . = ..()

    hologram_list.Add(src)

    var/datum/action/leave_hologram/LH = new()
    LH.give_action(src)

/mob/living/carbon/hologram/process()
    . = ..()
    if(!linked_mob || linked_mob.stat == DEAD)
        qdel(src)
    
    if(linked_mob.mind != mind)
        qdel(src)

/mob/living/carbon/hologram/proc/return_to_body()
    if(!mind || !linked_mob)
        return

    mind.transfer_to(linked_mob, TRUE)

/mob/living/carbon/hologram/say(message, datum/language/speaking, verb, alt_name, italics, message_range, sound/speech_sound, sound_vol, nolog, message_mode)
    if(linked_mob)
        linked_mob.say(message, speaking, verb, alt_name, italics, message_range, speech_sound, sound_vol, nolog, message_mode)
    
    return
    
/mob/living/carbon/hologram/verb/mob_return_to_body()
    set name = "Return to body"
    set category = "IC"

    return_to_body()
    qdel(src)

/mob/living/carbon/hologram/Dispose()
    . = ..()
    return_to_body()
    linked_mob = null

    hologram_list.Remove(src)
    return

/datum/action/leave_hologram
    name = "Leave"
    action_icon_state = "techtree_exit"

/datum/action/leave_hologram/action_activate()
    var/mob/living/carbon/hologram/H = owner

    if(!istype(H))
        return

    H.mob_return_to_body()