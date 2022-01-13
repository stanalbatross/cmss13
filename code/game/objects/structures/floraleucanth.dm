//-------------------------- ICHOR BULBS --------------------------------

/obj/structure/flora/bulb_ichor
	name = "Ichor Bulb"
	desc = "Dark woody vines growing engorged bulbs full of some yellowish liquid."
	anchored = TRUE
	density = TRUE
	icon_tag = "bulb_S"
	icon = 'icons/obj/structures/props/leucanth.dmi'
	icon_state = "bulb_S_1"
	variations = 4
	cut_level = 3 //taken from flora.dm 3 means machete insta breaks it :o)
	cut_hits = 5
	var/splash_size = 2
	var/datum/ammo/ichor/splash_ammo = /datum/ammo/ichor

/obj/structure/flora/bulb_ichor/fire_act()
	overlays += image('icons/mob/hostiles/Effects.dmi', "alienegg_fire")
	SetLuminosity(3)
	addtimer(CALLBACK(src, .proc/destroy), rand(20,80))

/obj/structure/flora/bulb_ichor/bullet_act(obj/item/projectile/P)
	. = ..()
	if(P.damage_type == BRUTE) //bad code
		Destroy()

/obj/structure/flora/bulb_ichor/Destroy()
	playsound(src.loc, "sound/effects/splat.ogg", 25)
	splash()
	var/obj/structure/flora/bulbvines/bibi = new /obj/structure/flora/bulbvines(src.loc)
	bibi.update_icon(icon, icon_state)
	..()

/obj/structure/flora/bulb_ichor/proc/splash()
	for(var/i = 1, i <= splash_size, i++)
		var/obj/item/projectile/P = new /obj/item/projectile(src.loc, create_cause_data(name))
		var/datum/ammo/ammoDatum = GLOB.ammo_list[splash_ammo]
		P.generate_bullet(ammoDatum)
		P.permutated += src
		var/list/targets = range(rand(2,5), src.loc)
		P.fire_at(targets[rand(1,length(targets))], src, src, ammoDatum.max_range, ammoDatum.shell_speed)

/obj/structure/flora/bulb_ichor/medium
	icon_tag = "bulb_M"
	icon = 'icons/obj/structures/props/leucanth32x64.dmi'
	icon_state = "bulb_M_1"
	variations = 2
	splash_size = 4

/obj/structure/flora/bulb_ichor/large
	icon_tag = "bulb_L"
	icon = 'icons/obj/structures/props/leucanth64x64.dmi'
	icon_state = "bulb_L_1"
	variations = 3
	splash_size = 6

//----------------------------ICHOR BULB VINES---------------------------------

/obj/structure/flora/bulbvines
	name = "Ichor Bulb"
	desc = "Dark woody vines growing small bulbs full of some yellowish liquid."
	anchored = TRUE
	density = FALSE
	icon_tag = "bulbvines_S"
	icon = 'icons/obj/structures/props/leucanth.dmi'
	icon_state = "bulbvines_S_1"
	variations = 3
	cut_level = 1 //check flora.dm NO_CUT
	var/variation_icon_state = null

/obj/structure/flora/bulbvines/Initialize()
	..()
	variation_icon_state = icon_state

/obj/structure/flora/bulbvines/update_icon(given_icon, given_icon_state)
	if(given_icon && given_icon_state)
		icon = given_icon
		icon_state = "[given_icon_state]_broken"
	else
		icon = initial(icon)
		icon_state = variation_icon_state

/obj/structure/flora/bulbvines/medium
	icon = 'icons/obj/structures/props/leucanth64x32.dmi'
	icon_tag = "bulbvines_M"
	icon_state = "bulbvines_M_1"
	variations = 2

