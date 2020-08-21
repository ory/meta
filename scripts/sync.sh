#!/bin/bash

set -Eexuo pipefail

function sync {
    workdir=$1
    branch=$2
    type=$3
    humanName=$4

    # Copy common templates
    cp -R "templates/repository/common/CONTRIBUTING.md" "$workdir/CONTRIBUTING.md"
    cp -R "templates/repository/common/SECURITY.md" "$workdir/SECURITY.md"
    cp -R "templates/repository/common/LICENSE" "$workdir/LICENSE"
    cp -R "templates/repository/common/.github/" "$workdir/.github/"

    # Copy specific templates for servers or library
    cp -R "templates/repository/$type/.github/" "$workdir/.github/"

    # Replace placeholders
    sed -i '' -e "s|{{Project}}|$humanName|g" `find "$workdir/.github" -type f -print` "$workdir/CONTRIBUTING.md" "$workdir/SECURITY.md"

    perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
    perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"

    (cd "$workdir"; \
      git add -A; \
      git status; \
      ( \
        git commit -a -m "docs: update repository templates" \
        && git push origin HEAD:$branch \
      ) || true)
}
