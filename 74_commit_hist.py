import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# CSVファイルの読み込み
csv_file_name = 'tensorflow_commits.csv'
df = pd.read_csv(csv_file_name)

# コミッタごとのコミット数を集計
commit_counts = df['committer'].value_counts()

# ヒストグラムの描画
sns.histplot(commit_counts, bins=30, kde=False, log_scale=(True,True))
plt.xlabel('Number of Commits')
plt.ylabel('Number of Committers')
plt.title('Histogram of TensorFlow Commits by Committers')

# ヒストグラムをPNGファイルとして保存
output_filename = 'tensorflow_commits_histogram.png'
plt.savefig(output_filename)
plt.show()

print(f"ヒストグラムは '{output_filename}' として保存されました。")

# 上位10名のコミッタとそのコミット数を表示
top_committers = commit_counts.head(10)
print("コミット数の多い上位10名のコミッタ：")
print(top_committers)