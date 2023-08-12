# 一様分布に基づく乱数の集団を生成する関数
function rand_population_uniform(m, a, b)
    # 配列aの次元数を取得
    d = length(a)
    # 各次元ごとに一様乱数を生成して、集団として返す
    return [a + rand(d).*(b-a) for i in 1:m]
end

# 必要なライブラリをインポート
import Pkg
Pkg.add("Distributions")
using Distributions

# 多変量正規分布に基づく乱数の集団を生成する関数
function rand_population_normal(m, µ, ∑)
    # 多変量正規分布の定義
    D = MvNormal(µ, ∑)
    # 多変量正規分布に基づく乱数を生成して、集団として返す
    return [rand(D) for i in 1:m]
end

# コーシー分布に基づく乱数の集団を生成する関数
function rand_population_cauchy(m, µ, σ)
    # 配列µの次元数を取得
    n = length(µ)
    # 各次元ごとにコーシー乱数を生成して、集団として返す
    return [[rand(Cauchy(μ[j], σ[j])) for j in 1:n] for i in 1:m]
end

import Pkg
Pkg.add("Plots")
using Plots

# 一様分布に基づく乱数を生成
population_uniform = rand_population_uniform(1000, [0, 0], [1, 1])
x = [pt[1] for pt in population_uniform]
y = [pt[2] for pt in population_uniform]
#scatter(x, y, title="Uniform Distribution")
plot = scatter(x, y, title="Uniform Distribution")
savefig(plot, "uniform_distribution.png")