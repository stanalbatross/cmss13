/obj/effect/landmark/structure_spawner/setup/plant
	name = "plant spawner"
	icon_state = "plant1"
	is_turf = FALSE
	path_to_spawn = /obj/structure/flora
	mode_flags = NO_FLAGS

/obj/effect/landmark/structure_spawner/setup/plant/themed //path to spawn changed on init
	name = "themed plant spawner"
	var/list/theme = list(/obj/structure/flora)

/obj/effect/landmark/structure_spawner/setup/plant/themed/Initialize()
	. = ..()
	path_to_spawn = pick(theme)

/obj/effect/landmark/structure_spawner/setup/plant/themed/grass
	name = "grass spawner"
	theme = list(/obj/structure/flora/bush/ausbushes/var3/sparsegrass/random,
				/obj/structure/flora/bush/ausbushes/var3/fullgrass/random)

/obj/effect/landmark/structure_spawner/setup/plant/themed/grass_2
	name = "grass spawner 2"
	theme = list(/obj/structure/flora/bush/ausbushes/var3/sparsegrass,
				/obj/structure/flora/bush/ausbushes/var3/fullgrass)

/obj/effect/landmark/structure_spawner/setup/plant/thick //blocks vision
	name = "thick plant spawner"
	icon_state = "plant2"

/obj/effect/landmark/structure_spawner/setup/plant/thick/dense //blocks vision and is also dense
	name = "dense plant spawner"
	icon_state = "plant3"

