
//moved these here from code/defines/obj/weapon.dm
//please preference put stuff where it's easy to find - C

/obj/item/device/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon_state = "autopsy_scanner"
	flags_atom = FPRINT|CONDUCT
	w_class = SIZE_SMALL
	

/obj/item/device/autopsy_scanner/New()
	. = ..()
	
	LAZYADD(objects_of_interest, src)

/obj/item/device/autopsy_scanner/Destroy()
	. = ..()
	
	LAZYREMOVE(objects_of_interest, src)





/obj/item/device/autopsy_scanner/verb/print_data()
	set category = "Object"
	set src in view(usr, 1)
	set name = "Print Data"
	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		to_chat(usr, "No.")
		return

	for(var/mob/O in viewers(usr))
		O.show_message(SPAN_DANGER("\the [src] beeps negatively. A message shows up on the screen: \"Out of ink. Please buy more ink cartridges\"."), 1)


/obj/item/device/autopsy_scanner/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	var/obj/limb/S = M.get_limb(user.zone_selected)
	if(!S)
		to_chat(usr, "<b>You can't scan this body part.</b>")
		return
	if(!S.surgery_open_stage)
		to_chat(usr, "<b>You have to cut the limb open first!</b>")
		return
	for(var/mob/O in viewers(M))
		O.show_message(SPAN_DANGER("[user.name] scans the wounds on [M.name]'s [S.display_name] with \the [src.name]"), 1)

	return 1
