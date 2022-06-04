# !/usr/bin/bash
ver_major=$1
ver_minor=$2
ver_patch=$3
user=$4
trLC=$5
repo=$6
bMajor=false
bMinor=false
bPatch=false
bDefault=false

echo "User= $USER , REPO= $REPO"

targetD=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .created_at)

# targetD="2022-06-03T02:00:00Z"

echo "Date = $targetD"

# arrCom=()
while IFS= read -r line; do
# arrCom+=( "$line" )
## handlle char case
lowerstr=$(echo ${line:41:50}|tr '[:upper:]' '[:lower:]')
echo "transformed to lower = $lowerstr"
if [[ "${lowerstr}" != "[job]"* ]]
then
    if [[ "${lowerstr}" == *"#major"* ]]
    then
    echo "Found major in commit"
    bMajor=true
    colMajor="$colMajor \n    - ##### ${line:0:7} - ${line:41:50} \n"
    elif [[ "${lowerstr}" == *"#minor"* ]]
    then
    echo "Found minor in commit"
    bMinor=true
    colMinor="$colMinor \n    - ##### ${line:0:7} - ${line:41:50} \n"
    elif [[ "${lowerstr}" == *"#patch"* ]]
    then
    echo "Found patch in commit"
    bPatch=true
    colPatch="$colPatch \n    - ##### ${line:0:7} - ${line:41:50} \n"
    else
    # echo "Default condition"
    bDefault=true
    colDefault="$colDefault \n    - #### ${line:0:7} - ${line:41:50} \n"
    fi
fi
done < <( git log --after="$targetD" --format=oneline )
echo "$bMajor - $bMinor - $bPatch"
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
echo "::set-output name=envgitmojiko::$gitmojiko"
echo "::set-output name=envMajor::$colMajor"
echo "::set-output name=envMinor::$colMinor"
echo "::set-output name=envPatch::$colPatch"
echo "::set-output name=envVersion::$ver_major.$ver_minor.$ver_patch"
echo "NEW= major=$ver_major,minor=$ver_minor,patch=$ver_patch"

echo "trLC= $trLC"
LenlastComm=${#trLC}
echo "size of commit is = " $LenlastComm
if [[ $LenlastComm -gt 50 ]]
then
    trimLC="${trLC:0:50}..."
else
    trimLC=${trLC}
fi
echo "trimmed = " $trimLC
cat /dev/null > ./VERSION
echo -n "Version $ver_major.$ver_minor.$ver_patch - $trimLC" > ./VERSION
