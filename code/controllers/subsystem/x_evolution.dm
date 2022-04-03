#define BOOST_POWER_MAX 20
#define BOOST_POWER_MIN 1
#define EVOLUTION_INCREMENT_TIME (30 MINUTES) // Evolution increases by 1 every 30 minutes.

SUBSYSTEM_DEF(xevolution)
	name = "Evolution"
	wait = 1 MINUTES
	priority = SS_PRIORITY_INACTIVITY

	var/human_xeno_ratio_modifier = 0.4
	var/time_ratio_modifier = 0.4

	var/list/boost_power = list()
	var/force_boost_power = FALSE // Debugging only

/datum/controller/subsystem/xevolution/Initialize(start_timeofday)
	var/list/xeno_hives = SET_FACTION_LIST_XENOS
	for(var/faction in xeno_hives)
		var/datum/faction_status/xeno/hive = GLOB.faction_datum[faction]
		boost_power[hive] = 1
	return ..()

/datum/controller/subsystem/xevolution/fire(resumed = FALSE)
	for(var/datum/faction_status/xeno/HS in GLOB.faction_datum)
		if(!HS)
			continue

		if(!HS.dynamic_evolution)
			boost_power[HS] = HS.evolution_rate + HS.evolution_bonus
			HS.faction_ui.update_pooled_larva()
			continue

		var/boost_power_new
		// Minimum of 5 evo until 10 minutes have passed.
		if((world.time - SSticker.round_start_time) < XENO_ROUNDSTART_PROGRESS_TIME_2)
			boost_power_new = max(boost_power_new, XENO_ROUNDSTART_PROGRESS_AMOUNT)
		else
			boost_power_new = Floor(10 * (world.time - XENO_ROUNDSTART_PROGRESS_TIME_2 - SSticker.round_start_time) / EVOLUTION_INCREMENT_TIME) / 10

			//Add on any bonuses from evopods after applying upgrade progress
			boost_power_new += (0.25 * HS.has_special_structure(XENO_STRUCTURE_EVOPOD))

		boost_power_new = Clamp(boost_power_new, BOOST_POWER_MIN, BOOST_POWER_MAX)

		boost_power_new += HS.evolution_bonus
		if(!force_boost_power)
			boost_power[HS] = boost_power_new

		//Update displayed Evilution, which is under larva apparently
		HS.faction_ui.update_pooled_larva()

/datum/controller/subsystem/xevolution/proc/get_evolution_boost_power(var/datum/faction_status/xeno/faction)
	return boost_power[faction]

#undef EVOLUTION_INCREMENT_TIME
#undef BOOST_POWER_MIN
#undef BOOST_POWER_MAX
