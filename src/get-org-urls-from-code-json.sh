#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# Takes a URL to a code.json file outputs repo URLs

>&2 echo "========================================"
>&2 echo "Downloading ${1}"
>&2 echo "========================================"

curl --location --silent -4 "$1" | jq -r '.releases[].repositoryURL' | \
  grep --ignore-case --fixed-strings "github.com" | \
  sed 's/git:/https:/g; s/\.git$//g' | \
  sort --ignore-case --unique
