# 一様分布に基づく乱数の集団を生成する関数
function rand_population_uniform(m, a, b)
    d = length(a)
    return [a + rand(d).*(b-a) for i in 1:m]
end

import Pkg
Pkg.add("Distributions")
using Distributions

# 多変量正規分布に基づく乱数の集団を生成する関数
function rand_population_normal(m, µ, ∑)
    D = MvNormal(µ, ∑)
    return [rand(D) for i in 1:m]
end

# コーシー分布に基づく乱数の集団を生成する関数
function rand_population_cauchy(m, µ, σ)
    n = length(µ)
    return [[rand(Cauchy(μ[j], σ[j])) for j in 1:n] for i in 1:m]
end

import Pkg
Pkg.add("Plots")
using Plots

function generate_scatter_plot(rand_func, m, params...)
    # 乱数を生成
    population = rand_func(m, params...)
    x = [pt[1] for pt in population]
    y = [pt[2] for pt in population]

    # 分布の名前を取得
    distribution_name = split(string(rand_func), "_")[3]
    title = "$(uppercasefirst(distribution_name)) Distribution"
    filename = "_$(distribution_name)_distribution.png"

    # 散布図を作成
    plot = scatter(x, y, title=title)
    savefig(plot, filename)
end

# 各分布に基づいた散布図を作成
#generate_scatter_plot(rand_population_uniform, 1000, [0, 0], [1, 1])
#generate_scatter_plot(rand_population_normal, 1000, [0, 0], [1, 1])
#generate_scatter_plot(rand_population_cauchy, 1000, [0, 0], [1, 1])

function genetic_algorithm(f, population, k_max, S, C, M)
    for k in 1:k_max
        parents = select(S, f.(population))
        children = [crossover(C, population[p[1]], population[p[2]])
                    for p in parents]
        population .= mutate.(Ref(M), children)
    end
    population[argmin(f.(population))]
end

rand_population_binary(m, n) = [bitrand(n) for i in 1:m]

abstract type SelectionMethod end

# 上位k個の中から親となるペアをランダムで選ぶ
struct TruncationSelection <: SelectionMethod
    # 上位k個を残す
    k
end
function select(t::TruncationSelection, y)
    p = sortperm(y)
    return [p[rand(1:t.k, 2)] for i in y]
end

# ランダムな部分集合から最も優れた親を選ぶ
struct TournamentSelection <: SelectionMethod
    k
end
function select(t::TournamentSelection, y)
    getparent() = begin
        p = randperm(length(y))
        p[
            argmin(
                y[p[1:t.k]]
            )
        ]
    end
    return [[getparent(), getparent()] for i in y]
end

# 適応度に比例した確率で親をサンプリングする
struct RouletteWheelSelection <: SelectionMethod end
function select(::RouletteWheelSelection, y)
    y = maximum(y) .- y
    cat = Categorical(normalize(y, 1))
    return [rand(cat, 2) for i in y]
end