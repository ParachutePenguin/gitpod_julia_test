import Pkg;
Pkg.add("Distributions")
Pkg.add("Plots")
Pkg.add("Random")
using Distributions, Plots, Random

Random.seed!(0)

# OSSエージェント用の構造体を定義します。フィールドは故障率と累積修復故障数です。
mutable struct OSSAgent
    failure_rate::Float64
    resolved_failures::Int64
    merge_records::Vector{Tuple{Int64, Int64}}
end

# 開発者エージェント用の構造体を定義します。フィールドは見つけた故障と修復した故障数です。
mutable struct DeveloperAgent
    found_failures::Int64
    fixed_failures::Int64
end

# コミュニティエージェント用の構造体を定義します。フィールドはマージしたバグ数です。
mutable struct CommunityAgent
    merged_bugs::Int64
    resolved_merged_failures::Int64
end

# シミュレーションの各ステップを進行させる関数です。
function step!(oss::OSSAgent, dev::DeveloperAgent, community::CommunityAgent)
    # OSSエージェントがポアソン分布に従って故障を生成します。
    failures = rand(Poisson(oss.failure_rate))

    # 開発者エージェントが故障を見つけます
    find_failures!(dev, failures)

    # 開発者エージェントが次のタイムステップで故障を修復します。
    fix_failures!(dev)

    # コミュニティエージェントが修復済みバグをマージします
    merge_failures!(dev, community)

    return failures
end

# 開発者エージェントがバグを見つける関数です
function find_failures!(dev::DeveloperAgent, failures::Int64)
    dev.found_failures = failures
end

# 開発者エージェントが故障を修復する関数です。
function fix_failures!(dev::DeveloperAgent)
    # OSSエージェントと開発者エージェントの修復数を更新します。
    dev.fixed_failures = dev.found_failures
end

# コミュニティが受け取ったバグをマージする関数です。
function merge_failures!(dev::DeveloperAgent, community::CommunityAgent)
    # バグを受け取ってマージする
    community.merged_bugs = dev.fixed_failures
    # マージ数累計
    community.resolved_merged_failures += dev.fixed_failures
end

# シミュレーションを実行する関数です。
function run_simulation(oss::OSSAgent, dev::DeveloperAgent, community::CommunityAgent, steps::Int64)
    history_failures = []
    history_resolved = []

    for t in 1:steps
        failures = step!(oss, dev, community)
        push!(history_failures, failures)
        push!(history_resolved, community.resolved_merged_failures)
    end

    return history_failures, history_resolved
end

# 故障率0.1のOSSエージェントと開発者エージェントを作成します。
oss = OSSAgent(0.1, 0, [(0,0)])
dev = DeveloperAgent(0, 0)
community = CommunityAgent(0,0)

# 1000ステップのシミュレーションを実行します。
history_failures, history_resolved_per_step = run_simulation(oss, dev, community, 1000)

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
