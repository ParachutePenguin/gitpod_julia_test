Pkg.add("Agents")
Pkg.add("Random")
Pkg.add("Distributions")

using Agents
using Random
using Distributions
numagents = 100

mutable struct Haploid <: AbstractAgent
    id::Int
    trait::Float64
end

model = ABM(Haploid)

for i in 1:numagents
    add_agent!(model, rand(Uniform(0, numagents)))
end


sample!(model, nagents(model))

modelstep_neutral!(model::ABM) = sample!(model, nagents(model))

using Statistics: mean

data, _ = run!(model, dummystep, modelstep_neutral!, 20; adata = [(:trait, mean)])
data