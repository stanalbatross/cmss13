/datum/tech/droppod/item/modular_armor_upgrade
    name = "Squad Engineer Combat Zone Support Package"
    desc = {"Gives upgraded composite (deployable) cades to regulars. \
            Gives squad engineers a mod kit for their deployable."}
    icon_state = "red"

    flags = TREE_FLAG_MARINE

    required_points = 0
    tier = TECH_TIER_ONE

    options = list()

/datum/tech/droppod/item/modular_armor_upgrade/on_pod_access(mob/living/carbon/human/H, obj/structure/droppod/D)
    if(H.job == JOB_SQUAD_ENGI)
        options = list(
            "Engineering Upgrade Kit" = /obj/item/engi_upgrade_kit
        )
    else
        options = list(
            "Upgraded Composite Barricade" = /obj/item/folding_barricade/upgraded
        )

    . = ..()
    return

/obj/item/engi_upgrade_kit
    name = "engineering upgrade kit"
    desc = "It seems to be a kit to upgrade an engineer's structure"

/obj/item/engi_upgrade_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
    . = ..()
    to_chat(user, "THIS KIT IS A WORK IN PROGRESS!!")

/obj/item/folding_barricade/upgraded
    name = "Upgraded MB-6 Folding Barricade"
    
    health = 500
    maxhealth = 500