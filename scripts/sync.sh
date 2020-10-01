#!/bin/bash

set -Eexuo pipefail

bin=$(mktemp -d -t bin-XXXXXX)
export PATH="$PATH:$bin"

bash <(curl -s https://raw.githubusercontent.com/ory/ci/master/src/scripts/install/git.sh)
git config --global url."git@github.com:".insteadOf https://github.com/

function sync {
    cd "$( dirname "${BASH_SOURCE[0]}" )/.."
    workdir=$1
    branch=$2
    type=$3
    humanName=$4
    project=$5
    pushBranch="meta-$(date +%m-%d-%y-%H-%M-%S)"
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

    perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->\n#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
    perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->\n#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"

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
