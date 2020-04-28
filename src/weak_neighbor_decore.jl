# get all neighbors at distance l
function l_hop_neighbors!(g, u, l, bfsqueue, is_visited, k)
    startIt, endIt = 1, 2
	bfsqueue[1] = u
	is_visited[u] = true

	for i=1:l
		lastEndIt = endIt
		while startIt != lastEndIt
			for v in neighbors(g, bfsqueue[startIt])
				if k[v] > 0 && !is_visited[v]
					bfsqueue[endIt] = v
					endIt += 1
					is_visited[v] = true
				end
			end
			startIt += 1
		end
	end

	for i=1:endIt-1
		is_visited[bfsqueue[i]] = false
	end
	return startIt, endIt-1
end

function weak_neighbor_decore(g,k=2)
	n = nv(g)
	attack_nodes = Int[]
	deg = degree(g)
	degmax = maximum(deg)
	score = zeros(Int,n)
	bfsqueue = zeros(Int,n)
	is_visited = fill(false, n)
	H = [SortedDict{Int,Set{Int}}() for i=1:degmax]

	for i in vertices(g)
		if deg[i] > 0
			deg_i = max(deg[i], k-1)
			scr_i = 0
			for j in neighbors(g,i)
				scr_i += deg[j]
			end
			score[i] = scr_i
			if haskey(H[deg_i], scr_i)
				push!(H[deg_i][scr_i],i)
			else
				H[deg_i][scr_i] = Set{Int}(i)
			end
		end
	end

	d = isempty(H[k-1]) ? degmax : k-1
	cnt = 0
	done = false
	while cnt < n && done == false
		cnt += 1
		# get the min score of degree d nodes
		min_scr_d, list = first(H[d])

		# remove one of them at random
		i = rand(list)

		# if d >= k add them to the seed set
		d >= k && push!(attack_nodes, i)

		# remove element from H
		delete!(list, i)
		deg[i] = 0
		isempty(list) && delete!(H[d],min_scr_d)

		# update scores of 1-hop neighbors
		startIt, endIt = l_hop_neighbors!(g, i, 1, bfsqueue, is_visited, deg)
		for index in startIt:endIt
			j = bfsqueue[index]
			deg_j = max(deg[j],k-1)
			list = H[deg_j][score[j]]
			delete!(list,j)
			isempty(list) && delete!(H[deg_j], score[j])
			deg[j] -= 1
		end
		for index in startIt:endIt
			j = bfsqueue[index]
			deg_j = max(deg[j],k-1)
			scr_j = 0
			for nb in neighbors(g,j)
				if deg[nb] > 0
					scr_j += deg[nb]
				end
			end
			score[j] = scr_j
			if haskey(H[deg_j],scr_j)
				push!(H[deg_j][scr_j],j)
			else
				H[deg_j][scr_j] = Set{Int}(j)
			end
		end

		# update scores of 2-hop neighbors
		startIt, endIt = l_hop_neighbors!(g, i, 2, bfsqueue, is_visited, deg)
		for index in startIt:endIt
			j = bfsqueue[index]
			deg_j = max(deg[j],k-1)
			list = H[deg_j][score[j]]
			delete!(list,j)
			isempty(list) && delete!(H[deg_j], score[j])
			scr_j = 0
			for nb in neighbors(g,j)
				if deg[nb] > 0
					scr_j += deg[nb]
				end
			end
			score[j] = scr_j
			if haskey(H[deg_j],scr_j)
				push!(H[deg_j][scr_j],j)
			else
				H[deg_j][scr_j] = Set{Int}(j)
			end
		end

		while isempty(H[degmax])
			degmax -= 1
			done = degmax <= k-1
		end

		d = isempty(H[k-1]) ? degmax : k-1
	end
	attack_nodes
end
