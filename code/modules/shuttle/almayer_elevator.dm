/obj/docking_port/mobile/almayer_elevator
	name = "almayer elevator"
	width = 5
	height = 5
	dwidth = 2
	dheight = 2

	callTime = 5 SECONDS
	ignitionTime = 1 SECONDS

	ignition_sound = 'sound/machines/asrs_raising.ogg'
	ambience_idle = null
	ambience_flight = null

	var/list/railings = list()
	var/list/gears = list()

/obj/docking_port/mobile/almayer_elevator/register()
	. = ..()
	SSshuttle.almayer_elevator = src
	for(var/obj/structure/machinery/gear/G in machines)
		if(G.id == "almayer_elevator_gears")
			gears += G
	for(var/obj/structure/machinery/door/poddoor/railing/R in machines)
		if(R.id == "almayer_elevator_railing")
			railings += R

/obj/docking_port/mobile/almayer_elevator/on_ignition()
	for(var/i in gears)
		var/obj/structure/machinery/gear/G = i
		G.start_moving()

/obj/docking_port/mobile/almayer_elevator/afterShuttleMove()
	if(!is_mainship_level(z))
		return
	for(var/i in gears)
		var/obj/structure/machinery/gear/G = i
		G.stop_moving()
	for(var/i in railings)
		var/obj/structure/machinery/door/poddoor/railing/R = i
		INVOKE_ASYNC(R, /obj/structure/machinery/door.proc/open)

/obj/docking_port/stationary/almayer_elevator
	name = "Upper Deck Elevator Dock"
	id = "upper almayer"
	width = 5
	height = 5
	dwidth = 2
	dheight = 2

/obj/docking_port/stationary/almayer_elevator/lowerdeck
	name = "Lower Deck Elevator Dock"
	id = "lower almayer"
	roundstart_template = /datum/map_template/shuttle/vehicle
