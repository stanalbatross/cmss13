/datum/tech/droppod/item/medic
    name = "Squad Medic Combat Zone Support Package"
    desc = "Gives medics to use powerful tools to heal marines."
    icon_state = "red"

    flags = TREE_FLAG_MARINE

    required_points = 0
    tier = TECH_TIER_ONE
    options = list(
        "Combat Zone Support Package" = /obj/item/storage/box/combat_zone_support_package
    )

/datum/tech/droppod/item/medic/can_access(var/mob/living/carbon/human/H, var/obj/structure/droppod/D)
    if(H.job != JOB_SQUAD_MEDIC)
        to_chat(H, SPAN_WARNING("This droppod is for medics only!"))
        return FALSE

    . = ..()

/obj/item/storage/box/combat_zone_support_package
    name = "squad medic combat zone support package"
    storage_slots = 2

/obj/item/storage/box/combat_zone_support_package/Initialize()
    . = ..()
    new/obj/item/storage/box/medic_upgraded_kits(src)
    new/obj/item/stack/medical/splint/nano(src)


/obj/item/storage/box/medic_upgraded_kits
    name = "medical upgrade kit"
    max_w_class = SIZE_MEDIUM

    storage_slots = 4

/obj/item/storage/box/medic_upgraded_kits/Initialize()
    . = ..()
    new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
    new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
    new /obj/item/stack/medical/advanced/ointment/upgraded(src)
    new /obj/item/stack/medical/advanced/ointment/upgraded(src)

/obj/item/stack/medical/advanced/ointment/upgraded
    name = "upgraded advance burn kit"
    singular_name = "upgraded advance burn kit"
    stack_id = "upgraded advanced burn kit"

/obj/item/stack/medical/advanced/ointment/upgraded/Initialize(mapload, ...)
    . = ..()
    heal_burn = initial(heal_burn) * 3 // 3x stronger

/obj/item/stack/medical/advanced/bruise_pack/upgraded
    name = "upgraded advance trauma kit"
    singular_name = "upgraded advance trauma kit"
    stack_id = "upgraded advanced trauma kit"

/obj/item/stack/medical/advanced/bruise_pack/upgraded/Initialize(mapload, ...)
    . = ..()
    heal_brute = initial(heal_brute) * 3 // 3x stronger

/obj/item/stack/medical/splint/nano
    name = "nano splints"
    singular_name = "nano splint"

    indestructible_splints = TRUE
    amount = 2
    max_amount = 2

    stack_id = "nano splint"