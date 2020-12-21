#!/bin/bash

# Causes the script to abort on error
set -Eexuo pipefail

# Set bin to temporary directory named bin-XXXXXX), set path to bin
bin=$(mktemp -d -t bin-XXXXXX)
export PATH="$PATH:$bin"

# Set git email & username as specified in git.sh, change global url from https://github.com/ to git@github.com:
bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
git config --global url."git@github.com:".insteadOf https://github.com/

function sync {

    # Change directory to the path of the invoking script, set variables workdir, branch, type, humanName, project, set upstream branch as pushBranch, 
    cd "$( dirname "${BASH_SOURCE[0]}" )/.."
    workdir=$1
    branch=$2
    type=$3
    humanName=$4
    project=$5
    # discussions="https://github.com/${REPOSITORY}/discussions"
    pushBranch="meta-$(date +%m-%d-%y-%H-%M-%S)"
    # set hash as github commit hash, first 8 bytes
    hash=$(echo $GITHUB_SHA | head -c 8)

    # in subshell, change directory to workdir, checkout git branch specified in pushBranch
    (cd "$workdir"; git checkout -b "$pushBranch")

    # Copy common templates to workdir
    cp -R "templates/repository/common/CONTRIBUTING.md" "$workdir/CONTRIBUTING.md"
    cp -R "templates/repository/common/SECURITY.md" "$workdir/SECURITY.md"
    cp -R "templates/repository/common/LICENSE" "$workdir/LICENSE"
    # Copy .reference-ignore only if it does not exist, as it is meant to help getting started
    cp -n "templates/repository/common/.reference-ignore" "$workdir/.reference-ignore" || true
    cp -R "templates/repository/common/.github" "$workdir/"

    # Copy specific templates for servers or library (depending on $type)
    cp -R "templates/repository/$type/.github" "$workdir/"

    # Replace placeholders - find in regular files (type f)
    # env clears environment and sets REPOSITORY and PROJECT as new env variables
    # /bin/bash -c execute commands in " " in the new environment 
    # envsubst: replace all env variables found ($f) with the ones specified 2 steps before, pipe to sponge and write to file
    for f in $(find "./.github/ISSUE_TEMPLATE" " ./.github/pull_request_template.md" "CONTRIBUTING.md" "SECURITY.md" "CODE_OF_CONDUCT.md" "LICENSE" -type f -print); do
        env -i REPOSITORY="$project" PROJECT="$humanName" /bin/bash -c "envsubst < \"$f\" | sponge \"$f\""
    done

    # Copy contributing guide to docs if docs exist
    if [ -d "$workdir/docs/docs" ]; then
      cat <<EOF > "$workdir/docs/docs/contributing.md"
---
id: contributing
title: Contribution Guidelines
---

EOF
        cat "$workdir/CONTRIBUTING.md" >> "$workdir/docs/docs/contributing.md"
        sed '/Contributing to/d' "$workdir/docs/docs/contributing.md"
        (
          cd "$workdir/docs"
          bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/prettier.sh)
          npm run format
        )
    fi

    # Add Adopters to README.md 
    perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->\n#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
    # Add Ecosystem (overview of all projects) to README.md
    perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->\n#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"

    # Commit changes - line by line: change to workdir, add all files to git index, show working tree status, commit changes with "chore:..." title, push to upstream 
    # curl: make pull request through Github API with token to authenticate and the PR titles, body. With pushBranch (the "script" branch) as head and the specified branch (main) as base
    (cd "$workdir"; \
      git add -A; \
      git status; \
      ( \
        git commit -a -m "chore: update repository templates" && \
        git push --set-upstream origin "$pushBranch" && \
        curl \
          -X POST \
          -H "Authorization: token $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github.v3+json" \
          https://api.github.com/repos/$project/pulls \
          -d '{"title":"chore: update repository template to '$hash'","body":"Updated repository templates to https://github.com/ory/meta/commit/'$GITHUB_SHA'.","head":"'$pushBranch'","base":"'$branch'"}' \
      ) || true)
}
