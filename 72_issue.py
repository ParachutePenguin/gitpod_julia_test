from github import Github
import csv
from datetime import datetime

token = ""
g = Github(token)
repo = g.get_repo("tensorflow/tensorflow")

# リポジトリが作成された日
repo_created_at = repo.created_at

# CSVファイルの作成
with open('issue_data.csv', 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ['通し番号', '識別番号', '作成日', '経過日数']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()

    counter = 1

    # "bug" ラベルがついているIssueを取得
    issues = repo.get_issues(state='all', labels=['bug'])
    for issue in issues:
        issue_created_at = issue.created_at
        days_since_repo_created = (issue_created_at - repo_created_at).days
        
        writer.writerow({'通し番号': counter, '識別番号': issue.number, '作成日': issue_created_at, '経過日数': days_since_repo_created})

        counter += 1
