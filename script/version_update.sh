#!/usr/bin/bash
Env_Token=$1
user=$2
repo=$3

Repo_SHA=$(curl -H "Authorization: token $Env_Token" \
-X GET https://api.github.com/repos/$user/$repo/contents/VERSION | jq .sha)

echo "This is repo_sha = " $Repo_SHA
UpdatedVer=$(cat ./VERSION)
echo "Updated Version = " $UpdatedVer
content=$(echo $UpdatedVer | base64)
content=$(echo $content | tr -d ' ')
content=\"${content}\"
echo "Content is = " $content

prep_data()
{
  cat <<EOF
{
  "path":"VERSION",
  "message":"[JOB] Push version",
  "branch":"main",
  "sha": $Repo_SHA,
  "content": $content
  }
EOF
}

# echo "prep data= $(prep_data)"

curl -i -X PUT \
-H "Authorization: token $Env_Token" \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/contents/VERSION \
-d "$(prep_data)"
 