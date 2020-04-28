function high_degree_adaptive(g)
	attack_nodes = Int[]
	deg = degree(g)
	degmax = maximum(deg)
	H = [Set{Int}() for i=1:degmax]

	for i in vertices(g)
		deg[i] > 0 && push!(H[deg[i]], i)
	end

	while degmax > 0
		if !isempty(H[degmax])
			i = rand(H[degmax])
			delete!(H[degmax], i)
			deg[i] = 0
			push!(attack_nodes, i)
			for j in neighbors(g,i)
				if deg[j] > 0
					delete!(H[deg[j]], j)
					deg[j] -= 1
					deg[j] > 0 && push!(H[deg[j]], j)
				end
			end
		else
			degmax -= 1
		end
	end
	return attack_nodes
end
