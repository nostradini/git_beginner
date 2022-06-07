#!/usr/bin/bash
Env_Token=$1
user=$2
repo=$3
cl=$4
envGM=$5
envVer=$6
envMj=$7
envMn=$8
envPt=$9

echo "cl=$4"
echo "envGM=$5"
echo "envVer=$6"
echo "envMj=$7"
echo "envMn=$8"
echo "envPt=$9"

if [[ $cl == 0 ]]
then
  path="VERSION"
  UpdatedVer=$(cat ./$path)
elif [[ $cl == 1 ]]
then
  path="CHANGELOG.md"

  if [[ ${#envMj} != 0 ]]
  then 
  MjTitle=" - #### Major Changes  "
  $envMj=$(echo '$envMj' | sed 's/#major//g')
  fi
  if [[ ${#envMn} != 0 ]]
  then
  MnTitle="\n - #### Minor Changes  "
  $envMn=$(echo '$envMn' | sed 's/#minor//g')
  fi
  if [[ ${#envPt} != 0 ]]
  then
  PtTitle="<br /> <h2>Patches</h2/>  "
  $envPt="$(echo '$envPt' | sed 's/#patch//g')"
  fi

  UpdatedVer="# CHNAGELOG <br /> ### $envGM $MjTitle $envMj $MnTitle $envMn $PtTitle $envPt"

fi

echo $path

Repo_SHA=$(curl -H "Authorization: token $Env_Token" \
-X GET https://api.github.com/repos/$user/$repo/contents/$path | jq .sha)

echo "This is repo_sha = " $Repo_SHA

echo "Updated Version = " $UpdatedVer
content=$(echo $UpdatedVer | base64)
content=$(echo $content | tr -d ' ')
content=\"${content}\"
echo "Content is = " $content

prep_data()
{
  cat <<EOF
{
  "path": "$path",
  "message":"[JOB] Push $path update",
  "branch":"main",
  "sha": $Repo_SHA,
  "content": $content
  }
EOF
}
echo "prep data= $(prep_data)"

curl -i -X PUT \
-H "Authorization: token $Env_Token" \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/contents/$path \
-d "$(prep_data)"
 