# !/usr/bin/bash

USER="$(git log -n 1 --pretty=format:%an)"
REPO="git_beginner"

echo "User= $USER , REPO= $REPO"

# targetD=$(curl \
# -H "Accept: application/vnd.github.v3+json" \
# https://api.github.com/repos/$user/$repo/releases/latest | jq .created_at)

targetD="2022-06-02T03:00:00Z"

echo "Date = $targetD"

arrCom=()
while IFS= read -r line; do
arrCom+=( "$line" )
done < <( git log --after="$targetD" --format=oneline )
echo " arrCOUNT= ${#arrCom[@]}"
echo "::set-output name=COUNTER::${#arrCom[@]}"
lcommit=$(git log --format=%B -n 1 HEAD)
echo "::set-output name=LASTCOM::$lcommit"

ver_str=$(cat "VERSION")
ver_extract_str="$(cut -d' ' -f2 <<< "$ver_str")"
echo "Version string is $ver_extract_str"
ver_major="$(cut -d'.' -f1 <<< "$ver_extract_str")"
ver_minor="$(cut -d'.' -f2 <<< "$ver_extract_str")"
ver_patch="$(cut -d'.' -f3 <<< "$ver_extract_str")"
echo "OLD= ver_major=$ver_major,ver_minor=$ver_minor,ver_patch=$ver_patch"