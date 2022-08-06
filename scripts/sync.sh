#!/bin/bash

set -Eexuo pipefail  # abort the script on error

# syncs all repositories
# $push == "push" --> commit and push to Github
# $push == "keep" --> don't commit or push
function sync_all {
  workspace=$1
  if [ -z "$workspace" ]; then
    echo "Please provide a workspace directory to sync_all"
    exit 1
  fi
  push=$2
  if [ "$push" != "push" ] && [ "$push" != "keep" ]; then
    echo "Unknown value for 'push' argument: '$push'. Please provide either 'push' or 'keep'."
    exit 1
  fi
  cd "$workspace"
  sync ory/hydra server "Hydra" "$workspace" "$push"
  sync ory/keto server "Keto" "$workspace" "$push"
  sync ory/oathkeeper server "Oathkeeper" "$workspace" "$push"
  sync ory/kratos server "Kratos" "$workspace" "$push"
  sync ory/hydra-login-consent-node library "Hydra Login, Logout And Consent Node Example" "$workspace" "$push"
  sync ory/docs library "Documentation" "$workspace" "$push"
  sync ory/cli library "CLI" "$workspace" "$push"
  sync ory/kratos-selfservice-ui-node library "Kratos SelfService UI Node Example" "$workspace" "$push"
  sync ory/kratos-selfservice-ui-react-native library "Kratos SelfService UI React Native Example" "$workspace" "$push"
  sync ory/fosite library "Fosite" "$workspace" "$push"
  sync ory/dockertest library "Dockertest" "$workspace" "$push"
  sync ory/herodot library "Herodot" "$workspace" "$push"
  sync ory/graceful library "Graceful" "$workspace" "$push"
  sync ory/themes library "Themes" "$workspace" "$push"
  sync ory/k8s library "Kubernetes Resources" "$workspace" "$push"
  sync ory/x library  "X" "$workspace" "$push"
  sync ory/web library "Web" "$workspace" "$push"
  sync ory/closed-reference-notifier action "Closed Reference Notifier" "$workspace" "$push"
  sync ory/label-sync-action action "Label Sync Action" "$workspace" "$push"
  sync ory/milestone-action action "Milestone Action" "$workspace" "$push"
  sync ory/prettier-styles action  "Prettier Styles" "$workspace" "$push"
  sync ory/build-buf-action action  "Buildbuf Action" "$workspace" "$push"
  sync ory/examples library "Examples" "$workspace" "$push"
  sync ory/hydra-maester library "Ory Hydra Maester" "$workspace" "$push"
  sync ory/oathkeeper-maester library "Ory Oathkeeper Maester" "$workspace" "$push"
  sync ory/sdk library "Ory SDK" "$workspace" "$push"
  sync ory/platform library "Ory Platform" "$workspace" "$push"
  sync ory/keto-client-dotnet library "Ory Keto Dotnet Client" "$workspace" "$push"
  sync ory/keto-client-java library "Ory Keto Java Client" "$workspace" "$push"
  sync ory/keto-client-rust library "Ory Keto Rust Client" "$workspace" "$push"
  sync ory/keto-client-dart library "Ory Keto Dart Client" "$workspace" "$push"
  sync ory/keto-client-js library "Ory Keto JavaScript Client" "$workspace" "$push"
  sync ory/keto-client-php library "Ory Keto PHP Client" "$workspace" "$push"
  sync ory/keto-client-go library "Ory Keto Go Client" "$workspace" "$push"
  sync ory/keto-client-ruby library "Ory Keto Ruby Client" "$workspace" "$push"
  sync ory/keto-client-python library "Ory Keto Python Client" "$workspace" "$push"
  sync ory/kratos-client-dotnet library "Ory Kratos Dotnet Client" "$workspace" "$push"
  sync ory/kratos-client-java library "Ory Kratos Java Client" "$workspace" "$push"
  sync ory/kratos-client-rust library "Ory Kratos Rust Client" "$workspace" "$push"
  sync ory/kratos-client-dart library "Ory Kratos Dart Client" "$workspace" "$push"
  sync ory/kratos-client-js library "Ory Kratos JavaScript Client" "$workspace" "$push"
  sync ory/kratos-client-php library "Ory Kratos PHP Client" "$workspace" "$push"
  sync ory/kratos-client-go library "Ory Kratos Go Client" "$workspace" "$push"
  sync ory/kratos-client-ruby library "Ory Kratos Ruby Client" "$workspace" "$push"
  sync ory/kratos-client-python library "Ory Kratos Python Client" "$workspace" "$push"
  sync ory/hydra-client-dotnet library "Ory Hydra Dotnet Client" "$workspace" "$push"
  sync ory/hydra-client-java library "Ory Hydra Java Client" "$workspace" "$push"
  sync ory/hydra-client-rust library "Ory Hydra Rust Client" "$workspace" "$push"
  sync ory/hydra-client-dart library "Ory Hydra Dart Client" "$workspace" "$push"
  sync ory/hydra-client-js library "Ory Hydra JavaScript Client" "$workspace" "$push"
  sync ory/hydra-client-php library "Ory Hydra PHP Client" "$workspace" "$push"
  sync ory/hydra-client-go library "Ory Hydra Go Client" "$workspace" "$push"
  sync ory/hydra-client-ruby library "Ory Hydra Ruby Client" "$workspace" "$push"
  sync ory/hydra-client-python library "Ory Hydra Python Client" "$workspace" "$push"
  sync ory/oathkeeper-client-dotnet library "Ory Oathkeeper Dotnet Client" "$workspace" "$push"
  sync ory/oathkeeper-client-java library "Ory Oathkeeper Java Client" "$workspace" "$push"
  sync ory/oathkeeper-client-rust library "Ory Oathkeeper Rust Client" "$workspace" "$push"
  sync ory/oathkeeper-client-dart library "Ory Oathkeeper Dart Client" "$workspace" "$push"
  sync ory/oathkeeper-client-js library "Ory Oathkeeper JavaScript Client" "$workspace" "$push"
  sync ory/oathkeeper-client-php library "Ory Oathkeeper PHP Client" "$workspace" "$push"
  sync ory/oathkeeper-client-go library "Ory Oathkeeper Go Client" "$workspace" "$push"
  sync ory/oathkeeper-client-ruby library "Ory Oathkeeper Ruby Client" "$workspace" "$push"
  sync ory/oathkeeper-client-python library "Ory Oathkeeper Python Client" "$workspace" "$push"
}

function sync {
  # load and verify arguments
	repo_id=$1
  if [ -z "$repo_id" ]; then
    echo "ERROR: argument \"repo_id\" for sync() is missing. Please provide the XXX part of the URL: https://github.com/XXX"
    exit 1
  fi
	repo_type=$2
  if [ "$repo_type" != "action" ] && [ "$repo_type" != "library" ] && [ "$repo_type" != "server" ]; then
    echo "ERROR: invalid argument \"repo_type\" for sync(): \"$repo_type\". Please provide either \"action\", \"library\", or \"server\""
    exit 1
  fi
	human_name=$3
  if [ -z "$human_name" ]; then
    echo 'ERROR: argument "human_name" for sync() is missing'
    exit 1
  fi
	workspace=$4
  if [ -z "$workspace" ]; then
    echo 'ERROR: argument "workspace" for sync() is missing'
    exit 1
  fi
	push=$5
  if [ "$push" != "push" ] && [ "$push" != "keep" ]; then
    echo "Unknown value for \"push\" argument: \"$push\". Please provide either \"push\" or \"keep\"."
    exit 1
  fi

  # clone if the codebase doesn't exist in the workspace yet
  repo_name=$(basename "$repo_id")
  repo_path="$workspace/$repo_name"
  if [ ! -d "$repo_path" ]; then
    clone "$repo_id" "$repo_path"
  fi

	copy_templates "$repo_path" "$repo_type"
  substitutePlaceholders "$project" "https://github.com/$project/discussions" "$human_name"

	# format everything that was rendered, only if package.json exists
  if test -f package.json; then
			format_everything
	fi
	if [ -d "$repo_id/docs/docs" ]; then
    copy_contributing_guide_to_docs "$repo_id"
    format_docs "$repo_id"
  fi
  add_adopters_to_readme "$repo_id"
  add_ecosystem_to_readme "$repo_id"
  if [ "$push" == "push" ]; then
    commit_changes
    push_changes
  fi
}


############################################################
### HELPER FUNCTIONS

function add_adopters_to_readme {
	workdir=$1
	perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->\n#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
}

# adds an overview of all projects to README.md
function add_ecosystem_to_readme {
	workdir=$1
	perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->\n#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"
}

# clones the given project onto the local machine
function clone {
  repo_id=$1
  repo_path=$2
  git clone --depth 1 "git@github.com:$repo_id.git" "$repo_path"
}

# commits the changes in the current directory to the local Git client
function commit_changes {
  git add -A
  git commit -a -m "chore: update repository templates" -m "[skip ci] - updated repository templates to https://github.com/ory/meta/commit/$GITHUB_SHA"
}

# configures the Git client on CI
function configure_git_on_ci {
  # set git email & username
  bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
  # change global url from https://github.com/ to git@github.com:
  git config --global url."git@github.com:".insteadOf https://github.com/
}

# copy contributing guide to docs if docs exist
function copy_contributing_guide_to_docs {
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

# replicates the template files in templates/repository into the given project
function copy_templates {
  repo_path=$1
  repo_type=$2
	rm -rf "$repo_path/.github/ISSUE_TEMPLATE/"
	cp "templates/repository/common/CONTRIBUTING.md" "$repo_path/CONTRIBUTING.md"
	cp "templates/repository/common/SECURITY.md" "$repo_path/SECURITY.md"
	cp "templates/repository/common/LICENSE" "$repo_path/LICENSE"
	cp "templates/repository/common/CODE_OF_CONDUCT.md" "$repo_path/CODE_OF_CONDUCT.md"
	cp -n "templates/repository/common/.reference-ignore" "$repo_path/.reference-ignore" || true # copy only if it does not exist, as it is meant to help getting started
	cp -r "templates/repository/common/.github" "$repo_path/"
	cp -r "templates/repository/$repo_type/.github" "$repo_path/"
}

# creates a pull request with the changes on GitHub
# function create_pull_request {
# 	curl \
# 	  -X POST \
# 	  -H "Authorization: token $GITHUB_TOKEN" \
# 	  -H "Accept: application/vnd.github.v3+json" \
# 	  https://api.github.com/repos/$project/pulls \
# 	  -d '{"title":"chore: update repository template to '$hash'","body":"Updated repository templates to https://github.com/ory/meta/commit/'$GITHUB_SHA'.","head":"'$pushBranch'","base":"'$branch'"}' \
# 	) || true)
# }

# creates the workspace directory on disk and returns the path to it
function create_workspace {
  mktemp -d
}

function format_everything {
  npm i --legacy-peer-deps
  npm run format
}

# formats only the /docs folder
function format_docs {
	workdir=$1
  (
    cd "$workdir/docs"
    bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/prettier.sh)
    npm run format
  )
}

# pushes the committed changes from the local Git client to GitHub
function push_changes {
  git push origin HEAD:master
}

function substitutePlaceholders {
	project=$1
  discussions=$2
  human_name=$3
  substitute_placeholders_in_file ".github/ISSUE_TEMPLATE" "$project" "$discussions" "$human_name"
  substitute_placeholders_in_file ".github/pull_request_template.md" "$project" "$discussions" "$human_name"
  substitute_placeholders_in_file "CONTRIBUTING.md" "$project" "$discussions" "$human_name"
  substitute_placeholders_in_file "SECURITY.md" "$project" "$discussions" "$human_name"
  substitute_placeholders_in_file "CODE_OF_CONDUCT.md" "$project" "$discussions" "$human_name"
  substitute_placeholders_in_file "LICENSE" "$project" "$discussions" "$human_name"
}

# replaces placeholders like "$PROJECT" in the given file with the given values
function substitute_placeholders_in_file {
  file=$1
	project=$2
  discussions=$3
  human_name=$4
  if [ ! -f "$file" ]; then
    return
  fi
  if [[ "$project" = "ory/hydra" || $project = "ory/kratos" || $project = "ory/oathkeeper" || $project = "ory/keto" ]]; then
    env -i DISCUSSIONS="$discussions" REPOSITORY="$project" PROJECT="$human_name" /bin/bash -c "envsubst < \"$file\" | sponge \"$file\""
  else
    env -i DISCUSSIONS="https://github.com/orgs/ory/discussions" REPOSITORY="$project" PROJECT="$human_name" /bin/bash -c "envsubst < \"$file\" | sponge \"$file\""
  fi
}
