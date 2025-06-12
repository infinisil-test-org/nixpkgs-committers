#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo >&2 "Usage: $0 ORG ACTIVITY_REPO MEMBER_REPO DIR"
  exit 1
}

ORG=${1:-$(usage)}
ACTIVITY_REPO=${2:-$(usage)}
MEMBER_REPO=${3:-$(usage)}
DIR=${4:-$(usage)}

tmp=$(mktemp -d)

shopt -s nullglob

# One month plus a bit of leeway
epochOneMonthAgo=$(( $(date --date='1 month ago' +%s) - 60 * 60 * 12 ))
mainBranch=$(git branch --show-current)

mkdir -p "$DIR"
cd "$DIR"
for login in *; do
  gh api -X GET /repos/"$ORG"/"$ACTIVITY_REPO"/activity -f time_period=year -f actor="$login" -f per_page=100 \
    --jq ".[] | \"- \(.timestamp) [\(.activity_type) on \(.ref | ltrimstr(\"refs/heads/\"))](https://github.com/$ORG/$ACTIVITY_REPO/compare/\(.before)...\(.after))\"" \
    > "$tmp/$login"
  activityCount=$(wc -l <"$tmp/$login")

  branchName=retire-$login
  prInfo=$(gh api -X GET /repos/"$ORG"/"$MEMBER_REPO"/pulls -f head="$ORG":"$branchName" --jq '.[0]')
  if [[ -n "$prInfo" ]]; then
    # If there is a PR already
    prNumber=$(jq .number <<< "$prInfo")
    epochCreatedAt=$(date --date="$(jq -r .created_at <<< "$prInfo")" +%s)
    if (( epochCreatedAt < epochOneMonthAgo )); then
      echo "$login has a retirement PR due, comment with a reminder to merge"
      {
        if (( activityCount > 0 )); then
          echo "One month has passed, @$login has been active again:"
          cat "$tmp/$login"
          echo ""
          echo "This PR may be merged and implemented by:"
        else
          echo "One month has passed, to this PR should now be merged and implemented by:"
        fi
        echo "- Adding @$login to the [Retired Nixpkgs Contributors team](https://github.com/orgs/NixOS/teams/retired-nixpkgs-contributors)"
        echo "- Removing @$login from the [Nixpkgs Committers team](https://github.com/orgs/NixOS/teams/nixpkgs-committers)"
      } | gh api --method POST /repos/"$ORG"/"$MEMBER_REPO"/issues/"$prNumber"/comments -F "body=@-" >/dev/null
    else
      echo "$login has a retirement PR pending"
    fi
  elif (( activityCount <= 0 )); then
    echo "$login has become inactive, opening a PR"
    # If there is no PR yet, but they have become inactive
    git switch -C "$branchName"
    git rm "$login"
    git commit -m "Automatic retirement of @$login"
    git push -f origin "$branchName"
    {
      echo "This is an automated PR to retire @$login as a Nixpkgs committers due to not using their commit access for 1 year."
      echo ""
      echo "Make a comment with your motivation to keep commit access, otherwise this PR will be merged and implemented in 1 month."
    } | gh api \
      --method POST \
      /repos/"$ORG"/"$MEMBER_REPO"/pulls \
       -f "title=Automatic retirement of @$login" \
       -F "body=@-" \
       -f "head=$ORG:$branchName" \
       -f "base=$mainBranch" >/dev/null
    git checkout "$mainBranch"
  else
    echo "$login is active with $activityCount activities"
  fi
done
