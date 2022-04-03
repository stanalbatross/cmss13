/*
 * Construction Node
 */

/obj/effect/alien/resin/construction
	name = "construction node"
	desc = "A strange wriggling lump. Looks like a marker for something."
	icon = 'icons/mob/hostiles/weeds.dmi'
	icon_state = "constructionnode"
	density = 0
	anchored = 1
	health = 200
	block_range = 1

	var/datum/construction_template/xenomorph/template //What we're building

/obj/effect/alien/resin/construction/Initialize(mapload, var/hive_ref)
	. = ..()
	faction = hive_ref
	if (faction.color)
		color = faction.color

/obj/effect/alien/resin/construction/Destroy()
	if(template && faction && (template.crystals_stored < template.crystals_required))
		faction.crystal_stored += template.crystals_stored
		faction.remove_construction(src)
	template = null
	faction = null
	return ..()

/obj/effect/alien/resin/construction/update_icon()
	..()
	overlays.Cut()
	if(template)
		var/image/I = template.get_structure_image()
		I.alpha = 122
		I.pixel_x = template.pixel_x
		I.pixel_y = template.pixel_y
		overlays += I

/obj/effect/alien/resin/construction/examine(mob/user)
	..()
	if((isXeno(user) || isobserver(user)) && faction)
		var/message = "A [template.name] construction is designated here. It requires [template.crystals_required - template.crystals_stored] more [MATERIAL_CRYSTAL]."
		to_chat(user, message)

/obj/effect/alien/resin/construction/attack_alien(mob/living/carbon/Xenomorph/M)
	if(!faction || (faction && (M.faction != faction)) || (M.a_intent == INTENT_HARM && M.can_destroy_special()))
		return ..()
	if(!template)
		to_chat(M, SPAN_XENOWARNING("There is no template!"))
	else
		template.add_crystal(M) //This proc handles attack delay itself.
	return XENO_NO_DELAY_ACTION

/obj/effect/alien/resin/construction/proc/set_template(var/datum/construction_template/xenomorph/new_template)
	if(!istype(new_template) || !faction)
		return
	template = new_template
	template.owner = src
	template.build_loc = get_turf(src)
	template.hive_ref = faction
	update_icon()
