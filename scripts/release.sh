#!/bin/bash

set -Eeuo pipefail

if (echo "$1" | grep -Eq "^(major|minor|patch)$"); then
  echo "$1 is a valid release tag!"
elif echo "$1" | grep -Eq "^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?$"; then
  echo "$1 is a valid release tag!"
else
  echo "$1 is not valid, choose 'major', 'minor', 'patch' or a valid semantic version (v1.2.3-alpha.123)!"
  exit 1
fi

go get github.com/davidrjonas/semver-cli@1.1.0
go install github.com/davidrjonas/semver-cli
git checkout -- go.mod
git checkout -- go.sum

prev=$(git describe --abbrev=0)
bumpTo=v$(semver-cli inc "$1" "$prev")

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
