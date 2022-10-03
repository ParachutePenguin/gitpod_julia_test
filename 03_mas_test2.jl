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
