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
data="$data ## * ${line:0:7} - ${line:41:50} \n "

if [["${line:41:50}" != "[JOB]"* ]]
    if [[ "${line:41:50}" == *"#major"* ]]
    then
    echo "Found major in commit"
    echo "gitmojiko=:boom: Breaking Changes"
    ver_major=$((ver_major+1))
    ver_minor=0
    ver_patch=0
    bMajor= true
    arrMajor="$arrMajor"
    elif [[ "$lowerstr" == *"#minor"* ]]
    then
    echo "Found minor in commit"
    echo "gitmojiko=:sparkles: New Features"
    ver_minor=$((ver_minor+1))
    ver_patch=0
    elif [[ "$lowerstr" == *"#patch"* ]]
    then
    echo "Found patch in commit"
    echo "gitmojiko=:bug: Bug Fixes"
    ver_patch=$((ver_patch+1))
    else
    echo "Default condition"
    echo "gitmojiko=UNRELEASED"
    fi

fi
done < <( git log --after="$targetD" --format=oneline )

echo "data == \n" $data