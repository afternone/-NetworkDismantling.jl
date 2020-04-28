function HDA(g, threshold=sqrt(nv(g)))
	attack_nodes = high_degree_adaptive(g)
	present = fill(true, nv(g))
	present[attack_nodes] .= false
	reinsert_nodes = reverse_greedy!(present, g, threshold)
	return [i for i in attack_nodes if !present[i]]
end

function CoreHD(g, threshold=sqrt(nv(g)))
	decycling_nodes = decore(g)
	present = fill(true, nv(g))
	present[decycling_nodes] .= false
	treebreak_nodes, _ = tree_break!(present, g, threshold)
	reinsert_nodes = reverse_greedy!(present, g, threshold)
	return [i for i in [decycling_nodes;treebreak_nodes] if !present[i]]
end

function WeakNei(g, threshold=sqrt(nv(g)))
	decycling_nodes = weak_neighbor_decore(g)
	present = fill(true, nv(g))
	present[decycling_nodes] .= false
	treebreak_nodes, _ = tree_break!(present, g, threshold)
	reinsert_nodes = reverse_greedy!(present, g, threshold)
	return [i for i in [decycling_nodes;treebreak_nodes] if !present[i]]
end
