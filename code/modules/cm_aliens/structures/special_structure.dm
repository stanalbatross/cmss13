/*
 * Special Structures
 */

/proc/get_xeno_structure_desc(var/name)
	var/message
	switch(name)
		if(XENO_STRUCTURE_CORE)
			message = "<B>[XENO_STRUCTURE_CORE]</B> - Heart of the hive, grows hive weeds (which are necessary for other structures), stores resources and protects the hive from skyfire."
		if(XENO_STRUCTURE_PYLON)
			message = "<B>[XENO_STRUCTURE_PYLON]</B> - Remote section of the hive, grows hive weeds (which are necessary for other structures), stores resources and protects sisters from skyfire."
		if(XENO_STRUCTURE_POOL)
			message = "<B>[XENO_STRUCTURE_POOL]</B> - Respawns xenomorphs that fall in battle."
		if(XENO_STRUCTURE_EGGMORPH)
			message = "<B>[XENO_STRUCTURE_EGGMORPH]</B> - Processes hatched hosts into new eggs."
		if(XENO_STRUCTURE_EVOPOD)
			message = "<B>[XENO_STRUCTURE_EVOPOD]</B> - Grants an additional 0.2 evolution per tick for all sisters on weeds."
		if(XENO_STRUCTURE_RECOVERY)
			message = "<B>[XENO_STRUCTURE_RECOVERY]</B> - Hastily recovers the strength of sisters resting around it."
		if(XENO_STRUCTURE_NEST)
			message = "<B>[XENO_STRUCTURE_NEST]</B> - Strong enough to secure a headhunter for indeterminate durations."
	return message

/obj/effect/alien/resin/special
	name = "Special Resin Structure"
	icon = 'icons/mob/hostiles/structures64x64.dmi'
	pixel_x = -16
	pixel_y = -16
	health = 200
	var/maxhealth = 200

	density = TRUE
	unacidable = TRUE
	anchored = TRUE
	block_range = 1

/obj/effect/alien/resin/special/Initialize(mapload, var/hive_ref)
	. = ..()
	maxhealth = health

	if(hive_ref)
		faction = hive_ref
	else
		faction = GLOB.faction_datum[SET_FACTION_HIVE_NORMAL]

	set_hive_data(src, faction)

	if(!faction.add_special_structure(src))
		return INITIALIZE_HINT_QDEL

	START_PROCESSING(SSfastobj, src)
	update_icon()

/obj/effect/alien/resin/special/Destroy()
	if(faction)
		faction.remove_special_structure(src)
		if(faction.living_xeno_queen)
			xeno_message("Hive: \A [name] has been destroyed at [sanitize(get_area_name(src))]!", 3, faction)
	faction = null
	STOP_PROCESSING(SSfastobj, src)

	. = ..()

/obj/effect/alien/resin/special/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.can_destroy_special() || M.faction != faction)
		return ..()
