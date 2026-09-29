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
	if ! refs=$(yq -r '(.jobs[].uses, .jobs[].steps[]?.uses) | select(. != null)' "$file"); then
		fail "$file: cannot parse"
		continue
	fi
	while IFS= read -r ref; do
		[ -n "$ref" ] || continue
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
	done <<<"$refs"
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
write_if=$(yq '.jobs.write.if // ""' "$licenses" | tr -s ' \n' ' ' | sed 's/ $//')
expected_if="\${{ github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master' || github.ref == 'refs/heads/v3') }}"
if [ "$write_if" != "$expected_if" ]; then
	fail "$licenses: job write must run only on pushes to main, master and v3"
fi
if [ "$(yq '[.jobs.* | select(.permissions == null)] | length' "$licenses")" != 0 ]; then
	fail "$licenses: every job must declare permissions"
fi

exit "$failed"
