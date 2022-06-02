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