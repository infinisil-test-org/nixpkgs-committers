#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo >&2 "Usage: $0 ORG TEAM DIR"
  exit 1
}

ORG=${1:-$(usage)}
TEAM=${2:-$(usage)}
DIR=${3:-$(usage)}

shopt -s nullglob

for file in "$DIR"/*; do
  rm "$file"
done

mkdir -p "$DIR"

gh api /orgs/"$ORG"/teams/"$TEAM"/members --paginate --jq '.[].login' |
  while read -r login; do
    touch "$DIR"/"$login"
  done
