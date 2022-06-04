# !/usr/bin/bash

token=$ENV_TOKEN
envGM=$1
envVer=$2
envMj=$3
envMn=$4
envPt=$5
user=$6
repo=$7
echo "user= $user , repo= $repo"
echo "cred = $ENV_TOKEN"

if [[ ${#envMj} != 0 ]]
then  MjTitle="\n - #### Major Changes  "
fi
if [[ ${#envMn} != 0 ]]
then MnTitle="\n - #### Minor Changes  "
fi
if [[ ${#envPt} != 0 ]]
then PtTitle="\n - #### Patches  "
fi


tag=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .tag_name)

prevtag=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))

echo "prevtag = $prevtag , tag = $tag , new = $envVer"

data="### $envGM $MjTitle $envMj $MnTitle $envMn $PtTitle $envPt"

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
