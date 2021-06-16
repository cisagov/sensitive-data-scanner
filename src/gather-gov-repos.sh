#!/usr/bin/env bash

# beautysh suxors
# @formatter:off

set -o nounset
set -o errexit
# set -o pipefail


if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} <output-filename>"
    exit 255
fi

AGENCY_LIST=https://raw.githubusercontent.com/GSA/code-gov-front-end/master/config/site/agency_list.json


>&2 echo ">>>> Fetching orgs from GSA list on GitHub."

gsa_orgs_file=$(mktemp -t gsa_orgs.XXXXXX)

curl --silent --show-error --location "${AGENCY_LIST}" | jq -r '.[].orgs[]' | \
  sort --ignore-case --unique > "$gsa_orgs_file"


>&2 echo ">>>> Fetching code.json urls from GSA's list on GitHub."

gsa_code_json_url_file=$(mktemp -t gsa_code_json_url.XXXXXX)

curl --silent --show-error --location "${AGENCY_LIST}" | jq -r '.[].codeUrl' | \
  sort --ignore-case --unique > "$gsa_code_json_url_file"


>&2 echo ">>>> Extracting repository URLs from code.json files."

repo_urls_from_code_jsons_file=$(mktemp -t gsa_code_json_url.XXXXXX)

while read -r url; do
  >&2 echo ">>>> Fetching ${url}."
  curl --silent --show-error --location -4 "${url}"  | \
    jq -r '.releases[].repositoryURL' | \
    grep --ignore-case --fixed-strings "github.com" | \
    sed 's/git:/https:/g; s/\.git$//g' | \
    sort --ignore-case --unique >> "${repo_urls_from_code_jsons_file}"
done < "$gsa_code_json_url_file"

# Convert a list of GitHub orgs into a list of repo URLs
>&2 echo ">>>> Converting GitHub orgs into repository URLs."
repo_urls_from_gsa_orgs_file=$(mktemp -t repo_urls_from_gsa_orgs.XXXXXX)

while read -r org; do
  >&2 echo ">>>> Querying GitHub for repositories in ${org} organization."
  gh repo list "${org}" --limit 10000  | \
  awk '{print "https://github.com/"$1}' >> "$repo_urls_from_gsa_orgs_file"
done < "$gsa_orgs_file"

>&2 echo ">>>> Writing combinined repository URLs to ${1}"
cat "${repo_urls_from_code_jsons_file}" "${repo_urls_from_gsa_orgs_file}" | \
  sort --ignore-case --unique > "${1}"
