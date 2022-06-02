# !/usr/bin/bash

user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"

targetD=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .created_at)

# targetD="2022-06-02"

echo "Date = $targetD"

arrCom=()
while IFS= read -r line; do
arrCom+=( "$line" )
data="$data * ${line:0:7} - ${line:41:50} \n "
cn=$((cn+1))
done < <( git log --after="$targetD" --format=oneline )

echo " arrCOUNT= ${#arrCom[@]} , CN= $cn"
echo "::set-output name=COUNTER::$cn"
# echo "data == \n" $data