using DataStructures
using Compat
using Compat.Test
using Compat.Random
using Compat.Serialization

import DataStructures: IntSet

@test isempty(detect_ambiguities(Base, Core, DataStructures))

using Primes

tests = ["int_set",
         "deque",
         "circ_deque",
         "sorted_containers",
         "stack_and_queue",
         "accumulator",
         "classified_collections",
         "disjoint_set",
         "binheap",
         "mutable_binheap",
         "default_dict",
         "ordered_dict",
         "ordered_set",
         "trie",
         "list",
         "multi_dict",
         "circular_buffer",
         "sorting",
         "priority_queue"
        ]

if length(ARGS) > 0
    tests = ARGS
end

@testset "DataStructures" begin

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end

end # @testset
