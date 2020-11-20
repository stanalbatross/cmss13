// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_VEHICLE_ORDERED "!vehicle_ordered"
///from /datum/game_mode/proc/pre_setup
#define COMSIG_GLOB_MODE_PRESETUP "!mode_presetup"
///from /datum/game_mode/proc/post_setup
#define COMSIG_GLOB_MODE_POSTSETUP "!mode_postsetup"
///from /mob/living/carbon/human/death
#define COMSIG_GLOB_MARINE_DEATH "!marine_death"
///from /mob/living/carbon/Xenomorph/death
#define COMSIG_GLOB_XENO_DEATH "!xeno_death"

//////////////////////////////////////////////////////////////////

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_PARENT_QDELETING "parent_qdeleting"
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// /mob signals
/// From /obj/structure/machinery/door/airlock/proc/take_damage
#define COMSIG_MOB_DESTROY_AIRLOCK "mob_destroy_airlock"
/// From /obj/structure/machinery/door/airlock/attackby
#define COMSIG_MOB_DISASSEMBLE_AIRLOCK "mob_disassemble_airlock"
/// From /turf/closed/wall/proc/take_damage
#define COMSIG_MOB_DESTROY_WALL "mob_destroy_wall"
/// From /turf/closed/wall/ex_act
#define COMSIG_MOB_EXPLODED_WALL "mob_exploded_wall"
/// From /obj/structure/girder/proc/do_wall
#define COMSIG_MOB_CONSTRUCT_WALL "mob_construct_wall"
/// Currently unused
#define COMSIG_MOB_DESTROY_W_FRAME "mob_destroy_w_frame"
/// From /obj/structure/window_frame/attackby
#define COMSIG_MOB_DISASSEMBLE_W_FRAME "mob_disassemble_w_frame"
/// From /obj/structure/window/proc/healthcheck
#define COMSIG_MOB_DESTROY_WINDOW "mob_destroy_window"
/// From /obj/structure/window_frame/attackby
#define COMSIG_MOB_CONSTRUCT_WINDOW "mob_construct_window"
/// From /obj/structure/window/attackby
#define COMSIG_MOB_DISASSEMBLE_WINDOW "mob_disassemble_window"
/// From /obj/structure/machinery/power/apc/attackby
#define COMSIG_MOB_APC_REMOVE_BOARD "mob_apc_remove_board"
/// From /obj/structure/machinery/power/apc/attack_hand
#define COMSIG_MOB_APC_REMOVE_CELL "mob_apc_remove_cell"
/// From /obj/structure/machinery/power/apc/proc/cut
#define COMSIG_MOB_APC_CUT_WIRE "mob_apc_cut_wire"
/// From /obj/structure/machinery/power/apc/proc/pulse
#define COMSIG_MOB_APC_POWER_PULSE "mob_apc_power_pulse"

/// For when a mob is dragged
#define COMSIG_MOB_DRAGGED "mob_dragged"

/// For when a mob is devoured by a Xeno
#define COMSIG_MOB_DEVOURED "mob_devoured"
	#define COMPONENT_CANCEL_DEVOUR	(1<<0)

/// From /mob/living/rejuvenate
#define COMSIG_LIVING_REJUVENATED "living_rejuvenated"

/// From /obj/item/device/defibrillator/attack
#define COMSIG_HUMAN_REVIVED "human_revived"

// /obj/item signals
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
/// From /atom/movable/proc/launch_towards
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"
	#define COMPONENT_CANCEL_THROW (1<<0)

///from /obj/item/device/agents/floppy_disk/proc/insert_drive
#define COMSIG_AGENT_DISK_INSERTED "agent_disk_inserted"
///from /obj/item/reagent_container/food/snacks/proc/On_Consume
#define COMSIG_SNACK_EATEN "snack_eaten"
///from /turf/closed/wall/proc/place_poster
#define COMSIG_POSTER_PLACED "poster_placed"
///from /obj/item/device/agents/tracking_device/proc/plant_tracker
#define COMSIG_TRACKING_PLANTED "tracking_planted"
///from /obj/item/device/agents/tracking_device/attackby
#define COMSIG_TRACKING_DISARMED "tracking_disarmed"

// need to do this for now thanks to shit code
#define COMSIG_HUMAN_BULLET_ACT "human_bullet_act"
	#define COMPONENT_CANCEL_BULLET_ACT (1<<0)

#define COMSIG_HUMAN_XENO_ATTACK "human_attack_alien"
	#define COMPONENT_CANCEL_XENO_ATTACK (1<<0)

#define COMSIG_ITEM_EQUIPPED "item_equipped"

#define COMSIG_ITEM_UNEQUIPPED "item_unequipped"

#define COMSIG_MOB_ENTER_TREE "mob_enter_tree"
	#define COMPONENT_CANCEL_TREE_ENTRY (1<<0)

#define COMSIG_MOB_TAKE_DAMAGE "mob_take_damage"
	#define COMPONENT_BLOCK_DAMAGE (1<<0)

#define COMSIG_MOB_RESET_VIEW "mob_reset_view"
	#define COMPONENT_OVERRIDE_VIEW	(1<<0)

#define COMSIG_CLIENT_MOB_MOVE	"client_mob_move"
	#define COMPONENT_OVERRIDE_MOVE	(1<<0)