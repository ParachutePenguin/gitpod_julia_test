import Pkg;
Pkg.add("Distributions")
Pkg.add("Plots")
Pkg.add("Random")
using Distributions, Plots, Random

Random.seed!(0)

# OSSエージェント用の構造体を定義します。フィールドは故障率と累積修復故障数です。
mutable struct NewMutableOSSAgent
    failure_rate::Float64
    resolved_failures::Int64
end

# 開発者エージェント用の構造体を定義します。フィールドは修復した故障数です。
mutable struct NewDeveloperAgent
    resolved_failures::Int64
end

# シミュレーションの各ステップを進行させる関数です。
function step!(oss::NewMutableOSSAgent, dev::NewDeveloperAgent)
    # OSSエージェントがポアソン分布に従って故障を生成します。
    failures = rand(Poisson(oss.failure_rate))

    # 開発者エージェントが次のタイムステップで故障を修復します。
    fix_failures!(oss, dev, failures)

    return failures
end

# 開発者エージェントが故障を修復する関数です。
function fix_failures!(oss::NewMutableOSSAgent, dev::NewDeveloperAgent, failures::Int64)
    # OSSエージェントと開発者エージェントの修復数を更新します。
    oss.resolved_failures += failures
    dev.resolved_failures = failures
end

# シミュレーションを実行する関数です。
function run_simulation(oss::NewMutableOSSAgent, dev::NewDeveloperAgent, steps::Int64)
    history_failures = []
    history_resolved = []

    for t in 1:steps
        failures = step!(oss, dev)
        push!(history_failures, failures)
        push!(history_resolved, dev.resolved_failures)
    end

    return history_failures, history_resolved
end

# 故障率0.1のOSSエージェントと開発者エージェントを作成します。
oss = NewMutableOSSAgent(0.1, 0)
dev = NewDeveloperAgent(0)

# 1000ステップのシミュレーションを実行します。
history_failures, history_resolved_per_step = run_simulation(oss, dev, 1000)

# 修復された故障数の累積履歴を作成します。
history_resolved_cumulative = cumsum(history_resolved_per_step)

# 二つのy軸を持つグラフを作成します。
#=
p = plot(history_failures, label="Failures per step", title="OSS Development Simulation", xlabel="Time Step", ylabel="Failures & Resolved per step", legend=:top)
plot!(history_resolved_per_step, label="Resolved per step")
p2 = twinx()
plot!(p2, history_resolved_cumulative, label="Cumulative resolved", color=:green, ylabel="Cumulative resolved", legend=:topright)
=#


p = plot(history_failures, label="Failures per step", title="OSS Development Simulation", xlabel="Time Step", ylabel="Failures & Resolved per step", legend=:topright)
p2 = twinx()
plot!(p, history_resolved_per_step, label="Resolved per step", legend=(0.75,0.2))
plot!(p2, history_resolved_cumulative, label="Cumulative resolved", color=:green, ylabel="Cumulative resolved", legend=:bottomright)

# PNGファイルとして保存
save_path = "_04_plot.png"
savefig(p, save_path)

# ターミナルでリンクを表示
println("Plot saved to: ", save_path)
