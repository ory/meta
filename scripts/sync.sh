#!/bin/bash

set -Eexuo pipefail

bin=$(mktemp -d -t bin-XXXXXX)
export PATH="$PATH:$bin"

# get github api client
wget -O "$bin/gh.tar.gz" https://github.com/cli/cli/releases/download/v0.10.1/gh_0.10.1_linux_amd64.tar.gz
tar -xf "$bin/gh.tar.gz"
mv gh_0.10.1_linux_amd64/bin/gh "$bin/gh"
rm -rfd gh_0.10.1_linux_amd64

function sync {
    cd "$( dirname "${BASH_SOURCE[0]}" )/.."
    workdir=$1
    branch=$2
    type=$3
    humanName=$4
    pushBranch="docusaurus-$(date +%m-%d-%y-%H-%M-%S)"
    hash=$(echo $GITHUB_SHA | head -c 8)

    (cd "$workdir"; git checkout -b "$pushBranch")

    # Copy common templates
    cp -R "templates/repository/common/CONTRIBUTING.md" "$workdir/CONTRIBUTING.md"
    cp -R "templates/repository/common/SECURITY.md" "$workdir/SECURITY.md"
    cp -R "templates/repository/common/LICENSE" "$workdir/LICENSE"
    cp -R "templates/repository/common/.github" "$workdir/"

    # Copy specific templates for servers or library
    cp -R "templates/repository/$type/.github" "$workdir/"

    # Replace placeholders
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i -e "s|{{Project}}|$humanName|g" `find "$workdir/.github" -type f -print` "$workdir/CONTRIBUTING.md" "$workdir/SECURITY.md"
    else
      sed -e "s|{{Project}}|$humanName|g" `find "$workdir/.github" -type f -print` "$workdir/CONTRIBUTING.md" "$workdir/SECURITY.md"
    fi
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
    fi

    perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
    perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"

    (cd "$workdir"; \
      git add -A; \
      git status; \
      ( \
        git commit -a -m "docs: update repository templates" \
        && git push origin HEAD:"$pushBranch" \
        && gh pr create --repo "$1" --title "chore: update repository template to $hash" --body "Updated repository templates to master to https://github.com/ory/meta/commit/$GITHUB_SHA." \
      ) || true)
}
