import Pkg
Pkg.add("ExprRules")
Pkg.add("TreeView")
Pkg.add("Distributions")
Pkg.add("Random")
Pkg.add("StatsBase")

include("support_code.jl")
include("Particle_filter.jl") # 粒子フィルタコードを含める

using ExprRules
using TreeView
using Distributions
using Random
using StatsBase

# 選択、交叉、突然変異のための抽象型定義
abstract type SelectionMethod end
abstract type CrossoverMethod end
abstract type MutationMethod end

# トランケーション選択
struct TruncationSelection <: SelectionMethod
    k::Int
end

# ルーレットホイール選択
struct RouletteWheelSelection <: SelectionMethod end

# 木構造の交叉
struct TreeCrossover <: CrossoverMethod
    grammar::Grammar
    max_depth::Int
end

# 木構造の突然変異
struct TreeMutation <: MutationMethod
    grammar::Grammar
    p::Float64
end


# ポアソン分布に従う乱数で観測データを作成
n_observations = 100
#true_state = rand(Normal(0, 1), n_observations)
#observations = [rand(Poisson(exp(x))) for x in true_state]
observations = [2,2,2,3,1]

# 観測関数の修正
observation(x, y) = pdf(Poisson(exp(x)), y)

g = let
    grammar = @grammar begin
        P1 = rand(Uniform(0, 10))
        P2 = rand(Uniform(-10, 10))
        P = rand(Gamma(P1,P1))
        P2 = rand(Normal(P2,P1))
        P = P1
        P = P2
    end

    function select(T::TruncationSelection, y)
        p = sortperm(y)
        return [p[rand(1:T.k, 2)] for i in y]
    end

    function select(::RouletteWheelSelection, y)
        y = maximum(y) - y
        cat = Categorical(normalize(y, 1))
        return [rand(cat, 2) for i in y]
    end

    function crossover(C::TreeCrossover, a, b)
        child = deepcopy(a)
        crosspoint = sample(b)
        typ = return_type(C.grammar, crosspoint.ind)
        d_subtree = depth(crosspoint)
        d_max = C.max_depth + 1 - d_subtree
        if d_max > 0 && contains_returntype(child, C.grammar, typ, d_max)
            loc = sample(NodeLoc, child, typ, C.grammar, d_max)
            insert!(child, loc, deepcopy(crosspoint))
        end
        child
    end

    function mutate(M::TreeMutation, a)
        child = deepcopy(a)
        if rand() < M.p
            loc = sample(NodeLoc, child)
            typ = return_type(M.grammar, get(child, loc).ind)
            subtree = rand(RuleNode, M.grammar, typ)
            child = insert!(child, loc, subtree)
        end
        return child
    end

    function Nmutate(M::TreeMutation, a)
        child = deepcopy(a)
        if rand() < M.p
            loc = sample(NodeLoc, child)
            typ = return_type(M.grammar, get(child, loc).ind)
            subtree = rand(RuleNode, M.grammar, typ)
            
            if is_valid_node(subtree, M.grammar)
                child = insert!(child, loc, subtree)
            end
        end
        return child
    end
    

    f = (node) -> begin
        transition_function = (x) -> Core.eval(node, grammar)
        n_particles = 100
        #initial_distribution = Normal(0, 1)
        initial_distribution = Uniform(-10, 10)
        estimates, marginal_log_likelihoods = particle_filter(n_particles, initial_distribution, transition_function, observation, observations)
        #log_likelihood = sum(log.(estimates))
        return -marginal_log_likelihoods # 最大尤度を求めたいので符号を反転
    end

    function genetic_algorithm(f, population, k_max, S, C, M)
        for k in 1 : k_max
            parents = select(S, f.(population))
            children = [crossover(C,population[p[1]],population[p[2]]) for p in parents]
            population = [mutate(M, c) for c in children]
        end
        population[argmin(f.(population))]
    end

    Random.seed!(1)
    m = 1000
    population = [rand(RuleNode, grammar, :P) for i in 1:m]
    k_max = 10
    #

    # 粒子フィルタでの観測データの使用
    #estimates = particle_filter(n_particles, initial_distribution, transition_function, observations, observation)

    # 上記の例を使って遺伝的アルゴリズムを実行
    best_tree = genetic_algorithm(f, population, k_max, 
            TruncationSelection(50), 
            TreeCrossover(grammar, 10), 
            TreeMutation(grammar, 0.25))

    # 結果の表示
    expr = get_executable(best_tree, grammar)
    tree = walk_tree(expr)
    @show best_tree

    #
end
global cur_plot = g