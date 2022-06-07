# !/usr/bin/bash
ver_major=0
ver_minor=0
ver_patch=0
user="nostradini"
trLC=$5
repo="git_beginner"
bMajor=false
bMinor=false
bPatch=false
bDefault=false
Env_Token=$ENV_TOKEN

echo "User= $user , REPO= $repo"

targetD=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .created_at)

# targetD="2022-06-01T01:00:00Z"
echo "Date = $targetD"

while IFS= read -r line; do
lowerstr=$(echo ${line:41:50}|tr '[:upper:]' '[:lower:]')
# echo "transformed to lower = $lowerstr"
if [[ "${lowerstr}" != "[job]"* ]]
then
    if [[ "${lowerstr}" == *"#major"* ]]
    then
    # echo "Found major in commit"
    bMajor=true
    colMajor="$colMajor<li> ${line:0:7} - ${line:41:50}</li><br>"
    elif [[ "${lowerstr}" == *"#minor"* ]]
    then
    # echo "Found minor in commit"
    bMinor=true
    colMinor="$colMinor<li> ${line:0:7} - ${line:41:50}</li><br>"
    elif [[ "${lowerstr}" == *"#patch"* ]]
    then
    # echo "Found patch in commit"
    bPatch=true
    colPatch="$colPatch<li> ${line:0:7} - ${line:41:50}</li><br>"
    else
    # echo "Default condition"
    bDefault=true
    colDefault="$colDefault<li> ${line:0:7} - ${line:41:50}</li><br>"
    fi
fi
done < <( git log --after="$targetD" --format=oneline )

if [[ $bMajor == true ]]
then
    gitmojiko=":boom: Breaking Changes"
    ver_major=$((ver_major+1))
    ver_minor=0
    ver_patch=0
elif [[ $bMinor == true ]]
then
    gitmojiko=":sparkles: New Features"
    ver_minor=$((ver_minor+1))
    ver_patch=0
elif [[ $bPatch == true ]]
then
    gitmojiko=":bug: Bug Fixes"
    ver_patch=$((ver_patch+1))
else
    gitmojiko="UNRELEASED"
fi
echo "gitmojiko= $gitmojiko"
echo "colMajor= $colMajor"
echo "colMinor= $colMinor"
echo "colPatch= $colPatch"

newVER="v$ver_major.$ver_minor.$ver_patch"
echo "newVer= $newVER"

if [[ ${#colMajor} != 0 ]]
then 
    MjTitle="<br><h4>Major Changes</h4><br><ul>"
    colMajor="<h6>$colMajor</h6></ul>"
# $envMj=$(echo '$envMj' | sed 's/#major//g')
fi
if [[ ${#colMinor} != 0 ]]
then
    if [[ ${#colMajor} != 0  ]]
    then
    MnTitle="<h4>Minor Changes</h4><br><ul>"
    else
    MnTitle="<br><h4>Minor Changes</h4><br><ul>"
    fi
    colMinor="<h5>$colMinor</h5></ul>"
fi
if [[ ${#colPatch} != 0 ]]
then
    if [[ ${#colMinor} != 0 ]]
    then
    PtTitle="<h4>Patches</h4><br><ul>"
    else
    PtTitle="<br><h4>Patches</h4><br><ul>"
    fi
    colPatch="<h5>$colPatch</h5></ul>"
fi

echo "MjTitle=$MjTitle,MnTitle=$MnTitle,PtTitle=$PtTitle"
content="<div style="line-height:150%;"><h1>CHANGELOG</h1><h6></h6><br><h2>$newVER - $(date " +%F%H%M%S")</h2><br><h3>$gitmojiko</h3> $MjTitle $colMajor $MnTitle $colMinor $PtTitle $colPatch </div>"

echo "content= $content"

path="CHANGELOG.md"
# UpdatedVer=$(cat ./$path)
echo "path= $path"

Repo_SHA=$(curl -H "Authorization: token $Env_Token" \
-X GET https://api.github.com/repos/$user/$repo/contents/$path | jq .sha)

# echo "This is repo_sha = " $Repo_SHA

# echo "Updated Version = " $UpdatedVer
content=$(echo $content | base64)
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
 