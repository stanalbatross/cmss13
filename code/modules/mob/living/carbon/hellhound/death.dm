
/mob/living/carbon/hellhound/death(datum/cause_data/cause_data, var/gibbed)
	emote("roar")
	GLOB.hellhound_list -= src
	SSmob.living_misc_mobs -= src
	..(cause_data, gibbed, "lets out a horrible roar as it collapses and stops moving...")
