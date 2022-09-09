#!/bin/bash
set -Eexuo pipefail # abort the script on error

# replicate shared data from this repo into all repositories at Ory
function replicate_all {
	# verify arguments
	local -r workspace=$1
	if [ -z "$workspace" ]; then
		echo "ERROR (sync_all): please provide the path to a workspace directory"
		exit 1
	fi
	if [ ! -d "$workspace" ]; then
		echo "ERROR (sync_all): provided workspace ($workspace) is not a directory"
		exit 1
	fi
	local -r persist=$2
	if [ "$persist" != "push" ] && [ "$persist" != "commit" ] && [ "$persist" != "keep" ]; then
		echo "ERROR (sync_all): unknown value for \"persist\" argument: \"$persist\". Please provide either \"push\", \"commit\", or \"keep\"."
		exit 1
	fi
	replicate ory/hydra server "Hydra" "$workspace" "$persist"
	replicate ory/keto server "Keto" "$workspace" "$persist"
	replicate ory/oathkeeper server "Oathkeeper" "$workspace" "$persist"
	replicate ory/kratos server "Kratos" "$workspace" "$persist"
	replicate ory/hydra-login-consent-node library "Hydra Login, Logout And Consent Node Example" "$workspace" "$persist"
	replicate ory/docs library "Documentation" "$workspace" "$persist"
	replicate ory/cli library "CLI" "$workspace" "$persist"
	replicate ory/kratos-selfservice-ui-node library "Kratos SelfService UI Node Example" "$workspace" "$persist"
	replicate ory/kratos-selfservice-ui-react-native library "Kratos SelfService UI React Native Example" "$workspace" "$persist"
	replicate ory/fosite library "Fosite" "$workspace" "$persist"
	replicate ory/dockertest library "Dockertest" "$workspace" "$persist"
	replicate ory/herodot library "Herodot" "$workspace" "$persist"
	replicate ory/graceful library "Graceful" "$workspace" "$persist"
	replicate ory/themes library "Themes" "$workspace" "$persist"
	replicate ory/k8s library "Kubernetes Resources" "$workspace" "$persist"
	replicate ory/x library "X" "$workspace" "$persist"
	replicate ory/web library "Web" "$workspace" "$persist"
	replicate ory/closed-reference-notifier action "Closed Reference Notifier" "$workspace" "$persist"
	replicate ory/label-sync-action action "Label Sync Action" "$workspace" "$persist"
	replicate ory/milestone-action action "Milestone Action" "$workspace" "$persist"
	replicate ory/prettier-styles action "Prettier Styles" "$workspace" "$persist"
	replicate ory/build-buf-action action "Buildbuf Action" "$workspace" "$persist"
	replicate ory/examples library "Examples" "$workspace" "$persist"
	replicate ory/hydra-maester library "Ory Hydra Maester" "$workspace" "$persist"
	replicate ory/oathkeeper-maester library "Ory Oathkeeper Maester" "$workspace" "$persist"
	replicate ory/sdk library "Ory SDK" "$workspace" "$persist"
	replicate ory/platform library "Ory Platform" "$workspace" "$persist"
	replicate ory/keto-client-dotnet library "Ory Keto Dotnet Client" "$workspace" "$persist"
	replicate ory/keto-client-java library "Ory Keto Java Client" "$workspace" "$persist"
	replicate ory/keto-client-rust library "Ory Keto Rust Client" "$workspace" "$persist"
	replicate ory/keto-client-dart library "Ory Keto Dart Client" "$workspace" "$persist"
	replicate ory/keto-client-js library "Ory Keto JavaScript Client" "$workspace" "$persist"
	replicate ory/keto-client-php library "Ory Keto PHP Client" "$workspace" "$persist"
	replicate ory/keto-client-go library "Ory Keto Go Client" "$workspace" "$persist"
	replicate ory/keto-client-ruby library "Ory Keto Ruby Client" "$workspace" "$persist"
	replicate ory/keto-client-python library "Ory Keto Python Client" "$workspace" "$persist"
	replicate ory/kratos-client-dotnet library "Ory Kratos Dotnet Client" "$workspace" "$persist"
	replicate ory/kratos-client-java library "Ory Kratos Java Client" "$workspace" "$persist"
	replicate ory/kratos-client-rust library "Ory Kratos Rust Client" "$workspace" "$persist"
	replicate ory/kratos-client-dart library "Ory Kratos Dart Client" "$workspace" "$persist"
	replicate ory/kratos-client-js library "Ory Kratos JavaScript Client" "$workspace" "$persist"
	replicate ory/kratos-client-php library "Ory Kratos PHP Client" "$workspace" "$persist"
	replicate ory/kratos-client-go library "Ory Kratos Go Client" "$workspace" "$persist"
	replicate ory/kratos-client-ruby library "Ory Kratos Ruby Client" "$workspace" "$persist"
	replicate ory/kratos-client-python library "Ory Kratos Python Client" "$workspace" "$persist"
	replicate ory/hydra-client-dotnet library "Ory Hydra Dotnet Client" "$workspace" "$persist"
	replicate ory/hydra-client-java library "Ory Hydra Java Client" "$workspace" "$persist"
	replicate ory/hydra-client-rust library "Ory Hydra Rust Client" "$workspace" "$persist"
	replicate ory/hydra-client-dart library "Ory Hydra Dart Client" "$workspace" "$persist"
	replicate ory/hydra-client-js library "Ory Hydra JavaScript Client" "$workspace" "$persist"
	replicate ory/hydra-client-php library "Ory Hydra PHP Client" "$workspace" "$persist"
	replicate ory/hydra-client-go library "Ory Hydra Go Client" "$workspace" "$persist"
	replicate ory/hydra-client-ruby library "Ory Hydra Ruby Client" "$workspace" "$persist"
	replicate ory/hydra-client-python library "Ory Hydra Python Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-dotnet library "Ory Oathkeeper Dotnet Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-java library "Ory Oathkeeper Java Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-rust library "Ory Oathkeeper Rust Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-dart library "Ory Oathkeeper Dart Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-js library "Ory Oathkeeper JavaScript Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-php library "Ory Oathkeeper PHP Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-go library "Ory Oathkeeper Go Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-ruby library "Ory Oathkeeper Ruby Client" "$workspace" "$persist"
	replicate ory/oathkeeper-client-python library "Ory Oathkeeper Python Client" "$workspace" "$persist"
}

# replicates the info in this repository into the given target repository
function replicate {
	# verify arguments
	local -r repo_id=$1
	if [ -z "$repo_id" ]; then
		echo "ERROR (replicate): argument \"repo_id\" is missing. Please provide the XXX part of the URL: https://github.com/XXX"
		exit 1
	fi
	local -r repo_type=$2
	if [ "$repo_type" != "action" ] && [ "$repo_type" != "library" ] && [ "$repo_type" != "server" ]; then
		echo "ERROR (replicate): invalid argument \"repo_type\": \"$repo_type\". Please provide either \"action\", \"library\", or \"server\""
		exit 1
	fi
	local -r human_name=$3
	if [ -z "$human_name" ]; then
		echo 'ERROR (replicate): argument "human_name" is missing'
		exit 1
	fi
	local -r workspace=$4
	if [ -z "$workspace" ]; then
		echo 'ERROR (replicate): argument "workspace" is missing'
		exit 1
	fi
	local -r persist=$5
	if [ "$persist" != "push" ] && [ "$persist" != "commit" ] && [ "$persist" != "keep" ]; then
		echo "ERROR (replicate): Unknown value for \"persist\" argument: \"$persist\". Please provide either \"push\", \"commit\", or \"keep\"."
		exit 1
	fi

	printf "\n\n\n########################################################################################\n\n%s (%s)\n\n########################################################################################\n\n" "$repo_id" "$repo_type"

	# clone if the codebase doesn't exist in the workspace yet
	local -r repo_name=$(basename "$repo_id")
	local -r repo_path="$workspace/$repo_name"
	if [ ! -d "$repo_path" ]; then
		clone "$repo_id" "$repo_path"
	fi

	# replicate changes from meta into this repo
	copy_templates "$repo_path" "$repo_type"
	substitutePlaceholders "$repo_id" "$repo_path" "https://github.com/$repo_id/discussions" "$human_name"
	if [ -d "$repo_id/docs/docs" ]; then
		copy_contributing_guide_to_docs "$repo_id"
	fi
	add_adopters_to_readme "$repo_id"
	add_ecosystem_to_readme "$repo_id"
	if test -f package.json; then
		format "$repo_path"
	fi

	# optionally commit
	if [ "$persist" == "commit" ] || [ "$persist" == "push" ]; then
		commit_changes "$repo_path"
	fi
	if [ "$persist" == "push" ]; then
		push_changes
	fi
}

############################################################
### INDIVIDUAL ACTIVITIES

function add_adopters_to_readme {
	local -r workdir=$1
	perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->\n#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
}

# adds an overview of all projects to README.md
function add_ecosystem_to_readme {
	local -r workdir=$1
	perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->\n#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"
}

# clones the given project onto the local machine
function clone {
	local -r repo_id=$1
	local -r repo_path=$2
	git clone --depth 1 "git@github.com:$repo_id.git" "$repo_path"
}

# commits the changes in the current directory to the local Git client
function commit_changes {
	local -r repo_path=$1
	(
		cd "$repo_path"
		git add -A
		git commit -a -m "chore: update repository templates" -m "[skip ci] - updated repository templates to https://github.com/ory/meta/commit/$GITHUB_SHA" || true
	)
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
	local -r workdir=$1
	local -r file="$workdir/docs/docs/contributing.md"
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
	local -r repo_path=$1
	local -r repo_type=$2
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

function format {
	local -r repo_path=$1
	(
		cd "$repo_path"
		if [ -f 'package.json' ] && [ -f 'package-lock.json' ]; then
			npm i --legacy-peer-deps
			npm exec -- prettier --write "*.md" .github
		fi
	)
}

function install_dependencies_on_ci {
	sudo apt-get update -y
	sudo apt-get install -y moreutils gettext-base
}

# pushes the committed changes from the local Git client to GitHub
function push_changes {
	git push
}

function substitutePlaceholders {
	local -r repo_id=$1
	local -r repo_path=$2
	local -r repo_discussions=$3
	local -r human_name=$4
	for file in "$repo_path"/.github/ISSUE_TEMPLATE/*; do
		substitute_placeholders_in_file "$file" "$repo_id" "$repo_discussions" "$human_name"
	done
	substitute_placeholders_in_file "$repo_path/.github/pull_request_template.md" "$repo_id" "$repo_discussions" "$human_name"
	substitute_placeholders_in_file "$repo_path/CONTRIBUTING.md" "$repo_id" "$repo_discussions" "$human_name"
	substitute_placeholders_in_file "$repo_path/SECURITY.md" "$repo_id" "$repo_discussions" "$human_name"
	substitute_placeholders_in_file "$repo_path/CODE_OF_CONDUCT.md" "$repo_id" "$repo_discussions" "$human_name"
	substitute_placeholders_in_file "$repo_path/LICENSE" "$repo_id" "$repo_discussions" "$human_name"
}

# replaces placeholders like "$PROJECT" in the given file with the given values
function substitute_placeholders_in_file {
	local -r file=$1
	local -r repo_id=$2
	local -r repo_discussions=$3
	local -r human_name=$4
	case "$repo_id" in
	"ory/hydra" | "ory/kratos" | "ory/oathkeeper" | "ory/keto")
		discussions=$repo_discussions
		;;
	*)
		discussions="https://github.com/orgs/ory/discussions"
		;;
	esac
	if [ -f "$file" ]; then
		env -i DISCUSSIONS="$discussions" REPOSITORY="$repo_id" PROJECT="$human_name" /bin/bash -c "envsubst < \"$file\" | sponge \"$file\""
	fi
}
