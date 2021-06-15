#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# Get the orgs from GSA's list on GitHub

AGENCY_LIST=https://raw.githubusercontent.com/GSA/code-gov-front-end/master/config/site/agency_list.json

curl -L --silent "${AGENCY_LIST}" | jq -r '.[].orgs[]' | \
  sort --ignore-case --unique
