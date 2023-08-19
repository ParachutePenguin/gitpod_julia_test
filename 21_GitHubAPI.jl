using Pkg
Pkg.add("HTTP")
Pkg.add("JSON")
Pkg.add("DataFrames")
Pkg.add("CSV")

using HTTP, JSON, DataFrames, CSV

function fetch_commits(owner, repo)
    url = "https://api.github.com/repos/$(owner)/$(repo)/commits"
    response = HTTP.get(url)
    return JSON.parse(String(response.body))
end

function commits_to_dataframe(commits)
    df = DataFrame(sha = String[], author = String[], date = String[], message = String[])

    for commit in commits
        sha = commit["sha"]
        author = commit["commit"]["author"]["name"]
        date = commit["commit"]["author"]["date"]
        message = commit["commit"]["message"]
        push!(df, (sha, author, date, message))
    end

    return df
end

owner = "tensorflow" # リポジトリのオーナー名
repo = "tensorflow" # リポジトリ名

commits = fetch_commits(owner, repo)
df = commits_to_dataframe(commits)
CSV.write("commits.csv", df)

println("コミット履歴をcommits.csvに保存しました！")
