#!/bin/bash

set -Eeuo pipefail

if ! (echo "$1" | grep -Eq "^(major|minor|patch)$"); then
  echo "$1 is not valid, choose major, minor, or patch!"
  exit 1
fi

go get github.com/davidrjonas/semver-cli
go install github.com/davidrjonas/semver-cli

prev=$(git describe --abbrev=0)
bumpTo=$(semver-cli inc "$1" "$prev")

if grep -q "$bumpTo" <(git tag); then
  echo "There was a problem. It appears that tag $bumpTo already exists!"
  exit 1
fi

read -p "Are you sure you want to bump to $bumpTo? Previous version was $prev. [yN] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

git checkout master
git pull -ff
git diff --exit-code

goreleaser check
circleci config check

git commit --allow-empty -m "chore: pin $bumpTo release commit"
git tag -a "$bumpTo"
git push
git push --tags

echo "Successfully released $bumpTo"
