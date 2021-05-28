//Life variables
#define HUMAN_MAX_OXYLOSS 1 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
#define HUMAN_CRIT_MAX_OXYLOSS 1 //The amount of damage you'll get when in critical condition. We want this to be a 5 minute deal = 300s. There are 50HP to get through, so (1/6)*last_tick_duration per second. Breaths however only happen every 3 ticks.

///////////////////HUMAN BLOODTYPES///////////////////
#define HUMAN_BLOODTYPES list("O-","O+","A-","A+","B-","B+","AB-","AB+")

#define HUMAN_MAX_PALENESS	30 //this is added to human skin tone to get value of pale_max variable

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define POCKET_STRIP_DELAY 20

///////////////////LIMB DEFINES///////////////////
#define LIMB_BROKEN 1
#define LIMB_DESTROYED 2 //limb is missing
#define LIMB_ROBOT 4
#define LIMB_SPLINTED 8
#define LIMB_MUTATED 16 //limb is deformed by mutations
#define LIMB_AMPUTATED 32 //limb was amputated cleanly or destroyed limb was cleaned up, thus causing no pain
#define LIMB_REPAIRED 64 //we just repaired the bone, stops the gelling after setting
#define LIMB_SPLINTED_INDESTRUCTIBLE 128 // Splint is indestructible

///////////////SURGERY DEFINES///////////////
#define SPECIAL_SURGERY_INVALID	"special_surgery_invalid"

#define HEMOSTAT_MIN_DURATION 20
#define HEMOSTAT_MAX_DURATION 40

#define BONESETTER_MIN_DURATION 40
#define BONESETTER_MAX_DURATION 60

#define BONEGEL_REPAIR_MIN_DURATION 20
#define BONEGEL_REPAIR_MAX_DURATION 40

#define FIXVEIN_MIN_DURATION 40
#define FIXVEIN_MAX_DURATION 60

#define FIX_ORGAN_MIN_DURATION 40
#define FIX_ORGAN_MAX_DURATION 60

#define RETRACTOR_MIN_DURATION 10
#define RETRACTOR_MAX_DURATION 20

#define CIRCULAR_SAW_MIN_DURATION 40
#define CIRCULAR_SAW_MAX_DURATION 60

#define INCISION_MANAGER_MIN_DURATION 40
#define INCISION_MANAGER_MAX_DURATION 60

#define SCALPEL_MIN_DURATION 20
#define SCALPEL_MAX_DURATION 40

#define CAUTERY_MIN_DURATION 40
#define CAUTERY_MAX_DURATION 60

#define AMPUTATION_MIN_DURATION 70
#define AMPUTATION_MAX_DURATION 90

#define SURGICAL_DRILL_MIN_DURATION 70
#define SURGICAL_DRILL_MAX_DURATION 90

#define IMPLANT_MIN_DURATION 40
#define IMPLANT_MAX_DURATION 60

#define REMOVE_OBJECT_MIN_DURATION 40
#define REMOVE_OBJECT_MAX_DURATION 60

#define BONECHIPS_MAX_DAMAGE 20

#define LIMB_PRINTING_TIME 550
#define LIMB_METAL_AMOUNT 125

// INTEGRITY STUFF

#define LIMB_INTEGRITY_AUTOHEAL_THRESHOLD 39
#define MAX_LIMB_INTEGRITY 200
#define MINIMUM_AUTOHEAL_DAMAGE_INTERVAL 10 SECONDS
#define MINIMUM_AUTOHEAL_HEALTH 50

#define LIMB_INTEGRITY_PERFECT      0
#define LIMB_INTEGRITY_OKAY         1
#define LIMB_INTEGRITY_CONCERNING   2
#define LIMB_INTEGRITY_SERIOUS      3
#define LIMB_INTEGRITY_CRITICAL     4
#define LIMB_INTEGRITY_NONE         5

#define LIMB_INTEGRITY_EFFECT_PERFECT      (0)
#define LIMB_INTEGRITY_EFFECT_MINOR        (1 << 0)
#define LIMB_INTEGRITY_EFFECT_MODERATE		(1 << 1)
#define LIMB_INTEGRITY_EFFECT_MAJOR      	(1 << 2)
#define LIMB_INTEGRITY_EFFECT_SERIOUS     (1 << 3)
#define LIMB_INTEGRITY_EFFECT_CRTICAL         (1 << 4)

#define LIMB_INTEGRITY_THRESHOLD_PERFECT 0 //0-29
#define LIMB_INTEGRITY_THRESHOLD_OKAY 30 //30-79
#define LIMB_INTEGRITY_THRESHOLD_CONCERNING 80 // 80-139
#define LIMB_INTEGRITY_THRESHOLD_SERIOUS 140 // 140-199
#define LIMB_INTEGRITY_THRESHOLD_CRITICAL 200

#define NO_INTERNAL_DAMAGE 0
#define INT_DMG_MULTIPLIER_NORMAL 1
#define INT_DMG_MULTIPLIER_SHARP 1.2
#define INT_DMG_MULTIPLIER_VERYSHARP 1.5

// Surgery chance modifiers
#define SURGERY_MULTIPLIER_SMALL 	0.10
#define SURGERY_MULTIPLIER_MEDIUM 	0.20
#define SURGERY_MULTIPLIER_LARGE	0.40
#define SURGERY_MULTIPLIER_HUGE 	0.60

// ORDERS
#define COMMAND_ORDER_RANGE		7
#define COMMAND_ORDER_COOLDOWN 	800
#define COMMAND_ORDER_MOVE 		"move"
#define COMMAND_ORDER_FOCUS 	"focus"
#define COMMAND_ORDER_HOLD 		"hold"

#define ORDER_HOLD_MAX_LEVEL    15
#define ORDER_HOLD_CALC_LEVEL	20
#define ORDER_MOVE_MAX_LEVEL    50
#define ORDER_FOCUS_MAX_LEVEL   50

//Human Overlays Indexes used in update_icons/////////
#define UNDERWEAR_LAYER			38
#define UNDERSHIRT_LAYER		37
#define MUTANTRACE_LAYER		36
#define FLAY_LAYER 				35.5 //For use by Hunter Flay
#define DAMAGE_LAYER			35
#define UNIFORM_LAYER			34
#define TAIL_LAYER				33	//bs12 specific. this hack is probably gonna come back to haunt me
#define ID_LAYER				32
#define SHOES_LAYER				31
#define GLOVES_LAYER			30
#define MEDICAL_LAYER			29	//For splint and gauze overlays
#define SUIT_LAYER				28
#define SUIT_GARB_LAYER			27
#define SUIT_SQUAD_LAYER		26
#define GLASSES_LAYER			25
#define BELT_LAYER				24
#define SUIT_STORE_LAYER		23
#define BACK_LAYER				22
#define HAIR_LAYER				21
#define FACIAL_LAYER			20
#define EARS_LAYER				19
#define FACEMASK_LAYER			18
#define HEAD_LAYER				17
#define HEAD_SQUAD_LAYER		16
#define HEAD_GARB_LAYER_2		15	// These actual defines are unused but this space within the overlays list is
#define HEAD_GARB_LAYER_3		14	//  |
#define HEAD_GARB_LAYER_4		13	//  |
#define HEAD_GARB_LAYER_5		12	// End here
#define HEAD_GARB_LAYER			11
#define BACK_FRONT_LAYER        10 // For backpacks when mob is facing north
#define COLLAR_LAYER			9
#define HANDCUFF_LAYER			8
#define LEGCUFF_LAYER			7
#define L_HAND_LAYER			6
#define R_HAND_LAYER			5
#define BURST_LAYER				4	//Chestburst overlay
#define TARGETED_LAYER			3	//for target sprites when held at gun point, and holo cards.
#define FIRE_LAYER				2	//If you're on fire		//BS12: Layer for the target overlay from weapon targeting system
#define EFFECTS_LAYER			1  //If you're hit by an acid DoT
#define TOTAL_LAYERS			38
//////////////////////////////////
