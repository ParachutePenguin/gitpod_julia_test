using Pkg

Pkg.add("Agents")
Pkg.add("Distributions")

using Agents
using Distributions

mutable struct OSS <: AbstractAgent
    id::Int
    lamb::Float64
    lamb_fil::Float64
    th::Float64
    th_fil::Float64
    failure::Int
end

mutable struct Dev <: AbstractAgent
    id::Int
    theta::Float64
end

lamb = 0.4
d_lamb = Bernoulli(lamb)

function initialize_model(;
    seed = 0,
    lamb = 0.7,
    lamb_fil = 0.5,
    th = 0.95,
    th_fil = 0.5,
    failure = 0,
    theta = 0.95
    )
end

function agent_step!(agent,model)

end

model = ABM(Union{OSS,Dev})
