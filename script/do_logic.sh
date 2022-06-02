# !/usr/bin/bash

user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"

# targetD=$(curl \
# -H "Accept: application/vnd.github.v3+json" \
# https://api.github.com/repos/$user/$repo/releases/latest | jq .created_at)

targetD="2022-06-02T03:00:00Z"

echo "Date = $targetD"
data="# $ENV_GM date "+%F-%H-%M-%S" \n "
arrCom=()
while IFS= read -r line; do
arrCom+=( "$line" )
# data="$data ## * ${line:0:7} - ${line:41:50} \n "

if [[ "${line:41:50}" != "[JOB]"* ]]
then
    if [[ "${line:41:50}" == *"#major"* ]]
    then
    echo "Found major in commit"
    ver_major=$((ver_major+1))
    ver_minor=0
    ver_patch=0
    bMajor=true
    colMajor="$colMajor ## * ${line:0:7} - ${line:41:50} \n "
    elif [[ "${line:41:50}" == *"#minor"* ]]
    then
    echo "Found minor in commit"
    ver_minor=$((ver_minor+1))
    ver_patch=0
    bMinor=true
    colMinor="$colMinor ## * ${line:0:7} - ${line:41:50} \n "
    elif [[ "${line:41:50}" == *"#patch"* ]]
    then
    echo "Found patch in commit"
    ver_patch=$((ver_patch+1))
    bPatch=true
    colPatch="$colPatch ## * ${line:0:7} - ${line:41:50} \n "
    else
    echo "Default condition"
    fi
fi
done < <( git log --after="$targetD" --format=oneline )
if [[ bMajor=true ]] then
    gitmojiko=":boom: Breaking Changes"
elif [[ bMinor=true ]] then
    gitmojiko=":sparkles: New Features"
elif [[ bPatch=true ]] then
    gitmojiko=":bug: Bug Fixes"
else
    gitmojiko="UNRELEASED"
fi
echo "gitmojiko= $gitmojiko"
echo "colMajor= $colMajor"
echo "colMinor= $colMinor"
echo "colPatch= $colPatch"
echo "::set-output name=envgitmojiko::$gitmojiko"
echo "::set-output name=envMajor::$colMajor"
echo "::set-output name=envMinor::$colMinor"
echo "::set-output name=envPatch::$colPatch"
echo "NEW= ver_major=$ver_major,ver_minor=$ver_minor,ver_patch=$ver_patch"
# echo "data == \n" $data