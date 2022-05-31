# !/usr/bin/bash
user="$(git log -n 1 --pretty=format:%an)"
repo="git_beginer"

curl \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$user/$repo/releases/latest


prep_post_data()
{
  cat <<EOF
{
  "tag_name":"v1.0.0",
  "target_commitish":"main",
  "previous_tag_name":"v0.9.2",
#   "configuration_file_path":".github/custom_release_config.yml"
}
EOF
}

echo "$(prep_post_data)"


curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos//$user/$repo/releases/generate-notes \
  -d "$(prep_post_data)"