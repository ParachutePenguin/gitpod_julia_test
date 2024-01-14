import requests
import pandas as pd

# アクセストークンの設定（セキュリティのため、トークンは直接コードに埋め込まないでください）
access_token = ''
csv_file_name = 'tensorflow_commits.csv'

# GitHubリポジトリのURL
repo_url = "https://api.github.com/repos/tensorflow/tensorflow/commits"

# コミットデータを格納するリスト
commits_data = []

# ページネーションでAPIからデータを取得する
page = 1
while True:
    headers = {'Authorization': f'token {access_token}'}
    response = requests.get(repo_url, headers=headers, params={'page': page, 'per_page': 100})
    if response.status_code != 200:
        break  # APIからのエラーレスポンスがあった場合、ループを抜ける
    data = response.json()
    if not data:
        break  # データがない場合、ループを抜ける

    # コミット情報をリストに追加
    for commit in data:
        commit_date = commit['commit']['committer']['date']
        committer = commit['commit']['committer']['name']
        commits_data.append({'date': commit_date, 'committer': committer})
    
    page += 1  # 次のページへ

# データをDataFrameに変換
df = pd.DataFrame(commits_data)

# CSVファイルとして保存
df.to_csv(csv_file_name, index=False)
print(f"データを {csv_file_name} に保存しました。")