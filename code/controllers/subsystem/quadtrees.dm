SUBSYSTEM_DEF(quadtree)
    name = "Quadtree"
    wait = 0.5 SECONDS 
    priority = SS_PRIORITY_QUADTREE

    var/list/cur_quadtrees 
    var/list/new_quadtrees 
    var/list/player_feed
    var/qtree_capacity = QUADTREE_CAPACITY

/datum/controller/subsystem/quadtree/Initialize()
    cur_quadtrees = new/list(world.maxz)
    new_quadtrees = new/list(world.maxz)
    var/datum/shape/rectangle/R
    for(var/i in 1 to length(cur_quadtrees))
        R = RECT(world.maxx/2,world.maxy/2, world.maxx, world.maxy)
        new_quadtrees[i] = QTREE(R, qtree_capacity, i)
    return ..()

/datum/controller/subsystem/quadtree/stat_entry()
	..("QT:[length(cur_quadtrees)]")

/datum/controller/subsystem/quadtree/fire(resumed = FALSE)
    if(!resumed)
        player_feed = player_list.Copy()
        cur_quadtrees = new_quadtrees.Copy()
        if(new_quadtrees.len < world.maxz)
            new_quadtrees.len = world.maxz
        for(var/i in 1 to world.maxz)
            new_quadtrees[i] = QTREE(RECT(world.maxx/2,world.maxy/2, world.maxx, world.maxy), qtree_capacity, i)

    while(length(player_feed))
        var/mob/M = player_feed[player_feed.len]
        player_feed.len--
        for(var/datum/quadtree/Q in new_quadtrees)
            Q.insert_player(M)
        if(MC_TICK_CHECK)
            return

/datum/controller/subsystem/quadtree/proc/players_in_range(datum/shape/range, z_level, flags = 0)
    var/list/players = list()
    if(z_level && cur_quadtrees.len >= z_level)
        var/datum/quadtree/Q = cur_quadtrees[z_level]
        if(!Q)
            return players
        players = SEARCH_QTREE(Q, range, flags)
    return players
