Pkg.add("Agents")
Pkg.add("Distributions")

using Agents
using Distributions

mutable struct OSS <: AbstractAgent
    id::Int
    lamb::Float64
    failure::Bool
end
