#!/bin/bash

set -Eexuo pipefail # abort the script on error

# check arguments
project=$1
if [ -z "$project" ]; then
  echo "ERROR: argument 'project' for sync-server.sh is missing"
  exit 1
fi
branch=$2
if [ -z "$branch" ]; then
  echo "ERROR: argument 'branch' for sync-server.sh is missing"
  exit 1
fi
humanName=$3
if [ -z "$humanName" ]; then
  echo "ERROR: argument 'humanName' for sync-server.sh is missing"
  exit 1
fi

# load the sync toolkit
scriptDir="$(dirname "${BASH_SOURCE[0]}")"
source "$scriptDir/sync.sh"

# configure the local Git client on CI
configureGitOnCI

# create a folder to contain the target repo
workdir=$(mktemp -d)

clone "$workdir" "$project" "$branch"
syncRepo "$workdir" "server" "$humanName" "$project"
pushChanges "$GITHUB_SHA"
