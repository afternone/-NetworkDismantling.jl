function ncsize!(S, present, g, i, j)
	!present[i] && return 0
	S[i] != 0 && error("the graph is not acyclic")
	S[i] = 1
	for k in neighbors(g,i)
		if k != j && present[k]
			S[i] += ncsize!(S, present, g, k, i)
		end
	end
	return S[i]
end

"""
Optimally break tree until the giant component size is less than threshold.
"""
function tree_break!(present, g, threshold)
    S = zeros(Int, nv(g))
    H = MutableBinaryMaxHeap{Tuple{Int64,Int64}}()
    for i in vertices(g)
        if present[i] && S[i] == 0
            push!(H, (ncsize!(S, present, g, i, nothing), i))
        end
    end

    attack_nodes = Int[]
    scomps = Int[]
    while !isempty(H)
        scomp, i = pop!(H)
        sender = nothing
        while true
            sizes = [(S[k],k) for k in neighbors(g,i) if k != sender && present[k]]
            isempty(sizes) && break
            M, largest = maximum(sizes)
            if M <= scomp/2
                for k in neighbors(g,i)
                    if S[k] > 1 && present[k]
                        push!(H, (S[k],k))
                    end
                end
                present[i] = false
                push!(attack_nodes, i)
                push!(scomps, scomp)
                break
            end
            S[i] = 1
            for k in neighbors(g,i)
                if k != largest && present[k]
                    S[i] += S[k]
                end
            end
            sender, i = i, largest
        end
		scomp <= threshold && break
    end
    return attack_nodes, scomps
end
