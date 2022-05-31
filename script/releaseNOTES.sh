# !/usr/bin/bash
user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginner"
echo "user= $user , repo= $repo"

curl \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$user/$repo/releases/latest


prep_post_data()
{
  cat <<EOF
{
  "tag_name":"v0.0.2",
  "target_commitish":"main",
  "previous_tag_name":"v0.0.1",
  "body":"## Release v0.0.2 - by $user"
}
EOF
}

echo "$(prep_post_data)"

#   "configuration_file_path":".github/custom_release_config.yml"

curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos//$user/$repo/releases/generate-notes \
  -d "$(prep_post_data)"