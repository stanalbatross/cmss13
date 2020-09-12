/obj/structure/droppod
    name = "\improper Droppod"

    icon = 'icons/obj/structures/droppod_32x64.dmi'
    icon_state = "techpod_closed"

    density = FALSE
    invisibility = 101

    climbable = TRUE
    climb_delay = 2

    unslashable = TRUE
    unacidable = TRUE

    var/droppod_flags = NO_FLAGS

    var/land_damage = 5000
    var/tiles_to_take = 15

    var/drop_time = SECONDS_2

    layer = ABOVE_FLY_LAYER
    appearance_flags = TILE_BOUND | KEEP_TOGETHER

    var/obj/effect/lz/warning_zone

/obj/structure/droppod/Initialize(mapload, var/time_to_drop = 0)
    . = ..()
    warn_turf(loc)
    add_timer(CALLBACK(src, .proc/drop_on_target, loc), time_to_drop)

    update_icon()

/obj/structure/droppod/Dispose()
    . = ..()
    if(warning_zone)
        qdel(warning_zone)
        warning_zone = null

/obj/structure/droppod/update_icon()
    overlays.Cut()
    if(!(droppod_flags & DROPPOD_DROPPED))
        overlays += image(icon, src, "chute_cables_static")
        var/image/I = image('icons/obj/structures/droppod_64x64.dmi', src, "chute_static")

        I.pixel_x -= 16
        I.pixel_y += 16

        overlays += I

    if(droppod_flags & DROPPOD_OPEN)
        icon_state = "techpod_open"
    else
        icon_state = "techpod_closed"

    if(droppod_flags & DROPPOD_STRIPPED)
        icon_state = "[icon_state]_stripped"

/obj/structure/droppod/attackby(obj/item/W, mob/user)
    if(!ishuman(user))
        return . = ..()

    var/mob/living/carbon/human/H = user

    if(H.action_busy)
        return . = ..()

    if(droppod_flags & DROPPOD_STRIPPED)
        return . = ..()

    if(iscrowbar(W))
        visible_message(SPAN_NOTICE("[H] begins to pry off the external plating on [src]."))
        playsound(loc, 'sound/items/Crowbar.ogg', 75)

        if(!do_after(H, SECONDS_5, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src, INTERRUPT_ALL))
            return

        if(droppod_flags & DROPPOD_STRIPPED)
            return

        visible_message(SPAN_NOTICE("[H] pries off the external plating on [src]."))
        droppod_flags |= DROPPOD_STRIPPED

        new/obj/item/stack/sheet/metal/small_stack(loc)
        new/obj/item/stack/sheet/plasteel(loc, 5)

        update_icon()
    else
        . = ..()

/obj/structure/droppod/proc/open(mob/user)
    droppod_flags |= DROPPOD_OPEN
    update_icon()

/obj/structure/droppod/proc/warn_turf(var/turf/T)
    if(warning_zone)
        qdel(warning_zone)

    warning_zone = new(T)

/obj/structure/droppod/proc/drop_on_target(var/turf/T)
    droppod_flags |= DROPPOD_DROPPING

    invisibility = FALSE

    pixel_y = 32*tiles_to_take
    animate(src, pixel_y = 0, time = drop_time, easing = LINEAR_EASING)

    add_timer(CALLBACK(src, .proc/land, T), drop_time)

/obj/structure/droppod/proc/land(var/turf/T)
    if(warning_zone)
        qdel(warning_zone)
        warning_zone = null

    droppod_flags &= ~DROPPOD_DROPPING
    layer = MOB_LAYER

    for(var/mob/M in T)
        M.gib(initial(name))

    for(var/obj/structure/O in T)
        O.update_health(-land_damage)

    for(var/mob/M in view(7, T))
        shake_camera(M, 4, 5)

    forceMove(T)

    density = TRUE
    droppod_flags |= DROPPOD_DROPPED
    update_icon()

    add_timer(CALLBACK(src, .proc/open), SECONDS_3)