#!/usr/bin/env bash
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

	declare -A name_map=(
		["hydra"]="Hydra"
		["keto"]="Keto"
		["oathkeeper"]="Oathkeeper"
		["kratos"]="Kratos"
		["hydra-login-consent-node"]="Hydra Login, Logout And Consent Node Example"
		["docs"]="Documentation"
		["cli"]="CLI"
		["kratos-selfservice-ui-node"]="Kratos SelfService UI Node Example"
		["kratos-selfservice-ui-react-native"]="Kratos SelfService UI React Native Example"
		["fosite"]="Fosite"
		["dockertest"]="Dockertest"
		["herodot"]="Herodot"
		["graceful"]="Graceful"
		["k8s"]="Kubernetes Resources"
		["x"]="X"
		["closed-reference-notifier"]="Closed Reference Notifier"
		["label-sync-action"]="Label Sync Action"
		["milestone-action"]="Milestone Action"
		["build-buf-action"]="Buildbuf Action"
		["examples"]="Examples"
		["hydra-maester"]="Ory Hydra Maester"
		["oathkeeper-maester"]="Ory Oathkeeper Maester"
		["sdk"]="Ory SDK"
		["network"]="Ory Network"
		["elements"]="Ory Elements"
		["keto-client-dotnet"]="Ory Keto Dotnet Client"
		["keto-client-java"]="Ory Keto Java Client"
		["keto-client-rust"]="Ory Keto Rust Client"
		["keto-client-dart"]="Ory Keto Dart Client"
		["keto-client-js"]="Ory Keto JavaScript Client"
		["keto-client-php"]="Ory Keto PHP Client"
		["keto-client-go"]="Ory Keto Go Client"
		["keto-client-ruby"]="Ory Keto Ruby Client"
		["keto-client-python"]="Ory Keto Python Client"
		["kratos-client-dotnet"]="Ory Kratos Dotnet Client"
		["kratos-client-java"]="Ory Kratos Java Client"
		["kratos-client-rust"]="Ory Kratos Rust Client"
		["kratos-client-dart"]="Ory Kratos Dart Client"
		["kratos-client-js"]="Ory Kratos JavaScript Client"
		["kratos-client-php"]="Ory Kratos PHP Client"
		["kratos-client-go"]="Ory Kratos Go Client"
		["kratos-client-ruby"]="Ory Kratos Ruby Client"
		["kratos-client-python"]="Ory Kratos Python Client"
		["hydra-client-dotnet"]="Ory Hydra Dotnet Client"
		["hydra-client-java"]="Ory Hydra Java Client"
		["hydra-client-rust"]="Ory Hydra Rust Client"
		["hydra-client-dart"]="Ory Hydra Dart Client"
		["hydra-client-js"]="Ory Hydra JavaScript Client"
		["hydra-client-php"]="Ory Hydra PHP Client"
		["hydra-client-go"]="Ory Hydra Go Client"
		["hydra-client-ruby"]="Ory Hydra Ruby Client"
		["hydra-client-python"]="Ory Hydra Python Client"
		["oathkeeper-client-dotnet"]="Ory Oathkeeper Dotnet Client"
		["oathkeeper-client-java"]="Ory Oathkeeper Java Client"
		["oathkeeper-client-rust"]="Ory Oathkeeper Rust Client"
		["oathkeeper-client-dart"]="Ory Oathkeeper Dart Client"
		["oathkeeper-client-js"]="Ory Oathkeeper JavaScript Client"
		["oathkeeper-client-php"]="Ory Oathkeeper PHP Client"
		["oathkeeper-client-go"]="Ory Oathkeeper Go Client"
		["oathkeeper-client-ruby"]="Ory Oathkeeper Ruby Client"
		["oathkeeper-client-python"]="Ory Oathkeeper Python Client"
	)

	declare -A type_map=(
		["hydra"]="server"
		["keto"]="server"
		["oathkeeper"]="server"
		["kratos"]="server"
		["closed-reference-notifier"]="action"
		["label-sync-action"]="action"
		["milestone-action"]="action"
		["build-buf-action"]="action"
		["ci"]="action"
	)

	declare -a exclusion_list=(
		"meta"
		".github"
	)

	gh repo list ory --visibility public --no-archived --source --json name -L 1000 | jq -r '.[] | .name' | while read -r repo_name; do
		# Check if the repository is in the exclusion list
		for excluded_repo in "${exclusion_list[@]}"; do
			if [[ "$repo_name" == "$excluded_repo" ]]; then
				echo "Skipping ${repo_name} as it is in the exclusion list."
				continue 2
			fi
		done

		human_name=${name_map[$repo_name]:-$repo_name}
		repo_type=${type_map[$repo_name]:-library}
		replicate "ory/$repo_name" "$repo_type" "$human_name" "$workspace" "$persist"
	done
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

	{ printf "\n\n\n\n\n\n\n########################################################################################\n\n  %s (%s)\n\n########################################################################################\n\n\n" "$repo_id" "$repo_type"; } 2>/dev/null

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
		copy_contributing_guide_to_docs "$repo_path"
	fi
	add_adopters_to_readme "$repo_path"
	add_ecosystem_to_readme "$repo_path"
	if test -f "$repo_path/package-lock.json"; then
		format "$repo_path"
	fi

	# optionally commit
	if [ "$persist" == "commit" ] || [ "$persist" == "push" ]; then
		commit_changes "$repo_path"
	fi
	if [ "$persist" == "push" ]; then
		push_changes "$repo_path"
	fi
}

############################################################
### INDIVIDUAL ACTIVITIES

function add_adopters_to_readme {
	header "ADDING ADOPTERS TO README"
	local -r repo_path=$1
	perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->\n#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$repo_path/README.md"
}

# adds an overview of all projects to README.md
function add_ecosystem_to_readme {
	header "ADDING ECOSYSTEM TO README"
	local -r repo_path=$1
	perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->\n#`cat templates/repository/common/PROJECTS.md`#gse' -i "$repo_path/README.md"
}

# clones the given project onto the local machine
function clone {
	header "CLONING"
	local -r repo_id=$1
	local -r repo_path=$2
	git clone --depth 1 "https://github.com/$repo_id.git" "$repo_path"
}

# commits the changes in the current directory to the local Git client
function commit_changes {
	header "COMMITTING"
	local -r repo_path=$1
	(
		cd "$repo_path"
		git add -A
		git restore --staged package-lock.json || true
		git commit -a -m "chore: update repository templates to https://github.com/ory/meta/commit/$GITHUB_SHA" || true
	)
}

# configures the Git client on CI
function configure_git_on_ci {
	header "CONFIGURING GIT"
	# set git email & username
	bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
	# change global url from https://github.com/ to git@github.com:
	# git config --global url."git@github.com:".insteadOf https://github.com/
}

# copy contributing guide to docs if docs exist
function copy_contributing_guide_to_docs {
	header "COPYING WRITING GUIDE TO DOCS"
	local -r repo_path=$1
	local -r file="$repo_path/docs/docs/contributing.md"
	cat <<EOF >"$file"
---
id: contributing
title: Contribution Guidelines
---

EOF
	cat "$repo_path/CONTRIBUTING.md" >>"$file"
	sed '/Contributing to/d' "$file"
}

# replicates the template files in templates/repository into the given project
function copy_templates {
	header "COPYING TEMPLATES"
	local -r repo_path=$1
	local -r repo_type=$2
	rm -rf "$repo_path/.github/ISSUE_TEMPLATE/"
	.bin/ory dev headers cp "templates/repository/common/CONTRIBUTING.md" "$repo_path/CONTRIBUTING.md"
	.bin/ory dev headers cp "templates/repository/common/SECURITY.md" "$repo_path/SECURITY.md"
	.bin/ory dev headers cp "templates/repository/common/LICENSE" "$repo_path/LICENSE"
	.bin/ory dev headers cp "templates/repository/common/CODE_OF_CONDUCT.md" "$repo_path/CODE_OF_CONDUCT.md"
	.bin/ory dev headers cp -n "templates/repository/common/.reference-ignore" "$repo_path/.reference-ignore" || true # copy only if it does not exist, as it is meant to help getting started
	.bin/ory dev headers cp -r "templates/repository/common/.github" "$repo_path/"
	.bin/ory dev headers cp -r "templates/repository/$repo_type/.github" "$repo_path/"
	# copy pull-request templates as-is because they are displayed verbatim and shouldn't contain the comment header
	if [ -f "templates/repository/$repo_type/.github/pull_request_template.md" ]; then
		cp "templates/repository/$repo_type/.github/pull_request_template.md" "$repo_path/.github"
	fi
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
  header "FORMATTING"
  local -r repo_path=$1
  if [ ! -f "$repo_path/package.json" ]; then
    echo "Skipping formatting as package.json does not exist in $repo_path"
    return
  fi
  (
    cd "$repo_path"
    npm ci --legacy-peer-deps
    npx prettier --write "*.md" .github
  )
}

function install_dependencies_on_ci {
	header "INSTALLING DEPENDENCIES"
	sudo apt-get update -y
	sudo apt-get install -y moreutils gettext-base
	curl https://raw.githubusercontent.com/ory/meta/master/install.sh | bash -s -- -b .bin ory v0.1.48
}

# pushes the committed changes from the local Git client to GitHub
function push_changes {
	header "PUSHING TO GITHUB"
	local -r repo_path=$1
	(
		cd "$repo_path"
		git push
	)
}

function substitutePlaceholders {
	header "SUBSTITUTING PLACEHOLDERS"
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
	header "SUBSTITUTING PLACEHOLDERS IN FILE"
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

function header {
	{ set +x; } 2>/dev/null
	echo
	echo "$1" ...
	echo
	set -x
}
