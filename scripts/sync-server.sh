#!/bin/bash

set -Eexuo pipefail # abort the script on error

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
