function merge_nodes!(ds, comp_sizes, i, j)
	iroot = find_root(ds, i)
	jroot = find_root(ds, j)
	if iroot != jroot
		root = root_union!(ds, iroot, jroot)
		comp_sizes[root] = comp_sizes[iroot] + comp_sizes[jroot]
		return root
	else
		return iroot
	end
end

function component_neighbors!(nodes_in_comp, mask, compos, label, present, g, u)
    Q = Queue{Int}()
    label[u] = u
	i = 1
	nodes_in_comp[i] = u
    enqueue!(Q, u)
	ncomp = 0
    while !isempty(Q)
        src = dequeue!(Q)
		i += 1
		nodes_in_comp[i] = src
        for vertex in all_neighbors(g, src)
			if present[vertex]
	            if label[vertex] == 0
	                enqueue!(Q, vertex)
	                label[vertex] = u
	            end
			else
				if !mask[vertex]
					mask[vertex] = true
					ncomp += 1
					compos[ncomp] = vertex
				end
			end
        end
    end
	for j in 1:i
		label[nodes_in_comp[j]] = 0
	end
	for j in 1:ncomp
		mask[compos[j]] = false
	end
    return ncomp
end

function reverse_greedy!(present, g, threshold)
	threshold = max(1, round(Int, threshold))
	n = nv(g)
	ds = IntDisjointSets(n)
	reinsert_nodes = Int[]
	comp_sizes = ones(Int, n) # size of the component where the node in
	S = zeros(Int, n)
	Svec = [Set{Int}() for _ in 1:threshold]
	label = zeros(Int, n)
	nodes_in_comp = zeros(Int, n)
	mask = fill(false, n) # auxiliary vector
	compos = zeros(Int, n) # auxiliary vector
	max_comp_size = 1 # record giant component size

	# add edges between present nodes and record component sizes
	for i in vertices(g)
		if present[i]
			for j in neighbors(g,i)
				if present[j]
					newroot = merge_nodes!(ds, comp_sizes, i, j)
					if comp_sizes[newroot] > max_comp_size
						max_comp_size = comp_sizes[newroot]
					end
				end
			end
		end
	end
	smin = threshold
	for i in vertices(g)
		if !present[i]
			s, ncomp = 1, 0
			for j in neighbors(g,i)
				if present[j]
					jroot = find_root(ds,j)
					if !mask[jroot]
						mask[jroot] = true
						ncomp += 1
						compos[ncomp] = jroot
						s += comp_sizes[jroot]
					end
				end
			end
			# reset the auxiliary vector mask
			for k in 1:ncomp
				mask[compos[k]] = false
			end
			s > threshold && continue
			S[i] = s
			push!(Svec[s], i)
			if s < smin
				smin = s
			end
		end
	end

	while smin <= threshold
		if isempty(Svec[smin])
			smin += 1
			continue
		end
		ibest = rand(Svec[smin])
		for j in neighbors(g, ibest)
			if present[j]
				newroot = merge_nodes!(ds, comp_sizes, ibest, j)
				if comp_sizes[newroot] > max_comp_size
					max_comp_size = comp_sizes[newroot]
				end
			end
		end
		max_comp_size > threshold && break
		delete!(Svec[smin], ibest)
		push!(reinsert_nodes, ibest)
		S[ibest] = 0
		present[ibest] = true

		ncomp = component_neighbors!(nodes_in_comp, mask, compos, label, present, g, ibest)
		for index in 1:ncomp
			i = compos[index]
			if 0 < S[i] <= threshold
				s, ncomp = 1, 0
				for j in neighbors(g,i)
					if present[j]
						jroot = find_root(ds,j)
						if !mask[jroot]
							mask[jroot] = true
							ncomp += 1
							compos[ncomp] = jroot
							s += comp_sizes[jroot]
						end
					end
				end
				# reset the auxiliary vector mask
				for k in 1:ncomp
					mask[compos[k]] = false
				end
				if S[i] != s
					delete!(Svec[S[i]],i)
					s <= threshold && push!(Svec[s], i)
					S[i] = s
				end
			end
		end
	end
	reinsert_nodes
end
