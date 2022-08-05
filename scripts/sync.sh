#!/bin/bash

set -Eexuo pipefail  # abort the script on error


function syncAll {
  sync ory/hydra server master "Hydra"
  sync ory/keto server master "Keto"
  sync ory/oathkeeper server master "Oathkeeper"
  sync ory/kratos server master "Kratos"
  sync ory/hydra-login-consent-node library master "Hydra Login, Logout And Consent Node Example"
  sync ory/docs library master "Documentation"
  sync ory/cli library master "CLI"
  sync ory/kratos-selfservice-ui-node library master "Kratos SelfService UI Node Example"
  sync ory/kratos-selfservice-ui-react-native library master "Kratos SelfService UI React Native Example"
  sync ory/fosite library master "Fosite"
  sync ory/dockertest library v3 "Dockertest"
  sync ory/herodot library master "Herodot"
ory/graceful library master Graceful
ory/themes library master Themes
ory/k8s library master "Kubernetes Resources"
ory/x library  master "X"
ory/web library master Web
ory/closed-reference-notifier action master "Closed Reference Notifier"
ory/label-sync-action action master "Label Sync Action"
ory/milestone-action action master "Milestone Action"
ory/prettier-styles action  master "Prettier Styles"

action.sh ory/build-buf-action main "Buildbuf Action"
library.sh ory/examples master Examples
library.sh ory/hydra-maester master "Ory Hydra Maester"
library.sh ory/oathkeeper-maester master "Ory Oathkeeper Maester"
library.sh ory/sdk master "Ory SDK"
library.sh ory/platform master "Ory Platform"
library.sh ory/keto-client-dotnet master "Ory Keto Dotnet Client"
library.sh ory/keto-client-java master "Ory Keto Java Client"
library.sh ory/keto-client-rust master "Ory Keto Rust Client"
library.sh ory/keto-client-dart master "Ory Keto Dart Client"
library.sh ory/keto-client-js master "Ory Keto JavaScript Client"
library.sh ory/keto-client-php master "Ory Keto PHP Client"
library.sh ory/keto-client-go master "Ory Keto Go Client"
library.sh ory/keto-client-ruby master "Ory Keto Ruby Client"
library.sh ory/keto-client-python master "Ory Keto Python Client"
library.sh ory/kratos-client-dotnet master "Ory Kratos Dotnet Client"
library.sh ory/kratos-client-java master "Ory Kratos Java Client"
library.sh ory/kratos-client-rust master "Ory Kratos Rust Client"
library.sh ory/kratos-client-dart master "Ory Kratos Dart Client"
library.sh ory/kratos-client-js master "Ory Kratos JavaScript Client"
library.sh ory/kratos-client-php master "Ory Kratos PHP Client"
library.sh ory/kratos-client-go master "Ory Kratos Go Client"
library.sh ory/kratos-client-ruby master "Ory Kratos Ruby Client"
library.sh ory/kratos-client-python master "Ory Kratos Python Client"
library.sh ory/hydra-client-dotnet master "Ory Hydra Dotnet Client"
library.sh ory/hydra-client-java master "Ory Hydra Java Client"
library.sh ory/hydra-client-rust master "Ory Hydra Rust Client"
library.sh ory/hydra-client-dart master "Ory Hydra Dart Client"
library.sh ory/hydra-client-js master "Ory Hydra JavaScript Client"
library.sh ory/hydra-client-php master "Ory Hydra PHP Client"
library.sh ory/hydra-client-go master "Ory Hydra Go Client"
library.sh ory/hydra-client-ruby master "Ory Hydra Ruby Client"
library.sh ory/hydra-client-python master "Ory Hydra Python Client"
library.sh ory/oathkeeper-client-dotnet master "Ory Oathkeeper Dotnet Client"
library.sh ory/oathkeeper-client-java master "Ory Oathkeeper Java Client"
library.sh ory/oathkeeper-client-rust master "Ory Oathkeeper Rust Client"
library.sh ory/oathkeeper-client-dart master "Ory Oathkeeper Dart Client"
library.sh ory/oathkeeper-client-js master "Ory Oathkeeper JavaScript Client"
library.sh ory/oathkeeper-client-php master "Ory Oathkeeper PHP Client"
library.sh ory/oathkeeper-client-go master "Ory Oathkeeper Go Client"
library.sh ory/oathkeeper-client-ruby master "Ory Oathkeeper Ruby Client"
library.sh ory/oathkeeper-client-python master "Ory Oathkeeper Python Client"

}





# configures the Git client on CI
function configureGitOnCI {
  # Set git email & username as specified in git.sh
  bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
  # change global url from https://github.com/ to git@github.com:
  git config --global url."git@github.com:".insteadOf https://github.com/
}

function sync {
  # load and verify arguments
	workdir=$1
  if [ -z "$workdir" ]; then
    echo "ERROR: argument 'humanName' for sync() is missing"
    exit 1
  fi
	type=$2
  if [ -z "$type" ]; then
    echo "ERROR: argument 'type' for sync() is missing"
    exit 1
  fi
	humanName=$3
  if [ -z "$humanName" ]; then
    echo "ERROR: argument 'humanName' for sync() is missing"
    exit 1
  fi
	project=$4
  if [ -z "$project" ]; then
    echo "ERROR: argument 'project' for sync() is missing"
    exit 1
  fi
	# branch=$5

	# Change directory to the path of the invoking script
	cd "$(dirname "${BASH_SOURCE[0]}")/.."
	# pushBranch="meta-$(date +%m-%d-%y-%H-%M-%S)"
	# set hash as github commit hash, first 8 bytes
	# hash=$(echo $GITHUB_SHA | head -c 8)

	copyTemplates "$workdir" "$type"
  cd "$workdir"
  substitutePlaceholders "$project" "https://github.com/$project/discussions" "$humanName"

	# format everything that was rendered, only if package.json exists
  if test -f package.json; then
			formatEverything
	fi
	if [ -d "$workdir/docs/docs" ]; then
    copyContributingGuideToDocs "$workdir"
    formatDocs "$workdir"
  fi
  addAdoptersToReadme "$workdir"
  addEcosystemToReadme "$workdir"
}


function clone {
  workdir=$1
  project=$2
  branch=$3
  git clone --depth 1 --branch "$branch" "git@github.com:$project.git" "$workdir"
}


function copyTemplates {
  workdir=$1
  type=$2
	rm -rf "$workdir/.github/ISSUE_TEMPLATE/"
	# Copy common templates to workdir
	cp -R "templates/repository/common/CONTRIBUTING.md" "$workdir/CONTRIBUTING.md"
	cp -R "templates/repository/common/SECURITY.md" "$workdir/SECURITY.md"
	cp -R "templates/repository/common/LICENSE" "$workdir/LICENSE"
	cp -R "templates/repository/common/CODE_OF_CONDUCT.md" "$workdir/CODE_OF_CONDUCT.md"
	# Copy .reference-ignore only if it does not exist, as it is meant to help getting started
	cp -n "templates/repository/common/.reference-ignore" "$workdir/.reference-ignore" || true
	cp -R "templates/repository/common/.github" "$workdir/"
	# Copy specific templates for servers or library (depending on $type)
	cp -R "templates/repository/$type/.github" "$workdir/"
}

function substitutePlaceholders {
	project=$1
  discussions=$2
  humanName=$3
  substitutePlaceholders ".github/ISSUE_TEMPLATE" "$project" "$discussions" "$humanName"
  substitutePlaceholders ".github/pull_request_template.md" "$project" "$discussions" "$humanName"
  substitutePlaceholders "CONTRIBUTING.md" "$project" "$discussions" "$humanName"
  substitutePlaceholders "SECURITY.md" "$project" "$discussions" "$humanName"
  substitutePlaceholders "CODE_OF_CONDUCT.md" "$project" "$discussions" "$humanName"
  substitutePlaceholders "LICENSE" "$project" "$discussions" "$humanName"
}

# replaces placeholders like "$PROJECT" in the given file with the given values
function substitutePlaceholdersInFile {
  file=$1
	project=$2
  discussions=$3
  humanName=$4
  if [ ! -f "$file" ]; then
    return
  fi
  if [[ "$project" = "ory/hydra" || $project = "ory/kratos" || $project = "ory/oathkeeper" || $project = "ory/keto" ]]; then
    env -i DISCUSSIONS="$discussions" REPOSITORY="$project" PROJECT="$humanName" /bin/bash -c "envsubst < \"$file\" | sponge \"$file\""
  else
    env -i DISCUSSIONS="https://github.com/orgs/ory/discussions" REPOSITORY="$project" PROJECT="$humanName" /bin/bash -c "envsubst < \"$file\" | sponge \"$file\""
  fi
}


function formatEverything {
  npm i --legacy-peer-deps
  npm run format
}


# formats only the /docs folder
function formatDocs {
	workdir=$1
  (
    cd "$workdir/docs"
    bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/prettier.sh)
    npm run format
  )
}


# copy contributing guide to docs if docs exist
function copyContributingGuideToDocs {
	workdir=$1
  file="$workdir/docs/docs/contributing.md"
  cat <<EOF >"$file"
---
id: contributing
title: Contribution Guidelines
---

EOF
  cat "$workdir/CONTRIBUTING.md" >>"$file"
  sed '/Contributing to/d' "$file"
}


function addAdoptersToReadme {
	workdir=$1
	perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->\n#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
}

# adds an overview of all projects to README.md
function addEcosystemToReadme {
	workdir=$1
	perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->\n#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"
}

# commits the changes in the current directory to the local Git client
function commitChanges {
  GITHUB_SHA=$1
  git add -A
  git commit -a -m "chore: update repository templates" -m "[skip ci] - updated repository templates to https://github.com/ory/meta/commit/$GITHUB_SHA"
}

# pushes the committed changes from the local Git client to GitHub
function pushChanges {
  git push origin HEAD:master
}

# creates a pull request with the changes on GitHub
# function createPullRequest {
# 	curl \
# 	  -X POST \
# 	  -H "Authorization: token $GITHUB_TOKEN" \
# 	  -H "Accept: application/vnd.github.v3+json" \
# 	  https://api.github.com/repos/$project/pulls \
# 	  -d '{"title":"chore: update repository template to '$hash'","body":"Updated repository templates to https://github.com/ory/meta/commit/'$GITHUB_SHA'.","head":"'$pushBranch'","base":"'$branch'"}' \
# 	) || true)
# }
