# !/usr/bin/bash

user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"
echo "user= $user , repo= $repo"
echo "cred = $ENV_TOKEN"

echo "$(git log --after="2022-05-31T01:16:29Z" --format=oneline)"


arrCom=()
while IFS= read -r line; do
    arrCom+=( "$line" )
done < <( git log --after="2022-05-31T01:16:29Z" --format=oneline )

echo "arrCom = " ${arrCom[0]:0:7}

body="## Release v$tag"

for i in ${arrCom[*]}; do
  echo $i
  # body+="$body "\n ${i:0:7} - $(cut -d' ' -f2 <<< "$i")"
done


tag=$(curl \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$user/$repo/releases/latest | jq .tag_name)


prep_post_data()
{
  cat <<EOF
{
  "tag_name":$tag,
  "target_commitish":"main",
  "previous_tag_name":"v0.0.1",
  "configuration_file_path":".github/release.yml",
  "body":$body
  }
EOF
}

echo "$(prep_post_data)"


# curl \
#   -X POST \
#   -H "Accept: application/vnd.github.v3+json" \
#   -H "Authorization: token $ENV_TOKEN" \
#   https://api.github.com/repos//$user/$repo/releases/generate-notes \
#   -d "$(prep_post_data)"