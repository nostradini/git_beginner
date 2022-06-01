# !/usr/bin/bash

user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"
echo "user= $user , repo= $repo"
echo "cred = $ENV_TOKEN"

# echo "$(git log --after="2022-05-31T01:16:29Z" --format=oneline)"

tag=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/$user/$repo/releases/latest | jq .tag_name)

prevtag=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))

echo "tag = $tag , prevtag = $prevtag"

targetD=$(curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/repos/nostradini/git_beginner/releases/latest | jq .created_at)

echo "target date= $targetD"
body="## Release $tag"

arrCom=()
while IFS= read -r line; do
    arrCom+=( "$line" )
    # echo "arrCom = " ${line:0:7}
    # echo ${line:41:50}
    body="$body * ${line:0:7} - ${line:41:50} \n"
done < <( git log --after="$targetD" --format=oneline )


prep_post_data()
{
  cat <<EOF
{
  "tag_name":$tag,
  "target_commitish":"main",
  "previous_tag_name":"$prevtag",
  "configuration_file_path":".github/release.yml",
  "body":"$body"
  }
EOF
}

echo "$(prep_post_data)"


# curl \
# -X POST \
# -H "Accept: application/vnd.github.v3+json" \
# -H "Authorization: token $ENV_TOKEN" \
# https://api.github.com/repos/$user/$repo/releases/generate-notes \
# -d "$(prep_post_data)"