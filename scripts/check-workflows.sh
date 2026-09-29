#!/bin/bash

set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

templates=templates/repository/common/.github/workflows
live_licenses=.github/workflows/licenses.yml
failed=0

fail() {
	echo "check-workflows: $*" >&2
	failed=1
}

for file in "$templates"/*.yml "$live_licenses" .github/workflows/workflows.yml; do
	while IFS= read -r ref; do
		case "$ref" in
		./* | docker://*) ;;
		*@*)
			sha=${ref##*@}
			if ! [[ $sha =~ ^[0-9a-f]{40}$ ]]; then
				fail "$file: $ref is not pinned to a full commit SHA"
			fi
			;;
		*) fail "$file: $ref has no ref" ;;
		esac
	done < <(yq -r '.jobs[].steps[]?.uses // "" | select(. != "")' "$file")
done

if ! cmp -s "$templates/licenses.yml" "$live_licenses"; then
	fail "$live_licenses differs from $templates/licenses.yml"
fi

licenses="$templates/licenses.yml"
if [ "$(yq -o=json -I=0 '.jobs.check.permissions' "$licenses")" != '{"contents":"read"}' ]; then
	fail "$licenses: job check must have only contents: read"
fi
if [ -n "$(yq '.jobs.check.if // ""' "$licenses")" ]; then
	fail "$licenses: job check must run on every event"
fi
if yq -o=json '.jobs.check' "$licenses" | grep -q 'secrets\.'; then
	fail "$licenses: job check must not use secrets"
fi
if [ "$(yq -o=json -I=0 '.jobs.write.permissions' "$licenses")" != '{"contents":"write"}' ]; then
	fail "$licenses: job write must have only contents: write"
fi
if [ "$(yq '.jobs.write.needs' "$licenses")" != check ]; then
	fail "$licenses: job write must need job check"
fi
write_if=$(yq '.jobs.write.if // ""' "$licenses")
if [[ $write_if != *"github.event_name == 'push' && ("* ]]; then
	fail "$licenses: job write must run only on push"
fi
for branch in main master v3; do
	if [[ $write_if != *"'refs/heads/$branch'"* ]]; then
		fail "$licenses: job write must allow refs/heads/$branch"
	fi
done
if [ "$(yq '[.jobs.* | select(.permissions == null)] | length' "$licenses")" != 0 ]; then
	fail "$licenses: every job must declare permissions"
fi

exit "$failed"
