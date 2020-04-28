function giant_component_size(g, present)
    n = nv(g)
    Q = Queue{Int}()
	label = zeros(Int,n)
	cnt = zeros(Int,n)
	maxcnt = 0
    @inbounds for u in vertices(g)
		if present[u]
	        label[u] != 0 && continue
	        label[u] = u
			cnt[u] += 1
	        enqueue!(Q, u)
	        while !isempty(Q)
	            src = dequeue!(Q)
	            for vertex in all_neighbors(g, src)
					if present[vertex]
		                if label[vertex] == 0
		                    enqueue!(Q, vertex)
		                    label[vertex] = u
							cnt[u] += 1
		                end
					end
	            end
	        end
			if cnt[u] > maxcnt
				maxcnt = cnt[u]
			end
		end
    end
    return maxcnt
end

function recover_add_nodes(g, attack_nodes)
	n = nv(g)
	max_comp_sizes = Int[]
	ds = IntDisjointSets(n)
	present = fill(true, n)
	present[attack_nodes] .= false
	comp_sizes = ones(Int, n)
	max_comp_size = 1

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

	for i in reverse(attack_nodes)
		for j in neighbors(g, i)
			if present[j]
				newroot = merge_nodes!(ds, comp_sizes, i, j)
				if comp_sizes[newroot] > max_comp_size
					max_comp_size = comp_sizes[newroot]
				end
			end
		end
		present[i] = true
		push!(max_comp_sizes, max_comp_size)
	end
	reverse(max_comp_sizes)
end
