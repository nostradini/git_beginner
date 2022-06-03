# !/usr/bin/bash

user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"
echo "user= $user , repo= $repo"
echo "cred = $ENV_TOKEN"
envGM=$1
envVer=$2
envMj=$3
envMn=$4
envPt=$5

# echo "$(git log --after="2022-05-31T01:16:29Z" --format=oneline)"

tag=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .tag_name)

prevtag=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))

echo "tag = $tag , prevtag = $prevtag , new = $envVer"

data="# v$envVer  $(date "+%F-%H-%M-%S")"
echo "data initial= $data"
data="\n $data \n ## $envGM \n ### $envMj \n ### $envMn \n $envPt"

prep_data()
{
  cat <<EOF
{
  "tag_name": "$envVer",
  "target_commitish":"main" , 
  "name": "v$envVer" ,
  "body": "$data" ,
  "draft":false,"prerelease":false,
  "generate_release_notes":false
}
EOF
}

echo "$(prep_data)"

# curl \
# -X POST \
# -H "Authorization: token $token" \
# -H "Accept: application/vnd.github.v3+json" \
# https://api.github.com/repos/$user/$repo/releases  \
# -d "$(prep_data)"
