#!/bin/bash

set -Eexuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )/.."
source scripts/sync.sh

workdir=$(mktemp -d)
project=$1
branch=$2
humanName=$3

git clone --depth 1 --branch "$branch" "git@github.com:$1.git" "$workdir"
sync "$workdir" "$branch" "library" $humanName $project
