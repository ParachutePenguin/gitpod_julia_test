using GitHub
using Dates
using CSV

token = ""
GitHub.authenticate(token)
const AUTH = GitHub.OAuth2(token)

function fetch_issue_data(repo_name)
    # リポジトリのデータを取得
    #repo = repository(repo_name)
    repo = GitHub.repos(repo_name;auth = AUTH)
    repo_created_at = Date(repo.created_at)

    # Issueのデータを取得
    issues = issues(repo_name;auth=AUTH)
    issue_data = []

    for (i, issue) in enumerate(issues)
        issue_number = issue.number
        issue_created_at = Date(issue.created_at)
        days_since_repo_creation = Dates.value(issue_created_at - repo_created_at)
        
        push!(issue_data, (i, issue_number, issue_created_at, days_since_repo_creation))
    end

    # CSVファイルに保存
    CSV.write("issue_data.csv", DataFrame(issue_data, ["通し番号", "識別番号", "立った日", "リポジトリ立ち上げからの日数"]))
end

#fetch_issue_data("owner/repo_name")
fetch_issue_data("tensorflow/tensorflow")
