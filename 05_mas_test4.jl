import Pkg
Pkg.add("Distributions")
Pkg.add("Plots")
Pkg.add("Agents")
Pkg.add("Random")

using Agents, Distributions, Plots, Random


# エージェントの定義
mutable struct OSSAgent <: AbstractAgent
    id::Int
    failure_rate::Float64
    resolved_failures::Int64
end

# 開発者エージェント用の構造体
mutable struct DeveloperAgent <: AbstractAgent
    id::Int
    resolved_failures::Int64
end

# シミュレーションモデルの作成
function oss_model(;failure_rate=0.1, seed=0)
    model = ABM(OSSAgent; scheduler = Schedulers.randomly, rng = Random.Xoshiro(seed)) # 空間をnothingとして定義
    add_agent!(OSSAgent(1, failure_rate, 0), model) # 位置を指定せずにエージェントを追加
    add_agent!(DeveloperAgent(2, 0), model) # 位置を指定せずにエージェントを追加
    return model
end

# シミュレーションステップ
function agent_step!(agent::OSSAgent, model)
    failures = rand(Poisson(agent.failure_rate))
    developer = model[2::DeveloperAgent]
    developer.resolved_failures = failures
    agent.resolved_failures += failures
    model.cumulative_resolved += failures
end

function agent_step!(agent::DeveloperAgent, model)
    # 開発者エージェントはOSSエージェントから指示を受けるだけなので、ここでの動作はありません。
end

# シミュレーションの実行
model = oss_model()
stepdata = run!(model, agent_step!, 1000; adata=[(:failure_rate, mean), (:resolved_failures, mean)])
cumulative_resolved = [sum(stepdata.resolved_failures[1:i]) for i in 1:length(stepdata.resolved_failures)]

# グラフの作成
p = plot(stepdata.failure_rate, label="Failures per step", title="OSS Development Simulation", xlabel="Time Step", ylabel="Failures & Resolved per step", legend=:top)
plot!(stepdata.resolved_failures, label="Resolved per step")
p2 = twinx()
plot!(p2, cumulative_resolved, label="Cumulative resolved", color=:green, ylabel="Cumulative resolved", legend=:topright)

display(p)