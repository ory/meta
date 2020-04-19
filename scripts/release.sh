#!/bin/bash

set -Eeuox pipefail

if [[ $1 =~ ^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?$ ]]
then
  echo "$1 is a valid release tag!"
else
  echo "$1 is not a valid semver!"
  exit 1
fi

git checkout master
git pull -ff
git diff --exit-code

goreleaser check
circleci config check

git tag -a "$1"
git push
git push --tags
