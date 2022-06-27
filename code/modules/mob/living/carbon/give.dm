/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in oview(1)

	receive_from(usr)

/mob/living/carbon/proc/receive_from(var/mob/living/carbon/giver)
	if(stat == DEAD || giver.stat == DEAD || client == null)
		return
	if(src == giver)
		return
	if(giver.mob_flags & GIVING)
		to_chat(giver, SPAN_WARNING("You are already giving an item to someone!"))
		return
	var/obj/item/I
	if(!giver.hand && giver.r_hand == null)
		to_chat(giver, SPAN_WARNING("You don't have anything in your right hand to give to [name]."))
		return
	if(giver.hand && giver.l_hand == null)
		to_chat(giver, SPAN_WARNING("You don't have anything in your left hand to give to [name]."))
		return
	if(!ishuman(src) || !ishuman(giver))
		return
	if(giver.hand)
		I = giver.l_hand
	else if(!giver.hand)
		I = giver.r_hand
	if(!istype(I) || (I.flags_item & (DELONDROP|NODROP|ITEM_ABSTRACT)))
		return
	if(r_hand == null || l_hand == null)
		giver.mob_flags |= GIVING
		var/choice = tgui_alert(src, "[giver] wants to give you \a [I]?", "You are being offered an item", list("No", "Yes"), 10 SECONDS)
		if(!choice)
			giver.mob_flags &= ~GIVING
			return
		switch(choice)
			if("Yes")
				giver.mob_flags &= ~GIVING
				if(!I || !giver || !istype(I))
					return
				if(!Adjacent(giver))
					to_chat(giver, SPAN_WARNING("You need to stay in reaching distance while giving an object."))
					to_chat(src, SPAN_WARNING("[giver] moved too far away."))
					return
				if((giver.hand && giver.l_hand != I) || (!giver.hand && giver.r_hand != I))
					to_chat(giver, SPAN_WARNING("You need to keep the item in your active hand."))
					to_chat(src, SPAN_WARNING("[giver] seem to have given up on giving [I] to you."))
					return
				if(r_hand != null && l_hand != null)
					to_chat(src, SPAN_WARNING("Your hands are full."))
					to_chat(giver, SPAN_WARNING("[src]'s hands are full."))
					return
				else
					if(giver.drop_held_item())
						if(put_in_hands(I))
							giver.visible_message(SPAN_NOTICE("[giver] hands [I] to [src]."),
							SPAN_NOTICE("You hand [I] to [src]."), null, 4)
			if("No")
				giver.mob_flags &= ~GIVING
				return
	else
		to_chat(giver, SPAN_WARNING("[src]'s hands are full."))
