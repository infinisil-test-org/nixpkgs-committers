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

mkdir -p "$DIR"
cd "$DIR"

for login in *; do
  rm "$login"
done

gh api /orgs/"$ORG"/teams/"$TEAM"/members --paginate --jq '.[].login' |
  while read -r login; do
    touch "$login"
  done
