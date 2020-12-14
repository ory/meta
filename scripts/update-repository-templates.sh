#!/bin/bash

set -Eexuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )/.."

npx doctoc ./templates/repository/common/CONTRIBUTING.md
npx doctoc ./templates/repository/common/SECURITY.md

workdir=$(mktemp -d)

function update {
    workdir=$(mktemp -d)
    name="$1"
    type="$2"
    branch="$3"
    humanName="$4"

    git clone "git@github.com:$name.git" "$workdir"

    # Clone repository
    (cd "$workdir"; \
      git checkout "$branch"; \
      git reset --hard HEAD; \
      git pull -ff)

    # Copy common templates
    cp -R "templates/repository/common/CONTRIBUTING.md" "$workdir/CONTRIBUTING.md"
    cp -R "templates/repository/common/SECURITY.md" "$workdir/SECURITY.md"
    cp -R "templates/repository/common/LICENSE" "$workdir/LICENSE"
    cp -R "templates/repository/common/.github/" "$workdir/.github/"

    # Copy specific templates for servers or library
    cp -R "templates/repository/$type/.github/" "$workdir/.github/"

    # Replace placeholders
    sed -i '' -e "s|{{Project}}|$humanName|g" `find "$workdir/.github" -type f -print` "$workdir/CONTRIBUTING.md" "$workdir/SECURITY.md"
    sed -i '' -e "s|{{Repo}}|$name|g" `find "$workdir/.github" -type f -print` "/.github/ISSUE_TEMPLATE/config.yml"

    perl -0pe 's#<!--\s*BEGIN ADOPTERS\s*-->.*<!--\s*END ADOPTERS\s*-->#`cat templates/repository/common/ADOPTERS.md`#gse' -i "$workdir/README.md"
    perl -0pe 's#<!--\s*BEGIN ECOSYSTEM\s*-->.*<!--\s*END ECOSYSTEM\s*-->#`cat templates/repository/common/PROJECTS.md`#gse' -i "$workdir/README.md"

    (cd "$workdir"; git add -A; (git commit -a -m "docs: update repository templates" && git push origin HEAD:master) || true)
}

update ory/oathkeeper server master Oathkeeper
update ory/keto server master Keto
update ory/hydra server master Hydra
update ory/kratos server master Kratos

update ory-cloud/oasis server master Oasis

update ory/hydra-login-consent-node library master "Hydra Login, Logout And Consent Node Example"
update ory/kratos-selfservice-ui-node library master "Kratos SelfService UI Node Example"

update ory/fosite library master Fosite
update ory/dockertest library v3 Dockertest
update ory/x library master X
update ory/herodot library master Herodot
update ory/graceful library master Graceful
update ory/examples library master Examples
update ory/k8s library master K8S
