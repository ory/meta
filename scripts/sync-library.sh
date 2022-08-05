#!/bin/bash

# Causes the script to abort on error.
set -Eexuo pipefail

# Change directory to the path of the invoking script.
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Reads and executes commands from sync.sh in the current shell environment.
source scripts/sync.sh

# Set workdir to a temporary directory, set project, branch, humanName to the shell arguments 1-3.
workdir=$(mktemp -d)
project=$1
branch=$2
humanName=$3

# Clones the in project specified repository (for example ory/hydra) with history truncated to latest commit on the in sync.yml specified branch.
git clone --depth 1 --branch "$branch" "git@github.com:$1.git" "$workdir"
sync "$workdir" "$branch" "library" "$humanName" "$project"
