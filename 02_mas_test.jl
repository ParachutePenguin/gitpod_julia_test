using Pkg

Pkg.add("Agents")

using Agents
using Random

mutable struct WealthAgent <: AbstractAgent
    id::Int
    wealth::Int
end

function wealth_model(; numagents = 100, initwealth = 1, seed = 5)
    model = ABM(WealthAgent; scheduler = Agents.Schedulers.randomly(), rng = Random.Xoshiro(seed))
    for _ in 1:numagents
        add_agent!(model, initwealth)
    end
    return model
end

model = wealth_model()

function agent_step!(agent, model)
    agent.wealth == 0 && return # do nothing
    ragent = random_agent(model)
    agent.wealth -= 1
    ragent.wealth += 1
end

N = 5
M = 2000
adata = [:wealth]
model = wealth_model(numagents = M)
data, _ = run!(model, agent_step!, N; adata)
data[(end-20):end, :]
