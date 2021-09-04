/mob/living/silicon/robot/death(datum/cause_data/cause_data, gibbed)
	if(camera)
		camera.status = 0
	if(module)
		var/obj/item/device/gripper/G = locate(/obj/item/device/gripper) in module
		if(G) G.drop_item()
	remove_robot_verbs()
	. = ..(cause_data, gibbed, "is destroyed!")
	playsound(src.loc, 'sound/effects/metal_crash.ogg', 30)
	robogibs(src)
	qdel(src)
