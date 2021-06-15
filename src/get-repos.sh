#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail


# Takes a github org, returns a list of repo URLs

gh repo list "$1" --limit 10000 | awk '{print "https://github.com/"$1}' # AWK FOR THE WIN!
