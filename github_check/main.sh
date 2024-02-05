#!/bin/bash
#用于检测github仓库是否有更新

alarm_url="https://api.day.app/dkeidkwieslxiciweisdpwe/"
# 这个函数用来发送通知
function sendNotification {
  local t=$1
  local rep_name=${t#*/}
  local version=$2
  curl -s "${alarm_url}${rep_name}/${rep_name}有新版本${version}"
}

# 这个函数用来获取最新的 GitHub release 版本
function getLatestRelease {
  local repo_name=$1
  local response=$(curl -s --write-out "%{http_code}" --silent --output /dev/null "https://api.github.com/repos/$repo_name/releases/latest")
  if [ "$response" -ne 200 ]; then
    echo "$(date) 获取 ${repo_name} 最新版本失败。错误代码：$response"
    curl -s "${alarm_url}${rep_name}/最新版本失败。错误代码：$response"
    return 1
  else
    curl --silent "https://api.github.com/repos/$repo_name/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
  fi
}

# 读取repos.txt文件
while IFS= read -r line || [ -n "$line" ]; do
  # 分离仓库名和版本
  repo_name=$(echo $line | cut -d ' ' -f 1)
  current_version=$(echo $line | cut -d ' ' -f 2)

  echo "$(date) 检查 ${repo_name} ..."

  # 获取最新的 release 版本
  latest_release=$(getLatestRelease $repo_name)

  # 当前版本和最新 release 版本进行比较
  if [ "$current_version" != "$latest_release" ]; then
    echo "$(date) ${repo_name} 的版本更新了。"
    # 发送通知
    sendNotification $repo_name $latest_release
    # 更新 repos.txt 的版本号为最新
    sed -i "s#$repo_name $current_version#$repo_name $latest_release#" repos.txt
  else
    echo "$(date) ${repo_name} 没有版本更新。"
  fi
done < repos.txt





