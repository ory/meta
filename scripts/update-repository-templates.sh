#!/bin/bash

set -Eeuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )/.."

npx doctoc ./templates/repository/common/CONTRIBUTING.md
npx doctoc ./templates/repository/common/SECURITY.md

workdir=$(mktemp -d)

function update {
    workdir=$(mktemp -d -p "$1")
    name="$1"
    type="$2"
    branch="$3"
    humanName="$4"

    git clone "git@github.com:ory/$name.git" "$workdir"

    # Clone repository
    (cd "$workdir"; \
      git checkout "$branch"; \
      git reset --hard HEAD; \
      git git pull -ff)

    # Copy common templates
    cp -R "templates/repository/common/CONTRIBUTING.md" "$workdir/CONTRIBUTING.md"
    cp -R "templates/repository/common/SECURITY.md" "$workdir/SECURITY.md"
    cp -R "templates/repository/common/LICENSE" "$workdir/LICENSE"
    cp -R "templates/repository/common/.github/" "$workdir/.github/"

    # Copy specific templates for servers or library
    cp -R "templates/repository/$type/.github/" "$workdir/.github/"

    # Replace placeholders
    sed -i '' -e "s|{{Project}}|$humanName|g" `find "$workdir/.github/*" -type f -print` "$workdir/CONTRIBUTING.md" "$workdir/SECURITY.md"

    perl -0pe 's/<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->/`cat ADOPTERS.md`/gse' -i "$workdir/README.md"
    perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->#`cat ../../PROJECTS.md`#gse' -i "$workdir/README.md"

    echo "Wrote all changes to: $workdir"
}

update oathkeeper server master Oathkeeper
update keto server master Keto
update hydra server master Hydra
#update kratos server master Kratos
#
#update hydra-login-consent-node library master "Hydra Login, Logout And Consent Node Example"
#update kratos-selfservice-ui-node library master "Kratos SelfService UI Node Example"
#
#update fosite library master Fosite
#update dockertest library v3 Dockertest
#update x library master X
#update herodot library master Herodot
#update graceful library master Graceful
#update examples library master Examples
#update k8s library master K8S
