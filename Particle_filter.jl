import Pkg;
Pkg.add("Distributions")
Pkg.add("StatsBase")

using Distributions, StatsBase

# 粒子フィルタ関数
function particle_filter(n_particles::Int, initial_distribution, transition_function, observation_function, observations)
    # 粒子の初期化
    particles = rand(initial_distribution, n_particles)
    weights = fill(1/n_particles, n_particles)
    
    # 結果の保存
    estimates = []

    # 各観測値に対してフィルタリングを実行
    for observation in observations
        # 予測ステップ
        particles = transition_function.(particles)

        # 更新ステップ
        weights = observation_function.(particles, observation)
        weights ./= sum(weights)

        # リサンプリングステップ
        resample_indices = sample(1:n_particles, Weights(weights), n_particles)
        particles = particles[resample_indices]
        
        # 状態の推定
        estimate = sum(particles .* weights)
        push!(estimates, estimate)
    end

    return estimates
end
#=
# 使い方の例:
# 状態遷移関数と観測関数を定義
transition(x) = 0.5 * x + randn()
#observation(x, y) = pdf(Normal(x, 1), y)
observations(x,y) = pdf(Poisson(x), y)

# 観測データ (ダミー)
observations = [2.3, 1.9, 2.8, 2.5]

# 粒子フィルタの実行
n_particles = 100
initial_distribution = Normal(0, 1)
estimates = particle_filter(n_particles, initial_distribution, transition, observation, observations)

println("Estimates: ", estimates)
=#