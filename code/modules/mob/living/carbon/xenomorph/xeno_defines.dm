// Actual caste datum basedef
/datum/caste_datum
	var/caste_type = ""
	var/display_name = ""
	var/tier = 0
	var/dead_icon = "Drone Dead"
	var/language = LANGUAGE_XENOMORPH

	var/melee_damage_lower = 10
	var/melee_damage_upper = 20
	var/evasion = XENO_EVASION_NONE

	var/speed = XENO_SPEED_TIER_10

	var/plasma_max = 10
	var/plasma_gain = 5

	var/crystal_max = 0

	var/max_health = XENO_UNIVERSAL_HPMULT * 100

	var/evolution_allowed = 1 //Are they allowed to evolve (and have their evolution progress group)
	var/evolution_threshold = 0 //Threshold to next evolution

	var/list/evolves_to = list() //This is where you add castes to evolve into. "Seperated", "by", "commas"
	var/deevolves_to // what caste to de-evolve to.
	var/is_intelligent = 0 //If they can use consoles, etc. Set on Queen
	var/caste_desc = null

	// Tackles
	var/tackle_min = 2
	var/tackle_max = 6
	var/tackle_chance = 35
	var/tacklestrength_min = 2
	var/tacklestrength_max = 3

	var/armor_deflection = 0 //Chance of deflecting projectiles.
	var/fire_immunity = FIRE_IMMUNITY_NONE
	var/fire_intensity_resistance = 0

	var/spit_delay = 60 //Delay timer for spitting

	var/aura_strength = 0 //The strength of our aura. Zero means we can't emit one
	var/aura_allowed = list("frenzy", "warding", "recovery") //"Evolving" removed for the time being

	var/adjust_size_x = 1 //Adjust pixel size. 0.x is smaller, 1.x is bigger, percentage based.
	var/adjust_size_y = 1
	var/list/spit_types //list of datum projectile types the xeno can use.

	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.

	var/agility_speed_increase = 0 // this opens up possibilities for balancing

	// The type of mutator delegate to instantiate on the base caste. Will
	// be replaced when the Xeno chooses a strain.
	var/behavior_delegate_type = /datum/behavior_delegate

	// Resin building-related vars
	var/build_time_mult = BUILD_TIME_MULT_XENO // Default build time and build distance
	var/max_build_dist = 0

	// Carrier vars //

	/// if a hugger is held in hand, won't attempt to leap and kill itself
	var/hugger_nurturing = FALSE
	var/huggers_max = 0
	var/throwspeed = 0
	var/hugger_delay = 0
	var/eggs_max = 0
	var/egg_cooldown = 30

	var/xeno_explosion_resistance = 0 //Armor but for explosions

	//Queen vars
	var/can_hold_facehuggers = 0
	var/can_hold_eggs = CANNOT_HOLD_EGGS

	var/can_be_queen_healed = TRUE
	var/can_be_revived = TRUE

	var/can_vent_crawl = 1

	var/caste_luminosity = 0

	var/burrow_cooldown = 5 SECONDS
	var/tunnel_cooldown = 100
	var/widen_cooldown = 10 SECONDS
	var/tremor_cooldown = 30 SECONDS //Big strong ability, big cooldown.

	var/innate_healing = FALSE //whether the xeno heals even outside weeds.

	var/acid_level = 0
	var/weed_level = WEED_LEVEL_STANDARD

	var/acid_splash_cooldown = 3 SECONDS //Time it takes between acid splash retaliate procs. Variable per caste, for if we want future castes that are acid bombs

	// regen vars

	var/heal_delay_time = 0 SECONDS
	var/heal_resting = 1
	var/heal_standing = 0.4
	var/heal_knocked_out = 0.33

	var/list/resin_build_order
	var/minimum_xeno_playtime = 0

/datum/caste_datum/can_vv_modify()
	return FALSE

/datum/caste_datum/New()
	. = ..()

	//Initialise evolution and upgrade thresholds in one place, once and for all
	evolution_threshold = 0
	if(evolution_allowed)
		switch(tier)
			if(1)
				evolution_threshold = 200
			if(2)
				evolution_threshold = 500
			//Other tiers (T3, Queen, etc.) can't evolve anyway

	resin_build_order = GLOB.resin_build_order_default

/client/var/cached_xeno_playtime

/client/proc/get_total_xeno_playtime(var/skip_cache = FALSE)
	if(cached_xeno_playtime && !skip_cache)
		return cached_xeno_playtime

	var/total_xeno_playtime = 0

	for(var/caste in RoleAuthority.castes_by_name)
		total_xeno_playtime += get_job_playtime(src, caste)

	total_xeno_playtime += get_job_playtime(src, JOB_XENOMORPH)

	if(player_entity)
		var/past_xeno_playtime = player_entity.get_playtime(STATISTIC_XENO)
		if(past_xeno_playtime)
			total_xeno_playtime += past_xeno_playtime


	cached_xeno_playtime = total_xeno_playtime

	return total_xeno_playtime

/datum/caste_datum/proc/can_play_caste(var/client/client)
	if(!CONFIG_GET(flag/use_timelocks))
		return TRUE

	var/total_xeno_playtime = client.get_total_xeno_playtime()

	if(minimum_xeno_playtime && total_xeno_playtime < minimum_xeno_playtime)
		return FALSE

	return TRUE

/datum/caste_datum/proc/get_caste_requirement(var/client/client)
	return minimum_xeno_playtime - client.get_total_xeno_playtime()