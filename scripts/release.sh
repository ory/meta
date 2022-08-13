#!/bin/bash

set -Eeuo pipefail

prompt() {
	read -p "$1 [yN] " -n 1 -r
	echo # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	fi
}

git checkout master
git tag -d "$(git tag -l)"
git fetch origin --tags
git pull -ff
git diff --exit-code
prev=$(git describe --abbrev=0 --tags)

if (echo "$1" | grep -Eq "^(major|minor|patch)$"); then
	echo "$1 is a valid release tag!"
	go get github.com/davidrjonas/semver-cli@1.1.0
	go install github.com/davidrjonas/semver-cli
	git checkout -- go.mod
	git checkout -- go.sum
	bumpTo=v$(semver-cli inc "$1" "$prev")
elif echo "$1" | grep -Eq "^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?$"; then
	echo "$1 is a valid release tag!"
	bumpTo="$1"
else
	echo "$1 is not valid, choose 'major', 'minor', 'patch' or a valid semantic version (v1.2.3-alpha.123)!"
	exit 1
fi

project=$(basename "$(pwd)")
if ! echo "$project" | grep -Eq "^hydra|keto|oathkeeper|kratos$"; then
	echo "This script is expected to run in a directory named 'hydra', 'keto', 'oathkeeper', 'kratos'."
	exit 1
fi

git checkout master
git tag -d "$(git tag -l)"
git fetch origin --tags
git pull -ff
git diff --exit-code

if grep -q "$bumpTo" <(git tag); then
	echo "There was a problem. It appears that tag $bumpTo already exists!"
	exit 1
fi

prompt "Are you sure you want to bump to $bumpTo? Previous version was $prev."

if [[ $project == 'hydra' ]]; then
	prompt "This will also release hydra-login-consent-node to $bumpTo. Previous version was $prev. Is that ok?"
	ui=$(mktemp -d)
	git clone git@github.com:ory/hydra-login-consent-node.git "$ui"
	(cd "$ui" &&
		git commit --allow-empty -m "chore: pin $bumpTo release commit" &&
		git tag "$bumpTo" &&
		git push &&
		git push --tags)

elif [[ $project == 'kratos' ]]; then
	prompt "This will also release kratos-selfservice-ui-node to $bumpTo. Previous version was $prev. Is that ok?"
	ui=$(mktemp -d)
	git clone git@github.com:ory/kratos-selfservice-ui-node.git "$ui"
	(cd "$ui" &&
		git commit --allow-empty -m "chore: pin $bumpTo release commit" &&
		git tag "$bumpTo" &&
		git push &&
		git push --tags)
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
