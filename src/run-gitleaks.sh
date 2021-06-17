#!/usr/bin/env bash

# beautysh suxors
# @formatter:off

set -o nounset
# set -o errexit
set -o pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: ${0} <threads> <github-urls-file>"
    exit 255
fi

timestamp=$(date +%Y-%m-%d-%H%M%S)

i=0
while read -r url; do
  i=$((i + 1))
  >&2 echo ">>>> Processing URL #${i}: ${url}"
  output_dir="${url#*github.com/}"
  output_file=${output_dir}/${timestamp}.serif.json
  mkdir -p "${output_dir}"
  gitleaks --threads="${1}" --format=sarif --report="${output_file}" --repo-url "${url}"
done < "$2"
