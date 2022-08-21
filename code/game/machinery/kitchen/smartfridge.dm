#define FRIDGE_WIRE_SHOCK		1
#define FRIDGE_WIRE_SHOOT_INV	2
#define FRIDGE_WIRE_IDSCAN		3

GLOBAL_LIST_INIT(fridge_wire_descriptions, list(
		FRIDGE_WIRE_SHOCK   = "Ground safety",
		FRIDGE_WIRE_IDSCAN 	  = "ID scanner",
		FRIDGE_WIRE_SHOOT_INV = "Dispenser motor control"
	))

#define FRIDGE_LOCK_NOLOCK		0
#define FRIDGE_LOCK_COMPLETE	1
#define FRIDGE_LOCK_ID			2


/* SmartFridge.  Much todo
*/
/obj/structure/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/structures/machinery/vending.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	wrenchable = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags_atom = NOREACT
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/icon_panel = "smartfridge-panel"
	var/item_quants = list()
	var/ispowered = TRUE //starts powered
	var/is_secure_fridge = FALSE
	var/seconds_electrified = 0;
	var/shoot_inventory = FALSE
	var/locked = FRIDGE_LOCK_ID
	var/panel_open = FALSE //Hacking a smartfridge
	var/wires = 7
	var/networked = FALSE
	var/transfer_mode = FALSE

/obj/structure/machinery/smartfridge/proc/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/food/snacks/grown/) || istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/structure/machinery/smartfridge/process()
	if(!src.ispowered)
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/structure/machinery/smartfridge/power_change()
	..()
	if( !(stat & NOPOWER) )
		src.ispowered = TRUE
		icon_state = icon_on
	else
		spawn(rand(0, 15))
			src.ispowered = FALSE
			icon_state = icon_off

//*******************
//*   Item Adding
//********************/

/obj/structure/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(HAS_TRAIT(O, TRAIT_TOOL_WRENCH))
		. = ..()
		return

	if(HAS_TRAIT(O, TRAIT_TOOL_SCREWDRIVER))
		panel_open = !panel_open
		to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
		overlays.Cut()
		if(panel_open)
			overlays += image(icon, icon_panel)
		nanomanager.update_uis(src)
		return

	if(HAS_TRAIT(O, TRAIT_TOOL_MULTITOOL)||HAS_TRAIT(O, TRAIT_TOOL_WIRECUTTERS))
		if(panel_open)
			attack_hand(user)
		return

	if(!ispowered)
		to_chat(user, SPAN_NOTICE("\The [src] is unpowered and useless."))
		return

	if(accept_check(O))
		if(user.drop_held_item())
			add_item(O)
			user.visible_message(SPAN_NOTICE("[user] has added \the [O] to \the [src]."), \
								 SPAN_NOTICE("You add \the [O] to \the [src]."))

		nanomanager.update_uis(src)

	else if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(accept_check(G))
				P.remove_from_storage(G,src)
				if(item_quants[G.name])
					item_quants[G.name]++
				else
					item_quants[G.name] = 1
				plants_loaded++
		if(plants_loaded)

			user.visible_message( \
				SPAN_NOTICE("[user] loads \the [src] with \the [P]."), \
				SPAN_NOTICE("You load \the [src] with \the [P]."))
			if(P.contents.len > 0)
				to_chat(user, SPAN_NOTICE("Some items are refused."))

		nanomanager.update_uis(src)

	else if(!(O.flags_item & NOBLUDGEON)) //so we can spray, scan, c4 the machine.
		to_chat(user, SPAN_NOTICE("\The [src] smartly refuses [O]."))
		return 1

/obj/structure/machinery/smartfridge/attack_remote(mob/user)
	return 0

/obj/structure/machinery/smartfridge/attack_hand(mob/user)
	if(!ispowered)
		to_chat(user, SPAN_WARNING("\The [src] has no power."))
		return
	if(seconds_electrified != 0)
		if(shock(user, 100))
			return
	if(is_secure_fridge)
		if(locked == FRIDGE_LOCK_COMPLETE)
			to_chat(user, SPAN_WARNING("Access denied!"))
			return
		if(!allowed(usr) && locked == FRIDGE_LOCK_ID)
			to_chat(user, SPAN_WARNING("Access denied!"))
			return
	tgui_interact(user)

/obj/structure/machinery/smartfridge/proc/add_item(var/obj/item/O)
	O.forceMove(src)

	if(item_quants[O.name])
		item_quants[O.name]++
	else
		item_quants[O.name] = 1

/obj/structure/machinery/smartfridge/proc/add_network_item(var/obj/item/O)
	if(is_in_network())
		chemical_data.shared_item_storage.Add(O)

		if(chemical_data.shared_item_quantity[O.name])
			chemical_data.shared_item_quantity[O.name]++
		else
			chemical_data.shared_item_quantity[O.name] = 1
		return TRUE
	return FALSE

/obj/structure/machinery/smartfridge/proc/dispense(obj/item/O, mob/M)
	if(!M.put_in_hands(O))
		O.forceMove(src.loc)


//*******************
//*   tgui
//********************/

/obj/structure/machinery/smartfridge/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(is_secure_fridge)
		if(locked == FRIDGE_LOCK_COMPLETE)
			return UI_DISABLED
		if(!allowed(usr) && locked == FRIDGE_LOCK_ID)
			return UI_DISABLED

/obj/structure/machinery/smartfridge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(panel_open)
			ui = new(user, src, "Wires", "[name] Wires")
			ui.open()
		else
			ui = new(user, src, "SmartVend", name)
			ui.open()

/obj/structure/machinery/smartfridge/ui_data(mob/user)
	var/list/data = list()

	var/listofitems = list()
	var/listofshareditems = list()
	for(var/I in src)
		var/atom/movable/O = I
		if(!QDELETED(O))
			if(listofitems[O.name])
				listofitems[O.name]["amount"]++
			else
				listofitems[O.name] = list("name" = O.name, "type" = O.type, "amount" = 1)
	sortList(listofitems)

	if(is_in_network())
		for(var/I in chemical_data.shared_item_storage)
			var/atom/movable/O = I
			if(!QDELETED(O))
				if (listofshareditems[O.name])
					listofshareditems[O.name]["amount"]++
				else
					listofshareditems[O.name] = list("name" = O.name, "type" = O.type, "amount" = 1)
		sortList(listofshareditems)

	data["networked_contents"] = listofshareditems
	data["contents"] = listofitems
	data["locked"] = locked
	data["secure"] = is_secure_fridge
	data["networked"] = is_in_network()
	data["transfer_mode"] = transfer_mode

	var/list/payload = list()
	for(var/wire in 1 to length(GLOB.fridge_wire_descriptions))
		payload.Add(list(list(
			"number" = wire,
			"cut" = isWireCut(wire),
		)))
	data["wires"] = payload

	data["proper_name"] = name

	return data

/obj/structure/machinery/smartfridge/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/target_wire = params["wire"]
	switch(action)
		if("Release")
			if(is_secure_fridge)
				if(locked == FRIDGE_LOCK_COMPLETE)
					to_chat(usr, SPAN_DANGER("Access denied."))
					return FALSE
				if(!allowed(usr) && locked == FRIDGE_LOCK_ID)
					to_chat(usr, SPAN_DANGER("Access denied."))
					return FALSE

			var/desired = 0

			if(params["amount"])
				desired = text2num(params["amount"])
			else
				desired = input(usr, "How many items?") as num

			if(QDELETED(src) || QDELETED(usr) || !usr.Adjacent(src)) // Sanity checkin' in case stupid stuff happens while we wait for input()
				return FALSE
			if(!params["from_network"])
				if(!transfer_mode)
					if(desired == 1 && Adjacent(usr))
						for(var/obj/item/O in src)
							if(O.name == params["name"])
								dispense(O, usr)
								break
						return TRUE

					for(var/obj/item/O in src)
						if(desired <= 0)
							break
						if(O.name == params["name"])
							dispense(O, usr)
							desired--
					return TRUE
				else

			else
				if(desired == 1 && Adjacent(usr))
					for(var/obj/item/O in chemical_data.shared_item_storage)
						if(O.name == params["name"])
							dispense(O, usr)
							break
					return TRUE

				for(var/obj/item/O in chemical_data.shared_item_storage)
					if(desired <= 0)
						break
					if(O.name == params["name"])
						dispense(O, usr)
						desired--
				return TRUE

		if("toggletransfer")
			if(is_secure_fridge)
				if(locked == FRIDGE_LOCK_COMPLETE)
					to_chat(usr, SPAN_DANGER("Access denied."))
					return FALSE
				if(!allowed(usr) && locked == FRIDGE_LOCK_ID)
					to_chat(usr, SPAN_DANGER("Access denied."))
					return FALSE
			if(is_in_network() && !transfer_mode)
				transfer_mode = TRUE
			else
				transfer_mode = FALSE
			return TRUE
		if("cut")
			if(!panel_open)
				return
			var/obj/item/held_item = usr.get_held_item()
			if (!held_item || !HAS_TRAIT(held_item, TRAIT_TOOL_WIRECUTTERS))
				to_chat(usr, SPAN_WARNING("You need wirecutters!"))
				return FALSE

			if(isWireCut(target_wire))
				mend(target_wire, usr)
			else
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
				cut(target_wire, usr)
			return TRUE
		if("pulse")
			if(!panel_open)
				return
			var/obj/item/held_item = usr.get_held_item()
			if (!held_item || !HAS_TRAIT(held_item, TRAIT_TOOL_MULTITOOL))
				to_chat(usr, SPAN_WARNING("You need a multitool!"))
				return FALSE
			if (isWireCut(target_wire))
				to_chat(usr, "You can't pulse a cut wire.")
				return FALSE
			playsound(src.loc, 'sound/effects/zzzt.ogg', 25, 1)
			pulse(target_wire, usr)
			return TRUE

	return FALSE

//*******************
//*   SmartFridge Menu
/*

/obj/structure/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_interaction(src)

	var/data[0]
	data["contents"] = null
	data["wires"] = null
	data["panel_open"] = panel_open
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure_fridge
	data["networked"] = is_in_network()
	data["transfer_mode"] = transfer_mode

	var/list/items[0]
	for (var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if (count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if (length(items) > 0)
		data["contents"] = items

	if(is_in_network())
		var/list/networked_items = list()
		for (var/i=1 to length(chemical_data.shared_item_quantity))
			var/K = chemical_data.shared_item_quantity[i]
			var/count = chemical_data.shared_item_quantity[K]
			if (count > 0)
				networked_items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

		if (length(networked_items) > 0)
			data["networked_contents"] = networked_items

	var/list/wire_descriptions = get_wire_descriptions()
	var/list/panel_wires = list()
	for(var/wire = 1 to wire_descriptions.len)
		panel_wires += list(list("desc" = wire_descriptions[wire], "cut" = isWireCut(wire)))

	if (panel_wires)
		data["wires"] = panel_wires

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", src.name, 420, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/machinery/smartfridge/Topic(href, href_list)
	if (..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	src.add_fingerprint(user)

	if (href_list["close"])
		user.unset_interaction()
		ui.close()
		return FALSE

	if (href_list["toggletransfer"])
		if(is_secure_fridge)
			if(locked == FRIDGE_LOCK_COMPLETE)
				to_chat(usr, SPAN_DANGER("Access denied."))
				return FALSE
			if(!allowed(usr) && locked == FRIDGE_LOCK_ID)
				to_chat(usr, SPAN_DANGER("Access denied."))
				return FALSE
		if(is_in_network() && !transfer_mode)
			transfer_mode = TRUE
		else
			transfer_mode = FALSE
		return TRUE

	if (href_list["vend"])
		if(!ispowered)
			to_chat(usr, SPAN_WARNING("[src] has no power."))
			return FALSE
		if (!in_range(src, usr))
			return FALSE
		if(is_secure_fridge)
			if(locked == FRIDGE_LOCK_COMPLETE)
				to_chat(usr, SPAN_DANGER("Access denied."))
				return FALSE
			if(!allowed(usr) && locked == FRIDGE_LOCK_ID)
				to_chat(usr, SPAN_DANGER("Access denied."))
				return FALSE
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/from_network = text2num(href_list["network"])


		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		var/list/source = contents
		var/list/quantity_holder = item_quants
		// Validate we can reach the shared network.
		transfer_mode = transfer_mode && is_in_network()

		if(is_in_network() && from_network)
			source = chemical_data.shared_item_storage
			quantity_holder = chemical_data.shared_item_quantity

		var/K = quantity_holder[index]
		var/count = quantity_holder[K]

		if(count > 0)
			quantity_holder[K] = max(count - amount, 0)
			var/i = amount
			if(!transfer_mode)
				for(var/obj/O in source)
					if(O.name == K)
						source.Remove(O)
						O.forceMove(loc)
						i--
						if (i <= 0)
							return TRUE
			else
				for(var/obj/O in source)
					if(O.name == K)
						if(from_network)
							contents.Add(O)
							item_quants[K]++
							source.Remove(O)
						else
							chemical_data.shared_item_storage.Add(O)
							chemical_data.shared_item_quantity[K]++
							source.Remove(O)
						i--
						if(i <= 0)
							return TRUE

		return TRUE

	if (panel_open)
		if (href_list["cutwire"])
			var/obj/item/held_item = usr.get_held_item()
			if (!held_item || !HAS_TRAIT(held_item, TRAIT_TOOL_WIRECUTTERS))
				to_chat(user, "You need wirecutters!")
				return TRUE

			var/wire = text2num(href_list["cutwire"])
			if (isWireCut(wire))
				mend(wire)
			else
				cut(wire)
			return TRUE

		if (href_list["pulsewire"])
			var/obj/item/held_item = usr.get_held_item()
			if (!held_item || !HAS_TRAIT(held_item, TRAIT_TOOL_MULTITOOL))
				to_chat(usr, "You need a multitool!")
				return TRUE

			var/wire = text2num(href_list["pulsewire"])
			if (isWireCut(wire))
				to_chat(usr, "You can't pulse a cut wire.")
				return TRUE

			pulse(wire)
			return TRUE

	return FALSE

*/

//*************
//*	Hacking
//**************/

/obj/structure/machinery/smartfridge/proc/cut(var/wire)
	wires ^= getWireFlag(wire)

	switch(wire)
		if(FRIDGE_WIRE_SHOCK)
			seconds_electrified = -1
			visible_message(SPAN_DANGER("Electric arcs shoot off from \the [src]!"))
		if (FRIDGE_WIRE_SHOOT_INV)
			if(!shoot_inventory)
				shoot_inventory = TRUE
				visible_message(SPAN_WARNING("\The [src] begins whirring noisily."))
		if(FRIDGE_WIRE_IDSCAN)
			locked = FRIDGE_LOCK_COMPLETE //totally lock it down
			visible_message(SPAN_NOTICE("\The [src] emits a slight thunk."))

/obj/structure/machinery/smartfridge/proc/mend(var/wire)
	wires |= getWireFlag(wire)
	switch(wire)
		if(FRIDGE_WIRE_SHOCK)
			seconds_electrified = 0
		if (FRIDGE_WIRE_SHOOT_INV)
			shoot_inventory = FALSE
			visible_message(SPAN_NOTICE("\The [src] stops whirring."))
		if(FRIDGE_WIRE_IDSCAN)
			locked = FRIDGE_LOCK_ID //back to normal
			visible_message(SPAN_NOTICE("\The [src] emits a click."))

/obj/structure/machinery/smartfridge/proc/pulse(var/wire)
	switch(wire)
		if(FRIDGE_WIRE_SHOCK)
			seconds_electrified = 30
			visible_message(SPAN_DANGER("Electric arcs shoot off from \the [src]!"))
		if(FRIDGE_WIRE_SHOOT_INV)
			shoot_inventory = !shoot_inventory
			if(shoot_inventory)
				visible_message(SPAN_WARNING("\The [src] begins whirring noisily."))
			else
				visible_message(SPAN_NOTICE("\The [src] stops whirring."))
		if(FRIDGE_WIRE_IDSCAN)
			locked = FRIDGE_LOCK_NOLOCK //open sesame
			visible_message(SPAN_NOTICE("\The [src] emits a click."))

/obj/structure/machinery/smartfridge/proc/isWireCut(var/wire)
	return !(wires & getWireFlag(wire))

/obj/structure/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for (var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue

		item_quants[O]--
		for(var/obj/T in contents)
			if(T.name == O)
				T.forceMove(src.loc)
				throw_item = T
				break
		break
	if(!throw_item)
		return 0
	INVOKE_ASYNC(throw_item, /atom/movable/proc/throw_atom, target, 16, SPEED_AVERAGE, src)
	src.visible_message(SPAN_DANGER("<b>[src] launches [throw_item.name] at [target.name]!</b>"))
	return 1

/obj/structure/machinery/smartfridge/proc/is_in_network()
	return networked && is_mainship_level(z)



//********************
//*	Smartfridge types
//*********************/

/obj/structure/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/structures/machinery/vending.dmi'
	icon_state = "seeds"
	icon_on = "seeds"
	icon_off = "seeds-off"

/obj/structure/machinery/smartfridge/seeds/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

//the secure subtype does nothing, I'm only keeping it to avoid conflicts with maps.
/obj/structure/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	icon_on = "smartfridge_chem"
	is_secure_fridge = TRUE
	req_one_access = list(ACCESS_MARINE_CMO, 33)

/obj/structure/machinery/smartfridge/secure/medbay/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/glass/))
		return 1
	if(istype(O,/obj/item/storage/pill_bottle/))
		return 1
	if(istype(O,/obj/item/reagent_container/pill/))
		return 1
	return 0


/obj/structure/machinery/smartfridge/secure/virology
	name = "\improper Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	is_secure_fridge = TRUE
	req_access = list(39)
	icon_state = "smartfridge_virology"
	icon_on = "smartfridge_virology"
	icon_off = "smartfridge_virology-off"

/obj/structure/machinery/smartfridge/secure/virology/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/glass/beaker/vial/))
		return 1
	return 0


/obj/structure/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."
	is_secure_fridge = TRUE
	req_one_access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP)
	networked = TRUE

/obj/structure/machinery/smartfridge/chemistry/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/storage/pill_bottle) || istype(O,/obj/item/reagent_container) || istype(O,/obj/item/storage/fancy/vials))
		return 1
	return 0

/obj/structure/machinery/smartfridge/chemistry/antag
	req_one_access = list(ACCESS_ILLEGAL_PIRATE)

/obj/structure/machinery/smartfridge/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."


/obj/structure/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/structure/machinery/smartfridge/drinks/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/glass) || istype(O,/obj/item/reagent_container/food/drinks) || istype(O,/obj/item/reagent_container/food/condiment))
		return 1
