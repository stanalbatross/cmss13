GLOBAL_LIST_EMPTY(processing_resources)
GLOBAL_LIST_EMPTY(processing_techs)

SUBSYSTEM_DEF(techtree)
    name     = "Tech Tree"
    init_order    = SS_INIT_TECHTREE
    priority      = SS_PRIORITY_TECHTREE

    var/list/datum/techtree/trees = list()
    var/list/datum/tech/nodes = list()

    var/list/obj/structure/resource_node/resources = list()

    var/list/currentrun_nodes = list()
    var/list/currentrun_resource = list()

/datum/controller/subsystem/techtree/Initialize()
    var/list/tech_trees = subtypesof(/datum/techtree)
    var/list/tech_nodes = subtypesof(/datum/tech)

    if(!tech_trees.len)
        log_admin(SPAN_DANGER("\b Error setting up tech trees, no datums found."))
    if(!tech_nodes.len)
        log_admin(SPAN_DANGER("\b Error setting up tech nodes, no datums found."))

    for(var/T in tech_trees)
        var/datum/techtree/tree = new T()
        if(!tree || tree.flags == NO_FLAGS)
            qdel(tree)
            continue

        trees += list("[tree.name]" = tree)

        world.maxz += 1
        tree.zlevel = world.maxz
        var/turf/z_min = locate(1, 1, tree.zlevel)
        var/turf/z_max = locate(world.maxx, world.maxy, tree.zlevel)

        var/obj/structure/resource_node/passive_node = new(z_max, FALSE, FALSE)
        passive_node.set_tree(tree.name)

        tree.passive_node = passive_node

        for(var/turf/Tu in block(z_min, z_max))
            Tu.ChangeTurf(/turf/closed/void, list(/turf/closed/void))
            new /area/techtree(Tu)

        for(var/tier in tree.tree_tiers)
            LAZYADD(tree.unlocked_techs, tier)
            LAZYADD(tree.all_techs, tier)
            tree.unlocked_techs[tier] = list()
            tree.all_techs[tier] = list()

        for(var/N in tech_nodes)
            var/datum/tech/node = new N()
            var/tier = node.tier

            if(node.flags == NO_FLAGS || !(tier in tree.all_techs))
                qdel(node)
                continue

            if(tree.flags & node.flags)
                tree.all_techs[tier] += list(node.type = node)
                LAZYADD(nodes, node)

                node.tier = tree.tree_tiers[node.tier]
                node.holder = tree
                if(node.processing_info == TECH_ALWAYS_PROCESS)
                    GLOB.processing_techs.Add(node)

        tree.generate_tree()
    
    . = ..()

/datum/controller/subsystem/techtree/proc/activate_passive_nodes()
    for(var/name in trees)
        var/datum/techtree/T = trees[name]

        if(T.passive_node.active)
            continue
        
        T.passive_node.make_active()

/datum/controller/subsystem/techtree/proc/activate_all_nodes()
    for(var/obj/structure/resource_node/RN in resources)
        if(QDELETED(RN))
            resources.Remove(RN)
            continue

        if(RN.active)
            continue
        
        RN.make_active()
        


/datum/controller/subsystem/techtree/fire(resumed = FALSE)
    if (!resumed)
        currentrun_nodes = GLOB.processing_techs.Copy()
        currentrun_resource = GLOB.processing_resources.Copy()

    while (currentrun_nodes.len)
        var/datum/tech/o = currentrun_nodes[currentrun_nodes.len]
        currentrun_nodes.len--

        if (!o || QDELETED(o))
            continue

        o.fire()
        if (MC_TICK_CHECK)
            return

    while (currentrun_resource.len)
        var/obj/structure/resource_node/o = currentrun_resource[currentrun_resource.len]
        currentrun_resource.len--

        if (!istype(o) || QDELETED(o) || o.next_cycle_at > world.time)
            continue

        o.cycle()
        if (MC_TICK_CHECK)
            return
    
