/obj/item/ammo_magazine/grappling
	name = "\improper M4A3 magazine (9mm)"
	desc = "A pistol magazine."
	caliber = "9mm"
	icon_state = "m4a3"
	max_rounds = 9
	w_class = SIZE_SMALL
	default_ammo = /datum/ammo/bullet/pistol/heavy
	gun_type = /obj/item/weapon/gun/grappling


//-------code for the projectile---------\\

/obj/projectile/tentacle
	name = "tentacle"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	var/chain
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it
	///Click params that were used to fire the tentacle shot
	var/list/fire_modifiers

/obj/projectile/tentacle/Initialize(mapload)
	source = loc
	. = ..()

/obj/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle")
	..()

/obj/projectile/tentacle/proc/reset_throw(mob/living/carbon/human/H)
	if(H.throw_mode)
		H.throw_mode_off(THROW_MODE_TOGGLE) //Don't annoy the changeling if he doesn't catch the item

/obj/projectile/tentacle/proc/tentacle_grab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		if(H.get_active_held_item() && !H.get_inactive_held_item())
			H.swap_hand()
		if(H.get_active_held_item())
			return
		C.grabbedby(H)
		C.grippedby(H, instant = TRUE) //instant aggro grab

/obj/projectile/tentacle/proc/tentacle_stab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		for(var/obj/item/I in H.held_items)
			if(I.get_sharpness())
				C.visible_message(span_danger("[H] impales [C] with [H.p_their()] [I.name]!"), span_userdanger("[H] impales you with [H.p_their()] [I.name]!"))
				C.apply_damage(I.force, BRUTE, BODY_ZONE_CHEST)
				H.do_item_attack_animation(C, used_item = I)
				H.add_mob_blood(C)
				playsound(get_turf(H),I.hitsound,75,TRUE)
				return

/obj/projectile/tentacle/on_hit(atom/target, blocked = FALSE)
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isitem(target))
		var/obj/item/I = target
		if(!I.anchored)
			to_chat(firer, span_notice("You pull [I] towards yourself."))
			H.throw_mode_on(THROW_MODE_TOGGLE)
			I.throw_at(H, 10, 2)
			. = BULLET_ACT_HIT

	else if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)//avoid double hits
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				var/firer_combat_mode = TRUE
				var/mob/living/living_shooter = firer
				if(istype(living_shooter))
					firer_combat_mode = living_shooter.combat_mode
				if(fire_modifiers && fire_modifiers["right"])
					var/obj/item/I = C.get_active_held_item()
					if(I)
						if(C.dropItemToGround(I))
							C.visible_message(span_danger("[I] is yanked off [C]'s hand by [src]!"),span_userdanger("A tentacle pulls [I] away from you!"))
							on_hit(I) //grab the item as if you had hit it directly with the tentacle
							return BULLET_ACT_HIT
						else
							to_chat(firer, span_warning("You can't seem to pry [I] off [C]'s hands!"))
							return BULLET_ACT_BLOCK
					else
						to_chat(firer, span_danger("[C] has nothing in hand to disarm!"))
						return BULLET_ACT_HIT
				if(firer_combat_mode)
					C.visible_message(span_danger("[L] is thrown towards [H] by a tentacle!"),span_userdanger("A tentacle grabs you and throws you towards [H]!"))
					C.throw_at(get_step_towards(H,C), 8, 2, H, TRUE, TRUE, callback=CALLBACK(src, .proc/tentacle_stab, H, C))
					return BULLET_ACT_HIT
				else
					C.visible_message(span_danger("[L] is grabbed by [H]'s tentacle!"),span_userdanger("A tentacle grabs you and pulls you towards [H]!"))
					C.throw_at(get_step_towards(H,C), 8, 2, H, TRUE, TRUE, callback=CALLBACK(src, .proc/tentacle_grab, H, C))
					return BULLET_ACT_HIT

			else
				L.visible_message(span_danger("[L] is pulled by [H]'s tentacle!"),span_userdanger("A tentacle grabs you and pulls you towards [H]!"))
				L.throw_at(get_step_towards(H,L), 8, 2)
				. = BULLET_ACT_HIT

/obj/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()
