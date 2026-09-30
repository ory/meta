#!/bin/bash

set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! yq --version 2>&1 | grep -q mikefarah; then
	echo "check-workflows: requires mikefarah/yq v4" >&2
	exit 1
fi

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
		\$/*@*) fail "$file: $ref must not have a ref" ;;
		./* | \$/?* | docker://*) ;;
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
if [ "$(yq '.jobs.check | has("if")' "$licenses")" != false ]; then
	fail "$licenses: job check must run on every event"
fi
if [ "$(yq -o=json -I=0 '.on | keys' "$licenses")" != '["pull_request","push"]' ]; then
	fail "$licenses: triggers must be only pull_request and push"
fi
if yq -o=json 'del(.jobs.write)' "$licenses" | grep -q 'secrets'; then
	fail "$licenses: only job write may use secrets"
fi
if [ "$(yq -o=json -I=0 '.jobs.write.permissions' "$licenses")" != '{"contents":"write"}' ]; then
	fail "$licenses: job write must have only contents: write"
fi
if [ "$(yq -o=json -I=0 '[.jobs.write.needs] | flatten' "$licenses")" != '["check"]' ]; then
	fail "$licenses: job write must need job check"
fi
write_if=$(yq '.jobs.write.if // ""' "$licenses" | tr -s ' \n' ' ' | sed 's/ $//')
expected_if="\${{ github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master' || github.ref == 'refs/heads/v3' || github.ref == 'refs/heads/v4') }}"
if [ "$write_if" != "$expected_if" ]; then
	fail "$licenses: job write must run only on pushes to main, master, v3 and v4"
fi
if [ "$(yq '[.jobs.* | select(.permissions == null)] | length' "$licenses")" != 0 ]; then
	fail "$licenses: every job must declare permissions"
fi

exit "$failed"
