"""
Remove minimum number of nodes so that the graph no longer exists k-core
"""
function decore(g, k=2)
	attack_nodes = Int[]
	deg = degree(g) # adaptive degrees
	degmax = maximum(deg)
	H = [Set{Int}() for i=1:degmax]

	for i in vertices(g)
		if deg[i] > 0
			degi = max(deg[i], k-1)
			push!(H[degi], i)
		end
	end

	d = isempty(H[k-1]) ? degmax : k-1
	cnt = 0
	done = false
	while cnt < nv(g) && done == false
		cnt += 1
		i = rand(H[d])
		delete!(H[d], i)
		deg[i] = 0
		d >= k && push!(attack_nodes, i)

		# update neighbors
		for j in neighbors(g,i)
			if deg[j] >= k
				delete!(H[deg[j]], j)
				deg[j] -= 1
				push!(H[deg[j]],j)
			end
		end

		while isempty(H[degmax])
			degmax -= 1
			done = degmax < k
		end
		d = isempty(H[k-1]) ? degmax : k-1
	end
	attack_nodes
end
