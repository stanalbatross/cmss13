#define TECH_TIER_ONE "t1"
#define TECH_TIER_TWO "t2"
#define TECH_TIER_THREE "t3"
#define TECH_TIER_FOUR "t4"

#define TECH_TIER_FREE "free"
#define TECH_TIER_TRANSITION_ONETWO "t1-t2"
#define TECH_TIER_TRANSITION_TWOTHREE "t2-t3"
#define TECH_TIER_TRANSITION_THREEFOUR "t3-t4"

#define TECH_ALWAYS_PROCESS 1 // Always process
#define TECH_UNLOCKED_PROCESS 2 // Only processes when unlocked
#define TECH_NEVER_PROCESS 3 // Never processes

#define TREE_ACCESS_MODIFY 1
#define TREE_ACCESS_VIEW 2

// Flags
#define TREE_FLAG_MARINE 1
#define TREE_FLAG_XENO  2

// Trees

#define TREE_NONE ""
#define TREE_MARINE "Marine Tech Tree"
#define TREE_XENO "Xenomorph Tech Tree"

// Resource
#define RESOURCE_HEALTH 200

#define RESOURCE_TICKS_TO_CYCLE SECONDS_30
#define RESOURCE_PER_CYCLE 1

#define RESOURCE_PLASMA_PER_REPAIR 3 // Calculated like this: RESOURCE_PLASMA_PER_REPAIR * damage_to_repair
#define RESOURCE_FUEL_TO_REPAIR 5 // Calculated like this: RESOURCE_FUEL_TO_REPAIR * (damage_to_repair / max_health)

// Droppods

#define DROPPOD_DROPPED 1
#define DROPPOD_DROPPING 2
#define DROPPOD_OPEN 4
#define DROPPOD_STRIPPED 8

#define GET_TREE(treeid) SStechtree? SStechtree.trees[treeid] : null
#define GET_NODE(treeid, nodeid) SStechtree? SStechtree.trees[treeid].get