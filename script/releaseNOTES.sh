# !/usr/bin/bash

user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"
token=$ENV_TOKEN
echo "user= $user , repo= $repo"
echo "cred = $ENV_TOKEN"
envGM=$1
envVer=$2
envMj=$3
envMn=$4
envPt=$5

if [[ ${#envMj} != 0 ]]
then  MjTitle="- #### Major Changes"
elif [[ ${#envMn} != 0 ]]
then MnTitle="- #### Minor Changes"
elif [[ ${#envPt} != 0 ]]
then PtTitle="- #### Patches"
fi


tag=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .tag_name)

prevtag=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))

echo "tag = $tag , prevtag = $prevtag , new = $envVer"

data="### $envGM \n $MjTitle \n $envMj $MnTitle \n $envMn $PtTitle \n $envPt"

prep_data()
{
  cat <<EOF
{
  "tag_name": "$envVer",
  "target_commitish":"main" , 
  "name": "v$envVer - $(date "+%F-%H-%M-%S")" ,
  "body": "$data" ,
  "draft":false,"prerelease":false,
  "generate_release_notes":false
}
EOF
}

echo "$(prep_data)"

curl \
-X POST \
-H "Authorization: token $token" \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases  \
-d "$(prep_data)"
