import pandas as pd
import stan
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import os

# ファイルパスの設定
input_file = 'tensorflow_commits.csv'
output_dir = '004_output_zipf'

# CSVファイルの読み込み
df = pd.read_csv(input_file)
df['date'] = pd.to_datetime(df['date']).dt.date

# 集計単位の選択
unit = input("集計単位を選択してください（d: 日, w: 週, m: 月, q: 四半期, y: 年, a: 全データ）: ")

# 集計処理
if unit == 'd':
    df_grouped = df.groupby(['date', 'committer']).size().reset_index(name='counts')
elif unit == 'w':
    df['week'] = df['date'].apply(lambda x: x.isocalendar()[1])
    df_grouped = df.groupby(['week', 'committer']).size().reset_index(name='counts')
elif unit == 'm':
    df_grouped = df.groupby([df['date'].dt.to_period('M'), 'committer']).size().reset_index(name='counts')
elif unit == 'q':
    df_grouped = df.groupby([df['date'].dt.to_period('Q'), 'committer']).size().reset_index(name='counts')
elif unit == 'y':
    df_grouped = df.groupby([df['date'].dt.to_period('Y'), 'committer']).size().reset_index(name='counts')
elif unit == 'a':
    df_grouped = df.groupby(['committer']).size().reset_index(name='counts')

# コミット数のユーザー別集計とソート
df_sorted = df_grouped.groupby('committer')['counts'].sum().reset_index().sort_values('counts', ascending=False)

# データの最大binの値を設定
max_k_value = len(df_sorted['committer'].unique())  # これが横軸の数、すなわちbinの数です

# Stanのモデル定義
zipf_code = """
functions {
    // リーマンのゼータ関数の近似（データの最大値までの和）
    real zeta_approx(real alpha, int max_k) {
        real sum = 0.0;
        for (n in 1:max_k) {
            sum += 1.0 / pow(n, alpha);
        }
        return sum;
    }

    // Zipf分布の確率質量関数
    real zipf_lpmf(int k, real alpha, int max_k) {
        return -alpha * log(k) - log(zeta_approx(alpha, max_k));
    }
}

data {
    int<lower=1> N;          // データポイントの数
    array[N] int<lower=1> dat;  // データ
    int<lower=1> max_k;      // データの最大値
}

parameters {
    real<lower=0, upper=10> alpha; // 1から10の一様事前分布の範囲でalphaを定義
}

model {
    alpha ~ uniform(0, 10); // 事前分布として一様分布を設定
    for (i in 1:N)
        dat[i] ~ zipf(alpha, max_k);
}
"""

# データの準備
stan_data = {'N': len(df_sorted), 'dat': df_sorted['counts'].values, 'max_k': max_k_value}

# モデルのビルドとサンプリング
posterior = stan.build(zipf_code, data=stan_data, random_seed=1)
fit = posterior.sample(num_chains=2, num_warmup=200, num_samples=300)

# 結果の保存
if not os.path.exists(output_dir):
    os.makedirs(output_dir)
#fit.plot()
    
import pandas as pd
import matplotlib.pyplot as plt

# StanのFitオブジェクトからDataFrameを作成
df = fit.to_frame()

# DataFrameからパラメータのプロットを作成
plt.figure(figsize=(10, 4))
df['alpha'].plot(kind='hist', bins=50)
plt.title('Alpha Parameter Distribution')
plt.xlabel('Alpha')
plt.ylabel('Frequency')
plt.show()


plt.savefig(os.path.join(output_dir, 'zipf_distribution.png'))

# アンダーソンダーリング統計量の計算
def calculate_anderson_darling(data, distribution):
    N = len(data)
    sorted_data = np.sort(data)
    cdf_values = np.array([distribution.cdf(x) for x in sorted_data])
    ad_statistic = -N - np.mean((2 * np.arange(1, N + 1) - 1) * np.log(cdf_values) + np.log(1 - cdf_values[::-1]))
    return ad_statistic

# サンプルデータからアンダーソンダーリング統計量を計算
ad_statistic = calculate_anderson_darling(df_sorted['counts'].values, stats.zipf(a=fit['alpha'].mean()))

# アンダーソンダーリング統計量の分布をプロット
plt.hist(ad_statistic, bins=30)
plt.title('Anderson-Darling Statistic Distribution')
plt.xlabel('AD Statistic')
plt.ylabel('Frequency')
plt.savefig(os.path.join(output_dir, 'anderson_darling_distribution.png'))

# 事前分布の定義（一様分布を使用）
alpha_prior = np.random.uniform(low=1, high=10, size=1000)  # 事前分布の範囲とサンプル数

# 事前分布に基づいたアンダーソンダーリング統計量の計算
ad_stats_prior = [calculate_anderson_darling(df_sorted['counts'].values, stats.zipf(a=alpha)) for alpha in alpha_prior]

# 事前分布のアンダーソンダーリング統計量の分布をプロット
plt.hist(ad_stats_prior, bins=30, alpha=0.7, label='Prior Distribution')
plt.title('Anderson-Darling Statistic Distribution - Prior')
plt.xlabel('AD Statistic')
plt.ylabel('Frequency')
plt.legend()
plt.savefig(os.path.join(output_dir, 'anderson_darling_distribution_prior.png'))
