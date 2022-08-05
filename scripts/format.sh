#!/bin/bash

set -Eexuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
source scripts/sync.sh

npx doctoc ./templates/repository/common/CONTRIBUTING.md
npx doctoc ./templates/repository/common/SECURITY.md
