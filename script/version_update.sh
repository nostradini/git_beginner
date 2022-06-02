#!/usr/bin/bash
Env_Token=$1
user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"

Repo_SHA=$(curl -H "Authorization: token $Env_Token" \
-X GET https://api.github.com/repos/$user/$repo/contents/VERSION | jq .sha)

echo "This is repo_sha = " $Repo_SHA

UpdatedVer=$(cat ./VERSION)
echo "Updated Version = " $UpdatedVer
content=$(echo $UpdatedVer | base64)
content=$(echo $content | tr -d ' ')
content=\"${content}\"
echo "Content is = " $content

curl -i -X PUT \
-H "Authorization: token $Env_Token" \
-H "Accept: application/vnd.github.v3+json" \
-d '{ "path":"VERSION","message":"[JOB] Push version","content":'$content',"branch":"main","sha":'$Repo_SHA' }' \
 https://api.github.com/repos/nostradini/myrepo3/contents/VERSION