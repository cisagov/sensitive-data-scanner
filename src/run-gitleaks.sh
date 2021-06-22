#!/usr/bin/env bash

# beautysh suxors
# @formatter:off

set -o nounset
# set -o errexit
set -o pipefail

USAGE=$(cat << EOF
Run gitleaks over multiple GitHub repositories.

Usage:
  ${0} [options] <github-urls-file>
  ${0} (-h | --help)

Options:
  -h --help                    Show this message.
  -s --skipto=<line-num>       Skip to line number.
  -t --threads=<thread-count>  Number of gitleak threads to run [default: 2]


EOF
)
# setup logging
# shellcheck disable=SC2034
# LOG_NAME used in sourced file
LOG_NAME="RunGitLeaks"

# shellcheck source=src/logging.sh
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

# Positional parameters
PARAMS=""

# Defaults
SKIP_TO_LINE=0
THREADS=2

# Parse command line arguments
while (( "$#" )); do
  case "$1" in
    -h|--help)
      echo "${USAGE}" >&2
      exit 0
      ;;
    -s|--skipto)
      shift
      SKIP_TO_LINE=$1
      shift
      ;;
    -t|--threads)
      shift
      THREADS=$1
      shift
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

if [ "$#" -ne 1 ]; then
    echo "${USAGE}"
    exit 1
fi

URL_FILE=$1

timestamp=$(date +%Y-%m-%d-%H%M%S)

log "Starting scan at ${timestamp} using ${THREADS} threads."

line_number=0
while read -r url; do
  line_number=$((line_number + 1))
  if (( line_number < SKIP_TO_LINE )); then
    continue
  fi
  log "Processing URL #${line_number}: ${url}"
  output_dir="${url#*github.com/}"
  output_file=${output_dir}/${timestamp}.serif.json
  mkdir -p "${output_dir}"
  gitleaks --threads="${THREADS}" --format=sarif --report="${output_file}" --repo-url "${url}"
done < "$URL_FILE"

log "All scans completed."
