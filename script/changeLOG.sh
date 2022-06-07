# !/usr/bin/bash
ver_major=$1
ver_minor=$2
ver_patch=$3
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


arrCom=()
while IFS= read -r line; do
lowerstr=$(echo ${line:41:50}|tr '[:upper:]' '[:lower:]')
echo "transformed to lower = $lowerstr"
if [[ "${lowerstr}" != "[job]"* ]]
then
    if [[ "${lowerstr}" == *"#major"* ]]
    then
    echo "Found major in commit"
    bMajor=true
    colMajor="$colMajor <h4><li> ${line:0:7} - ${line:41:50} <li/><h4/><br>"
    elif [[ "${lowerstr}" == *"#minor"* ]]
    then
    echo "Found minor in commit"
    bMinor=true
    colMinor="$colMinor <h4><li> ${line:0:7} - ${line:41:50} <li/><h4/><br>"
    elif [[ "${lowerstr}" == *"#patch"* ]]
    then
    echo "Found patch in commit"
    bPatch=true
    colPatch="$colPatch <h4><li> ${line:0:7} - ${line:41:50} <li/><h4/><br>"
    else
    # echo "Default condition"
    bDefault=true
    colDefault="$colDefault <h4><li> ${line:0:7} - ${line:41:50} <li/><h4/><br>"
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

echo "NEW= major=$ver_major,minor=$ver_minor,patch=$ver_patch"

content="<h1> CHANGELOG <h1/> <br> <h2> $gitmojiko <h2/> <br><ul> $colMajor $colMinor $colPatch <ul/>"

echo "content= $content"

# echo "trLC= $trLC"
# LenlastComm=${#trLC}
# echo "size of commit is = " $LenlastComm
# if [[ $LenlastComm -gt 50 ]]
# then
#     trimLC="${trLC:0:50}..."
# else
#     trimLC=${trLC}
# fi
# echo "trimmed = " $trimLC 
# cat /dev/null > ./VERSION
# echo -n "Version $ver_major.$ver_minor.$ver_patch - $trimLC" > ./VERSION

path="CHANGELOG.md"
# UpdatedVer=$(cat ./$path)
echo "path= $path"

Repo_SHA=$(curl -H "Authorization: token $Env_Token" \
-X GET https://api.github.com/repos/$user/$repo/contents/$path | jq .sha)

echo "This is repo_sha = " $Repo_SHA

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
 