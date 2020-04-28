module NetworkDismantle

using LightGraphs
using DataStructures

export
HDA,
CoreHD,
WeakNei,
high_degree_adaptive,
decore,
weak_neighbor_decore,
tree_break!,
reverse_greedy!,
giant_component_size,
recover_add_nodes

include("dismantle.jl")
include("high_degree_adaptive.jl")
include("decore.jl")
include("weak_neighbor_decore.jl")
include("tree_break.jl")
include("reverse_greedy.jl")
include("utils.jl")

end # module
