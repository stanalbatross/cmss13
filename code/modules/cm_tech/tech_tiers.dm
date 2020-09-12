/datum/tier
    var/name = "Placeholder Name"
    var/tier = 0

    var/color = "#FFFFFF"
    var/max_techs = -1 // Infinite

/datum/tier/proc/can_purchase()

/datum/tier/free
    name = "Initial Tier"
    tier = 0
    color = "#000000"

    max_techs = 1

/datum/tier/one
    name = "Tier 1"
    tier = 1
    color = "#00FF00"

    max_techs = 3

/datum/tier/one_transition_two
    name = "Tier 1 to Tier 2 transition"
    tier = 1.5
    color = "#000000"

    max_techs = 1

/datum/tier/two
    name = "Tier 2"
    tier = 2
    color = "#FFAA00"

    max_techs = 3

/datum/tier/two_transition_three
    name = "Tier 2 to Tier 3 transition"
    tier = 2.5
    color = "#000000"

    max_techs = 1

/datum/tier/three
    name = "Tier 3"
    tier = 3
    color = "#FF0000"

    max_techs = 3

/datum/tier/three_transition_four
    name = "Tier 3 to Tier 4 transition"
    tier = 3.5
    color = "#000000"

    max_techs = 1

/datum/tier/four
    name = "Tier 4"
    tier = 4
    color = "#FF00FF"
    max_techs = 1

var/global/list/tech_tiers = list(
    TECH_TIER_FREE = new /datum/tier/free(),
    TECH_TIER_ONE = new /datum/tier/one(), 
    TECH_TIER_TRANSITION_ONETWO = new /datum/tier/one_transition_two(), 
    TECH_TIER_TWO = new /datum/tier/two(),
    TECH_TIER_TRANSITION_TWOTHREE = new /datum/tier/one_transition_two(), 
    TECH_TIER_THREE = new /datum/tier/three(), 
    TECH_TIER_TRANSITION_THREEFOUR = new /datum/tier/one_transition_two(), 
    TECH_TIER_FOUR = new /datum/tier/four()
) // we need them in order