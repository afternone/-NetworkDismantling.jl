using Test
using LightGraphs
using DataStructures

n = 100
threshold = 10
g = erdos_renyi(n, 4/n)

@testset "HDA" begin
    attack_nodes = HDA(g, threshold)
    present = fill(true, n)
    present[attack_nodes] .= false
    @test giant_component_size(g, present) <= threshold
end

@testset "CoreHD" begin
    attack_nodes = CoreHD(g, threshold)
    present = fill(true, n)
    present[attack_nodes] .= false
    @test giant_component_size(g, present) <= threshold
end

@testset "WeakNei" begin
    attack_nodes = WeakNei(g, threshold)
    present = fill(true, n)
    present[attack_nodes] .= false
    @test giant_component_size(g, present) <= threshold
end

@testset "tree_break" begin
    decycling_nodes = decore(g)
    present = fill(true, n)
    present[decycling_nodes] .= false
    tree_break!(present, g, threshold)
    @test giant_component_size(g, present) <= threshold
end
