/*

EARLY FOOLO PROJECT
/datum/surgery_procedure/fix_bone
    name = "Bone Reparation Procedure"
    common_steps = list(/datum/surgery_step/move_bone,
                        /datum/surgery_step/drain_blood_bone,
                        /datum/surgery_step/pick_fragments,
                        /datum/surgery_step/glue_fragments,
                        /datum/surgery_step/heal_bone,
                        /datum/surgery_step/set_bone)
    open_stage = 1

/datum/surgery_procedure/fix_bone/hairline
    name = "Bone Reparation Procedure (Hairline)"
    special_sequence_change_point = 3
    special_sequence = list(null,
                          null,
                          /datum/surgery_step/fill_fracture,
                          /datum/surgery_step/heal_bone
                          )//Skips fragment picking & setting

/datum/surgery_procedure/fix_bone/broken
    name = "Bone Reparation Procedure (Broken)"
    special_sequence_change_point = 1
    special_sequence = list(/datum/surgery_step/remove_bone,
                          /datum/surgery_step/drain_blood_bone,
                          /datum/surgery_step/glue_ends,
                          /datum/surgery_step/replace_bone
                          )
/datum/surgery_procedure/fix_bone/dislocation
    name = "Bone Reparation Procedure (Dislocation)"
    special_sequence_change_point = 1
    special_sequence = list(/datum/surgery_step/heal_trauma,
                          /datum/surgery_step/realign_bone,
                          /datum/surgery_step/set_bone,
                          /datum/surgery_step/heal_bone
                          )

/datum/surgery_procedure/fix_muscle
    name = "Muscle Reparation Procedure"
    open_stage = 1
    common_steps = list(/datum/surgery_step/drain_blood_muscle,
                        /datum/surgery_step/tension_muscle,
                        /datum/surgery_step/rebuild_muscle_veins,
                        /datum/surgery_step/apply_synthmuscle,
                        /datum/surgery_step/apply_muscle_growth,
                        /datum/surgery_step/stitch_muscle)

/datum/surgery_procedure/fix_muscle/tendon
    name = "Muscle Reparation Procedure (Severed Tendon)"
    special_sequence_change_point = 1
    special_sequence = list(/datum/surgery_step/pull_tendon,
                          /datum/surgery_step/stitch_muscle,
                          /datum/surgery_step/apply_muscle_growth,
                          /datum/surgery_step/heal_tendon_bone
                          )

/datum/surgery_procedure/fix_muscle/tear
    name = "Muscle Reparation Procedure (Partial Tear)"
    special_sequence_change_point = 2
    special_sequence = list(null,
                          /datum/surgery_step/apply_synthmuscle,
                          /datum/surgery_step/apply_muscle_growth,
                          /datum/surgery_step/stitch_muscle
                          )

/datum/surgery_procedure/fix_muscle/hemorrage
    name = "Muscle Reparation Procedure (Hemorraging)"
    special_sequence_change_point = 2
    special_sequence = list(null,
                          /datum/surgery_step/retract_muscle,
                          /datum/surgery_step/rebuild_muscle_veins,
                          /datum/surgery_step/apply_muscle_growth
                          )

*/